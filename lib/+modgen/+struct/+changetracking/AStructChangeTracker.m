classdef AStructChangeTracker<handle
    methods
        function self=AStructChangeTracker()
        end
    end
    methods(Abstract)
        [SInput,lastRev]=applyAllLaterPatches(self,SInput,startRev)
            % APPLYALLLATERPATCHES applies a series of patches up to the latest
            % revision
            % 
            % Input: 
            %   regular:
            %       self: the object itself
            %       SInput: struct[1,1] - input structure
            %       startRev: numeric[1,1] - start revision
            %
            % Output:
            %   SInput: struct[1,1] - updated structure
            %   lastRev: numeric[1,1] - 
            %   
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
        
        SInput=applyPatches(self,SInput,startRev,endRev,isInclusiveVec)
            % APPLYPATCHES applies a series of patches corresponding to the
            % given revision range to the input structure
            % 
            % Input: 
            %   regular:
            %       self: the object itself
            %       SInput: struct[1,1] - input structure
            %       startRev: numeric[1,1] - start revision
            %       endRev: numeric[1,1] - end revision
            %
            %   optional:
            %       isInclusiveVec: logical[1,2] - indicates whether
            %         startRev and endRev specify the revision bounds
            %              inclusively
            %   
            % Output:
            %   SInput: struct[1,1] - updated structure
            %   
            
        lastRev=getLastRevision(self)
            % GETLASTREVISION returns the latest revision number found
            % amonth all the patches defined in the given object
            % 
            % Input:
            %   regular: 
            %       self: the object itself
            % Output:
            %   lastRev: double[1,1] - latest revision number
            %  
            
           
    end
end