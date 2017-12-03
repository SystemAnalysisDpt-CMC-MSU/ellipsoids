classdef TolCounter < handle
    %TOLCOUNTER Class to count references to absTol, relTol properties
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    properties (GetAccess = protected)
        absTolCount = 0;
        relTolCount = 0;
    end
    %
    methods (Access = protected)
        function resetTolCounters(self)
           self.absTolCount = 0;
           self.relTolCount = 0;
        end
        function incAbsTolCount(self)
            self.absTolCount = self.absTolCount + 1;
        end
        function incRelTolCount(self)
            self.relTolCount = self.relTolCount + 1;
        end
        function checkMentions(self)
           if self.absTolCount > 0
               msgID = 'TolCounter:absTol';
               msg = 'absTolCount is positive.';
               exception = MException(msgID,msg);
               throw(exception);
           end
           if self.relTolCount > 0
               msgID = 'TolCounter:relTol';
               msg = 'relTolCount is positive.';
               exception = MException(msgID,msg);
               throw(exception);
           end
        end
    end
end

