classdef ALinSys < elltool.linsys.ILinSys
%
% $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%           Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
%           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

    properties (Access = protected)
        atMat
        btMat
        controlBoundsEll
        gtMat
        disturbanceBoundsEll
        ctMat
        noiseBoundsEll
        isTimeInv
        isDiscr
        isConstantBoundsVec
        absTol
    end

    methods (Access = protected, Static)
        function isEllHaveNeededDim(InpEll, nDim)
        % isEllHaveNeededDim - checks if given structure InpEll represents
        %     an ellipsoid of dimension nDim.
        %
        % Input:
        %   regular:
        %       InpEll: struct[1, 1]
        %
        %       nDim: double[1, 1]
        %
        % Output:
        %   None.
        %
            import modgen.common.throwerror;
            qVec = InpEll.center;
            QMat = InpEll.shape;
            [kRows, lCols] = size(qVec);
            [mRows, nCols] = size(QMat);
            %%
            if mRows ~= nCols
                throwerror(sprintf('value:%s:shape', inputname(1)),...
                    'shape matrix must be symmetric, positive definite');
            elseif nCols ~= nDim
                throwerror(sprintf('linsys:dimension:%s:shape', inputname(1)),...
                    'shape matrix must be of dimension %dx%d', nDim, nDim);
            elseif lCols > 1 || kRows ~= nDim
                throwerror(sprintf('linsys:dimension:%s:center', inputname(1)),...
                    'center must be a vector of dimension %d', nDim);  
            end 
            %%
            if ~iscell(qVec) && ~iscell(QMat)
                throwerror(sprintf('linsys:type:%s',inputname(1)),...
                    'for constant ellipsoids use ellipsoid object');
            end
            %%
            if ~iscell(qVec) && ~isa(qVec, 'double')
                throwerror(sprintf('type:%s:center', inputname(1)),...
                    'center must be of type ''cell'' or ''double''');        
            end
            %%
            if iscell(QMat)
                if elltool.conf.Properties.getIsVerbose() > 0
                    fprintf('Warning! Cannot check if symbolic matrix is positive definite.\n');
                end
                isEqMat = strcmp(QMat, QMat.');
                if ~all(isEqMat(:))
                    throwerror(sprintf('linsys:value:%s:shape', inputname(1)),...
                        'shape matrix must be symmetric, positive definite');
                end
            else
                if isa(QMat, 'double')
                    isnEqMat = (QMat ~= QMat.');
                    if any(isnEqMat(:)) || min(eig(QMat)) <= 0
                        throwerror(sprintf('linsys:value:%s:shape', inputname(1)),...
                            'shape matrix must be symmetric, positive definite');
                    end                    
                else
                    throwerror(sprintf('type:%s:shape', inputname(1)),...
                        'shape matrix must be of type ''cell'' or ''double''');    
                end        
            end
        end 
    end

    methods
        function aMat = getAtMat(self)
            aMat = self.atMat;
        end
        
        function bMat = getBtMat(self)
            bMat = self.btMat;
        end
        
        function uEll = getUBoundsEll(self)
            uEll = self.controlBoundsEll;
        end    
        
        function gMat = getGtMat(self)
            gMat = self.gtMat;
        end
        
        function distEll = getDistBoundsEll(self)
            distEll = self.disturbanceBoundsEll;
        end
        
        function cMat = getCtMat(self)
            cMat = self.ctMat;
        end
        
        function noiseEll = getNoiseBoundsEll(self)
            noiseEll = self.noiseBoundsEll;
        end
        
        function [stateDimArr, inpDimArr, outDimArr, distDimArr] =...
                dimension(self)
            [stateDimArr, inpDimArr, outDimArr, distDimArr] =...
                arrayfun(@(x) getDimensions(x), self);
            %
            if nargout < 4
                clear('distDimArr');
                if nargout < 3
                    clear('outDimArr');
                    if nargout < 2
                        clear('inpDimArr');
                    end
                end
            end
            %
            function [stateDim, inpDim, outDim, distDim] =...
                    getDimensions(linsys)
                stateDim = size(linsys.atMat, 1);
                inpDim = size(linsys.btMat, 2);
                outDim = size(linsys.ctMat, 1);
                distDim = size(linsys.gtMat, 2);
            end
        end
        
        function isDisturbanceArr = hasdisturbance(self)
            isDisturbanceArr = arrayfun(@(x) isDisturb(x), self);
            %
            function isDisturb = isDisturb(linsys)
                isDisturb = false;
                if  ~isempty(linsys.disturbanceBoundsEll) &&...
                        ~isempty(linsys.gtMat)
                    isDisturb = true;
                end
            end
        end
        
        function isNoiseArr = hasnoise(self)
            isNoiseArr = arrayfun(@(x) isNoise(x), self);
            %
            function isNoise = isNoise(linsys)
                isNoise = false;
                if ~isempty(linsys.noiseBoundsEll)
                    isNoise = true;
                end
            end
        end
        
        function isDiscreteArr = isdiscrete(self)
            isDiscreteArr = arrayfun(@(x) isDiscrete(x), self);
            %
            function isDiscrete = isDiscrete(linsys)
                isDiscrete = linsys.isDiscr;
            end
        end
        
        function isEmptyArr = isempty(self)
            isEmptyArr = arrayfun(@(x) isEmp(x), self);
            %
            function isEmp = isEmp(linsys)
                isEmp = false;
                if isempty(linsys.atMat) 
                    isEmp = true;
                end
            end
        end
        
        function isLtiArr = islti(self)
            isLtiArr = arrayfun(@(x) isLti(x), self);
            %
            function isLti = isLti(linsys)
                isLti = linsys.isTimeInv;
            end
        end
        
        function absTolArr = getAbsTol(self)
            absTolArr = arrayfun(@(x)x.absTol, self);
        end        
    end
end