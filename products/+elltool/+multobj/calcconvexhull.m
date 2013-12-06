function [convexMat, convexVec, discrepVec,vertMat] =...
    calcconvexhull(pointsMat,indVec,improveDirectVec,nPropExpected, properties)
%
% CALCCONVEXHULL - builds the convex hull of given points
%
%  Input:
%    regular:
%       pointsMat: double [nPoints, nDims] - array of points to build the
%                  convex hull
%       indVec:double [1, nElems] - indieces of variables
%       improveDirectVec: double [1, nElems] - the direction of improvement
%                         of  variables:  nonzero value indicates that for
%                         corresponding variable Pareto shell will be built
%                         in specified direction
%       for each variable :1 -  increase,-1 - reduction,0 - no improvement
%       NOTE: if Pareto shell is not needed, indVec and
%       improveDirectVec must be empty.
%    optional:
%       nPropExpected: double[1,1] - an expected number of properties
%     properties:
%       nAddTopElems: double[1,1] - the number of points, that will be
%          additionally attached to the convex hull before the process is
%          completed; by default the value of nAddTopElems is set in a such way,
%          that the common number of attached points is divided on 32
%
%       approxPrec: double[1,1] - desirable precision of approximation,
%          when the precision is reached, the process will be completed;
%          by default approxPrec = 1e-3
%
%       errorCheckMode: double[1,1] - determines if mode of checking errors,
%          emerged during the process of construction of the convex hull
%          and associated with rounding during the calculations,is on
%          (1 - by default) or off (0)
%
%       freeMemoryMode: double[1,1] - determines if mode of freeing memory
%          after attaching of each vertex is on (1) or off (0 - by default)
%
%       discardIneqMode: double[1,1] - determines if mode of combinatory
%          discarding  nonessential inequalities is on (1 - by default)
%          or off (0)
%
%       incDim: double[1,1] - using (1) or disuse (0 - by default) of
%           combinatory transition into the space of one more dimensoin

%       faceDist: double[1,1] - is used to determine on which side from
%          the face the attached point is, if the distance from the point
%          to the hyperplane of the face is less then faceDist then it is
%          considered that the point is on the face;by default faceDist=9e-5
%
%       inApproxDist: double[1,1] - is used in the process of approximation;
%          if  the point found as a result of calculating  the support
%          function lies inside the current approximation at the distance
%          more than inApproxDist, then the process is interrupted with
%          a message "the vertex is inside the multiplicity" ;
%          by default inApproxDist = 1e-4
%
%       ApproxDist: double[1,1] - is used in the process of approximation;
%          if  the point found as a result of calculating  the support
%          function lies at the distance less than ApproxDist from the
%          internal approximation then it is not expectant to be attached
%          and so it isn't kept on memory;by default ApproxDist  = 1e-5
%
%       precTest: double[1,1] - is used only when errorCheckMode = 1;
%          if the vertex of the convex hull should be on the face
%          (according to the polytope's structure), but actually lies at
%          the distanse more than precTest from the face because of  erros,
%          emerged by rounding during the calculations, then the process
%          is interrupted with message "the precision s not sufficient";
%          by default precTest = 1e-4
%
%       relPrec: double[1,1] - is used in the process of calculating
%          the dot product; if when finding the sum of two values,
%          the result isn't more than the result of multiplying of one
%          of the values and relPrec, then the sum is defined as 0;
%          by default relPrec = 1e-5
%
%       inftyDef: double[1,1] - is used as infinity; by default inftyDef=1e6
%
%       isVerbose:double[1,1] - determins if the mode of printing the
%
%          process information is on (1) or off (0 - be default)
%               NOTE: faceDist must be less than ApproxDist and precTest!
%
%  Output:
%       convexMat: double [nResInequalities,nDims]
%       convexVec:double [nResInequalities,1]
%       the result is defined  as a multiplicity of x such that:
%                      convexMat*x +  convexVec <= 0
%
%       discrepVec: double [1,nResInequalities] - vector of approximation
%          error for  each vertex of result polytope
%       vertMat: double [nVertices, nDims] - vertices of result polytope

import modgen.common.throwerror;
import modgen.common.checkvar;
import modgen.common.checkmultvar;

params=elltool.multobj.ObjectApproxControlParams;

if (nargin < 4)
    throwerror('wrongInput','4 or 5 input arguments needed');
end
checkvar(pointsMat,@(x)isa(x,'double'),'errorTag',...
    'wrongType','errorMessage','polyMat must be double array');

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
    SParams=params.convexHullParams(properties);
    controlParams=[SParams.nAddTopElems SParams.errorCheckMode SParams.approxPrec...
                SParams.freeMemoryMode SParams.discardIneqMode ...
                SParams.incDim SParams.faceDist SParams.inApproxDist...
                SParams.ApproxDist SParams.precTest SParams.relPrec...
                SParams.inftyDef SParams.isVerbose];
else
    controlParams=params.getValues(propList);
end

checkvar(controlParams,@(x)isa(x,'double'),'errorTag',...
    'wrongParamsType','errorMessage','properties must be double');

checkvar(pointsMat,'size(x,1)>=3','errorTag','wrongSize',...
    'errorMessage','polyMat must contain at least three points');

checkvar(pointsMat,'ndims(x)==2','errorTag','wrongSize',...
    'errorMessage','polyMat must be 2-dimensional array');

checkvar(indVec,'size(x,1)<=1','errorTag','wrongSize',...
    'errorMessage','indVec must be vector');

checkvar(improveDirectVec,'size(x,1)<=1','errorTag',...
    'wrongSize','errorMessage','improveDirectVec must be vector');

checkmultvar('size(x1,2)==size(x2,2)',2,indVec,...
    improveDirectVec,'errorTag','wrongSizes',...
    'errorMessage','indVec and improveDirectVec must be the same length');

nDims = size(pointsMat,2);
pointsMat=pointsMat';
pointsMat=pointsMat(:);
pointsMat=pointsMat';
num=numel(pointsMat);
[convexMat,convexVec,discrepVec,vertMat,sizeMat]=...
    elltool.multobj.mexconvexhull(nDims,indVec,improveDirectVec,num,...
    pointsMat,controlParams);
convexMat=convexMat(1:min(numel(convexMat),sizeMat(1)));
convexVec=convexVec(1:min(numel(convexVec),sizeMat(2)));
discrepVec=discrepVec(1:min(numel(discrepVec),sizeMat(3)));
vertMat=vertMat(1:min(numel(vertMat),sizeMat(4)));
convexMat=reshape(convexMat,numel(convexMat)/nDims,nDims);
convexVec=(convexVec)';
vertMat=reshape(vertMat,numel(vertMat)/nDims,nDims);
if (numel(convexMat)==0)
    convexMat=[];
    convexVec=[];
    discrepVec=[];
    vertMat = [];
end
end