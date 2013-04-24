function regQMat = ell_regularize(qMat, regTol)
%
% ELL_REGULARIZE - regularization of singular matrix.
%
regQMat = gras.la.regposdefmat(qMat, regTol);
