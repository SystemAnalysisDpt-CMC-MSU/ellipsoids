function resCMat=toCellIsNull(self,varargin)
% TOCELLISNULL - transforms is-null indicators of all fields for all tuples 
%                into two dimensional cell array
%
% Usage: resCMat=toCell(self,varargin)
%
% input:
%   regular:
%     self: ARelation [1,1] - class object
%   optional:
%     fieldName1: char - name of first field
%     ...
%     fieldNameN: char - name of N-th field
% output:
%   resCMat: cell [nTuples,nFields(N)] - cell with values of all fields (or
%       fields selected by optional arguments) for all tuples
%
% FIXME - order fields in setData method
%
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
resCMat=self.toMat('checkInputs',false,...
    'structNameList','SIsNull','fieldNameList',varargin);
%