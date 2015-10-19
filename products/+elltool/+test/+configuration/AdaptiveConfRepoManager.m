classdef AdaptiveConfRepoManager<...
        modgen.configuration.AdaptiveConfRepoManagerUpd
% ADAPTIVECONFREPOMANAGER -  a simplistic extension of
%                            AdaptiveConfRepoManager that
%                            injects a configuration change
%                            repository class 
%               equivolent.test.configuration.ConfPatchRepo
%               automatically
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	
% $Date: 2011-05-18 $ 
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2011 $
%
    methods
        function self=AdaptiveConfRepoManager(varargin)
            self=self@modgen.configuration.AdaptiveConfRepoManagerUpd(...
                varargin{:});
            confPatchRepo=elltool.test.configuration.ConfPatchRepo();
            self.deployConfTemplate('*','forceUpdate',true);            
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end