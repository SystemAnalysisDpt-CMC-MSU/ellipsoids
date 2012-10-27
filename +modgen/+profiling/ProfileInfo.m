classdef ProfileInfo<handle
    % PROFILEINFO contains profiling info obtaining during exectution of
    % some code
    
    properties (Access=private,Hidden)
        % start time of profiling
        tStart
        % elapsed time of profiling
        tElapsed
    end
    
    methods
        function self=ProfileInfo()
            % PROFILEINFO is constructor of ProfileInfo class
            %
            % Usage: self=ProfileInfo()
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %
            
            self.tStart=[];
            self.tElapsed=[];
        end
        
        function tic(self)
            % TIC starts a stopwatch timer and begins profiling
            %
            % Usage: tic(self)
            %
            % input:
            %   regular:
            %     self: ProfileInfo [1,1] - class object
            %
            %
            
            self.tStart=tic;
            self.tElapsed=[];
        end
        
        function resTime=toc(self)
            % TOC ends profiling and stops the timer, returning the time
            % elapsed in seconds
            %
            % Usage: resTime=toc(self)
            %
            % input:
            %   regular:
            %     self: ProfileInfo [1,1] - class object
            % output:
            %   regular:
            %     resTime: double [1,1] - time between tic and toc
            %
            %
            
            if ~isempty(self.tElapsed),
                resTime=self.tElapsed;
            elseif ~isempty(self.tStart),
                resTime=toc(self.tStart);
                self.tElapsed=resTime;
            else
                error([upper(mfilename),':wrongInput'],...
                    'You must call TIC before calling TOC');
            end
        end
        
        function resTime=processProfileInfo(self,profCaseName) %#ok<INUSD>
            % PROCESSPROFILEINFO process obtained profile info
            %
            % Usage: processProfileInfo(self,profCaseName)
            %
            % input:
            %   regular:
            %     self: ProfileInfo [1,1] - class object
            %   optional:
            %     profCaseName: char [1,] - name of profiling case
            % output:
            %   regular:
            %     resTime: double [1,1] - time between tic and toc
            %
            %
            
            resTime=self.toc();
        end
    end
end