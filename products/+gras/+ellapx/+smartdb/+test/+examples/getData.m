% This function returns the values of arguments, that are the same for
% FROMQARRAYS, FROMQMARRAYS and FROMQMSCALEDARRAYS methods of creating an 
% ellipsoid tube object. Basically, this function creates a set of
% arguments nessesary for creating an ellipsoid tube object containing 
% nTubes ellipsoid tubes. Here nTubes is a random natural number in the
% range from one to ten.
%
function [nTubes, nPoints, nDims, absTol, relTol, timeVec,...
    sTime, lsGoodDirVec, ltGoodDirArray, aMat, qArrayList] = getData()
nTubes=randi(10,1);
nPoints=20;
nDims=3;
absTol=0.001;
relTol=0.001;
timeVec=(1/nPoints):(1/nPoints):1;
sTime=timeVec(randi(nPoints,1));
lsGoodDirVec=[1;0;0];
ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
aMat=zeros(nDims,nPoints);
qArrayList=repmat({repmat(diag([0.1 0.2 0.3]),[1,1,nPoints])},1,nTubes);
end