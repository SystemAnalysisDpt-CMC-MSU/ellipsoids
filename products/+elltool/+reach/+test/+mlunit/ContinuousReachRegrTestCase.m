classdef ContinuousReachRegrTestCase < ...
        elltool.reach.test.mlunit.AReachRegrTestCase
    methods
        function self = ContinuousReachRegrTestCase(varargin)
            self = self@elltool.reach.test.mlunit.AReachRegrTestCase(...
                elltool.linsys.LinSysContinuousFactory(), ...
                elltool.reach.ReachContinuousFactory(), ...
                varargin{:});
        end
        function self = testGetEllTubeRel(self)
            mlunitext.assert(all(self.reachObj.get_ia() == ...
                self.reachObj.getEllTubeRel.getEllArray(...
                gras.ellapx.enums.EApproxType.Internal))); 
            mlunitext.assert(all(self.reachObj.get_ea() == ...
                self.reachObj.getEllTubeRel.getEllArray(...
                gras.ellapx.enums.EApproxType.External))); 
        end
        function self = testGetEllTubeUnionRel(self)
            ellTubeRel = self.reachObj.getEllTubeRel();
            ellTubeUnionRel = self.reachObj.getEllTubeUnionRel();
            compFieldList = fieldnames(ellTubeRel());
            [isOk, reportStr] = ...
                ellTubeUnionRel.getFieldProjection(compFieldList). ...
                isEqual(ellTubeRel.getFieldProjection(compFieldList));
            mlunitext.assert(isOk,reportStr);
        end        
    end
end