classdef AdpConfRepoMgrUpd<modgen.configuration.AdaptiveConfRepoManagerUpd&...
        modgen.configuration.test.StructChangeTrackerTest
    %CONFIGURATIONREADERTEST Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function self=AdpConfRepoMgrUpd(varargin)
            self=self@modgen.configuration.AdaptiveConfRepoManagerUpd(varargin{:});
            self.setConfPatchRepo(modgen.configuration.test.StructChangeTrackerTest());
        end
    end
end
