function [approxMat, approxVec, discrepVec,vertMat] =...
    calcellipsoidapprox(semiaxesVec,indVec,improveDirectVec,nPropExpected, properties)

% CALCELLIPSOIDAPPROX - builds the approximation of ellipsoid with center
%                       in the origin by the polytope
%
% Input:
%   regular:
%       semiaxesVec: double [1, nDims] -  values of ellipsoid's  semiaxes
%       indVec:double [1, nElems] - indieces of variables
%       improveDirectVec: double [1, nElems] - the direction of improvement
%                         of  variables:  nonzero value indicates that for
%                         corresponding  variable Pareto shell will be built
%                         in specified direction
%       for each variable :1 -  increase,-1 - reduction,0 - no improvement
%       NOTE: if Pareto shell is not needed, indVec and
%             improveDirectVec must be empty.
%   optional:
%       nPropExpected: double[1,1] - an expected number of properties
%
%    properties:
%       approxPrec: double[1,1] - desirable precision of approximation,
%           when the precision is reached, the process will be completed;
%            by default approxPrec = 1e-3
%
%       freeMemoryMode: double[1,1] - determines if mode of freeing memory
%           after attaching of each vertex is on (1) or off (0 - by default)
%
%       discardIneqMode: double[1,1] - determines if mode of combinatory
%           discarding  nonessential inequalities is on (1 - by default)
%           or off (0)
%
%       faceDist: double[1,1] - is used to determine on which side from
%           the face the attached point is, if the distance from the point
%           to the hyperplane of the face is less then faceDist then it
%           is considered that the point is on the face;
%           by default faceDist = 9e-5
%
%       inApproxDist: double[1,1] - is used in the process of approximation;
%           if  the point found as a result of calculating the support
%           function lies inside the current approximation at the distance
%           more than inApproxDist, then the process is interrupted
%           with a message "the vertex is inside the multiplicity" ;
%           by default inApproxDist = 1e-4
%
%       ApproxDist: double[1,1] - is used in the process of approximation;
%           if  the point found as a result of calculating  the support
%           function lies at the distance less than ApproxDist from the
%           internal approximation then it is not expectant to be attached
%           and so it isn't kept on memory;by default ApproxDist  = 1e-5
%
%       relPrec: double[1,1] - is used in the process of calculating
%           the dot product; if when finding the sum of two values,
%           the result isn't more than the result of multiplying of one
%           of the values and relPrec, then the sum is defined as 0;
%           by default relPrec = 1e-5
%
%       inftyDef: double[1,1] - is used as infinity; by default inftyDef=1e6
%
%       isVerbose:double[1,1] - determins if the mode of printing
%           the process information is on (1) or off (0 - be default)
%               NOTE: faceDist must be less than ApproxDist!
%  Output:
%       approxMat: double [nResInequalities,nDims] ,
%       approxVec: double [nResInequalities,1]
%       the result is defined  as a multiplicity of x such that:
%                   approxMat*x +  approxVec <= 0
%
%       discrepVec: double [1,nResInequalities] - vector of approximation
%                   error for  each vertex of result polytope
%       vertMat: double [nVertices, nDims] - vertices of result polytope


import modgen.common.throwerror;
import modgen.common.checkvar;
import modgen.common.checkmultvar;

params=elltool.multobj.ObjectApproxControlParams;

if (nargin < 4)
    throwerror('wrongInput','4 or 5 input arguments needed');
end
checkvar(semiaxesVec,@(x)isa(x,'double'),'errorTag',...
    'wrongType','errorMessage','semiaxesVec must be double array');

checkvar(nPropExpected,@(x)isa(x,'numeric'),'errorTag',...
    'wrongInput','errorMessage','nPropExpected must be defined');

if (nargin==5)
    checkvar(properties,@(x)isa(x,'cell'),'errorTag',...
        'wrongType','errorMessage','properties mast be cell array');
end

propList={'nAddTopElems','errorCheckMode','approxPrec',...
    'freeMemoryMode','discardIneqMode','incDim','faceDist',...
    'inApproxDist','ApproxDist','precTest','relPrec',...
    'inftyDef','isVerbose'};

if(nPropExpected > 0)
    SParams=params.parseParams(properties,propList);
    controlParams=zeros(1,numel(propList));
    for iElem=1:numel(propList)
        checkvar(SParams.(propList{iElem}),@(x)isa(x,'double'),'errorTag',...
            'wrongParamsType','errorMessage','properties must be double');
        controlParams(iElem)=SParams.(propList{iElem});
    end
    checkmultvar('(x1<x2)',2,SParams.(propList{7}),...
        SParams.(propList{9}), 'errorTag',...
        'wrongParams','errorMessage',...
        'faceDist must be less then ApproxDist');
else
    controlParams=params.getValues(propList);
end
checkvar(controlParams,@(x)isa(x,'double'),'errorTag',...
    'wrongParamsType','errorMessage','properties must be double');

checkvar(semiaxesVec,'size(x,1)==1','errorTag','wrongSize',...
    'errorMessage','semiaxesVec must be vector');

checkvar(indVec,'size(x,1)<=1','errorTag','wrongSize',...
    'errorMessage','indVec must be vector');

checkvar(improveDirectVec,'size(x,1)<=1','errorTag',...
    'wrongSize','errorMessage','improveDirectVec must be vector');

checkmultvar('size(x1,2)==size(x2,2)',2,indVec,...
    improveDirectVec,'errorTag','wrongSizes',...
    'errorMessage','indVec and improveDirectVec must be the same length');

nDims = numel(semiaxesVec);
centerVec=zeros(1,nDims);
[approxMat,approxVec,discrepVec,vertMat,sizeMat]=...
    elltool.multobj.mexellipsoidapprox(nDims,indVec,improveDirectVec,...
    centerVec,semiaxesVec,controlParams);
approxMat=approxMat(1:sizeMat(1));
approxVec=approxVec(1:sizeMat(2));
discrepVec=discrepVec(1:sizeMat(3));
vertMat=vertMat(1:sizeMat(4));
approxMat=reshape(approxMat,numel(approxMat)/nDims,nDims);
approxVec=(approxVec)';
vertMat=reshape(vertMat,numel(vertMat)/nDims,nDims);
end