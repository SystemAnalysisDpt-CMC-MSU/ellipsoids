function [xMat,yVec]=circlepart(nPoints,angleRangeVec)
% CIRCLEPART builds a partition of unit circle into a specified number of
% points within a specified angle range
% 
% Input:
%   regular:
%       nPoints: double[1,1] - number of points to partition the circle
%   optional
%       angleRangeVec: double[1,2] - angle range in radians, default value
%           is [0,2*PI]
%   
% Output:
%   xVec: double[nPoints,1]/[nPoints,2] - coordinates on the unit circle,
%       both x and y coordinates are returned in different columns if the
%       second output argument is not specified, otherwise only x
%       coordinates are returned
%   yVec: double[nPoints,1] - y coordinates of the points on the unit
%       circle
%   
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-31$ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
if nargin<2
    angleRangeVec=[0 2*pi];
end
dphi=(angleRangeVec(2)-angleRangeVec(1))/nPoints;
vphi=transpose(angleRangeVec(1):dphi:angleRangeVec(2));
vphi=vphi(1:end-1);
if nargout==1
    xMat=[cos(vphi) sin(vphi)];
else
    xMat=cos(vphi);yVec=sin(vphi);
end