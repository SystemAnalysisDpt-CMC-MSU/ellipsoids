function [isEqualArr, reportStr] = eq(ellFirstArr, ellSecArr)
% EQ - compares two arrays of ellipsoids
%
% Input:
%  regular:
%   ellFirstArr: ellipsoid: [nDims1,nDims2,...,nDimsN]/[1,1]-
%                                        the first array of 
%                                        ellipsoid objects
%           
%    ellSecArr: ellipsoid: [nDims1,nDims2,...,nDimsN]/[1,1]-
%                                         the second array of
%                                         ellipsoid objects
%
% Output:
%   isEqualArr: logical: [nDims1,nDims2,...,nDimsN] - array
%                                     of comparison results
%       
%
%   reportStr: char[1,] - comparison report
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $    
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import modgen.common.throwerror;
import modgen.struct.structcomparevec;
import gras.la.sqrtmpos;
import elltool.core.GenEllipsoid;
relTol=GenEllipsoid.getCheckTol();

GenEllipsoid.checkIsMe(ellFirstArr);
GenEllipsoid.checkIsMe(ellSecArr);
nFirstElems = numel(ellFirstArr);
nSecElems = numel(ellSecArr);

firstSizeVec = size(ellFirstArr);
secSizeVec = size(ellSecArr);
isnFirstScalar=nFirstElems > 1;
isnSecScalar=nSecElems > 1;
%
SEll1Array=ellFirstArr.toStruct();
SEll2Array=ellSecArr.toStruct();
%
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
        [isEqualArr,reportStr]=modgen.struct.structcomparevec(SEll1Array,...
            SEll2Array,relTol);
    end
end