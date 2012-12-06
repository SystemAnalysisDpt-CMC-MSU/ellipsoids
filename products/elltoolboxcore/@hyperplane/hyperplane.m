classdef hyperplane < handle
    %HYPERPLANE - a class for hyperplanes
    properties (Access=private)
        normal
        shift
        absTol
    end
    methods
        
        function hypObjArr = hyperplane(hypNormArr, hypConstArr, varargin)
            %
            % HYPERPLANE - creates hyperplane structure
            %              (or array of hyperplane structures).
            %
            %   Hyperplane H = { x in R^n : <v, x> = c },
            %   with current "Properties"..
            %   Here v must be vector in R^n, and c - scalar.
            %
            %   hypH = HYPERPLANE - create empty hyperplane.
            %
            %   hypH = HYPERPLANE(hypNormVec) - create
            %       hyperplane object hypH with properties:
            %           hypH.normal = hypNormVec,
            %           hypH.shift = 0.
            %
            %   hypH = HYPERPLANE(hypNormVec, hypConst) - create
            %       hyperplane object hypH with properties:
            %           hypH.normal = hypNormVec,
            %           hypH.shift = hypConst.
            %
            %   hypH = HYPERPLANE(hypNormVec, hypConst, ...
            %   'absTol', absTolVal) - create
            %       hyperplane object hypH with properties:
            %           hypH.normal = hypNormVec,
            %           hypH.shift = hypConst.
            %           hypH.absTol = absTolVal
            %
            %   hypObjArr = HYPERPLANE(hypNormArr, hypConstArr) - create
            %       array of hyperplanes object just as
            %       hyperplane(hypNormVec, hypConst).
            %
            %   hypObjArr = HYPERPLANE(hypNormArr, hypConstArr, ...
            %   'absTol', absTolValArr) - create
            %       array of hyperplanes object just as
            %       hyperplane(hypNormVec, hypConst, 'absTol', absTolVal).
            %
            % Input:
            %   regular:
            %       hypNormArr: double[hpDims, nDims1, nDims2,...] /
            %           / double[hpDims, 1] - array of vectors
            %           in R^hpDims. There hpDims - hyperplane dimension.
            %
            %   optional:
            %       hypConstArr: double[nDims1, nDims2, ...] /
            %           / double[VecArrDim1, nVecArrDim2, ...] -
            %           array of scalar.
            %       absTolValArr: double[1, 1] - value of
            %           absTol propeties.
            %
            %   properties:
            %       propMode: char[1,] - property mode, the following
            %           modes are supported:
            %           'absTol' - name of absTol properties.
            %
            %           note: if size of hypNormArr is
            %               [hpDims, nDims1, nDims2,...], then size of
            %               hypConstArr is [nDims1, nDims2, ...] or
            %               [1, 1], if size of hypNormArr [hpDims, 1],
            %               then hypConstArr can be any size
            %               [nVecArrDim1, nVecArrDim2, ...],
            %               in this case output variable will has
            %               size [VecArrDim1, nVecArrDim2, ...].
            %
            % Output:
            %   hypObjArr: hyperplane [nDims1, nDims2...] /
            %       / hyperplane [VecArrDim1, nVecArrDim2, ...] -
            %       array of hyperplane structure hypH:
            %           hypH.normal - vector in R^hpDims,
            %           hypH.shift  - scalar.
            %
            % $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
            % $Copyright: The Regents of the University
            %   of California 2004-2008 $
            %
            % $Author: Aushkap Nikolay <n.aushkap@gmail.com> $
            %   $Date: 30-11-2012$
            % $Copyright: Moscow State University,
            %   Faculty of Computational Mathematics and Computer
            %   Science, System Analysis Department 2012 $
            
            import modgen.common.checkvar;
            import modgen.common.checkmultvar;
            
            if nargin == 0
                hypObjArr = hyperplane(0, 0);
                return;
            end
            
            neededPropNameList = {'absTol'};
            absTolVal = elltool.conf.Properties.parseProp(varargin, ...
                neededPropNameList);
            
            if nargin < 2
                hypConstArr = 0;
            end
            
            checkmultvar('isa(x1,''double'') && isa(x2,''double'')', 2,...
                hypNormArr, hypConstArr, 'errorTag', ...
                'wrongInput', 'errorMessage', ...
                'Both arguments must be of type ''double''.');
            
            fstCompStr = '~(any(isnan(x1(:))) || any(isinf(x1(:))) || ';
            secCompStr = 'any(isnan(x2(:))) || any(isinf(x2(:))))';
            checkmultvar([fstCompStr secCompStr], 2, hypNormArr, ...
                hypConstArr,  'errorTag', 'wrongInput', 'errorMessage',...
                'Wrong values of input arguments.');
            
            sizeArrNormVec = size(hypNormArr);
            sizeArrConstVec = size(hypConstArr);
            
            if (isscalar(sizeArrNormVec(2:end)) && isscalar(hypConstArr)...
                    && (sizeArrNormVec(2) == 1))
                hypObjArr.normal = hypNormArr;
                hypObjArr.shift  = hypConstArr;
                hypObjArr.absTol = absTolVal;
                return;
            end
            
            if ((size(sizeArrNormVec, 2) == 2) && ...
                    (sizeArrNormVec(2) ~= 1))
                if ((size(sizeArrConstVec, 2) == 2)  && ...
                        (sizeArrConstVec(1) == 1))
                    subHypNormArr = zeros(sizeArrNormVec(1), 1, ...
                        sizeArrNormVec(2));
                    subHypNormArr(:, 1, :) = hypNormArr;
                    hypNormArr = subHypNormArr;
                    sizeArrNormVec = size(hypNormArr);
                end
            end
            
            fstCompStr = 'isequal(x1, x2) || (isscalar(x4) && ';
            secCompStr = '~isempty(x3))|| (isscalar(x1) && ~isempty(x4))';
            fstErrStr = 'Array of normal vectors and array of constants ';
            secErrStr = 'has wrong sizes.';
            checkmultvar([fstCompStr secCompStr], ...
                4, sizeArrNormVec(2:end), sizeArrConstVec, hypNormArr, ...
                hypConstArr, 'errorTag', 'wrongSizes', ...
                'errorMessage', [fstErrStr secErrStr]);
            
            if (isscalar(sizeArrNormVec(2:end)) &&...
                    (sizeArrNormVec(2) == 1))
                nElems = numel(hypConstArr);
                indVec = 1:nElems;
                hypObjArr(nElems) = hyperplane();
                hypConstVec = reshape(hypConstArr, [1 nElems]);
                arrayfun(@(x, y) setProp(x, hypNormArr, y, absTolVal), ...
                    indVec, hypConstVec);
                hypObjArr = reshape(hypObjArr, size(hypConstArr));
            elseif (isscalar(hypConstArr))
                otherDimVec = sizeArrNormVec;
                otherDimVec(:, 1) = [];
                indCVec = arrayfun(@(x) ones(1, x), otherDimVec, ...
                    'UniformOutput', false);
                nDims = sizeArrNormVec(1);
                hypNormCArr = mat2cell(hypNormArr, nDims, indCVec{:});
                hypNormCArr = shiftdim(hypNormCArr,1);
                nElems = numel(hypNormCArr);
                indVec = 1:nElems;
                nElems = numel(hypNormCArr);
                hypObjArr(nElems) = hyperplane();
                hypNormCVec = reshape(hypNormCArr, [1 nElems]);
                arrayfun(@(x, y) setProp(x, y{1}, ...
                    hypConstArr, absTolVal), indVec, hypNormCVec);
                hypObjArr = reshape(hypObjArr, size(hypNormCArr));
            else
                otherDimVec = sizeArrNormVec;
                otherDimVec(:, 1) = [];
                indCVec = arrayfun(@(x) ones(1, x), otherDimVec, ...
                    'UniformOutput', false);
                nDims = sizeArrNormVec(1);
                hypNormCArr = mat2cell(hypNormArr, nDims, indCVec{:});
                hypNormCArr = shiftdim(hypNormCArr,1);
                nElems = numel(hypNormCArr);
                indVec = 1:nElems;
                hypNormCVec = reshape(hypNormCArr, [1 nElems]);
                hypConstVec = reshape(hypConstArr, [1 nElems]);
                hypObjArr(nElems) = hyperplane();
                arrayfun(@(x, y, z) setProp(x, y{1}, z, absTolVal), ...
                    indVec, hypNormCVec, hypConstVec);
                hypObjArr = reshape(hypObjArr, size(hypNormCArr));
            end
            
            function setProp(iObj, nrmVec, shft, curAbsTol)
                hypObjArr(iObj).normal = nrmVec;
                hypObjArr(iObj).shift = shft;
                hypObjArr(iObj).absTol = curAbsTol;
            end
            
        end
        
    end
    
    methods (Static)
        
        checkIsMe(someObj)
        
    end
    
end
