function [obj,isThereVec]=getTuplesFilteredBy(self,filterFieldName,filterValueVec,...
    varargin)
% GETTUPLESFILTEREDBY - selects tuples from given relation such that a
%                       fixed index field contains values from a given set
%                       of value and returns the result as new relation
%
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%     filterFieldName: char - name of index field
%     filterValueVec: numeric/ cell of char [nValues,1] - vector of index
%         values
%
%   properties:
%     keepNulls: logical[1,1] - if true, null values are not filteed out,
%        and removed otherwise,
%           default: false
%
% Output:
%   regular:
%     obj: ARelation [1,1] - new class object containing only selected
%         tuples
%     isThereVec: logical[nTuples,1] - contains true for the kept tuples
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-09-21 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   a minor bug fix related to error message format
%
%
import modgen.common.throwerror;
[~,prop]=modgen.common.parseparams(varargin,{'keepNulls'},0);
if ~isempty(prop)
    isNullsKept=prop{2};
else
    isNullsKept=false;
end
%
self.isFieldsCheck(filterFieldName)
%
if ~modgen.common.isvec(filterValueVec)
    throwerror('wrongInput',...
        'filterValueVec is expected to be a vector');
end
if ~(isnumeric(filterValueVec)||iscellstr(filterValueVec)||ischar(filterValueVec))
    throwerror('wrongInput',...
        'filterValueVec is expected to be a numeric or cellOfChar vector');
end
%
if self.getNTuples()>0
    fieldValueVec=self.(filterFieldName);
    if ~(isnumeric(filterValueVec)&&isnumeric(fieldValueVec)||...
            iscellstr(fieldValueVec)&&...
            (iscellstr(filterValueVec)||ischar(filterValueVec)))
        throwerror('wrongInput',...
            'field type is inconsistent with type of filterValueVec');
    end
    isNullVec=self.getFieldIsValueNull(filterFieldName);
    isThereVec=ismember(fieldValueVec,filterValueVec)&~isNullVec;
    %
    if isNullsKept
        isThereVec=isThereVec|isNullVec;
    end
    %
    obj=self.getTuples(isThereVec);
else
    obj=self.getCopy();
    isThereVec=true(0,1);
end