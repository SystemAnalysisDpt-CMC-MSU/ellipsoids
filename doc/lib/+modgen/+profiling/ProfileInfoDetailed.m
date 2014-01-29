classdef ProfileInfoDetailed<modgen.profiling.ProfileInfo
    % PROFILEINFODETAILED contains detailed profiling info obtaining during
    % exectution of some code
    
    properties (Access=private,Hidden)
        % detailed profile info
        StProfileInfo
    end
    
    methods
        function self=ProfileInfoDetailed()
            % PROFILEINFODETAILED is constructor of ProfileInfoDetailed
            % class
            %
            % Usage: self=ProfileInfoDetailed()
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %
            
            self=self@modgen.profiling.ProfileInfo();
            self.StProfileInfo=[];
        end
        
        function tic(self)
            % TIC starts a stopwatch timer and begins profiling
            %
            % Usage: tic(self)
            %
            % input:
            %   regular:
            %     self: ProfileInfoDetailed [1,1] - class object
            %
            %
            
            self.StProfileInfo=[];
            tic@modgen.profiling.ProfileInfo(self);
            profile on;
        end
        
        function resTime=toc(self)
            % TOC ends profiling and stops the timer, returning the time
            % elapsed in seconds
            %
            % Usage: resTime=toc(self)
            %
            % input:
            %   regular:
            %     self: ProfileInfoDetailed [1,1] - class object
            % output:
            %   regular:
            %     resTime: double [1,1] - time between tic and toc
            %
            %
            
            resTime=toc@modgen.profiling.ProfileInfo(self);
            if isempty(self.StProfileInfo),
                profile off;
                self.StProfileInfo=profile('info');
            end
        end
        
        function StProfileInfo=getProfileInfo(self)
            % GETPROFILEINFO returns structure containing info on profiling
            %
            % Usage: StProfileInfo=getProfileInfo(self)
            %
            % input:
            %   regular:
            %     self: ProfileInfoDetailed [1,1] - class object
            % output:
            %   regular:
            %     StProfileInfo: struct [1,1] - structure containing the
            %         current profiler statistics (see help for PROFILE,
            %         section PROFILE('INFO') for details)
            %
            %
            
            if isempty(self.StProfileInfo),
                error([upper(mfilename),':wrongInput'],...
                    'You must call TOC before calling getProfileInfo');
            end
            StProfileInfo=self.StProfileInfo;
        end
        
        function resTime=processProfileInfo(self,profCaseName)
            % PROCESSPROFILEINFO process obtained profile info
            %
            % Usage: processProfileInfo(self,profCaseName)
            %
            % input:
            %   regular:
            %     self: ProfileInfoDetailed [1,1] - class object
            %   optional:
            %     profCaseName: char [1,] - name of profiling case
            % output:
            %   regular:
            %     resTime: double [1,1] - time between tic and toc
            %
            %
            
            if nargin<2,
                profCaseName='default';
            end
            callerName=modgen.common.getcallername(2);
            profileDir=fileparts(which(callerName));
            resTime=modgen.profiling.profresult('file',...
                self,profCaseName,...
                'callerName',callerName,'profileDir',profileDir);
        end
    end
end