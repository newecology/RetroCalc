function importUsageTable(w,useTbl)
%IMPORTUSAGETABLE Method to populate the AdjustedUsageTable property of an
%Water object from a provided table of usage data.
%   This method will receive a raw useTbl table that has been loaded from
%   an excel file (or set up from another db) and place it into the
%   corresponding Water object. The table will undergo sanitization and
%   validation checks first, such that the table finally assigned to the
%   AdjustedUsageTable property of the Water object is set for HEA (or other)
%   downstream calculations.

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % w: Self-referential Water object.
    w (1,1) ece.Water

    % useTbl: 4-column table containing the usage data for the associated
    % water utility object.
    useTbl (:,4) table

end %argblock

%% Set Initial Input Directly to Raw Usage Table and Usage Table
% Assign input directly to Raw and AdjustedUsageTable property.
w.RawUsageTable = useTbl;

% The AdjustedUsageTable will be further cleaned and sanitized as it is processed
% going forward.
w.AdjustedUsageTable = useTbl;

%% Correct Billing Periods in Table
% If there are uneven billing periods that would skew the analysis, we need
% to adjust the usage time to 12 periods of equal duration in each year.
% This is done with the correctBilling.m method for the Water class.
w.correctBilling();

end %function

