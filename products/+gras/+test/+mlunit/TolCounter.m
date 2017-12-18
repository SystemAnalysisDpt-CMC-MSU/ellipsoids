classdef TolCounter < handle
    properties (GetAccess = protected)
        absTolCount;
        relTolCount;
        isTesting;
    end
    %
    methods
        function self = TolCounter(varargin)
            % TolCounter - class that counts number of references to absTol
            % and relTol properties of its subclasses.
            % To count references in subclass, the getters of
            % those properties should be overridden to invoke
            % incAbsTolCount and incRelTolCount methods of TolCounter.
            % Methods startTolTest and finishTolTest should be called at 
            % the beginning and the end of a test method respectively to
            % check if this method does not refer to absTol, relTol
            % properties.
            %
            % Input:
            %     properties:
            %       isTesting: logical[1, 1] - if it is true then the
            %       startTolTest method is automatically called in the 
            %       TolTest constructor (to avoid the startTolTest method 
            %       call in subclass if it is not possible, e.g. in subclass
            %       constructor)
            %
            % Output:
            %   regular:
            %     self - counter object.
            %
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2017$
            self.absTolCount = 0;
            self.relTolCount = 0;
            if nargin > 0 && varargin{1} == true
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
            if self.isTesting
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
               modgen.common.throwerror('Tol counter is positive', ...
                   '%s', msgID);
           end
        end
    end
end

