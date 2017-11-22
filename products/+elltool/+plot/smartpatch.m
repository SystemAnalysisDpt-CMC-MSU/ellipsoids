function hPatch = smartpatch(extraPropCVec, varargin)
%
% SMARTPATCH legend-friendly wrapper for 'patch'
%
% In order to correct legend displaying, there ...to be continued
%
% Usage: 

hPatch = patch(varargin{:});
if (~isempty(extraPropCVec))
    set(hPatch, extraPropCVec{:});
end