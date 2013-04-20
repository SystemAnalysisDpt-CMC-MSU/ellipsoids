classdef RegProblemDynamics <...
        gras.ellapx.lreachplain.probdyn.RegProblemDynamics &...
        gras.ellapx.lreachuncert.probdyn.IReachProblemDynamics
    methods
        function self = RegProblemDynamics(varargin)
            self =...
                self@gras.ellapx.lreachplain.probdyn.RegProblemDynamics(...
                varargin{:});
        end
        function CqtDynamics = getCqtDynamics(self)
            CqtDynamics = self.pDynObj.getCqtDynamics();
        end
        function CQCTransDynamics = getCQCTransDynamics(self)
            CQCTransDynamics =...
                self.fMatPosHandle(self.pDynObj.getCQCTransDynamics());
        end
    end
end


