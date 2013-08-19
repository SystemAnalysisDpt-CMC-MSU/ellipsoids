classdef Properties<modgen.common.obj.StaticPropStorage
    %PROPERTIES - a static class, providing emulation of static properties for
    %             toolbox.
    %
    %$Author: Zakharov Eugene  <justenterrr@gmail.com> $
    %$Date: 2012-11-05 $
    %$Author: Peter Gagarinov  <pgagarinov@gmail.com> $
    %$Date: 2012-11-25 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2012 $
    %
    properties (GetAccess=private,Constant)
        DEFAULT_CONF_NAME='default'
        SETUP_CLASS_NAME_VEC = {'elltool.exttbx.cvx.CVXController',...
            'elltool.exttbx.mpt.MPTController'};
    end
    %
    methods (Static,Access=private)
        function argList=getBasicPropList()
            import elltool.conf.Properties;
            argList={Properties.getAbsTol(),Properties.getRelTol(),...
                Properties.getIsVerbose()};
        end
    end
    methods(Static)
        function checkSettings()
            % Example:
            %   elltool.conf.Properties.checkSettings()
            %
            import elltool.conf.Properties;
            inpArgList=Properties.getBasicPropList();
            cellfun(@check,Properties.SETUP_CLASS_NAME_VEC);
            function check(name)
                obj = feval(name);
                obj.checkSettings(inpArgList{:});
            end
        end
        %
        function init()
            % Example:
            %   elltool.conf.Properties.init()
            import elltool.conf.Properties;
            %
            confRepoMgr=elltool.conf.ConfRepoMgr();
            confRepoMgr.selectConf(Properties.DEFAULT_CONF_NAME);
            Properties.setConfRepoMgr(confRepoMgr);
            %
            inpArgList=Properties.getBasicPropList();
            %setup external toolboxes
            cellfun(@setUpToolbox,Properties.SETUP_CLASS_NAME_VEC);
            %
            %
            function setUpToolbox(name)
                obj = feval(name);
                obj.fullSetup(inpArgList{:});
            end
            elltool.logging.Log4jConfigurator.configure(confRepoMgr,...
                'islockafterconfigure',true);
        end
        %
        function ConfRepoMgr=getConfRepoMgr()
            % Example:
            %   elltool.conf.Properties.getConfRepoMgr()
            %
            %   ans =
            %
            %     elltool.conf.ConfRepoMgr handle
            %     Package: elltool.conf
            %
            %     Properties:
            %       DEFAULT_STORAGE_BRANCH_KEY: '_default'
            %
            
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
            % Example:
            %   prevConfRepo = Properties.getConfRepoMgr();
            %   prevAbsTol = prevConfRepo.getParam('absTol');
            %   elltool.conf.Properties.setConfRepoMgr(prevConfRepo);
            %
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,'ConfRepoMgr',ConfRepoMgr);
        end
        %%
        %Public getters
        function version = getVersion()
            % Example:
            %   elltool.conf.Properties.getVersion();
            %
            version = elltool.conf.Properties.getOption('version');
        end
        %
        function isVerbose = getIsVerbose()
            % Example:
            %   elltool.conf.Properties.getIsVerbose();
            %
            isVerbose = elltool.conf.Properties.getOption('isVerbose');
        end
        %
        function absTol = getAbsTol()
            % Example:
            %   elltool.conf.Properties.getAbsTol();
            %
            absTol = elltool.conf.Properties.getOption('absTol');
        end
        %
        function relTol = getRelTol()
            relTol = elltool.conf.Properties.getOption('relTol');
        end
        %
        function regTol = getRegTol()
            regTol = elltool.conf.Properties.getOption('regTol');
        end
        %
        function nTimeGridPoints = getNTimeGridPoints()
            % Example:
            %   elltool.conf.Properties.getNTimeGridPoints();
            %
            nTimeGridPoints = elltool.conf.Properties.getOption(...
                'nTimeGridPoints');
        end
        %
        function oDESolverName = getODESolverName()
            % Example:
            %   elltool.conf.Properties.getODESolverName();
            %
            oDESolverName = elltool.conf.Properties.getOption(...
                'ODESolverName');
        end
        %
        function isODENormControl = getIsODENormControl()
            % Example:
            %   elltool.conf.Properties.getIsODENormControl();
            %
            isODENormControl = elltool.conf.Properties.getOption(...
                'isODENormControl');
        end
        %
        function isEnabled = getIsEnabledOdeSolverOptions()
            % Example:
            %   elltool.conf.Properties.getIsEnabledOdeSolverOptions();
            %
            isEnabled = elltool.conf.Properties.getOption(...
                'isEnabledOdeSolverOptions');
        end
        %
        function nPlot2dPoints = getNPlot2dPoints()
            % Example:
            %   elltool.conf.Properties.getNPlot2dPoints();
            %
            nPlot2dPoints = elltool.conf.Properties.getOption(...
                'nPlot2dPoints');
        end
        %
        function nPlot3dPoints = getNPlot3dPoints()
            % Example:
            %   elltool.conf.Properties.getNPlot3dPoints();
            %
            nPlot3dPoints = elltool.conf.Properties.getOption(...
                'nPlot3dPoints');
        end
        %%
        %Public setters
        function setIsVerbose(isVerb)
            % Example:
            %   elltool.conf.Properties.setIsVerbose(true);
            %
            elltool.conf.Properties.setOption('isVerbose',isVerb);
        end
        %
        function setNPlot2dPoints(nPlot2dPoints)
            % Example:
            %   elltool.conf.Properties.setNPlot2dPoints(300);
            %
            elltool.conf.Properties.setOption('nPlot2dPoints',...
                nPlot2dPoints);
        end
        %
        function setNTimeGridPoints(nTimeGridPoints)
            % Example:
            %   elltool.conf.Properties.setNTimeGridPoints(300);
            %
            elltool.conf.Properties.setOption('nTimeGridPoints',...
                nTimeGridPoints);
        end
        %
        function setRelTol(value)
            % SETRELTOL - set global relative tolerance
            %
            % Input
            % relTol: double[1,1]
            elltool.conf.Properties.setOption('relTol',value);
        end
        %
        function SProp=getPropStruct()
            % Example:
            %   elltool.conf.Properties.getConfRepoMgr.getCurConf()
            %
            %   ans =
            %
            %                     version: '1.4dev'
            %                   isVerbose: 0
            %                      absTol: 1.0000e-07
            %                      relTol: 1.0000e-05
            %             nTimeGridPoints: 200
            %               ODESolverName: 'ode45'
            %            isODENormControl: 'on'
            %   isEnabledOdeSolverOptions: 0
            %               nPlot2dPoints: 200
            %               nPlot3dPoints: 200
            %                     logging: [1x1 struct]
            %
            SProp=elltool.conf.Properties.getConfRepoMgr.getCurConf();
        end
        %
        varargout = parseProp(args,neededPropNameList)
    end
    methods(Static, Access = private)
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