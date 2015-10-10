function resStr=obj2plainstr(meObj)
%OBJ2PLAINSTR does the same as OBJ2STR but without using the
%hyper-references and via a legacy function errst2str
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
resCStr=cellfun(@(x)sprintf('%s\n',x),...
    errst2str(meObj),'UniformOutput',false);
resStr=[resCStr{:}];
end
function str=errst2str(S,indentSize,isHeaderShow)
% ERRST2STR converts error structure to string
%
if nargin<3
    isHeaderShow=true;
    if nargin<2
        indentSize=0;
    end
end
%
critErrHeaderStr='--------CRITICAL ERROR--------';
sepStr='-------------';
%
fieldNames=fieldnames(S);
nFields=length(fieldNames);
nElem=length(S);
%
headerStr=critErrHeaderStr;
%
if isHeaderShow
    str={[genindent(indentSize) headerStr]};
else
    str={};
end
%
for iElem=1:nElem
    if nElem>1
        str=[str;{[genindent(indentSize) '(',num2str(iElem),')',sepStr]}];
        indentSize=indentSize+1;
    end
    %
    for iField=1:nFields
        str=[str;{[genindent(indentSize) '<' fieldNames{iField} '>']}];
        str{end}=[str{end} ':  ' ];
        S1=S(iElem).(fieldNames{iField});
        switch class(S1)
            case {'struct','MException'}
                str{end}=[str{end} 'struct'];
                res=strcelljoint(genindent(indentSize),...
                    errst2str(S1,indentSize+1,0));
                str=[str;res];
            case 'char',
                %the following string is only for fixing a bug on
                % PC platform where file separator is recognized as
                % escape symbol
                S1=strrep(S1,'\','/');
                res=strsplit(S1,char(10)).';
                nCells=length(res);
                if nCells
                    str{end}=[str{end} res{1}];
                end
                if nCells>1
                    str=[str;strcelljoint(genindent(indentSize+1),...
                        res(2:end))];
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
                            str=[str;{[genindent(indentSize+1)...
                                '(',num2str(iCellElem),')',sepStr]}];
                        end
                        res=strcelljoint(genindent(indentSize),...
                            errst2str(S1{iCellElem},...
                            indentSize+isnScalar+1,0));
                        str=[str;res];
                    end
                else
                    className=cellfun(@class,S1,'UniformOutput',false);
                    if all(strcmp(className{1},className(2:end))),
                        className=[className{1} ' type'];
                    else
                        className='different types';
                    end
                    str{end}=[str{end} ' ' mat2str(size(S1))...
                        ' with elements of ' className];
                end
        end
    end
    if nElem>1
        indentSize=indentSize-1;
    end
end
str=[str;{[genindent(indentSize) sepStr]}];
%
end
function str=genindent(indentSize)
indentStep=3;
str=repmat(' ',[1 indentSize*indentStep]);
end
function cellStr=strcelljoint(str,cellStr)
%%
nCells=length(cellStr);

for iCell=1:nCells
    cellStr{iCell}=[str cellStr{iCell}];
end
end