classdef hyperplane < elltool.core.AGenEllipsoid
    %HYPERPLANE - a class for hyperplanes
    properties (Access=private)
        normal
        shift
        absTol
        relTol
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
            %       'absTol', absTolVal) - create
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
            %       'absTol', absTolValArr) - create
            %       array of hyperplanes object just as
            %       hyperplane(hypNormVec, hypConst, 'absTol', absTolVal).
            %
            % Input:
            %   Case1:
            %     regular:
            %       hypNormArr: double[hpDims, nDims1, nDims2,...] -
            %           array of vectors in R^hpDims. There hpDims -
            %           hyperplane dimension.
            %
            %   Case2:
            %     regular:
            %       hypNormArr: double[hpDims, nCols] /
            %           / [hpDims, nDims1, nDims2,...] /
            %           / [hpDims, 1] - array of vectors
            %           in R^hpDims. There hpDims - hyperplane dimension.
            %       hypConstArr: double[1, nCols] / [nCols, 1] /
            %           / [nDims1, nDims2,...] /
            %           / [nVecArrDim1, nVecArrDim2,...] -
            %           array of scalar.
            %
            %   Case3:
            %     regular:
            %       hypNormArr: double[hpDims, nCols] /
            %           / [hpDims, nDims1, nDims2,...] /
            %           / [hpDims, 1] - array of vectors
            %           in R^hpDims. There hpDims - hyperplane dimension.
            %       hypConstArr: double[1, nCols] / [nCols, 1] /
            %           / [nDims1, nDims2,...] /
            %           / [nVecArrDim1, nVecArrDim2,...] -
            %           array of scalar.
            %       absTolValArr: double[1, 1] - value of
            %           absTol propeties.
            %
            %     properties:
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
            %               size [nVecArrDim1, nVecArrDim2, ...].
            %               If size of hypNormArr is [hpDims, nCols],
            %               then size of hypConstArr may be
            %               [1, nCols] or [nCols, 1],
            %               output variable will has size
            %               respectively [1, nCols] or [nCols, 1].
            %
            % Output:
            %   hypObjArr: hyperplane [nDims1, nDims2...] /
            %       / hyperplane [nVecArrDim1, nVecArrDim2, ...] -
            %       array of hyperplane structure hypH:
            %           hypH.normal - vector in R^hpDims,
            %           hypH.shift  - scalar.
            %
            % Example:
            %   hypNormMat = [1 1 1; 1 1 1];
            %   hypConstVec = [1 -5 0];
            %   hypObj = hyperplane(hypNormMat, hypConstVec);
            %
            % $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
            % $Copyright: The Regents of the University of California
            %             2004-2008 $
            %
            % $Author: Aushkap Nikolay <n.aushkap@gmail.com> $
            % $Date: 30-11-2012$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012 $
            
            import modgen.common.checkvar;
            import modgen.common.checkmultvar;
            
            if nargin == 0
                hypObjArr = hyperplane(0, 0);
            else
                neededPropNameList = {'absTol', 'relTol'};
                %                 absTolVal = elltool.conf.Properties.parseProp(varargin,...
                %                     neededPropNameList);
                [regParamList,propNameValList]=modgen.common.parseparams(...
                    varargin, neededPropNameList);
                [absTolVal, relTolVal] =...
                    elltool.conf.Properties.parseProp(propNameValList,...
                    neededPropNameList);
                %
                if nargin < 2
                    hypConstArr = 0;
                end
                %
                checkmultvar('isa(x1,''double'') && isa(x2,''double'')',...
                    2, hypNormArr, hypConstArr, 'errorTag', ...
                    'wrongInput', 'errorMessage', ...
                    'Both arguments must be of type ''double''.');
                %
                fstCompStr = '~(any(isnan(x1(:))) || any(isinf(x1(:))) ';
                secCompStr = '|| any(isnan(x2(:))) || any(isinf(x2(:))))';
                checkmultvar([fstCompStr secCompStr], 2, hypNormArr, ...
                    hypConstArr,  'errorTag', 'wrongInput', ...
                    'errorMessage', 'Wrong values of input arguments.');
                %
                sizeArrNormVec = size(hypNormArr);
                nHypArrDims=ndims(hypNormArr);
                sizeArrConstVec = size(hypConstArr);
                nConstDims=ndims(hypConstArr);
                nDims = sizeArrNormVec(1);
                %
                isSingleNormVec = nHypArrDims==2&&iscolumn(hypNormArr);
                %
                isConstScal = isscalar(hypConstArr);
                if (isSingleNormVec && isConstScal)
                    hypObjArr.normal = hypNormArr;
                    hypObjArr.shift  = hypConstArr;
                    hypObjArr.absTol = absTolVal;
                    hypObjArr.relTol = relTolVal;
                else
                    if (nHypArrDims == 2) && ~iscolumn(hypNormArr)&&...
                            nConstDims==2&&isrow(hypConstArr)
                        sizeArrNormVec=[sizeArrNormVec(1),1,...
                            sizeArrNormVec(2)];
                        %
                        hypNormArr=reshape(hypNormArr,sizeArrNormVec);
                    end
                    %
                    fstCompStr = 'isequal(x1, x2) ||';
                    secCompStr = '(isscalar(x4) && ~isempty(x3)) ||';
                    thrCompStr = '(isscalar(x1) && ~isempty(x4))';
                    fstErrStr = 'Array of normal vectors and array';
                    secErrStr = ' of constants has wrong sizes.';
                    checkmultvar([fstCompStr secCompStr thrCompStr], ...
                        4, sizeArrNormVec(2:end), sizeArrConstVec, ...
                        hypNormArr, hypConstArr, 'errorTag', ...
                        'wrongSizes', 'errorMessage', ...
                        [fstErrStr secErrStr]);
                    %
                    if isSingleNormVec
                        [nElems outSizeVec] = setSizes(hypConstArr);
                        build();
                        arrayfun(@(x, y) setProp(x, hypNormArr, y, ...
                            absTolVal, relTolVal), indArr, hypConstArr);
                    elseif isConstScal
                        cellBuild();
                        [nElems outSizeVec] = setSizes(hypNormCArr);
                        build();
                        arrayfun(@(x, y) setProp(x, y{1}, ...
                            hypConstArr, absTolVal, relTolVal), indArr, hypNormCArr);
                    else
                        cellBuild();
                        [nElems outSizeVec] = setSizes(hypNormCArr);
                        build();
                        arrayfun(@(x, y, z) setProp(x, y{1}, z, ...
                            absTolVal, relTolVal), indArr, hypNormCArr, hypConstArr);
                    end
                end
            end
            %
            function setProp(iObj, nrmVec, shft, curAbsTol, curRelTol)
                hypObjArr(iObj).normal = nrmVec;
                hypObjArr(iObj).shift = shft;
                hypObjArr(iObj).absTol = curAbsTol;
                hypObjArr(iObj).relTol = curRelTol;
            end
            %
            function build()
                indArr = reshape(1:nElems, outSizeVec);
                hypObjArr(nElems) = hyperplane();
                hypObjArr = reshape(hypObjArr, outSizeVec);
            end
            %
            function cellBuild()
                indCVec = arrayfun(@(x)ones(1, x),sizeArrNormVec(2:end),...
                    'UniformOutput', false);
                nDims = sizeArrNormVec(1);
                hypNormCArr = mat2cell(hypNormArr, nDims, ...
                    indCVec{:});
                hypNormCArr = shiftdim(hypNormCArr,1);
            end
        end
    end
    methods (Static)
        checkIsMe(someObj)
        hpArr = fromRepMat(varargin)
        hpObj = fromStruct(SHpObj)
    end
    
    methods (Access = protected, Static)
        function SComp = formCompStruct(SHp, SFieldNiceNames, ~, isPropIncluded)
            SComp.(SFieldNiceNames.normal) = SHp.normal;
            SComp.(SFieldNiceNames.shift) = SHp.shift;
            if (isPropIncluded)
                SComp.(SFieldNiceNames.absTol) = SHp.absTol;
            end
        end
    end
end
%
function [nElems outSizeVec] = setSizes(inpObjArr)
nElems = numel(inpObjArr);
outSizeVec = size(inpObjArr);
end
