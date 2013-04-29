function [isThere indTheres]=isMemberAlongDimInternal(self,other,dimNum,varargin)
% ISMEMBERALONGDIM - performs ismember operation of CubeStruct data slices
%                    along the specified dimension
%
% Usage: isThere=isMemberAlongDimInternal(self,otherRel,keyFieldNameList,...) 
%    or [isThere indTheres]=isMemberDim(self,otherRel,keyFieldNameList,...)
%
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%     other: ARelation [1,1] - other class object
%     dim: double[1,1] - dimension number for ismember operation
%
%   properties:
%     keyFieldNameList/fieldNameList: char or char cell [1,nKeyFields] - list 
%         of fields to which ismember is applied; by default all fields of 
%         first (self) object are used
%
%
% Output:
%   regular:
%     isThere: logical [nSlices,1] - determines for each data slice of the
%         first (self) object whether combination of values for key fields 
%         is in the second (other) object or not
%     indTheres: double [nSlices,1] - zero if the corresponding coordinate
%         of isThere is false, otherwise the highest index of the
%         corresponding data slice in the second (other) object
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-23 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
[reg,prop]=modgen.common.parseparams(varargin);
isKeyFieldNameListSpec=false;
if ~isempty(reg)
    error([upper(mfilename),':wrongInput'],...
        'no regular input arguments is expected');
end
%
for k=1:2:numel(prop)-1
    switch lower(prop{k})
        case {'keyfieldnamelist','fieldnamelist'},
            isKeyFieldNameListSpec=true;
            keyFieldNameList=prop{k+1};
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'unsupported property: %s',prop{k});
    end
end
%
if ~isa(other,'smartdb.cubes.CubeStruct'),
   error([upper(mfilename),':wrongInput'],...
       'second argument must be object of smartdb.cubes.CubeStruct class');
end
%
self.checkIfObjectScalar();
other.checkIfObjectScalar();
modgen.common.type.simple.checkgen(dimNum,'isnumeric(x)&&numel(x)==1');
dimNum=double(dimNum);
modgen.common.type.simple.checkgen(dimNum,['isreal(x)&&floor(x)==x&&x>=1&&x<=',...
    num2str(min(self.getMinDimensionality(),other.getMinDimensionality()))]);
%
if ~isKeyFieldNameListSpec
    keyFieldNameList=self.getFieldNameList();
else
    if ischar(keyFieldNameList),
        keyFieldNameList={keyFieldNameList};
    else
        keyFieldNameList=reshape(keyFieldNameList,1,[]);
    end
    if ~iscellstr(keyFieldNameList),
        error([upper(mfilename),':wrongInput'],...
            'keyFieldNameList must be char or char cell array');
    end
    if ~self.isFields(keyFieldNameList),
        error([upper(mfilename),':wrongInput'],...
            ['all fields from keyFieldNameList must be ',...
            'contained in given object']);
    end
end
if ~other.isFields(keyFieldNameList),
    error([upper(mfilename),':wrongInput'],...
        ['all fields from keyFieldNameList must be contained ',...
        'in the second relation']);
end
if isempty(keyFieldNameList)
    throwerror('wrongInput','keyFieldNameList cannot be empty');
end
%
[SData,SIsNull,SIsValueNull]=self.getDataInternal('fieldNameList',keyFieldNameList,'replaceNull',true);
leftCell=[struct2cell(SData);struct2cell(SIsNull)];
leftIsNullCell=struct2cell(SIsValueNull);
leftIsNullCell=[leftIsNullCell;leftIsNullCell];
%
[SData,SIsNull,SIsValueNull]=other.getDataInternal('fieldNameList',keyFieldNameList,'replaceNull',true);
rightCell=[struct2cell(SData);struct2cell(SIsNull)];
rightIsNullCell=struct2cell(SIsValueNull);
rightIsNullCell=[rightIsNullCell;rightIsNullCell];
%
leftLenVec=cellfun('size',leftCell,dimNum);
rightLenVec=cellfun('size',rightCell,dimNum);
if ~all(leftLenVec(2:end)==leftLenVec(1)),
    error([upper(mfilename),':wrongInput'],...
        'first argument must have the same size along dimension %d for all fields',dimNum);
end
if ~all(rightLenVec(2:end)==rightLenVec(1)),
    error([upper(mfilename),':wrongInput'],...
        'second argument must have the same size along dimension %d for all fields',dimNum);
end
leftLenVec=leftLenVec(1);
rightLenVec=rightLenVec(1);
if leftLenVec==0,
    if dimNum>1,
        isThere=false(1,0);
        indTheres=nan(1,0);
    else
        isThere=false(0,1);
        indTheres=nan(0,1);
    end
elseif rightLenVec==0,
    if dimNum>1,
        isThere=false(1,leftLenVec);
        indTheres=zeros(1,leftLenVec);
    else
        isThere=false(leftLenVec,1);
        indTheres=zeros(leftLenVec,1);
    end
else
    if nargout>1,
        [isThere,indTheres]=modgen.common.ismemberjointwithnulls(...
            leftCell,leftIsNullCell,...
            rightCell,rightIsNullCell,dimNum);
    else
        isThere=modgen.common.ismemberjointwithnulls(...
            leftCell,leftIsNullCell,...
            rightCell,rightIsNullCell,dimNum);
    end
end