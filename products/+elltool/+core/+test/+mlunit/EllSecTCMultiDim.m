classdef EllSecTCMultiDim < mlunitext.test_case
    
% $Author: Igor Samokhin, Lomonosov Moscow State University,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 02-November-2012, <igorian.vmk@gmail.com>$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

    properties (Access=private)
        testDataRootDir
    end
    methods
        function self=EllSecTCMultiDim(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,...
                'TestData', filesep,shortClassName];
        end
    end
end
% function [varargout] = createTypicalArray(flag)
%     switch flag
%         case 18
%             arraySize = [2, 1, 3, 2, 1, 1, 4];
%             my1Ell = ell_unitball(10);
%             my2Ell = ell_unitball(10);
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 10, 1, 1);
%             myMat = eye(10);
%             ansEllMat = diag(48 ^ 2 * ones(1, 10));
%             ansEllVec = createObjectArray([1, 10], @ellipsoid, ... 
%                 ansEllMat, 1, 1);
%             varargout{1} = my1Ell;
%             varargout{2} = my2Ell;
%             varargout{3} = myEllArray;          
%             varargout{4} = myMat;          
%             varargout{5} = ansEllVec;   
%         case 19
%             arraySize = [1, 2, 4, 3, 2, 1];
%             my1Ell = ellipsoid(10 * ones(1, 7), diag(9 * ones(1, 7)));
%             my2Ell = ellipsoid(-3 * ones(1, 7), diag([1, zeros(1, 6)]));
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 7, 1, 1);
%             myMat = eye(7);
%             ansEllMat = diag([50 ^ 2, 51 ^ 2 * ones(1, 6)]);
%             ansEllVec = createObjectArray([1, 7], @ellipsoid, ... 
%                 7 * ones(1, 7), ansEllMat, 2);
%             varargout{1} = my1Ell;
%             varargout{2} = my2Ell;
%             varargout{3} = myEllArray;          
%             varargout{4} = myMat;          
%             varargout{5} = ansEllVec;   
%         case 20
%             arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
%             my1Ell = ell_unitball(1);
%             my2Ell = ellipsoid(1, 0.25);
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 7, 1, 1);
%             myMat = [1, -1];
%             ansEllMat = diag(49.5 ^ 2);
%             ansEllVec = createObjectArray([1, 2], @ellipsoid, ... 
%                 -1, ansEllMat, 2);
%             varargout{1} = my1Ell;
%             varargout{2} = my2Ell;
%             varargout{3} = myEllArray;          
%             varargout{4} = myMat;          
%             varargout{5} = ansEllVec;  
%         otherwise
%     end
% end
% function objectArray = createObjectArray(arraySize, func, firstArg, ...
% secondArg, nArg)
%     nElems = prod(arraySize, 2);
%     switch nArg
%         case 0 
%             objectCArray = cellfun(func, ...
%                 'UniformOutput', false);
%         case 1
%             firstArgCArray = repmat({firstArg}, 1, nElems);
%             objectCArray = cellfun(func, firstArgCArray, ...
%                 'UniformOutput', false);
%         case 2
%             firstArgCArray = repmat({firstArg}, 1, nElems);
%             secondArgCArray = repmat({secondArg}, 1, nElems);
%             objectCArray = cellfun(func, firstArgCArray, secondArgCArray, ...
%                 'UniformOutput', false);
%         otherwise
%     end
%     objectArray = reshape([objectCArray{:}], arraySize);
% end