function [isPositive,outVec]=isunique(inpVec)
outVec=unique(inpVec);
isPositive=length(inpVec)==length(outVec);
