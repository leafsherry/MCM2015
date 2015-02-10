%% For computing increasing rate of the disease
    % input:
        % fileName  : the file that contain the value
    % output:
        % x         : x-axis value in date format: yyyy-mm-dd
        % rateCell  : numCountry * 1 cell, the observed rate for country
%% Start
function [timeX, rateCell] = computeRate(fileName)
% three country in total
countryNum = 3;
file = xlsread(fileName);

% flag for case (= 1) and death (= 0)
% flag for country
country = file(:, 4);
rateCell = cell(countryNum,1);

% concate x var into time
x = unique(file(:,1));
timeX = cell(size(x,1),1);
for i = 1:size(x, 1)
    cur = num2str(x(i));
    Year = strcat(cur(1:4),'-');
    Month = strcat(cur(5:6),'-');
    day = cur(7:8);
    timeX{i} = strcat(Year, strcat(Month,day));
end

timeX = cell2mat(timeX);

timeXnum = datenum(timeX); 
% for each country, construct data
for i = 1: countryNum
    curCountry = file(find(country == i),:);
    % find case and death
    caseDeath = curCountry(:,2);
    total = curCountry(find(caseDeath==1),3);
    death = curCountry(find(caseDeath==0),3);
    live = total - death;
    timeLen = size(live,1);
    baseLive = live(1);
    baseDeath = death(1);
    rate = zeros(timeLen, 1);
    for j = 1: timeLen
        newDeath = death(j) - baseDeath;
        newLive = live(j) - baseLive;
        rate(j) = (newLive + newDeath) / baseLive;
        baseLive = live(j);
        baseDeath = death(j);
    end
    rateCell{i} = rate;
end

end