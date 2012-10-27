function varargout=uniqueobj(objCell,funHandle)
% UNIQUEOBJ unique for cellarrays of objects of any kind
%
%Usage: [uniqObjCell,indUniq,indInUniq]=uniqueobj(objCell,funHandle);
%
% input:
%   regular:
%     objCell: cell[nObjects,1] of objects
%   optional:
%     funHandle: function_handle [1,1] - compare function, default
%         isequalwithequalnans, the format of funHandle:
%         @(objectLeft,objectRight)compare(objectLeft,objectRight)
% output:
%   regular:
%     uniqObjCell: cell[nUniqObjects,1]
%     indUniq: double[nUniqObjects] : all
%         funHandle(objCell(indUniq)==uniqObjCell)==true
%     indInUniq: double[nObjects,1] : all
%         all(funHandle(uniqObjCell(indInUniq)==objCell))
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
varargout=cell(1,nargout);
if nargout>0,
    if nargin>=2,
        [varargout{:}]=uniqueobjinternal(objCell,funHandle);
    else
        [varargout{:}]=uniquejoint({objCell(:)},1);
        varargout{1}=varargout{1}{:};
    end
end