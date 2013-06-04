classdef EllApxBuilder<gras.ellapx.uncertcalc.EllApxBuilder
    %
    methods (Static,Access=public)
        function fHandle=getApxBuilder(apxName,schemaName)
            import gras.ellapx.*
            fHandle=function_handle.empty;
            switch apxName
                case 'internalApx'
                    switch schemaName
                        case 'uncertMixed'
                            fHandle=@lreachuncert.MixedIntEllApxBuilder;
                    end
            end
            if isempty(fHandle)
                modgen.common.throwerror('wrongInput',...
                    'Unsupported schema: %s.%s',apxName,schemaName);
            end
        end
    end
    %
    methods
        function [ellTubeRel,ellUnionTubeRel]=build(self)
            import gras.ellapx.smartdb.rels.EllUnionTubeNotTight;
            ellTubeRel=self.ellTubeBuilder.getEllTubes();
            ellTubeRel.scale(@self.getScaleFactorByApxType,{'approxType'});
            ellUnionTubeRel=EllUnionTubeNotTight.fromEllTubes(ellTubeRel);
        end
        %
        function self=EllApxBuilder(confRepoMgr,pDynObj,goodDirSetObj)
            self=self@gras.ellapx.uncertcalc.EllApxBuilder(confRepoMgr,...
                pDynObj,goodDirSetObj);
            %
            calcTimeLimVec=confRepoMgr.getParam(...
                'genericProps.calcTimeLimVec');
            calcPrecision=confRepoMgr.getParam(...
                'genericProps.calcPrecision');
            %
            fBuildOne=@(x,y)self.buildOneApx(pDynObj,...
                goodDirSetObj,calcTimeLimVec,calcPrecision,x,y);
            %
            intBuilderList=self.buildApxGroupGeneric(...
                'internalApx',confRepoMgr,fBuildOne);
            extBuilderList=self.buildApxGroupGeneric(...
                'externalApx',confRepoMgr,fBuildOne);
            extIntBuilderList=self.buildApxGroupGeneric(...
                'extIntApx',confRepoMgr,fBuildOne);
            %
            self.ellTubeBuilder=gras.ellapx.uncertmixcalc.EllApxCollectionBuilder(...
                [intBuilderList,extBuilderList,extIntBuilderList]);
        end
    end
end