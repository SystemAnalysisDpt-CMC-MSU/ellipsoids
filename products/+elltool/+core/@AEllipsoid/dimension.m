function [dimArr,rankArr]=dimension(myEllArr)
%
% DIMENSION - returns the dimension of the space in which the ellipsoid is  
%             defined and the actual dimension of the ellipsoid.
%             
% Input:
%   regular:
%     myEllArr: ABasicEllipsoid[nDims1,nDims2,...,nDimsN] - array 
%       of ABasicEllipsoids.
%
% Output:
%   regular:
%     dimArr: double[nDims1,nDims2,...,nDimsN] - space dimensions.
%
%   optional:
%     rankArr: double[nDims1,nDims2,...,nDimsN] - dimensions of the  
%            ABasicEllipsoids in myEllArr.
% 
% Example:
%   firstEllObj = ellipsoid();
%   tempMatObj = [3 1; 0 1; -2 1]; 
%   secEllObj = ellipsoid([1; -1; 1], tempMatObj*tempMatObj');
%   thirdEllObj = ellipsoid(eye(2));
%   fourthEllObj = ellipsoid(0);
%   ellMat = [firstEllObj secEllObj; thirdEllObj fourthEllObj];
%   [dimMat, rankMat] = ellMat.dimension()
% 
%   dimMat =
% 
%      0     3
%      2     1
% 
%   rankMat =
% 
%      0     2
%      2     0
%
%
%
% $Author: Irina Zhukova <irizka91@gmail.com> $	$Date: 2013-04-19 $ 
% $Copyright: Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
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
% $Author: Alexandr Timchenko  <timchenko.alexandr@gmail.com> $    
% $Date: 12-Dec-2015$
% $Copyright: Moscow State University,
% 			Faculty of Computational Mathematics and Computer Science,
% 			System Analysis Department 2015 $
% 
checkIsMeVirtual(myEllArr);
dimArr=arrayfun(@(x)size(x.getCenterVec(),1),myEllArr);
if nargout>1
    rankArr=arrayfun(@(x)rank(x.getShapeMat()),myEllArr);
end