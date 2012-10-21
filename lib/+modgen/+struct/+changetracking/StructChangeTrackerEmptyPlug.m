classdef StructChangeTrackerEmptyPlug<modgen.struct.changetracking.AStructChangeTracker
    % STRUCTCHANGETRACKEREMPTYPLUG is an empty impementation of ASTRUCTCHANGETRACKER interface
    methods
        function self=StructChangeTrackerEmptyPlug()
        end
        function SInput=applyPatches(self,SInput,~,~,~)
        end
        function [SInput,confVersion]=applyAllLaterPatches(~,SInput,confVersion)
        end

        function lastRev=getLastRevision(self)
            lastRev=-Inf;
        end
    end
    
end
