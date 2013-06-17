classdef ALinSys < elltool.linsys.ILinSys
    %
    %  Abstract class of linear system class of the Ellipsoidal Toolbox.
    %
    %
    % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
    %           Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
    %           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
    %           Igor Kitsenko <kitsenko@gmail.com> $              $Date: March-2013 $
    %           Peter Gagarinov <pgagarinov@gmail.com> $          $Date: June-2013 $        
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    properties (Access = protected)
        atMat
        btMat
        controlBoundsEll
        ctMat
        disturbanceBoundsEll
        isTimeInv
        isConstantBoundsVec
        absTol
    end
    methods (Access=protected,Abstract)
        typeStr=getSystemTypeDescr(self)
        paramList=getSystemParamStrList(self)
    end
    %
    methods (Access = protected, Static)
        function isEllHaveNeededDim(InpEll, nDim, absTol)
            %
            % ISELLHAVENEEDEDDIM - checks if given structure InpEll represents an
            %                      ellipsoid of dimension nDim.
            %
            % Input:
            %   regular:
            %       InpEll: struct[1, 1] - structure to check for being an ellipsoid
            %           of dimension nDim.
            %
            %       nDim: double[1, 1] - dimension of ellipsoid.
            %
            %       absTol: doulbe[1,1] - absolute tolerance.
            %
            % Output:
            %   None.
            %
            import elltool.logging.Log4jConfigurator;
            import modgen.common.throwerror;
            
            persistent logger;
            
            qVec = InpEll.center;
            qMat = InpEll.shape;
            [kRows, lCols] = size(qVec);
            [mRows, nCols] = size(qMat);
            %%
            if mRows ~= nCols
                throwerror(sprintf('value:%s:shape', inputname(1)),...
                    'shape matrix must be square');
            elseif nCols ~= nDim
                throwerror(sprintf('dimension:%s:shape', inputname(1)),...
                    'shape matrix must be of dimension %dx%d', nDim, nDim);
            elseif lCols > 1 || kRows ~= nDim
                throwerror(sprintf('dimension:%s:center', inputname(1)),...
                    'center must be a vector of dimension %d', nDim);
            end
            %%
            if ~iscell(qVec) && ~iscell(qMat)
                throwerror(sprintf('type:%s',inputname(1)),...
                    'for constant ellipsoids use ellipsoid object');
            end
            %%
            if ~iscell(qVec) && ~isa(qVec, 'double')
                throwerror(sprintf('type:%s:center', inputname(1)), ...
                    'center must be of type ''cell'' or ''double''');
            end
            %%
            if iscell(qMat)
                if elltool.conf.Properties.getIsVerbose() > 0
                    if isempty(logger)
                        logger=Log4jConfigurator.getLogger();
                    end
                    logger.info(['Warning! Cannot check if symbolic ', ...
                        'matrix is positive definite.\n']);
                end
                isEqMat = strcmp(qMat, qMat.');
                if ~all(isEqMat(:))
                    throwerror(sprintf('value:%s:shape', inputname(1)), ...
                        ['shape matrix must be symmetric, ', ...
                        'positive definite']);
                end
            else
                if isa(qMat, 'double')
                    if ~gras.la.ismatsymm(qMat)
                        throwerror(sprintf('value:%s:shape', ...
                            inputname(1)),...
                            'shape matrix must be symmetric');
                    elseif ~gras.la.ismatposdef(qMat,absTol,false)
                        throwerror(sprintf('value:%s:shape', ...
                            inputname(1)),...
                            'shape matrix must be  positive definite');
                    end
                else
                    throwerror(sprintf('type:%s:shape', inputname(1)),...
                        ['shape matrix must be of type ''cell'' ', ...
                        'or ''double''']);
                end
            end
        end
        %
        function copyEll = getCopyOfNotEmptyEll(inpEll)
            if isstruct(inpEll)
                copyEll = inpEll;
            else
                copyEll = inpEll.getCopy();
            end
        end
        %
        function copyEll = getCopyEll(inpEll)
            if ~isempty(inpEll)
                copyEll =...
                    elltool.linsys.ALinSys.getCopyOfNotEmptyEll(inpEll);
            else
                copyEll = [];
            end
        end
        %
        function isEq = isEqualEll(firstEll, secondEll)
            isEq = false;
            if ~isempty(firstEll) && ~isempty(secondEll)
                if isstruct(firstEll) && isstruct(secondEll)
                    isEq = isequal(firstEll, secondEll);
                end
                if ~isstruct(firstEll) && ~isstruct(secondEll)
                    isEq = firstEll.isEqual(secondEll);
                end
            end
            if isempty(firstEll) && isempty(secondEll)
                isEq = true;
            end
        end
        %
        function isEq = isEqualMat(firstMat, secondMat, absTol)
            isEq = false;
            if iscell(firstMat) && iscell(secondMat)
                isEq = isequal(firstMat, secondMat);
            end
            if ~iscell(firstMat) && ~iscell(secondMat)
                isEq = norm(firstMat - secondMat) <= absTol;
            end
        end
    end
    %
    methods
        function display(self)
            %
            % DISPLAY - displays the details of linear system object.
            %
            % Input:
            %   regular:
            %       self: elltool.linsys.ALinSys[1, 1] - linear system.
            %
            % Output:
            %   None.
            %
            fprintf('\n');
            disp([inputname(1) ' =']);
            %
            if self.isEmpty()
                fprintf('Empty linear system object.\n\n');
                return;
            end
            %
            if min(size(self)) == 0
                if max(size(self)) == 0
                    fprintf('Empty linear system object.\n\n');
                    return;
                else
                    fprintf('Empty linear system objects array.\n\n');
                    return;
                end
            end
            %
            [s0, s1, s2, s3] = self.getSystemParamStrList();
            %
            fprintf('\n');
            if iscell(self.atMat)
                fprintf(['A', s0, ':\n']);
                s4 = ['A', s0];
            else
                fprintf('A:\n');
                s4 = 'A';
            end
            disp(self.atMat);
            if iscell(self.btMat)
                fprintf(['\nB', s0, ':\n']);
                s5 = ['  +  B', s0];
            else
                fprintf('\nB:\n');
                s5 = '  +  B';
            end
            disp(self.btMat);
            %
            fprintf('\nControl bounds:\n');
            s6 = [' u' s0];
            if isempty(self.controlBoundsEll)
                fprintf('     Unbounded\n');
            elseif isa(self.controlBoundsEll, 'ellipsoid')
                [qVec, qMat] = parameters(self.controlBoundsEll);
                fprintf(['   %d-dimensional constant ellipsoid ', ...
                    'with center\n'],...
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
            %
            if ~(isempty(self.ctMat)) && ...
                    ~(isempty(self.disturbanceBoundsEll))
                if iscell(self.ctMat)
                    fprintf(['\nC', s0, ':\n']);
                    s7 = ['  +  C', s0];
                else
                    fprintf('\nC:\n');
                    s7 = '  +  C';
                end
                disp(self.ctMat);
                fprintf('\nDisturbance bounds:\n');
                s8 = [' v' s0];
                if isa(self.disturbanceBoundsEll, 'ellipsoid')
                    [qVec, qMat] = parameters(self.disturbanceBoundsEll);
                    fprintf(['   %d-dimensional constant ellipsoid ', ...
                        'with center\n'],...
                        size(self.ctMat, 2));
                    disp(qVec);
                    fprintf('   and shape matrix\n');
                    disp(qMat);
                elseif isstruct(self.disturbanceBoundsEll)
                    uEll = self.disturbanceBoundsEll;
                    fprintf('   %d-dimensional ellipsoid with center\n',...
                        size(self.ctMat, 2));
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
            %
            %
            fprintf(self.getSystemTypeDescr());
            %
            if self.isTimeInv
                fprintf('time-invariant system ');
            else
                fprintf('system ');
            end
            fprintf('of dimension %d', size(self.atMat, 1));
            if ~(isempty(self.ctMat))
                if size(self.ctMat, 2) == 1
                    fprintf('\nwith 1 disturbance input');
                elseif size(self.ctMat, 2) > 1
                    fprintf('\nwith %d disturbance input',...
                        size(self.ctMat, 2));
                end
            end
            fprintf(':\n%s%s%s%s%s%s%s\n%s%s\n\n',...
                s1, s4, s3, s5, s6, s7, s8,s2, s3);
            return;
        end
    end
    methods (Access = protected)    
        function checkScalar(self)
            import modgen.common.throwerror;
            %
            if numel(self) > 1
                throwerror('wrongInput', 'Input argument must be scalar.');
            end
        end
        %
        function [aMat, bMat, uEll, cMat, distEll] =...
                getParams(self)
            aMat = self.getAtMat();
            bMat = self.getBtMat();
            uEll = self.getUBoundsEll();
            cMat = self.getCtMat();
            distEll = self.getDistBoundsEll();
        end
    end
    %
    methods
        function self = ALinSys(atInpMat, btInpMat, uBoundsEll, ...
                ctInpMat, distBoundsEll,varargin)
            %
            % ALinSys - constructor abstract class of linear system.
            %
            % Continuous-time linear system:
            %           dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  C(t) v(t)
            %
            % Discrete-time linear system:
            %           x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  C[k] v[k]
            %
            % Input:
            %   regular:
            %       atInpMat: double[nDim, nDim]/cell[nDim, nDim] - matrix A.
            %
            %       btInpMat: double[nDim, kDim]/cell[nDim, kDim] - matrix B.
            %
            %       uBoundsEll: ellipsoid[1, 1]/struct[1, 1] - control bounds
            %           ellipsoid.
            %
            %       ctInpMat: double[nDim, lDim]/cell[nDim, lDim] - matrix G.
            %
            %       distBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds
            %           ellipsoid.
            %       discrFlag: char[1, 1] - if discrFlag set:
            %           'd' - to discrete-time linSys
            %           not 'd' - to continuous-time linSys.
            %
            % Output:
            %   self: elltool.linsys.ALinSys[1, 1] -
            %       linear system.
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
                self.ctMat = [];
                self.disturbanceBoundsEll = [];
                self.isTimeInv = false;
                self.isConstantBoundsVec = false(1, 3);
                self.absTol = absTolVal;
                return;
            end
            self.absTol = absTolVal;
            %%
            isTimeInvar = true;
            [mRows, nCols] = size(atInpMat);
            if mRows ~= nCols
                throwerror('dimension:A',...
                    'A must be square matrix.');
            end
            if iscell(atInpMat)
                isTimeInvar = false;
            elseif ~(isa(atInpMat, 'double'))
                throwerror('type:A',...
                    'matrix A must be of type ''cell'' or ''double''.');
            end
            self.atMat = atInpMat;
            %%
            [kRows, lCols] = size(btInpMat);
            if kRows ~= nCols
                throwerror('dimension:B',...
                    'dimensions of A and B do not match.');
            end
            if iscell(btInpMat)
                isTimeInvar = false;
            elseif ~(isa(btInpMat, 'double'))
                throwerror('type:B',...
                    'matrix B must be of type ''cell'' or ''double''.');
            end
            self.btMat = btInpMat;
            %%
            isCBU = true;
            if nargin > 2
                if isempty(uBoundsEll)||...
                        isa(uBoundsEll, 'ellipsoid')&&(uBoundsEll.isEmpty())
                    % leave as is
                elseif isa(uBoundsEll, 'ellipsoid')
                    uBoundsEll = uBoundsEll(1, 1);
                    [dRows, rCols] = dimension(uBoundsEll);
                    if dRows ~= lCols
                        throwerror('dimension:U',...
                            ['dimensions of control bounds U and', ...
                            'matrix B do not match.']);
                    end
                    if (dRows > rCols) &&...
                            (elltool.conf.Properties.getIsVerbose() > 0)
                        if isempty(logger)
                            logger=Log4jConfigurator.getLogger();
                        end
                        logger.info(['Warning! Control bounds', ...
                            'U represented by degenerate ellipsoid.']);
                    end
                elseif isa(uBoundsEll, 'double') || iscell(uBoundsEll)
                    [kRows, mRows] = size(uBoundsEll);
                    if mRows > 1
                        throwerror('type:U',...
                            'control U must be an ellipsoid or a vector.')
                    elseif kRows ~= lCols
                        throwerror('dimension:U',...
                            ['dimensions of control vector U and', ...
                            'matrix B do not match.']);
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
                    throwerror('type:U',...
                        'control U must be an ellipsoid or a vector.')
                end
            else
                uBoundsEll = [];
            end
            self.controlBoundsEll = uBoundsEll;
            %%
            if nargin > 3
                if isempty(ctInpMat)
                    % leave as is
                else
                    [kRows, lCols] = size(ctInpMat);
                    if kRows ~= nCols
                        throwerror('dimension:G',...
                            'dimensions of A and G do not match.');
                    end
                    if iscell(ctInpMat)
                        isTimeInvar = false;
                    elseif ~(isa(ctInpMat, 'double'))
                        throwerror('type:G',...
                            ['matrix G must be of type ''cell''', ...
                            'or ''double''.']);
                    end
                end
            else
                ctInpMat = [];
            end
            %%
            isCBV = true;
            if nargin > 4
                if isempty(ctInpMat) || isempty(distBoundsEll)
                    ctInpMat = [];
                    distBoundsEll = [];
                elseif isa(distBoundsEll, 'ellipsoid')
                    distBoundsEll = distBoundsEll(1, 1);
                    [dRows, rCols] = dimension(distBoundsEll);
                    if dRows ~= lCols
                        error('dimension:V',...
                            ['dimensions of disturbance bounds V and', ...
                            'matrix G do not match.']);
                    end
                elseif isa(distBoundsEll, 'double') || iscell(distBoundsEll)
                    [kRows, mRows] = size(distBoundsEll);
                    if mRows > 1
                        throwerror('type:V',...
                            ['disturbance V must be an ellipsoid', ...
                            'or a vector.'])
                    elseif kRows ~= lCols
                        throwerror('dimension:V',...
                            ['dimensions of disturbance vector V and', ...
                            'matrix G do not match.']);
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
                    throwerror('type:V',...
                        'disturbance V must be an ellipsoid or a vector.')
                end
            else
                distBoundsEll = [];
            end
            self.ctMat = ctInpMat;
            self.disturbanceBoundsEll = distBoundsEll;
            
            %%
            self.isTimeInv = isTimeInvar;
            self.isConstantBoundsVec = [isCBU isCBV];
        end
        
        function aMat = getAtMat(self)
            self.checkScalar();
            aMat = self.atMat;
        end
        
        function bMat = getBtMat(self)
            self.checkScalar();
            bMat = self.btMat;
        end
        
        function uEll = getUBoundsEll(self)
            self.checkScalar();
            uEll = self.controlBoundsEll;
        end
        function distEll = getDistBoundsEll(self)
            self.checkScalar();
            distEll = self.disturbanceBoundsEll;
        end
        
        function cMat = getCtMat(self)
            self.checkScalar();
            cMat = self.ctMat;
        end
        %
        function [stateDimArr, inpDimArr, distDimArr] = ...
                dimension(self)
            [stateDimArr, inpDimArr, distDimArr] = ...
                arrayfun(@(x) getDimensions(x), self);
            %
            if nargout < 3
                clear('distDimArr');
                if nargout < 2
                    clear('inpDimArr');
                end
            end
            %
            function [stateDim, inpDim, distDim] =  getDimensions(linsys)
                stateDim = size(linsys.atMat, 1);
                inpDim = size(linsys.btMat, 2);
                distDim = size(linsys.ctMat, 2);
            end
        end
        %
        function isDisturbanceArr = hasDisturbance(self, varargin)
            if (nargin == 1)
                isMeaningful = true;
            else
                isMeaningful = varargin{1};
            end
            isDisturbanceArr = arrayfun(@(x) isDisturb(x), self);
            %
            function isDisturb = isDisturb(linsys)
                isDisturb = false;
                if  (~isempty(linsys.ctMat) &&...
                        ~isempty(linsys.disturbanceBoundsEll)) &&...
                        ((~isMeaningful && ...
                        isa(linsys.disturbanceBoundsEll,'double')) ||...
                        (isa(linsys.disturbanceBoundsEll,'ellipsoid')))
                    isDisturb = true;
                end
            end
        end
        %
        function isEmptyArr = isEmpty(self)
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
            isLtiArr = arrayfun(@(x) isLti(x), self);
            %
            function isLti = isLti(linsys)
                isLti = linsys.isTimeInv;
            end
        end
        %
        function absTolArr = getAbsTol(self)
            absTolArr = arrayfun(@(x)x.absTol, self);
        end
        %
        function copyLinSysArr = getCopy(self)
            sizeCVec = num2cell(size(self));
            copyLinSysArr(sizeCVec{:}) = feval(class(self));
            arrayfun(@(x) fSingleCopy(x), 1 : numel(self));
            %
            function fSingleCopy(index)
                curLinSys = self(index);
                copyLinSysArr(index).atMat = curLinSys.atMat;
                copyLinSysArr(index).btMat = curLinSys.btMat;
                copyLinSysArr(index).controlBoundsEll =...
                    self.getCopyEll(curLinSys.controlBoundsEll);
                copyLinSysArr(index).ctMat = curLinSys.ctMat;
                copyLinSysArr(index).disturbanceBoundsEll =...
                    self.getCopyEll(curLinSys.disturbanceBoundsEll);
                copyLinSysArr(index).isTimeInv = curLinSys.isTimeInv;
                copyLinSysArr(index).isConstantBoundsVec =...
                    curLinSys.isConstantBoundsVec;
                copyLinSysArr(index).absTol = curLinSys.absTol;
            end
        end
        %
        function isEqualArr = isEqual(self, compLinSysArr)
            import modgen.common.throwerror;
            %
            if ~all(size(self) == size(compLinSysArr))
                throwerror('wrongInput', 'dimensions must be the same.');
            end
            %
            isEqualArr =...
                arrayfun(@(x, y) fSingleComp(x, y), self, compLinSysArr);
            %
            function isEq = fSingleComp(firstLinSys, secondLinSys)
                [firstStateDim, firstInpDim,...
                    firstDistDim] = firstLinSys.dimension();
                [secondStateDim, secondInpDim, ...
                    secondDistDim] = secondLinSys.dimension();
                isEq = firstStateDim == secondStateDim &&...
                    firstInpDim == secondInpDim &&...
                    firstDistDim == secondDistDim;
                if isEq
                    absT = min(firstLinSys.getAbsTol(),...
                        secondLinSys.getAbsTol());
                    [firstAMat, firstBMat, firstUEll, firstCMat,...
                        firstDistEll] =...
                        firstLinSys.getParams();
                    %
                    [secondAMat, secondBMat, secondUEll, secondCMat,...
                        secondDistEll] =...
                        secondLinSys.getParams();
                    %
                    isEq =...
                        self.isEqualMat(firstAMat, secondAMat, absT) &&...
                        self.isEqualMat(firstBMat, secondBMat, absT) &&...
                        self.isEqualEll(firstUEll, secondUEll) &&...
                        self.isEqualMat(firstCMat, secondCMat, absT) &&...
                        self.isEqualEll(firstDistEll, secondDistEll);
                end
            end
        end
    end
end