function [dimArr, rankArr] = dimension(myEllMat)
% Example:
%   firstEllObj = elltool.core.GenEllipsoid([1; 1], eye(2));
%   secEllObj = elltool.core.GenEllipsoid([0; 5], 2*eye(2));
%   ellVec = [firstEllObj secEllObj];
%   ellVec.dimension()
% 
%   ans =
% 
%        2     2
%
% $Author: Vadim Kaushanskiy <vkaushanskiy@gmail.com> $ $Date: 2012-12-24 $ 
% $Copyright: Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department 2012 $
% 
% import elltool.conf.Properties;
% 
% [mRows, nCols] = size(myEllMat);
% spaceDimMat = zeros(mRows, nCols);
% rankMat = zeros(mRows, nCols);
% 
% for iRows = 1:mRows
%     for jCols = 1:nCols
%         spaceDimMat(iRows, jCols) = numel(myEllMat(iRows, jCols).getCenter());     
%     end
% end
% if nargout > 1
%     for iRows = 1:mRows
%         for jCols = 1:nCols
%             rankMat(iRows, jCols) = rank(myEllMat(iRows, jCols).shapeMat); 
%         end
%     end   
% end
import elltool.conf.Properties;

elltool.core.GenEllipsoid.checkIsMe(myEllMat);

dimArr = arrayfun(@(x) size(x.shapeMat,1), myEllMat);
if nargout > 1
    rankArr = arrayfun(@(x) rank(x.shapeMat), myEllMat);
end