function copyEllObj = getSingleCopy(ellObj)
% GETCOPY - returns the copy of single ellipsoid.
%
% Input:
%	regular:
%		ellObj: ellipsoid[1,1] - ellipsoid
%
% Output:
%	copyEllObj: ellipsoid[1,1] - copy of given ellipsoid
% 
% Example:
%	ellObj = ellipsoid([-1; 1], [2 0; 0 3]);
%	copyEllObj = getCopy(ellObj)
% 
%	-------ellipsoid object-------
%	Properties:
%		|    
%		|-- actualClass : 'ellipsoid'
%		|--------- size : [1 1]
%
%	Fields (name, type, description):
%		Q    double    Ellipsoid shape matrix.
%		q    double    Ellipsoid center vector.
%
%	Data: 
%		|    
%		|-- centerVec : [-1 1]
%		|               -----
%		|--- shapeMat : |2|0|
%		|               |0|3|
%		|               -----
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
ellipsoid.checkIsMe(ellObj);
copyEllObj=feval(class(ellObj));
copyEllObj.centerVec=ellObj.centerVec;
copyEllObj.shapeMat=ellObj.shapeMat;
copyEllObj.absTol=ellObj.absTol;
copyEllObj.relTol=ellObj.relTol;
copyEllObj.nPlot2dPoints=ellObj.nPlot2dPoints;
copyEllObj.nPlot3dPoints=ellObj.nPlot3dPoints;
end