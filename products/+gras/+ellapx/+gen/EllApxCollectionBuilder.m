classdef EllApxCollectionBuilder<gras.ellapx.gen.IEllApxBuilder
    properties (Access=private)
        builderList
    end
    methods(Static)
        function fCalcTube(ellTubeTempRel, CalcPrec)
              import gras.ellapx.uncertcalc.log.Log4jConfigurator;
               logger=Log4jConfigurator.getLogger();
                tStart=tic;
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
                    CalcPrec,...
                    num2str(toc(tStart))));
            
        end    
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
            ellTubeRel=gras.ellapx.smartdb.rels.EllTube();
            nBuilders=length(self.builderList);
            
            pCalc=elltool.pcalc.ParCalculator();
             
            ellTubeTempRelCVec=cell(1,nBuilders);
            ellTubeTempRelCVec{:}=self.builderList{1:nBuilders}.getEllTubes();
            
            CalcPrecCVec=cell(1,nBuilders);
            CalcPrecCVec{:}=self.builderList{1:nBuilders}.getCalcPrecision();
            
           
            
            ellTubeRel=smartdb.relationoperators.union(ellTubeTempRelCVec{:});

            pCalc.eval(@gras.ellapx.gen.EllApxCollectionBuilder.fCalcTube,...
              ellTubeTempRelCVec,CalcPrecCVec);

        end
    end
end
