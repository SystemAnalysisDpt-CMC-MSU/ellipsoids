classdef TEllApxBuilder < gras.ellapx.uncertcalc.EllApxBuilder
    %TELLAPXBUILDER Subclass to choose handles that are tested for absTol,
    %relTol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods (Static, Access = public)
        function fHandle = getApxBuilder(apxName,schemaName)
            import gras.ellapx.*
            fHandle = function_handle.empty;
            switch apxName
                case 'internalApx'
                    switch schemaName
                        case 'noUncertSqrtQ'
                            fHandle = @lreachplain.test.TIntEllApxBuilder;
                        case 'noUncertJustQ'
                            fHandle = @lreachplain.test.TIntProperEllApxBuilder;
                        case 'uncertMixed'
                            fHandle = @lreachuncert.test.TMixedIntEllApxBuilder;
                    end
                case 'externalApx'
                    switch schemaName
                        case 'justQ'
                            fHandle = @lreachplain.test.TExtEllApxBuilder;
                    end
                case 'extIntApx'
                    switch schemaName
                        case 'uncert'
                            fHandle = @lreachuncert.test.TExtIntEllApxBuilder;
                    end
            end
            if isempty(fHandle)
                modgen.common.throwerror('wrongInput', ...
                    'Unsupported schema: %s.%s', apxName, schemaName);
            end
        end
        %
        function builderList=buildApxGroupGeneric(apxName,confRepoMgr,...
                fBuildOne)
            import gras.ellapx.uncertcalc.test.TEllApxBuilder
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
                        TEllApxBuilder.getApxBuilder(apxName,schemaName),...
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
                calcTimeLimVec,relTol,absTol,fHandle,SProps)
            paramsCMat = [fieldnames(SProps),struct2cell(SProps)].';
            builderObj=fHandle(pDynObj,goodDirSetObj,calcTimeLimVec,...
                relTol,absTol,...
                paramsCMat{:});
        end
    end
    %
    methods
        function self = TEllApxBuilder(confRepoMgr,pDynObj,goodDirSetObj)
            import gras.ellapx.uncertcalc.test.TEllApxBuilder;
            %
            self = self@gras.ellapx.uncertcalc.EllApxBuilder(...
                confRepoMgr,pDynObj,goodDirSetObj);
            %
            calcTimeLimVec=confRepoMgr.getParam(...
                'genericProps.calcTimeLimVec');
            relTol=confRepoMgr.getParam(...
                'genericProps.relTol');            
            absTol=confRepoMgr.getParam(...
                'genericProps.absTol');
            %
            fBuildOne=@(x,y)TEllApxBuilder.buildOneApx(pDynObj,...
                goodDirSetObj,calcTimeLimVec,relTol,absTol,x,y);
            %
            intBuilderList=TEllApxBuilder.buildApxGroupGeneric(...
                'internalApx',confRepoMgr,fBuildOne);
            extBuilderList=TEllApxBuilder.buildApxGroupGeneric(...
                'externalApx',confRepoMgr,fBuildOne);
            extIntBuilderList=TEllApxBuilder.buildApxGroupGeneric(...
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