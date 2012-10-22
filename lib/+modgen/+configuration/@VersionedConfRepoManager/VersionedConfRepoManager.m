classdef VersionedConfRepoManager<modgen.configuration.AdaptiveConfRepoManager&modgen.struct.changetracking.StructChangeTracker
    % VERSIONEDCONFREPOMANAGER is a simple extension of
    % AdaptiveConfRepoManager that provides an ability to define
    % configuration patches as methods of the class
    % (AdaptiveConfRepoManager requires an injection of
    % modgen.struct.changetracking.StructChangeTracker class that is not
    % that convinient). This approach can be used only by experts as the
    % patches have a direct access ot the class internals. To be safe, use
    % AdaptiveConfRepoManager class. To be sorry, use this class
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    %

    methods
        function self=VersionedConfRepoManager(varargin)
            self=self@modgen.struct.changetracking.StructChangeTracker();
            self=self@modgen.configuration.AdaptiveConfRepoManager(varargin{:});
            self.setConfPatchRepo(self);
        end
    end
end