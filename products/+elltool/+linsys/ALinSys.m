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
        function isEllHaveNeededDim(InpEll, nDim, absTol)
        % isEllHaveNeededDim - checks if given structure InpEll represents
        %     an ellipsoid of dimension nDim.
        %
        % Input:
        %   regular:
        %       InpEll: struct[1, 1]
        %
        %       nDim: double[1, 1]
        %
        %       absTol: doulbe[1,1]
        %
        % Output:
        %   None.
        %
            import elltool.logging.Log4jConfigurator;
            import modgen.common.throwerror;

            persistent logger;

            qVec = InpEll.center;
            QMat = InpEll.shape;
            [kRows, lCols] = size(qVec);
            [mRows, nCols] = size(QMat);
            %%
            if mRows ~= nCols
                throwerror(sprintf('value:%s:shape', inputname(1)),...
                    'shape matrix must be square');
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
                    if isempty(logger)
                        logger=Log4jConfigurator.getLogger();
                    end
                    logger.info('Warning! Cannot check if symbolic matrix is positive definite.\n');
                end
                isEqMat = strcmp(QMat, QMat.');
                if ~all(isEqMat(:))
                    throwerror(sprintf('linsys:value:%s:shape', inputname(1)),...
                        'shape matrix must be symmetric, positive definite');
                end
            else
                if isa(QMat, 'double')
                    if ~gras.la.ismatsymm(QMat)
                        throwerror(sprintf('linsys:value:%s:shape', ...
                            inputname(1)),...
                            'shape matrix must be symmetric');
                    elseif ~gras.la.ismatposdef(QMat,absTol,false)
                        throwerror(sprintf('linsys:value:%s:shape',...
                            inputname(1)),...
                            'shape matrix must be  positive definite');
                    end                    
                else
                    throwerror(sprintf('type:%s:shape', inputname(1)),...
                        'shape matrix must be of type ''cell'' or ''double''');    
                end        
            end
        end
    end

    methods
        function self = ALinSys(atInpMat, btInpMat, uBoundsEll, gtInpMat,...
                distBoundsEll, ctInpMat, noiseBoundsEll, discrFlag, varargin)
        %
        % LINSYS - constructor for linear system object.
        %
        % Continuous-time linear system:
        %                   dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  G(t) v(t)
        %                    y(t)  =  C(t) x(t)  +  w(t)
        %
        % Discrete-time linear system:
        %                  x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  G[k] v[k]
        %                    y[k]  =  C[k] x[k]  +  w[k]
        %
        % Input:
        %   regular:
        %       atInpMat: double[nDim, nDim]/cell[nDim, nDim].
        %
        %       btInpMat: double[nDim, kDim]/cell[nDim, kDim].
        %
        %       uBoundsEll: ellipsoid[1, 1]/struct[1, 1].
        %
        %       gtInpMat: double[nDim, lDim]/cell[nDim, lDim].
        %
        %       distBoundsEll: ellipsoid[1, 1]/struct[1, 1].
        %
        %       ctInpMat: double[mDim, nDim]/cell[mDim, nDim].
        %
        %       noiseBoundsEll: ellipsoid[1, 1]/struct[1, 1].
        %
        %       discrFlag: char[1, 1] - if discrFlag set:
        %           'd' - to discrete-time linSys
        %           not 'd' - to continuous-time linSys.
        %
        % Output:
        %   self: elltool.linsys.LinSys[1, 1].
        %
            import modgen.common.throwerror;
            import elltool.conf.Properties;
            import elltool.logging.Log4jConfigurator;

            persistent logger;

            neededPropNameList = {'absTol'};
            absTolVal = Properties.parseProp(varargin, neededPropNameList);
            if nargin == 0
                self.atMat = [];
                self.btMat = [];
                self.controlBoundsEll = [];
                self.gtMat = [];
                self.disturbanceBoundsEll = [];
                self.ctMat = [];
                self.noiseBoundsEll = [];
                self.isTimeInv = false;
                self.isDiscr = false;
                self.isConstantBoundsVec = false(1, 3);
                self.absTol = absTolVal;
                return;
            end
            self.absTol = absTolVal;
            %%
            isTimeInvar = true;
            [mRows, nCols] = size(atInpMat);
            if mRows ~= nCols
                throwerror('linsys:dimension:A',...
                    'LINSYS: A must be square matrix.');
            end
            if iscell(atInpMat)
                isTimeInvar = false;
            elseif ~(isa(atInpMat, 'double'))
                throwerror('linsys:type:A',...
                    'LINSYS: matrix A must be of type ''cell'' or ''double''.');
            end
            self.atMat = atInpMat;
            %%
            [kRows, lCols] = size(btInpMat);
            if kRows ~= nCols
                throwerror('linsys:dimension:B',...
                    'LINSYS: dimensions of A and B do not match.');
            end
            if iscell(btInpMat)
                isTimeInvar = false;
            elseif ~(isa(btInpMat, 'double'))
                throwerror('linsys:type:B',...
                    'LINSYS: matrix B must be of type ''cell'' or ''double''.');
            end 
            self.btMat = btInpMat;
            %%
            isCBU = true;
            if nargin > 2
                if isempty(uBoundsEll)
                    % leave as is
                elseif isa(uBoundsEll, 'ellipsoid')
                    uBoundsEll = uBoundsEll(1, 1);
                    [dRows, rCols] = dimension(uBoundsEll);
                    if dRows ~= lCols
                        throwerror('linsys:dimension:U',...
                            'LINSYS: dimensions of control bounds U and matrix B do not match.');
                    end
                    if (dRows > rCols) &&...
                            (elltool.conf.Properties.getIsVerbose() > 0)
                        if isempty(logger)
                            logger=Log4jConfigurator.getLogger();
                        end
                        logger.info('LINSYS: Warning! Control bounds U represented by degenerate ellipsoid.');
                    end
                elseif isa(uBoundsEll, 'double') || iscell(uBoundsEll)
                    [kRows, mRows] = size(uBoundsEll);
                    if mRows > 1
                        throwerror('linsys:type:U',...
                            'LINSYS: control U must be an ellipsoid or a vector.')
                    elseif kRows ~= lCols
                        throwerror('linsys:dimension:U',...
                            'LINSYS: dimensions of control vector U and matrix B do not match.');
                    end
                    if iscell(uBoundsEll)
                        isCBU = false;
                    end
                elseif isstruct(uBoundsEll) &&...
                        isfield(uBoundsEll, 'center') &&...
                        isfield(uBoundsEll, 'shape')
                    isCBU = false;
                    uBoundsEll = uBoundsEll(1, 1);
                    self.isEllHaveNeededDim(uBoundsEll, lCols,self.absTol);      
                else
                    throwerror('linsys:type:U',...
                        'LINSYS: control U must be an ellipsoid or a vector.')
                end
            else
                uBoundsEll = [];
            end
            self.controlBoundsEll = uBoundsEll;
            %%
            if nargin > 3
                if isempty(gtInpMat)
                    % leave as is
                else
                    [kRows, lCols] = size(gtInpMat);
                    if kRows ~= nCols
                        throwerror('linsys:dimension:G',...
                            'LINSYS: dimensions of A and G do not match.');
                    end
                    if iscell(gtInpMat)
                        isTimeInvar = false;
                    elseif ~(isa(gtInpMat, 'double'))
                        throwerror('linsys:type:G',...
                            'LINSYS: matrix G must be of type ''cell'' or ''double''.');
                    end 
                end 
            else
                gtInpMat = [];
            end
            %%
            isCBV = true;
            if nargin > 4
                if isempty(gtInpMat) || isempty(distBoundsEll)
                    gtInpMat = [];
                    distBoundsEll = [];
                elseif isa(distBoundsEll, 'ellipsoid')
                    distBoundsEll = distBoundsEll(1, 1);
                    [dRows, rCols] = dimension(distBoundsEll);
                    if dRows ~= lCols
                        error('linsys:dimension:V',...
                            'LINSYS: dimensions of disturbance bounds V and matrix G do not match.');
                    end
                elseif isa(distBoundsEll, 'double') || iscell(distBoundsEll)
                    [kRows, mRows] = size(distBoundsEll);
                    if mRows > 1
                        throwerror('linsys:type:V',...
                            'LINSYS: disturbance V must be an ellipsoid or a vector.')
                    elseif kRows ~= lCols
                        throwerror('linsys:dimension:V',...
                            'LINSYS: dimensions of disturbance vector V and matrix G do not match.');
                    end
                    if iscell(distBoundsEll)
                        isCBV = false;
                    end
                elseif isstruct(distBoundsEll) &&...
                        isfield(distBoundsEll, 'center') &&...
                        isfield(distBoundsEll, 'shape')
                    isCBV = false;
                    distBoundsEll = distBoundsEll(1, 1);
                        self.isEllHaveNeededDim(distBoundsEll, lCols,...
                        self.absTol);
                else
                    throwerror('linsys:type:V',...
                        'LINSYS: disturbance V must be an ellipsoid or a vector.')
                end
            else
                distBoundsEll = [];
            end
            self.gtMat = gtInpMat;
            self.disturbanceBoundsEll = distBoundsEll;
            %%
            if nargin > 5
                if isempty(ctInpMat)
                    ctInpMat = eye(nCols);
                else
                    [kRows, lCols] = size(ctInpMat);
                    if lCols ~= nCols
                        throwerror('linsys:dimension:C',...
                            'LINSYS: dimensions of A and C do not match.');
                    end
                    if iscell(ctInpMat)
                        isTimeInvar = false;
                    elseif ~(isa(ctInpMat, 'double'))
                        throwerror('linsys:type:C',...
                            'LINSYS: matrix C must be of type ''cell'' or ''double''.');
                    end 
                end 
            else
                ctInpMat = eye(nCols);
            end
            self.ctMat = ctInpMat;
            %%
            isCBW = true;
            if nargin > 6
                if isempty(noiseBoundsEll)
                    % leave as is
                elseif isa(noiseBoundsEll, 'ellipsoid')
                    noiseBoundsEll = noiseBoundsEll(1, 1);
                    [dRows, rCols] = dimension(noiseBoundsEll);
                    if dRows ~= kRows
                        throwerror('linsys:dimension:W',...
                            'LINSYS: dimensions of noise bounds W and matrix C do not match.');
                    end
                elseif isa(noiseBoundsEll, 'double') || iscell(noiseBoundsEll)
                    [lCols, mRows] = size(noiseBoundsEll);
                    if mRows > 1
                        throwerror('linsys:type:W',...
                            'LINSYS: noise W must be an ellipsoid or a vector.')
                    elseif kRows ~= lCols
                        throwerror('linsys:dimension:W',...
                            'LINSYS: dimensions of noise vector W and matrix C do not match.');
                    end
                    if iscell(noiseBoundsEll)
                        isCBW = false;
                    end
                elseif isstruct(noiseBoundsEll) &&...
                        isfield(noiseBoundsEll, 'center') &&...
                        isfield(noiseBoundsEll, 'shape')
                    isCBW = false;
                    noiseBoundsEll = noiseBoundsEll(1, 1);
                    self.isEllHaveNeededDim(noiseBoundsEll, kRows, ...
                        self.absTol);
                else
                    throwerror('linsys:type:W',...
                        'LINSYS: noise W must be an ellipsoid or a vector.')
                end
            else
                noiseBoundsEll = [];
            end
            self.noiseBoundsEll = noiseBoundsEll;
            %%
            self.isTimeInv = isTimeInvar;
            self.isDiscr  = false;
            if (nargin > 7)  && ischar(discrFlag) && (discrFlag == 'd')
                self.isDiscr = true;
            end
            self.isConstantBoundsVec = [isCBU isCBV isCBW];
        end
        
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