function ResStruct=auxfieldfilterstruct(InpStruct,field2KeepList,isCheckField)
% AUXFIELDFILTERSTRUCT leaves in input structure array only specified
% fields
% 
% Usage: ResStruct=auxfieldfilterstruct(InpStruct,field2KeepList)
%
% input:
%   regular:
%       mandatory:
%           inpStruct: struct[multydimensional] - struct array;
%           field2KeepList: cell[1,nFields] - names of fields to leave;
%       optional:
%           isCheckField: logical[1] - if it is true all names from
%                   field2KeepList have to be names of fields from
%                   InpStruct or function displays error message;
%                   by default false;
% output:
%   regular:
%      ResStruct: struct[multydimensional] - struct array of the same size
%               as inpStruct;
%       
% Example:  ResStruct=auxfieldfilterstruct(InpStruct,{'a','b'})
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
% isCheckField
%

if nargin<3
    isCheckField=false;
end
if isempty(field2KeepList)
    ResStruct=InpStruct;
    return;
end
%
if ischar(field2KeepList)
    field2KeepList={field2KeepList};
end

initFieldList=fieldnames(InpStruct);
fieldList=setdiff(initFieldList,field2KeepList);
ResStruct=rmfield(InpStruct,fieldList);

if isCheckField
    isExist=ismember(field2KeepList,initFieldList);
    if ~all(isExist(:))
        indBad= find(~isExist,1,'first');
        error('STRUCT:auxfieldfilterstruct:wrongfieldname','InpStruct does not contain %s field', field2KeepList{indBad});
    end
end