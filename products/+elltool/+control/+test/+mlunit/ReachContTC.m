classdef ReachContTC<elltool.control.test.mlunit.SintTC
    methods(Access=public)
        function self=ReachContTC(varargin)
            self=self@elltool.control.test.mlunit.SintTC(varargin{:});
        end
        function controlObj=getControlBuilder(self,varargin)
            controlObj=...
                elltool.control.ContControlBuilder(self.reachObj,varargin);
        end
    end
end