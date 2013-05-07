function applySetFunc(self,varargin)
% APPLYSETFUNC - applies some function to each cell of the specified fields
%                of a given CubeStruct object
%
% Usage: applySetFunc(self,toFieldNameList,hFunc)
%        applySetFunc(self,hFunc,toFieldNameList)
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - class object
%
%       hFunc: function handle [1,1] - handle of function to be
%         applied to fields, the function is assumed to
%           1) have the same number of input/output arguments
%           2) the number of input arguments should be
%              length(structNameList)*length(fieldNameList)
%           3) the input arguments should be ordered according to the
%           following rule
%               (x_struct_1_field_1,x_struct_1_field_2,...,struct_n_field1,
%               ...,struct_n_field_m)
%
%   optional:
%   
%       toFieldNameList: char or char cell [1,nFields] - list of
%         field names to which given function should be applied
%
%         Note1: field lists of length>1 are not currently supported !
%         Note2: it is possible to specify toFieldNameList before hFunc in
%            which case the parameters will be recognized automatically
%
%   properties:
%       uniformOutput: logical[1,1] - specifies if the result
%          of the function is uniform to be stored in non-cell
%          field, by default it is false for cell fileds and
%          true for non-cell fields
%
%       structNameList: char[1,]/cell[1,], name of data structure/list of 
%         data structure names to which the function is to
%              be applied, can be composed from the following values
%
%            SData - data itself
%
%            SIsNull - contains is-null indicator information for data 
%              values
%
%            SIsValueNull - contains is-null indicators for CubeStruct 
%               cells (not for cell values)
%
%         structNameList={'SData'} by default
%   
%       inferIsNull: logical[1,2] - if the first(second) element is true,  
%           SIsNull(SIsValueNull) indicators are inferred from SData, 
%           i.e. with this indicator set to true it is sufficient to apply 
%           the function only to SData while the rest of the structures 
%           will be adjusted automatically.
%
%       inputType: char[1,] - specifies a way in which the field value is
%          partitioned into individual cells before being passed as an
%          input parameter to hFunc. This parameter directly corresponds to
%          outputType parameter of toArray method, see its documentation
%          for a list of supported input types.
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if nargin>1
    if isa(varargin{2},'function_handle')
        hFunc=varargin{2};
        varargin(2)=varargin(1);
        varargin{1}=hFunc;
    end
end
self.applySetFuncInternal(varargin{:});