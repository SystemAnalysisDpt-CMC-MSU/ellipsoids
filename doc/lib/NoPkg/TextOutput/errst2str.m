function str=errst2str(S,varargin)
% ERRST2STR converts error structure to string
%
% Usage: str=errst2str(S,indentSize,showHeader)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
% 
isStringify=false;
%
[reg,prop]=parseparams(varargin);
nReg=length(reg);
%
nProp=length(prop);
for k=1:2:nProp
    switch lower(prop{k})
        case 'stringify',
            isStringify=prop{k+1};
    end
end
%
relvErrHeaderStr='------Non-Critical Error------';
critErrHeaderStr='--------CRITICAL ERROR--------';
sepStr='-------------';
if nReg<2
    showHeader=1;
else
    showHeader=reg{2};
end
%
if nReg<1
    indentSize=0;
else
    indentSize=reg{1};
end
%
fieldNames=fieldnames(S);
nFields=length(fieldNames);
nElem=length(S);
%
isRelvalverError=0;
if (isfield(S,'identifier'))
    lasterror('reset');
    if (strncmpi(S.identifier,'Relvalver',length('Relvalver'))),
        isRelvalverError=1;
    end
end
if isRelvalverError,
    headerStr=relvErrHeaderStr;
else
    headerStr=critErrHeaderStr;
end
%
if showHeader
    str={[genindent(indentSize) headerStr]};
else
    str={};
end
%
if (isRelvalverError),
    res=strlinedivide(S.message);
    str=[str;res(2:end)];
else
    for iElem=1:nElem
        if nElem>1
            str=[str;{[genindent(indentSize) '(',num2str(iElem),')',sepStr]}];
            indentSize=indentSize+1;
            %      str=[str;{[genindent(indentSize) sepStr]}];
        end
        %
        for iField=1:nFields
            str=[str;{[genindent(indentSize) '<' fieldNames{iField} '>']}];
            str{end}=[str{end} ':  ' ];
            S1=S(iElem).(fieldNames{iField});
            switch class(S1)
                case {'struct','MException'}
                    str{end}=[str{end} 'struct'];
                    res=strcelljoint(genindent(indentSize),errst2str(S1,indentSize+1,0));
                    str=[str;res];
                case 'char',
                    %the following string is only for fixing a bug on PC platform where file
                    %separator is recognized as escape symbol
                    S1=strrep(S1,'\','/');
                    res=strlinedivide(S1);
                    nCells=length(res);
                    if nCells
                        str{end}=[str{end} res{1}];
                    end
                    if nCells>1
                        str=[str;strcelljoint(genindent(indentSize+1),res(2:end))];
                    end
                case 'double'
                    str{end}=[str{end} mat2str(S1)];
                case 'cell'
                    str{end}=[str{end} 'cell'];
                    if all(cellfun('isclass',S1,'struct')|...
                            cellfun('isclass',S1,'MException')),
                        nCellElems=numel(S1);
                        isnScalar=nCellElems>1;
                        for iCellElem=1:nCellElems,
                            if isnScalar,
                                str=[str;{[genindent(indentSize+1) '(',num2str(iCellElem),')',sepStr]}];
                            end
                            res=strcelljoint(genindent(indentSize),errst2str(S1{iCellElem},indentSize+isnScalar+1,0));
                            str=[str;res];
                        end
                    else
                        className=cellfun(@class,S1,'UniformOutput',false);
                        if all(strcmp(className{1},className(2:end))),
                            className=[className{1} ' type'];
                        else
                            className='different types';
                        end
                        str{end}=[str{end} ' ' mat2str(size(S1)) ' with elements of ' className];
                    end
            end
            %str=[str;{[genindent(indentSize) sepStr]}];
        end
        if nElem>1
            indentSize=indentSize-1;
        end
    end
end
str=[str;{[genindent(indentSize) sepStr]}];
%
if isStringify
    str=cellfun(@(x)[x sprintf('\n')],str,'UniformOutput',false);
    str=[str{:}];
end
function str=genindent(indentSize)
indentStep=3;
str=repmat(' ',[1 indentSize*indentStep]);

function cellStr=strcelljoint(str,cellStr)
%%
nCells=length(cellStr);

for iCell=1:nCells
    cellStr{iCell}=[str cellStr{iCell}];
end