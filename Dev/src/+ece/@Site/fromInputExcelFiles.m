function site = fromInputExcelFiles(fOpts)
%FROMINPUTEXCELFILES Method to create a Site from a set of input EXCEL
%files.
%   A site can be generated from a variety of input files, so this is a
%   method that organizes all the possible inputs into a single place and
%   splits to the corresponding properties the file informs.

%% Arguments Block
% Set up optional arguments.
arguments
    % fOpts: File opts, optional input paths to load from.
    % BuildingPath: String path to EXCEL file containing Building info.
    fOpts.BuildingPath (:,1) string = string.empty(0,1);

    % UtilityDataPath: String path to EXCEL file containing utility info.
    fOpts.UtilityPath (:,1) string = string.empty(0,1);

    % HistDDPath: String path to EXCEL file containing historical degree
    % day data.
    fOpts.HistDDPath (:,1) string = string.empty(0,1);

end %argblock

%% Initialize Site Object
% Default instantiation, independent of any input arguments.
site = ece.Site;

%% Optional: Set up Site Buildings
% Process optional input Buildings file into Site.
if ~isempty(fOpts.BuildingPath)
    site.importBuildings(fOpts.BuildingPath);
end %endif

%% Optional: Set up Site Utilities
% Process optional input Utilities file into Site.
if ~isempty(fOpts.UtilityPath)
    site.importUtilities(fOpts.UtilityPath);
end %endif

%% Optional: Set up Site Historical DegreeDays
% Process optional Historical Degree Days file into Site.
if ~isempty(fOpts.HistDDPath)
    site.importHistoricalDegreeDays(fOpts.HistDDPath);
end %endif

end %function

