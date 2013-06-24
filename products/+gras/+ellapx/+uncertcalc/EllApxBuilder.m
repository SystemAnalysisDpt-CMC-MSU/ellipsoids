classdef EllApxBuilder<handle
    properties
        ellTubeBuilder
        intApxScaleFactor
        extApxScaleFactor
    end
    %
    methods (Access=protected)
        function scaleFactor=getScaleFactorByApxType(self,apxType)
            import gras.ellapx.enums.EApproxType;
            switch apxType
                case EApproxType.Internal
                    scaleFactor=self.intApxScaleFactor;
                case EApproxType.External
                    scaleFactor=self.extApxScaleFactor;
                otherwise
                    scaleFactor=1;
            end
        end
    end
    %
    methods (Static,Access=public)
        function fHandle=getApxBuilder(apxName,schemaName)
            import gras.ellapx.*
            fHandle=function_handle.empty;
            switch apxName
                case 'internalApx'
                    switch schemaName
                        case 'noUncertSqrtQ'
                            fHandle=@lreachplain.IntEllApxBuilder;
                        case 'noUncertJustQ'
                            fHandle=@lreachplain.IntProperEllApxBuilder;
                        case 'uncertMixed'
                            fHandle=@lreachuncert.MixedIntEllApxBuilder;
                    end
                case 'externalApx'
                    switch schemaName
                        case 'justQ'
                            fHandle=@lreachplain.ExtEllApxBuilder;
                    end
                case 'extIntApx'
                    switch schemaName
                        case 'uncert'
                            fHandle=@lreachuncert.ExtIntEllApxBuilder;
                    end
            end
            if isempty(fHandle)
                modgen.common.throwerror('wrongInput',...
                    'Unsupported schema: %s.%s',apxName,schemaName);
            end
        end
        %
        function builderList=buildApxGroupGeneric(apxName,confRepoMgr,...
                fBuildOne)
            import gras.ellapx.uncertcalc.EllApxBuilder
            %
            builderList={};
            apxPath=['ellipsoidalApxProps.',apxName];
            %
            if ~getParamIfExists([apxPath,'.isEnabled'],false)
                return
            end
            %
            schemasPath=[apxPath,'.schemas'];
            schemaNameList=fieldnames(confRepoMgr.getParam(schemasPath));
            nSchemas=length(schemaNameList);
            %
            builderList=cell(1,nSchemas);
            for iSchema=1:nSchemas
                schemaName=schemaNameList{iSchema};
                schemaPath=[schemasPath,'.',schemaName];
                if confRepoMgr.getParam([schemaPath,'.isEnabled'])
                    builderList{iSchema}=fBuildOne(...
                        EllApxBuilder.getApxBuilder(apxName,schemaName),...
                        getParamIfExists([schemaPath,'.props'],struct));
                end
            end
            builderList=builderList(~cellfun(@isempty,builderList));
            %
            function value=getParamIfExists(paramPath,default)
                if confRepoMgr.isParam(paramPath);
                    value=confRepoMgr.getParam(paramPath);
                else
                    value=default;
                end
            end
        end
        %
        function builderObj=buildOneApx(pDynObj,goodDirSetObj,...
                calcTimeLimVec,calcPrecision,fHandle,SProps)
            paramsCMat = [fieldnames(SProps),struct2cell(SProps)].';
            builderObj=fHandle(pDynObj,goodDirSetObj,calcTimeLimVec,...
                calcPrecision,paramsCMat{:});
        end
    end
    %
    methods
        function [ellTubeRel,ellUnionTubeRel]=build(self)
            import gras.ellapx.smartdb.rels.EllUnionTube;
            ellTubeRel=self.ellTubeBuilder.getEllTubes();
            ellTubeRel.scale(@self.getScaleFactorByApxType,{'approxType'});
            ellUnionTubeRel=EllUnionTube.fromEllTubes(ellTubeRel);
        end
        %
        function self=EllApxBuilder(confRepoMgr,pDynObj,goodDirSetObj)
            import gras.ellapx.uncertcalc.EllApxBuilder;
            %
            calcTimeLimVec=confRepoMgr.getParam(...
                'genericProps.calcTimeLimVec');
            calcPrecision=confRepoMgr.getParam(...
                'genericProps.calcPrecision');
            %
            fBuildOne=@(x,y)EllApxBuilder.buildOneApx(pDynObj,...
                goodDirSetObj,calcTimeLimVec,calcPrecision,x,y);
            %
            intBuilderList=EllApxBuilder.buildApxGroupGeneric(...
                'internalApx',confRepoMgr,fBuildOne);
            extBuilderList=EllApxBuilder.buildApxGroupGeneric(...
                'externalApx',confRepoMgr,fBuildOne);
            extIntBuilderList=EllApxBuilder.buildApxGroupGeneric(...
                'extIntApx',confRepoMgr,fBuildOne);
            %
            self.ellTubeBuilder=gras.ellapx.gen.EllApxCollectionBuilder(...
                [intBuilderList,extBuilderList,extIntBuilderList]);
            %
            self.intApxScaleFactor=getParamIfExists(...
                'ellipsoidalApxProps.internalApx.dispScaleFactor',1);
            self.extApxScaleFactor=getParamIfExists(...
                'ellipsoidalApxProps.externalApx.dispScaleFactor',1);
            %
            function value=getParamIfExists(paramPath,default)
                if confRepoMgr.isParam(paramPath);
                    value=confRepoMgr.getParam(paramPath);
                else
                    value=default;
                end
            end
        end
    end
end