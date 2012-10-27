function [minArray,indMinSide]=minadv(leftArray,rightArray)
% MINADV works in the same way as the built-in min function but returns
% indMinSize as a second argument which equals 1 if all minimum elements
% can be taken from leftArray, 2 if they all can be taken from rightArray
% and 0 otherwise
%
% Input:
%   regular:
%       leftArray: numeric[nElems1,...,nElemsK]
%       rightArray: numeric[nElems1,...,nElemsK]
% Output:
%   minArray: numeric[nElems1,...,nElemsK] - array composed from minimum
%       elements 
%   indMinSide: double[1,1] - 1 if all minimum elements
%       can be taken from leftArray, 2 if they all can be taken from rightArray
%       and 0 otherwise
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
minArray=min(leftArray,rightArray);
isLeftArray=minArray==leftArray;
indMinSide=0;
if all(isLeftArray)
    indMinSide=1;
elseif ~any(isLeftArray)
    indMinSide=2;
end
    