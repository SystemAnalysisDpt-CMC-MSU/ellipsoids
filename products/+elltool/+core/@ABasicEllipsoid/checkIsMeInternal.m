function checkIsMeInternal(objType,ellArr,varargin)
%
% CHECKISME - determine whether input object is object of given type. 
%			And display message and abort function if input object
%			is not object of given type.
%
% Input:
%	regular:
%		objType: scalar[1,1] - type of objects.
%		someObjArr: any[] - any type array of objects.
%
% Example:
%	ellObj = ellipsoid([1; 2], eye(2));
%	ellipsoid.checkIsMe(ellObj)
% 
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com>  
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
if nargin == 2
    modgen.common.checkvar(ellArr,@(x) isa(x,objType),...
        'errorTag','wrongInput',...
        'errorMessage',strcat('input argument must be ',objType));
elseif nargin==3
    modgen.common.checkvar(ellArr,@(x) isa(x,objType),...
        'errorTag','wrongInput','errorMessage',...
        [varargin{1}, strcat(' input argument must be ',objType)]);
else
    modgen.common.checkvar(ellArr,@(x) isa(x,objType),varargin{:});
end