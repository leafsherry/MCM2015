% To generate labArr and costArr.
    % input
        % distanceMapFile : file containing the desired information
        % totalMedi     : total medicine count producted everyday
        % vInit         : initial Spread rate
        % ItoCrate      : ItoCrate q
        % CtoDrate      : deathRate d
        % numGroup      : num of 4 [H, I, C, D]
        % expectNumPeople:generate how many people
    % output
        % costArr       : numLab * numTC, 
                        %(i,j): cost from lab_i to TC_j
        % rawlabArr     : the index of district and numMedi for the lab
                        %[index, numMedProducted],numMedProducted = 0
        % dayInput      : initial conditions in every treatment center
            % Dimension : numTC (Num. treatment center) * CV (condition vector)
            % CV        : [  
                        %H: no infection + live
                        %I: infection + no medicine
                        %C: infection + advanced
                        %D: no infection + dead
                     %]

function [ rawlabArr, costArr, dayInput ] = inputDistanceInfo...
                        (distanceMapFile, vInit, ItoCrate, CtoDrate, numGroup, expectNumPeople)

addpath('data');
addpath('jsonlab-1.0/jsonlab/');
% read in
distFile = loadjson(distanceMapFile);
costArr = distFile.distanceArr;
% dimensions
numLab = length(distFile.labIndex);
numTC = size(distFile.distanceArr,2);
rawlabArr = [distFile.labIndex; zeros(1,numLab)]';

d = distFile.populationArr;
totalSum = sum(sum(d));
d = d./totalSum * expectNumPeople;
d = d';

%d = randi(3000,numTC, 1);
genMat = [1, vInit, vInit * ItoCrate, vInit * ItoCrate * CtoDrate];

dayInput = d * genMat;
end

