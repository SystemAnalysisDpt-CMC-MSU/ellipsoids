function isPositive=isvec(inpArray)
isPositive=length(inpArray)==numel(inpArray)&&ndims(inpArray)<=2;