function setData(self,varargin)
% SETDATA - sets values of all cells for all fields
%           see SETDATAINTERNAL for more details
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.prohibitProperty('fieldMetaData',varargin);

if ~any(strcmpi('transactionSafe',varargin))
    inpArgList={'transactionSafe',true};
else
    inpArgList={};
end
%
self.setDataInternal(varargin{:},inpArgList{:});