classdef IReach < handle
% $Authors: Kirill Mayantsev <kirill.mayantsev@gmail.com> $   
%               $Date: March-2013 $
%           Igor Kitsenko <kitsenko@gmail.com> $
%               $Date: May-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics 
%             and Computer Science, 
%             System Analysis Department 2013$
%
    methods (Abstract)
        % CUT - extracts the piece of reach tube from given start time to given 
        %       end time. Given reach set self, find states that are reachable  
        %       within time interval specified by cutTimeVec. If cutTimeVec 
        %       is a scalar, then reach set at given time is returned.
        % 
        % Input:
        %   regular:
        %       self.
        %
        %    cutTimeVec: double[1, 2]/double[1, 1] - time interval to cut.
        %
        % Output:
        %   cutObj: elltool.reach.IReach[1, 1] - reach set resulting from the CUT
        %         operation.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   cutObj = rsObj.cut([3 5]);
        %   dRsObj = elltool.reach.ReachDiscrete(dtsys, x0EllObj, dirsMat, timeVec);
        %   dCutObj = dRsObj.cut([3 5]);
        %
        cutObj = cut(self, cutTimeVec)
        %
        % DIMENSION - returns array of dimensions of given reach set array.
        %
        % Input:
        %   regular:
        %       self - multidimensional array of
        %              ReachContinuous/ReachDiscrete objects
        %
        % Output:
        %   rSdimArr: double[nDim1, nDim2,...] - array of reach set dimensions.
        %   sSdimArr: double[nDim1, nDim2,...] - array of state space dimensions.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   rsObjArr = rsObj.repMat(1,2);
        %   [rSdim sSdim] = rsObj.dimension()
        %
        %   rSdim =
        %
        %            2
        %
        %
        %   sSdim =
        %
        %            2
        %
        %   [rSdim sSdim] = rsObjArr.dimension()
        %
        %   rSdim = 
        %           [ 2  2 ]
        %
        %   sSdim = 
        %           [ 2  2 ]
        %
        [rSdimArr sSdimArr] = dimension(self)
        %
        % DISPLAY - displays the reach set object.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   None.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   rsObj.display()
        %
        %   rsObj =
        %   Reach set of the continuous-time linear system in R^2 in the time...
        %        interval [0, 10].
        % 
        %   Initial set at time t0 = 0:
        %   Ellipsoid with parameters
        %   Center:
        %        0
        %        0
        % 
        %   Shape Matrix:
        %        1     0
        %        0     1
        % 
        %   Number of external approximations: 2
        %   Number of internal approximations: 2
        %
        display(self)
        % 
        % REFINE - adds new approximations computed for the specified directions
        %          to the given reach set or to the projection of reach set.
        %
        % Input:
        %   regular:
        %       self.
        %       l0Mat: double[nDim, nDir] - matrix of directions for new
        %           approximation
        %
        % Output:
        %   regular:
        %       reachObj: reach[1,1] - refine reach set for the directions
        %           specified in l0Mat
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);        
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   newDirsMat = [1; -1];
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   rsObj = rsObj.refine(newDirsMat);
        %
        % $Author: Vitaly Baranov <vetbar42@gmail.com> $ $Date: 21-04-2013$
        % $Copyright: Lomonosov Moscow State University,
        %            Faculty of Computational Mathematics and Cybernetics,
        %            System Analysis Department 2013 $
        %
        reachObj = refine(self, l0Mat)
        %
        % EVOLVE - computes further evolution in time of the
        %          already existing reach set.
        %
        % Input:
        %   regular:
        %       self.
        %
        %       newEndTime: double[1, 1] - new end time.
        %
        %   optional:
        %       linSys: elltool.linsys.LinSys[1, 1] - new linear system.
        %
        % Output:
        %   newReachObj: reach[1, 1] - reach set on time  interval 
        %         [oldT0 newEndTime].
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);         
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj = elltool.reach.ReachDiscrete(dsys, x0EllObj, dirsMat, timeVec);
        %   newRsObj = rsObj.evolve(12);
        %   newDRsObj = dRsObj.evolve(11);
        %
        newReachObj = evolve(self, newEndTime, linSys)
        %
        % GET_CENTER - returns the trajectory of the center of the reach set.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   trCenterMat: double[nDim, nPoints] - array of points that form the  
        %       trajectory of the reach set center, where nDim is reach set 
        %       dimentsion, nPoints - number of points in time grid.
        %
        %   timeVec: double[1, nPoints] - array of time values.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   [trCenterMat timeVec] = rsObj.get_center();
        %
        [trCenterMat timeVec] = get_center(self)
        %
        % GET_DIRECTIONS - returns the values of direction vectors for time grid 
        %                  values.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   directionsCVec: cell[1, nPoints] of double [nDim, nDir] - array of  
        %       cells, where each cell is a sequence of direction vector values  
        %       that correspond to the time values of the grid, where nPoints is
        %       number of points in time grid.      
        %
        %   timeVec: double[1, nPoints] - array of time values.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   [directionsCVec timeVec] = rsObj.get_directions();
        %
        [directionsCVec timeVec] = get_directions(self)
        %
        % GET_EA - returns array of ellipsoid objects representing external 
        %          approximation of the reach  tube.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   eaEllMat: ellipsoid[nAppr, nPoints] - array of ellipsoids, where nAppr  
        %       is the number of approximations, nPoints is number of points in time
        %       grid.
        %       
        %    timeVec: double[1, nPoints] - array of time values.
        %    l0Mat: double[nDirs,nDims] - matrix of good directions at t0
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   [eaEllMat timeVec] = rsObj.get_ea();
        %
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        %   dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        %   [eaEllMat timeVec] = dRsObj.get_ea();
        %
        [eaEllMat timeVec] = get_ea(self)  
        % GET_GOODCURVES - returns the 'good curve' trajectories of the reach set.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   goodCurvesCVec: cell[1, nPoints] of double [x, y] - array of cells,  
        %       where each cell is array of points that form a 'good curve'.       
        %
        %   timeVec: double[1, nPoints] - array of time values.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   [goodCurvesCVec timeVec] = rsObj.get_goodcurves();
        % 
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        %   dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        %   [goodCurvesCVec timeVec] = dRsObj.get_goodcurves(); 
        %
        [goodCurvesCVec timeVec] = get_goodcurves(self)
        %
        % GET_IA - returns array of ellipsoid objects representing internal 
        %          approximation of the  reach tube.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   iaEllMat: ellipsoid[nAppr, nPoints] - array of ellipsoids, where nAppr  
        %       is the number of approximations, nPoints is number of points in time 
        %       grid.
        %
        %   timeVec: double[1, nPoints] - array of time values.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   [iaEllMat timeVec] = rsObj.get_ia();
        %
        [iaEllMat timeVec] = get_ia(self)
        %
        % GET_SYSTEM - returns the linear system for which the reach set is 
        %              computed.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   linSys: elltool.linsys.LinSys[1, 1] - linear system object.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   linSys = rsObj.get_system()
        %
        %   self =
        %   A:
        %        0     1
        %        0     0
        % 
        % 
        %   B:
        %        1     0
        %        0     1
        % 
        % 
        %   Control bounds:
        %      2-dimensional ellipsoid with center
        %       'sin(t)'
        %       'cos(t)'
        % 
        %      and shape matrix
        %        9     0
        %        0     2
        % 
        % 
        %   C:
        %        1     0
        %        0     1
        % 
        %   2-input, 2-output continuous-time linear time-invariant system of 
        %           dimension 2:
        %   dx/dt  =  A x(t)  +  B u(t)
        %    y(t)  =  C x(t)
        %
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        %   dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj.get_system(); 
        %
        linSys = get_system(self)        
        % INTERSECT - checks if its external (s = 'e'), or internal (s = 'i')  
        %             approximation intersects with given ellipsoid, hyperplane
        %             or polytop.
        %
        % Input:
        %   regular:
        %       self.
        %
        %       intersectObj: ellipsoid[1, 1]/hyperplane[1,1]/polytop[1, 1].
        %
        %       approxTypeChar: char[1, 1] - 'e' (default) - external approximation,
        %                                    'i' - internal approximation.
        %
        % Output:
        %   isEmptyIntersect: logical[1, 1] -  true - if intersection is nonempty, 
        %                                      false - otherwise.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   ellObj = ellipsoid([0; 0], 2*eye(2));
        %   isEmptyIntersect = intersect(rsObj, ellObj)
        %
        %   isEmptyIntersect =
        %
        %                   1
        %
        isEmptyIntersect = intersect(self, intersectObj, approxTypeChar)       
        % ISCUT - checks if given array of reach set objects is a cut of 
        %         another reach set object's array.
        %
        % Input:
        %   regular:
        %       self - multidimensional array of
        %              ReachContinuous/ReachDiscrete objects
        %
        % Output:
        %   isCutArr: logical[nDim1, nDim2, nDim3 ...] - 
        %             isCut(iDim1, iDim2, iDim3,..) = true - if self(iDim1, iDim2, iDim3,...) is a cut of the reach set, 
        %                                           = false - otherwise.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
        %   cutObj = rsObj.cut([3 5]);
        %   cutObjArr = cutObj.repMat(2,3,4);
        %   iscut(cutObj);
        %   iscut(cutObjArr);
        %   cutObj = dRsObj.cut([4 8]);
        %   cutObjArr = cutObj.repMat(1,2);
        %   iscut(cutObjArr);
        %   iscut(cutObj);
        %
        isCutArr = iscut(self)
        %
        % ISPROJECTION - checks if given array of reach set objects is projections.
        %
        % Input:
        %   regular:
        %       self - multidimensional array of
        %              ReachContinuous/ReachDiscrete objects
        %
        % Output:
        %   isProjArr: logical[nDim1, nDim2, nDim3, ...] - 
        %              isProj(iDim1, iDim2, iDim3,...) = true - if self(iDim1, iDim2, iDim3,...) is projection, 
        %                                              = false - otherwise.  
        %                        
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
        %   projMat = eye(2);
        %   projObj = rsObj.projection(projMat);
        %   projObjArr = projObj.repMat(3,2,2);
        %   isprojection(projObj);
        %   isprojection(projObjArr);
        %   projObj = dRsObj.projection(projMat);
        %   projObjArr = projObj.repMat(1,2);
        %   isprojection(projObj);
        %   isprojection(projObjArr);
        %
        isProjArr = isprojection(self) 
        %
        % PLOT_EA - plots external approximations of 2D and 3D reach sets.
        %
        % Input:
        %   regular:
        %       self.
        %
        %   optional:
        %       colorSpec: char[1, 1] - set color to plot in following way:
        %                              'r' - red color, 
        %                              'g' - green color,
        %                              'b' - blue color, 
        %                              'y' - yellow color,
        %                              'c' - cyan color,
        %                              'm' - magenta color,
        %                              'w' - white color.
        %
        %       OptStruct: struct[1, 1] with fields:
        %           color: double[1, 3] - sets color of the picture in the form 
        %                 [x y z].
        %           width: double[1, 1] - sets line width for 2D plots. 
        %           shade: double[1, 1] in [0; 1] interval - sets transparency level  
        %                 (0 - transparent, 1 - opaque).
        %            fill: double[1, 1] - if set to 1, reach set will be filled with
        %                  color.
        %
        % Output:
        %   None.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   rsObj.plotEa();
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        %   
        %   dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj.plotEa();
        %
        plotEa(self, varargin)
        %
        % PLOTBYEA - plot external approximation of 2D and 3D reach sets.
        %
        % Input:
        %   regular:
        %       self.
        %
        %   optional:
        %       colorSpec: char[1,1] - color specification code, can be 'r','g',
        %                    etc (any code supported by built-in Matlab function).
        %
        %   properties:
        %
        %       'fill': logical[1,1]  -
        %               if true, approximation in 2D will be filled with color.
        %        Default value is false.
        %       'lineWidth': double[1,1]  -
        %                    line width for  2D plots. Default value is 1.
        %       'color': double[1,3] -
        %                sets default color in the form [x y z].
        %                   Default value is [0.5 0.5 0.5].
        %       'shade': double[1,1] -
        %       level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
        %                Default value is 0.4.
        %
        %       'relDataPlotter' - relation data plotter object.
        %       'showDiscrete':logical[1,1]  -
        %           if true, approximation in 3D will be filled in every time slice
        %       'numPointsInOneTime': double[1,1] -
        %           number of points in every time slice.
        %
        % Output:
        %   regular:
        %       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
        %       data plotter object.
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   x0EllObj = ell_unitball(2);
        %   timeVec = [0 10];
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   rsObj.plotEa();
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj.plotByEa();
        %
        plObj = plotByEa(self, varargin)
        %
        % PLOTIA - plots internal approximations of 2D and 3D reach sets.
        %
        % Input:
        %   regular:
        %       self.
        %
        %   optional:
        %       colorSpec: char[1, 1] - set color to plot in following way:
        %                              'r' - red color,
        %                              'g' - green color,
        %                              'b' - blue color,
        %                              'y' - yellow color,
        %                              'c' - cyan color,
        %                              'm' - magenta color,
        %                              'w' - white color.
        %
        %       OptStruct: struct[1, 1] with fields:
        %           color: double[1, 3] - sets color of the picture in the form
        %                 [x y z].
        %           width: double[1, 1] - sets line width for 2D plots.
        %           shade: double[1, 1] in [0; 1] interval - sets transparency level
        %                 (0 - transparent, 1 - opaque).
        %            fill: double[1, 1] - if set to 1, reach set will be filled with
        %                 color.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   x0EllObj = ell_unitball(2);
        %   timeVec = [0 10];
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   rsObj.plotIa();
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj.plotIa();
        %
        plObj = plotIa(self, varargin)
        %
        % PLOTBYIA - plot internal approximation of 2D and 3D reach sets.
        %
        % Input:
        %   regular:
        %       self.
        %
        %   optional:
        %       colorSpec: char[1,1] - color specification code, can be 'r','g',
        %                    etc (any code supported by built-in Matlab function).
        %
        %   properties:
        %
        %       'fill': logical[1,1]  -
        %               if true, approximation in 2D will be filled with color.
        %        Default value is false.
        %       'lineWidth': double[1,1]  -
        %                    line width for  2D plots. Default value is 1.
        %       'color': double[1,3] -
        %                sets default color in the form [x y z].
        %                   Default value is [0.5 0.5 0.5].
        %       'shade': double[1,1] -
        %       level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
        %                Default value is 0.4.
        %
        %       'relDataPlotter' - relation data plotter object.
        %       'showDiscrete':logical[1,1]  -
        %           if true, approximation in 3D will be filled in every time slice
        %       'numPointsInOneTime': double[1,1] -
        %           number of points in every time slice.
        %
        % Output:
        %   regular:
        %       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
        %       data plotter object.
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   x0EllObj = ell_unitball(2);
        %   timeVec = [0 10];
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   rsObj.plotEa();
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj.plotByEa();
        %
        plObj = plotByIa(self, varargin)
        %
        % PROJECTION - projects the reach set self onto the orthogonal basis
        %              specified by the columns of matrix projMat.
        %
        % Input:
        %   regular:
        %       self.
        %       projMat: double[nRows, nCols] - projection matrix, where nRows
        %           is dimension of reach set, nCols <= nRows.
        %
        % Output:
        %   projObj: elltool.reach.IReach[1, 1] - projected reach set.
        %
        % Examples:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %   dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        %   x0EllObj = ell_unitball(2);
        %   timeVec = [0 10];
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
        %   projMat = eye(2);
        %   projObj = rsObj.projection(projMat);
        %   dProjObj = dRsObj.projection(projMat);
        %
        
        projObj = projection(self, projMat)
        %
        % ISEMPTY - checks if given reach set array is an array of empty objects.
        %
        % Input:
        %   regular:
        %       self - multidimensional array of
        %              ReachContinuous/ReachDiscrete objects
        %
        % Output:
        %   isEmptyArr: logical[nDim1, nDim2, nDim3,...] - 
        %               isEmpty(iDim1, iDim2, iDim3,...) = true - if self(iDim1, iDim2, iDim3,...) is empty, 
        %                                                = false - otherwise.
        %
        % Example:
        %   aMat = [0 1; 0 0]; bMat = eye(2);
        %   SUBounds = struct();
        %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %   SUBounds.shape = [9 0; 0 2];
        %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   dsys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %   x0EllObj = ell_unitball(2);  
        %   timeVec = [0 10];  
        %   dirsMat = [1 0; 0 1]';
        %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %   dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
        %   rsObjArr = rsObj.repMat(1,2);
        %   dRsObjArr = dRsObj.repMat(1,2);
        %   dRsObj.isEmpty();        
        %   rsObj.isEmpty()
        %
        %   ans =
        %
        %        0
        %
        %   dRsObjArr.isEmpty();
        %   rsObjArr.isEmpty()
        %
        %   ans = 
        %       [ 0  0 ]
        %
        isEmptyArr = isEmpty(self)
        %
        % REPMAT - is analogous to built-in repmat function with one exception - it
        %          copies the objects, not just the handles
        %
        % Input:
        %   regular:
        %       self. 
        %
        % Output:
        %   Array of given ReachContinuous/ReachDiscrete object's copies.
        %
        %  Example:
        %    aMat = [0 1; 0 0]; bMat = eye(2);
        %    SUBounds = struct();
        %    SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %    SUBounds.shape = [9 0; 0 2];
        %    sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %    x0EllObj = ell_unitball(2);  
        %    timeVec = [0 10];  
        %    dirsMat = [1 0; 0 1]';
        %    reachObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %    reachObjArr = reachObj.repMat(1,2);
        %
        %    reachObjArr = 1x2 array of ReachContinuous objects 
        %
        resArr=repMat(self,varargin)
        %
        % GETCOPY - returns the copy of ReachContinuous/ReachDiscrete
        %           array of objects
        %
        % Input:
        %   regular:
        %       self - multidimensional array of
        %              ReachContinuous/ReachDiscrete objects
        %
        % Output:
        %  copyReachObjArr: elltool.reach.ReachContinuous/ReachDiscrete -
        %       copy of the given array of objects.
        %    
        %  Example:
        %    aMat = [0 1; 0 0]; bMat = eye(2);
        %    SUBounds = struct();
        %    SUBounds.center = {'sin(t)'; 'cos(t)'};  
        %    SUBounds.shape = [9 0; 0 2];
        %    sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        %    x0EllObj = ell_unitball(2);  
        %    timeVec = [0 10];  
        %    dirsMat = [1 0; 0 1]';
        %    reachObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %    reachObjArr = reachObj.repMat(1,2);
        %    copyReachObj = reachObj.getCopy();
        %    copyReachObjArr = reachObjArr.getCopy();
        %
        %    copyReachObj = ReachContinuous object
        %    copyReachObjArr = 1x2 array of ReachContinuous objects   
        %
        copyReachObjArr = getCopy(self)
    end
end