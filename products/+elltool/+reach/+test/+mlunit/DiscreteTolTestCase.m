classdef DiscreteTolTestCase < mlunitext.test_case
    %DISCRETETOLTESTCASE Test to count Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    properties (Access = private)
        nDirs
        aMat
        bMat
        gMat
        x0EllObj
        uEllObj
        vEllObj
    end
    methods
        function self = DiscreteTolTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self.set_up_param();
        end
        function self = set_up_param(self)
            self.nDirs = 4;
            self.aMat = [0.9 1;0 0.7];
            self.bMat = [1 0; 0 1];
            self.gMat = [0.4 0.02; 0.02 0.4];
            self.x0EllObj = ell_unitball(2);
            self.uEllObj = ell_unitball(2);
            self.vEllObj = ell_unitball(2);
        end
        function testTolDiscrete(self)
            sys = elltool.linsys.LinSysDiscrete(self.aMat, self.bMat, ...
                self.uEllObj, self.gMat, self.vEllObj, [], [], 'd');
            phiVec = linspace(0, pi, self.nDirs);
            dirsMat = [cos(phiVec); sin(phiVec)];
            nSteps = 10;
            elltool.reach.test.mlunit.TReachDiscrete(sys, self.x0EllObj, ...
                dirsMat, [0 nSteps], 'isRegEnabled',true, 'isJustCheck', ...
                false ,'regTol',1e-4);
        end
    end
end