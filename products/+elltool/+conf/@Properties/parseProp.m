function varargout = parseProp(args,neededPropNameList)
%PARSEPROP - parses input into cell array with values of properties listed 
%            in neededPropNameList. 
%            Values are  taken from args or, if there no value for some 
%            property in args, in current Properties.
%            
%
% Input:
%   regular:
%       args:cell[1,] - cell array of arguments that should be parsed.
%       neededPropNameList:cell[1,] or empty cell - cell array of strings, 
%       containing names of parameters, that output should consist of. 
%       Possible properties:
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
% Output:
%   varargout:cell array[1,] - cell array with values of properties listed
%                              in neededPropNameList in the same order as 
%                              they listed in neededPropNameList
% 
% Example:
%   testAbsTol = 1;
%   testRelTol = 2;
%   nPlot2dPoints = 3;
%   someArg = 4;
%   args = {'absTol',testAbsTol, 'relTol',testRelTol,'nPlot2dPoints',nPlot2dPoints, 'someOtherArg', someArg};
%   neededProp = {'absTol','relTol'};
%   [absTol, relTol] = elltool.conf.Properties.parseProp(args,neededProp)
% 
%   absTol =
% 
%        1
% 
% 
%   relTol =
% 
%        2
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    
%$Date: 2012-11-05 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics 
%            and Computer Science,
%            System Analysis Department 2012 $
%
import elltool.conf.Properties;
import modgen.common.throwerror;
%
propNamesList = {'version','isVerbose','absTol','relTol',...
    'nTimeGridPoints','ODESolverName','isODENormControl','isEnabledOdeSolverOptions',...
    'nPlot2dPoints','nPlot3dPoints'};
%
if isempty(neededPropNameList)
    neededPropNameList = propNamesList;
end
%%
%
SPreProp=Properties.getPropStruct();
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