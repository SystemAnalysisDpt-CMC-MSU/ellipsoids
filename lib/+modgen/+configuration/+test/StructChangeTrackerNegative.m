classdef StructChangeTrackerNegative<modgen.struct.changetracking.StructChangeTracker
    properties
    end
    
    methods (Static)
        function SInput=patch_001_alpha(SInput)
            SInput.alpha=1;
        end
        function SInput=patch_103_test(SInput)
            modgen.common.throwerror('artificialPatchApplicationError',...
                'artificially generated exception');
        end        
    end
    methods 
        function SInput=patch_002_test(~,SInput)
            SInput.beta=3;
        end        
    end
end
