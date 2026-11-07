function setValueColumnFormat(tblObj, colIdx, propDataType)
  % SETVALUECOLUMNFORMAT Switches a uitable column to an enum dropdown or
  % plain text input depending on the property's data type.
  %   Must be called before the user begins editing the cell, e.g. from a
  %   CellSelectionCallback, since ColumnFormat takes effect when the editor opens.
  %
  %   tblObj:       uitable handle.
  %   colIdx:       column index to update (1-based).
  %   propDataType: string. MATLAB class name returned by lookupPropertyDataType.
  %       Enum classes get a dropdown restricted to their member names; all
  %       others get a free-text ('char') editor.
      if propDataType == ""
          tblObj.ColumnFormat{colIdx} = 'char'; return;
      end
      try
          mcls = matlab.metadata.Class.fromName(propDataType);
          if ~isempty(mcls) && mcls.Enumeration
              tblObj.ColumnFormat{colIdx} = cellstr({mcls.EnumerationMemberList.Name});
          else
              tblObj.ColumnFormat{colIdx} = 'char';
          end
      catch
          tblObj.ColumnFormat{colIdx} = 'char';
      end
end