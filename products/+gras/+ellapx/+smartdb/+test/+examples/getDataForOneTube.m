% This function returns the values of arguments, that are needed to use
% FROMELLARRAY and FROMELLMARRAY methods of creating an ellipsoid tube 
% object. Basically, this function creates a set of arguments nessesary for
% creating an ellipsoid tube object containing one ellipsoid tube.
%
function [nTubes, nPoints, nDims, absTol, relTol, timeVec,...
    sTime, lsGoodDirVec, ltGoodDirArray, aMat, qArrayList] = getDataForOneTube()
nTubes=1;
nPoints=20;
nDims=3;
absTol=0.001;
relTol=0.001;
timeVec=(1/nPoints):(1/nPoints):1;
sTime=timeVec(randi(nPoints,1));
lsGoodDirVec=[1;0;0];
ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
aMat=zeros(nDims,nPoints);
qArrayList=repmat({repmat(diag([1 2 3]),[1,1,nPoints])},1,nTubes);
end