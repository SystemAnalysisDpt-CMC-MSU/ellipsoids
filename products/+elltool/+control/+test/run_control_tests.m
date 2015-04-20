function results = run_control_tests(varargin)


import elltool.reach.ReachFactory;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confCMat = {
%     there are three points for each system: the first one is inner, 
%     the second is situated on the bound, the third is external

%     Notice: 
%         it takes much more time to run test for internal points than for external
% 
% %      'checkTime', [1,1]; % internal approximation should be within 
% %                           external appproximation with tolerance 0.000000, 
% %                           actual tolerance is 0.000002, 
% %                           Identifier: GRAS:ELLAPX:SMARTDB:RELS:ELLTUBEBASIC:CHECKINTWITHINEXT:
% %                           wrongInput:internalWithinExternal
%                           
     'varTest', [1 1],[-3 4; -3 4.70281982421875; -3 5]; 
     
% %     'check', [1 1]; %     internal approximation should be within 
% %                           external appproximation with tolerance 0.000000, 
% %                           actual tolerance is 0.000002, 
% %                           Identifier: GRAS:ELLAPX:SMARTDB:RELS:ELLTUBEBASIC:CHECKINTWITHINEXT:
% %                           wrongInput:internalWithinExternal
    'testnull', [1 1],[0.5 0.5; 0.993 0.1208; 2 0.5];
    'testANull', [1 1],[8 -6; -10.0001 12.44415; -10 15];
    'testAneNull',[1 1],[2 5; -1.0999 8.4; -1 10];
    'testA0Cunitball', [1 1],[-4 2.9; -4 3; -4 3.1];
    
    'testA0UInterval', [1 1],[0.5 0.8; 0.9544 0.98174; 1 1];  %fails, on
%                           the external point the final dot product is 0.99987, however, if the
%                           external point is [1, 1.1] the test passes


    'rot2dAnull', [1 1],[3 -10; 11 0; 3 -12];
    'rot2d', [1 1], [5 -7; 0 -11; 7.7 8];
    
    'test2dbad', [1 1], [5 -7; 10.8502758741379 7.6256896853447; 11 8]; %test fails with the external point, 
%                                                   the final dot product is 0.1
  
    
    'empty',[1,1],[-1 0 0 0 -5.3 6 -3 2;-1 1.59722852706909 0 0 -3.46318719387055...
          2.80554294586182 0.194457054138184 -1.19445705413818;-1 2 0 0 -3 2 1 -2]; % isEvolve = true crashed with 
                            % scalProd = 1.2949 and isXoInSet = 1
          
      'advanced',[1,1],[-1 0 0 0 -5.3 6 -3 2; -2.92020392417908 0.960101962089539...
        -0.960101962089539 0.960101962089539 -3.09176548719406 10.3204588294029...
         -3.96010196208954 3.92020392417908;-3 1 -1 1 -3 10.5 -4 4]; %fail, noEvolve: 0.95325while isX0inSet is 0
                            % evolve: 2.1896while isX0inSet is 1


    'basic',[1 1],[-0.1 0 0 0 -3 6 -4 2; 0.51117172241211 1.11122131347656 0.555610656738281...
            0 -0.777557373046875 3.77755737304688 -1.77755737304688 1.44438934326172; 1 2 1 0 1 2 0 1];
%             evolve: 3.0057while isX0inSet is 1
% %             as in 'advanced' the same problem with [-3 1 -1 1 -3 10.5 -4 4];

 
    'demo3firstBackTest',[1 1],[-1.4 0.1; -1.40863134860992 0.108631348609924;-1.5 0.2];
    
    'demo3firstTest',[1 1],[10^(17) 10^(17);10^(30) 10^(30)]; % scale problem for some points 
%                                       because of scale coefficient k 

    'demo3fourthTest',[1 1], [1.6 1.2 -11.1 -11.6;  1.56499699354172 1.18833233118057 -11.0941661655903...
         -11.5649969935417; 1 1 -11 -11];
    'demo3secondTest',[1 1],[12 -14; -4.0166437625885 -17.5592541694641;-15 -20]; 
    'demo3thirdTest',[1 1],[25 -10; -39.649453163147 -29.8921394348145 ;-40 -30];

    'ellDemo3test',[1 1],[1 1]; % scale problem for some points 
%                                       because of scale coefficient k 


    'ltisys',[1 1],[1 0 1 0 0 0 -1 1;1.89532947540283 0.895329475402832 1.89532947540283...
         0.895329475402832 1.79065895080566 0.895329475402832...
         1.6859884262085 1;2 1 2 1 2 1 2 1];%fail, however, presumably
%         there is disturbance in the system 


    'onedir',[1 1],[1 0 0 1 -4 7 -7 6; 1 0.627918422222137 0.627918422222137 1 -0.860407888889313...
          3.23248946666718 -1.9766526222229 2.86040788888931 ;1 1 1 1 1 1 1 1];
    'test3d',[1 1],[0.5 -0.5 0.5; 0.553621858358383 -0.66086557507515 0.768109291791916 ;1 -2 3];

    'test2dend',[1 1],[10 -12; 9.92501068115234 -12.0749893188477; 9 -13]; %fail

    'osc8',[1 1],[-16 14 0 16 4 -30 0 -30;0.414507150650024 1.44772982597351 0.965559244155884...
          1.51661133766174 1.10332226753235 -0.0676634311676025 0.965559244155884...
        -0.0676634311676025;1 1 1 1 1 1 1 1];

    'uosc8',[1 1],[-16 14 0 16 4 -30 30 -30;-2.70171475410461 3.83072304725647 0.782252073287964...
          4.26621890068054 1.65324378013611 -5.75018572807312 7.31468987464905 ...
          -5.75018572807312;1 1 1 1 1 1 1 1];  %fail, however, presumably
%         there is disturbance in the system 

    'x2dtest',[1 1],[-100 50;-97.0051956176758 94.9220657348633;-80 350];
    };      
%
nConfs = size(confCMat, 1);
suiteList = {};
outPointVecList=[];
% 
for iConf = 1:nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};
    inPointVecList  = confCMat{iConf, 3};
    if confTestsVec(1)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.control.test.mlunit.ReachContTC',...
            ReachFactory(confName, crm, crmSys, true, false),...
            inPointVecList , outPointVecList,...
            'marker',[confName,'_IsBackTrueIsEvolveFalse']);
    end 
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.control.test.mlunit.ReachContTC',...
            ReachFactory(confName, crm, crmSys, true, true),...
            inPointVecList , outPointVecList,...
            'marker',[confName,'_IsBackTrueIsEvolveTrue']);
    end 

end
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.MPTIntegrationTestCase');
%%
testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
testList=horzcat(testLists{:});
suite = mlunitext.test_suite(testList);
% suiteFilteredObj = suite.getCopyFiltered(varargin{:}); 
suiteFilteredObj = suite.getCopyFiltered('basic'); 
results = runner.run(suiteFilteredObj);