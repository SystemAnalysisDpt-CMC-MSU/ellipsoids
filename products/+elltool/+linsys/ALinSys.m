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
        controlBoundsEll=ellipsoid()
        ctMat
        disturbanceBoundsEll=ellipsoid()
        isTimeInv
        isConstantBoundsVec
        absTol
    end
    methods
        function set.controlBoundsEll(self,ell)
            import modgen.common.throwerror;
            if ~(isa(ell,'ellipsoid')||isstruct(ell))
                throwerror('wrongInput:badType',...
                    ['attempt to put a value different from ',...
                    'a ellipsoid and a structure into ',...
                    'controlBoundsEll object field']);
            end
            self.controlBoundsEll=ell;
        end
        function set.disturbanceBoundsEll(self,ell)
            import modgen.common.throwerror;
            if ~(isa(ell,'ellipsoid')||isstruct(ell))
                throwerror('wrongInput:badType',...
                    ['attempt to put a value different from ',...
                    'a ellipsoid and a structure into ',...
                    'disturbanceBoundsEll object field']);
            end
            self.disturbanceBoundsEll=ell;
        end
        function set.isConstantBoundsVec(self,isConstantBoundsVec)
            import modgen.common.checkvar;
            checkvar(isConstantBoundsVec,...
                'islogical(x)&&isrow(x)&&numel(x)==2');
            self.isConstantBoundsVec=isConstantBoundsVec;
        end
    end
    methods (Access=protected,Abstract)
        typeStr=getSystemTypeDescr(self)
        paramList=getSystemParamStrList(self)
    end
    %
    methods (Access = protected, Static)
        function isEllHaveNeededDim(inpEll, nDim, absTol,inpName)
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
            
            qVec = inpEll.center;
            qMat = inpEll.shape;
            [kRows, lCols] = size(qVec);
            [mRows, nCols] = size(qMat);
            %%
            if mRows ~= nCols
                throwerror(sprintf('value:%s:shape', inpName),...
                    'shape matrix must be square');
            elseif nCols ~= nDim
                throwerror(sprintf('dimension:%s:shape', inpName),...
                    'shape matrix must be of dimension %dx%d', nDim, nDim);
            elseif lCols > 1 || kRows ~= nDim
                throwerror(sprintf('dimension:%s:center', inpName),...
                    'center must be a vector of dimension %d', nDim);
            end
            %%
            if ~iscell(qVec) && ~iscell(qMat)
                throwerror(sprintf('type:%s',inpName),...
                    'for constant ellipsoids use ellipsoid object');
            end
            %%
            if ~iscell(qVec) && ~isa(qVec, 'double')
                throwerror(sprintf('type:%s:center', inpName), ...
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
                    throwerror(sprintf('value:%s:shape', inpName), ...
                        ['shape matrix must be symmetric, ', ...
                        'positive definite']);
                end
            else
                if isa(qMat, 'double')
                    if ~gras.la.ismatsymm(qMat)
                        throwerror(sprintf('value:%s:shape', ...
                            inpName),...
                            'shape matrix must be symmetric');
                    elseif ~gras.la.ismatposdef(qMat,absTol,false)
                        throwerror(sprintf('value:%s:shape', ...
                            inpName),...
                            'shape matrix must be  positive definite');
                    end
                else
                    throwerror(sprintf('type:%s:shape', inpName),...
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
        function [setMultMat,setEll,isCBV]=processConstrParam(self,...
                setMultMat,setEll,setName,matName)
            import modgen.common.throwerror;
            errDimTag=['wrongInput:dimension:',setName];
            errTypeTag=['wrongInput:type:',setName];
            isCBV=true;
            %
            nDims=size(self.atMat,1);
            if ~isempty(setMultMat)
                [kRows, lCols] = size(setMultMat);
                if kRows ~= nDims
                    throwerror(['wrongInput:dimension:',matName],...
                        'dimensions of A(t) and %s do not match.',...
                        matName);
                end
                if iscell(setMultMat)
                    isCBV=false;
                elseif ~isa(setMultMat, 'double')
                    throwerror(['wrongInput:type:',matName],...
                        'matrix %s must be of type ''cell'' or ''double''.',...
                        matName);
                end
            end
            %
            isOk=true;
            if isempty(setEll)
                setEll=ellipsoid();
            elseif isa(setEll, 'ellipsoid')
                if ~isscalar(setEll)
                        throwerror(errDimTag,...
                            ['ellipsoid %s defining the constrains ',...
                            'is not scalar'],setName);                    
                end
                %
                if ~isempty(setMultMat)&&~isempty(setMultMat)
                    setEll = setEll;
                    [dRows, ~] = dimension(setEll);
                    if dRows ~= lCols
                        throwerror(errDimTag,...
                            ['dimensions of %s bounds and', ...
                            'matrix %s do not match.'],setName,matName);
                    end
                end
            elseif isa(setEll, 'double') || iscell(setEll)
                [kRows, mRows] = size(setEll);
                if mRows > 1
                    throwerror(errTypeTag,...
                        ['%s must be an ellipsoid', ...
                        'or a vector.'],setName)
                elseif ~isempty(setMultMat)&&(kRows ~= lCols)
                    throwerror(errDimTag,...
                        ['dimensions of vector %s and', ...
                        'matrix %s do not match.'],setName,matName);
                end
                if iscell(setEll)
                    isCBV = false;
                    tmpSetEll.center=setEll;
                    tmpSetEll.shape=zeros(numel(setEll));
                    setEll=tmpSetEll;
                else
                    setEll=ellipsoid(setEll,...
                        zeros(size(setEll,1)));
                end
            elseif isstruct(setEll)
                if ~isscalar(setEll)
                        throwerror(errDimTag,...
                            ['structure %s defining the constrains ',...
                            'is not scalar'],setName);  
                end
                isCBV = false;                
                if isfield(setEll, 'center')&&isfield(setEll, 'shape')
                    self.isEllHaveNeededDim(setEll, lCols,...
                        self.absTol,setName);
                else
                    isOk=false;
                end
            else
                isOk=false;
            end
            if ~isOk
                throwerror(errTypeTag,...
                    ['%s can be a scalar ellipsoid, scalar structure'...
                    'or a vector.'],setName);            
            end
        end
    end
    %
    methods
        function self = ALinSys(atInpMat, btInpMat, uBoundsEll, ...
                ctInpMat, vBoundsEll,varargin)
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
            %       vBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds
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
            import modgen.common.checkvar;
            import elltool.logging.Log4jConfigurator;
            neededPropNameList = {'absTol'};
            absTolVal = Properties.parseProp(varargin, neededPropNameList);
            if nargin == 0
                self.atMat = [];
                self.btMat = [];
                self.controlBoundsEll = ellipsoid();
                self.ctMat = [];
                self.disturbanceBoundsEll = ellipsoid();
                self.isTimeInv = false;
                self.isConstantBoundsVec = false(1, 2);
                self.absTol = absTolVal;
            else
                self.absTol = absTolVal;
                %%
                checkvar(atInpMat,'ismatrix(x)&&size(x,1)==size(x,2)',...
                    'errorTag','dimension:A','errorMessage',...
                    'A must be square matrix.');
                checkvar(atInpMat,@(x)iscell(x)||isa(x,'double'),'errorTag',...
                    'type:A','errorMessage',...
                    'matrix A must be of type ''cell'' or ''double''.');
                self.atMat = atInpMat;
                isConstantBoundsVec=[true,true];
                %%
                if nargin > 1
                    if nargin==2
                        uBoundsEll=[];
                    end
                    [self.btMat,self.controlBoundsEll,...
                        isConstantBoundsVec(1)]=...
                        processConstrParam(self,btInpMat,uBoundsEll,...
                        'P','B');
                end
                %%
                if nargin > 3
                    if nargin==4
                        vBoundsEll=[];
                    end
                    [self.ctMat,self.disturbanceBoundsEll,...
                        isConstantBoundsVec(2)]=...
                        processConstrParam(self,ctInpMat,vBoundsEll,...
                        'Q','C');
                end
                
                %%
                self.isTimeInv = all(isConstantBoundsVec)&&~iscell(self.atMat);
                self.isConstantBoundsVec = isConstantBoundsVec;
            end
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
                distEll=linsys.disturbanceBoundsEll;
                isDisturb=true;
                if isempty(linsys.ctMat)||...
                        isMeaningful&&(isa(distEll,'ellipsoid')&&...
                        all(all(distEll.getShapeMat()==0))||...
                        isstruct(distEll)&&all(all(distEll.shape==0)))
                    isDisturb=false;
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
        function isLtiArr = isLti(self)
            isLtiArr = arrayfun(@(x) isLtiInternal(x), self);
            %
            function isLti = isLtiInternal(linsys)
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