classdef ReachContTC < elltool.control.test.mlunit.SintTC
 
    methods(Access = public)
        function self = ReachContTC(varargin)
            self = self@elltool.control.test.mlunit.SintTC(varargin{:});
        end

        function controlObj = getControlObj(self)
            controlObj = elltool.control.ContControlBuilder(self.reachObj);
        end
        
    end
end