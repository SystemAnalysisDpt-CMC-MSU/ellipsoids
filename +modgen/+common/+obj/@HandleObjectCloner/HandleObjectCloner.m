classdef HandleObjectCloner<handle
    % HANDLEOBJECTCLONER provides some simples functionality for clonable
    % objects
    % 
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-07 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    methods (Access=protected,Static)
        function propCheckCMat=getHandleClonerIsEqualPropCheckCMat(propNameList)
            propCheckCMat={'asHandle','propEqScalarList','compareClass';...
                false,cell(1,0),true;...
                'isscalar(x)&&islogical(x)',...
                'iscell(x)&&(isrow(x)||(max(size(x))<=1))',...
                'isscalar(x)&&islogical(x)'};
            if nargin>0
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
    methods (Access=protected,Static,Sealed)
        function [regArgList,propEqScalarList]=...
                parseEqScalarProps(eqPropCheckCMat,...
                propListToParse)
            import modgen.common.parseparams;
            import modgen.common.parseparext;
            %
            import modgen.common.obj.HandleObjectCloner;            
            %
            propCheckCMat=...
                HandleObjectCloner.getHandleClonerIsEqualPropCheckCMat(...
                'propEqScalarList');            
            nProps=size(eqPropCheckCMat,2);
            [regArgList,~,eqRelatedPropValList]=...
            modgen.common.parseparext(propListToParse,...
            eqPropCheckCMat,...
            'propRetMode','list','isDefaultPropSpecVec',false(1,nProps));            
            %
            [regArgList,~,propEqScalarList]=...
                parseparext(regArgList,propCheckCMat);
            %
            propEqScalarList=[propEqScalarList,eqRelatedPropValList];
        end
    end
    %
    methods (Sealed)
        function isEqArr=ne(varargin)
            isEqArr=eq(varargin{:});
            isEqArr=~isEqArr;
        end
        function isEqArr=eq(varargin)
            % EQ - same as isEqualElem from below but without reportStr
            %   output
            import modgen.common.parseparext;
            import modgen.common.obj.HandleObjectCloner;
            propCheckCMat=...
                HandleObjectCloner.getHandleClonerIsEqualPropCheckCMat(...
                'asHandle');
            [regArgList,~,isAsHandle]=parseparext(varargin,...
                propCheckCMat,2);
            if isAsHandle
                isEqArr=eq@handle(regArgList{:});
            else
                isEqArr=isEqualElem(regArgList{:});
            end
        end
        function isEq=isequal(varargin)
            % ISEQUAL - same as isEqual but without reportStr output
            isEq=isEqual(varargin{:});
        end
        function isEq=isequaln(varargin)
            % ISEQUALN - same as isEqual but without reportStr output
            isEq=~isequal(varargin{:});
        end
    end
    methods
        %
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
            import modgen.common.obj.HandleObjectCloner;            
            NOT_EQ_STR='(object arrays #%d and #%d):%s';
            %
            propCheckCMat=...
                HandleObjectCloner.getHandleClonerIsEqualPropCheckCMat();
            %
            reportStr='';
            [objList,~,isFullCheck,isAsHandle,propEqScalarList,...
                isClassCompared]=...
                parseparext(varargin,...
                [{'isfullcheck';false;'isscalar(x)&&islogical(x)'},...
                propCheckCMat]);
            %
            nObj=length(objList);
            if nObj==1,
                throwerror('wrongInput','Not enough input arguments');
            end
            %
            reportStrList=cell(1,nObj-1);
            isEq=true;
            for iObj=1:nObj-1,
                obj1=objList{iObj};
                obj2=objList{iObj+1};
                if isequal(size(obj1),size(obj2)),
                    if ~isClassCompared||isequal(class(obj1),class(obj2))
                        if nargout>1,
                            if isAsHandle
                                isEqCur=obj1.eq(obj2,'asHandle',true);
                                if ~isEqCur
                                    reportStrCur='handles are different';
                                else
                                    reportStrCur='';
                                end
                            else
                                [isEqCurMat,reportStrCur]=...
                                    obj1.isEqualElem(...
                                    obj2,'propEqScalarList',...
                                    propEqScalarList,'compareClass',...
                                    isClassCompared);
                                %
                                isEqCur=all(isEqCurMat(:));
                            end
                            %
                            isEqCur=all(isEqCur(:));
                            if ~isempty(reportStrCur),
                                reportStrList{iObj}=sprintf(...
                                    NOT_EQ_STR,...
                                    iObj,iObj+1,reportStrCur);
                            end
                        else
                            isEqCurArr=(eq(obj1,obj2));
                            isEqCur=all(isEqCurArr(:));
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
            if nargout>1,
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
        function [isEqArr,reportStr]=isEqualElem(selfArr,otherArr,varargin)
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
            %       propEqScalarList: cell[1,] - list of properties passed
            %           to isEqualScalarInternal method            
            % Output:
            %   	isEqMat: logical[n_1,n_2,...,n_k] - the element is true if the
            %           corresponding objects are equal, false otherwise
            %       reportStr: char[1,] - report about the found differences
            %            
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 05-June-2015 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2015 $   
            %
            import modgen.common.throwerror;
            import modgen.common.parseparext;
            import modgen.common.obj.HandleObjectCloner;            
            %
            propCheckCMat=...
                HandleObjectCloner.getHandleClonerIsEqualPropCheckCMat();            
            [~,~,isAsHandle,propEqScalarList,isClassCompared]=...
                parseparext(varargin,propCheckCMat,0);
            reportStr='';
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
            isEqHandleMat=selfArr.eq(otherArr,'asHandle',true);
            if ~all(isEqHandleMat(:))
                isEqArr=true(sizeVec);                
                if isClassCompared&&(~isa(otherArr,class(selfArr))),
                    isEqArr(:)=false;
                    if nargout>1,
                        reportStr='Not equal classes of objects';
                    end
                else
                    if ~isempty(isEqArr),
                        nElems=numel(selfArr);
                        reportStrList=cell(1,nElems);
                        for iElem=1:nElems,
                            if isAsHandle
                                isEqCur=isEqHandleMat(iElem);
                                if ~isEqCur
                                    reportStrCur='handles are different';
                                end
                            else
                                [isEqCur,reportStrCur]=...
                                    selfArr(iElem).isEqualScalarInternal(...
                                    otherArr(iElem),propEqScalarList{:});
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
        end
    end
    %
    methods (Access=protected)
        function [isOk,reportStr]=isEqualScalarInternal(self,otherObj,...
                varargin)
            %
            isOk=self.eq(self,otherObj,'asHandle',true);
            reportStr='';
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