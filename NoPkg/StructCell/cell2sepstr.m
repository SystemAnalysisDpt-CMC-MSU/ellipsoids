function res=cell2sepstr(titleList,dataCell,sepSymbol,varargin)
% CELL2SEPSTR - converts a cell array into a symbol-separated char array
%
% Usage: res=cell2sepstr(titles,dataCell,sepSymbol,varargin)
%
% Input:
%   regular:
%       titleList: cell[1,nCols]- cell array of column titles
%       dataCell: cell[nRows,nCols] - data cell array
%       sepSymbol: char[1,nSymbs] - sequence used as separator
%
%   properties:
%       isMatlabSyntax: logical[1,1] - forms result according to Matlab
%          syntax(default=0);
%       UniformOutput: logical[1,1] - if true, output is char array, if
%          false - output is cell array; by default true;
%       minSepCount: double[1] - minimal number of separated symbols, by
%           default 1;
%       numPrecision: double[1,1] - number of digits used for displaying
%          numeric values
% output:
%   regular:
%       res: char or cell array
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-06-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[reg,prop]=modgen.common.parseparams(varargin);
if ~isempty(reg)
    error('STRUCT:cell2sepstr:wrongoptional','wrong regular parametr');
end
nProp=length(prop);
isUniformOutput=true;
%
isMatlabSyntax=0;
minSepCount=1;
numPrecision=3;
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'ismatlabsyntax',
            isMatlabSyntax=prop{k+1};
        case 'uniformoutput',
            isUniformOutput=prop{k+1};
        case 'minsepcount'
            minSepCount=prop{k+1};
        case 'numprecision',
            numPrecision=prop{k+1};
        otherwise
            error('STRUCT:cell2sepstr:wrongproperty','unidentified property name: %s',prop{k});
    end;
end;
%
[nRows,nCols] = size(dataCell);
%emptyMatrix = repmat(sepSymbol,nRows+1,1);
nRowsRes=nRows;
if ~isempty(titleList);
    nRowsRes=nRowsRes+1;
    dataCell=[titleList;dataCell];
end
%
%% process data cell
dataCell=cellfun(@cellformatter,dataCell,'UniformOutput',false);
%
%% insert separators
resCell=cell(nRowsRes,1);
for iCol=1:(nCols-1)
    dataColCell=dataCell(:,iCol);
    lenColCell=cellfun(@length,dataColCell,'UniformOutput',false);
    lenColVec=cell2mat(lenColCell);
    maxLength=max(lenColVec(:))+minSepCount;
    sepCell=cellfun(@(x)(repmat(sepSymbol,1,maxLength-x)),lenColCell,'UniformOutput',false);
    resCell=strcat(resCell,strcat(dataCell(:,iCol),sepCell));
    
end
if nRowsRes==0
    nRowsRes=1;
end
if nCols>0
    resCell=strcat(resCell,dataCell(:,end));
else
    resCell=repmat({''},[nRowsRes,1]);
end
%
if isMatlabSyntax
    resCell=cellfun(@horzcat,repmat({'{'},[nRowsRes,1]),resCell,'UniformOutput',false);
    resCell=cellfun(@horzcat,resCell,repmat({'}'},[nRowsRes,1]),'UniformOutput',false);
end
%
%
%% convert to char array if necessary
%
if isUniformOutput,
    res=char(resCell);
else
    res=resCell;
end
    function outCont=cellformatter(inpCont)
        switch class(inpCont)
            case {'double','single'}
                outCont=num2str(inpCont,numPrecision);
            case 'logical',
                outCont=num2str(inpCont);
            case 'struct',
                outCont='<structure>';
            otherwise,
                if isnumeric(inpCont),
                    outCont=num2str(inpCont);
                else
                    outCont=inpCont;
                end
        end
    end
end






%