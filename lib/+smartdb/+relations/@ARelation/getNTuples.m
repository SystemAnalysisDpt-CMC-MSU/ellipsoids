function nTuples=getNTuples(self)
% GETNTUPLES - returns number of tuples in given relation
%
% Usage: nTuples=getNTuples(self)
%
% input:
%   regular:
%     self: ARelation [1,1] - class object
% output:
%   regular:
%     nTuples: double [1,1] - number of tuples in given  relation
%        
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
nTuples=self.getNElems();