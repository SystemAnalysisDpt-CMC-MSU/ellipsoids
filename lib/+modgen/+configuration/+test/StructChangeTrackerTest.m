classdef StructChangeTrackerTest<modgen.struct.changetracking.StructChangeTracker
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function SInput=patch_001_alpha(SInput)
            SInput.alpha=1;
        end
        function SInput=patch_103_test(SInput)
            SInput.beta=2;
        end        
    end
    methods 
        function SInput=patch_002_test(~,SInput)
            SInput.beta=3;
        end        
    end
    
end
