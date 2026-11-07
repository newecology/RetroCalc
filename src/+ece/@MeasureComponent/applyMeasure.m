function applyMeasure(obj,bldg,snapshotTargets)
%APPLYMEASURE Method to apply a Measure onto an input Building.
%  The MC in question is applied to the Building based on the kind of MC it
%  is (add/delete/change) and the properties of the Building.
%
%  snapshotTargets (optional): array of object handles that were resolved
%  from an Object#-based FilterCriteria at ECM entry, before earlier MCs
%  shifted the target collection. When provided, Edit/Delete operate on
%  these handles rather than re-parsing FilterCriteria. Callers other than
%  ECM.applyECM should omit this argument; the existing FilterCriteria
%  parse path is preserved when it is empty.

%% Arguments Block
% Ensure inputs are the correct size and type.
arguments
    % obj: Self-referential MeasureComponent object.
    obj (1,1) ece.MeasureComponent

    % building: Building object that MeasureComponent is applied to.
    bldg (1,1) ece.Building

    % snapshotTargets: Optional pre-resolved handles from ECM-entry snapshot.
    snapshotTargets = []

end %argblock

%% Search for Building Object MC Addresses
% The first step of applying an MC is to get the list of the corresponding
% object that the MC is applying to. This can be an object array within the
% Building, OR the Building itself.
% --- Determine ObjectOfReference
% Compare MC's string to Building or other to determine the object being
% impacted.
if strcmp(obj.ObjectOfReference,"Building")
    % Referencing Building itself.
    impctObj = bldg;

else
    % Referencing object array within Building.
    impctObj = bldg.(obj.ObjectVarName);

end %endif

%% Apply Change to Building Objects
% The second step of applying an MC involves determining what change is
% requested (insert/edit/delete) and then calling the correct code to apply
% that change to the impacted Objects retrieved earlier.

% Determine operation by switch/case. Accept "update" as a synonym for
% "edit" so MCs created by the Excel ECM import path (which writes
% "update" into Operation) dispatch correctly — the UI path writes "Edit".
op = lower(string(obj.Operation));
if op == "update"
    op = "edit";
end
switch op
    case "insert"
        % -- Insert
        % Insert Operation adds a new object of the specified type to the
        % Building's array of object.
        for k = 1 : obj.InsertQuantity
            idx = numel(impctObj) + 1;
            impctObj(idx) = ece.(obj.ObjectOfReference);
            applyPropertyValues(impctObj(idx),obj.InsertedProperty);
        end %forloop

    case "edit"
        % -- Edit
        % Edit Operation modifies properties of objects of the specified
        % type in Building that fall under a specific filter criteria.
        % If ECM.applyECM pre-resolved this MC's Object# criterion to
        % actual handles, resolve those handles to current positions in
        % the (possibly-shifted) live array; otherwise re-parse
        % FilterCriteria against the current live state.
        if ~isempty(snapshotTargets)
            idx = [];
            for h = 1:numel(snapshotTargets)
                pos = find(arrayfun( ...
                    @(x) x == snapshotTargets(h), impctObj));
                idx = [idx; pos(:)]; %#ok<AGROW>
            end
        else
            idx = parseToGetIndex(impctObj,obj.FilterCriteria);
        end
        % Parse PropertyToChange for an indexed form "Name(k)" or an
        % annotated form "Name(k) — Label". The regex anchors at string
        % start and matches a bare identifier followed by (digits); any
        % trailing " — label" from the dropdown display is ignored.
        idxTok = regexp(obj.PropertyToChange, '^(\w+)\((\d+)\)', 'tokens', 'once');
        if ~isempty(idxTok)
            basePropName  = string(idxTok{1});
            targetElemIdx = str2double(idxTok{2});
        else
            basePropName  = obj.PropertyToChange;
            targetElemIdx = [];
        end

        for k = 1 : numel(idx)
            thdx = idx(k);
            if isempty(targetElemIdx)
                % Whole-property path (unchanged behavior).
                cval = impctObj(thdx).(basePropName);
                calcVal = applyOperation(cval,obj.UpdateType,obj.ValueForChange);
                try
                    impctObj(thdx).(basePropName) = calcVal;
                catch
                    % Direct assignment failed — likely an enum property receiving a string.
                    targetClass = class(impctObj(thdx).(basePropName));
                    impctObj(thdx).(basePropName) = feval(targetClass, string(calcVal));
                end
            else
                % Indexed-element path: mutate a single slot of the array
                % property, leaving the other elements untouched.
                arrVal = impctObj(thdx).(basePropName);
                cval = arrVal(targetElemIdx);
                calcVal = applyOperation(cval,obj.UpdateType,obj.ValueForChange);
                arrVal(targetElemIdx) = calcVal;
                impctObj(thdx).(basePropName) = arrVal;
            end
        end %forloop

    case "delete"
      % -- Delete
      % If ECM.applyECM pre-resolved this MC's Object# criterion to actual
      % handles, use those (snapshot semantics — matches what the user
      % labelled in the UI against the pristine collection).
      if ~isempty(snapshotTargets)
          keepMask = true(numel(impctObj),1);
          for h = 1:numel(snapshotTargets)
              keepMask = keepMask & arrayfun( ...
                  @(x) x ~= snapshotTargets(h), impctObj);
          end
          impctObj = impctObj(keepMask);
      else
          if ismissing(obj.FilterCriteria) || strlength(obj.FilterCriteria) == 0
              warning("applyMeasure:emptyDeleteFilter", ...
                  "MeasureComponent has Operation=Delete but empty FilterCriteria; skipping to avoid wiping entire %s collection.", ...
                  obj.ObjectVarName);
              return
          end
          idx = parseToGetIndex(impctObj, obj.FilterCriteria);
          impctObj(idx) = [];
      end

end %switch/case

%% Write Back Changes to Impacted Object
% This step may be pseudo-redundant, as the changes should be reflected in
% the object collections by reference already, but this will certify that
% the updates are assigned back. 
%    Note: This update is done in the same way, determining if the overall
%    Building is updated or just the object array.
% -- Determine Which Object is Impacted
% Check if Building or sub-object array in Building.
if strcmp(obj.ObjectOfReference,"Building")
    % Update referenced building itself.
    bldg = impctObj;

else
    % Update referenced object array within Building.
    bldg.(obj.ObjectVarName) = impctObj;

end %endif

end %function


function applyPropertyValues(cObj,prpStr)
% APPLYPROPERTYVALUES: Helper method to parse the insert_property string 
% into commands and assigns the provided values to each property of a 
% newly inserted objects.

% The prpStr is formatted in such a way that it contains sets of
% propertynames and assigned values separated by semicolons:
%    Ex: "Name="Default Name";Area_ft2=[0];
% String values are bounded by "", and numeric values are bounded by [].
% A Regex will be created to parse these into a string array of values that
% can be eval'd to do the appropriate string extraction.

% Create REGEX to split (Explanation Below)
%   [^=]+ → One or more non-equals characters (the property name)
%   = → The equals sign
%   (?: ... | ... ) → Non-capturing group for either quoted or bracketed value
%   "[^\"]*" → Double-quoted string (no internal quotes)
%   \[[^\]]*\] → Bracketed string (no internal closing brackets)
%   ; → ends in semicolon
regPattern = '[^=]+=(?:"[^"]*"|\[[^\]]*\]);';

% Extract Matches
matches = regexp(prpStr,regPattern,"match")';

% Convert matches to strings for evaluation with prefix (cobj.)
evalStrings = "cObj." + string(matches);

% Iteratively run each eval string.
for evalStrIdx = 1 : numel(evalStrings)
    try
        eval(evalStrings(evalStrIdx))
    catch
        % Eval failed — likely assigning a string to an enum property.
        % Parse property name and value, then convert to target type.
        tok = regexp(evalStrings(evalStrIdx), 'cObj\.(\w+)\s*=\s*"([^"]*)"', 'tokens');
        if ~isempty(tok)
            propName = tok{1}{1};
            propVal  = tok{1}{2};
            targetClass = class(cObj.(propName));
            try
                cObj.(propName) = feval(targetClass, propVal);
            catch ME2
                warning('applyMeasure: could not set %s to "%s": %s', ...
                    propName, propVal, ME2.message);
            end
        end
    end
end %forloop

end %function

function idx = parseToGetIndex(cObj,crtStr)
% PARSETOGETINDEX: parses the criteria string into logical operations and
% apply that on the object to find out the index of objects in that object
% array that fulfills the criteria.

% Get number of objects
numObjs = numel(cObj);

% Condition check
if numObjs > 0
    % Default Index to None of the Elements in Array
    idx = false(numObjs,1);
else
    idx = [];
    return
end

% -- Parse Criteria String
% Determine the filtering index from strings, checking if a filter is even
% applied before parsing the filter language.
filterExists = ~strcmp(crtStr,"");
if filterExists
    % --  Criteria for Filter Exists
    % Determine if criteria is logical or index-based.
    % If index-based, it will contain "Object#"
    isIndexBased = contains(crtStr,"Object#");

    if isIndexBased
        % -- Parse Index Filter
        % If it's an index filter, should be in the form of:
        %  "Object#: 1,2,3...".
        % Extract numbers using string pattern.
        indiceStrings = extract(crtStr,digitsPattern);

        % Convert index string to numbers, and then sort for posterity.
        indicNums = str2double(indiceStrings);

        % Filter out-of-range indices rather than clipping them —
        % clip(5,1,3)=3 silently mapped e.g. "Object#: 5" on a 3-element
        % collection to element 3. Now out-of-range indices are skipped,
        % consistent with the snapshot path in ECM.applyECM.
        indicNums = indicNums(indicNums >= 1 & indicNums <= numObjs);

        % Set Idx values at nums to true;
        idx(indicNums) = true;

    else
        % -- Parse Logical Filter
        % Parse the logical strings into an index flag.
        crtStr  = strrep(crtStr,"(", "(obj.");
        crtStr  = strrep(crtStr,"AND", "&&");
        crtStr  = strrep(crtStr,"OR", "||");

        % Iterate through each object in array to determine if it should be
        % included in the filter flag array.
        for k = 1 : numObjs
            obj = cObj(k);%#ok
            flg = eval(crtStr);
            if flg
                idx(k) = true;
            end
        end %forloop

    end %endif

else
    % No Criteria for Filter Exists
    % Assumed to mean the edit is intended to apply to every element of the
    % object array.
    idx = true(numObjs,1);

end %endif

% -- Convert to Numeric Index
% Return numeric index into object array.
idx = find(idx);

end %function


function calcVal = applyOperation(cval,opr,oVal)
% APPLYOPERATION: Applies operation (add/multiply/replace) for updating
% property of an object.

% Get Value by OperationType. Accept "replace" as a synonym for "direct"
% so Excel-sourced ECMs (which use the user-friendly label "replace")
% dispatch the same as UI-sourced ones (which store "direct").
opLc = lower(string(opr));
if opLc == "replace"
    opLc = "direct";
end

switch opLc
    case "multiply"
        % -- Multiply
        % Return current value multiplied by operation value.
        calcVal = cval*oVal;

    case "add"
        % -- Add
        % Return current value plus operation value.
        calcVal = cval+oVal;

    case "direct"
        % -- Direct
        % Return operation value directly.
        calcVal = oVal;

    otherwise
        % -- Unsupported
        % Throw error for unsupported operation type.
        error("applyMeasure:UnsupportedUpdateType", ...
            "Unsupported UpdateType '%s'. Must be one of: add, multiply, direct, replace.", opr);

end %switch/case

end %function
