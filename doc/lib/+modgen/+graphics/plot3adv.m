function h=plot3adv(xVec,yVec,zVec,colorMat,varargin)
% PLOT3ADV works similarly to the built-in plot3 function but based on
% build-in "patch" function instead
%
% Input:
%   regular:
%       xVec: double[nPoints,1] - vector of x coordinates
%       yVec: double[nPoints,1] - vector of x coordinates
%       zVec: double[nPoints,1] - vector of x coordinates
%       colorMat: double[nPoints,3] - matrix with rgb colors of individual
%           line points
%   properties:
%       any property accepted by patch function
%
% Output:
%   h: graphic handle[1,1]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-05 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
modgen.common.type.simple.checkgenext(...
    ['iscol(x1)&&iscol(x2)&&iscol(x3)&&(numel(x1)==numel(x2))&&',...
    '(numel(x2)==numel(x3))'],3,xVec,yVec,zVec);
nPoints=length(xVec);
if nPoints==1
    h=line(xVec,yVec,zVec,...
        varargin{:},'Color',colorMat,'Marker','.');
else
    vMat=[xVec,yVec,zVec];
    indVec=transpose(1:(size(vMat,1)-1));
    fMat=[indVec indVec indVec+1];
    %
    h=patch('FaceColor','interp','EdgeColor','interp',...
        'FaceVertexCData',colorMat,...
        'Faces',fMat,'Vertices',vMat,varargin{:});
end