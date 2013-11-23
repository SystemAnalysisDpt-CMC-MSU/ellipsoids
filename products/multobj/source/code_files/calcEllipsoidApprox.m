function [approxMat, approxVec, discrepVec,vertMat] = calcEllipsoidApprox(centerVec, semiaxesVec,nPropExpected, properties)

% CALCELLIPSOIDAPPROX - builds the approximation of ellipsoid by the polytope
% 
% Input:
%   regular:
%       centerVec: double [1, nDims] -  ellipsoid's center coordinates 
%       semiaxesVec: double [1, nDims] -  values of ellipsoid's  semiaxes
%   optional:
%       nPropExpected: double[1,1] - an expected number of properties
% 
%    properties:
%       approxPrec: double[1,1] - desirable precision of approximation, when the precision is reached, the process will be completed; by default approxPrec = 1e-3  
%       freeMemoryMode: double[1,1] - determines if mode of freeing memory after attaching of each vertex is on (1) or off (0 - by default)
%       discardIneqMode: double[1,1] - determines if mode of combinatory discarding  nonessential inequalities is on (1 - by default) or off (0)
%       faceDist: double[1,1] - is used to determine on which side from the face the attached point is, if the distance from the point to the hyperplane of the face is less then faceDist then it is considered that the point is on the face; by default faceDist = 9e-5
%       inApproxDist: double[1,1] - is used in the process of approximation; if  the point found as a result of calculating  the support function lies inside the current approximation at the distance more than inApproxDist, then the process is interrupted with a message "the vertex is inside the multiplicity" ; by default inApproxDist = 1e-4  
%       ApproxDist: double[1,1] - is used in the process of approximation; if  the point found as a result of calculating  the support function lies at the distance less than ApproxDist from the internal approximation then it is not expectant to be attached and so it isn't kept on memory;by default ApproxDist  = 1e-5
%       relPrec: double[1,1] - is used in the process of calculating  the dot product; if when finding the sum of two values, the result isn't more than the result of multiplying of one of the values and relPrec, then the sum is defined as 0;by default relPrec = 1e-5
%       inftyDef: double[1,1] - is used as infinity; by default IinftyDef = 1e6
%       isVerbose:double[1,1] - determins if the mode of printing the process information is on (1) or off (0 - be default)
%             NOTE: EPSdif must be less than faceDist and precTest!
%  Output:
%       approxMat: double [nResInequalities,nDims] ,
%       approxVec: double [nResInequalities,1] 
%       the result is defined  as a multiplicity of x such that:
%                                                approxMat*x +  approxVec <= 0                                               
%         
%       discrepVec: double [1,nResInequalities] - vector of approximation
%          error for  each vertex of result polytope
%       vertMat: double [nVertices, nDims] - vertices of result polytope

if(nPropExpected > 0)
    [reg,isSpecVec,...
          propVal1,propVal2,propVal3,propVal4,propVal5,propVal6,propVal7...
          propVal8,propVal9,propVal10,propVal11,propVal12,propVal13]=...
          modgen.common.parseparext(properties,...
          {'nAddTopElems','errorCheckMode','approxPrec','freeMemoryMode','discardIneqMode',...
          'incDim','faceDist','inApproxDist','ApproxDist','precTest','relPrec','inftyDef','isVerbose';...
         32, 1.e-3 ,1.0 ,0.0, 1.0, 0.0, .9e-5, 1.e-4, 1.e-5, 1.e-4, 1.e-5, 1.e6,1;})
    controlParams=[propVal1 propVal2 propVal3 propVal4 propVal5 propVal6 propVal7 propVal8 propVal9 propVal10 propVal11 propVal12 propVal13];
else
    controlParams=[32 1.e-3 1.0 0.0 1.0 0.0 .9e-5 1.e-4 1.e-5 1.e-4 1.e-5 1.e6 1];
end

size = numel(centerVec);
indProjVec=[];
improveDirectVec=[];
[approxMat,approxVec,discrepVec,vertMat,sizeMat]=EllipsoidApprox(size,indProjVec,improveDirectVec,centerVec,semiaxesVec,controlParams);
approxMat=approxMat(1:sizeMat(1));
approxVec=approxVec(1:sizeMat(2));
discrepVec=discrepVec(1:sizeMat(3));
vertMat=vertMat(1:sizeMat(4));
approxMat=reshape(approxMat,numel(approxMat)/size,size);
approxVec=(approxVec)';
vertMat=reshape(vertMat,numel(vertMat)/size,size);
end