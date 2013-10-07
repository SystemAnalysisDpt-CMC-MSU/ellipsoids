 function  [ ellTubeRel ]=fCalcTube5(selfBuilderListGetEllTubes1,ellTubeRel, logger, selfBuilderListGetCalcPrecision1)
      tStart=tic;
 
     ellTubeTempRel=selfBuilderListGetEllTubes1;
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
                    selfBuilderListGetCalcPrecision1,...
                    num2str(toc(tStart))));           
 end