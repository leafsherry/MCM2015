% for generating the madicine per day of each lab
    % input:
        % rawlabArr     : the index of district and numMedi for the lab
                            %[index, numMedProducted],numMedProducted = 0
        % numMedicine   : total num of medicine produced per day
        % type          : which objective
                            % 'constant': same produce ability
                            % 'dynamic' : given total num of medicine,
                                % try different produce rate
        % ProduceMat    : possible produce rates
        % i             : the ith produce rate
    % output
        % labArr        : the index of district and numMedi for the lab
                            %[index, numMedProducted]
function [labArr] = computeLabProduce(rawLabArr, numMedicine, type, produceMat, i)
labArr = rawLabArr;
% dimension
numLab = size(labArr,1);
if strcmp(type,'constant')
    numMedProducted = numMedicine / numLab;
    labArr(:,2) = ones(numLab, 1) * numMedProducted;
elseif strcmp(type, 'dynamic')
    labArr(:,2) = numMedicine * produceMat(i,:);
else
    fprintf('Un-recognized type: %s\n\n', type);
end

end

