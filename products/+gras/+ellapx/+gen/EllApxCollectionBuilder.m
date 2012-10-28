classdef EllApxCollectionBuilder<gras.ellapx.gen.IEllApxBuilder
    properties (Access=private)
        builderList
    end
    methods
        function calcPrecision=getCalcPrecision(self)
            nBuilders=length(self.builderList);
            calcPrecision=-Inf;
            for iBuilder=1:nBuilders
                calcPrecision=max(calcPrecision,...
                    self.builderList{iBuilder}.getCalcPrecision());
            end
        end        
        function apxType=getApxType(self)
            apxType=gras.ellapx.enums.EApproxType.NotDefined;
        end
        function [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(self)
            apxSchemaName='Mixed';
            apxSchemaDescr=['Different schemas based on content ',...
                'of collection of ellApxBuilders'];
        end
        function self=EllApxCollectionBuilder(builderList)
            import modgen.common.throwerror;
            isOk=all(cellfun(@(x)isa(x,...
                'gras.ellapx.gen.IEllApxBuilder'),builderList))&...
                (cellfun('length',builderList)==1);
            if ~isOk
                throwerror('wrongInput',...
                    ['builderList is expected to contain ',...
                    'instances of type %s'],...
                    'gras.ellapx.gen.IEllApxBuilder');
            end
            self.builderList=builderList;
        end
        function ellTubeRel=getEllTubes(self)
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            logger=Log4jConfigurator.getLogger();
            ellTubeRel=gras.ellapx.smartdb.rels.EllTube();
            nBuilders=length(self.builderList);
            for iBuilder=1:nBuilders
                tStart=tic;
                ellTubeTempRel=self.builderList{iBuilder}.getEllTubes();
                ellTubeRel.unionWith(ellTubeTempRel);
                schemaNamesStr=...
                    ['{',modgen.string.catwithsep(...
                    unique(ellTubeTempRel.approxSchemaName),','),'}'];
                apxTypeStr=['{',modgen.string.catwithsep(...
                    arrayfun(@char,unique(ellTubeTempRel.approxType),...
                    'UniformOutput',false),','),'}'];
                logger.info(...
                    sprintf(['building approximation with ',...
                    'types=%s, schema=%s, #tubes=%d, calc. ',...
                    'precision=%d: done, time elapsed =%s sec.'],...
                    schemaNamesStr,apxTypeStr,...
                    ellTubeTempRel.getNTuples(),...
                    self.builderList{iBuilder}.getCalcPrecision(),...
                    num2str(toc(tStart))));
            end
        end
    end
end
