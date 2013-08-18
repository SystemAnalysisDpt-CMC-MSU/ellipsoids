function varargout = parseProp(args,neededPropNameList)
% PARSEPROP - parses input into cell array with values of properties listed
%            in neededPropNameList.
%            Values are  taken from args or, if there no value for some
%            property in args, in current Properties.
%
%
% Input:
%   regular:
%       args: cell[1,] of any[] - cell array of arguments that
%           should be parsed.
%   optional
%       neededPropNameList: cell[1,nProp] of char[1,] - cell array of strings
%           containing names of parameters, that output should consist of.
%           The following properties are supported:
%               version
%               isVerbose
%               absTol
%               relTol
%               regTol
%               ODESolverName
%               isODENormControl
%               isEnabledOdeSolverOptions
%               nPlot2dPoints
%               nPlot3dPoints
%               nTimeGridPoints
%           trying to specify other properties would be result in error
%           If neededPropNameList is not specified, the list of all
%           supported properties is assumed.
%
% Output:
%   propVal1:  - value of the first property specified
%                              in neededPropNameList in the same order as
%                              they listed in neededPropNameList
%       ....
%   propValN:  - value of the last property from neededPropNameList
%   restList: cell[1,nRest] - list of the input arguments that were not
%       recognized as properties
%
% Example:
%     testAbsTol = 1;
%     testRelTol = 2;
%     nPlot2dPoints = 3;
%     someArg = 4;
%     args = {'absTol',testAbsTol, 'relTol',testRelTol,'nPlot2dPoints',...
%         nPlot2dPoints, 'someOtherArg', someArg};
%     neededPropList = {'absTol','relTol'};
%     [absTol, relTol,resList]=elltool.conf.Properties.parseProp(args,...
%         neededPropList)
%
%     absTol =
%
%          1
%
%
%     relTol =
%
%          2
%
%
%     resList =
%
%         'nPlot2dPoints'    [3]    'someOtherArg'    [4]
%
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $
% $Author: Gagarinov Peter  <pgagarinov@gmail.com> $
% $Date: 2013-06-05 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2012-2013 $
%
import elltool.conf.Properties;
import modgen.common.throwerror;
import modgen.cell.cellstr2expression;
%
PROP_NAME_LIST = {'version','isVerbose','absTol','relTol','regTol',...
    'ODESolverName','isODENormControl','isEnabledOdeSolverOptions',...
    'nPlot2dPoints','nPlot3dPoints','nTimeGridPoints'};
%
PROP_CHECK_FUNC_LIST={...
    'isstring(x)',... %'version'
    'islogical(x)&&isscalar(x)',...%isVerbose
    @(x)isa(x,'double')&&(x>0),...%absTol
    @(x)isa(x,'double')&&(x>0),...%relTol
    @(x)isa(x,'double')&&(x>0),...%regTol    
    @(x)ischar(x)&& any(strcmp(x, {'ode45','ode23','ode113'})),...%'ODESolverName'
    'islogical(x)',...%'isODENormControl'
    'islogical(x)&&isscalar(x)',...%isEnabledOdeSolverOptions
    @(x)isa(x,'double') &&(x > 0)&&(mod(x,1) == 0),...
    @(x)isa(x,'double') &&(x > 0)&&(mod(x,1) == 0),...
    @(x)isa(x,'double') &&(x > 0)&&(mod(x,1) == 0)...
    };
%%
if nargin<2
    neededPropNameList = PROP_NAME_LIST;
    checkFuncList=PROP_CHECK_FUNC_LIST;
else
    [isThereVec,indThereVec]=ismember(neededPropNameList,PROP_NAME_LIST);
    if ~all(isThereVec)
        throwerror('wrongInput','properties %s are unknown',...
            cellstr2expression(neededPropNameList(~isThereVec)));
    end
    checkFuncList=PROP_CHECK_FUNC_LIST(indThereVec);
end
SPreProp=Properties.getPropStruct();
propDefValList=cellfun(@(x)SPreProp.(x),neededPropNameList,...
    'UniformOutput',false);
nProp=numel(neededPropNameList);
varargout = cell(1,nProp+1);
%
[restList,~,varargout{1:nProp}] = modgen.common.parseparext(args,...
    [neededPropNameList;propDefValList;checkFuncList]);
%%
varargout{nProp+1}=restList;
