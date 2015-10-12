classdef ATypifiedAdjustedRel<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    methods 
        function self=ATypifiedAdjustedRel(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(varargin{:});
        end
        %
        function sortDetermenistically(self,varargin)
            self.sortDetermenisticallyInternal(varargin{:});
        end
    end
    methods (Access=protected,Sealed)
        %
        function propCheckCMat=getEllOnlyIsEqualPropCheckCMat(self)
            import gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel;
            %checkTupleOrder=true for EllTube classes by default
            propCheckCMat=self.getRelIsEqualPropCheckCMat(...
                {'checkTupleOrder'});
            propCheckCMat{2}=true;
            %
            propCheckCMat=[{'notComparedFieldList','areTimeBoundsCompared';...
                cell(1,0),false;...
                'isrow(x)&&iscellofstrvec(x)','isscalar(x)&&islogical(x)'},...
                propCheckCMat];
        end
    end
    methods (Sealed)
        %
        function propCheckCMat=getEllIsEqualPropCheckCMat(self,propNameList)
            import modgen.common.throwerror;
            propCheckCMat=[...
                self.getEllOnlyIsEqualPropCheckCMat(),...
                self.getRelIsEqualPropCheckCMat()];
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
    methods
        function [isEq,reportStr]=isEqual(varargin)
        % ISEQUAL compares the specified CubeStruct object with other CubeStruct
        % object and returns true if they are equal, otherwise it
        % returns false
        %
        % Usage: isEq=obj1Arr.isEqual(,...,objNArr,varargin) or
        %        [isEq,reportStr]=isequal(obj1Arr,...,objNArr,varargin)
        %
        % Input:
        % 	regular:
        %       obj1Arr: CubeStruct of any size - first object
        %           array
        %       obj2Arr: CubeStruct of any size - second object
        %           array
        %           ...
        %       objNArr: CubeStruct of any size - N-th object
        %           array
        %
        %   properties:
        %       asHandle: logical[1,1] - if true, elements are compared
        %           as handles ignoring content of the objects 
        %       asBlob: logical[1,1] - if true, objects are compared as
        %           binary sequencies aka BLOBs
        %         Note: you cannot set both asBlob and asHandle to true
        %           at the same time
        %
        %       propEqScalarList: cell[1,] - list of properties passed
        %           to isEqualScalarInternal method  
        %
        %       checkTupleOrder: logical[1,1] -  if true, then the tuples in the 
        %           compared relations are expected to be in the same order,
        %           otherwise the order is not important (false by default)        
        %       checkFieldOrder: logical [1,1] -
        %           if true, then fields in compared objects must
        %           be in the same order, otherwise the order is not
        %           important (false by default)
        %
        %       compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
        %           referenced from the meta data objects are also compared
        %
        %       maxTolerance: double [1,1] - maximum allowed tolerance
        %
        %       maxRelativeTolerance: double [1,1] - maximum allowed relative
        %           tolerance
        %       notComparedFieldList: cell[1,nFields] of char[1,] - list
        %       	of fields that are not compared
        %
        %       areTimeBoundsCompared: logical[1,1] - if false,
        %           ellipsoidal tubes are compared on intersection of
        %           definition domains        
        %
        % Output:
        %   isEq: logical[1,1] - result of comparison
        %   reportStr: char[1,] - contains an additional information about the
        %      differences (if any)
        %
        %
        % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 21-June-2015 $ 
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2015 $
        %                
            import modgen.common.parseparams;
            import modgen.common.parseparext;
            import gras.ellapx.smartdb.rels.ATypifiedAdjustedRel;            
            %
            indObj=find(cellfun(@(x)isa(x,mfilename('class')),varargin),...
                1,'first');            
            [regArgList,propEqScalarList]=...
                varargin{indObj}.parseEqScalarProps(...
                varargin{indObj}.getEllOnlyIsEqualPropCheckCMat(),...
                varargin);
            %
            [isEq,reportStr]=...
                isEqual@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                regArgList{:},'compareClass',false,'propEqScalarList',...
                propEqScalarList);
        end
        function [isEqArr,varargout]=isEqualElem(varargin)
        % ISEQUALELEM compares the specified CubeStruct object with other CubeStruct
        % object and returns true if they are equal, otherwise it
        % returns false
        %
        % Usage: isEqArr=isEqualElem(selfArr,otherArr,varargin)
        %
        % Input:
        %   regular:
        %       selfArr: ARelation [n_1,n_2,...,n_k] - calling
        %           object
        %       otherArr: ARelation [n_1,n_2,...,n_k] - other
        %           object to compare with
        %
        %   properties:
        %       asHandle: logical[1,1] - if true, elements are compared
        %           as handles ignoring content of the objects   
        %       asBlob: logical[1,1] - if true, objects are compared as
        %           binary sequencies aka BLOBs
        %         Note: you cannot set both asBlob and asHandle to true
        %           at the same time        
        %       propEqScalarList: cell[1,] - list of properties passed
        %           to isEqualScalarInternal method  
        %
        %       checkTupleOrder: logical[1,1] -  if true, then the tuples in the 
        %           compared relations are expected to be in the same order,
        %           otherwise the order is not important (false by default)        
        %       checkFieldOrder: logical [1,1] -
        %           if true, then fields in compared objects must
        %           be in the same order, otherwise the order is not
        %           important (false by default)
        %
        %       compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
        %           referenced from the meta data objects are also compared
        %
        %       maxTolerance: double [1,1] - maximum allowed tolerance
        %
        %       maxRelativeTolerance: double [1,1] - maximum allowed relative
        %           tolerance
        %       notComparedFieldList: cell[1,nFields] of char[1,] - list
        %       	of fields that are not compared
        %
        %       areTimeBoundsCompared: logical[1,1] - if false,
        %           ellipsoidal tubes are compared on intersection of
        %           definition domains        
        %
        % Output:
        %   isEqArr: logical[n_1,n_2,...,n_k] - result of comparison
        %   reportStr: char[1,] - contains an additional information about the
        %      differences (if any)
        %   signOfDiffArr: double[n_1,n_2,...,n_k] - array of signs of
        %       differences:
        %           -1: if left element < right element
        %            0: if elements are equal
        %           +1: if left element > right element
        %        Note: current implementation defines this sign
        %           only for asBlob=true mode, for the rest of the
        %           comparison modes it is NaN        
        %
        %
        % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 21-June-2015 $ 
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2015 $
        %                        
            import modgen.common.parseparams;
            import gras.ellapx.smartdb.rels.ATypifiedAdjustedRel;    
            %
            indObj=find(cellfun(@(x)isa(x,mfilename('class')),varargin),...
                1,'first');                 
            [regArgList,propEqScalarList]=...
                varargin{indObj}.parseEqScalarProps(...
                varargin{indObj}.getEllOnlyIsEqualPropCheckCMat(),...
                varargin);
            %
            classComparePropCMat=...
                varargin{indObj}.getHandleClonerIsEqualPropCheckCMat(...
                {'compareClass'});
            classComparePropCMat{2}=false;
            %
            [regArgList,~,propValList]=...
                        modgen.common.parseparext(regArgList,...
                        classComparePropCMat,...
                        'propRetMode','list');
            %
            varargout=cell(1,max(nargout-1,0));            
            [isEqArr,varargout{:}]=...
                isEqualElem@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                regArgList{:},propValList{:},'propEqScalarList',...
                propEqScalarList);
        end        
    end    
    methods (Access=protected)
        function [isOk,varargout]=isEqualScalarInternal(self,otherRel,varargin)
            self.checkIfObjectScalar();
            otherRel.checkIfObjectScalar();
            [reg,prop]=modgen.common.parseparams(varargin,...
                {'maxTolerance'});
            self.sortDetermenisticallyInternal(prop{2:end});
            otherRel.sortDetermenisticallyInternal(prop{2:end});
            %
            varargout=cell(1,max(nargout-1,0));                     
            [isOk,varargout{:}]=self.isEqualScalarAdjustedInternal(otherRel,...
                reg{:},prop{:});
        end
    end
    methods (Access=protected,Static,Hidden)
        function outObj=loadObjViaConstructor(className,inpObj)
            import modgen.common.throwwarn;
            if isstruct(inpObj)&&isfield(inpObj,'SData')&&...
                    isfield(inpObj,'SIsNull')&&isfield(inpObj,'SIsValueNull')
                throwwarn('badMatFile:wrongState',...
                    ['Apparently relation loaded from ',...
                    'the file has a legacy format \n',...
                    'and was loaded as a structure. ',...
                    'Calling %s constructor on loaded data.'],className);                
                %
                isEmptyFieldVec=structfun(@isempty,inpObj.SData);
                %
                if all(isEmptyFieldVec)
                    inpObj=feval(className);
                else
                    inpObj=feval(className,inpObj.SData,...
                        inpObj.SIsNull,inpObj.SIsValueNull);
                end
            end
            outObj=...
                gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel.loadobj(inpObj);
        end
    end    
    
    
    methods (Access=protected)
        function sortDetermenisticallyInternal(self,maxTolerance)
            import modgen.common.checkvar;
            import modgen.common.roundn;
            MAX_PREC_DEFAULT=1e-6;
            if nargin<2
                maxTolerance=MAX_PREC_DEFAULT;
            else
                checkvar(maxTolerance,'isfloat(x)&&isscalar(x)&&(x>0)');
            end
            nRoundDigits=-fix(log(maxTolerance)/log(10));            
            %
            sortFieldList=self.getDetermenisticSortFieldList();
            sortableRel=self.getFieldProjection(sortFieldList);
            %
            typeSpecList=self.getFieldTypeSpecList(sortFieldList);
            fIsFloat=@(x)getIsClassFloat(x{1})||...
                (strcmp(x{1},'cell')&&getIsClassFloat(x{2}));
            
            isFloatVec=cellfun(fIsFloat,typeSpecList);
            floatFieldList=sortFieldList(isFloatVec);
            nFloatFields=numel(floatFieldList);
            for iField=1:nFloatFields
                sortableRel.applySetFunc(@(x)roundn(x,-nRoundDigits),...
                    floatFieldList{iField});
            end
            indVec=sortableRel.getSortIndexInternal(sortFieldList,1);
            self.reorderData(indVec);
            function isPos=getIsClassFloat(className)
                isPos=strcmp(className,'double')||strcmp(className,'float');
                
            end
        end        
    end
    methods 
        function varargout=getData(self,varargin)
            import modgen.common.parseparext;
            import modgen.common.parseparams;
            hookPropNameList=getPostDataHookPropNameList(self);
            [getDataPropList,hookPropList]=parseparams(varargin,...
                hookPropNameList);
            if nargout>0
                varargout=cell(1,nargout);
                [~,~,structNameList,isStructNameListSpec]=...
                    parseparext(getDataPropList,...
                    {'structNameList';{};@iscellstr});
                %
                [varargout{:}]=...
                    getData@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                    self,getDataPropList{:});
                if isStructNameListSpec
                    [isThereVec,indLoc]=ismember(self.completeStructNameList,structNameList);
                    if isThereVec(1)
                        varargout{indLoc(1)}=...
                            self.postGetDataHook(varargout{indLoc(1)},hookPropList{:});
                    end
                else
                    varargout{1}=self.postGetDataHook(varargout{1},hookPropList{:});
                end
            else
                getData@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                    self,getDataPropList{:});
            end
        end
    end
    methods (Abstract,Access=protected)
        propNameList=getPostDataHookPropNameList(self)
        SData=postGetDataHook(self,SData,varargin)
        [isOk,reportStr]=isEqualScalarAdjustedInternal(self,varargin)
        fieldList=getDetermenisticSortFieldList(self)
    end
end
