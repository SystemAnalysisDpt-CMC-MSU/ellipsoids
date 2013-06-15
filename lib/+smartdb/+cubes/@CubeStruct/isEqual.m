function [isEq,reportStr]=isEqual(self,otherObj,varargin)
% ISEQUAL compares the specified CubeStruct object with other CubeStruct
% object and returns true if they are equal, otherwise it
% returns false
%
% Usage: isEq=isEqual(self,otherObj)
%
% Input:
%   regular:
%     self: CubeStruct [1,1]
%     otherObj: CubeStruct [1,1] - the other object
%
%   properties:
%     checkFieldOrder/isFieldOrderCheck: logical [1,1] -
%         if true, then fields in compared objects must
%         be in the same order, otherwise the order is not
%         important (false by default)
%
%     sortDim: numeric[1,1] - dimension along which the CubeStruct slices
%        order is considered irrelevant with regard to equality
%
%     compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
%         referenced from the meta data objects are also compared
%
%     compareMetaDataParamList: cell[1,nParam] - list of additional
%        parameters passed to isEqual method of CubeStruct from isEqual method
%        of CubeStructFieldInfo. This list is used particularly to
%        elimitate an infinite loop when comparing the reverse
%        references from CubeStructFieldInfo to CubeStruct
%
%     maxTolerance: double [1,1] - maximum allowed tolerance
%
%     maxRelativeTolerance: double [1,1] - maximum allowed relative
%        tolerance
%
%     leftIndCVec: cell[1,nLeftIndDims] - list of indices to be applied to
%       the dimensions of left-hand side CubeStruct object
%
%     leftDimVec: numeric[1,nLeftIndDims] - vector of index dimensions for
%        which leftIndCVec is specified
%
%     rightIndCVec: cell[1,nRightIndDims] - same as leftIndCVec but for the
%        right-hand side CubeStruct object
%
%     rightDimVec: numeric[1,nRightIndDims] - same as leftDimVec but for
%     the right-hand side CubeStruct object
%
%       Note: sortDim property cannot be specified along with
%           any of leftIndCVec, leftDimVec, rightIndCVec, rightDimVec
%           properties
%
%     compareFuncHandle: function_handle[1,1] - function handle used to
%        compare data structures
%
% Output:
%   isEq: logical[1,1] - result of comparison
%   reportStr: char[1,] - contains an additional information about the
%      differences (if any)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-09-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.common.type.simple.checkgen;
import modgen.common.throwerror;
reportStr='';
if nargin<2,
    error([upper(mfilename),':wrongInput'],...
        'both object to be compared must be given');
end
if numel(self)~=1||numel(otherObj)~=1,
    error([upper(mfilename),':wrongInput'],...
        'both object to be compared must be scalar');
end
isEq=strcmp(class(otherObj),class(self));
if ~isEq,
    reportStr='Objects are of different classes';
    return;
end
[~,prop]=modgen.common.parseparams(varargin,[],0);
nProp=length(prop);
maxTolerance=0;
isRelComparison=false;
maxRelTolerance=0;
isFieldOrderCheck=false;
isSortedBeforeCompare=false;
isCompareCubeStructBackwardRef=true;
compareCubeStructParamList={};
%
isLeftIndCVecSpec=false;
isRightIndCVecSpec=false;
isLeftDimVecSpec=false;
isRightDimVecSpec=false;
%
isCompFuncHandleSpec=false;
%
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'comparefunchandle',
            isCompFuncHandleSpec=true;
            compFuncHandle=prop{k+1};
            %
        case {'isfieldordercheck','checkfieldorder'},
            isFieldOrderCheck=prop{k+1};
        case 'sortdim',
            isSortedBeforeCompare=true;
            sortDim=prop{k+1};
        case 'comparemetadatabackwardref',
            isCompareCubeStructBackwardRef=prop{k+1};
        case 'maxtolerance',
            maxTolerance=prop{k+1};
            checkgen(maxTolerance,'isscalar(x)&&isnumeric(x)&&x>=0');
        case 'maxrelativetolerance'
            isRelComparison=true;
            maxRelTolerance=prop{k+1};
            checkgen(maxRelTolerance,'isscalar(x)&&isnumeric(x)&&x>=0');
        case 'leftindcvec',
            leftIndCVec=prop{k+1};
            isLeftIndCVecSpec=true;
        case 'rightindcvec',
            rightIndCVec=prop{k+1};
            isRightIndCVecSpec=true;
        case 'leftdimvec',
            leftDimVec=prop{k+1};
            isLeftDimVecSpec=true;
        case 'rightdimvec',
            rightDimVec=prop{k+1};
            isRightDimVecSpec=true;
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'unidentified property name: %s ',prop{k});
    end
end
if ~isCompFuncHandleSpec
    compFuncHandle=@modgen.struct.structcompare;
end
%
if isRightDimVecSpec&&~isRightIndCVecSpec
    error([upper(mfilename),':wrongInput'],...
        'rightDimVec cannot be used in isolation from rightIndCVec');
end
%
if isLeftDimVecSpec&&~isLeftIndCVecSpec
    error([upper(mfilename),':wrongInput'],...
        'leftDimVec cannot be used in isolation from leftIndCVec');
end
%
if (isLeftIndCVecSpec||isRightIndCVecSpec)&&isSortedBeforeCompare
    error([upper(mfilename),':wrongInput'],...
        ['sortDim cannot be used in conjuction with ',...
        'leftIndCVec or rightIndCVec']);
end
%
if isCompareCubeStructBackwardRef
    compareCubeStructParamList={'comparemetadatabackwardref',false};
end
%
selfMetaClass=metaclass(self);
isEq=selfMetaClass==metaclass(otherObj);
if ~isEq,
    reportStr='Objects are of different types';
    return;
end
selfFieldNameList=self.getFieldNameList();
isFieldOrderEq=isequal(selfFieldNameList,otherObj.getFieldNameList());
%
isEq=(~isFieldOrderCheck||isFieldOrderEq);
%
if ~isEq,
    reportStr='Field names are different';
    return;
end
isEq=isequal(self.getMinDimensionSizeInternal(),...
    otherObj.getMinDimensionSizeInternal());
if ~isEq,
    reportStr='Cube dimensionalities are different';
    return;
end
%
inpIsMemberOtherArgList={};
if ~isFieldOrderEq
    [isThereVec,indLoc]=ismember(selfFieldNameList,otherObj.getFieldNameList());
    isEq=all(isThereVec);
    if ~isEq
        reportStr='Field names are different';
        return;
    end
    otherFieldMetaData=otherObj.getFieldMetaData();
    otherFieldMetaData=otherFieldMetaData(indLoc);
    if ~issorted(indLoc)
        inpIsMemberOtherArgList={'fieldNameList',selfFieldNameList};
    end
else
    otherFieldMetaData=otherObj.getFieldMetaData();
end
isEq=self.getFieldMetaData.isEqual(otherFieldMetaData,...
    isCompareCubeStructBackwardRef,compareCubeStructParamList);
if ~isEq
    reportStr='Field meta data is different';
    return;
end
nFields=length(selfFieldNameList);
for iField=1:nFields,
    p1=findprop(self,selfFieldNameList{iField});
    p2=findprop(otherObj,selfFieldNameList{iField});
    isEq=isequal(isempty(p1),isempty(p2));
    if ~isEq,
        reportStr=['CubeStruct fields are not defined as properties ',...
            'in the same way'];
        return;
    end
end
structNameList={'SData','SIsNull','SIsValueNull'};
nStructs=length(structNameList);
%
resSelfCVec=cell(1,nStructs);
resOtherCVec=cell(1,nStructs);
%
if isSortedBeforeCompare
    % try sorting first (just because it is faster)
    %
    res=warning('off','GETSORTINDEX:wrongSortType');
    inpSelfArgList={self.getSortIndexInternal(self.fieldNameList,sortDim)};
    inpOtherArgList={otherObj.getSortIndexInternal(self.fieldNameList,sortDim)};
    [resSelfCVec{:}]=self.getDataInternal(inpSelfArgList{:},...
        'replaceNull',true,'structNameList',structNameList);
    [resOtherCVec{:}]=otherObj.getDataInternal(inpOtherArgList{:},...
        'replaceNull',true,'structNameList',structNameList);
    %get sorted data for otherObj
    warning(res.state,res.identifier);
    %compare the sorted data
    %
    compareData();
    %if sorting doesn't help try is member
    %
    if ~isEq
        [resSelfCVec{:},~,indSelfBackwardVec]=...
            self.getUniqueDataAlongDimInternal(sortDim,'replaceNull',true);
        [resOtherCVec{:},~,indOtherBackwardVec]=...
            otherObj.getUniqueDataAlongDimInternal(sortDim,'replaceNull',true,...
            inpIsMemberOtherArgList{:});
        %
        resSelfCVec=cellfun(@struct2cell,resSelfCVec,'UniformOutput',false);
        resOtherCVec=cellfun(@struct2cell,resOtherCVec,'UniformOutput',false);
        resSelfCVec=[resSelfCVec{:}];
        resOtherCVec=[resOtherCVec{:}];
        if isequal(cellfun(@size,resSelfCVec,'UniformOutput',false),...
                cellfun(@size,resOtherCVec,'UniformOutput',false)),
            [isThere,indThere]=ismemberjoint(resSelfCVec,resOtherCVec,sortDim);
            %
            numUniqueOtherVec=accumarray(indOtherBackwardVec,ones(size(indOtherBackwardVec)));
            numUniqueSelfVec=accumarray(indSelfBackwardVec,ones(size(indSelfBackwardVec)));
            %
            isEq=all(isThere)&&numel(unique(indThere))==numel(indThere);
            isEq=isEq&&isequal(numUniqueSelfVec(indThere),...
                numUniqueOtherVec);
            %
            if ~isEq
                if maxTolerance>0
                    throwerror('wrongInput',...
                        ['Cannot provide a determenistic answer as there is ',...
                        'an attempt to use ismemberjoin with absolute precision ',...
                        'when maxTolerance>0']);
                end
            else
                reportStr='';
            end
        end
    end
else
    if isLeftIndCVecSpec
        if isLeftDimVecSpec
            leftInpArgList={leftIndCVec,leftDimVec};
        else
            leftInpArgList={leftIndCVec};
        end
    else
        leftInpArgList={};
    end
    %
    if isRightIndCVecSpec
        if isRightDimVecSpec
            rightInpArgList={rightIndCVec,rightDimVec};
        else
            rightInpArgList={rightIndCVec};
        end
    else
        rightInpArgList={};
    end
    %
    [resSelfCVec{:}]=self.getDataInternal(leftInpArgList{:},...
        'replaceNull',true);
    [resOtherCVec{:}]=otherObj.getDataInternal(rightInpArgList{:},...
        'replaceNull',true,...
        inpIsMemberOtherArgList{:});
    %
    %compare the sorted data
    compareData();
end
if isEq&&~isempty(reportStr)
    throwerror('wrongImplementation','Oops'', we shouldn''t be here');
end
    function compareData()
        isEq=true;
        reportStrList=cell(1,nStructs);
        for iStruct=1:nStructs
            if iStruct==1,
                curTolerance=maxTolerance;
                curRelTolerance=maxRelTolerance;
            else
                curTolerance=0;
                curRelTolerance=0;
            end
            if isRelComparison
                inpArgs={curRelTolerance};
            else
                inpArgs={};
            end
            [isEqCur,reportStrCur]=compFuncHandle(...
                resSelfCVec{iStruct},resOtherCVec{iStruct},curTolerance,...
                inpArgs{:});
            if ~isempty(reportStrCur),
                reportStrList{iStruct}=sprintf('(%s):%s',structNameList{iStruct},reportStrCur);
            end
            isEq=isEq&&isEqCur;
        end
        reportStrList(cellfun('isempty',reportStrList))=[];
        nReports=length(reportStrList);
        %
        if nReports>1,
            reportStrList(1:end-1)=cellfun(@(x)horzcat(x,sprintf('\n')),...
                reportStrList(1:end-1),'UniformOutput',false);
        end
        if nReports>0,
            reportStr=horzcat(reportStrList{:});
        end
    end
end