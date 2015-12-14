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
%   ellObj = GenEllipsoid([1; 2], eye(2));
%   GenEllipsoid.checkIsMe(ellObj)
% 
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com>  
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
checkIsMeInternal('elltool.core.GenEllipsoid',ellArr,varargin)