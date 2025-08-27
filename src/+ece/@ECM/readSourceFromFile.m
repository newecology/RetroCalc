function ecm = readSourceFromFile(fileName, sheetName)
%fineName to provide excel file path for defined ECM
%sheetname to provide sheet name that corresponds to this particular ECM
%   This method will output an array of Airmovers objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing Airmovers data.
    fileName (1,1) string

    % sheetName: Sheet Name corresponding to this particular ECM
    sheetName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load ECM  data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Airmovers Data
% Get a list of all sheet names, then filter out Airmovers one.
avlSheetNames = sheetnames(fileName);
if ~any(avlSheetNames==sheetName)
    % Throw error that describes issues and returns.
    error("Provided file doesn't have a sheet with the name: " + ...
        "'" + sheetName + "'" );
end %endif

%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
ecmTbl  = readtable(fileName,"Sheet",sheetName);
%ecmTbl  = rmmissing(ecmTbl,'MinNumMissing', 19);

% Call the ReadSourceFromTable function
ecm = ReadSourceFromTable(ecmTbl,sheetName);

end %function
