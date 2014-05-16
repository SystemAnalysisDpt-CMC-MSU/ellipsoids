function [projOrthMatArray,projOrthMatTransArray]=...
    fGetProjMat(projMat,timeVec,varargin)
    nPoints=length(timeVec);
    projOrthMatArray=repmat(projMat,[1,1,nPoints]);
    projOrthMatTransArray=repmat(projMat.',[1,1,nPoints]);
end