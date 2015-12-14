function checkIsMe(ellArr,varargin)
%
% CHECKISME - determine whether input object is ellipsoid. And display
%             message and abort function if input object
%             is not ellipsoid
%
% Input:
%   regular:
%       someObjArr: any[] - any type array of objects.
%
% Example:
%   ellObj = ellipsoid([1; 2], eye(2));
%   ellipsoid.checkIsMe(ellObj)
% 
% % $Author: Rustam Galiev <glvrst@gmail.com> $	$Date: 2012-12-27 $ 
% $Copyright: Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department 2012 $
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com>  
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
checkIsMeInternal('ellipsoid',ellArr,varargin)