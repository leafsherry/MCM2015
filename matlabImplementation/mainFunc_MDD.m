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
% This is the main function for assumption that the medicine lab is in
% local MMD.
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
[rawLabArr, costArr, dayInput] = inputDistanceInfo...
                        (distanceMapFile, vInit, ItoCrate, CtoDrate, numGroup,expectNumPeople);
                    
%% Basic var initialization

% Input data and compute
[x, rateCell] = computeRate('inputCountry.xlsx');
% Compute change function for three countries
rateFunc = rateFunction(x, rateCell, n);
%%
% objective     : for model_MMD, 
                    % 'dynamic' :?to test best produce rate combination
                    % 'constant':  to test best numMedicine
%% try to compute the appropriate medicine
if strcmp(objective,'constant')

    medArr = startM:changeRate:endM;

    %medArr = [2000];
    m = length(medArr);
    deathArr = zeros(m,1);
    dayArr = zeros(m,1);
    costoutArr = zeros(m,1);
    pArr = zeros(m,1);
    for i = 1: m
        numMedicine = medArr(i);
        [labArr] = computeLabProduce(rawLabArr, numMedicine, objective, produceMat, i);
        [ numOfDeath, countDay, totalCost, minP ] = buildModel_MMD(dayInput, rateFunc,...
                                            ItoCrate, CtoDrate,...
                                            numMedicine, TCMap, p, ...
                                            labArr,costArr, maxDay);                              
        deathArr(i) = numOfDeath;
        dayArr(i) = countDay;
        costoutArr(i) = totalCost;
        pArr(i) = minP;
    end
    h = figure(2);
    set(h,'name','model-MMD, objective-constant','Numbertitle','on');
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
    title('Total cost');
    xlabel('num of Medicine produced');
    ylabel('num. transportation cost');
elseif strcmp(objective, 'dynamic')
%% try to compute appropriate produce rate
    numProb = size(produceMat,1);
    deathArr = zeros(numProb,1);
    dayArr = zeros(numProb,1);
    costoutArr = zeros(numProb,1);
    pArr = zeros(m,1);
    for i = 1: numProb
        numMedicine = appropriateM;
        [labArr] = computeLabProduce(rawLabArr, numMedicine, objective, produceMat, i);
        [ numOfDeath, countDay, totalCost, minP ] = buildModel_MMD(dayInput, rateFunc,...
                                            ItoCrate, CtoDrate,...
                                            numMedicine, TCMap, p, ...
                                            labArr,costArr, maxDay); 
        deathArr(i) = numOfDeath;
        dayArr(i) = countDay;
        costoutArr(i) = totalCost;
        pArr(i) = minP;
    end
    h = figure(2);
    set(h,'name','model-MMD, objective-dynamic','Numbertitle','on');
    hold on;
    subplot(311)
    plot(deathArr);
    title('Num of total death');
    xlabel('index of produce rate combination');
    ylabel('num. death');
    subplot(312)
    plot(dayArr);
    title('Num of day needed to control situation');
    xlabel('index of produce rate combination');
    ylabel('num. days');
    subplot(313)
    plot(costoutArr);
    xlabel('index of produce rate combination');
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
        [labArr] = computeLabProduce(rawLabArr, numMedicine, 'constant', produceMat, i);
        [ numOfDeath, countDay, totalCost, minP ] = buildModel_MMD(dayInput, rateFunc,...
                                            ItoCrate, CtoDrate,...
                                            numMedicine, TCMap, p, ...
                                            labArr,costArr, maxDay);                              
        deathArr(i,j) = numOfDeath;
        dayArr(i,j) = countDay;
        costoutArr(i,j) = totalCost;
    end
    end
    surf(initP,medArr,deathArr);
else
    fprintf('Un-recognized objective: %s\n\n', objective);
end