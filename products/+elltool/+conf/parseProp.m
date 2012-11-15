function varargout = parseProp(args,neededPropNameList)
%PARSEPROP parses input into sturcture with filds from neededPropNameList
%and values stated in args or in current Properties.
%
%Input:
%   regular:
%       args:cell[1,] - cell array of arguments that should be parsed.
%       neededPropNameList:cell[1,] or empty cell - cell array of strings, containing
%           names of parameters, that output should consist of. Possible
%           properties:
%               version
%               isVerbose
%               absTol
%               relTol
%               nTimeGridPoints
%               ODESolverName
%               isODENormControl
%               isEnabledOdeSolverOptions
%               nPlot2dPoints
%               nPlot3dPoints
%           trying to specify other properties would be regarded as an
%           error.
%
%Output:
%   SProp:struct[1,1] - structure, with fields, specified in neededPropNameList
%                       or all possible fields, if neededPropNameList is
%                       empty cell
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 5-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import elltool.conf.Properties;
import modgen.common.throwerror;
%
propNamesList = {'version','isVerbose','absTol','relTol',...
'nTimeGridPoints','ODESolverName','isODENormControl','isEnabledOdeSolverOptions',...
'nPlot2dPoints','nPlot3dPoints'};
%
if(isempty(neededPropNameList))    
    neededPropNameList = propNamesList;
end
%%
%
SPreProp = struct('version',Properties.getVersion(),...
'isVerbose',Properties.getIsVerbose(),...
'absTol',Properties.getAbsTol(),...
'relTol',Properties.getRelTol(),...
'nTimeGridPoints',Properties.getNTimeGridPoints(),...
'ODESolverName',Properties.getODESolverName(),...
'isODENormControl',Properties.getIsODENormControl,...
'isEnabledOdeSolverOptions',Properties.getIsEnabledOdeSolverOptions(),...
'nPlot2dPoints',Properties.getNPlot2dPoints(),...
'nPlot3dPoints',Properties.getNPlot3dPoints());
%%
%
nProp = size(neededPropNameList,2);
%
[~,parsedInpList] = modgen.common.parseparams(args, neededPropNameList);
%%
%
varargout = cell(1,nProp);
for iProp = 1:nProp
    propInd = find(strcmp(neededPropNameList(iProp),parsedInpList),1,'first');
    if ~isempty(propInd)
        propVal = parsedInpList{propInd+1};
        checkPropAndValue(propVal, neededPropNameList{iProp});
        varargout{iProp} = propVal;
    else
        if ~any(strcmp(neededPropNameList(iProp),propNamesList))
            throwerror('wrongInput',[neededPropNameList{iProp},':no such property']);
        end
        varargout{iProp} = SPreProp.(neededPropNameList{iProp});
    end
end
%
%
function checkPropAndValue(value,property)
import modgen.common.throwerror;
isOk = true;
%
switch property
    case 'version'
        isOk = isa(value, 'char');
    case 'isODENormControl'
        isOk = isa(value, 'char') && any(strcmp(value, {'on','off'}));
    case 'ODESolverName'
        isOk = isa(value,'char') && any(strcmp(value, {'ode45','ode23','ode113'}));
    %
    case {'isVerbose','isEnabledOdeSolverOptions'}
        isOk = isa(value, 'boolean') || (value == 1) || (value == 0);
    %
    case {'absTol','relTol'}
        isOk = isa(value,'double') && (value > 0);
    case {'nTimeGridPoints','nPlot2dPoints','nPlot3dPoints'}
        isOk = isa(value,'double') && (value > 0) && (mod(value,1) == 0);
    
    otherwise
        throwerror('wrongInput',[property,':no such property']);
end
%
if(~isOk)
    throwerror('wrongInput',[property,': wrong value of this property']);
end