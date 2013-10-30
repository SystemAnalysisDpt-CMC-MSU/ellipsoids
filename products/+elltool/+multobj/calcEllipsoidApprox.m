function [approxMat, approxVec, discrepVec,vertMat] = calcEllipsoidApprox(centerVec, semiaxesVec, controlParamsVec,nPropExpected, properties)

% CALCELLIPSOIDAPPROX - builds the approximation of ellipsoid by the polytope
% 
% Input:
%   regular:
%       centerVec: double [1, nDims] -  ellipsoid's center coordinates 
%       semiaxesVec: double [1, nDims] -  values of ellipsoid's  semiaxes
%       controlParamsVec:double[1,nParamsElems] - values of control params that do not match with the default values
%   optional:
%       nPropExpected: double[1,1] - an expected number of properties
% 
%    properties:
%       add_top: double[1,1] - the number of points, that will be additionally attached to the convex hull before the process is completed; by default the value of add_top is set in a such way, that the common number of attached points is divided on 32
%       EPSset: double[1,1] - desirable precision of approximation, when the precision is reached, the process will be completed; by default EPSset = 1e-3  
%       RCHECK: double[1,1] - determines if mode of checking errors, emerged during the process of construction of the convex hull and associated with rounding during the calculations, is on (1 - by default) or off (0)
%       RFREE: double[1,1] - determines if mode of freeing memory after attaching of each vertex is on (1) or off (0 - by default)
%       INCHECK: double[1,1] - determines if mode of combinatory discarding  nonessential inequalities is on (1 - by default) or off (0)
%       RHYPER : double[1,1] - using (1) or disuse (0 - by default)  of  combinatory transition into the space of one more dimensoin
%       EPSdif: double[1,1] - is used to determine on which side from the face the attached point is, if the distance from the point to the hyperplane of the face is less then EPSdif then it is considered that the point is on the face; by default EPSdif = 9e-5
%       EPSin: double[1,1] - is used in the process of approximation; if  the point found as a result of calculating  the support function lies inside the current approximation at the distance more than EPSin, then the process is interrupted with a message "the vertex is inside the multiplicity" ; by default EPSin = 1e-4  
%       EPSest: double[1,1] - is used in the process of approximation; if  the point found as a result of calculating  the support function lies at the distance less than EPSset from the internal approximation then it is not expectant to be attached an so it isn't kept on memory;by default EPSest  = 1e-5
%       EPScheck: double[1,1] - is used onle whem RCHECK = 1;  if the vertex of the convex hull should be on the face ( according to the polytope's structure), but actually lies at the distanse more than EPScheck from the face because of  erros, emerged by rounding during the calculations, then the process is interrupted with message "the precision s not sufficient"; by default EPScheck  = 1e-4
%       EPSrel: double[1,1] - is used in the process of calculating  the dot product; if when finding the sum of two values, the result isn't more than the result of multiplying of one of the values and EPSrel, then the sum is defined as 0;by default EPSrel  = 1e-5
%       INF: double[1,1] - is used as infinity; by default INF  = 1e6
%       isVerbose:double[1,1] - determins if the mode of printing the process information is on (1) or off (0 - be default)
%         NOTE: EPSdif must be less than EPSest and EPScheck!
%  Output:
%       approxMat: double [nResInequalities,nDims] ,
%       approxVec: double [nResInequalities,1] 
%       the result is defined  as a multiplicity of x such that:
%                                                approxMat*x +  approxVec <= 0                                               
%         
%       discrepVec: double [1,nVertices] - vector of decperancy for the inequality on the estimated top
%       vertMat: double [nVertices, nDims] - vertices of result polytope
