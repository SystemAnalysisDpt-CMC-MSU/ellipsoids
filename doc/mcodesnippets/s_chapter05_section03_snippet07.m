aMat = [0 1; 0 0]; bMat = eye(2);  
SUBounds = struct();
SUBounds.center = {'sin(t)'; 'cos(t)'};  
SUBounds.shape = [9 0; 0 2]; 
sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
x0EllObj = ell_unitball(2);
timeVec = [0 10]; 
for iElem = 1:5
    dirInitial= rand(2, 1); 
    dirInitial = dirInitial ./ norm(dirInitial);
    dirsMat(:, iElem) = dirInitial;
end
rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
ellTubeObj = rsObj.getEllTubeRel();
ellTubeObj.dispOnUI();