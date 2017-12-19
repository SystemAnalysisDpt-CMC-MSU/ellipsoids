classdef TEllipsoid < ellipsoid & gras.test.mlunit.TolCounter
    %TELLIPSOID Subclass to count Tol references
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
    methods(Static,Access = private)
        function regQMat = regularize(qMat,absTol)
            self.startTolTest();
            regQMat = regularize@ellipsoid(qMat,absTol);
            self.finishTolTest();
        end
        function clrDirsMat = rm_bad_directions(q1Mat, q2Mat, dirsMat, ...
                absTol)
            self.startTolTest();
            clrDirsMat = rm_bad_directions@ellipsoid(...
                q1Mat, q2Mat, dirsMat, absTol);
            self.finishTolTest();
        end
        function [isBadDirVec,pUniversalVec] = isbaddirectionmat(q1Mat, ...
                q2Mat, dirsMat, absTol)
            self.startTolTest();
            [isBadDirVec,pUniversalVec] = ...
                isbaddirectionmat@ellipsoid(q1Mat, q2Mat,...
                dirsMat, absTol);
            self.finishTolTest();
        end
        function [supArr, bpMat] = rhomat(ellShapeMat, ellCenterVec, ...
                absTol, dirsMat)
            self.startTolTest();
            [supArr, bpMat] = ...
                rhomat@ellipsoid(ellShapeMat, ...
                ellCenterVec, absTol, dirsMat);
            self.finishTolTest();
        end
        function [bpMat, fMat] = ellbndr_3dmat(nPoints, cenVec, qMat, absTol)
            self.startTolTest();
            [bpMat, fMat] = ellbndr_3dmat@ellipsoid(...
                nPoints, cenVec, qMat, absTol);
            self.finishTolTest();
        end
        function [bpMat, fMat] = ellbndr_2dmat(nPoints, cenVec, qMat, absTol)
            self.startTolTest();
            [bpMat, fMat] = ellbndr_2dmat@ellipsoid(...
                nPoints, cenVec, qMat, absTol);
            self.finishTolTest();
        end
    end
    %
    methods
        function self = TEllipsoid(varargin)
            self = self@gras.test.mlunit.TolCounter();
            self = self@ellipsoid(varargin{:});
        end
    end
end

