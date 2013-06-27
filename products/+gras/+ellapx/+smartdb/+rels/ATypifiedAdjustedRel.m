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
    methods (Abstract,Access=protected)
        [isOk,reportStr]=isEqualAdjustedInternal(self,varargin)
        fieldList=getDetermenisticSortFieldList(self)
    end
end
