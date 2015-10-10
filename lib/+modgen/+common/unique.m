function varargout=unique(inpVec)
% UNIQUE for arrays of any type
%
% Usage: [outUnqVec,indRightToLeftVec,indLeftToRightVec]=...
%   modgen.common.unique(inpVec);
%
% Input:
%   regular:
%     inpVec: cell[nObjects,1]/[1,nObjects] of objects
%
% Output:
%   outUnqVec: cell[nUniqObjects,1]/[1,nUniqObjects]
%   indRightToLeftVec: double[nUniqObjects,1] : all
%       fCompare(inpVec(indRightToLeftVec)==outUnqVec)==true
%   indLeftToRightVec: double[nObjects,1] : all
%       all(fCompare(outUnqVec(indLeftToRightVec)==inpVec))
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-Oct-09 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
import modgen.common.uniquejoint;
import modgen.common.uniquebyfunc;
if nargout==0
    uniquejoint({inpVec});
else
    varargout=cell(1,nargout);
    [varargout{:}]=uniquejoint({inpVec});
    varargout{1}=varargout{1}{1};
end