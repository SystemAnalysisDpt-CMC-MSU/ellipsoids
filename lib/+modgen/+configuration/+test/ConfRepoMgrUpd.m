classdef ConfRepoMgrUpd<modgen.configuration.ConfRepoManagerUpd&...
        modgen.configuration.test.StructChangeTrackerTest
    %CONFIGURATIONREADERTEST Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function self=ConfRepoMgrUpd(varargin)
            self=self@modgen.configuration.ConfRepoManagerUpd(varargin{:});
            self.setConfPatchRepo(modgen.configuration.test.StructChangeTrackerTest());
        end
    end
end
