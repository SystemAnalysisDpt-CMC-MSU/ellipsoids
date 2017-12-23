function hPatch = smartpatch(isShowLegend, extraPropCVec, varargin)
% SMARTPATCH patch-wrapper for patch allowing to pass it extra arguments
%
% Usage:
%   hPatch = smartpatch(isShowLegend, extraPropCVec, patchArgs)
%
% input:
%       regular:
%           isShowLegend: logical[1, 1] - display or not legend annotation for
%               this object
%           extraPropCVec: cell[1, ] - cell array of extra patch properties
%           patchArgs: - arguments to pass directly to patch ('help patch'
%               for details)
% output:
%       regular:
%           hPatch: matlab.graphics.primitive.Patch[1, 1] - patch handle

hPatch = patch(varargin{:});
if (~isempty(extraPropCVec))
    set(hPatch, extraPropCVec{:});
end
if (~isShowLegend)
    hPatch.Annotation.LegendInformation.IconDisplayStyle = 'off';
end
