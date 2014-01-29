function resRelObj = union(varargin)
% UNION produces a relation which cosists of a union of tuples from all the
% relations passed as the input arguments
%
% Input:
%   regular:
%     relInp1: smartdb.relations.ARelation [1,1] - relation object
%   optional
%     relInp2: smartdb.relations.ARelation [1,1] - relation object
%     ....  
%     relInpn: smartdb.relations.ARelation [1,1] - relation object
%     ...
%   
% Output:
%     relOut: smartdb.relations.DynamicRelation [1,1] represents a union of 
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-11 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
%
if nargin<1
    error([upper(mfilename),':wrongInput'],...
        'at least one argument expected');
end
%
if ~all(cellfun(@(x)isa(x,'smartdb.relations.ARelation'),varargin))
    error([upper(mfilename),':wrongInput'],...
        'all inputs are expected to be of type smartdb.relations.ARelation');
end
%
resRelObj=varargin{1}.getCopy();
if nargin>1
    resRelObj.unionWith(varargin{2:end});
end