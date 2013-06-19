function [reg,isRegSpecVec,varargout]=parseparext(args,propNameValMat,varargin)
% PARSEPAREXT behaves in the same way as modgen.common.parseparams but
% returns property values in a more convenient form
%
% Input:
%   regular:
%       arg: cell[1,] list of input parameters to parse
%       propNameValMat: cell[1-3,nExpProps] of char[1,]/cell[2,]
%           - list of properties to recognize
%           - and optionally the list of default values for properties
%           - and optionally the list of check strings for properties
%               (see modgen.common.type.simple.checkgen for check string
%                   syntax)
%
%         Note: property names are case-insensitive!
%
%   optional:
%       nRegExpected: numeric[1,1]/[1,2] - an expected number of regular
%          arguments/range of regular argument numbers. If the actual
%          number doesn't mach the expected number an exception is thrown.
%
%       nPropExpected: numeric[1,1] - an expected number of properties
%
%   properties:
%       regCheckList: cell[1,nRegMax] of char[1,] - list of regular
%           parameter check strings
%
%       regDefList: cell[1,nRegMax] of any[] - list of regular parameter
%          values
%       
%       propRetMode: char[1,] - property return mode, the following modes
%           are supported
%               'list' - an aggregated list of specified properties 
%                   is  returned instead of returning each property as 
%                   a separate  output
%               'separate' - each property is returned separately followed
%                   isSpec indicator, this is a default method
%
%       isObligatoryPropVec: logical[1,nExpProp] - indicates whether a
%           corresponding property from propNameValMat is obligatory. This
%           property can only be used when propNameValMat is not empty
%
% Output:
%   reg: cell[1,nRegs] - list of regular parameters
%
%   isRegSpecVec: logical[1,nRegs] - indicates whether a regular argument
%       specified
%   
%   ---------------"list" mode -----------------         
%   prop: cell[1,nFilledProps] 
%   isPropSpecVec: logical[1,nExpProps]
%
%   ---------------"separate" mode
%   prop1Val: any[] - value of the first property specified by propNameValMat
%       ...
%   propNVal: any[] - value of the last property specified by propNameValMat
%
%   isProp1Spec: logical[1,1] - indicates whether the first property is
%       specified
%       ...
%   isPropNSpec: logical[1,1] - indicates whether the last property is
%       specified
%
% Example:
%   [reg,isSpecVec,...
%       propVal1,propVal2,propVal3...
%       isPropVal1,isPropVal2,isPropVal3]=...
%       modgen.common.parseparext({1,2,'prop1',3,'prop2',4},...
%       {'prop1','prop2','prop3';...
%       [],[],5;...
%       'isscalar(x)','isscalar(x)','isnumeric(x)'},...
%       [0 3],...
%       'regDefList',{1,2,3},...
%       'regCheckList',{'isnumeric(x)','isscalar(x)','isnumeric(x)'},...
%       'isObligatoryPropVec',[true true false])
%
% reg =   {1,2,3}
% isSpecVec = [true,true,false]
% propVal1 = 3
% propVal2 = 4
% propVal3 = 5
% isPropVal1 =true
% isPropVal2 =true
% isPropVal3 =false
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-27 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.common.type.simple.*;
import modgen.common.checkvar;
import modgen.common.ismembercellstr;
import modgen.common.throwerror;
%
if ~isempty(propNameValMat)
    if ~(ischar(propNameValMat)&&lib.isrow(propNameValMat)||...
            iscell(propNameValMat)&&ismatrix(propNameValMat)&&...
        (size(propNameValMat,1)==1||size(propNameValMat,1)==2||...
        size(propNameValMat,1)==3&&...
        lib.iscellofstrorfunc(propNameValMat(3,:))&&...
        iscellstr(propNameValMat(1,:))))
        throwerror('wrongInput',...
            'propNameValMat is badly formed');
    end
    %
    propNameList=propNameValMat(1,:);
    if ischar(propNameList)
        propNameList={lower(propNameList)};
    else
        propNameList=lower(propNameList);
    end
    %
    isDefSpec=size(propNameValMat,1)>1;
    isCheckSpec=size(propNameValMat,1)>2;
    isPropNameSpec=true;    
else
    isPropNameSpec=false;    
    isDefSpec=false;
    propNameList=propNameValMat;
    isCheckSpec=false;
end
[inpReg,inpProp]=modgen.common.parseparams(varargin,...
    {'regCheckList','regDefList','propRetMode','isObligatoryPropVec'});
%
if ~isempty(inpReg)&&~isempty(inpReg{1})
    isNRegExpSpec=true;
    nRegExpVec=inpReg{1};
    if numel(nRegExpVec)==1
        nRegExpVec=[nRegExpVec,nRegExpVec];
    end
else
    isNRegExpSpec=false;
    nRegExpVec=[0,Inf];
end
[reg,prop]=modgen.common.parseparams(args,propNameList,inpReg{:});
%
nRegs=length(reg);
isRegDefListSpec=false;
isPropRetModeSpec=false;
isObligatoryPropVecSpec=false;
if ~isempty(inpProp)
    nInpProps=length(inpProp);
    for iInpProp=1:2:nInpProps-1
        switch lower(inpProp{iInpProp})
            case 'regchecklist',
                regCheckList=inpProp{iInpProp+1};
                checkvar(regCheckList,...
                    @(x)iscell(x)&&lib.isrow(x)&&...
                    (~isNRegExpSpec&&numel(x)>=nRegs||...
                    isNRegExpSpec&&numel(x)<=nRegExpVec(2)));
                %
                for iReg=1:nRegs
                    checkgen(reg{iReg},regCheckList{iReg},...
                        sprintf('regular arg #%d',iReg));
                end
            case 'regdeflist',
                regDefList=inpProp{iInpProp+1};
                    checkgen(regDefList,...
                    @(x)iscell(x)&&lib.isrow(x)&&...
                    (isNRegExpSpec&&...
                    numel(x)<=nRegExpVec(2)&&...
                    numel(x)>=nRegExpVec(1)||~isNRegExpSpec));
                isRegDefListSpec=true;
            case 'propretmode',
                propRetMode=inpProp{iInpProp+1};
                checkgen(propRetMode,...
                    @(x)lib.isstring(x)&&any(strcmpi(x,{'list','separate'})));
                propRetMode=lower(propRetMode);
                isPropRetModeSpec=true;
            case 'isobligatorypropvec',
                isObligatoryPropVec=inpProp{iInpProp+1};
                checkgen(isObligatoryPropVec,'islogical(x)&&isrow(x)');
                if ~isPropNameSpec
                    throwerror('wrongInput',...
                        ['isObligatoryPropVec property is allowed only ',...
                        'when property names are specified']);
                end
                isObligatoryPropVecSpec=true;
                %
            otherwise 
                throwerror('wrongInput','Oops, we shouldn''t be here');
        end
    end
end
if ~isPropRetModeSpec
    propRetMode='separate';
end
if ~isPropNameSpec&&strcmp(propRetMode,'separate')
    throwerror([upper(mfilename),':wrongInput'],...
        'propRetMode=separate is not supported for empty propNameValMat');
end
%
if isRegDefListSpec
    nRegDefs=length(regDefList);
    if nRegDefs>nRegs    
        reg=[reg,cell(1,nRegDefs-nRegs)];
        isRegSpecVec=[true(1,nRegs),false(1,nRegDefs-nRegs)];
        for indArg=nRegs+1:nRegDefs
            reg{indArg}=regDefList{indArg};
        end
    else
        isRegSpecVec=true(1,nRegs);
    end
else
    isRegSpecVec=true(1,nRegs);
end
%
nElems=length(prop);
propResNameList=lower(prop(1:2:nElems-1));
propResValList=prop(2:2:nElems);
[isUnique,propUResNameList]=modgen.common.isunique(propResNameList);
if ~isUnique
    nResProps=nElems*0.5;    
    [~,indThereVec]=ismember(propResNameList,propUResNameList);
    nResPropSpecVec=accumarray(indThereVec.',ones(nResProps,1));
    isPropDupVec=nResPropSpecVec>1;
    dupPropListStr=modgen.cell.cellstr2expression(...
        propUResNameList(isPropDupVec));
    throwerror('wrongInput:duplicatePropertiesSpec',...
        sprintf('properties %s are specified more than once',...
        dupPropListStr));
end
%
if isPropNameSpec
    [isPropSpecVec,indLocVec]=ismembercellstr(propNameList,propResNameList);
    propValList=cell(size(propNameList));
    propValList(isPropSpecVec)=propResValList(indLocVec(isPropSpecVec));
    if isDefSpec
        propValList(~isPropSpecVec)=propNameValMat(2,~isPropSpecVec);
    end
    if isCheckSpec&&any(isPropSpecVec)
        cellfun(@checkgen,propValList(isPropSpecVec),...
            propNameValMat(3,isPropSpecVec),...
            strcat('property:',propNameList(isPropSpecVec)));
    end
    nProps=length(propNameList);
else
    isPropSpecVec=true(size(propResNameList));
    propValList=propResValList;
    nProps=length(propResValList);
end
if isObligatoryPropVecSpec
    isObligAndNotSpecVec=~isPropSpecVec&isObligatoryPropVec;
    if any(isObligAndNotSpecVec)
        throwerror('wrongInput',['property(es) %s are obligatory but ',...
            'were not specified'],...
            cell2sepstr([],propNameList(isObligAndNotSpecVec),','));
    end
end
%    
nOut=nargout-2;
switch propRetMode
    case 'list',
        if nOut>2
            throwerror('wrongInput',...
                ['retPropAsList=true so number of ',...
                'output arguments cannot exceed 4']);
        end
        if nOut>0
            if isPropNameSpec
                isPropFilledVec=isPropSpecVec|isDefSpec;
                prop=[propNameList(isPropFilledVec);...
                    propValList(isPropFilledVec)];
                varargout{1}=transpose(prop(:));
            else
                varargout{1}=prop;
            end
            if nOut>1
                varargout{2}=isPropSpecVec;
            end
        end
    case 'separate',
        if nOut>2*nProps
            throwerror('wrongInput',...
                'number of output arguments cannot exceed 2+ 2*nProperties');
        end
        %
        varargout(1:min(nOut,nProps))=propValList(1:min(nOut,nProps));
        if nOut>nProps
            varargout((nProps+1):min(nOut,2*nProps))=...
                num2cell(isPropSpecVec(1:min(nOut-nProps,nProps)));
        end
    otherwise,
        throwerror('wrongInput',...
            'Oops, we shouldn''t be here');
end