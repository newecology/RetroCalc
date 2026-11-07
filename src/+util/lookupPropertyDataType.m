  function propDataType = lookupPropertyDataType(mainObjectTbl, objName, propName)
 % LOOKUPPROPERTYDATATYPE Returns the MATLAB data type of a named property
  % on a named ECM object, as recorded in the main object table.
  %
  %   propDataType = util.lookupPropertyDataType(mainObjectTbl, objName, propName)
  %
  %   mainObjectTbl: table from ECMCreationPanel.getObjectDetails, with columns
  %       Classes, PropertyName, DataType.
  %   objName:  string. ECM object class name (e.g. "ece.Building").
  %   propName: string. Property name to look up.
  %
  %   propDataType: string. MATLAB class of the property (e.g. "double",
  %       "ece.enum.SystemType"). Returns "" if objName or propName not found.
      propDataType = "";
      objRowMask = mainObjectTbl.Classes == string(objName);
      if ~any(objRowMask); return; end
      propNames   = mainObjectTbl.PropertyName{objRowMask};
      propRowMask = propNames == string(propName);
      if ~any(propRowMask)
          % Fallback: strip "(idx) — label" from both sides and compare
          % bare identifiers. Lets legacy MCs that stored a whole-array
          % PropertyToChange (e.g. "HeatCoolSetpoints") still resolve to
          % the element type now that the table lists indexed entries.
          bareQuery = regexp(string(propName), '^\w+', 'match', 'once');
          bareRows  = arrayfun( ...
              @(s) regexp(s, '^\w+', 'match', 'once'), propNames);
          propRowMask = bareRows == bareQuery;
          if ~any(propRowMask); return; end
      end
      propDataType = mainObjectTbl.DataType{objRowMask}(propRowMask);
  end