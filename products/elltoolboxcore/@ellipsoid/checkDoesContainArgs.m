function checkDoesContainArgs(fstEllArr,secObjArr)
% CHECKDOESCONTAINARGS -- private function, used by doesContain and
%    doesIntersectionContain to check their arguments.
import modgen.common.throwerror;
import modgen.common.checkmultvar;

ellipsoid.checkIsMe(fstEllArr,'first');
modgen.common.checkvar(secObjArr,@(x) isa(x, 'ellipsoid') ||...
    isa(x, 'polytope'),'errorTag','wrongInput', 'errorMessage',...
    'second input argument must be ellipsoid or polytope.');

modgen.common.checkvar( fstEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( fstEllArr,'all(~isempty(x(:)))','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

if isa(secObjArr,'ellispoid')
    modgen.common.checkvar( secondObjArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');
end

nFstEllDimsMat = dimension(fstEllArr);
nSecEllDimsMat = dimension(secObjArr);

checkmultvar('(x1(1)==x2(1))&&all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
    2,nFstEllDimsMat,nSecEllDimsMat,...
    'errorTag','wrongSizes',...
    'errorMessage','input arguments must be of the same dimension.');

if isa(secObjArr, 'polytope')
    isEmptyArr = true(size(secObjArr));
    [~, nCols] = size(secObjArr);
    for iCols = 1:nCols
        isEmptyArr(iCols) = isempty(secObjArr(iCols));
    end
    isAnyObjEmpty = any(isEmptyArr);
else
    isAnyObjEmpty = any(isempty(secObjArr(:)));
end
if isAnyObjEmpty
    throwerror('wrongInput:emptyObject',...
    'Array should not have empty ellipsoid or polytope.');
end
