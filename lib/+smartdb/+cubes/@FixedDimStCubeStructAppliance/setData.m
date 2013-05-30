function setData(self,varargin)
% SETDATA - sets values of all cells for all fields
%
% Input:
%   regular:
%     self: CubeStruct[1,1]
%
%   optional:
%     SData: struct [1,1] - structure with values of all cells for
%         all fields
%
%     SIsNull: struct [1,1] - structure of fields with is-null
%        information for the field content, it can be logical for
%        plain real numbers of cell of logicals for cell strs or
%        cell of cell of str for more complex types
%
%     SIsValueNull: struct [1,1] - structure with logicals
%         determining whether value corresponding to each field
%         and field cell is null or not
%
%   properties:
%       fieldNameList: cell[1,] of char[1,] - list of fields for which data
%           should be generated, if not specified, all fields from the
%           relation are taken
%
%       isConsistencyCheckedVec: logical [1,1]/[1,2]/[1,3] - 
%           the first element defines if a consistency between the value
%               elements (data, isNull and isValueNull) is checked;
%           the second element (if specified) defines if
%               value's type is checked. 
%           the third element defines if consistency between of sizes
%               between different fields is checked
%             If isConsistencyCheckedVec
%               if scalar, it is automatically replicated to form a
%                   3-element vector
%               if the third element is not specified it is assumed 
%                   to be true
%
%       transactionSafe: logical[1,1], if true, the operation is performed
%          in a transaction-safe manner
%
%       checkStruct: logical[1,nStruct] - an array of indicators which when
%          all true force checking of structure content (including presence  
%          of required fields). The first element correspod to SData, the
%          second and the third (if specified) to SIsNull and SIsValueNull
%          correspondingly
%
%       structNameList: char[1,]/cell[1,], name of data structure/list of
%         data structure names to which the function is to
%              be applied, can be composed from the following values
%
%            SData - data itself
%
%            SIsNull - contains is-null indicator information for data 
%                 values
%
%            SIsValueNull - contains is-null indicators for CubeStruct cells
%                (not for cell values)
%         structNameList={'SData'} by default
%
%       fieldMetaData: smartdb.cubes.CubeStructFieldInfo[1,] - field meta
%          data array which is used for data validity checking and for
%          replacing the existing meta-data
%
%       mdFieldNameList: cell[1,] of char - list of names of fields for
%          which meta data is specified
%
%       dataChangeIsComplete: logical[1,1] - indicates whether a change
%           performed by the function is complete
%
% Note: call of setData with an empty list of arguments clears
%    the data
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