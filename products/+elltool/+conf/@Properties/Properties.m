classdef Properties<modgen.common.obj.StaticPropStorage
    %PROPERTIES is a static class, providing emulation of static properties
    %for toolbox.
    %
    %$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 5-november-2012 $
    %$Author: Peter Gagarinov  <pgagarinov@gmail.com> $    $Date: 25-november-2012 $    
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    properties (GetAccess=private,Constant)
        DEFAULT_SOLVER = 'SeDuMi';
        DEFAULT_CONF_NAME='default'
        TOL_FACTOR = 2;
    end
    %
    methods(Static)
        function init()
            import elltool.cvx.CVXController;
            import elltool.conf.Properties;
            %
            confRepoMgr=elltool.conf.ConfRepoMgr();
            confRepoMgr.selectConf(Properties.DEFAULT_CONF_NAME);
            Properties.setConfRepoMgr(confRepoMgr);
            
            elltool.logging.Log4jConfigurator.configure(confRepoMgr)
            % CVX settings.
            elltool.cvx.CVXController.setUpIfNot();
            CVXController.setSolver(Properties.DEFAULT_SOLVER);
            CVXController.setPrecision(...
                Properties.getPrecisionForCVXVec());
            CVXController.setIsVerbosityEnabled(...
                Properties.getIsVerbose());
        end
        %
        function checkSettings()
            import modgen.common.throwerror;
            import elltool.cvx.CVXController;
            import elltool.conf.Properties;
            precisionVec = CVXController.getPrecision();
            solverStr = CVXController.getSolver();
            isVerbosity = CVXController.getIsVerbosityEnabled();
            if (~isequal(precisionVec, ...
                    Properties.getPrecisionForCVXVec())) || ...
                    (~(strcmp(solverStr, Properties.DEFAULT_SOLVER))) ...
                    || (isVerbosity ~= Properties.getIsVerbose())
                throwerror('cvxError', 'wrong cvx properties');
            end
        end
        %
        function ConfRepoMgr=getConfRepoMgr()
            import modgen.common.throwerror;
            branchName=mfilename('class');
            [ConfRepoMgr, isThere] = getCrm();
            if ~isThere
                elltool.conf.Properties.init();
                [ConfRepoMgr, isThere] = getCrm();
                if ~isThere
                    throwerror('noConfRepoMgr',...
                        'cannot initialize Configuration Repo Manager');
                end
            end
            %
            function [ConfRepoMgr, isThere]=getCrm()
                [ConfRepoMgr, isThere] = ...
                    modgen.common.obj.StaticPropStorage.getPropInternal(...
                    branchName,'ConfRepoMgr',true);
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
            nTimeGridPoints = elltool.conf.Properties.getOption(...
                'nTimeGridPoints');
        end
        %
        function oDESolverName = getODESolverName()
            oDESolverName = elltool.conf.Properties.getOption(...
                'ODESolverName');
        end
        %
        function isODENormControl = getIsODENormControl()
            isODENormControl = elltool.conf.Properties.getOption(...
                'isODENormControl');
        end
        %
        function isEnabled = getIsEnabledOdeSolverOptions()
            isEnabled = elltool.conf.Properties.getOption(...
                'isEnabledOdeSolverOptions');
        end
        %
        function nPlot2dPoints = getNPlot2dPoints()
            nPlot2dPoints = elltool.conf.Properties.getOption(...
                'nPlot2dPoints');
        end
        %
        function nPlot3dPoints = getNPlot3dPoints()
            nPlot3dPoints = elltool.conf.Properties.getOption(...
                'nPlot3dPoints');
        end
        %%
        %Public setters
        
        function setIsVerbose(isVerb)
            elltool.conf.Properties.setOption('isVerbose',isVerb);
        end
        %
        function setNPlot2dPoints(nPlot2dPoints)
            elltool.conf.Properties.setOption('nPlot2dPoints',...
                nPlot2dPoints);
        end
        %
        function setNTimeGridPoints(nTimeGridPoints)
            elltool.conf.Properties.setOption('nTimeGridPoints',...
                nTimeGridPoints);
        end
        %
        function SProp=getPropStruct()
            SProp=elltool.conf.Properties.getConfRepoMgr.getCurConf();
        end
        %
        varargout = parseProp(args,neededPropNameList)
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
        function relTolVec = getPrecisionForCVXVec()
            import elltool.conf.Properties;
            relTol = Properties.getRelTol();
            relTolVec = [0, 0, Properties.TOL_FACTOR*relTol];
        end
    end
end