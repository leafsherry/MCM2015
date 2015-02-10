%% This function build the model w.r.t input.

% Input:
    % dayInput      : initial conditions in every treatment center
        % Dimension : numTC (Num. treatment center) * CV (condition vector)
        % CV        : [  
                        %H: no infection + live
                        %I: infection + no medicine
                        %W: infection + advanced
                        %D: no infection + dead
                     %]
    % rateFunc      : Spread rate computed w.r.t the given data
    % ItoC          : Period for I to C to happen
    % CtoD          : Period for C to D to happen
    % numMedicine   : Available medicine
    % TCMap         : Mapping between country and TC
                        % numTC * 1, each with num 1-numCountry indicating
                        % which country

% Output:
    % numOfDeath    : total death
    % condiHist     : record of everyday's change
function [ numOfDeath, countDay ] = buildModel(dayInput, rateFunc,...
                                        ItoC, CtoD, numMedicine, TCMap)
% get dimension
numTC = size(dayInput, 1);      % number of treatment center
numGroup = size(dayInput, 2);   % number of classification of crowd

dayCompute = dayInput;

% specify transformation matrixs
medicineMat = [1, 1, 0, 0;
               0, 0, 0, 0;
               0, 0, 1, 0;
               0, 0, 0, 1];
spreadMat   = [1, -1, -1, 0;
               0, 1, 1, 0;
               0, 0, 1, 0;
               0, 0, 0, 1];
ItoWMat     = [1, 0, 0, 0;
               0, 0, 0, 0;
               0, 1, 1, 0;
               0, 0, 0, 1];
WtoDMat     = [1, 0, 0, 0;
               0, 1, 0, 0;
               0, 0, 0, 0;
               0, 0, 1, 1];

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
        i = index(k);
        % confirm which country
        curCountry = TCMap(i);
        spreadRate = polyval(rateFunc{curCountry}, countDay);
        %if spreadRate < 0
        %    spreadRate = 0;
        %end
        % update spreadMat function
        spreadMat(1:2, 2:3) = [-1, -1; 1, 1] .* spreadRate + [0,0;1,0];
        
        curTC = dayCompute(i,:);
        % w to D
        if (mod(countDay,CtoD) == 0)
            curTC = (WtoDMat * curTC')';
        end  
        [v_treat, v_no, curMedicine] = computePartition(curTC, curMedicine);
        %v_treat
        %v_no
        v_treated = medicineMat * v_treat;
        nextTC = spreadMat * (v_treated + v_no);
        newDayHist(i, :) = nextTC';
        % if the next day is for ItoW
        if (mod(countDay,CtoD) == 0 && countDay > ItoC)
            histDay = condiHist{countDay-ItoC};
            histSpreadRate = polyval(rateFunc{curCountry}, countDay-ItoC);
            %if histSpreadRate < 0
            %    histSpreadRate = 0;
            %end
            newDayHist(i, 3) = histSpreadRate * dayCompute(i, 3);
        end
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
    if (countDay >1000)
        break;
    end
    countDay = countDay + 1;
    curMedicine = curMedicine + numMedicine;
end
    numOfDeath = sum(newDayHist(4,:));
end



