function hPatch = smartpatch(ellTypeObj, isShowLegend, extraPropCVec, varargin)
% SMARTPATCH patch-wrapper for patch allowing to pass it extra arguments

% Input:
%   regular:
%		ellTypeObj: elltool.plotGraphObjTypeEnum[1, 1] - graphical object
%             type
%       isShowLegend: logical[1, 1] - display or not legend annotation for
%           this object
%       extraPropCVec: cell[1, ] - cell array of extra patch properties
%   Note: All other input arguments immediately following after
%       extraPropCVec are passed to patch function (see its help for details)
% Output:
%   regular:
%       hPatch: matlab.graphics.primitive.Patch[1, 1] - patch handle
% 
% 
% $Author: Stanislav Mologin <stas.mologin@gmail.com> $ $Date: 2017-12-24 $
% $Copyright: Moscow State University,
%       Faculty of Computational Mathematics and Computer Science,
%       System Analysis Department 2017 $

import elltool.plot.setgraphobjtype;
hPatch = patch(varargin{:});
setgraphobjtype(hPatch,ellTypeObj);
if (~isempty(extraPropCVec))
    set(hPatch, extraPropCVec{:});
end
if (~isShowLegend)
    hPatch.Annotation.LegendInformation.IconDisplayStyle = 'off';
end
