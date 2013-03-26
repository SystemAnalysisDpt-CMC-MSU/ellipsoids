classdef ConfRepoMgr<modgen.configuration.AdaptiveConfRepoManager
    %CONREPOMGR is analogue for elltool.test.configuration.AdaptiveConfRepoManager
    %constructed to provide access for elltool.conf.Properties class to 
    %local xml files, where information about properties is stored.
    %
    % $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    $Date: <5 november> $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department <2012> $
    %
    methods
        function self=ConfRepoMgr(varargin)
            self=self@modgen.configuration.AdaptiveConfRepoManager(varargin{:});
            confPatchRepo=elltool.conf.ConfPatchRepo();
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end