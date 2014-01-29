classdef PropertiesTestCase < mlunitext.test_case
% PUTCOPYRIGHTHERE
%$Author: <Zakharov Eugene>  <justenterrr@gmail.com> $
%$Date: 2012-11-05$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics 
%            and Computer Science,
%            System Analysis Department <2012> $
%
    properties (Access=private)
        confName
    end
    %
    methods 
        function self = PropertiesTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            self.confName=className;     
        end
        %
        function self = testGetAndSet(self)
            %remember previous ConfRepoMgr to restore it after test
            import elltool.conf.Properties;
            prevConfRepo = Properties.getConfRepoMgr();
            prevAbsTol = prevConfRepo.getParam('absTol');
            %%
            %testing getters
            confRepo = elltool.conf.ConfRepoMgr();
            elltool.copyconf('default',self.confName);
            confRepo.selectConf(self.confName);
            %
            version = 'my string';
            verbose = true;
            absTol = 0.237*prevAbsTol;
            relTol = 3e-7;
            timeGrid = 300; 
            odeSolver = 2;
            normControl = 'on';
            solverOptions = true;
            plot2dGrid = 117;
            plot3dGrid = 118;
            %
            confRepo.setParam('version',version);
            confRepo.setParam('isVerbose',verbose);
            confRepo.setParam('absTol',absTol);
            confRepo.setParam('relTol',relTol);
            confRepo.setParam('nTimeGridPoints',timeGrid);
            confRepo.setParam('ODESolverName',odeSolver);
            confRepo.setParam('isODENormControl',normControl);
            confRepo.setParam('isEnabledOdeSolverOptions',solverOptions);
            confRepo.setParam('nPlot2dPoints',plot2dGrid);
            confRepo.setParam('nPlot3dPoints',plot3dGrid);
            %
            Properties.setConfRepoMgr(confRepo);
            mlunitext.assert_equals(version,Properties.getVersion());
            mlunitext.assert_equals(verbose,Properties.getIsVerbose());
            mlunitext.assert_equals(absTol,Properties.getAbsTol());
            mlunitext.assert_equals(relTol,Properties.getRelTol());
            mlunitext.assert_equals(timeGrid,Properties.getNTimeGridPoints());
            mlunitext.assert_equals(odeSolver,Properties.getODESolverName());
            mlunitext.assert_equals(normControl,Properties.getIsODENormControl());
            mlunitext.assert_equals(solverOptions,Properties.getIsEnabledOdeSolverOptions());
            mlunitext.assert_equals(plot2dGrid,Properties.getNPlot2dPoints());
            mlunitext.assert_equals(plot3dGrid,Properties.getNPlot3dPoints());
            %%
            %testing setters
            Properties.setIsVerbose(~verbose);
            Properties.setNPlot2dPoints(plot2dGrid - 1);
            Properties.setNTimeGridPoints(timeGrid + 1);
            %
            mlunitext.assert_equals(~verbose,Properties.getIsVerbose());
            mlunitext.assert_equals(plot2dGrid-1,Properties.getNPlot2dPoints());
            mlunitext.assert_equals(timeGrid+1,Properties.getNTimeGridPoints());
%             %%
%             %negative test, trying to access one of properties, before
%             %Properties were initialized
%             Properties.flush();
%             self.runAndCheckError('Properties.getRelTol()','notInitialized');
            %%
            %placing previous confRepoMgr back and testing if absTol
            %not changed
            Properties.setConfRepoMgr(prevConfRepo);
            mlunitext.assert_equals(prevAbsTol,Properties.getAbsTol());   
        end
        function self = testParseProp(self)
            %Positive test
            testAbsTol = 1;
            testRelTol = 2;
            nPlot2dPoints = 3;
            someArg = 4;
            args = {'absTol',testAbsTol, 'relTol',testRelTol,'nPlot2dPoints',nPlot2dPoints, 'someOtherArg', someArg};
            neededProp = {'absTol','relTol'};
            [absTol, relTol] = elltool.conf.Properties.parseProp(args,neededProp);
            isOk = (absTol == testAbsTol) && (relTol == testRelTol);
            mlunitext.assert(isOk);
            %Negative test
            args{2} = -absTol;
            self.runAndCheckError('elltool.conf.Properties.parseProp(args,neededProp)','wrongInput');
            args{2} = absTol;
            neededProp{2} = 'notAProperty';
            self.runAndCheckError('elltool.conf.Properties.parseProp(args,neededProp)','wrongInput');
        end
    end
    
end