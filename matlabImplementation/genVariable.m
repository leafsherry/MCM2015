% This file for generating necessary varaibles.
% n             : degree for polyfit
n = 6;
% numTC         : (Num. treatment center)
numTC = 61;
%numGroup       : i.e. CV (condition vector length)
numGroup = 4;
% objective     : for model_Africa, 
                    % 'dynamic' :?to test best produce rate combination
                    % 'constant':  to test best numMedicine
objective = 'constant';
%objective = 'pValue';
%objective = 'dynamic';
% ItoC          : Period for I to C to happen
ItoC = 2;
% CtoD          : Period for C to D to happen
WtoD = 5;

% ItoCrate      : ItoCrate q
% CtoDrate      : deathRate d
ItoCrate = 0.1;
CtoDrate = 0.7;
% vInit         : initial Spread rate
vInit = 0.1;
% p             : Preparedness, numTC * 1, different for every TC
% p = 0.06 + (0.64-0.06).* rand(numTC,1);
startP = 0.01;
endP = 1;
changeP = 0.01;
p = [
   0.635324734346478
   0.509428186386073
   0.561254871112417
   0.544917591993472
   0.518767288176062
   0.518841921031598
   0.612832672444618
   0.573466997015285
   0.632195975881401
   0.638367610729421
   0.557385185178597
   0.551966302799947
   0.531759572942304
   0.562444334235339
   0.537271001259402
   0.564273495155444
   0.560606745936628
   0.536347280800769
   0.518720031171264
   0.558691978602722
   0.570960471573956
   0.545405437700014
   0.595856432058758
   0.562033091543733
   0.560992831177254
   0.611023292178635
   0.614177891755776
   0.605295771519335
   0.610495831784979
   0.570177443431822
   0.577725469177597
   0.588304963373823
   0.513718483078483
   0.534394665471164
   0.586201519920547
   0.542694394064982
   0.607375464385179
   0.537412072931392
   0.505530882595228
   0.541518648854618
   0.577891096513117
   0.635670425952328
   0.596477459558785
   0.600503395774263
   0.578264076739791
   0.574669589092512
   0.622601360359048
   0.555033802981430
   0.564129371320129
   0.529154328696260
   0.606018242817735
   0.576536883944990
   0.550034347015484
   0.598139690557333
   0.515291149536412
   0.500925507234988
   0.583622291172189
   0.592284649327062
   0.581200900277263
   0.627393225417221
   0.589040861295646    
];
p = p';
% maxDay        : at most put into action for this number of day
maxDay = 500;
% expectNumPeople:generate how many people
expectNumPeople = 100000;
% start and end medicine num
    % for objective : 'constant'
startM = 1000;
endM = 20000;
changeRate = 500;
    % for objective : 'constant'
appropriateM = 5000;
    
% ProduceMat    : possible produce rates
baseProduceMat = [
    0.1, 0.1, 0.1, 0.1, 0.6;
    0.1, 0.1, 0.1, 0.2, 0.5;
    0.1, 0.1, 0.1, 0.3, 0.4;
    0.1, 0.1, 0.2, 0.2, 0.4;
    0.1, 0.1, 0.2, 0.3, 0.3;
    0.1, 0.2, 0.2, 0.2, 0.3;
    0.2, 0.2, 0.2, 0.2, 0.2;
    ];
produceMat = [];
numProb = size(baseProduceMat,1);
for i = 1: numProb
    newProb = perms(baseProduceMat(i,:));
    newPerms = unique(newProb,'rows');
    produceMat = [produceMat; newPerms]; 
end
