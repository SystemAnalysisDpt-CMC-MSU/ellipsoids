function trArr = trace(inpEllArr)
%
% TRACE - returns the trace of the ellipsoid.
%
%
% Description:
% ------------
%
%    T = TRACE(E)  Computes the trace of ellipsoids in ellipsoidal array E.
%
%
% Output:
% -------
%
%    T - array of trace values, same size as E.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%
%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Rustam Guliev  <glvrst@gmail.com>
%
    
import modgen.common.throwerror;
import modgen.common.type.simple.checkgen;

checkgen(inpEllArr,@(x)isa(x,'ellipsoid'),'Input argument');

if any(isempty(inpEllArr(:)))
    throwerror('wrongInput:emptyEllipsoid','TRACE: input argument is empty.');
end
trArr = arrayfun(@(x) trace(double(x)), inpEllArr);
