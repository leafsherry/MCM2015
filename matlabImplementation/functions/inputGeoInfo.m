%% Comput which center to transform the medicines to -> min trans fee
    % input: 
        % countryMapFile
            % json file storing which country a district belongs to
        % targetTC (numTargetTC * 1)
            % json file storing which country are adjecent to each other
    % output:
        % TCMap: Mapping between country and TC
            % numTC * 1, each with num 1-numCountry indicating
            % which country
        % reachTCMat (numTC * numTC)
            % reachable from i to j: reachTCMat(i,j) = 1, 0 otherwise    
            
function [TCMap, reachTCMat] = inputGeoInfo(countryMapFile, neighborMapFile)
addpath('jsonlab-1.0/jsonlab/');
addpath('data');

countryMapCell = loadjson(countryMapFile);
neighborMapCell = loadjson(neighborMapFile);

% num of district
m = size(countryMapCell,2);

% initialization
TCMap = zeros(m, 1);
reachTCMat = eye(m, m);
for i = 1:m
    % generate TCMap
    TCMap(i) = countryMapCell{i}.countryID;
    % generate reachTCMat
    neighbor = neighborMapCell{i}.neighbor;
    n = size(neighbor,2);
    for j = 1:n
        index = neighbor(j);
        reachTCMat(i, index) = 1;
        reachTCMat(index, i) = 1;
    end
end
end