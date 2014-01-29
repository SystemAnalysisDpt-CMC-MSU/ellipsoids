classdef ValueBox<handle
    properties
        val
    end
    %
    methods
        function setValue(self,val)
            self.val=val;
        end
        function val=getValue(self)
            val=self.val;
        end
    end
end
