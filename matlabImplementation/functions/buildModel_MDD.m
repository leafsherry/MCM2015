%% This function build the model w.r.t input.
 % _MOD: for model with assumption the medical lab is in local MOD


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
    % ItoCrate      : ItoCrate q
    % CtoDrate      : deathRate d
    % numMedicine   : Available medicine
    % TCMap         : Mapping between country and TC
                        % numTC * 1, each with num 1-numCountry indicating
                        % which country
    % p             : Preparedness, numTC * 1, different for every TC
    % costArr       : numLab * numTC, 
                        %(i,j): cost from lab_i to TC_j
    % labArr        : the index of district and numMedi for the lab
                        %[index, numMedProducted]
    % maxDay        : at most put into action for this number of day
% Output:
    % numOfDeath    : total death
    % countDay      : number of days needed to control the disease
    % totalCost     : cost for transforming medicines 
    % minP          : the min value of p for making an impact with curMedi
    
function [ numOfDeath, countDay, totalCost, minP ] = buildModel_MDD(dayInput, rateFunc,...
                                        ItoCrate, CtoDrate,...
                                        numMedicine, TCMap, p, ...
                                        labArr,costArr, maxDay)
% get dimension
numTC = size(dayInput, 1);      % number of treatment center
numGroup = size(dayInput, 2);   % number of classification of crowd
numLab = size(labArr, 1);

dayCompute = dayInput;
totalCost = 0;
% initialize minP
minP = 1;
% initialize condition history, record changes for every day
condiHist = cell(1,1);
condiHist{1} = dayInput;

% count days, medicines for periodical events
countDay = 1;
curMedicine = numMedicine;

% initialize a big matrix just for computation
reserveDayCompute = zeros(numTC,numGroup);
for i = 1:numLab
    
    curIndex = labArr(i,1);
    curMedi = labArr(i,2);
    curI = dayCompute(curIndex,2);
    toSub = min(curMedi, curI);
    reserveDayCompute(curIndex,2) = toSub;
end

% for the period
while(true)
    % new record for a new day
    newDayHist = zeros(numTC, numGroup);
    % compute a tempDay for computing index if medicine are first reserved
    temp = dayCompute - reserveDayCompute;
    
    % compute the expected spread and sort TC
    [expectNum, index] = computeExpectI(temp, rateFunc, countDay, TCMap);
    % compute the districts to receive the method
    [v_treatArr, v_noArr, targetMediArr, curMedicine] = ...
                            computeTargetDistrict...
                                (curMedicine, index, dayCompute, labArr);
                            
    % compute the transformation cost
    [transformAmountArr, cost ] = computeCost(labArr, costArr, targetMediArr);
    totalCost = totalCost + cost;
    % for every TC
    for k = 1:numTC
        % specify transformation matrixs
        medicineMat = [1,   0       ,0,           0;
                       0,   1       ,0,           0;
                       0,   0       ,1,           0;
                       0,   0       ,0,           1];
        spreadMat   = [1,   -1      , -1        , 0;
                       0,   1       , 1         , 0;
                       0,   ItoCrate, 1-CtoDrate, 0;
                       0,   0       , 1         , 1];
        i = index(k);
        % compute current medicineMat
        medicineMat(1:2,2:2) = medicineMat(1:2,2:2) + [p(i);-p(i)];
        % confirm which country
        curCountry = TCMap(i);
        spreadRate = polyval(rateFunc{curCountry}, countDay);
        
        curTC = dayCompute(i,:);
        % compute p
        Cp = curTC(3);Ip = curTC(2); 
        newP = 1 - 1/(1-ItoCrate+(1+Cp / Ip) * spreadRate);
        if newP < minP
            minP = newP;
        end
        %if spreadRate < 0
        %    spreadRate = 0;
        %end
        % update spreadMat function
        spreadMat(1:2, 2:3) = [-1, -1; 1, 1] .* spreadRate + ...
                                    [0,0;1-ItoCrate,0];
        % compute 
        v_treat = v_treatArr(i,:);
        v_no = v_noArr(i,:);
        v_treat = v_treat';
        v_no = v_no';
        v_treated = medicineMat * v_treat;
        nextTC = spreadMat * [(v_treated + v_no)];
        newDayHist(i, :) = nextTC';
    end
    for q = 1:numGroup
    curNegHealthIndex = find(newDayHist(:,q) < 0);
    for k = 1: length(curNegHealthIndex)
        newDayHist(curNegHealthIndex(k),q) = 0;
    end
    end
    condiHist = [condiHist; newDayHist];
    dayCompute = newDayHist;
    if (newDayHist(:,2:3) < 2);
        break;
    end
    %newDayHist
    if (countDay >= maxDay)
        break;
    end
    countDay = countDay + 1;
    curMedicine = curMedicine + numMedicine;
    
end
    numOfDeath = sum(newDayHist(3,:));
end



