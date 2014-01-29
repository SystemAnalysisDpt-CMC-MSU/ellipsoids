function relDataObj=fromStructList(className,structList)
% FROMSTRUCTLIST - creates a dynamic relation from a list of structures 
%                  interpreting each structure as the data for
%                  several tuples.
%
% Input:
%   regular:
%       className: name of object class which will be created,
%           the class constructor should accept 2 properties:
%           'fieldNameList' and 'fieldTypeSpecList'
%
%       structList: cell[] of struct[1,1] - list of structures
%
% Output:
%   relDataObj: smartdb.relations.DynamicRelation[1,1] -
%      constructed relation
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
relDataObj=fromStructList@smartdb.cubes.CubeStruct(1,className,...
    structList);