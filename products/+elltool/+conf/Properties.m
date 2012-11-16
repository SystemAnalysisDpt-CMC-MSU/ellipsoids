classdef Properties<modgen.common.obj.StaticPropStorage
    %PROPERTIES is a static class, providing emulation of static properties
    %for toolbox.
    %
    %$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 5-november-2012 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    methods(Static)
        function ConfRepoMgr=getConfRepoMgr()
            import modgen.common.throwerror;
            branchName=mfilename('class');
            [ConfRepoMgr, isThere] = modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,'ConfRepoMgr',true);
            if ~isThere
                throwerror('notInitialized','Properties.confRepoManager was not inicialised yet');
            end
        end
        %
        function setConfRepoMgr(ConfRepoMgr)
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,'ConfRepoMgr',ConfRepoMgr);
        end
        %%
        %Public getters
        function version = getVersion()
            version = elltool.conf.Properties.getOption('version');
        end
        %
        function isVerbose = getIsVerbose()
            isVerbose = elltool.conf.Properties.getOption('isVerbose');
        end
        %
        function absTol = getAbsTol()
            absTol = elltool.conf.Properties.getOption('absTol');
        end
        %
        function absRel = getRelTol()
            absRel = elltool.conf.Properties.getOption('relTol');
        end
        %
        function nTimeGridPoints = getNTimeGridPoints()
            nTimeGridPoints = elltool.conf.Properties.getOption('nTimeGridPoints');
        end
        %
        function oDESolverName = getODESolverName()
            oDESolverName = elltool.conf.Properties.getOption('ODESolverName');
        end
        %
        function isODENormControl = getIsODENormControl()
            isODENormControl = elltool.conf.Properties.getOption('isODENormControl');
        end
        %
        function isEnabled = getIsEnabledOdeSolverOptions()
            isEnabled = elltool.conf.Properties.getOption('isEnabledOdeSolverOptions');
        end
        %
        function nPlot2dPoints = getNPlot2dPoints()
            nPlot2dPoints = elltool.conf.Properties.getOption('nPlot2dPoints');
        end
        %
        function nPlot3dPoints = getNPlot3dPoints()
            nPlot3dPoints = elltool.conf.Properties.getOption('nPlot3dPoints');
        end
        %%
        %Public setters
        function setIsVerbose(isVerb)
            elltool.conf.Properties.setOption('isVerbose',isVerb);
        end
        %
        function setNPlot2dPoints(nPlot2dPoints)
            elltool.conf.Properties.setOption('nPlot2dPoints',nPlot2dPoints);
        end
        %
        function setNTimeGridPoints(nTimeGridPoints)
            elltool.conf.Properties.setOption('nTimeGridPoints',nTimeGridPoints);
        end
        function varargout = parseProp(args,neededPropNameList)
    end
    methods(Static,Access = private)
        function opt = getOption(optName)
            confRepMgr = elltool.conf.Properties.getConfRepoMgr();
            opt = confRepMgr.getParam(optName);
        end
        %
        function setOption(optName,optVal)
            confRepMgr = elltool.conf.Properties.getConfRepoMgr();
            confRepMgr.setParam(optName,optVal);
        end
    end     
end