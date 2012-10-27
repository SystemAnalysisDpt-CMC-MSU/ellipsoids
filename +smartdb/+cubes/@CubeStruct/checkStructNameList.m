function checkStructNameList(self,structNameList,isCorrectnessChecked)
% CHECKSTRUCTNAMELIST checks that the field name list is consistent with
% the list of the field names for the object in question
%
% Input: 
%   regular:
%       self: CubeStruct[1,1] 
%       structNameList: cell[1,nItems] of char[1,] - list of field names
%   optional:
%       isCorrectnessChecked [1,1] - if true, the function checks if the
%          input contains a a list of strings 
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2012-10-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if nargin<3
    isCorrectnessChecked=false;
end
%    
if isempty(structNameList)
    return;
end
%
if isCorrectnessChecked
    if ~(modgen.common.isvec(structNameList)&&iscellstr(structNameList))
        error([upper(mfilename),':wrongInput'],...
            'structNameList is expected to be a cell vector of strings');
    end
end
%
[isThere,indLoc]=ismember(structNameList,self.completeStructNameList);
if ~all(isThere)
    structNameList=structNameList(find(~isThere,1,'first'));
    error([upper(mfilename),':wrongInput'],...
        'unknown structure name %s',...
        structNameList{1});
end
%
if ~isequal(length(indLoc),length(unique(indLoc)))
    error([upper(mfilename),':wrongInput'],...
        'structNameList is expected to contain only unique values');
end