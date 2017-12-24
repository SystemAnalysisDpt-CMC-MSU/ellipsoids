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
            beforeGetAbsTol@ellipsoid(self);
            self.incAbsTolCount();
        end
        function beforeGetRelTol(self)
            beforeGetRelTol@ellipsoid(self);
            self.incRelTolCount();
        end
    end
    %
    methods(Static)
        function ellArr = fromRepMat(varargin)
            import modgen.common.checkvar;
            if nargin>3
                indVec=[1:2,4:nargin];
                sizeVec=varargin{3};
            else
                sizeVec=varargin{nargin};
                indVec=1:nargin-1;
            end
            ellArr = repMat(elltool.core.test.mlunit.TEllipsoid(...
                varargin{indVec}), sizeVec);
        end
        function ellArr = fromStruct(SEllArr)
            function ell = struct2Ell(SEll)
                if (isfield(SEll, 'absTol'))
                    SProp = rmfield(SEll, {'shapeMat', 'centerVec'});
                    propNameValueCMat = [fieldnames(SProp), ...
                        struct2cell(SProp)].';
                    ell = elltool.core.test.mlunit.TEllipsoid(...
                        SEll.centerVec.', SEll.shapeMat, ...
                        propNameValueCMat{:});
                else
                    ell = elltool.core.test.mlunit.TEllipsoid(...
                        SEll.centerVec.', SEll.shapeMat);
                end
            end
            
            for iEll = numel(SEllArr) : -1 : 1
                ellArr(iEll) = struct2Ell(SEllArr(iEll));
            end
            ellArr = reshape(ellArr, size(SEllArr));
        end
    end
    %
    methods (Static, Access = protected)
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

