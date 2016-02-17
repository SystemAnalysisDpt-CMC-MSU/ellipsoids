function resObj = run_cont_tests(varargin)
% RUN_CONT_TESTS runs control synthesis tests for continous systems  
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
%               names, default is '.*' which means 'all configs'
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
import elltool.reach.ReachFactory;
%
confCMat = {
    %     there are three points for each system: the first one is inner,
    %     the second is situated on the bound, the third is external
    %
    %     Notice:
    %         it takes much more time to run test for internal points than
    %         for external
    %
    'checkTime', [1,1],[0 -12; 1.9022821866807 -11.8403139922137],[2.0234...
    -11.8403139922137];
    %
    'varTest', [1 1],[-3 4; -3 4.70281982421875],[-3 5];
    'check', [1 1],[0 0; 1.46428316926415 0],[1.46528316926415 0]; 
    'testnull', [1 1],[0.5 0.5; 0.993 0.1208],[2 0.5];
    'testANull', [1 1],[8 -6; -10.0001 12.44415],[-10 15];
    'testAneNull',[1 1],[2 5; -1.0999 8.4],[-1 10];
    'testA0Cunitball', [1 1],[-4 2.9; -4 3],[ -4 3.1];
    'testA0UInterval', [1 1],[0.5 0.8; 0.9544 0.98174],[4.030626880829518 0];
    'rot2dAnull', [1 1],[3 -10; 11 0],[3 -12];
    'rot2d', [1 1], [5 -7; 0 -11],[7.7 8];
    'test2dbad', [1 1], [5 -7; 10.8502758741379 7.6256896853447],[13.5352210986797...
    3.45072092145633];
    %
    'empty',[1,1],[-1 0 0 0 -5.3 6 -3 2;-1 1.59722852706909 0 0 -3.46318719387055...
    2.80554294586182 0.194457054138184 -1.19445705413818],[-1 2 0 0 -3 2 1 -2];
    %
    'advanced',[1,1],[-1 0 0 0 -5.3 6 -3 2; -2.92020392417908 0.960101962089539...
    -0.960101962089539 0.960101962089539 -3.09176548719406 10.3204588294029...
    -3.96010196208954 3.92020392417908],[5.277129437376774 -1.499746278192215...
    -0.615897180920930 -0.100150697895250 -2.785426696857000 6.049038785161450...
    -4.120971020066610 3.060133775615960];
    %
    'basic',[1 1],[-0.1 0 0 0 -3 6 -4 2; 0.51117172241211 1.11122131347656 0.555610656738281...
    0 -0.777557373046875 3.77755737304688 -1.77755737304688 1.44438934326172],...
    [1 2 1 0 1 2 0 1];
    %   
    'demo3firstBackTest',[1 1],[-1.4 0.1; -1.40863134860992 0.108631348609924],...
    [-1.5 0.2];
    %
    'demo3firstTest',[1 1],[10^(17) 10^(17)],[10^(30) 10^(30)];
    'demo3fourthTest',[1 1], [1.6 1.2 -11.1 -11.6;  1.56499699354172 1.18833233118057...
    -11.0941661655903 -11.5649969935417],[1 1 -11 -11];
    %
    'demo3secondTest',[1 1],[12 -14; -4.0166437625885 -17.5592541694641],[-15 -20];
    'demo3thirdTest',[1 1],[25 -10; -39.649453163147 -29.8921394348145],[-40 -30];
    'ellDemo3test',[1 1],[1 1],[1 1]; % QMat is not positive-definite
    %
    'ltisys',[1 1],[1 0 1 0 0 0 -1 1; 1.89532947540283 0.895329475402832...
    1.89532947540283 0.895329475402832 1.79065895080566 0.895329475402832...
    1.6859884262085 1],[5.806706636974377 -1.689787582904996 -0.543773176012340...
    -0.073717413570167 0.398274558192120 -0.182699382894721 -0.081832976288282...
    0.640635162173760];    
    %
    'onedir',[1 1],[1 0 0 1 -4 7 -7 6; 1 0.627918422222137 0.627918422222137 1 -0.860407888889313...
    3.23248946666718 -1.9766526222229 2.86040788888931],[1 1 1 1 1 1 1 1];
    %
    'test3d',[1 1],[0.5 -0.5 0.5; 0.553621858358383 -0.66086557507515 0.768109291791916],[1 -2 3];
    %
    'test2dend',[1 1],[10 -12; 9.92501068115234 -12.0749893188477],...
    [31.861827107790401 19.973969145971530];
    %
    'osc8',[1 1],[-16 14 0 16 4 -30 0 -30;0.414507150650024 1.44772982597351...
    0.965559244155884 1.51661133766174 1.10332226753235 -0.0676634311676025...
    0.965559244155884 -0.0676634311676025],[1 1 1 1 1 1 1 1];
    %
    'uosc8',[1 1],[-16 14 0 16 4 -30 30 -30;-2.70171475410461 3.83072304725647 0.782252073287964...
    4.26621890068054 1.65324378013611 -5.75018572807312 7.31468987464905 ...
    -5.75018572807312], 1.0e+03 * [0.010606000874019 0.056023841922464...
    -2.096946806820620 0.047129584962960 -0.045236237771804...
    0.008111623412550 2.455082381116110 0.022863906693279];
    %
    'x2dtest',[1 1],[-100 50;-97.0051956176758 94.9220657348633],[-80 350];
    };
%
fConstructFactory=...
    @(confName, crm, crmSys, isBack, isEvolve)ReachFactory(...
    confName, crm, crmSys, isBack, isEvolve,false);
%
testCaseName='elltool.control.test.mlunit.ReachContTC';
resObj=elltool.control.test.run_generic_tests(fConstructFactory,...
    testCaseName,confCMat,'',varargin{:});