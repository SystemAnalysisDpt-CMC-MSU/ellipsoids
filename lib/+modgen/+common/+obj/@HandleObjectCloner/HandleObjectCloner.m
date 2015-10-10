classdef HandleObjectCloner<handle
    % HANDLEOBJECTCLONER provides some simple functionality for clonable
    % objects
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-07 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    properties (Access=private)
        comparisonMode=modgen.common.obj.ObjectComparisonMode.UserDefined;
    end
    %
    methods (Access=protected)
        function blobComparisonHook(~)
        end
    end
    methods (Access=protected, Sealed)
        function prevMode=setComparisonMode(self,comparisonMode)
            if nargout>0
                prevMode=self.getComparisonMode();
            end
            [self.comparisonMode]=deal(comparisonMode);
        end
        %
        function comparisonMode=getComparisonMode(self)
            import modgen.common.throwerror;
            if numel(self)==1
                comparisonMode=self.comparisonMode;
            elseif isempty(self)
                comparisonMode=...
                    modgen.common.obj.ObjectComparisonMode.UserDefined;
            else
                isAllCompModeEq=isequal(self.comparisonMode);
                if ~isAllCompModeEq
                    throwerror('wrongInput',['all elements of an object',...
                        'array are expected to have the same value',...
                        'of comparisonMode']);
                end
                comparisonMode=self(1).comparisonMode;
            end
        end
    end
    %
    methods (Access=protected)
        function propCheckCMat=getHandleClonerIsEqualPropCheckCMat(self,...
                propNameList)
            import modgen.common.obj.ObjectComparisonMode;
            switch self.getComparisonMode
                case ObjectComparisonMode.UserDefined
                    isAsHandleDefault=false;
                    isAsBlobDefault=false;
                case ObjectComparisonMode.Blob
                    isAsBlobDefault=true;
                    isAsHandleDefault=false;
                case ObjectComparisonMode.Handle
                    isAsBlobDefault=false;
                    isAsHandleDefault=true;
            end
            %
            propCheckCMat={'asHandle','asBlob','propEqScalarList','compareClass';...
                isAsHandleDefault,isAsBlobDefault,cell(1,0),true;...
                'isscalar(x)&&islogical(x)','isscalar(x)&&islogical(x)',...
                'iscell(x)&&(isrow(x)||(max(size(x))<=1))',...
                'isscalar(x)&&islogical(x)'};
            if nargin>1
                [isThereVec,indThereVec]=ismember(lower(propNameList),...
                    lower(propCheckCMat(1,:)));
                if ~all(isThereVec)
                    throwerror('wrongInput','not all properties are know');
                end
                propCheckCMat=propCheckCMat(:,indThereVec);
            end
        end
    end
    methods (Access=private,Static)
        function isPositive=isMe(inpObj)
            %
            curClassName=mfilename('class');
            isPositive=isa(inpObj,curClassName);
        end
    end
    methods (Access=protected,Sealed)
        function [regArgList,propEqScalarList]=...
                parseEqScalarProps(self,eqPropCheckCMat,...
                propListToParse)
            import modgen.common.parseparams;
            import modgen.common.parseparext;
            %
            propCheckCMat=self.getHandleClonerIsEqualPropCheckCMat(...
                'propEqScalarList');
            nProps=size(eqPropCheckCMat,2);
            [regArgList,~,eqRelatedPropValList]=...
                modgen.common.parseparext(propListToParse,...
                eqPropCheckCMat,...
                'propRetMode','list','isDefaultPropSpecVec',...
                false(1,nProps));
            %
            [regArgList,~,propEqScalarList]=...
                parseparext(regArgList,propCheckCMat);
            %
            propEqScalarList=[propEqScalarList,eqRelatedPropValList];
        end
    end
    %
    methods (Sealed)
        function varargout=ismember(leftObjVec,rightObjVec,varargin)
            import modgen.common.obj.ObjectComparisonMode;
            import modgen.common.ismembersortableobj;
            prevLeftMode=...
                leftObjVec.setComparisonMode(ObjectComparisonMode.Blob);
            prevRightMode=...
                rightObjVec.setComparisonMode(ObjectComparisonMode.Blob);
            %
            try
                if nargout==0
                    ismembersortableobj(leftObjVec,rightObjVec,varargin{:});
                else
                    varargout=cell(1,nargout);
                    [varargout{:}]=ismembersortableobj(leftObjVec,...
                        rightObjVec,varargin{:});
                end
                leftObjVec.setComparisonMode(prevLeftMode);
                rightObjVec.setComparisonMode(prevRightMode);
            catch meObj
                leftObjVec.setComparisonMode(prevLeftMode);
                rightObjVec.setComparisonMode(prevRightMode);
                rethrow(meObj);
            end
        end
        function varargout=unique(inpObjVec,varargin)
            import modgen.common.obj.ObjectComparisonMode;
            import modgen.common.uniquesortableobj;
            prevMode=inpObjVec.setComparisonMode(ObjectComparisonMode.Blob);
            try
                if nargout==0
                    uniquesortableobj(inpObjVec,varargin{:});
                else
                    varargout=cell(1,nargout);
                    [varargout{:}]=uniquesortableobj(inpObjVec,varargin{:});
                end
                inpObjVec.setComparisonMode(prevMode);
            catch meObj
                inpObjVec.setComparisonMode(prevMode);
                rethrow(meObj);
            end
        end
        function [resObjVec,indVec]=sort(inpObjVec)
            import modgen.common.obj.ObjectComparisonMode;
            prevMode=inpObjVec.setComparisonMode(ObjectComparisonMode.Blob);
            try
                [resObjVec,indVec]=modgen.algo.sort.mergesort(inpObjVec);
                inpObjVec.setComparisonMode(prevMode);
            catch meObj
                inpObjVec.setComparisonMode(prevMode);
                rethrow(meObj);
            end
        end
        %
        function isEqArr=ne(varargin)
            isEqArr=eq(varargin{:});
            isEqArr=~isEqArr;
        end
        %
        function isEqArr=eq(varargin)
            % EQ - same as isEqualElem from below with a few exceptions:
            %   1) doesn't have reportStr output
            %   2) only supports "asHandle" property
            import modgen.common.parseparext;
            propCheckCMat=...
                varargin{1}.getHandleClonerIsEqualPropCheckCMat(...
                'asHandle');
            [regArgList,~,isAsHandle]=parseparext(varargin,...
                propCheckCMat,2);
            if isAsHandle
                isEqArr=eq@handle(regArgList{:});
            else
                isEqArr=isEqualElem(regArgList{:});
            end
        end
        function isLeArr=le(varargin)
            % LE - "<=" operator defined based on the 3rd output of 
            %   isEqualElem method described below and it
            %
            %   1) doesn't have reportStr output
            %   2) only supports "asHandle" property  
            %
            import modgen.common.parseparext;
            propCheckCMat=...
                varargin{1}.getHandleClonerIsEqualPropCheckCMat(...
                'asHandle');
            [regArgList,~,isAsHandle]=parseparext(varargin,...
                propCheckCMat,2);
            if isAsHandle
                isLeArr=le@handle(regArgList{:});
            else
                [~,~,signOfDiffArr]=isEqualElem(regArgList{:});
                isLeArr=signOfDiffArr<=0;
            end
        end
        %
        function isGeArr=ge(varargin)
            % GE - ">=" operator defined based on the 3rd output of 
            %   isEqualElem method described below and it
            %
            %   1) doesn't have reportStr output
            %   2) only supports "asHandle" property    
            %
            import modgen.common.parseparext;
            propCheckCMat=...
                varargin{1}.getHandleClonerIsEqualPropCheckCMat(...
                'asHandle');
            [regArgList,~,isAsHandle]=parseparext(varargin,...
                propCheckCMat,2);
            if isAsHandle
                isGeArr=ge@handle(regArgList{:});
            else
                [~,~,signOfDiffArr]=isEqualElem(regArgList{:});
                isGeArr=signOfDiffArr>=0;
            end
        end
        %
        function isLtArr=lt(varargin)
            % LT - "<" operator defined based on the 3rd output of 
            %   isEqualElem method described below and it
            %
            %   1) doesn't have reportStr output
            %   2) only supports "asHandle" property    
            %            
            import modgen.common.parseparext;
            propCheckCMat=...
                varargin{1}.getHandleClonerIsEqualPropCheckCMat(...
                'asHandle');
            [regArgList,~,isAsHandle]=parseparext(varargin,...
                propCheckCMat,2);
            if isAsHandle
                isLtArr=lt@handle(regArgList{:});
            else
                [~,~,signOfDiffArr]=isEqualElem(regArgList{:});
                isLtArr=signOfDiffArr<0;
            end
        end
        %
        function isGtArr=gt(varargin)
            % GT - ">" operator defined based on the 3rd output of 
            %   isEqualElem method described below and it
            %
            %   1) doesn't have reportStr output
            %   2) only supports "asHandle" property    
            %              
            import modgen.common.parseparext;
            propCheckCMat=...
                varargin{1}.getHandleClonerIsEqualPropCheckCMat(...
                'asHandle');
            [regArgList,~,isAsHandle]=parseparext(varargin,...
                propCheckCMat,2);
            if isAsHandle
                isGtArr=gt@handle(regArgList{:});
            else
                [~,~,signOfDiffArr]=isEqualElem(regArgList{:});
                isGtArr=signOfDiffArr>0;
            end
        end
        %
        function isEq=isequal(varargin)
            % ISEQUAL - same as isEqual but without reportStr output
            isEq=isEqual(varargin{:});
        end
        function isEq=isequaln(varargin)
            % ISEQUALN - same as isEqual but without reportStr output
            isEq=isequal(varargin{:});
        end
        function isEq=isequalwithequalnans(varargin)
            % ISEQUALNWITHEQUALNANS - same as isEqual but without reportStr output
            isEq=isequal(varargin{:});
        end
    end
    %
    methods
        function [isEq,reportStr]=isEqual(varargin)
            % ISEQUAL compares objects and returns true if they are found
            % equal
            %
            % Usage: isEq=obj1Arr.isEqual(,...,objNArr,varargin) or
            %        [isEq,reportStr]=isequal(obj1Arr,...,objNArr,varargin)
            %
            % Input:
            %   regular:
            %       obj1Arr: HandleObjectCloner of any size - first object
            %           array
            %       obj2Arr: HandleObjectCloner of any size - second object
            %           array
            %           ...
            %       objNArr: HandleObjectCloner of any size - N-th object
            %           array
            %
            %   properties:
            %       isFullCheck: logical [1,1] - if true, then all input
            %           objects are compared, otherwise (default) check is
            %           performed up to the first difference
            %       asHandle: logical[1,1] - if true, elements are compared
            %           as handles ignoring content of the objects
            %       asBlob: logical[1,1] - if true, objects are compared as
            %           binary sequencies aka BLOBs
            %         Note: you cannot set both asBlob and asHandle to true
            %           at the same time            
            %       propEqScalarList: cell[1,] - list of properties passed
            %           to isEqualScalarInternal method
            % Output:
            %   regular:
            %       isEq: logical [1,1] - true if all objects are equal,
            %           false otherwise
            %       reportStr: char - report about the found differences
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 05-June-2015 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2015 $
            %
            import modgen.common.throwerror;
            import modgen.common.parseparext;
            import modgen.common.parseparams;
            NOT_EQ_STR='(object arrays #%d and #%d):%s';
            %
            indObj=find(cellfun(@(x)isa(x,mfilename('class')),varargin),...
                1,'first');
            propCheckCMat=...
                varargin{indObj}.getHandleClonerIsEqualPropCheckCMat();
            %
            isReportRequired=nargout>1;
            %
            [objList,~,isFullCheck,isAsHandle,isAsBlob,propEqScalarList,...
                isClassCompared]=...
                parseparext(varargin,...
                [{'isfullcheck';false;'isscalar(x)&&islogical(x)'},...
                propCheckCMat]);
            %
            checkIsHandleIsBlob(isAsHandle,isAsBlob);
            if isAsBlob&&~isClassCompared
                throwerror('wrongInput',['isClassCompared cannot be ',...
                    'set to false when isAsBlob is true']);
            end
            %
            nObj=length(objList);
            if nObj==1,
                throwerror('wrongInput','Not enough input arguments');
            end
            %
            if isReportRequired
                reportStr='';
                reportStrList=cell(1,nObj-1);
                curReportCell=cell(1,1);
            else
                curReportCell={};
            end
            isEq=true;
            for iObj=1:nObj-1,
                obj1=objList{iObj};
                obj2=objList{iObj+1};
                if isequal(size(obj1),size(obj2)),
                    if ~isClassCompared||isequal(class(obj1),class(obj2))
                        if isAsHandle
                            isEqCur=obj1.eq(obj2,'asHandle',true);
                            if isReportRequired
                                if ~isEqCur
                                    reportStrCur='handles are different';
                                else
                                    reportStrCur='';
                                end
                            end
                        else
                            if isAsBlob
                                [isEqCur,curReportCell{:}]=...
                                    obj1.isEqualScalarAsBlobInternal(...
                                    obj2,propEqScalarList{:});
                            else
                                [isEqCurMat,curReportCell{:}]=...
                                    obj1.isEqualElem(...
                                    obj2,'propEqScalarList',...
                                    propEqScalarList,'compareClass',...
                                    isClassCompared);
                                %
                                isEqCur=all(isEqCurMat(:));
                            end
                            if isReportRequired
                                reportStrCur=curReportCell{1};
                            end
                        end
                        %
                        isEqCur=all(isEqCur(:));
                        if isReportRequired&&~isempty(reportStrCur),
                            reportStrList{iObj}=sprintf(...
                                NOT_EQ_STR,...
                                iObj,iObj+1,reportStrCur);
                        end
                    else
                        isEqCur=false;
                        if nargout>1,
                            reportStrList{iObj}=sprintf(...
                                NOT_EQ_STR,...
                                iObj,iObj+1,'classes are not equal');
                        end
                    end
                else
                    isEqCur=false;
                    if nargout>1,
                        reportStrList{iObj}=sprintf(...
                            NOT_EQ_STR,...
                            iObj,iObj+1,'sizes are not equal');
                    end
                end
                isEq=isEq&&isEqCur;
                if ~(isEq||isFullCheck),
                    break;
                end
            end
            if isReportRequired
                reportStrList(cellfun('isempty',reportStrList))=[];
                if length(reportStrList)>1,
                    reportStr=modgen.string.catwithsep(reportStrList,...
                        sprintf('\n'));
                elseif ~isempty(reportStrList),
                    reportStr=reportStrList{:};
                end
            end
        end
        %
        function [isEqArr,reportStr,signOfDiffArr]=isEqualElem(selfArr,...
                otherArr,varargin)
            % ISEQUALELEM returns true if HandleObjectCloner objects are
            % equal and false otherwise
            %
            % Usage: isEqArr=eq(selfArr,otherArr,varargin)
            %
            % Input:
            %   regular:
            %       selfArr: HandleObjectCloner [n_1,n_2,...,n_k] - calling
            %           object
            %       otherArr: HandleObjectCloner [n_1,n_2,...,n_k] - other
            %           object to compare with
            %   properties:
            %       asHandle: logical[1,1] - if true, elements are compared
            %           as handles ignoring content of the objects
            %       asBlob: logical[1,1] - if true, objects are compared as
            %           binary sequencies aka BLOBs
            %         Note: you cannot set both asBlob and asHandle to true
            %           at the same time
            %       propEqScalarList: cell[1,] - list of properties passed
            %           to isEqualScalarInternal method
            % Output:
            %   	isEqMat: logical[n_1,n_2,...,n_k] - the element is true if the
            %           corresponding objects are equal, false otherwise
            %       reportStr: char[1,] - report about the found differences
            %       signOfDiffArr: double[n_1,n_2,...,n_k] - array of signs of
            %           differences: 
            %               -1: if left element < right element
            %                0: if elements are equal
            %               +1: if left element > right element
            %            Note: current implementation defines this sign
            %               only for asBlob=true mode, for the rest of the
            %               comparison modes it is NaN
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 09-Sep-2015 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2015 $
            %
            import modgen.common.throwerror;
            import modgen.common.parseparext;
            %
            propCheckCMat=...
                selfArr.getHandleClonerIsEqualPropCheckCMat();
            %
            [~,~,isAsHandle,isAsBlob,propEqScalarList,isClassCompared]=...
                parseparext(varargin,propCheckCMat,0);
            %
            checkIsHandleIsBlob(isAsHandle,isAsBlob);
            %
            isReportRequired=nargout>1;
            isSignOfDiffRequired=nargout>2;
            %
            sizeVec=size(selfArr);
            if ~isequal(sizeVec,size(otherArr)),
                if numel(selfArr)==1,
                    sizeVec=size(otherArr);
                    selfArr=repmat(selfArr,sizeVec);
                elseif numel(otherArr)==1,
                    otherArr=repmat(otherArr,sizeVec);
                else
                    error('MATLAB:dimagree',...
                        'Matrix dimensions must agree.');
                end
            end
            nElems=numel(selfArr);
            if isReportRequired
                reportStr='';
                reportStrList=cell(1,nElems);
                curExtraOutArgList=cell(1,nargout-1);
            else
                curExtraOutArgList={};
            end
            
            isEqHandleMat=selfArr.eq(otherArr,'asHandle',true);
            %
            if isSignOfDiffRequired
                signOfDiffArr=nan(size(isEqHandleMat));
                signOfDiffArr(isEqHandleMat)=0;
            end
            %
            if ~all(isEqHandleMat(:))
                isEqArr=true(sizeVec);
                if isClassCompared&&(~isa(otherArr,class(selfArr))),
                    isEqArr(:)=false;
                    if nargout>1,
                        reportStr='Not equal classes of objects';
                    end
                else
                    if ~isempty(isEqArr),
                        for iElem=1:nElems,
                            
                            isEqCur=isEqHandleMat(iElem);
                            %
                            if ~isEqCur
                                if isAsHandle
                                    if isReportRequired
                                        reportStrCur='handles are different';
                                    end
                                else
                                    if isAsBlob
                                        [isEqCur,curExtraOutArgList{:}]=...
                                            selfArr(iElem).isEqualScalarAsBlobInternal(...
                                            otherArr(iElem),propEqScalarList{:});
                                        %
                                        if isSignOfDiffRequired
                                            signOfDiffArr(iElem)=curExtraOutArgList{2};
                                        end
                                    else
                                        [isEqCur,curExtraOutArgList{:}]=...
                                            selfArr(iElem).isEqualScalarInternal(...
                                            otherArr(iElem),propEqScalarList{:});
                                    end
                                    if isReportRequired
                                        reportStrCur=curExtraOutArgList{1};
                                    end
                                end
                            end
                            %
                            if (nargout>1)&&~isempty(reportStrCur)
                                reportStrList{iElem}=sprintf(...
                                    '(element #%d):%s',iElem,...
                                    reportStrCur);
                            end
                            isEqArr(iElem)=isEqCur;
                        end
                        if nargout>1,
                            reportStrList(...
                                cellfun('isempty',reportStrList))=[];
                            if length(reportStrList)>1,
                                reportStr=modgen.string.catwithsep(...
                                    reportStrList,sprintf('\n'));
                            elseif ~isempty(reportStrList),
                                reportStr=reportStrList{:};
                            end
                        end
                    end
                end
            else
                isEqArr=isEqHandleMat;
            end
            if isSignOfDiffRequired
                if any(isnan(signOfDiffArr(:)))
                    throwerror('wrongInput:signNotDefForAllElems',...
                        ['sign of difference is ',...
                        'not assigned for all elements']);
                end
            end
        end
    end
    methods (Access=private)
        function [isEq,reportStr,signOfDiff]=...
                isEqualScalarAsBlobInternal(leftObj,rightObj)
            %
            leftObj.blobComparisonHook();
            if nargout<=2
                isEq=false;
                isEqSize=isequal(size(leftObj),size(rightObj));
                if isEqSize
                    isEqClass=isequal(class(leftObj),class(rightObj));
                    if ~isEqClass
                        reportStr='classes are different';
                    else
                        isEq=true;
                    end
                else
                    if nargout>1
                        reportStr='sizes are different';
                    end
                end
            else
                isEq=true;
            end
            %
            if isEq
                leftBlobVec=getByteStreamFromArray(leftObj);
                rightBlobVec=getByteStreamFromArray(rightObj);
                nLeftElems=numel(leftBlobVec);
                nRightElems=numel(rightBlobVec);
                %
                isEqBlobSize=nLeftElems==nRightElems;
                isEq=isEqBlobSize&&isequal(leftBlobVec,rightBlobVec);
                if nargout>1
                    if isEq
                        reportStr='';
                    else
                        if isEqBlobSize
                            reportStr='blobs are different';
                        else
                            reportStr='blob sizes are different';
                        end
                    end
                    if nargout>2
                        if ~isEq
                            if ~isEqBlobSize
                                if nLeftElems<nRightElems
                                    leftBlobVec=[leftBlobVec,...
                                        zeros(1,nRightElems-nLeftElems)];
                                else
                                    leftBlobVec=[rightBlobVec,...
                                        zeros(1,nLeftElems)-nRightElems];
                                end
                            end
                            [~,indSortedVec]=sortrows([leftBlobVec;rightBlobVec]);
                            signOfDiff=indSortedVec(2)-indSortedVec(1);
                        else
                            signOfDiff=0;
                        end
                    end
                end
            end
        end
    end
    %
    methods (Access=protected)
        function [isOk,reportStr,signOfDiff]=...
                isEqualScalarInternal(self,otherObj,varargin)
            %
            isOk=self.eq(otherObj,'asHandle',true);
            if nargout>1
                if isOk
                    reportStr='';
                else
                    reportStr='handles are different';
                end
                if nargout>2
                    signOfDiff=nan;
                end
            end
        end
    end
    methods
        function obj=clone(self,varargin)
            % CLONE - creates a copy of a specified object via calling
            %         a copy constructor for the object class
            %
            % Input:
            %   regular:
            %     self: any [] - current object
            %   optional
            %     any parameters applicable for relation constructor
            %
            % Ouput:
            %   self: any [] - constructed object
            if isempty(varargin)
                %Performance optimization
                obj = getArrayFromByteStream(getByteStreamFromArray(self));
            else
                obj=self.createInstance(self,varargin{:});
            end
        end
        function resObj=createInstance(self,varargin)
            % CREATEINSTANCE - returns an object of the same class by calling a default
            %                  constructor (with no parameters)
            %
            % Usage: resObj=getInstance(self)
            %
            % input:
            %   regular:
            %     self: any [] - current object
            %   optional
            %     any parameters applicable for relation constructor
            %
            % Ouput:
            %   self: any [] - constructed object
            p=metaclass(self);
            resObj=feval(p.Name,varargin{:});
        end
    end
end
function checkIsHandleIsBlob(isAsHandle,isAsBlob)
import modgen.common.throwerror;
if isAsBlob&&isAsHandle
    throwerror('wrongInput:blobAndHandleIncompatible',['isAsBlob and isAsHandle ',...
        'cannot both be true']);
end
end