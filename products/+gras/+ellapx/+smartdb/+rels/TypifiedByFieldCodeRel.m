classdef TypifiedByFieldCodeRel<smartdb.relations.ATypifiedStaticRelation
    methods
        function self=TypifiedByFieldCodeRel(varargin)
            self=self@smartdb.relations.ATypifiedStaticRelation(varargin{:});
            
        end
    end
    methods (Access=protected)
        function initialize(self,varargin)
            import gras.ellapx.smartdb.F;
            CODE_PREFIX='FCODE_';
            [~,propDefCMat]=self.getFieldDefsByRegExp('^FDEF_');
            propNameCVec=self.getFieldDefsByRegExp(['^',CODE_PREFIX]);
            firstCodeValueInd=length(CODE_PREFIX)+1;
            codeCVec=cellfun(@(x)x(firstCodeValueInd:end),propNameCVec,...
                'UniformOutput',false);
            %
            [fieldNameList,fieldDescrList,fieldTypeSpecList]=...
                F.getDefs(codeCVec);
            propDefCMat=[fieldNameList fieldDescrList fieldTypeSpecList;...
                propDefCMat];
            %
            self.fieldNameList=propDefCMat(:,1).';
            self.fieldDescrList=propDefCMat(:,2).';
            self.fieldTypeSpecList=propDefCMat(:,3).';
        end
    end
end