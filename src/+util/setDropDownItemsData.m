function setDropDownItemsData(dropDown,enumStringName,initValue)
% setDropdownItemsData: Utility method to help set dropdown
% controls' ItemsData with a set of enumeration members.

%% Arguments Block
arguments
    % dropDown: Reference to application's dropdown control.
    dropDown (1,1) matlab.ui.control.DropDown
    % enumStringName: Qualified string name of enumeration class.
    enumStringName (1,1) string 
    % initialValue: Initial value to set into dropdown. Must be a member of
    % the specified enumeration class. If left empty the first member of
    % the enumeration class is used.
    initValue (:,1) = [];
end

% Get Enumeration Member List
[ddStrings,ddEnums] = ece.enum.BaseList.classToDisplayNames(...
    enumStringName);

% Place Enum string and value into dropdown.
dropDown.Items = ddStrings;
dropDown.ItemsData = ddEnums;

% Set initial value based on input initial value.
if isempty(initValue) || ~isa(initValue,enumStringName)
    % Use default first item in ItemsData if no initvalue is provided or
    % the initValue is not of the enumeration member type.
    dropDown.Value = dropDown.ItemsData(1);
else
    % Use provided init value
    dropDown.Value = initValue;
end %endif

end %function