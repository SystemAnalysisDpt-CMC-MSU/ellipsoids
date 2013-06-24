classdef MixTubeFortData < handle
    properties(SetAccess=private,GetAccess=public)
        FortranData
        sysDim
        nGoodDirs
        nTimePoints
        ellTubeRel
    end
    %
    methods(Access=private)
        function [atVec, xtMat, ltMat, qtArray] = unpack(self,ytVec)
            k = 0;
            atVec = ytVec(k+1:k+self.sysDim);
            %
            k = k + numel(atVec);
            xtMat = reshape(ytVec(k+1:k+self.sysDim*self.sysDim),...
                self.sysDim, self.sysDim);
            %
            k = k + numel(xtMat);
            ltMat = reshape(ytVec(k+1:k+self.sysDim*self.nGoodDirs),...
                self.sysDim, self.nGoodDirs);
            %
            k = k + numel(ltMat);
            qtArray = zeros(self.sysDim, self.sysDim, self.nGoodDirs);
            %
            for j = 1:self.nGoodDirs
                for i = 1:self.sysDim
                    qtArray(1:i, i, j) = ytVec(k+1:k+i);
                    qtArray(i, 1:i, j) = ytVec(k+1:k+i);
                    k = k + i;
                end
            end
        end
    end
    %
    methods
        function self = MixTubeFortData(fullName)
            import gras.ellapx.smartdb.rels.EllTube
            import gras.ellapx.lreachuncert.MixedIntEllApxBuilder
            import modgen.common.throwerror;
            %
            if ~modgen.system.ExistanceChecker.isFile(fullName)
                throwerror('wrongInput', 'File %s does not exist', ...
                    fullName);
            end
            %
            self.FortranData = load(fullName);
            self.sysDim = self.FortranData.nx;
            self.nGoodDirs = self.FortranData.nl;
            self.nTimePoints = self.FortranData.nt;
            %
            timeVec = self.FortranData.tVec.';
            sTime = timeVec(1);
            calcPrecision = self.FortranData.tolerance;
            %
            qArrayList = cell(1, self.nGoodDirs);
            aMat = zeros(self.sysDim, self.nTimePoints);
            ltGoodDirArray = zeros(self.sysDim, self.nGoodDirs, ...
                self.nTimePoints);
            %
            for iGoodDir = 1:self.nGoodDirs
                qArrayList{iGoodDir} = zeros(self.sysDim, self.sysDim, ...
                    self.nTimePoints);
            end
            %
            for iTimePoint = 1:self.nTimePoints
                iReversedTimePoint = self.nTimePoints + 1 - iTimePoint;
                %
                [atVec, ~, ltMat, qtArray] = self.unpack( ...
                    self.FortranData.yMat(:,iTimePoint));
                %
                aMat(:,iReversedTimePoint) = atVec;
                %
                ltMat = bsxfun(@rdivide,ltMat,realsqrt(sum(ltMat.*ltMat)));
                ltGoodDirArray(:,:,iReversedTimePoint) = ltMat;
                %
                for iGoodDir = 1:self.nGoodDirs
                    qArrayList{iGoodDir}(:,:,iReversedTimePoint) = qtArray(:,:,iGoodDir);
                end
            end
            %
            self.ellTubeRel = EllTube.fromQArrays(qArrayList, aMat, ...
                timeVec, ltGoodDirArray, sTime, ...
                MixedIntEllApxBuilder.APPROX_TYPE, ...
                MixedIntEllApxBuilder.APPROX_SCHEMA_NAME, ...
                MixedIntEllApxBuilder.APPROX_SCHEMA_DESCR, calcPrecision);
            %
        end
        %
        function saveEllTube(self, fileName)
            curPath = fileparts(mfilename('fullpath'));
            fullPath = [curPath filesep '..' filesep '+mlunit' filesep...
                'TestData' filesep fileName];
            ellTubeRel = self.ellTubeRel;
            save(fullPath, 'ellTubeRel');
        end
        %
        function saveConf(self, confName)
            import gras.ellapx.uncertmixcalc.test.conf.*;
            %
            timeVec = self.FortranData.tVec.';
            t0 = timeVec(1);
            t1 = timeVec(end);
            sTime = t0;
            calcPrecision = self.FortranData.tolerance;
            %
            if isempty(self.FortranData.cMat)
                cMat = zeros(self.sysDim,1);
                qMat = 0;
                qVec = 0;
            else
                cMat = self.FortranData.cMat;
                qMat = self.FortranData.qMat;
                qVec = self.FortranData.qVec;
            end
            %
            projSpaceVec = zeros(1,self.sysDim);
            projSpaceVec(1:min(2,self.sysDim)) = 1;
            %
            % save general conf
            %
            confRepoMgr = ConfRepoMgr().getTemplateRepo();
            confRepoMgr.copyConf('default', confName);
            confRepoMgr.selectConf(confName);
            %
            confRepoMgr.setParam('systemDefinitionConfName',confName);
            confRepoMgr.setParam('genericProps.calcTimeLimVec',[t0, t1]);
            confRepoMgr.setParam('genericProps.calcPrecision',calcPrecision);
            confRepoMgr.setParam('projectionProps.projSpaceSetName','set1');
            confRepoMgr.setParam('projectionProps.projSpaceSets.set1',...
                {projSpaceVec});
            confRepoMgr.setParam(['goodDirSelection.methodProps.manual.'...
                'lsGoodDirSetName'],'set1');
            confRepoMgr.setParam(['goodDirSelection.methodProps.manual.'...
                'lsGoodDirSets.set1'], ...
                toCellOfRows(self.FortranData.lMat.'));
            confRepoMgr.setParam('goodDirSelection.selectionTime', sTime);
            confRepoMgr.setParam(['ellipsoidalApxProps.internalApx.'...
                'schemas.uncertMixed.props.mixingStrength'],...
                self.FortranData.alpha);
            confRepoMgr.setParam(['ellipsoidalApxProps.internalApx.'...
                'schemas.uncertMixed.props.mixingProportions'],...
                toCellOfRows(ones(self.nGoodDirs)/double(self.nGoodDirs)));
            %
            % save system definition
            %
            sysDefRepoMgr = sysdef.ConfRepoMgr().getTemplateRepo();
            sysDefRepoMgr.copyConf('default', confName);
            sysDefRepoMgr.selectConf(confName);
            %
            sysDefRepoMgr.setParam('dim', {double(self.sysDim)});
            sysDefRepoMgr.setParam('time_interval.t0', {t0});
            sysDefRepoMgr.setParam('time_interval.t1', {t1});
            sysDefRepoMgr.setParam('At',...
                toCellOfStrings(-self.FortranData.aMat));
            sysDefRepoMgr.setParam('Bt',...
                toCellOfStrings(-self.FortranData.bMat));
            sysDefRepoMgr.setParam('Ct',toCellOfStrings(-cMat));
            sysDefRepoMgr.setParam('initial_set.Q',...
                toCellOfRows(self.FortranData.mMat));
            sysDefRepoMgr.setParam('initial_set.a',...
                {self.FortranData.mVec});
            sysDefRepoMgr.setParam('control_restriction.Q',...
                toCellOfStrings(self.FortranData.pMat));
            sysDefRepoMgr.setParam('control_restriction.a',...
                toCellOfStrings(self.FortranData.pVec));
            sysDefRepoMgr.setParam('disturbance_restriction.Q',...
                toCellOfStrings(qMat));
            sysDefRepoMgr.setParam('disturbance_restriction.a',...
                toCellOfStrings(qVec));
            sysDefRepoMgr.setParam('description', '');
            %
            function dCVec = toCellOfRows(dMat)
                [nRows, nCols] = size(dMat);
                dCVec = mat2cell(dMat,ones(1,nRows),nCols);
            end
            %
            function dCVec = toCellOfStrings(dMat)
                dCVec = toCellOfRows(dMat);
                dCVec = cellfun(@(rVec) num2str(rVec,'%f '), dCVec, ...
                    'UniformOutput', false);
            end
        end
    end
    
end