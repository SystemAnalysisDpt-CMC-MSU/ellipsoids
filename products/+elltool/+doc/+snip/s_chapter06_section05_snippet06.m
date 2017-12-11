%%
% programm

firstSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat,firstUBoundsEllObj);

x0EllObj = ellipsoid(VecIn',eye(9));
                     
                     % columns of L specify the directions
                     dirsMat = [1 0 0 0 0 0 0 0 0
                                0 1 0 0 0 0 0 0 0
                                0 0 1 0 0 0 0 0 0
                                0 0 0 1 0 0 0 0 0
                                0 0 0 0 1 0 0 0 0
                                0 0 0 0 0 1 0 0 0
                                0 0 0 0 0 0 1 0 0
                                0 0 0 0 0 0 0 1 0
                                0 0 0 0 0 0 0 0 1]';
                     firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
                                                                [0 switchTimeFirst], 'isRegEnabled', true, 'isJustCheck',false,...
                                                                'regTol', 1e-5,'absTol',1e-6,'relTol',1e-7);
                     
                     % solve collision with same times
                     secSys = elltool.linsys.LinSysContinuous(secAMat, secBMat,secUBoundsEllObj);
                     if switchTimeSec == switchTimeFirst
                     thRsObj = firstRsObj.evolve(T, firstSys);
                     else
                     secRsObj = firstRsObj.evolve(switchTimeSec, secSys);
                     thRsObj = secRsObj.evolve(T, firstSys);
                     end
                     
                     
                     basisMat1 = [1 0 0 0 0 0 0 0 0
                                  0 0 0 1 0 0 0 0 0]';
                     
                     basisMat2 = [1 0 0 0 0 0 0 0 0
                                  0 0 0 0 0 0 1 0 0]'; 
                     
                     basisMat3 = [0 0 0 1 0 0 0 0 0
                                  0 0 0 0 0 0 1 0 0]';
                     
                     thPsObj1 = thRsObj.projection(basisMat1);
                     thPsObj2 = thRsObj.projection(basisMat2);
                     thPsObj3 = thRsObj.projection(basisMat3);
                     
