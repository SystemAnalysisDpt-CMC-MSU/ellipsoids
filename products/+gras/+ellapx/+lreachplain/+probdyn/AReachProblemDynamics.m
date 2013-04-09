classdef AReachProblemDynamics<...
        gras.ellapx.lreachplain.probdyn.IReachProblemDynamics
    properties (Access = protected)
        problemDef
        AtDynamics
        BptDynamics
        BPBTransDynamics
        Rtt0Dynamics
        timeVec
    end
    properties (Abstract, Access = protected)
        xtDynamics
    end
    properties (Constant, GetAccess = protected)
        N_TIME_POINTS=1000;
        ODE_NORM_CONTROL='on';
        CALC_PRECISION_FACTOR=0.001;
    end
    properties (Access = private)
        fRtt0DerivFunc
        sRtt0InitialMat
        sizeSysVec
    end
    properties (Constant, GetAccess = private)
        % (temporary) algorithm:
        %   0 - X(t, t0)
        %   1 - X(t, t0) / matrixnorm(X(t, t0))
        %   2 - R(t, t0)
        %   3 - [R(t, t0); matrixnorm(X(t, t0))]
        %
        CALC_ALGORITHM = 2;
    end
    methods
        function self = AReachProblemDynamics(problemDef)
            if (nargin > 0)
                self.problemDef = problemDef;
                self.sizeSysVec = size(problemDef.getAMatDef());
                %
                t0 = problemDef.gett0();
                t1 = problemDef.gett1();
                self.timeVec = linspace(t0,t1,self.N_TIME_POINTS);
                %
                % (temporary) fRtt0DerivFunc selection
                %
                switch (self.CALC_ALGORITHM)
                    case 0
                        self.fRtt0DerivFunc = @(t,x) fXtt0DerivFunc(t, x, @(u) self.AtDynamics.evaluate(u));
                    case 1
                        self.fRtt0DerivFunc = @(t,x) fXtt0DerivFunc(t, x, @(u) self.AtDynamics.evaluate(u));
                    case 2
                        self.fRtt0DerivFunc = @(t,x) fRtt0SimDerivFunc(t, x, @(u) self.AtDynamics.evaluate(u));
                    case 3
                        self.fRtt0DerivFunc = @(t,x) fRtt0ExtDerivFunc(t, x, @(u) self.AtDynamics.evaluate(u), sizeAtVec);
                end
                %
                % (temporary) sRtt0InitialMat selection
                %
                switch (self.CALC_ALGORITHM)
                    case 0
                        self.sRtt0InitialMat = eye(self.sizeSysVec);
                    case 1
                        self.sRtt0InitialMat = eye(self.sizeSysVec);
                    case 2
                        self.sRtt0InitialMat = eye(self.sizeSysVec);
                        self.sRtt0InitialMat = normaliz(self.sRtt0InitialMat);
                    case 3
                        self.sRtt0InitialMat = eye(self.sizeSysVec);
                        norm = sqrt(sum(sum(self.sRtt0InitialMat, 2)));
                        self.sRtt0InitialMat = normaliz(self.sRtt0InitialMat);
                        self.sRtt0InitialMat = [self.sRtt0InitialMat(:); norm];
                end
            end
        end
        function BPBTransDynamics=getBPBTransDynamics(self)
            BPBTransDynamics=self.BPBTransDynamics;
        end
        function AtDynamics=getAtDynamics(self)
            AtDynamics=self.AtDynamics;
        end
        function BptDynamics=getBptDynamics(self)
            BptDynamics=self.BptDynamics;
        end
        function xtDynamics=getxtDynamics(self)
            xtDynamics=self.xtDynamics;
        end
        function Rtt0Dynamics=getRtt0Dynamics(self)
            Rtt0Dynamics=self.Rtt0Dynamics;
        end
        function timeVec=getTimeVec(self)
            timeVec=self.timeVec;
        end
        function X0Mat=getX0Mat(self)
            X0Mat=self.problemDef.getX0Mat();
        end
        function x0Vec=getx0Vec(self)
            x0Vec=self.problemDef.getx0Vec();
        end
        function tLims=getTimeLimsVec(self)
            tLims=self.problemDef.getTimeLimsVec();
        end
        function t0=gett0(self)
            t0=self.problemDef.gett0();
        end
        function t1=gett1(self)
            t1=self.problemDef.gett1();
        end
        function sysDim=getDimensionality(self)
            sysDim=self.problemDef.getDimensionality();
        end
        function problemDef=getProblemDef(self)
            problemDef=self.problemDef;
        end
    end
    methods (Access = protected)
        function odePropList=getOdePropList(self,calcPrecision)
            odePropList={'NormControl',self.ODE_NORM_CONTROL,'RelTol',...
                calcPrecision*self.CALC_PRECISION_FACTOR,...
                'AbsTol',calcPrecision*self.CALC_PRECISION_FACTOR};
        end
        %
        % We need this method because 
        % gras.ellapx.lreachplain.probdyn.AReachProblem* subclass must 
        % define AtDynamics and other funcions
        %
        function calcRtt0Dynamics(self, calcPrecision)
            %
            import gras.interp.MatrixInterpolantFactory;
            import gras.ode.MatrixODESolver;
            %
            odeArgList = self.getOdePropList(calcPrecision);
            %
            if (self.CALC_ALGORITHM == 3)
                numelSys = prod(self.sizeSysVec);
                solverObj=MatrixODESolver([numelSys + 1, 1],@ode45,odeArgList{:});
            else
                solverObj=MatrixODESolver(self.sizeSysVec,@ode45,odeArgList{:});
            end
            %
            [timeRtt0Vec,dataRtt0Array]=solverObj.solve(self.fRtt0DerivFunc,...
                self.timeVec,self.sRtt0InitialMat);
            %
            % (temporary) postprocessing
            %
            switch (self.CALC_ALGORITHM)
                case 1
                    dataRtt0Array = normaliz(dataRtt0Array);
                case 3
                    sizeRtt0ArrayVec = size(dataRtt0Array);
                    normVec = dataRtt0Array(sizeRtt0ArrayVec(1), sizeRtt0ArrayVec(2), :);
                    normVec = repmat(normVec, [self.sizeSysVec, 1]);
                    dataRtt0Array = dataRtt0Array(1:(sizeRtt0ArrayVec(1) - 1), :, :);
                    dataRtt0Array = reshape(dataRtt0Array, [self.sizeSysVec, self.N_TIME_POINTS]);
                    dataRtt0Array = dataRtt0Array .* normVec;
            end
            %
            self.Rtt0Dynamics=MatrixInterpolantFactory.createInstance(...
                'column',dataRtt0Array,timeRtt0Vec);
        end
    end
end
%
% new equation for R(t, t0)
%
function dx = fRtt0SimDerivFunc(t, x, fAt)
    cachedMat = fAt(t) * x;
    %
    dx = cachedMat - x * sum(x(:) .* cachedMat(:));
end
%
% (temporary) old equation for X(t, t0)
%
function dx = fXtt0DerivFunc(t, x, fAt)
    dx = fAt(t) * x;
end
%
% (temporary) new equation for R(t, t0) and matrixnorm(X(t, t0))
%
function dx = fRtt0ExtDerivFunc(t, x, fAt, sizeAtVec)
    norm = x(length(x)); x(length(x)) = [];
    sRtt0Mat = reshape(x, sizeAtVec);
    %
    cachedMat = fAt(t) * sRtt0Mat;
    scprod = sum(sRtt0Mat(:) .* cachedMat(:));
    %
    dnorm = scprod * norm;
    dsRtt0Mat = cachedMat - sRtt0Mat * scprod;
    %
    dx = [dsRtt0Mat(:); dnorm];
end
%
% normalizes matrix argMat (matrixnorm(normalizMat) = 1)
%
function normalizMat = normaliz(argMat)
    szVec = size(argMat);
    normMat = argMat .* argMat;
    normMat = sqrt(sum(sum(normMat, 2), 1));
    if (length(szVec) > 2)
        szVec(3:length(szVec)) = 1;
    end
    normMat = repmat(normMat, szVec);
    normalizMat = argMat ./ normMat;
end