function varargout=toMat(self,varargin)
% TOMAT - transforms values of all fields for all tuples into two 
%         dimensional array
%
% Usage: resCMat=toMat(self,varargin)
%
% input:
%   regular:
%     self: ARelation [1,1] - class object
%
%   optional:
%     fieldNameList: cell[1,] - list of filed names to return
%
%     uniformOutput: logical[1,1], true - cell is returned, false - the
%        functions tries to return a result as a matrix
%
%     groupByColumns: logical[1,1], if true, each column is returned in a
%        separate cell
%
%     structNameList/dataStructure: char[1,], data structure for which the 
%        data is to be taken from, can have one of the following values
%
%       SData - data itself
%       SIsNull - contains is-null indicator information for data values
%       SIsValueNull - contains is-null indicators for relation cells (not
%          for cell values
%
%     replaceNull: logical[1,1], if true, null values from SData are
%        replaced by null replacement, = true by default
%
%     nullTopReplacement: - can be of any type and currently only applicable
%       when  UniformOutput=false and of
%       the corresponding column type if UniformOutput=true.
%
%       Note!: this parameter is disregarded for any dataStructure different
%          from 'SData'. 
%       
%       Note!: the main difference between this parameter and the following
%          parameters is that nullTopReplacement can violate field type
%          constraints thus allowing to replace doubles with strings for
%          instance (for non-uniform output types only of course)
%
%
%     nullReplacements: cell[1,nReplacedFields]  - list of null
%        replacements for each of the fields
%
%     nullReplacementFields: cell[1,nReplacedFields] - list of fields in
%        which the nulls are to be replaced with the specified values,
%        if not specified it is assumed that all fields are to be replaced
%
%        NOTE!: all fields not listed in this parameter are replaced with 
%        the default values
%
% output:
%   resCMat:  [nTuples,nFields(N)] - matrix/cell with values of all fields 
%       (or fields selected by optional arguments) for all tuples
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[reg,prop]=modgen.common.parseparams(varargin);
for k=1:2:length(prop)-1
    if strcmpi(prop{k},'uniformOutput')
        prop{k}='outputType';
        if prop{k+1}
            prop{k+1}='uniformMat';
        else
            prop{k+1}='uniformCell';
        end
    end
end
if nargout>0
    varargout=cell(1,nargout);
    [varargout{:}]=self.toArray(reg{:},prop{:});
else
    self.toArray(reg{:},prop{:});
end