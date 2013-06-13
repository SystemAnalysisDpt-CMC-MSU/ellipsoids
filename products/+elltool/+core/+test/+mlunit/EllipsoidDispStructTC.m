classdef EllipsoidDispStructTC < elltool.core.test.mlunit.ADispStructTC
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods
        function self = EllipsoidDispStructTC(varargin)
            self = self@elltool.core.test.mlunit.ADispStructTC(varargin{:});
        end
        
        function self = testToStruct(self)
            ell = ellipsoid([1, 1]', eye(2));
            ellStruct = struct('shapeMat', eye(2), 'centerVec', [1, 1]);
            toStructTest(self, ell, ellStruct, false, true);
            
            ell2 = ellipsoid();
            ell2Struct = struct('shapeMat', [], 'centerVec', []);
            toStructTest(self, ell2, ell2Struct, false, true);
            toStructTest(self, ell, ell2Struct, false, false);
            
            ellStruct = struct('shapeMat', eye(2), 'centerVec', [1, 1],...
                'absTol', 1e-7, 'relTol', 1e-5,...
                'nPlot2dPoints', 200, 'nPlot3dPoints', 200);
            toStructTest(self, ell, ellStruct, true, true);
            
            ellStruct = struct('shapeMat', eye(2), 'centerVec', [2, 1]);
            toStructTest(self, ell, ellStruct, false, false);
            
            for iEll = 125 : -1 : 1
                ellArr(iEll) = ellipsoid(1, 1); 
            end
            ellArr = reshape(ellArr, [5 5 5]);
            ellArrStruct = struct('shapeMat', num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5)));
            toStructTest(self, ellArr, ellArrStruct, false, true);
            ellArr(1) = ellipsoid();
            toStructTest(self, ellArr, ellArrStruct, false, false);
        end
        
        function self = testFromStruct(self)
            ell = ellipsoid([1, 1]', eye(2));
            ellStruct = struct('shapeMat', eye(2), 'centerVec', [1, 1]);
            fromStructTest(self, ellStruct, ell, ellipsoid(), true);
            
            ell2Struct = struct('shapeMat', eye(2), 'centerVec', [1, 1],...
                'absTol', 1e-8, 'relTol', 1e-4,...
                'nPlot2dPoints', 300, 'nPlot3dPoints', 100);
            ell2 = ellipsoid([1, 1]', eye(2), 'absTol', 1e-8,...
                'relTol', 1e-4, 'nPlot2dPoints', 300, ...
                'nPlot3dPoints', 100);
            fromStructTest(self, ell2Struct, ell2, ellipsoid(), true);
            
            ell3 = ellipsoid();
            fromStructTest(self, ell2Struct, ell3, ellipsoid(), false);
            fromStructTest(self, ell2Struct, ell, ellipsoid(), false);
            
            for iEll = 125 : -1 : 1
                ellArr(iEll) = ellipsoid(1, 1); 
            end
            ellArr = reshape(ellArr, [5 5 5]);
            ellArrStruct = struct('shapeMat', num2cell(ones(5, 5, 5)),...
                'centerVec', num2cell(ones(5, 5, 5)));
            fromStructTest(self, ellArrStruct, ellArr, ellipsoid(), true);
            ellArr(1) = ellipsoid();
            fromStructTest(self, ellArrStruct, ellArr, ellipsoid(), false);
        end
        
        function self = testDisplay(self)
            ell = ellipsoid([1, 1]', eye(2));
            patternsCVec = {'Ellipsoid shape matrix.', ...
                            'ellipsoid object',...
                            'centerVec',...
                            'shapeMat'};
            displayTest(self, ell, patternsCVec, true);
            
            ell = ellipsoid();
            displayTest(self, ell, patternsCVec, true);
            
            ell = ellipsoid([1, 2]', eye(2));
            displayTest(self, ell, patternsCVec, true);
            
            ellArr = ellipsoid.fromStruct(struct('shapeMat', num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5))));
            displayTest(self, ellArr, patternsCVec, true);
            
            ell = [ell, ell];
            patternsCVec = horzcat(patternsCVec, 'ObjArr(1)');
            displayTest(self, ell, patternsCVec, true);
            hp = hyperplane();
            displayTest(self, hp, patternsCVec, false);
        end
        
        function self = testEq(self)
            ell = ellipsoid([1, 1]', eye(2));
            eqTest(self, ell, ell, true);
            
            ell2 = ellipsoid();
            eqTest(self, ell2, ell2, true);
            
            ell3 = ellipsoid([1, 2]', eye(2));
            eqTest(self, ell3, ell3, true);
            eqTest(self, ell2, ell3, false);
            eqTest(self, ell2, ell, false);
            
            ellArr = ellipsoid.fromStruct(struct('shapeMat', num2cell(ones(5, 5, 5)), ...
                                          'centerVec', num2cell(ones(5, 5, 5))));
            eqTest(self, ellArr, ellArr, true);
            ellArr2 = ellArr;
            ellArr2(1, 1, 1) = ellipsoid();
            eqTest(self, ellArr, ellArr2, false);
            
            ell = [ell ell];
            eqTest(self, ell, ell, true);
            eqTest(self, ell, ellArr2(1, 1:2, 1), false);
        end
    end
end