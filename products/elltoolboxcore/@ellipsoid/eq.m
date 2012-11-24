function [isEqual, reportStr] = eq(ellFirstArr, ellSecArr)

import modgen.common.throwerror;
import modgen.struct.structcomparevec;
import gras.la.sqrtm;
import elltool.conf.Properties;
import modgen.common.type.simple.*;

checkgen(ellFirstArr,@(x)isa(x,'ellipsoid'));
checkgen(ellSecArr,@(x)isa(x,'ellipsoid'));

[kDim, lDim] = size(ellFirstArr);
nFirstElems = kDim * lDim;
[mDim, nDim] = size(ellSecArr);
nSecElems = mDim * nDim;
relTol = ellFirstArr(1, 1).relTol;
if (nFirstElems > 1) & (nSecElems > 1)
    leftSizeVec = size(ellFirstArr);
    rightSizeVec = size(ellSecArr);
    if ~isequal(leftSizeVec, rightSizeVec)
        throwerror...
        ('wrongSizes', '==: sizes of ellipsoidal arrays do not... match.');
    end;
    SEll1Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',...
        x.center'),ellFirstArr(:, :));
    SEll2Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',...
        x.center'),ellSecArr(:, :));
    [isEqual,reportStr]=modgen.struct.structcomparevec(SEll1Array,...
        SEll2Array,relTol);
    isEqual = reshape(isEqual, leftSizeVec);
elseif (nFirstElems > 1)

    SScalar = arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',...
        x.center'), ellSecArr);   
    SEll1Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',...
        x.center'),ellFirstArr(:, :));
    SEll2Array=repmat(SScalar, size(ellFirstArr));
    [isEqual,reportStr]=modgen.struct.structcomparevec(SEll1Array,...
        SEll2Array,relTol);
    
    isEqual = reshape(isEqual, size(ellFirstArr));
else
    SScalar = arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',...
        x.center'), ellFirstArr);   
    SEll1Array=repmat(SScalar, size(ellSecArr));
    SEll2Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',...
        x.center'),ellSecArr(:, :));
    [isEqual,reportStr]=modgen.struct.structcomparevec(SEll1Array,...
        SEll2Array,relTol);
    isEqual = reshape(isEqual, size(ellSecArr));
end

