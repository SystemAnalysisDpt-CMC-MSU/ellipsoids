% Continuous-time system backward reachability test.

clear P;

  aMat        = [0 1; -2 0];
  bMat        = [0; 1];
  SUBounds.center = {'0'};
  SUBounds.shape  = 2;
  endTime        = 5;
  phi      = 0:0.1:pi;
  dirsMat       = [cos(phi); sin(phi)];
  %L0       = [1 0; 0 1; 1 1; -1 1; -1 -1]';
  x0EllObj        = 0.00001*ell_unitball(2) + [3;1];
  mEllObj         = 0.00001*ell_unitball(2) + [2;0];

%   o.approximation = 0;
  sys      = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
  rsObj       = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, [0 endTime],  'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

  dirsArray = rsObj.get_directions();
  dirsLenght = size(dirsArray, 2);
  backwardDirsMat = [];
  for i = 1:dirsLenght
    d  = dirsArray{i};
    backwardDirsMat = [backwardDirsMat d(:,end)];
  end
  brsObj      = elltool.reach.ReachContinuous(sys, mEllObj, backwardDirsMat, [endTime 0],  'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

  plotByEa(rsObj); hold on;
  plotByEa(brsObj, 'g'); hold on;


  [gc1, t1] = rsObj.cut([0 0.886]).get_goodcurves();  gc1 = gc1{1};
  [gc2, t2] = brsObj.cut([endTime 0.886]).get_goodcurves(); gc2 = gc2{28};
  bc = brsObj.cut([endTime 0.886]).get_center();
  gc2 = 2*bc - gc2;

  ell_plot([t1;gc1], 'r'); hold on;
  ell_plot([t2;gc2], 'k'); hold on;

  t  = 0.886;
  gc = rsObj.cut(t).get_goodcurves(); gc = gc{1};
  ell_plot([t;gc], 'ro');
  ell_plot([0;3;1],'r*');
  ell_plot([endTime;2;0],'k*');
