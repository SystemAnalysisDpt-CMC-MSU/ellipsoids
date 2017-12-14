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
        absTolCount;
        relTolCount;
        isTesting;
    end
    %
    methods
        function self = TolCounter(varargin)
            self.absTolCount = 0;
            self.relTolCount = 0;
            if nargin > 0 && strcmp(varargin{1},'true')
                self.isTesting = true;
            else
                self.isTesting = false;
            end
        end
    end
    %
    methods (Access = protected)
        function startTolTest(self)
           self.absTolCount = 0;
           self.relTolCount = 0;
           self.isTesting = true;
        end
        function finishTolTest(self)
           self.isTesting = false;
        end
        function incAbsTolCount(self)
            self.absTolCount = self.absTolCount + 1;
            if self.isTesting == true
                self.checkMentions();
            end
        end
        function incRelTolCount(self)
            self.relTolCount = self.relTolCount + 1;
            if self.isTesting == true
                self.checkMentions();
            end
        end
        function checkMentions(self)
           if self.absTolCount > 0 || self.relTolCount > 0
               if self.absTolCount > 0
                   msgID = 'TolCounter:absTol';
               else
                   msgID = 'TolCounter:relTol';
               end
               msg = 'counter is positive';
               exception = MException(msgID, msg);
               throw(exception);
           end
        end
    end
end

