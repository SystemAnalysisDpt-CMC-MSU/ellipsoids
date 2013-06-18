classdef HyperplaneDispStructTC < elltool.core.test.mlunit.ADispStructTC
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods (Static)
        function objArr = getToStructObj(iTest)
            switch iTest
                case 1
                    objArr = hyperplane([1, 1, 2]', 3);
                case 2
                    objArr = hyperplane();
                case 3
                    objArr = hyperplane([1, 1, 2]', 3);
                case 4
                    objArr = hyperplane([1, 1, 2]', 3);
                case 5
                    objArr = hyperplane([1, 1, 2]', 2);
                case 6
                    objArr = hyperplane.fromRepMat(1, 1, [5 5 5]);
                case 7
                    objArr = hyperplane.fromRepMat(1, 1, [5 5 5]);
                    objArr(1) = hyperplane();
            end
        end
        
        function SArr = getToStructStruct(iTest)
            switch iTest
                case 1
                    SArr = struct('normal', [1, 1, 2]', 'shift', 3);
                    SArr.shift = SArr.shift/norm(SArr.normal);
                    SArr.normal = SArr.normal/norm(SArr.normal);
                case 2
                    SArr = struct('normal', [], 'shift', []);
                case 3
                    SArr = struct('normal', [], 'shift', []);
                case 4
                    SArr = struct('normal', [1, 1, 2]', 'shift',...
                        3, 'absTol', 1e-7);
                    SArr.shift = SArr.shift/norm(SArr.normal);
                    SArr.normal = SArr.normal/norm(SArr.normal);
                case 5
                    SArr = struct('normal', [1, 1, 2]', 'shift', ...
                        3, 'absTol', 1e-7);
                    SArr.shift = SArr.shift/norm(SArr.normal);
                    SArr.normal = SArr.normal/norm(SArr.normal);
                case 6
                    SArr = struct('normal', num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5)));
                case 7
                    SArr = struct('normal', num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5)));
            end
        end
        
        function isProps = getToStructIsPropIncluded(iTest)
            isProps = iTest == 4;
        end
        
        function result = getToStructResult(iTest)
            falseAnswers = [3, 5, 7];
            result = isempty(find(falseAnswers == iTest, 1));
        end
        
        function objArr = getFromStructObj(iTest)
            switch iTest
                case 1
                    objArr = hyperplane([1, 2]', 3);
                case 2
                    objArr = hyperplane([1, 2]', 3);
                case 3
                    objArr = hyperplane();
                case 4
                    objArr = hyperplane([1, 2]', 3);
                case 5
                    objArr = hyperplane.fromRepMat(1, 1, [5 5 5]);
                case 6
                    objArr = hyperplane.fromRepMat(1, 1, [5 5 5]);
                    objArr(1) = hyperplane();
            end
        end
        
        function SArr = getFromStructStruct(iTest)
            switch iTest
                case 1
                    SArr = struct('normal', [1, 2]', 'shift', 3);
                case 2
                    SArr = struct('normal', [1, 2]', 'shift', 3);
                case 3
                    SArr = struct('normal', [1, 2]', 'shift', 3,...
                        'absTol', 1e-5);
                case 4
                    SArr = struct('normal', [1, 2]', 'shift', 3,...
                        'absTol', 1e-5);
                case 5
                    SArr = struct('normal', num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5)));
                case 6
                    SArr = struct('normal', num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5)));
            end
        end
        
        function result = getFromStructResult(iTest)
            falseAnswers = [3, 4, 6];
            result = isempty(find(falseAnswers == iTest, 1));
        end
        
        function objArr = getDisplayObj(iTest)
            switch iTest
                case 1
                    objArr = hyperplane([1, 2]', 3);
                case 2
                    objArr = hyperplane();
                case 3
                    objArr = hyperplane([1, 1]', 3);
                case 4
                    objArr = hyperplane.fromStruct(struct('normal',...
                        num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5))));
                case 5
                    objArr = hyperplane([1, 2]', 3);
                    objArr = [objArr objArr];
                case 6
                    objArr = ellipsoid();
            end
        end
        
        function stringsCVec = getDisplayStrings(iTest)
            stringsCVec = {'hyperplane object', ...
                'Properties',...
                'shift',...
                'normal',...
                'Hyperplane shift'};
            if (iTest > 4)
                stringsCVec = horzcat(stringsCVec, 'ObjArr(1)');
            end
        end
        
        function result = getDisplayResult(iTest)
            result = iTest ~= 6;
        end
        
        function objArr = getEqFstObj(iTest)
            switch iTest
                case 1
                    objArr = hyperplane([1, 2]', 3);
                case 2
                    objArr = hyperplane();
                case 3
                    objArr = hyperplane([1, 1]', 3);
                case 4
                    objArr = hyperplane([1, 2]', 3);
                case 5
                    objArr = hyperplane([1, 2]', 3);
                case 6
                    objArr = hyperplane.fromStruct(struct('normal',...
                        num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5))));
                case 7
                    objArr = hyperplane.fromStruct(struct('normal',...
                        num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5))));
                case 8
                    objArr = hyperplane([1, 2]', 3);
                    objArr = [objArr objArr];
            end
        end
        
        function objArr = getEqSndObj(iTest)
            switch iTest
                case 1
                    objArr = hyperplane([1, 2]', 3);
                case 2
                    objArr = hyperplane();
                case 3
                    objArr = hyperplane([1, 1]', 3);
                case 4
                    objArr = hyperplane([1, 1]', 3);
                case 5
                    objArr = hyperplane();
                case 6
                    objArr = hyperplane.fromStruct(struct('normal',...
                        num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5))));
                case 7
                    objArr = hyperplane.fromStruct(struct('normal',...
                        num2cell(ones(5, 5, 5)), ...
                        'shift', num2cell(ones(5, 5, 5))));
                    objArr(1) = hyperplane();
                case 8
                    objArr = hyperplane([1, 2]', 3);
                    objArr = [objArr objArr];
            end
        end
        
        function result = getEqResult(iTest)
            falseAnswers = [4, 5, 7];
            result = isempty(find(falseAnswers == iTest, 1));
        end
        
        function self = HyperplaneDispStructTC(varargin)
            self = self@elltool.core.test.mlunit.ADispStructTC(varargin{:});
        end
    end
end