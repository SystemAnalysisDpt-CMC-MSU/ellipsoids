function valueArray=createarray(className,sizeVec)
% CREATEARRAY creates an array of specified size and type filling it with
% some values
%
% Input:
%   regular:
%       className: char[1,] - class name for a target array
%       sizeVec: numeric[1,] - size for a target array
%
% Output:
%   valueArray className[] - resulting array of size sizeVec
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-25 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
persistent numericTypeList;
if ~ischar(className)
    error([upper(mfilename),':wrongInput'],...
        'className is expected to be a string');
end
%
if ~(isnumeric(sizeVec)&&(modgen.common.isrow(sizeVec)||isempty(sizeVec)))
    error([upper(mfilename),':wrongInput'],...
        'sizeVec is expected to a numeric row-vector');
end
%
if isempty(numericTypeList)
    numericTypeList={'int8','int16','int32','int64','double','logical','single',...
        'uint8','uint16','uint32','uint64','char'};
end
%
nElem=prod(sizeVec);
isNumeric=false;
for iType=1:numel(numericTypeList)
    isNumeric=strcmp(numericTypeList{iType},className);
    if isNumeric
        break
    end
end
%
if isNumeric
    if isempty(sizeVec)
        valueArray=feval(className,[]);
    else
        valueArray=feval(className,zeros(sizeVec));
    end
else
    if isempty(sizeVec)
        valueArray=feval([className,'.empty'],[0 0]);
    elseif nElem==0
        valueArray=feval([className,'.empty'],sizeVec);
    else
        enumMemberList=meta.class.fromName(className).EnumerationMemberList;
        if isempty(enumMemberList)
            valueArray=modgen.common.type.createvaluearray(className,...
                feval(className),sizeVec);
        else
            scalarEnumVal=eval([className,'.',enumMemberList(1).Name]);
            valueArray=repmat(scalarEnumVal,sizeVec);
        end
    end
end