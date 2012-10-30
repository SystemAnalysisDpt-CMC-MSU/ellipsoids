classdef EllApxBuilder<handle
    %IELLTUBEPROJECTOR Summary of this class goes here
    %   Detailed explanation goes here
    properties
        ellTubeBuilder
        intApxScaleFactor
        extApxScaleFactor
    end
    %   
    methods (Access=private)
        function scaleFactor=getScaleFactorByApxType(self,apxType)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            if apxType==EApproxType.Internal
                scaleFactor=self.intApxScaleFactor;
            elseif apxType==EApproxType.External
                scaleFactor=self.extApxScaleFactor;
            else
                scaleFactor=1;
            end
        end        
    end
    methods (Static,Access=private)
        function builderList=buildApxGroupGeneric(apxBranchName,...
                confRepoMgr,schemaNameList,classNameList,fBuildOne)
            nInternalSchemas=length(schemaNameList);
            nSchemas=nInternalSchemas;
            builderList=cell(1,nSchemas);
            isBuilderActiveVec=false(1,nSchemas);
            if confRepoMgr.getParam([apxBranchName,'.isEnabled']);
                for iSchema=1:nInternalSchemas
                    schemaName=schemaNameList{iSchema};
                    className=classNameList{iSchema};
                    branchName=[apxBranchName,'.schemas.',schemaName];
                    if confRepoMgr.getParam([branchName,'.isEnabled']);
                        isBuilderActiveVec(iSchema)=true;
                        builderList{iSchema}=fBuildOne(...
                            [branchName,'.props'],className);
                    end
                end
            end
            builderList=builderList(isBuilderActiveVec);
        end
        function builderObj=buildOneInternalApx(confRepoMgr,...
                pDefObj,goodDirSetObj,...
                calcTimeLimVec,calcPrecision,propBranchName,className)
            %
            sMethodName=confRepoMgr.getParam([propBranchName,...
                '.selectionMethodForSMatrix']);
            builderObj=feval(className,pDefObj,goodDirSetObj,...
                calcTimeLimVec,calcPrecision,sMethodName);
        end
        %
        function builderObj=buildOneExtIntApx(confRepoMgr,...
                pDefObj,goodDirSetObj,...
                calcTimeLimVec,calcPrecision,propBranchName,className)
            %
            sMethodName=confRepoMgr.getParam([propBranchName,...
                '.selectionMethodForSMatrix']);
            minQSqrtMatEig=confRepoMgr.getParam([propBranchName,...
                '.minQSqrtMatEig']);
            %
            builderObj=feval(className,pDefObj,goodDirSetObj,...
                calcTimeLimVec,calcPrecision,sMethodName,...
                minQSqrtMatEig);
        end        
        %
        function builderObj=buildOneExternalApx(~,...
                pDefObj,goodDirSetObj,...
                calcTimeLimVec,calcPrecision,~,className)
            builderObj=feval(className,pDefObj,goodDirSetObj,...
                calcTimeLimVec,calcPrecision);
        end
    end
    methods
        function self=EllApxBuilder(confRepoMgr,pDefObj,goodDirSetObj)
            import gras.ellapx.uncertcalc.EllApxBuilder;
            %% Define constants
            INTERNAL_SCHEMA_NAME_LIST={'noUncertSqrtQ','noUncertJustQ',...
                'uncert'};
            INTERNAL_CLASS_NAME_LIST={...
                'gras.ellapx.lreachplain.IntEllApxBuilder',...
                'gras.ellapx.lreachplain.IntProperEllApxBuilder',...
                'gras.ellapx.lreachuncert.IntEllApxBuilder'};
            %
            EXTERNAL_SCHEMA_NAME_LIST={'justQ'};
            EXTERNAL_CLASS_NAME_LIST={...
                'gras.ellapx.lreachplain.ExtEllApxBuilder'};
            %
            EXTINT_SCHEMA_NAME_LIST={'uncert'};
            EXTINT_CLASS_NAME_LIST={...
                'gras.ellapx.lreachuncert.ExtIntEllApxBuilder'};            
            %
            calcTimeLimVec=confRepoMgr.getParam(...
                'genericProps.calcTimeLimVec');
            %
            calcPrecision=confRepoMgr.getParam(...
                'genericProps.calcPrecision');
            %% Build internal approximations
            fBuildIntOne=@(x,y)EllApxBuilder.buildOneInternalApx(...
                confRepoMgr,pDefObj,goodDirSetObj,calcTimeLimVec,...
                calcPrecision,x,y);
            intBuilderList=EllApxBuilder.buildApxGroupGeneric(...
                'ellipsoidalApxProps.internalApx',confRepoMgr,...
                INTERNAL_SCHEMA_NAME_LIST,INTERNAL_CLASS_NAME_LIST,...
                fBuildIntOne);
            %% Build external approximations
            fBuildExtOne=@(x,y)EllApxBuilder.buildOneExternalApx(...
                confRepoMgr,pDefObj,goodDirSetObj,calcTimeLimVec,...
                calcPrecision,x,y);
            extBuilderList=EllApxBuilder.buildApxGroupGeneric(...
                'ellipsoidalApxProps.externalApx',confRepoMgr,...
                EXTERNAL_SCHEMA_NAME_LIST,EXTERNAL_CLASS_NAME_LIST,...
                fBuildExtOne);
            %%
            %% Build external-internal approximations
            fBuildExtIntOne=@(x,y)EllApxBuilder.buildOneExtIntApx(...
                confRepoMgr,pDefObj,goodDirSetObj,calcTimeLimVec,...
                calcPrecision,x,y);
            extIntBuilderList=EllApxBuilder.buildApxGroupGeneric(...
                'ellipsoidalApxProps.extIntApx',confRepoMgr,...
                EXTINT_SCHEMA_NAME_LIST,EXTINT_CLASS_NAME_LIST,...
                fBuildExtIntOne);
            %
            self.ellTubeBuilder=gras.ellapx.gen.EllApxCollectionBuilder(...
                [intBuilderList,extBuilderList,extIntBuilderList]);
            %
            self.intApxScaleFactor=confRepoMgr.getParam(...
                'ellipsoidalApxProps.internalApx.dispScaleFactor');
            self.extApxScaleFactor=confRepoMgr.getParam(...
                'ellipsoidalApxProps.externalApx.dispScaleFactor');
            %
        end
        function [ellTubeRel,ellUnionTubeRel]=build(self)
            import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            ellTubeRel=self.ellTubeBuilder.getEllTubes();
            ellTubeRel.scale(...
                @(apxType)getScaleFactorByApxType(self,apxType),...
                {'approxType'});
            %
            ellUnionTubeRel=EllUnionTube.fromEllTubes(ellTubeRel);
            
        end
    end
end
        