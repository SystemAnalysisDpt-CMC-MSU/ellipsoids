function varargout=getData(self,varargin)
% GETDATA - returns an indexed projection of CubeStruct object's content
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - the object
%
%   optional:
%
%       subIndCVec: 
%         Case#1: numeric[1,]/numeric[,1] 
%   
%         Case#2: cell[1,nDims]/cell[nDims,1] of double [nSubElem_i,1] 
%               for i=1,...,nDims 
%       
%           -array of indices of field value slices that are selected
%           to be returned; if not given (default), 
%           no indexation is performed
%       
%         Note!: numeric components of subIndVec are allowed to contain
%            zeros which are be treated as they were references to null
%            data slices
%
%       dimVec: numeric[1,nDims]/numeric[nDims,1] - vector of dimension 
%           numbers corresponding to subIndCVec
%
%   properties:
%
%       fieldNameList: char[1,]/cell[1,nFields] of char[1,]  
%           list of field names to return
%
%       structNameList: char[1,]/cell[1,nStructs] of char[1,] 
%           list of internal structures to return (by default it
%           is {SData, SIsNull, SIsValueNull}
%
%       replaceNull: logical[1,1] if true, null values are replaced with 
%           certain default values uniformly across all the cells, 
%               default value is false
%
%       nullReplacements: cell[1,nReplacedFields]  - list of null
%           replacements for each of the fields
%
%       nullReplacementFields: cell[1,nReplacedFields] - list of fields in
%          which the nulls are to be replaced with the specified values,
%          if not specified it is assumed that all fields are to be 
%          replaced
%
%          NOTE!: all fields not listed in this parameter are replaced with 
%          the default values
%
%       checkInputs: logical[1,1] - true by default (input arguments are
%          checked for correctness
%
% Output:
%   regular:
%     SData: struct [1,1] - structure containing values of
%         fields at the selected slices, each field is an array
%         containing values of the corresponding type
%
%     SIsNull: struct [1,1] - structure containing a nested
%         array with is-null indicators for each CubeStruct cell content
%
%     SIsValueNull: struct [1,1] - structure containing a
%        logical array [] for each of the fields (true
%        means that a corresponding cell doesn't not contain
%           any value
if nargout>0
    varargout=cell(1,nargout);
    [varargout{:}]=self.getDataInternal(varargin{:});
else
    self.getDataInternal(varargin{:});
end