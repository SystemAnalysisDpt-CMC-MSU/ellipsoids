classdef EllipsoidDispStructTC < elltool.core.test.mlunit.ADispStructTC
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
                case 2
                    objArr = ellipsoid();
                case 6
                    objArr = ellipsoid.fromRepMat(1, 1, [5 5 5]);
                case 7
                    objArr = ellipsoid.fromRepMat(1, 1, [5 5 5]);
                    objArr(1) = ellipsoid();
                otherwise
                    objArr = ellipsoid([1, 1]', eye(2));
            end
        end
        
        function SArr = getToStructStruct(iTest)
            switch iTest
                case 1
                    SArr = struct('shapeMat', eye(2), 'centerVec', [1, 1]');
                case 2
                    SArr = struct('shapeMat', [], 'centerVec', []);
                case 3
                    SArr = struct('shapeMat', [], 'centerVec', []);
                case 4
                    SArr = struct('shapeMat', eye(2), 'centerVec', [1, 1]',...
                        'absTol', 1e-7, 'relTol', 1e-5,...
                        'nPlot2dPoints', 200, 'nPlot3dPoints', 200);
                case 5
                    SArr = struct('shapeMat', eye(2), 'centerVec', [2, 1]');
                case 6
                    SArr = struct('shapeMat', num2cell(ones(5, 5, 5)), ...
                        'centerVec', num2cell(ones(5, 5, 5)));
                case 7
                    SArr = struct('shapeMat', num2cell(ones(5, 5, 5)), ...
                        'centerVec', num2cell(ones(5, 5, 5)));
            end
        end
        
        function isProp = getToStructIsPropIncluded(iTest)
            isProp = iTest == 4;
        end
        
        function result = getToStructResult(iTest)
            falseAnswers = [3, 5, 7];
            result = isempty(find(falseAnswers == iTest, 1));
        end
        
        function objArr = getFromStructObj(iTest)
            switch iTest
                case 1
                    objArr = ellipsoid([1, 1]', eye(2));
                case 2
                    objArr = ellipsoid([1, 1]', eye(2), 'absTol', 1e-8,...
                        'relTol', 1e-4, 'nPlot2dPoints', 300, ...
                        'nPlot3dPoints', 100);
                case 3
                    objArr = ellipsoid();
                case 4
                    objArr = ellipsoid([1, 1]', eye(2));
                case 5
                    objArr = ellipsoid.fromRepMat(1, 1, [5 5 5]);
                case 6
                    objArr = ellipsoid.fromRepMat(1, 1, [5 5 5]);
                    objArr(1) = ellipsoid();
            end
        end
        
        function SArr = getFromStructStruct(iTest)
            switch iTest
                case 1
                    SArr = struct('shapeMat', eye(2), 'centerVec', [1, 1]);
                case 2
                    SArr = struct('shapeMat', eye(2), 'centerVec', [1, 1],...
                        'absTol', 1e-8, 'relTol', 1e-4,...
                        'nPlot2dPoints', 300, 'nPlot3dPoints', 100);
                case 3
                    SArr = struct('shapeMat', eye(2), 'centerVec', [1, 1],...
                        'absTol', 1e-8, 'relTol', 1e-4,...
                        'nPlot2dPoints', 300, 'nPlot3dPoints', 100);
                case 4
                    SArr = struct('shapeMat', eye(2), 'centerVec', [1, 1],...
                        'absTol', 1e-8, 'relTol', 1e-4,...
                        'nPlot2dPoints', 300, 'nPlot3dPoints', 100);
                case 5
                    SArr = struct('shapeMat', num2cell(ones(5, 5, 5)),...
                        'centerVec', num2cell(ones(5, 5, 5)));
                case 6
                    SArr = struct('shapeMat', num2cell(ones(5, 5, 5)),...
                        'centerVec', num2cell(ones(5, 5, 5)));
            end
        end
        
        function result = getFromStructResult(iTest)
            falseAnswers = [3, 4, 6];
            result = isempty(find(falseAnswers == iTest, 1));
        end
        
        function self = EllipsoidDispStructTC(varargin)
            self = self@elltool.core.test.mlunit.ADispStructTC(varargin{:});
        end
        
        function objArr = getDisplayObj(iTest)
            switch iTest
                case 1
                    objArr = ellipsoid([1, 1]', eye(2));
                case 2
                    objArr = ellipsoid();
                case 3
                    objArr = ellipsoid([1, 2]', eye(2));
                case 4
                    objArr = ellipsoid.fromStruct(struct('shapeMat',...
                        num2cell(ones(5, 5, 5)), ...
                        'centerVec', num2cell(ones(5, 5, 5))));
                case 5
                    objArr = ellipsoid.fromStruct(struct('shapeMat', ...
                        num2cell(ones(5, 5, 5)), ...
                        'centerVec', num2cell(ones(5, 5, 5))));
                    objArr = [objArr, objArr];
                case 6
                    objArr = hyperplane();
            end
        end
        
        function stringCVec = getDisplayStrings(iTest)
            stringCVec = {'Ellipsoid shape matrix.', ...
                'ellipsoid object',...
                'centerVec',...
                'shapeMat'};
            if (iTest > 4)
                stringCVec = horzcat(stringCVec, 'ObjArr(1, 1, 1)');
            end
        end
        
        function result = getDisplayResult(iTest)
            result = iTest ~= 6;
        end
        
        function objArr = getEqFstObj(iTest)
            switch iTest
                case 1
                    objArr = ellipsoid([1, 1]', eye(2));
                case 2
                    objArr = ellipsoid();
                case 3
                    objArr = ellipsoid([1, 2]', eye(2));
                case 4
                    objArr = ellipsoid();
                case 5
                    objArr = ellipsoid();
                case 6
                    objArr = ellipsoid.fromStruct(struct('shapeMat',...
                        num2cell(ones(5, 5, 5)), ...
                        'centerVec', num2cell(ones(5, 5, 5))));
                case 7
                    objArr = ellipsoid.fromStruct(struct('shapeMat',...
                        num2cell(ones(5, 5, 5)), ...
                        'centerVec', num2cell(ones(5, 5, 5))));
                case 8
                    objArr = ellipsoid.fromRepMat([1, 1]', eye(2), [1 2]);
            end
        end
        
        function objArr = getEqSndObj(iTest)
            switch iTest
                case 1
                    objArr = ellipsoid([1, 1]', eye(2));
                case 2
                    objArr = ellipsoid();
                case 3
                    objArr = ellipsoid([1, 2]', eye(2));
                case 4
                    objArr = ellipsoid([1, 2]', eye(2));
                case 5
                    objArr = ellipsoid([1, 1]', eye(2));
                case 6
                    objArr = ellipsoid.fromStruct(struct('shapeMat',...
                        num2cell(ones(5, 5, 5)), ...
                        'centerVec', num2cell(ones(5, 5, 5))));
                case 7
                    objArr = ellipsoid.fromStruct(struct('shapeMat',...
                        num2cell(ones(5, 5, 5)), ...
                        'centerVec', num2cell(ones(5, 5, 5))));
                    objArr(1, 1, 1) = ellipsoid();
                case 8
                    objArr = ellipsoid.fromRepMat([1, 1]', eye(2), [1 2]);
            end
        end
        
        function result = getEqResult(iTest)
            falseAnswers = [4, 5, 7];
            result = isempty(find(falseAnswers == iTest, 1));
        end
    end
end