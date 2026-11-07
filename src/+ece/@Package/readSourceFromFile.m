function package = readSourceFromFile(fnmArray, shnArray, pckgName)
%READSOURCEFROMFILE Build an ece.Package from parallel arrays of Excel
%  file names and sheet names. Each (file, sheet) pair defines one ECM;
%  the Package's ECMs are added in the order supplied.
%
%  package = ece.Package.readSourceFromFile(fnmArray, shnArray, pckgName)
%
%  fnmArray: string array of file paths (length N, or scalar which is
%            broadcast to all sheets).
%  shnArray: string array of sheet names (length N).
%  pckgName: Package.Name for the result.

%% Arguments
arguments
    fnmArray (:,:) string
    shnArray (:,:) string
    pckgName (1,1) string
end

% Empty input → empty Package array.
if isempty(fnmArray) || isempty(shnArray)
    package = ece.Package.empty(0,1);
    return;
end

% Validate / broadcast.
if isscalar(fnmArray) && ~isscalar(shnArray)
    fnmArray = repmat(fnmArray, numel(shnArray), 1);
elseif isscalar(shnArray) && ~isscalar(fnmArray)
    shnArray = repmat(shnArray, numel(fnmArray), 1);
elseif numel(fnmArray) ~= numel(shnArray)
    error("ece:MismatchedFileSheetArrays", ...
        "fnmArray (len %d) and shnArray (len %d) must have the same length or one must be scalar.", ...
        numel(fnmArray), numel(shnArray));
end

%% Build Package
package      = ece.Package;
package.Name = pckgName;

for idx = 1:numel(shnArray)
    % readSourceFromFile is case-sensitive on Linux/macOS — use lowercase.
    thisECM = ece.ECM.readSourceFromFile(fnmArray(idx), shnArray(idx));
    package.ECMs(idx) = thisECM;
end

end %function
