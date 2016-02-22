classdef ReachContTC<elltool.control.test.mlunit.SintTC
    methods(Access=public)
        function self=ReachContTC(varargin)
            self=self@elltool.control.test.mlunit.SintTC(varargin{:});
        end
        function controlObj=getControlBuilder(self,timeout)
            controlObj=elltool.control.ContControlBuilder(self.reachObj,...
                'Timeout',timeout);
        end
    end
end