function monthVector = convertMonthsToVector(startMonth,endMonth)
%CONVERTMONTHSTOVECTOR Method to take in a start and ending month, and
%create a forward-moving vector of month indices.
%   Will return an ordered vector of month indices. For months where start
%   index is less than end month, this is straightforward. If the reverse
%   is true, we need to ensure it wraps past 12 (Jan) to the end month.
%  Two conditions are checked here:
%     start > end : wraps around december
%     start <= end : doesn't wrap (start == end will return scalar value)

%% Arguments Block
arguments
    % startingMonth: Index of the starting month.
    startMonth (1,1) double

    % endingMonth: Index of the ending month.
    endMonth (1,1)

end %endif

%% Determine Processing Path
% Check if startMonth is less/greater than endMonth, which will let us know
% if the range wraps around.
vectorWrapsAround = (startMonth > endMonth);

%% Process Vector Output
% Set up vectors based on wraparound.
if vectorWrapsAround
    % Build vector output piecewise.
    monthVector = [startMonth:12,1:endMonth];

else
    % Simply span from start to end.
    monthVector = startMonth:endMonth;

end %endif

end %function

