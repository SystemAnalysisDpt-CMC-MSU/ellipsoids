function [SDataArr, SFieldNiceNames, SFieldDescr] = ...
    toStructInternal(ObjArr, isPropIncluded)

if (nargin < 2)
    isPropIncluded = false;
end

SDataArr = arrayfun(@(Obj)elltube2Struct(Obj, isPropIncluded), ObjArr);
SFieldNiceNames = struct('QArray', 'aMat', 'MArray', 'timeVec', 'ltGoodDirMat',...
'lsGoodDirVec','ltGoodDirNormVec', 'xTouchCurveMat', 'xTouchOpCurveMat',...
'xsTouchVec', 'xsTouchOpVec');
SFieldDescr = struct('QArray', 'Ellipsoid matrices',...
'aMat', 'Ellipsoid centers',...
'MArray','Array of regularization ellipsoid matrices',...
'timeVec','Time vector',...
'ltGoodDirMat','Good direction curve',...
'lsGoodDirVec','Good direction s',...
'ltGoodDirNormVec','Norm of good direction curve',...
'xTouchCurveMat','Touch point',...
'xTouchOpCurveMat','Touch point to good direction',...
'xsTouchVec','Touch point s',...
'xsTouchOpVec','Touch point at s');

if (isPropIncluded)
    SFieldNiceNames.absTol = 'absTol';
    SFieldNiceNames.relTol = 'relTol';
    SFieldNiceNames.scaleFactor = 'scaleFactor';
    SFieldNiceNames.dim = 'dim';
    SFieldNiceNames.sTime = 'sTime';
    SFieldNiceNames.approxSchemaName = 'approxSchemaName';
    SFieldNiceNames.indSTime = 'indSTime';
    SFieldNiceNames.lsGoodDirNorm = 'lsGoodDirNorm';
  
    
    SFieldDescr.absTol = 'Absolute tolerance.';
    SFieldDescr.relTol = 'Relative tolerance.';
    SFieldDescr.scaleFactor = 'Tube scale factor.';
    SFieldDescr.dim = 'Dimensionality.';
    SFieldDescr.sTime = 'Time s.';
    SFieldDescr.approxSchemaName = ' Name.';
    SFieldDescr.indSTime = 'Index of sTime within timeVec.';
    SFieldDescr.lsGoodDirNorm = 'Norm of good direction at time s.';
end

end

function SEll = elltube2Struct(Obj, isPropIncluded)
SEll = struct('QArray',Obj.QArray, 'aMat',Obj.aMat, 'MArray',Obj.MArray,....
    'timeVec',Obj.timeVec, 'ltGoodDirMat', Obj.ltGoodDirMat,...
'lsGoodDirVec',Obj.lsGoodDirVec,'ltGoodDirNormVec',Obj.ltGoodDirNormVec,...
'xTouchCurveMat', Obj.xTouchCurveMat, 'xTouchOpCurveMat',Obj.xTouchOpCurveMat,...
'xsTouchVec', Obj.xsTouchVec,'xsTouchOpVec', Obj.xsTouchOpVec);

if (isPropIncluded)
    SEll.absTol = Obj.absTol;
    SEll.relTol = Obj.relTol;
    SEll.scaleFactor = Obj.scalefactor;
    SEll.dim = Obj.dim;
    SEll.sTime = Obj.sTime;
    SEll.approxSchemaName = Obj.approxSchemaName;
    SEll.indSTime = Obj.indSTime;
    SEll.lsGoodDirNorm =Obj.lsGoodDirNorm;    
end
end