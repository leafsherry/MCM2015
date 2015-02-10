%% This function build the model w.r.t input.
 % _SOD: for model with assumption the medical lab is in SOD

% Input:
    % dayInput      : initial conditions in every treatment center
        % Dimension : numTC (Num. treatment center) * CV (condition vector)
        % CV        : [  
                        %H: no infection + live
                        %I: infection + no medicine
                        %C: infection + advanced
                        %D: no infection + dead
                     %]
    % rateFunc      : Spread rate computed w.r.t the given data
    % ItoC          : Period for I to C to happen
    % CtoD          : Period for C to D to happen
    % ItoCrate      : ItoCrate q
    % CtoDrate      : deathRate d
    % numMedicine   : Available medicine
    % TCMap         : Mapping between country and TC
                        % numTC * 1, each with num 1-numCountry indicating
                        % which country
    % p             : Preparedness, numTC * 1, different for every TC
    % reachTCMat (numTC * numTC)
            % reachable from i to j: reachTCMat(i,j) = 1, 0 otherwise
% Output:
    % numOfDeath    : total death
    % condiHist     : record of everyday's change
    % totalCost     : cost for transforming medicines
    % minP          : the min value of p for making an impact with curMedi
function [ numOfDeath, countDay, totalCost, minP ] = buildModel_SOD(dayInput, rateFunc,...
                                        ItoCrate, CtoDrate,...
                                        numMedicine, TCMap, p, maxDay,reachTCMat)
% get dimension
numTC = size(dayInput, 1);      % number of treatment center
numGroup = size(dayInput, 2);   % number of classification of crowd
dayCompute = dayInput;
totalCost = 0;
minP = 1;
% specify transformation matrixs

% initialize condition history, record changes for every day
condiHist = cell(1,1);
condiHist{1} = dayInput;

% count days, medicines for periodical events
countDay = 1;
curMedicine = numMedicine;
% for the period
while(true)
    % new record for a new day
    newDayHist = zeros(numTC, numGroup);
    % compute the expected spread and sort TC
    [expectNum, index] = computeExpectI(dayCompute, rateFunc, countDay, TCMap);
    % for every TC
    for k = 1:numTC
            medicineMat = [ 1,   0       ,0,           0;
                            0,   1       ,0,           0;
                            0,   0       ,1,           0;
                            0,   0       ,0,           1];
            spreadMat   = [ 1,   -1      , -1        , 0;
                            0,   1       , 1         , 0;
                            0,   ItoCrate, 1-CtoDrate, 0;
                            0,   0       , 1         , 1];
        i = index(k);        
        medicineMat(1:2,2:2) = medicineMat(1:2,2:2) + [p(i);-p(i)];
        % confirm which country
        curCountry = TCMap(i);
        spreadRate = polyval(rateFunc{curCountry}, countDay);
        %if spreadRate < 0
        %    spreadRate = 0;
        %end
        
        curTC = dayCompute(i,:);
        % compute p
        Cp = curTC(3);Ip = curTC(2); 
        newP = 1 - 1/(1-ItoCrate+(1+Cp / Ip) * spreadRate);
        if newP < minP
            minP = newP;
        end
        % update spreadMat function
        spreadMat(1:2, 2:3) = [-1, -1; 1, 1] .* spreadRate + ...
                                    [0,0;1-ItoCrate,0];
        
        [v_treat, v_no, curMedicine] = computePartition(curTC, curMedicine);
        if curMedicine == 0
            targetTC = index(1:k);
            transitTC = computeTransMethod(reachTCMat, targetTC');
            totalCost = length(transitTC) + totalCost;
        end
        v_treated = medicineMat * v_treat;
        nextTC = spreadMat * [(v_treated + v_no)];
        newDayHist(i, :) = nextTC';
    end
    curNegHealthIndex = find(newDayHist(:,1) < 0);
    for k = 1: length(curNegHealthIndex)
        newDayHist(curNegHealthIndex(k),1) = 0;
    end
    condiHist = [condiHist; newDayHist];
    dayCompute = newDayHist;
    if (newDayHist(:,2:3) < 2);
        break;
    end
    if (countDay > maxDay)
        break;
    end
    countDay = countDay + 1;
    curMedicine = curMedicine + numMedicine;
    %newDayHist
end
    numOfDeath = sum(newDayHist(3,:));
end



