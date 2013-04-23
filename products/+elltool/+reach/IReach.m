classdef IReach < handle
% $Author: Kirill Mayantsev <kirill.mayantsev@gmail.com>$  
% $Date: March-2013 $
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % cutObj = rsObj.cut([3 5]);
        % dRsObj = elltool.reach.ReachDiscrete(dtsys, x0EllObj, dirsMat, timeVec);
        % dCutObj = dRsObj.cut([3 5]);
        %
        cutObj = cut(self, cutTimeVec)
        %
        % DIMENSION - returns the dimension of the reach set.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   rSdim: double[1, 1] - reach set dimension.
        %   sSdim: double[1, 1] - state space dimension.
        %
        % Example:
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % [rSdim sSdim] = rsObj.dimension()
        %
        % rSdim =
        %
        %          2
        %
        %
        % sSdim =
        %
        %          2
        %
        [rSdim sSdim] = dimension(self)
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % rsObj.display()
        %
        % rsObj =
        % Reach set of the continuous-time linear system in R^2 in the time...
        %      interval [0, 10].
        % 
        % Initial set at time t0 = 0:
        % Ellipsoid with parameters
        % Center:
        %      0
        %      0
        % 
        % Shape Matrix:
        %      1     0
        %      0     1
        % 
        % Number of external approximations: 2
        % Number of internal approximations: 2
        %
        display(self)
        %
        % EVOLVE - computes further evolution in time of the already existing 
        %          reach set.
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);         
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % dRsObj = elltool.reach.ReachDiscrete(dsys, x0EllObj, dirsMat, timeVec);
        % newDRsObj = dRsObj.evolve(11);
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % [trCenterMat timeVec] = rsObj.get_center();
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % [directionsCVec timeVec] = rsObj.get_directions();
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
        %
        % Example:
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % [eaEllMat timeVec] = rsObj.get_ea();
        %
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        % dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        % [eaEllMat timeVec] = dRsObj.get_ea();
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % [goodCurvesCVec timeVec] = rsObj.get_goodcurves();
        % 
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        % dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        % [goodCurvesCVec timeVec] = dRsObj.get_goodcurves(); 
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % [iaEllMat timeVec] = rsObj.get_ia();
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % linSys = rsObj.get_system()
        %
        % self =
        % A:
        %      0     1
        %      0     0
        % 
        % 
        % B:
        %      1     0
        %      0     1
        % 
        % 
        % Control bounds:
        %    2-dimensional ellipsoid with center
        %     'sin(t)'
        %     'cos(t)'
        % 
        %    and shape matrix
        %      9     0
        %      0     2
        % 
        % 
        % C:
        %      1     0
        %      0     1
        % 
        % 2-input, 2-output continuous-time linear time-invariant system of 
        %         dimension 2:
        % dx/dt  =  A x(t)  +  B u(t)
        %  y(t)  =  C x(t)
        %
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        % dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        % dRsObj.get_system(); 
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % ellObj = ellipsoid([0; 0], 2*eye(2));
        % isEmptyIntersect = intersect(rsObj, ellObj)
        %
        % sEmptyIntersect =
        %
        %                 1
        %
        isEmptyIntersect = intersect(self, intersectObj, approxTypeChar)       
        % ISCUT - checks if given reach set object is a cut of another reach set.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   isCut: logical[1, 1] - true - if self is a cut of the reach set, 
        %                          false - otherwise.
        %
        % Example:
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
        % cutObj = rsObj.cut([3 5]);
        % iscut(cutObj);
        % cutObj = dRsObj.cut([4 8]);
        % iscut(cutObj);
        %
        isCut = iscut(self)
        %
        % ISPROJECTION - checks if given reach set object is a projection.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   isProj: logical[1, 1] - true - if self is projection, false - otherwise.  
        %                        
        %
        % Example:
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
        % projMat = eye(2);
        % projObj = rsObj.projection(projMat);
        % isprojection(projObj);
        % projObj = dRsObj.projection(projMat);
        % isprojection(projObj);
        %
        isProj = isprojection(self) 
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % rsObj.plot_ea();
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        % dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        % dRsObj.plot_ea();
        %
        plot_ea(self, varargin)
        %
        % PLOT_IA - plots internal approximations of 2D and 3D reach sets.
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % rsObj.plot_ia();
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds); 
        % dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
        % dRsObj.plot_ia();
        %
        plot_ia(self, varargin)
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
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        % dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
        % projMat = eye(2);
        % projObj = rsObj.projection(projMat);
        % dProjObj = dRsObj.projection(projMat);
        %
        projObj = projection(self, projMat)
        %
        % ISEMPTY - checks if given reach set is an empty object.
        %
        % Input:
        %   regular:
        %       self.
        %
        % Output:
        %   isEmpty: logical[1, 1] - true - if self is empty, Ffalse - otherwise.
        %
        % Example:
        % aMat = [0 1; 0 0]; bMat = eye(2);
        % SUBounds = struct();
        % SUBounds.center = {'sin(t)'; 'cos(t)'};  
        % SUBounds.shape = [9 0; 0 2];
        % sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % dsys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds); 
        % x0EllObj = ell_unitball(2);  
        % timeVec = [0 10];  
        % dirsMat = [1 0; 0 1]';
        % rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        % dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
        % dRsObj.isempty();        
        % rsObj.isempty()
        %
        % ans =
        %
        %      0
        %
        isEmpty = isempty(self)
    end
end