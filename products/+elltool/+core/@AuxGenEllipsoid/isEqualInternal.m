function [isEqualArr, reportStr] = isEqualInternal(ellFirstArr, ellSecArr, ...
    isPropIncluded, postProcSruct)

import modgen.struct.structcomparevec;
import gras.la.sqrtmpos;
import elltool.conf.Properties;
import modgen.common.throwerror;
%
nFirstElems = numel(ellFirstArr);
nSecElems = numel(ellSecArr);

modgen.common.checkvar( ellFirstArr, 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( ellSecArr, 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');
[~, absTol] = ellFirstArr.getAbsTol;
firstSizeVec = size(ellFirstArr);
secSizeVec = size(ellSecArr);
isnFirstScalar=nFirstElems > 1;
isnSecScalar=nSecElems > 1;

% while (numel(varargin) == 1 && iscell(varargin))
%     varargin = varargin{1};
% end

% if (~isempty(varargin))
%     modgen.common.checkvar( varargin, ...
%         'isa(x,''double'') && (numel(x) == 1)', 'errorTag', ...
%         'wrongInput:maxTolerance', 'errorMessage', ...
%         'Tolerance must be scalar double.');
%     tolerance = varargin;
% else
    [~, tolerance] = ellFirstArr.getRelTol;
% end
%
[SEll1Array, SFieldNiceNames, ~] = ellFirstArr.toStruct(isPropIncluded);
SEll2Array = ellSecArr.toStruct(isPropIncluded);
%
SEll1Array = arrayfun(@(SEll)postProcSruct(SEll,...
    SFieldNiceNames, absTol), SEll1Array);
SEll2Array = arrayfun(@(SEll)postProcSruct(SEll,...
    SFieldNiceNames, absTol), SEll2Array);

if isnFirstScalar&&isnSecScalar
    if ~isequal(firstSizeVec, secSizeVec)
        throwerror('wrongSizes',...
            'sizes of ellipsoidal arrays do not... match');
    end;
    compare();
    isEqualArr = reshape(isEqualArr, firstSizeVec);
elseif isnFirstScalar
    SEll2Array=repmat(SEll2Array, firstSizeVec);
    compare();
    
    isEqualArr = reshape(isEqualArr, firstSizeVec);
else
    SEll1Array=repmat(SEll1Array, secSizeVec);
    compare();
    isEqualArr = reshape(isEqualArr, secSizeVec);
end
    function compare()
        [isEqualArr, reportStr] = modgen.struct.structcomparevec(SEll1Array,...
            SEll2Array, tolerance);
    end
end