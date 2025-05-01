function calculateEnvelopeArea(obj)
% Calculate envelope area. sum the areas of all the envelope components


%% Arguments Block
arguments
    % Obj - Self-referential building object.
    obj (1,1) ece.Building
end %argblock

%%

BuildingEnvelopeArea = 0;

BuildingEnvelopeArea = sum([obj.GlazedSurfaces.GlazedArea, ...
    obj.OpaqueSurfaces.Area_ft2, obj.SlabOnGrade.Area_ft2, ...
    obj.BelowGradeSurfaces.BGwallArea_ft2, ...
    obj.BelowGradeSurfaces.BGfloorArea_ft2]);

obj.BuildingEnvelopeArea = BuildingEnvelopeArea;


end %function

