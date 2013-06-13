classdef HyperplaneDispStructTC < elltool.core.test.mlunit.ADispStructTC
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods
        function self = HyperplaneDispStructTC(varargin)
            self = self@elltool.core.test.mlunit.ADispStructTC(varargin{:});
        end
        
        function self = testToStruct(self)
            hp = hyperplane([1, 1, 2]', 3);
            hpStruct = struct('normal', [1, 1, 2]', 'shift', 3);
            hpStruct.shift = hpStruct.shift/norm(hpStruct.normal);
            hpStruct.normal = hpStruct.normal/norm(hpStruct.normal);
            toStructTest(self, hp, hpStruct, false, true);
            
            hp2 = hyperplane();
            hp2Struct = struct('normal', [], 'shift', []);
            toStructTest(self, hp2, hp2Struct, false, true);
            toStructTest(self, hp, hp2Struct, false, false);
            
            hpStruct = struct('normal', [1, 1, 2]', 'shift', 3, 'absTol', 1e-7);
            hpStruct.shift = hpStruct.shift/norm(hpStruct.normal);
            hpStruct.normal = hpStruct.normal/norm(hpStruct.normal);
            toStructTest(self, hp, hpStruct, true, true);
            
            hp = hyperplane([1, 1, 2]', 2);
            toStructTest(self, hp, hpStruct, false, false);
            
            for iHp = 125 : -1 : 1
                hpArr(iHp) = hyperplane(1, 1); 
            end
            hpArr = reshape(hpArr, [5 5 5]);
            hpArrStruct = struct('normal', num2cell(ones(5, 5, 5)), ...
                'shift', num2cell(ones(5, 5, 5)));
            toStructTest(self, hpArr, hpArrStruct, false, true);
            hpArr(1) = hyperplane();
            toStructTest(self, hpArr, hpArrStruct, false, false);
        end
        
        function self = testFromStruct(self)
            hp = hyperplane([1, 2]', 3);
            hpStruct = struct('normal', [1, 2]', 'shift', 3);
            fromStructTest(self, hpStruct, hp, hyperplane(), true);
            
            hp2Struct = struct('normal', [1, 2]', 'shift', 3,...
                'absTol', 1e-5);
            hp2 = hyperplane([1, 2]', 3, 'absTol', 1e-5);
            fromStructTest(self, hpStruct, hp, hyperplane(), true);
            
            hp3 = hyperplane();
            fromStructTest(self, hp2Struct, hp3, hyperplane(), false);
            fromStructTest(self, hp2Struct, hp, hyperplane(), false);
            
            for iHp = 125 : -1 : 1
                hpArr(iHp) = hyperplane(1, 1);
            end
            hpArr = reshape(hpArr, [5 5 5]);
            hpArrStruct = struct('normal', num2cell(ones(5, 5, 5)), ...
                'shift', num2cell(ones(5, 5, 5)));
            fromStructTest(self, hpArrStruct, hpArr, hyperplane(), true);
            hpArr(1) = hyperplane();
            fromStructTest(self, hpArrStruct, hpArr, hyperplane(), false);
            
        end
        
        function self = testDisplay(self)
            hp = hyperplane([1, 2]', 3);
            patternsCVec = {'hyperplane object', ...
                            'Properties',...
                            'shift',...
                            'normal',...
                            'Hyperplane shift'};
            displayTest(self, hp, patternsCVec, true);
            
            hp = hyperplane();
            displayTest(self, hp, patternsCVec, true);
            
            hp = hyperplane([1, 1]', 3);
            displayTest(self, hp, patternsCVec, true);
            
            hpArr = hyperplane.fromStruct(struct('normal', num2cell(ones(5, 5, 5)), ...
                                          'shift', num2cell(ones(5, 5, 5))));
            displayTest(self, hpArr, patternsCVec, true);
            
            hp = [hp hp];
            patternsCVec = horzcat(patternsCVec, 'ObjArr(1)');
            displayTest(self, hp, patternsCVec, true);
            
            ell = ellipsoid();
            displayTest(self, ell, patternsCVec, false);
        end
        
        function self = testEq(self)
            hp = hyperplane([1, 2]', 3);
            eqTest(self, hp, hp, true);
            
            hp2 = hyperplane();
            eqTest(self, hp, hp, true);
            
            hp3 = hyperplane([1, 1]', 3);
            eqTest(self, hp3, hp3, true);
            eqTest(self, hp, hp3, false);
            eqTest(self, hp, hp2, false);
            
            hpArr = hyperplane.fromStruct(struct('normal', num2cell(ones(5, 5, 5)), ...
                                          'shift', num2cell(ones(5, 5, 5))));
            eqTest(self, hpArr, hpArr, true);
            hpArr2 = hpArr;
            hpArr2(1, 1, 1) = hyperplane();
            eqTest(self, hpArr, hpArr2, false);
            
            hp = [hp hp];
            eqTest(self, hp, hp, true);
            eqTest(self, hp, hpArr2(1, 1:2, 1), false);
        end
    end
end