%% For computing the function for interpotating spreading rate per country
    % input
        % x         : x-axis value in date format: yyyy-mm-dd
        % rateCell  : numCountry * 1 cell, the observed rate for country
        % n         : degree for polyfit
    % output:
        % rateFunc  : numCountry * 1 cell, the fitted rate function for country
%% Start
function [rateFunc] = rateFunction(x, rateCell, n)
% timeX: how many days past from the initial date
timeX = datenum(x);
timeX = timeX - timeX(1) + 1;
numCountry = size(rateCell,1);

rateFunc = cell(numCountry, 1);

color = 'b';
G = figure(1);
hold on
for i = 1: numCountry
    curRate = rateCell{i};
    rateFunc{i} = polyfit(timeX, curRate, n);
    
    % specify color for each country
    if i == 2
        color = 'r';
    elseif i == 3
        color = 'g';
    end
    plot(timeX, curRate, color,'linestyle',':', 'LineWidth',1.3);
    plot(timeX, polyval(rateFunc{i}, timeX), color, 'LineWidth',1.3);
end
xlabel('time series (day)');
ylabel('spread rate')
title('Spread rate function: curve-fitting')
legend('GI','GI-fit', 'LB', 'LB-fit', 'SE', 'SE-fit',-1);
end