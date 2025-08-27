function applyMeasure(obj,bldg)
%APPLYMEASURE Method to apply a Measure onto an input Building.
%  The MC in question is applied to the Building based on the kind of MC it
%  is (add/delete/change) and the properties of the Building.

%% Arguments Block
% Ensure inputs are the correct size and type.
arguments
    % obj: Self-referential MeasureComponent object.
    obj (1,1) ece.MeasureComponent

    % building: Building object that MeasureComponent is applied to.
    bldg (1,1) ece.Building

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

% Determine operation by switch/case
switch lower(obj.Operation)
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
        idx = parseToGetIndex(impctObj,obj.FilterCriteria);
        for k = 1 : numel(idx)
            thdx = idx(k);
            cval = impctObj(thdx).(obj.PropertyToChange);
            calcVal = applyOperation(cval,obj.UpdateType,obj.ValueForChange);
            impctObj(thdx).(obj.PropertyToChange) = calcVal;
        end %forloop

    case "delete"
        % -- Delete
        % Delete Operation removes objects of the specified type from the
        % Building, that fall under a specific filter criteria.
        idx = parseToGetIndex(impctObj,obj.FilterCriteria);
        impctObj(idx) = [];

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
    % Extract eval string and evaluate it.
    eval(evalStrings(evalStrIdx))
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

        % Clip between valid array indices.
        indicNums = clip(indicNums,1,numObjs);

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

% Get Value by OperationType
switch lower(opr)
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
        error("Unsupported operation type.");

end %switch/case

end %function
