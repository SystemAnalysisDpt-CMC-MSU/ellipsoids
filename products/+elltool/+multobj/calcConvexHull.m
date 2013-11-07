 function [convexMat, convexVec, discrepVec,vertMat] = calcConvexHull(polyMat,nPropExpected, properties)
% 
% CALCCONVEXHULL - builds the convex hull of given points
% 
%  Input:
%    regular:
%       pointsMat: double [nPoints, nDims] - array of points to build the convex hull
%    optional:
%       nPropExpected: double[1,1] - an expected number of properties
%     properties:
%       nAddTopElems: double[1,1] - the number of points, that will be additionally attached to the convex hull before the process is completed; by default the value of nAddTopElems is set in a such way, that the common number of attached points is divided on 32
%       approxPrec: double[1,1] - desirable precision of approximation, when the precision is reached, the process will be completed; by default approxPrec = 1e-3  
%       errorCheckMode: double[1,1] - determines if mode of checking errors, emerged during the process of construction of the convex hull and associated with rounding during the calculations, is on (1 - by default) or off (0)
%       freeMemoryMode: double[1,1] - determines if mode of freeing memory after attaching of each vertex is on (1) or off (0 - by default)
%       discardIneqMode: double[1,1] - determines if mode of combinatory discarding  nonessential inequalities is on (1 - by default) or off (0)
%       incDim: double[1,1] - using (1) or disuse (0 - by default)  of  combinatory transition into the space of one more dimensoin
%       faceDist: double[1,1] - is used to determine on which side from the face the attached point is, if the distance from the point to the hyperplane of the face is less then faceDist then it is considered that the point is on the face; by default faceDist = 9e-5
%       inApproxDist: double[1,1] - is used in the process of approximation; if  the point found as a result of calculating  the support function lies inside the current approximation at the distance more than inApproxDist, then the process is interrupted with a message "the vertex is inside the multiplicity" ; by default inApproxDist = 1e-4  
%       ApproxDist: double[1,1] - is used in the process of approximation; if  the point found as a result of calculating  the support function lies at the distance less than ApproxDist from the internal approximation then it is not expectant to be attached and so it isn't kept on memory;by default ApproxDist  = 1e-5
%       precTest: double[1,1] - is used only when errorCheckMode = 1;  if the vertex of the convex hull should be on the face ( according to the polytope's structure), but actually lies at the distanse more than precTest from the face because of  erros, emerged by rounding during the calculations, then the process is interrupted with message "the precision s not sufficient"; by default precTest = 1e-4
%       relPrec: double[1,1] - is used in the process of calculating  the dot product; if when finding the sum of two values, the result isn't more than the result of multiplying of one of the values and relPrec, then the sum is defined as 0;by default relPrec = 1e-5
%       inftyDef: double[1,1] - is used as infinity; by default IinftyDef = 1e6
%       isVerbose:double[1,1] - determins if the mode of printing the process information is on (1) or off (0 - be default)
%               NOTE: EPSdif must be less than faceDist and precTest!
% 
%  Output:
%       convexMat: double [nResInequalities,nDims] 
%       convexVec:double [nResInequalities,1] 
%       the result is defined  as a multiplicity of x such that:
%                                                convexMat*x +  convexVec <= 0                                               
%         
%       discrepVec: double [1,nResInequalities] - vector of approximation
%          error for  each vertex of result polytope
%       vertMat: double [nVertices, nDims] - vertices of result polytope