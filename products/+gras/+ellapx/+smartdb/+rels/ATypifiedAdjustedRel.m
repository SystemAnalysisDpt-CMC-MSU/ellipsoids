classdef ATypifiedAdjustedRel<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    methods 
        function self=ATypifiedAdjustedRel(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(varargin{:});
        end
        %
        function [isOk,reportStr]=isEqual(self,otherRel,varargin)
            self.checkIfObjectScalar();
            otherRel.checkIfObjectScalar();
            [reg,prop]=modgen.common.parseparams(varargin,...
                {'maxTolerance'});
            self.sortDetermenisticallyInternal(prop{2:end});
            otherRel.sortDetermenisticallyInternal(prop{2:end});
            %
            [isOk,reportStr]=self.isEqualAdjustedInternal(otherRel,...
                reg{:},prop{:});
        end
        function sortDetermenistically(self,varargin)
            self.sortDetermenisticallyInternal(varargin{:});
        end
    end
    methods (Access=protected)
        function sortDetermenisticallyInternal(self,maxTolerance)
            import modgen.common.checkvar;
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
        [isOk,reportStr]=isEqualAdjustedInternal(self,varargin)
        fieldList=getDetermenisticSortFieldList(self)
    end
end
