function hLightVec=lightaxis(hAxes,lightCoordList,powerVec,lightStyleList)
% LIGHTAXIS creates a set of light objects surrounding patch and surface
% objects from the specified axis
%   
% Input:
%   regular:
%       hAxes: double[1,1] - handle of axis object
%
%       lightCoordList: cell[1,nLights] of double[1,3] - coordinates of
%           light objects in normalized units. Normalization is based on
%           x,y,z -limits calculated based on graphical objects, for
%           instance [0 1 0] means x - center of all graphical objects, y -
%           right limit based on all graphical objects, z - center based on
%           all graphical objects. Values different from 0 and 1 can also
%           be used ([-1.1 0 0.4] is a valid vector)
%       powerVec: double[1,nLights] - powers of light objects
%
%       lightStyleList: char[1,]/cell[1,nLights] of char[1,] - list of
%           light styles, style can be 'local' and 'infinite' 
%
% Output:
%   hLightVec: double[1,nLightObjects] - vector of light object handles
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-07 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
%           
SUPPORTED_OBJ_TYPE_LIST={'patch','surface'};
%
nLights=length(lightCoordList);
if ischar(lightStyleList)
    lightStyleList=repmat({lightStyleList},1,nLights);
end
%
hVec=get(hAxes,'Children');
objTypeList=get(hVec,'Type');
if ischar(objTypeList)
    objTypeList={objTypeList};
end
isKeptVec=cellfun(@(x)any(strcmpi(x,SUPPORTED_OBJ_TYPE_LIST)),...
    objTypeList);
hVec=hVec(isKeptVec);
objTypeList=objTypeList(isKeptVec);
nObjs=length(objTypeList);
leftLimVec=nan(1,3);
rightLimVec=nan(1,3);
for iObj=1:nObjs
    hObj=hVec(iObj);
    xVec=reshape(get(hObj,'XData'),[],1);
    yVec=reshape(get(hObj,'YData'),[],1);
    zVec=reshape(get(hObj,'ZData'),[],1);
    %
    vMinVec=[min(xVec),min(yVec),min(zVec)];
    vMaxVec=[max(xVec),max(yVec),max(zVec)];
    leftLimVec=min([vMinVec;leftLimVec],[],1);
    rightLimVec=max([vMaxVec;rightLimVec],[],1);
end
halfRangeVec=0.5*(rightLimVec-leftLimVec);
midVec=0.5*(rightLimVec+leftLimVec);
%
hLightVec=sum(powerVec);
iCurLight=1;
for iLight=1:nLights
    lightStyle=lightStyleList{iLight};
    posVec=halfRangeVec.*lightCoordList{iLight};
    if strcmpi(lightStyle,'local')
        posVec=posVec+midVec;
    end
    lightPower=powerVec(iLight);
    for iPowerUnit=1:lightPower
        hLightVec(iCurLight)=light('Parent',hAxes,...
            'Position',posVec,'Style',lightStyle);
        iCurLight=iCurLight+1;
    end
end
