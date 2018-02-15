function setgraphobjtype(hPlot, graphObjType)
%
% setgraphobjtype - add type of graphical object to UserData of figure
% handle
%
% Input:
%   regular:
%       hPlot: patch object that contains the data for all the polygons
%       graphObjType: elltool.plot.GraphObjTypeEnum[1, 1] - graphical
%       object type.
%
% $Author: <Timofey Shalimov>  <ssstiss@gmail.com> $    
% $Date: <28 December 2017> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2017 $
%
if isstruct(hPlot.UserData)
    hPlot.UserData.graphObjType = graphObjType;
elseif isempty(hPlot.UserData)
    hPlot.UserData = struct('graphObjType', graphObjType);
else
    import modgen.common.throwerror;
    throwerror('WrongInput', ...
               'Patch UserData must be empty or struct [1x1]');
end
end
