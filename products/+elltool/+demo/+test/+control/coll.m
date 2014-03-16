function coll(varargin)
% Continuous-time system backward reachability test.
  
  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
  critTime = 0.886;
  aMat        = [0 1; -2 0];
  bMat        = [0; 1];
  SUBounds.center = {'0'};
  SUBounds.shape  = 2;
  endTime        = 5;
  phiVec      = linspace(0,pi,nDirs);
  dirsMat       = [cos(phiVec); sin(phiVec)];
  x0EllObj        = 0.00001*ell_unitball(2) + [3;1];
  mEllObj         = 0.00001*ell_unitball(2) + [2;0];

  sys      = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
  rsObj       = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat,...
      [0 endTime],  'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

  dirsArray = rsObj.get_directions();
  nDirs = size(dirsArray, 2);
  bcDirsMat = [];
  for i = 1:nDirs
    d  = dirsArray{i};
    bcDirsMat = [bcDirsMat d(:,end)];
  end
  brsObj      = elltool.reach.ReachContinuous(sys, mEllObj, bcDirsMat,...
      [endTime 0],  'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

  plotByEa(rsObj); hold on;
  plotByEa(brsObj, 'g'); hold on;


  [fgcCVec, fTime] = rsObj.cut([0 critTime]).get_goodcurves();  
  fgcVec = fgcCVec{1};
  [bgcCVec, bTime] = brsObj.cut([endTime critTime]).get_goodcurves(); 
  bgcVec = bgcCVec{1};
  bCenterVec = brsObj.cut([endTime critTime]).get_center();
  bgcVec = 2*bCenterVec - bgcVec;

  ell_plot([fTime;fgcVec], 'r'); hold on;
  ell_plot([bTime;bgcVec], 'k'); hold on;

  fgcCVec = rsObj.cut(critTime).get_goodcurves(); 
  fgcVec = fgcCVec{1};
  ell_plot([critTime;fgcVec], 'ro');
  ell_plot([0;3;1],'r*');
  ell_plot([endTime;2;0],'k*');
  
  
  %%%%%%%%%%% coll1 next
  
 ctObj = rsObj.cut(critTime);
 bctObj = brsObj.cut(critTime);
 efEllMat = ctObj.get_ea();
 ebEllMat = bctObj.get_ea();
 fgcCVec = ctObj.get_goodcurves(); 
 fgcVec = fgcCVec{1};
 dst = ebEllMat.distance(fgcVec);
 fgcId = find(dst == max(dst));
 bgcCVec = bctObj.get_goodcurves(); 
 bgcVec = bgcCVec{fgcId};
 bCenter = bctObj.get_center();
 bgcVec = -(bgcVec - bCenter) + bCenter;
 ctObj.plotByEa(); hold on;
 bctObj.plotByEa('g'); hold on;
 ell_plot(fgcVec,'r*');
 ell_plot(bgcVec,'k*');

end