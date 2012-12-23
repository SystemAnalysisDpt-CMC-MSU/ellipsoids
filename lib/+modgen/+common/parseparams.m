function [reg, prop]=parseparams(args,propNameList,nRegExpected,nPropExpected)
% PARSEPARAMS behaves exactly as a built-in Matlab function apart from the
% incorrect behavior of Matlab function in cases when the regular argument
% has a character type. Additionally the function allows to avoid a
% misinterpretation of symbolical values of regular parameters via listing
% all the allowed properties
%
% Input:
%   regular:
%       arg: cell[1,] list of input parameters to parse
%
%   optional:
%       propNameList: cell[1,] of char[1,] - list of properties to recognize
%           this parameter can be useful for confusing the symbolical regular
%           arguments with the properties. For instance, if a character
%           value 'alpha' is expected to be recognized as a regular
%           parameter one can just list all the properties in propNameList
%           not including 'alpha' in the list.
%
%         Note: property names are case-insensitive!
%
%       nRegExpected: numeric[1,1]/[1,2] - an expected number of regular
%          arguments/range of regular argument numbers. If the actual
%          number doesn't mach the expected number an exception is thrown.
%
%       nPropExpected: numeric[1,1] - an expected number of properties
%
% Output:
%   reg: cell[1,nRegs] - list of regular arguments
%   prop: cell[1,nProps*2] - list of property name-value pairs
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-06 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.common.*;
isUsePropNamesUsed=false;
if nargin>=2
    if ~(isempty(propNameList)&&isnumeric(propNameList))
        if ischar(propNameList)
            propNameList={propNameList};
        end
        if ~iscellstr(propNameList)
            throwerror('wrongInput',...
                'propNameList is expected to be a cell array of strings');
        end
        propNameList=cellfun(@lower,propNameList,'UniformOutput',false);
        isUsePropNamesUsed=true;
    end
end
%
if ~isUsePropNamesUsed
    isPropCandidateVec=false(size(args));
    isPropCandidateVec(length(args)-1:-2:1)=true;
else
    isPropCandidateVec=true(size(args));
    if numel(isPropCandidateVec)>0
        isPropCandidateVec(end)=false;
    end
end
%    
isPropCandidateVec=isPropCandidateVec&cellfun('isclass',args,'char');
if any(isPropCandidateVec)
    isPropCandidateVec=isPropCandidateVec&cellfun('ndims',args)==2&...
        cellfun('size',args,1)==1;
end
if isUsePropNamesUsed
    isPropSubVec=ismembercellstr(...
        cellfun(@lower,args(isPropCandidateVec),'UniformOutput',false)...
        ,propNameList);
    isPropCandidateVec(isPropCandidateVec)=isPropSubVec;
    if ~isempty(isPropCandidateVec)&&...
            any(isPropCandidateVec&isPropCandidateVec([end,1:end-1]))
        throwerror('wrongParamList','property list is badly formed');
    end
end
indPropVec=find(isPropCandidateVec);
if isempty(indPropVec)
    reg=args;
    prop={};
else
    prop=args(sort([indPropVec,indPropVec+1]));
    propResNameList=args(isPropCandidateVec);
    [isUnique,propUResNameList]=modgen.common.isunique(propResNameList);
    if ~isUnique
        nResProps=length(propResNameList);
        [~,indThereVec]=ismember(propResNameList,propUResNameList);
        nResPropSpecVec=accumarray(indThereVec.',ones(nResProps,1));
        isPropDupVec=nResPropSpecVec>1;
        dupPropListStr=modgen.cell.cellstr2expression(...
            propUResNameList(isPropDupVec));
        throwerror('wrongInput:duplicatePropertiesSpec',...
            sprintf('properties %s are specified more than once',...
            dupPropListStr));
    end
    isPropCandidateVec(indPropVec+1)=true;
    reg=args(~isPropCandidateVec);
end
if nargin>=3
    if isnumeric(nRegExpected)
        if isempty(nRegExpected)
            %do nothing
        elseif numel(nRegExpected)==1&&...
                nRegExpected>=0&&fix(nRegExpected)==nRegExpected
            if numel(reg)~=nRegExpected
                throwerror('wrongParamList',...
                    ['a number of extracted regular parameters (%d) does ',...
                    'not much an expected number(%d)'],numel(reg),nRegExpected);
            end
        elseif numel(nRegExpected)==2&&nRegExpected(1)>=0&&...
                nRegExpected(2)>=nRegExpected(1)&&...
                all(fix(nRegExpected)==nRegExpected)
            nReg=numel(reg);
            if ~(nReg<=nRegExpected(2)&&nReg>=nRegExpected(1))
                throwerror('wrongParamList',...
                    ['a number of extracted regular parameters is ',...
                    'expected to be within range %s'],...
                    mat2str(nRegExpected));
            end
        else
            throwerror('wrongInput',...
            ['nRegExpected is expected to either a positive integer ',...
            'scalar or two-element numeric monotinic integer array ']);
        end
    else
        throwerror('wrongInput',...
            'nRegExpected is expected to be of a numeric type');
    end
end
if nargin==4
    if isempty(nPropExpected)&&isnumeric(nPropExpected)
        %do nothing
    elseif numel(nPropExpected)==1&&isnumeric(nPropExpected)&&...
            nPropExpected>=0&&nPropExpected==fix(nPropExpected)
        if numel(prop)~=(nPropExpected+nPropExpected)
            throwerror('wrongParamList',...
                ['a number of extracted properties (%d) does not much ',...
                'an expected number of properties (%d)'],...
                numel(prop)*0.5,nPropExpected);
        end
    else
        throwerror('wrongInput',...
            'nPropExpected is expected to be a numeric non-negative integer scalar');
    end
end
end

