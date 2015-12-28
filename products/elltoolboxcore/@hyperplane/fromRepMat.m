function ellArr=fromRepMat(varargin)
% FROMREPMAT - returns array of equal hyperplanes the same
%			  size as stated in sizeVec argument
%
%	hpArr = fromRepMat(sizeVec) - creates an array  size
%			sizeVec of empty hyperplanes.
%
%	hpArr = fromRepMat(normalVec,sizeVec) - creates an array
%			size sizeVec of hyperplanes with normal
%			normalVec.
%
%	hpArr = fromRepMat(normalVec,shift,sizeVec) - creates an
%			array size sizeVec of hyperplanes with normal normalVec
%			and hyperplane shift shift.
%
% Input:
%	Case1:
%		regular:
%			sizeVec: double[1,n] - vector of size, have
%				integer values.
%
%	Case2:
%		regular:
%			normalVec: double[nDim, 1] - normal of
%				hyperplanes.
%			sizeVec: double[1, n] - vector of size, have
%				integer values.
%
%	Case3:
%		regular:
%			normalVec: double[nDim, 1] - normal of
%				hyperplanes.
%			shift: double[1, 1] - shift of hyperplane.
%			sizeVec: double[1,n] - vector of size, have
%				integer values.
%
%	properties:
%		absTol: double [1,1] - absolute tolerance with default
%			value 10^(-7)
%
% $Author: Alexander Karev <Alexander.Karev.30@gmail.com>
% $Copyright: Moscow State University,
%			 Faculty of Computational Mathematics
%			 and Computer Science,
%			 System Analysis Department 2013 $
%
import modgen.common.checkvar;
%
if nargin>3
    indVec=[1:2,4:nargin];
    sizeVec=varargin{3};
else
    sizeVec=varargin{nargin};
    indVec=1:nargin-1;
end
%
ellArr=repMat(hyperplane(varargin{indVec}),sizeVec);