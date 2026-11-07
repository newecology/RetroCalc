function [isValid, normalizedValue, message] = validateMeasureComponentValue(propDataType, rawValue)
% validateMeasureComponentValue: Utility method to check whether a raw
% value typed into an ECM Insert/Edit value table cell is legal for the
% named property's MATLAB class, before it gets glued into a
% MeasureComponent's property string and eval'd onto a Building object.
%
%   [isValid, normalizedValue, message] = ...
%       util.validateMeasureComponentValue(propDataType, rawValue)
%
%   propDataType: string. MATLAB class name of the target property (e.g.
%       "ece.enum.SystemType", "double", "string").
%   rawValue: the candidate value, as typed/selected in the table cell.
%       May be char, string, or numeric.
%
%   isValid: true if rawValue is legal for propDataType.
%   normalizedValue: canonicalized form of rawValue (e.g. enum member
%       name in its correct case). Equal to rawValue when no
%       normalization applies or isValid is false.
%   message: human-readable explanation when isValid is false; "" when
%       isValid is true.

arguments
    propDataType (1,1) string
    rawValue
end

normalizedValue = rawValue;
message = "";
isValid = true;

% -- Enumeration Properties
% If the property's class is a MATLAB enumeration, only accept a value
% that exactly matches one of its member names (case-insensitive).
mcls = [];
try
    mcls = matlab.metadata.Class.fromName(propDataType);
catch
    % Not a resolvable class name (e.g. "double") -- fall through to
    % the other type checks below.
end

if ~isempty(mcls) && mcls.Enumeration
    validNames = string({mcls.EnumerationMemberList.Name});
    matchIdx = find(strcmpi(validNames, strtrim(string(rawValue))), 1);

    if isempty(matchIdx)
        isValid = false;
        message = "Invalid value. Must be one of: " + ...
            strjoin(validNames, ", ");
    else
        normalizedValue = validNames(matchIdx);
    end

    return;
end

% -- Numeric Properties
if propDataType == "double" || propDataType == "single"
    if isnumeric(rawValue)
        normalizedValue = rawValue;
        return;
    end

    numVal = str2double(rawValue);
    if isnan(numVal)
        isValid = false;
        message = "Invalid value. Must be a number.";
    else
        normalizedValue = numVal;
    end

    return;
end

% -- Text Properties
% Reject characters that would break the "Name=""X"";" property-string
% parser/eval used to apply Insert/Edit measures.
if propDataType == "string" || propDataType == "char"
    strVal = string(rawValue);
    if contains(strVal, """") || contains(strVal, ";")
        isValid = false;
        message = "Invalid value. Cannot contain a quote ("") or semicolon (;).";
    else
        normalizedValue = strVal;
    end

    return;
end

% -- Other Types
% No specific validation rule defined; pass the value through unchanged.

end %function
