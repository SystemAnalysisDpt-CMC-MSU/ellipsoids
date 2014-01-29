function [ isOk, pPar] = getIsGoodDirForMat( ellQ1Mat, ellQ2Mat,dirVec,...
    absTol )
% GETISGOODDIRFORMAT - check whether specified direction is appropriate for
%                      computing tight extrenal approximation of the 
%                      difference of two generalized ellipsoids
%
% Input:
%   regular:
%       ellQ1Mat: double: [kSize,kSize] - positove matrix of
%            first ellipsoid
%       ellQ2Mat: double: [kSize,kSize] - semi-positive matrix of
%             second ellipsoid
%       dirVec: double: [kSize,1] - vector of direction
%       absTol: double: [1,1] - absolute tolerance
% Output:
%   isOk: logical: [1,1] - true if direction is good, i.e. if for this
%       direction p=p2/p1>lamMax and p<1, where lamMax is the maximal root
%       of equation det(Q2-pQ1)=0.
%   pPar: double: [1,1] - parameter for internal approximation
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import gras.gen.sqrtpos;
ellInvQ1Mat=ellQ1Mat\eye(size(ellQ1Mat));
[~,diagMat]=eig(ellQ2Mat*ellInvQ1Mat);
lamMax=max(diag(diagMat));
p1Par=sqrtpos(dirVec.'*ellQ1Mat*dirVec,absTol);
p2Par=sqrtpos(dirVec.'*ellQ2Mat*dirVec,absTol);
pPar=p2Par/p1Par;
isOk=(pPar>lamMax && pPar<1);
pPar=max(pPar,lamMax);
