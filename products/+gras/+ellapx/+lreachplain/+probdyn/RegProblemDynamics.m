classdef RegProblemDynamics <...
        gras.ellapx.lreachplain.probdyn.PlainWrapperProbDynamics
    properties (Access = protected)
        fMatPosHandle
        fAMatRegHandle
        isJustCheck
        regTol
    end
    methods
        function self = RegProblemDynamics(pDynObj, isJustCheck, regTol,isRegAt)
            if nargin<4
                isRegAt=false;
            end
            self=self@gras.ellapx.lreachplain.probdyn.PlainWrapperProbDynamics(...
                pDynObj);
            %
            if isJustCheck
                self.fMatPosHandle=@(x)gras.mat.MatrixPosCheck(x, regTol);
                if isRegAt
                    self.fAMatRegHandle=@(x)gras.mat.MatrixRegCheck(x,...
                        regTol);
                else
                    self.fAMatRegHandle=@deal;
                end
            else
                self.fMatPosHandle=@(x)gras.mat.MatrixPosReg(x, regTol);
                if isRegAt
                    self.fAMatRegHandle=@(x)gras.mat.MatrixReg(x,regTol);
                else
                    self.fAMatRegHandle=@deal;
                end
            end
            self.isJustCheck = isJustCheck;
            self.regTol = regTol;
        end
        function BPBTransDynamics = getBPBTransDynamics(self)
            BPBTransDynamics =...
                self.fMatPosHandle(self.pDynObj.getBPBTransDynamics());
        end
        function AtDynamics = getAtDynamics(self)
            AtDynamics = self.fAMatRegHandle(self.pDynObj.getAtDynamics());
        end
        function X0Mat=getX0Mat(self)
            if self.isJustCheck
                X0Mat = self.pDynObj.getX0Mat();
                modgen.common.type.simple.checkgen(X0Mat,...
                    @(x) gras.la.ismatposdef(x, self.regTol));
            else
                X0Mat = gras.la.regposdefmat(...
                    self.pDynObj.getX0Mat(), self.regTol);
            end
        end
    end
end