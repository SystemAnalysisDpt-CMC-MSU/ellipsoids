function checkIsMe(ellArr,varargin)
%
% CHECKISME - determine whether input object is hyperplane. And display
%             message and abort function if input object
%             is not hyperplane
%
% Input:
%   regular:
%       someObjArr: any[] - any type array of objects.
% 
% Example:
%   hypObj = hyperplane([-2, 0]);
%   hyperplane.checkIsMe(hypObj)
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  
% $Date: 30-11-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012 $
hyperplane.checkIsMeInternal('hyperplane',ellArr,varargin)
