function [isEqual,reportStr]= structcompare(SX,SY,tol)
% STRUCTCOMPARE compares two structures using the specified tolerance
%
% Input:
%   regular:
%       S1: struct[] - first input structure
%       S2: struct[] - second input structure
%   optional:
%       tol: double[1,] - maximum allowed tolerance, default value is 0
%
% Output:
%   isEqual: logical[1,1] - true if the structures are found equal
%   reportStr: char[1,1] report about the found differences
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-06-05 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

import modgen.struct.structcomparevec;
if nargin<3
    tol=0;
end
%
if ~isequal(size(SX),size(SY));
    isEqual=false;
    reportStr={'sizes are different'};
    return;
end
[isEqualVec,reportStr]=structcomparevec(SX(:),SY(:),tol);
isEqual=all(isEqualVec);




