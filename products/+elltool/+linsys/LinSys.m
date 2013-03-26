classdef LinSys < handle
% Linear system object of the Ellipsoidal Toolbox.
%
% 
%  LinSys         - Constructor of linear system object.
%  dimension      - Returns state space dimension, number of inputs, number of
%                   outputs and number of disturbance inputs.
%  isempty        - Checks if the linear system object is empty.
%  isdiscrete     - Returns 1 if linear system is discrete-time,
%                   0 - if continuous-time.
%  islti          - Returns 1 if the system is time-invariant, 0 - otherwise.
%  hasdisturbance - Returns 1 if unknown bounded disturbance is present,
%                   0 - if there is no disturbance, or disturbance vector is fixed.
%  hasnoise       - Returns 1 if unknown bounded noise at the output is present,
%                   0 - if there is no noise, or noise vector is fixed.
%
%
% $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%           Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
%           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
    properties (Access = private)
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
    %
    methods (Access = private, Static)
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
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   aMat: double[aMatDim, aMatDim].
        %
            aMat = self.atMat;
        end
        function bMat = getBtMat(self)
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   bMat: double[bMatDim, bMatDim].
        %
            bMat = self.btMat;
        end
        function uEll = getUBoundsEll(self)
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   uEll: ellipsoid[1, 1].
        %
            uEll = self.controlBoundsEll;
        end
        function gMat = getGtMat(self)
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   gMat: double[gMatDim, gMatDim].
        %
            gMat = self.gtMat;
        end
        function distEll = getDistBoundsEll(self)
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   distEll: ellipsoid[1, 1].
        %
            distEll = self.disturbanceBoundsEll;
        end
        function cMat = getCtMat(self)
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   cMat: double[cMatDim, cMatDim].
        %
            cMat = self.ctMat;
        end
        function noiseEll = getNoiseBoundsEll(self)
            noiseEll = self.noiseBoundsEll;
        end
        %
        function self = LinSys(atInpMat, btInpMat, uBoundsEll, gtInpMat,...
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
                    self.isEllHaveNeededDim(uBoundsEll, lCols);      
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
                    self.isEllHaveNeededDim(distBoundsEll, lCols);
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
                    self.isEllHaveNeededDim(noiseBoundsEll, kRows);
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
            self.absTol = absTolVal;
        end
        %
        function [stateDimArr, inpDimArr, outDimArr, distDimArr] =...
                dimension(self)
        %
        % DIMENSION - returns dimensions of state,
        %     input, output and disturbance spaces.
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   stateDimArr: double[nDims1, nDims2,...] - array of
        %       state space dimensions.
        %
        %   inpDimArr: double[nDims1, nDims2,...] - array of input dimensions.
        %
        %   outDimArr: double[nDims1, nDims2,...] - array of output dimensions.
        %
        %   distDimArr: double[nDims1, nDims2,...] - array of
        %       disturbance dimensions.
        %   
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
        %
        function display(self)
        %
        % Displays the details of linear system object.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   None.
        %
            fprintf('\n');
            disp([inputname(1) ' =']);
            %%
            if self.isempty()
                fprintf('Empty linear system object.\n\n');
                return;
            end
            %%
            if self.isDiscr
                s0 = '[k]';
                s1 = 'x[k+1]  =  ';
                s2 = '  y[k]  =  ';
                s3 = ' x[k]';
            else
                s0 = '(t)';
                s1 = 'dx/dt  =  ';
                s2 = ' y(t)  =  ';
                s3 = ' x(t)';
            end
            %%
            fprintf('\n');
            if iscell(self.atMat)
                if self.isDiscr
                    fprintf('A[k]:\n');
                    s4 = 'A[k]';
                else
                    fprintf('A(t):\n');
                    s4 = 'A(t)';
                end
            else
                fprintf('A:\n');
                s4 = 'A';
            end
            disp(self.atMat);
            if iscell(self.btMat)
                if self.isDiscr
                    fprintf('\nB[k]:\n');
                    s5 = '  +  B[k]';
                else
                    fprintf('\nB(t):\n');
                    s5 = '  +  B(t)';
                end
            else
                fprintf('\nB:\n');
                s5 = '  +  B';
            end
            disp(self.btMat);
            %%
            fprintf('\nControl bounds:\n');
            s6 = [' u' s0];
            if isempty(self.controlBoundsEll)
                fprintf('     Unbounded\n');
            elseif isa(self.controlBoundsEll, 'ellipsoid')
                [qVec, qMat] = parameters(self.controlBoundsEll);
                fprintf('   %d-dimensional constant ellipsoid with center\n',...
                    size(self.btMat, 2));
                disp(qVec);
                fprintf('   and shape matrix\n');
                disp(qMat);
            elseif isstruct(self.controlBoundsEll)
                uEll = self.controlBoundsEll;
                fprintf('   %d-dimensional ellipsoid with center\n',...
                    size(self.btMat, 2));
                disp(uEll.center);
                fprintf('   and shape matrix\n');
                disp(uEll.shape);
            elseif isa(self.controlBoundsEll, 'double')
                fprintf('   constant vector\n');
                disp(self.controlBoundsEll);
                s6 = ' u';
            else
                fprintf('   vector\n');
                disp(self.controlBoundsEll);
            end
            %%
            if ~(isempty(self.gtMat)) && ~(isempty(self.disturbanceBoundsEll))
                if iscell(self.gtMat)
                    if self.isDiscr
                        fprintf('\nG[k]:\n');
                        s7 = '  +  G[k]';
                    else
                        fprintf('\nG(t):\n');
                        s7 = '  +  G(t)';
                    end
                else
                    fprintf('\nG:\n');
                    s7 = '  +  G';
                end
                disp(self.gtMat);
                fprintf('\nDisturbance bounds:\n');
                s8 = [' v' s0];
                if isa(self.disturbanceBoundsEll, 'ellipsoid')
                    [qVec, qMat] = parameters(self.disturbanceBoundsEll);
                    fprintf('   %d-dimensional constant ellipsoid with center\n',...
                        size(self.gtMat, 2));
                    disp(qVec);
                    fprintf('   and shape matrix\n');
                    disp(qMat);
                elseif isstruct(self.disturbanceBoundsEll)
                    uEll = self.disturbanceBoundsEll;
                    fprintf('   %d-dimensional ellipsoid with center\n',...
                        size(self.gtMat, 2));
                    disp(uEll.center);
                    fprintf('   and shape matrix\n');
                    disp(uEll.shape);
                elseif isa(self.disturbanceBoundsEll, 'double')
                    fprintf('   constant vector\n');
                    disp(self.disturbanceBoundsEll);
                    s8 = ' v';
                else
                    fprintf('   vector\n');
                    disp(self.disturbanceBoundsEll);
                end
            else
                s7 = '';
                s8 = '';
            end
            %%
            if iscell(self.ctMat)
                if self.isDiscr
                    fprintf('\nC[k]:\n');
                    s9 = 'C[k]';
                else
                    fprintf('\nC(t):\n');
                    s9 = 'C(t)';
                end
            else
                fprintf('\nC:\n');
                s9 = 'C';
            end
            disp(self.ctMat);
            %%
            s10 = ['  +  w' s0];
            if ~(isempty(self.noiseBoundsEll))
                fprintf('\nNoise bounds:\n');
                if isa(self.noiseBoundsEll, 'ellipsoid')
                    [qVec, qMat] = parameters(self.noiseBoundsEll);
                    fprintf('   %d-dimensional constant ellipsoid with center\n',...
                        size(self.ctMat, 1));
                    disp(qVec);
                    fprintf('   and shape matrix\n');
                    disp(qMat);
                elseif isstruct(self.noiseBoundsEll)
                    uEll = self.noiseBoundsEll;
                    fprintf('   %d-dimensional ellipsoid with center\n',...
                        size(self.ctMat, 1));
                    disp(uEll.center);
                    fprintf('   and shape matrix\n');
                    disp(uEll.shape);
                elseif isa(self.noiseBoundsEll, 'double')
                    fprintf('   constant vector\n');
                    disp(self.noiseBoundsEll);
                    s10 = '  +  w';
                else
                    fprintf('   vector\n');
                    disp(self.noiseBoundsEll);
                end
            else
                s10 = '';
            end
            %%
            fprintf('%d-input, ', size(self.btMat, 2));
            fprintf('%d-output ', size(self.ctMat, 1));
            if self.isDiscr
                fprintf('discrete-time linear ');
            else
                fprintf('continuous-time linear ');
            end
            if self.isTimeInv
                fprintf('time-invariant system ');
            else
                fprintf('system ');
            end
            fprintf('of dimension %d', size(self.atMat, 1));
            if ~(isempty(self.gtMat))
                if size(self.gtMat, 2) == 1
                    fprintf('\nwith 1 disturbance input');
                elseif size(self.gtMat, 2) > 1
                    fprintf('\nwith %d disturbance input',...
                        size(self.gtMat, 2));
                end
            end
            fprintf(':\n%s%s%s%s%s%s%s\n%s%s%s%s\n\n',...
                s1, s4, s3, s5, s6, s7, s8, s2, s9, s3, s10);
            return; 
        end
        %
        function isDisturbanceArr = hasdisturbance(self)
        %
        % HASDISTURBANCE checks if linear system has unknown bounded disturbance.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isDisturbanceArr: logical[nDims1, nDims2,...] - array such that
        %       it's element at each position is true if corresponding
        %       linear system has disturbance, and false otherwise.
        %
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
        %
        function isNoiseArr = hasnoise(self)
        %
        % HASNOISE checks if linear system has unknown bounded noise.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isNoiseMat: logical[nDims1, nDims2,...] - array such that it's
        %       element at each position is true if corresponding
        %       linear system has noise, and false otherwise.
        %
            isNoiseArr = arrayfun(@(x) isNoise(x), self);
            %
            function isNoise = isNoise(linsys)
                isNoise = false;
                if ~isempty(linsys.noiseBoundsEll)
                    isNoise = true;
                end
            end
        end
        %
        function isDiscreteArr = isdiscrete(self)
        %
        % ISDISCRETE checks if linear system is discrete-time.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isDiscreteMat: logical[nDims1, nDims2,...] - array such that it's
        %       element at each position is true if corresponding
        %       linear system is discrete-time, and false otherwise.
        %
            isDiscreteArr = arrayfun(@(x) isDiscrete(x), self);
            %
            function isDiscrete = isDiscrete(linsys)
                isDiscrete = linsys.isDiscr;
            end
        end
        %
        function isEmptyArr = isempty(self)
        %
        % ISEMPTY checks if linear system is empty.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isEmptyMat: logical[nDims1, nDims2,...] - array such that it's
        %       element at each position is true if corresponding
        %       linear system is empty, and false otherwise.
        %
            isEmptyArr = arrayfun(@(x) isEmp(x), self);
            %
            function isEmp = isEmp(linsys)
                isEmp = false;
                if isempty(linsys.atMat) 
                    isEmp = true;
                end
            end
        end
        %
        function isLtiArr = islti(self)
        %
        % ISLTI checks if linear system is time-invariant.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        %
        % Output:
        %   isLtiMat: logical[nDims1, nDims2,...] -array such that it's
        %       element at each position is true if corresponding
        %       linear system is time-invariant, and false otherwise.
        %
            isLtiArr = arrayfun(@(x) isLti(x), self);
            %
            function isLti = isLti(linsys)
                isLti = linsys.isTimeInv;
            end
        end
        %
        function absTolArr = getAbsTol(self)
        %
        % GETABSTOL gives array the same size as linsysArr with
        % values of absTol properties for each hyperplane in hplaneArr.
        %
        % Input:
        %   regular:
        %       self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array
        %             of linear systems.
        % 
        % Output:
        %   absTolArr: double[nDims1, nDims2,...] - array of absTol
        %       properties for linear systems in self.
        %
        % $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        % 
            absTolArr = arrayfun(@(x)x.absTol, self);
        end
    end
end