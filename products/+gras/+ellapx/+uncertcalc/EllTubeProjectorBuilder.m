classdef EllTubeProjectorBuilder<handle
    %IELLTUBEPROJECTOR Summary of this class goes here
    %   Detailed explanation goes here
   
    methods (Static)
        function [projectorObj,staticProjectorObj]=build(confRepoMgr,...
                goodDirSetObj)
            import gras.ellapx.lreachplain.EllTubeDynamicSpaceProjector;
            import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            import gras.ellapx.proj.EllTubeCollectionProjector;
            %
            projSetName=confRepoMgr.getParam(...
                'projectionProps.projSpaceSetName');
            SProjSets=confRepoMgr.getParam(...
                'projectionProps.projSpaceSets');
            projSpaceList=SProjSets.(projSetName);
            
            projMatList=cellfun(@(x)eye(numel(x)),projSpaceList,...
                'UniformOutput',false);
            projMatList=cellfun(@(x,y)x(y,:),projMatList,projSpaceList,...
                'UniformOutput',false);
            %
            for iNum = 1:numel(projSpaceList)
                projMat = double(diag(projSpaceList{iNum}));
                projSpaceList{iNum} = projMat(:,sum(abs(projMat))>0)';
            end
            %
            isDynamicEnabled=confRepoMgr.getParam(...
                'projectionProps.isDynamicProjEnabled');
            isStaticEnabled=confRepoMgr.getParam(...
                'projectionProps.isStaticProjEnabled');
            projectorList=cell(1,2);
            if isDynamicEnabled
                projectorList{2}=EllTubeDynamicSpaceProjector(...
                    projMatList,goodDirSetObj);
            end
            %
            if isStaticEnabled
                staticProjectorObj=EllTubeStaticSpaceProjector(projMatList);
                projectorList{1}=staticProjectorObj;
            end
            isnEmptyVec=~cellfun('isempty',projectorList);
            projectorObj=EllTubeCollectionProjector(...
                projectorList(isnEmptyVec));
        end
    end
end
