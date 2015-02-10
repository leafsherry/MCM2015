%% MCM 2015 problem A: Erdicating data

%  Declaration
%  ------------
%  Date: 2015 / 02 / 09
%  Author: WU Tongshuang

%  Background
%  ------------
% The world medical association has announced that their new medication 
% could stop Ebola and cure patients whose disease is not advanced. Build 
% a realistic, sensible, and useful model that considers not only the
% spread of the disease, the quantity of the medicine needed, possible
%feasible delivery systems (sending the medicine to where it is needed), 
% (geographical) locations of delivery, speed of manufacturing of the 
% vaccine or drug, but also any other critical factors your team considers 
% necessary as part of the model to optimize the eradication of Ebola, or 
% at least its current strain. In addition to your modeling approach for 
% the contest, prepare a 1-2 page non-technical letter for the world 
% medical association to use in their announcement.

% Instruction
% ------------
% This is the main function for assumption that the medicine lab is in SOD.
%%
clc; clear;
format long
%% Generate useful data
genVariable;

% add datapath
addpath('data');
addpath('functions');

% load geo information
countryMapFile = 'countryMap.json';
neighborMapFile = 'neighborMap.json';
distanceMapFile = 'distanceMap.json';


[TCMap, reachTCMat] = inputGeoInfo(countryMapFile, neighborMapFile);
targetTC = [4,5,20,40];
transitTC = computeTransMethod(reachTCMat, targetTC);
[rawLabArr, costArr, dayInput] = inputDistanceInfo...
                        (distanceMapFile, vInit, ItoCrate, CtoDrate, numGroup,expectNumPeople);
%% Basic var initialization

% Input data and compute
[x, rateCell] = computeRate('inputCountry.xlsx');
% Compute change function for three countries
rateFunc = rateFunction(x, rateCell, n);
if strcmp(objective,'constant')

%% try to compute the appropriate medicine
medArr = startM:changeRate:endM;

%medArr = [2000];
m = length(medArr);
deathArr = zeros(m,1);
dayArr = zeros(m,1);
costoutArr = zeros(m,1);
pArr = zeros(m,1);
for i = 1: m
    numMedicine = medArr(i);
    [ numOfDeath, countDay, totalCost, minP ] = buildModel_SOD(dayInput, rateFunc,...
                                        ItoCrate, CtoDrate...
                                        , numMedicine, TCMap, p, maxDay,reachTCMat);                          
    deathArr(i) = numOfDeath;
    dayArr(i) = countDay;
    costoutArr(i) = totalCost;
    pArr(i) = minP;
end
    h = figure(2);
    set(h,'name','model-SOD','Numbertitle','on');
    hold on;
    subplot(311)
    plot(medArr, deathArr);
    title('Num of total death');
    xlabel('num of Medicine produced');
    ylabel('num. death');
    subplot(312)
    plot(medArr, dayArr);
    title('Num of day needed to control situation');
    xlabel('num of Medicine produced');
    ylabel('num. days');
    subplot(313)
    plot(medArr, costoutArr);
    xlabel('Num of day needed to control situation');
    ylabel('num. transportation cost');
    title('Total cost');
elseif strcmp(objective, 'pValue')
%% try to compute appropriate produce rate
    initP = startP: changeP: endP;
    medArr = startM:changeRate:endM;
    m = length(medArr);
    n = length(initP);
    deathArr = zeros(m,n);
    dayArr = zeros(m,n);
    costoutArr = zeros(m,n);
    for i = 1: m
    for j = 1: n
        numMedicine = medArr(i);
        p = initP(j) * ones(numTC,1);
        [ numOfDeath, countDay, totalCost, minP ] = buildModel_SOD(dayInput, rateFunc,...
                                        ItoCrate, CtoDrate...
                                        , numMedicine, TCMap, p, maxDay,reachTCMat);                             
        deathArr(i,j) = numOfDeath;
        dayArr(i,j) = countDay;
        costoutArr(i,j) = totalCost;
    end
    end
    surf(initP,medArr,costoutArr);
else
    fprintf('Un-recognized objective: %s\n\n', objective);
end