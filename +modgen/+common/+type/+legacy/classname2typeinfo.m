function STypeInfo=classname2typeinfo(classNameList)
% CLASSNAME2TYPEINFO translates built-in class names into STypeInfo
% definitions
%
% Input: 
%   classNameList: char/cell[1,nNestedLevels]
% 
% Output:
%   STypeInfo: struct[1,1] - type information
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
STypeInfo=struct(modgen.common.type.NestedArrayType.fromClassName(classNameList));




