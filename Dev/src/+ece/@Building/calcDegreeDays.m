function calcDegreeDays(obj)

% This function takes a year of hourly weather data that is typical or
% average, usually from TMY3 or TMY3x. The data has been loaded
% into the building's WeatherDataTable. The outputs are an array and a
% table that contain 6 parameters for each of the day and night periods
% in each month. The 6 parameters are:
% 1 HDD heating degree days (degrees F)
% 2 CDD cooling degree days (degrees F)
% 3 EDD enthalpy days
% 4 Average temperature (degrees F)
% 5 Average enthalpy, (Btu/lb mass dry air)
% 6 Average wind speed (miles per hour)

%Getting the setpoints from the hheatcoolsetpoints property array
htg1Setpt = obj.HeatCoolSetpoints(1);
htg2Setpt = obj.HeatCoolSetpoints(2);
clg1Setpt = obj.HeatCoolSetpoints(3);
clg2Setpt = obj.HeatCoolSetpoints(4);
% Getting the relative humidity target for summer
targetRHsummer = obj.HeatCoolSetpoints(5);
% Start and end times for time period 1
htg1StrtTime = obj.HVACStartEndTimePeriod1(1);
htg1EndTime = obj.HVACStartEndTimePeriod1(2);
clg1StrtTime = obj.HVACStartEndTimePeriod1(1);
clg1EndTime = obj.HVACStartEndTimePeriod1(2);
% Start and end dates for heating and cooling
htgStrtDate = obj.HeatCoolSeasonStartEndDates(1);
htgEndDate = obj.HeatCoolSeasonStartEndDates(2);
clgStrtDate = obj.HeatCoolSeasonStartEndDates(3);
clgEndDate = obj.HeatCoolSeasonStartEndDates(4);
%convert start and end dates to a "day number" i.e. the day of the year counting from
%1 to 365
htgStrtDayNumber = day(htgStrtDate,'dayofyear');
htgEndDayNumber = day(htgEndDate,'dayofyear');
clgStrtDayNumber = day(clgStrtDate,'dayofyear');
clgEndDayNumber = day(clgEndDate,'dayofyear');

%add columns to the weather data table for the month, hour, and day number
obj.WeatherDataTable.Day = day(obj.WeatherDataTable.Date);
obj.WeatherDataTable.Month = month(obj.WeatherDataTable.Date);
obj.WeatherDataTable.Hour = hour(obj.WeatherDataTable.Time);

%assign a day of the year number to each hour to use for heating/cooling
%seasons
obj.WeatherDataTable.dayNumber = floor([1:1/24:365.96]');

%convert degrees C to F and wind speed m/s to mph
obj.WeatherDataTable.DryBulb_F = obj.WeatherDataTable.DryBulb .* 1.8 + 32;
obj.WeatherDataTable.Rhum = obj.WeatherDataTable.Rhum;
obj.WeatherDataTable.wSpeed_mph = obj.WeatherDataTable.wSpeed * 2.237;
%enthalpy setpoints based on cooling temp setpoint and target RH
en1Setpt = ece.Building.calcEnthalpyAirH20(clg1Setpt, targetRHsummer);
en2Setpt = ece.Building.calcEnthalpyAirH20(clg2Setpt, targetRHsummer);

%add enthalpy
obj.WeatherDataTable.enthalpy = ...
    ece.Building.calcEnthalpyAirH20(obj.WeatherDataTable.DryBulb_F, ...
    obj.WeatherDataTable.Rhum);

%Calculating the total heating °F-hrs. negatives not included.
obj.WeatherDataTable.htgFhrs1 = max(0, htg1Setpt-obj.WeatherDataTable.DryBulb_F);
obj.WeatherDataTable.htgFhrs2=max(0, htg2Setpt-obj.WeatherDataTable.DryBulb_F);
%Calculating the total cooling °F-hrs
%utilization factor method includes negatives, i.e. it is the net cooling degree hours
obj.WeatherDataTable.clgFhrs1 = obj.WeatherDataTable.DryBulb_F - clg1Setpt;
obj.WeatherDataTable.clgFhrs2 = obj.WeatherDataTable.DryBulb_F - clg2Setpt;
%Calculating the total enthalpy °F-hrs
%utilization factor method includes negatives
obj.WeatherDataTable.enHrs1 = obj.WeatherDataTable.enthalpy - en1Setpt;
obj.WeatherDataTable.enHrs2 = obj.WeatherDataTable.enthalpy - en2Setpt;

monthName = ["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"]';
monthNum = [1:12]';

%Creating empty arrays to store the final calculated values of the degree
%days for heating and cooling, as well as average values of temp, enthalpy,
%wind speed
hdd1=zeros(1,12);
hdd2=zeros(1,12);
cdd1=zeros(1,12);
cdd2=zeros(1,12);
edd1=zeros(1,12);
edd2=zeros(1,12);
avgTemp1 = zeros(1,12);
avgTemp2 = zeros(1,12);
avgEnthalp1 = zeros(1,12);
avgEnthalp2 = zeros(1,12);
avgWspeed1 = zeros(1,12);
avgWspeed2 = zeros(1,12);

%use logical arrays with 8760 rows for the conditions of heating season, time
%of day, and month. zero out heating and cooling degree days for the time
%of year when heating / cooling aren't needed.
x = obj.WeatherDataTable.dayNumber >= htgStrtDayNumber | obj.WeatherDataTable.dayNumber < htgEndDayNumber;
obj.WeatherDataTable.htgFhrs1 = obj.WeatherDataTable.htgFhrs1 .* x;
obj.WeatherDataTable.htgFhrs2 = obj.WeatherDataTable.htgFhrs2 .* x;
y = obj.WeatherDataTable.dayNumber >= clgStrtDayNumber & obj.WeatherDataTable.dayNumber < clgEndDayNumber;
obj.WeatherDataTable.clgFhrs1 = obj.WeatherDataTable.clgFhrs1 .* y;
obj.WeatherDataTable.clgFhrs2 = obj.WeatherDataTable.clgFhrs2 .* y;
obj.WeatherDataTable.enHrs1 = obj.WeatherDataTable.enHrs1 .* y;
obj.WeatherDataTable.enHrs2 = obj.WeatherDataTable.enHrs2 .* y;

htgTime1 = obj.WeatherDataTable.Hour >= htg1StrtTime & obj.WeatherDataTable.Hour < htg1EndTime;
htgTime2 = obj.WeatherDataTable.Hour < htg1StrtTime | obj.WeatherDataTable.Hour >= htg1EndTime;
clgTime1 = obj.WeatherDataTable.Hour >= clg1StrtTime & obj.WeatherDataTable.Hour < clg1EndTime;
clgTime2 = obj.WeatherDataTable.Hour < clg1StrtTime | obj.WeatherDataTable.Hour >= clg1EndTime;

%make vectors with heating/cooling degree hours, enthalpy hours, average
%temp, wind speed and enthalpy, for each month, for time periods 1 and 2
for n=1:12
    z = obj.WeatherDataTable.Month == n;
    hdd1(n) = sum(obj.WeatherDataTable.htgFhrs1 .* z .* htgTime1) / 24;
    hdd2(n) = sum(obj.WeatherDataTable.htgFhrs2 .* z .*htgTime2) / 24;
    cdd1(n) = sum(obj.WeatherDataTable.clgFhrs1 .* z .* clgTime1) / 24;
    cdd2(n) = sum(obj.WeatherDataTable.clgFhrs2 .* z .* clgTime2) / 24;
    edd1(n) = sum(obj.WeatherDataTable.enHrs1 .* z .* clgTime1) / 24;
    edd2(n) = sum(obj.WeatherDataTable.enHrs2 .* z .* clgTime2) / 24;
    %add average temperature, enthalpy, and wind speed. for all months for
    %both time periods
    avgTemp1(n) = sum(obj.WeatherDataTable.DryBulb_F .* z .* htgTime1) / ...
        sum(z .* htgTime1);
    avgTemp2(n) = sum(obj.WeatherDataTable.DryBulb_F .* z .* htgTime2) / ...
        sum(z .* htgTime2);
    avgEnthalp1(n) = sum(obj.WeatherDataTable.enthalpy .* z .* clgTime1) / ...
        sum(z .* clgTime1);
    avgEnthalp2(n) = sum(obj.WeatherDataTable.enthalpy .* z .* clgTime2) / ...
        sum(z .* clgTime2);
    avgWspeed1(n) = sum(obj.WeatherDataTable.wSpeed_mph .* z .* htgTime1) / ...
        sum(z .* htgTime1);
    avgWspeed2(n) = sum(obj.WeatherDataTable.wSpeed_mph .* z .* htgTime2) / ...
        sum(z .* htgTime2);
end

%array for use in space heating / cooling calcs
%24 columns for time 1 and time 2 in each month (Jan day, Jan night, Feb
%day, Feb night, etc.)
% 3 rows for HDD, CDD, enthalpy days as well as 3 more rows for avg temp,
% avg enthalpy, and average wind speed
obj.weatherMonthly = zeros(6,24);
obj.weatherMonthly(1,1:2:23) = hdd1;
obj.weatherMonthly(1,2:2:24) = hdd2;
obj.weatherMonthly(2,1:2:23) = cdd1;
obj.weatherMonthly(2,2:2:24) = cdd2;
obj.weatherMonthly(3,1:2:23) = edd1;
obj.weatherMonthly(3,2:2:24) = edd2;
obj.weatherMonthly(4,1:2:23) = avgTemp1;
obj.weatherMonthly(4,2:2:24) = avgTemp2;
obj.weatherMonthly(5,1:2:23) = avgEnthalp1;
obj.weatherMonthly(5,2:2:24) = avgEnthalp2;
obj.weatherMonthly(6,1:2:23) = avgWspeed1;
obj.weatherMonthly(6,2:2:24) = avgWspeed2;


% Creating the table to store the final heating degree days and cooling
% degree days and cooling enthalpy days. this table is for user review.
obj.DegreeDaysTable = table(monthName, monthNum, 'VariableNames', ...
    {'month_name', 'month_num'});

% Transposing the arrays to fit the columnar table structure
obj.DegreeDaysTable.hdd1=hdd1';
obj.DegreeDaysTable.hdd2=hdd2';
obj.DegreeDaysTable.cdd1=cdd1';
obj.DegreeDaysTable.cdd2=cdd2';
obj.DegreeDaysTable.edd1=edd1';
obj.DegreeDaysTable.edd2=edd2';
obj.DegreeDaysTable.avgTemp1 = avgTemp1';
obj.DegreeDaysTable.avgTemp2 = avgTemp2';
obj.DegreeDaysTable.avgEnthalp1 = avgEnthalp1';
obj.DegreeDaysTable.avgEnthalp2 = avgEnthalp2';
obj.DegreeDaysTable.avgWindSpeed1 = avgWspeed1';
obj.DegreeDaysTable.avgWindSpeed2 = avgWspeed2';

obj.DegreeDaysTable(13,:) = table("Totals", "", sum(hdd1), sum(hdd2), sum(cdd1),...
    sum(cdd2), sum(edd1), sum(edd2), mean(avgTemp1), mean(avgTemp2), ...
    mean(avgEnthalp1), mean(avgEnthalp2), mean(avgWspeed1), mean(avgWspeed2));

end   % function end statement






