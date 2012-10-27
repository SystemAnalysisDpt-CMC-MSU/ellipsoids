function nFields=getNFieldsInternal(self,varargin)
% GETNFIELDS returns number of fields in given object
%
% Usage: nFields=getNFields(self)
%
% Input:
%   regular:
%       self: CubeStruct [1,1]
%   properties:
%       SData: struct[1,1] - structure used a source, if not specified,
%          self.SData is used
%     
% Output:
%   regular:
%     nFields: double [1,1] - number of fields in given object
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if ~isempty(varargin)
    if numel(varargin)==2&&ischar(varargin{1})&&isstruct(varargin{2})
        nFields=length(fieldnames(varargin{2}));
    else
        error([upper(mfilename),':wrongInput'],...
            'incorrect property name-value list');
    end
else
    nFields=numel(self.fieldMetaData);
end