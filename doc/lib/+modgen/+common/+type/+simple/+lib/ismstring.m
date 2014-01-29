function isPositive=ismstring(inpArray)
isPositive=isequal(inpArray,'')||(modgen.common.isrow(inpArray)&&ischar(inpArray));