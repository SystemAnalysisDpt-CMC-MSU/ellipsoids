function resObj = run_disc_tests(varargin)
% RUN_DISC_TESTS runs control synthesis tests for discrete systems  
% based on specified patters for markers, test cases, tests names
%
% Input:
%   optional:
%       confNameList: cell[1,nTestConfs] of char[1,] - list of
%           configurations to test, if not specified, all configurations
%           are tested
%   properties:
%       nParallelProcesses: double[1,1] - if nParallelProcesses>1 then
%           tests are run in parallel in the corresponding number of parallel
%           processes (Parallel Toolbox is required)
%       reCache: logical[1,1] - if true, test results are rechaced on disk
%       filter: cell[1,3] with the following elements
%           markerRegExp: char[1,] - regexp for marker AND/OR configuration
%               names, default is '.*' which means 'all cofigs'
%           testCaseRegExp: char[1,] - regexp for test case names, same 
%               default
%           testRegExp: char[1,] - regexp for test names, same default
%
% Output:
%   resObj: mlunitext.text_test_run[1,1] - test result object
%
% Example:
%
%   elltool.control.test.run_cont_tests('filter',{'rot2dAnull',...
%       'elltool.control.test.mlunit.ReachContTC','testReachControl'})
%
%   elltool.control.test.run_cont_tests({'rot2d','rot2dAnull'},...
%       'filter',{'.*',...
%       'elltool.control.test.mlunit.ReachContTC','testReachControl'})
%
%   elltool.control.test.run_cont_tests('nParallelProcesses',12,...
%       'reCache',true,'filter',{'.*',...
%       'elltool.control.test.mlunit.ReachContTC','testReachControl'})
%
%   elltool.control.test.run_cont_tests('filter',{'_IsBackTrueIsEvolveFalse',...
%       '.*','testReachControl'})
%
% $Author: Komarov Yuri <ykomarov94@gmail.com> $
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $
% $Date: 2015-30-10 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2015$
%
confCMat = {
    'rot2d', [1 0], [5 -7; 0 -11];%failed
    'test3d',[1 1],[0.5 -0.5 0];%failed
    'demo3thirdTest',[1 1],[25 -10; -39.649453163147 -29.8921394348145 ;-40 -30];%failed
    'uosc8',[1 1],[-16 14 0 16 4 -30 30 -30;-2.70171475410461 3.83072304725647 0.782252073287964...
        4.26621890068054 1.65324378013611 -5.75018572807312 7.31468987464905 ...
        -5.75018572807312;1 1 1 1 1 1 1 1];
    'ltisys',[1 1],[1 0 1 0 0 0 -1 1;1.89532947540283 0.895329475402832 1.89532947540283...
     0.895329475402832 1.79065895080566 0.895329475402832...
        1.6859884262085 1;2 1 2 1 2 1 2 1];
    'x2dtest',[1 1],[1 -5];%failed
    'demo3secondTest',[1 0],[12 -14; -4.0166437625885 -17.5592541694641;-15 -20];
    'test2dend',[1 0],[10 -12; 9.92501068115234 -12.0749893188477; 9 -13];
    'demo3fourthTest',[1 0], [1.6 1.2 -11.1 -11.6;  1.56499699354172 1.18833233118057 -11.0941661655903...
         -11.5649969935417; 1 1 -11 -11];
    'demo3firstTest',[1 1],[10^(17) 10^(17);10^(30) 10^(30)];
    'demo3firstBackTest',[1 1],[-1.4 0.1; -1.40863134860992 0.108631348609924;-1.5 0.2];
    'empty',[1,1],[-1 0 0 0 -5.3 6 -3 2;-1 1.59722852706909 0 0 -3.46318719387055...
          2.80554294586182 0.194457054138184 -1.19445705413818;-1 2 0 0 -3 2 1 -2];
    'ellDemo3test',[1 1],[1 1];
    'discrFirstTest',[1 1],[1 1];
    'discrSecondTest',[1 1],[1 1];
    'onedir',[1 1],[1 0 0 1 -4 7 -7 6; 1 0.627918422222137 0.627918422222137 1 -0.860407888889313...
          3.23248946666718 -1.9766526222229 2.86040788888931 ;1 1 1 1 1 1 1 1];
    'basic',[1 1],[-0.1 0 0 0 -3 6 -4 2; 0.51117172241211 1.11122131347656 0.555610656738281...
          0 -0.777557373046875 3.77755737304688 -1.77755737304688 1.44438934326172; 1 2 1 0 1 2 0 1];
    'advanced',[1,1],[-1 0 0 0 -5.3 6 -3 2; -2.92020392417908 0.960101962089539...
         -0.960101962089539 0.960101962089539 -3.09176548719406 10.3204588294029...
          -3.96010196208954 3.92020392417908;-3 1 -1 1 -3 10.5 -4 4];
    'osc8',[1 1],[-16 14 0 16 4 -30 0 -30;0.414507150650024 1.44772982597351 0.965559244155884...
          1.51661133766174 1.10332226753235 -0.0676634311676025 0.965559244155884...
        -0.0676634311676025;1 1 1 1 1 1 1 1];
    'testAneNull',[1 0],[-20 10];
    'test2dbad', [1 0], [50 -10]; 
    'varTest', [1 1],[1 1];
    'test2dbad', [1 1], [1 -1];
    };
confCMat=[confCMat,cell(size(confCMat,1),1)];%empty list of outer points
% 
testCaseName='elltool.control.test.mlunit.ReachDiscTC';
resObj=elltool.control.test.run_generic_tests(testCaseName,confCMat,...
    varargin{:});
