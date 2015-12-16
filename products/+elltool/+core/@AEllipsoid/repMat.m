function resArr=repMat(self,varargin)
% REPMAT -  is analogous to built-in repmat function with
%           one exception - it copies the objects, not
%           just the handles
% Example:
%   firstEllObj = ellipsoid([1; 2], eye(2));
%   secEllObj = ellipsoid([1; 1], 2*eye(2));
%   ellVec = [firstEllObj secEllObj];
%   repMat(ellVec)
%
%   ans =
%   1x2 array of ellipsoids.
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $
% $Date: 24-04-2013$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012-2013 $
%
%
sizeVec=horzcat(varargin{:});
resArr=repmat(self,sizeVec);
resArr=resArr.getCopy();
end