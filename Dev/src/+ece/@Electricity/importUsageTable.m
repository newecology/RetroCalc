function importUsageTable(e,useTbl)
%IMPORTUSAGETABLE Method to populate the UsageTable property of an
%Electricity object from a provided table of usage data.
%   This method will receive a raw useTbl table that has been loaded from
%   an excel file (or set up from another db) and place it into the
%   corresponding Elec object. The table will undergo sanitization and
%   validation checks first, such that the table finally assigned to the
%   UsageTable property of the Elec object is set for HEA (or other)
%   downstream calculations.

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % e: Self-referential Electricity object.
    e (1,1) ece.Electricity

    % useTbl: 4-column table containing the usage data for the associated
    % electricity utility object.
    useTbl (:,4) table

end %argblock

%% Set Initial Input Directly to Raw Usage Table and Usage Table
% Assign input directly to Raw and UsageTable property.
e.RawUsageTable = useTbl;

% The UsageTable will be further cleaned and sanitized as it is processed
% going forward.
e.AdjustedUsageTable = useTbl;

%% Correct Billing Periods in Table
% If there are uneven billing periods that would skew the analysis, we need
% to adjust the usage time to 12 periods of equal duration in each year.
% This is done with the correctBilling.m method for the Electricity class.
e.correctBilling();

end %function

