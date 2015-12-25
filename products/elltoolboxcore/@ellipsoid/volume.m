function volArr=volume(ellArr)
%
% VOLUME - returns the volume of the ellipsoid.
%
%	volArr = VOLUME(ellArr)  Computes the volume of ellipsoids in
%       ellipsoidal array ellArr.
%
%	The volume of ellipsoid E(q, Q) with center q and shape matrix Q 
%	is given by V = S sqrt(det(Q)) where S is the volume of unit ball.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%
% Output:
%	volArr: double [nDims1,nDims2,...,nDimsN] - array of
%   	volume values, same size as ellArr.
%
% Example:
%   firstEllObj = ellipsoid([4 -1; -1 1]);
%   secEllObj = ell_unitball(2);
%   ellVec = [firstEllObj secEllObj]
%   volVec = ellVec.volume()
% 
%   volVec =
% 
%       5.4414     3.1416
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
volArr = arrayfun(@(x) ellSingleVolume(x), ellArr);
end