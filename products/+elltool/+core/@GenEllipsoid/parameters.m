function [ellDiagMat,ellCenterVec,ellEigvMat]=parameters(ell)
%
% PARAMETERS - returns parameters of the GenEllipsoid.
%
% Input:
%	regular:
%		Ell: GenEllipsoid [1,1] - single GenEllipsoid of dimention nDims.
%
% Output:
%	ellCenterVec: double[nDims,1] - center of the GenEllipsoid ell.
%	ellDiagMat: double[nDims,nDims] - diagonal matrix
%		of the eigenvalues ell.
%	ellEigvMat: double[nDims,nDims] - eig matrix 
% 
% Example:
%	ellObj=elltool.core.GenEllipsoid([-2; 4],[4 -1; -1 5]);
%	[centVec,diagMat,eigvMat]=parameters(ellObj)
% 	centVec =
%
%		-2
%		4
%
%	diagMat =
%
%		3.3820	0
%		0    	5.6180
%
%
%	eigvMat =
%
%	-0.8507	-0.5257
%	-0.5257	0.8507
% 
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
if nargout < 2
    ellDiagMat=ell.getDiagMat();
elseif nargout < 3
    ellCenterVec=ell.getCenter();
    ellDiagMat=ell.getDiagMat();
else
    ellCenterVec=ell.getCenter();
    ellDiagMat=ell.getDiagMat();
    ellEigvMat=ell.getEigvMat();
end
