function ecm = readSourceFromTable(ecmTbl, name)
%READSOURCEFROMTABLE Build an ece.ECM from a MATLAB table.
%
%   ecm = ece.ECM.readSourceFromTable(ecmTbl, name)
%
%   ecmTbl columns (case-insensitive, extra columns ignored):
%     Operation          - "insert" | "update" / "edit" | "delete"
%     ObjectOfReference  - singular class name, e.g. "HeatCool", "Glazing",
%                          "Appliance", "OpaqueSurface"
%     FilterCriteria     - for update/delete rows; property-expression or
%                          "Object#: 1,2,3" index form. Blank = match all.
%     PropertyToChange   - for update rows; may be indexed "Name(k)" with
%                          optional " - Label" suffix.
%     UpdateType         - for update rows; "add" | "multiply"
%                          | "direct" / "replace"
%     ValueForChange     - for update rows; scalar, or a vector in Excel
%                          text form like "[2 0 0 0 0 0]"
%     InsertQuantity     - for insert rows; integer
%     InsertedProperty   - for insert rows; DSL string e.g.
%                          Name="X";Area_ft2=[100];Uvalue=[0.25];
%
%   name is the ECM's display name (typically the sheet name).
%
%   Rows with an unknown Operation or UpdateType are SKIPPED with a
%   warning naming the offending row index.

arguments
    ecmTbl
    name (1,1) string
end

% Handle empty input.
if isempty(ecmTbl)
    ecm = ece.ECM.empty(0,1);
    return;
end

% --- Normalize column headers (case-insensitive lookup) ---
origNames = string(ecmTbl.Properties.VariableNames);
lcNames   = lower(origNames);
required  = ["operation"; "objectofreference"];
missing   = required(~ismember(required, lcNames));
if ~isempty(missing)
    error("ece:MissingColumn", ...
        "ECM '%s' is missing required column(s): %s. Found: %s", ...
        name, strjoin(missing, ", "), strjoin(origNames, ", "));
end

% Build a lookup so we can index the table by canonical (lowercase) name
% regardless of the user's header casing.
function v = col(colName)
    idx = find(lcNames == lower(colName), 1);
    if isempty(idx)
        v = [];
    else
        v = ecmTbl.(origNames(idx));
    end
end

opCol      = col("Operation");
objCol     = col("ObjectOfReference");
filterCol  = col("FilterCriteria");
propCol    = col("PropertyToChange");
updCol     = col("UpdateType");
valCol     = col("ValueForChange");
qtyCol     = col("InsertQuantity");
insPropCol = col("InsertedProperty");

% --- Operation / UpdateType vocabularies (accept synonyms) ---
% Canonical operations are the ones applyMeasure dispatches on; "update"
% is accepted at apply time as a synonym for "edit".
opDict = ["insert", "delete", "update", "edit"];
updDict = ["add", "multiply", "replace", "direct"];

% --- Mapping from a bare class name to its Building property collection.
% Most are plural (Appliance → Appliances); these are the exceptions.
% Keep in sync with Building.m properties.
outlierMap = dictionary( ...
    "Airmovers",          "Airmovers", ...
    "SlabOnGrade",        "SlabOnGrade", ...
    "DHWpipesMechRoom",   "DHWpipesMechRoom", ...
    "HeatCool",           "HeatCool", ...
    "Glazing",            "GlazedSurfaces", ...
    "Building",           "");   % Building itself has no collection

hgt = height(ecmTbl);
ecm       = ece.ECM;
ecm.Name  = name;
msrArray  = ece.MeasureComponent.empty(0,1);
nKept     = 0;

for idx = 1:hgt
    try
        thisOp = lower(strtrim(string(opCol(idx))));
    catch
        warning("ece:BadOperationCell", ...
            "ECM '%s', row %d: unreadable Operation cell. Skipping.", name, idx);
        continue;
    end

    if ismissing(thisOp) || strlength(thisOp) == 0
        continue;   % blank row — silent skip
    end
    if ~any(opDict == thisOp)
        warning("ece:UnknownOperation", ...
            "ECM '%s', row %d: unknown Operation '%s' (must be one of: %s). Skipping.", ...
            name, idx, thisOp, strjoin(opDict, ", "));
        continue;
    end

    objRef = strtrim(string(objCol(idx)));
    if ismissing(objRef) || strlength(objRef) == 0
        warning("ece:BlankObject", ...
            "ECM '%s', row %d: ObjectOfReference is blank. Skipping.", name, idx);
        continue;
    end

    msr = ece.MeasureComponent;
    msr.ObjectOfReference = objRef;
    if isKey(outlierMap, objRef)
        msr.ObjectVarName = outlierMap(objRef);
    else
        msr.ObjectVarName = objRef + "s";
    end
    msr.Operation = thisOp;

    if thisOp == "insert"
        if isempty(qtyCol)
            msr.InsertQuantity = 1;
        else
            q = qtyCol(idx);
            if isnumeric(q)
                msr.InsertQuantity = max(1, round(q));
            else
                qn = str2double(string(q));
                if isnan(qn), qn = 1; end
                msr.InsertQuantity = max(1, round(qn));
            end
        end
        if ~isempty(insPropCol)
            msr.InsertedProperty = string(insPropCol(idx));
        end
    else
        if ~isempty(filterCol)
            fc = string(filterCol(idx));
            if ismissing(fc), fc = ""; end
            msr.FilterCriteria = fc;
        end
        if thisOp == "update" || thisOp == "edit"
            if isempty(propCol)
                warning("ece:MissingPropertyToChange", ...
                    "ECM '%s', row %d: update/edit row has no PropertyToChange column.", ...
                    name, idx);
                continue;
            end
            prop = strtrim(string(propCol(idx)));
            if ismissing(prop) || strlength(prop) == 0
                warning("ece:MissingPropertyToChange", ...
                    "ECM '%s', row %d: update/edit row has blank PropertyToChange.", ...
                    name, idx);
                continue;
            end
            msr.PropertyToChange = prop;

            updType = lower(strtrim(string(updCol(idx))));
            if ismissing(updType) || strlength(updType) == 0
                warning("ece:MissingUpdateType", ...
                    "ECM '%s', row %d: update/edit row has blank UpdateType (must be add / multiply / direct / replace).", ...
                    name, idx);
                continue;
            end
            if ~any(updDict == updType)
                warning("ece:UnknownUpdateType", ...
                    "ECM '%s', row %d: unknown UpdateType '%s' (must be one of: %s). Skipping.", ...
                    name, idx, updType, strjoin(updDict, ", "));
                continue;
            end
            msr.UpdateType = updType;

            msr.ValueForChange = parseValueForChange(valCol, idx);
        end
    end

    nKept = nKept + 1;
    msrArray(nKept) = msr;
end

ecm.MeasureComponents = msrArray;

end %function


function v = parseValueForChange(valCol, rowIdx)
%PARSEVALUEFORCHANGE Best-effort coercion of a ValueForChange cell.
%   Returns NaN if the column is missing or the cell is blank.
%   Returns a numeric scalar / vector where possible; falls back to the
%   raw string for cases where the target property is a string / enum.

if isempty(valCol)
    v = NaN;
    return;
end

raw = valCol(rowIdx);
if isnumeric(raw)
    v = raw;
    return;
end

s = string(raw);
if ismissing(s) || strlength(s) == 0
    v = NaN;
    return;
end

% Try plain numeric scalar first.
num = str2double(s);
if ~isnan(num)
    v = num;
    return;
end

% Try vector form, e.g. "[2 0 0 0 0 0]" or "2, 0, 0".
try
    num = str2num(char(s)); %#ok<ST2NM>
catch
    num = [];
end
if ~isempty(num) && isnumeric(num)
    v = num;
    return;
end

% Give up on numeric — pass the raw string through so enum / string
% property targets still get a usable value.
v = s;

end %function
