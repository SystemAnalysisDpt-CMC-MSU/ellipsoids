classdef TGenEllipsoid < elltool.core.GenEllipsoid & ...
        gras.test.mlunit.TolCounter
    %TGENELLIPSOID Subclass to count Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods (Access = protected)
        function beforeGetAbsTol(self)
            self.incAbsTolCount();
        end
        function beforeGetRelTol(self)
            self.incRelTolCount();
        end
    end
    %
    methods (Static,Access=private)
        function [isOk, pPar] = getIsGoodDirForMat(ellQ1Mat, ellQ2Mat, ...
               dirVec, absTol)
            self.startTolTest();
            [isOk, pPar] = getIsGoodDirForMat@elltool.core.GenEllipsoid(...
                ellQ1Mat, ellQ2Mat, dirVec, absTol);
            self.finishTolTest();
        end
        function sqMat = findSqrtOfMatrix(qMat, absTol)
            self.startTolTest();
            sqMat = findSqrtOfMatrix@elltool.core.GenEllipsoid(qMat, absTol);
            self.finishTolTest();
        end
        function isBigger = checkBigger(ellObj1, ellObj2, nDimSpace, absTol)
            self.startTolTest();
            isBigger = checkBigger@elltool.core.GenEllipsoid(ellObj1, ...
                ellObj2, nDimSpace, absTol);
            self.finishTolTest();
        end
        function [orthBasMat, rank] = findBasRank(qMat, absTol)
            self.startTolTest();
            [orthBasMat, rank] = findBasRank@elltool.core.GenEllipsoid(...
                qMat, absTol);
            self.finishTolTest();
        end
        function [spaceBasMat, oSpaceBasMat, spaceIndVec, oSpaceIndVec] = ...
                findSpaceBas(dirMat, absTol)
            self.startTolTest();
            [spaceBasMat, oSpaceBasMat,spaceIndVec,oSpaceIndVec] = ...
                findSpaceBas@elltool.core.GenEllipsoid(dirMat, absTol);
            self.finishTolTest();
        end
        function resQMat = findDiffEaND(ellQ1Mat, ellQ2Mat, curDirVec, ...
                absTol)
            self.startTolTest();
            resQMat = findDiffEaND@elltool.core.GenEllipsoid(ellQ1Mat, ...
                ellQ2Mat, curDirVec, absTol);
            self.finishTolTest();
        end
        function [resEllMat] = findDiffFC(fMethod, ellQ1Mat, ellQ2Mat, ...
                curDirVec, absTol)
            self.startTolTest();
            [resEllMat] = findDiffFC@elltool.core.GenEllipsoid(fMethod, ...
                ellQ1Mat, ellQ2Mat, curDirVec, absTol);
            self.finishTolTest();
        end
        function [resQMat, diagQVec] = findDiffINFC(fMethod, ellObj1, ...
            ellObj2, curDirVec, isInf1Vec, isInfForFinBas, absTol)
            self.startTolTest();
            [resQMat, diagQVec] = findDiffINFC@elltool.core.GenEllipsoid(...
                fMethod, ellObj1, ellObj2, curDirVec, isInf1Vec, ...
                isInfForFinBas, absTol);
            self.finishTolTest();
        end
        function resQMat = findDiffIaND(ellQ1Mat, ellQ2Mat, curDirVec, ...
                absTol)
            self.startTolTest();
            resQMat = findDiffIaND@elltool.core.GenEllipsoid(ellQ1Mat, ...
                ellQ2Mat, curDirVec, absTol);
            self.finishTolTest();
        end
    end
    %
    methods
        function self = TGenEllipsoid(varargin)
            self = self@gras.test.mlunit.TolCounter();
            self = self@elltool.core.GenEllipsoid(varargin{:});
        end
    end
end

