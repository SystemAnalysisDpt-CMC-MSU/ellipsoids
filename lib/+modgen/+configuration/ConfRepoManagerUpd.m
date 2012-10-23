classdef ConfRepoManagerUpd<modgen.configuration.ConfRepoManager
    % CONFREPOMANAGERUPD is a simplistic extension of
    % ConfRepoManager that updates configuration upon selection
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    %
    methods
        function self=ConfRepoManagerUpd(varargin)
            self=self@modgen.configuration.ConfRepoManager(varargin{:});
        end
        function selectConf(self,confName,varargin)
            % SELECTCONF - selects the specified plain configuration. If
            % the one does not exist it is created from the template
            % configuration. If the latter does not exist an exception is
            % thrown
            %
            %
            self.updateConf(confName);
            selectConf@modgen.configuration.ConfRepoManager(self,...
                confName,varargin{:});
        end
    end
end