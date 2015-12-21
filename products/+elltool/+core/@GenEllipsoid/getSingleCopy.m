function copyEllObj = getSingleCopy(ellObj)
% GETCOPY - returns the copy of single GenEllipsoid.
%
% Input:
%	regular:
%		ellObj: GenEllipsoid[1,1] - ellipsoid
%
% Output:
%	copyEllObj: GenEllipsoid[1,1] - copy of given ellipsoid%
% 
% Example:
%	ellObj = GenEllipsoid([-1; 1], [2 0; 0 3]);
%	copyEllObj = getCopy(ellObj)
% 
%	copyEllObj = 
%
%		|    
%		|-- centerVec : [-1 1]
%		|               -----
%		|------- QMat : |2|0|
%		|               |0|3|
%		|               -----
%		|               -----
%		|---- QInfMat : |0|0|
%		|               |0|0|
%		|               -----
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import elltool.core.GenEllipsoid;
GenEllipsoid.checkIsMe(ellObj);
copyEllObj=GenEllipsoid();
copyEllObj.centerVec=ellObj.centerVec;
copyEllObj.diagMat=ellObj.diagMat;
copyEllObj.eigvMat=ellObj.eigvMat;
end