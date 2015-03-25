function checkDoesContainArgs(fstEllArr,secObjArr)
% CHECKDOESCONTAINARGS -- private function, used by doesContain and
%    doesIntersectionContain to check their arguments.
import modgen.common.throwerror;
import modgen.common.checkmultvar;

elltool.core.GenEllipsoid.checkIsMe(fstEllArr,'first');
modgen.common.checkvar(secObjArr,@(x)isa(x, 'elltool.core.GenEllipsoid') || ...
    isa(x, 'Polyhedron'),'errorTag','wrongInput', 'errorMessage',...
    'second input argument must be ellipsoid or Polyhedron.');
modgen.common.checkvar(secObjArr,@(x)isa(x, 'Polyhedron') || isa(x, 'elltool.core.GenEllipsoid'), ...
    'errorTag','wrongInput', 'errorMessage',...
    'second input argument must be ellipsoid or Polyhedron.');

modgen.common.checkvar(fstEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar(fstEllArr,'all(~x(:).isEmpty())','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

if isa(secObjArr, 'elltool.core.GenEllipsoid')
    modgen.common.checkvar( secObjArr, 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');
end

nFstEllDimsMat = dimension(fstEllArr);
%nSecEllDimsMat = dimension(secObjArr);
if isa(secObjArr,'Polyhedron')
    nSecEllDimsMat=secObjArr.Dim;
else
    nSecEllDimsMat = dimension(secObjArr);
end

if isa(secObjArr, 'Polyhedron')
    isEmptyArr = true(size(secObjArr));
    [~, nCols] = size(secObjArr);
    for iCols = 1:nCols
        isEmptyArr(iCols) = isempty(secObjArr(iCols));
    end
    isAnyObjEmpty = any(isEmptyArr);
else
    isAnyObjEmpty = any(secObjArr(:).isEmpty());
end
if isAnyObjEmpty
    throwerror('wrongInput:emptyEllipsoid',...
    'Array should not have empty ellipsoid or Polyhedron.');
end
checkmultvar('(x1(1)==x2(1))&&all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
    2,nFstEllDimsMat,nSecEllDimsMat,...
    'errorTag','wrongSizes',...
    'errorMessage','input arguments must be of the same dimension.');

