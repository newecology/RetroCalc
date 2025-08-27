function [statusOK, msg] = importHistoricalDDTable_API(obj)
%IMPORTHISTORICALDEGREEDAYS Method to import historical degree data as a
%table via API.
% MW_MISU: This will create a two-column HDD table with different column
% names, so calling this and getting that table will break all downstream
% functionality.

%% Arguments Block
% Enforce input argument specifiers.
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    obj (1,1) ece.Location
end %argblock

%% Assume API Call Works
% Set default outputs.
statusOK = true;
msg = "";

%% Try API Call
% Use try/catch in case there is something on the API side that fails the
% call.
try
    % -- API Call
    dataTable = ece.Reference.fromDegreeDaysNetAPI(...
        obj.Latitude, obj.Longitude);

    if istable(dataTable) && ~isempty(dataTable)
        obj.HistoricalDDTable = dataTable;
    else
        warning("Historical degree days API returned empty" + ...
            " or invalid data. Using fallback.");
        obj.HistoricalDDTable = table.empty(0,3);
        
        % Create Output
        statusOK = false;
        msg = "Historical Degree Days API returned empty or " + ...
            "invalid data. Please check inputs to API or import HDD data " + ...
            "manually instead.";

    end

catch ME
    % Use format-safe warning (avoid warning(ME.message))
    warning('%s', getReport(ME, 'basic', 'hyperlinks', 'off'));
    obj.HistoricalDDTable = table.empty(0,3);
    
    % Set Output
    statusOK = false;
    msg = "Unable to access Historical Degree Days through API. Check that the source " + ...
        "is still up and working outside of this application.";

end %try/catch

end %function