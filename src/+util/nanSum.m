function y = nanSum(x)
%NANSUM Function to be used with pivot table to sum up like groups.
%   This is different from regular MATLAB sum in that it returns NaN for
%   any pivoted rows instead of zero. This helps to disambiguate from
%   things that should be 0 to begin with.

% Obtain mask for empty values in input.
emptyMask = isempty(x);

% Sum values.
y = sum(x);

% Apply Emptymask to Set NaN
y(emptyMask) = NaN;

end %function