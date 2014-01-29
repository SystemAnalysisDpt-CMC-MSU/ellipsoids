classdef StructChangeTrackerAdv<modgen.struct.changetracking.StructChangeTracker
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function SInput=patch_001_alpha(SInput)
            SInput.alpha1=strcat(SInput.alpha1,'1');
            SInput.alpha5=SInput.alpha5*10;
            SInput.alpha3=1;
        end
        function SInput=patch_103_test(SInput)
            SInput.alpha1=strcat(SInput.alpha1,'103');
            SInput.alpha5=SInput.alpha5*10;
            SInput.alpha3=103;
        end
    end
    methods 
        function SInput=patch_002_test(~,SInput)
            SInput.alpha1=strcat(SInput.alpha1,'2');
            SInput.alpha5=SInput.alpha5*10;
            SInput.alpha3=2;
        end        
    end
    
end
