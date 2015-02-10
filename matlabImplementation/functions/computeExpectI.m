%% Compute the expected patient that could be solved at this point
% Input:
    % dayCompute    : current conditions in every treatment center
        % Dimension : numTC (Num. treatment center) * CV (condition vector)
        % CV        : [  
                        %H: no infection + live
                        %I: infection + no medicine
                        %W: infection + advanced
                        %D: no infection + dead
                     %]
    % rateFunc      : Spread rate computed w.r.t the given data
    % countDay      : How many days has past from the first day
    % TCMap         : Mapping between country and TC
                        % numTC * 1, each with num 1-numCountry indicating
                        % which country

% Output:
    % expectNum     : vector of the computed expectNum
    % index         : Used for determine which one to give medicine
    
    
function [expectNum, index] = computeExpectI(dayCompute, rateFunc, ...
                                            countDay, TCMap)
% get dimension
numTC = size(dayCompute, 1);      % number of treatment center
numGroup = size(dayCompute, 2);   % number of classification of crowd

% initialize expectNum
expect = zeros(numTC, 1);

for i = 1:numTC
    % confirm which country
    curTC = dayCompute(i,:);
    I = curTC(2);
    W = curTC(3);
    curCountry = TCMap(i);
    spreadRate = polyval(rateFunc{curCountry}, countDay);
    expect(i) = I + spreadRate * (I + W);
end

[expectNum, index] = sort(-expect);
expectNum = expectNum * (-1);
end