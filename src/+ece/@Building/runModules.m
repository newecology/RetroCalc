function obj = runModules(fileName, config)

% Safe default assignment using isfield
if ~isfield(config, 'summary'), config.verbose = true; end
if ~isfield(config, 'skipCalc'), config.skipCalc = false; end
obj=ece.Building;
obj=obj.loadData(fileName);

% Checking for skipping calc or displaying summary options in parameters
if ~config.skipCalc
    obj.runCalcs(config);
end

if config.summary
    obj.reportSummary();
end
end