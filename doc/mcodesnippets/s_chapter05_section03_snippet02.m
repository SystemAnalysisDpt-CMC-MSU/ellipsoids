atMat = {'0' '1 - cos(2*t)'; '-1/t' '0'};  
sys_t = elltool.linsys.LinSysFactory.create(atMat, bMat, SUBounds);