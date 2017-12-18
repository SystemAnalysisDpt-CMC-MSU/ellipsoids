classdef ContinuousTolTestCase < mlunitext.test_case
    %CONTINUOUSTOLTESTCASE Test to count Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    properties (Access = private)
        firstACMat;
        secondAMat
        firstBMat
        secondBMat
        firstSUBounds
        secondSUBounds
        timeVec
        dirsMat;
        x0EllObj
        firstSys
        secondSys
    end
    methods
        function self = ContinuousTolTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self.set_up_param();
        end
        function self = set_up_param(self)
            self.firstACMat = {'sin(0.3*t)' '-0.22' '0'; '0' '-1' '0'; ...
                '-0.5' '1' 'cos(0.2*t)'};
            self.secondAMat = [0 0 1; 0 0 0; -4 0 0];
            self.firstBMat = [0 1 1; 1 1 0; 1 0 1];
            self.secondBMat = [1 0; 0 0; 0 1];
            self.firstSUBounds = ellipsoid([1 0 0; 0 2 0; 0 0 2]);
            self.secondSUBounds.center = [0; 0];
            self.secondSUBounds.shape = {'2 - sin(2*t)' '0'; '0' '2- cos(3*t)'};
            self.timeVec  = [0 2];
            self.dirsMat = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0].';
            self.x0EllObj = ell_unitball(3);
            self.firstSys = elltool.linsys.LinSysContinuous(...
                self.firstACMat, self.firstBMat, self.firstSUBounds);
            self.secondSys = elltool.linsys.LinSysContinuous(...
                self.secondAMat, self.secondBMat, self.secondSUBounds);
        end
        function testTolContinuous(self)
            firstRsObj = elltool.reach.test.mlunit.TReachContinuous(self.firstSys, ...
                self.x0EllObj, self.dirsMat, self.timeVec, ...
                'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
            firstRsObj.evolve(5, self.secondSys);
        end
    end
end