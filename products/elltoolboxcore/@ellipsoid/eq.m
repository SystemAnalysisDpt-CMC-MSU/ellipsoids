function [isEqual, reportStr] = eq_new(ell1Mat, ell2Mat)

  import modgen.common.throwerror;
  import modgen.struct.structcomparevec;
  import gras.la.sqrtm;
  import elltool.conf.Properties;
  
  if  ~(isa(ell1Mat, 'ellipsoid')) | ~(isa(ell2Mat, 'ellipsoid'))
    throwerror('wrongInput', '==: both arguments must be ellipsoids.');
  end
  [kDim, lDim] = size(ell1Mat);
  sNumel      = kDim * lDim;
  [mDim, nDim] = size(ell2Mat);
  tNumel      = mDim * nDim;

  if ((kDim ~= mDim) | (lDim ~= nDim)) & (sNumel > 1) & (tNumel > 1)
    throwerror('wrongSizes', '==: sizes of ellipsoidal arrays do not match.');
  end
  relTolMat = ell1Mat(1, 1).relTol;
  if (sNumel > 1) & (tNumel > 1)
        SEll1Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',x.center'),ell1Mat(:, :));
        SEll2Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',x.center'),ell2Mat(:, :));
        [isEqual,reportStr]=modgen.struct.structcomparevec(SEll1Array,SEll2Array,relTolMat);
  elseif (sNumel > 1)
        ell2Mat = repmat(ell2Mat, kDim, lDim);
        SEll1Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',x.center'),ell1Mat(:, :));
        SEll2Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',x.center'),ell2Mat(:, :));
        [isEqual,reportStr]=modgen.struct.structcomparevec(SEll1Array,SEll2Array,relTolMat);
  else
        ell1Mat = repmat(ell1Mat, mDim, nDim);
        SEll1Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',x.center'),ell1Mat(:, :));
        SEll2Array=arrayfun(@(x)struct('Q',gras.la.sqrtm(x.shape),'q',x.center'),ell2Mat(:, :));
        [isEqual,reportStr]=modgen.struct.structcomparevec(SEll1Array,SEll2Array,relTolMat);
  end

end
