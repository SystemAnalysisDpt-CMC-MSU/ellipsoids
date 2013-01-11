classdef IReach < handle
    methods (Abstract)
        cutObj = cut(self, cutTimeVec)
        %
        % CUT - extracts the piece of reach tube from given start time to
        % given end time. Given reach set self, find states that are
        % reachable within time interval specified by cutTimeVec. If
        % cutTimeVec is a scalar, then reach set at given time is returned.
        %
        % Input:
        %   regular:
        %       self
        %
        %       cutTimeVec: double[1, 2] or double[1, 1]  
        %
        % Output:
        %   cutObj: reach[1, 1] - reach set resulting from the CUT operation.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        [RSdim SSdim] = dimension(self)
        %
        % DIMENSION - returns the dimension of the reach set.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   RSdim: double[1, 1] - reach set dimension.
        %
        %   SSdim: double[1, 1] - state space dimension.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        display(self)
        %
        % DISPLAY - displays the reach set object
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   None.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        newReachObj = evolve(self, newEndTime, linSys)
        %
        % EVOLVE - computes further evolution in time of the already existing reach set.
        %
        % Input:
        %   regular:
        %       self
        %
        %       newEndTime: double[1, 1] - new end time
        %
        %   optional:
        %       linSys: elltool.linsys.LinSys[1, 1] - new linear system
        %
        % Output:	
        %   newReachObj: reach[1, 1] - reach set on time interval [oldT0 newEndTime]
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        [trCenterMat timeVec] = get_center(self)
        %
        % GET_CENTER - returns the trajectory of the center of the reach set.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   trCenterMat: double[nDim, nPoints] - array of points that
        %       form the trajectory of the reach set center, where
        %       nDim is reach set dimentsion, nPoints - number of points in
        %       time grid.
        %
        %     timeVec: double[1, nPoints] - array of time values.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        [directionsCVec timeVec] = get_directions(self)
        %
        % GET_DIRECTIONS - returns the values of direction vectors for time grid values.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   directionsCVec: cell[1, nPoints] - array of cells, where each
        %       cell is a sequence of direction vector values that
        %       correspond to the time values of the grid, where nPoints is
        %       number of points in time grid.
        %
        %   timeVec: double[1, nPoints] - array of time values.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        [eaEllMat timeVec] = get_ea(self)
        %
        % GET_EA - returns array of ellipsoid objects representing
        %     external approximation of the reach tube.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   eaEllMat: ellipsoid[nAppr, nPoints] - array of ellipsoids,
        %       where nAppr is the number of approximations, nPoints is
        %       number of points in time grid.
        %
        %   timeVec: double[1, nPoints] - array of time values.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        [goodCurvesCVec timeVec] = get_goodcurves(self)
        %
        % WARNING! This function cannot be used with projected reach sets.
        %
        % GET_GOODCURVES - returns the 'good curve' trajectories of the reach set.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   goodCurvesCVec: cell[1, nPoints] - array of cells, where each
        %       cell is array of points that form a 'good curve'.
        %
        %   timeVec: double[1, nPoints] - array of time values.
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        [iaEllMat timeVec] = get_ia(self)
        %
        % GET_IA - returns array of ellipsoid objects representing
        %     internal approximation of the reach tube.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   iaEllMat: ellipsoid[nAppr, nPoints] - array of ellipsoids,
        %       where nAppr is the number of approximations, nPoints is
        %       number of points in time grid.
        %
        %   timeVec: double[1, nPoints] - array of time values.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        linSys = get_system(self)
        %
        % GET_SYSTEM - returns the linear system for which the reach set is computed.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   linSys: elltool.linsys.LinSys[1, 1] - linear system object.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        isEmptyIntersect = intersect(self, intersectObj, approxTypeChar)
        %
        % INTERSECT - checks if its external (s = 'e'), or internal (s = 'i')
        %     approximation intersects with given ellipsoid, hyperplane or polytop.
        %
        % Input:
        %   regular:
        %       self
        %
        %       intersectObj: ellipsoid[1, 1], hyperplane[1, 1] or polytop[1, 1].
        %
        %       approxTypeChar: char[1, 1] -
        %           'e' (default) - external approximation,
        %           'i' - internal approximation.
        %
        % Output:
        %   isEmptyIntersect: logical[1, 1] -
        %       1 - if intersection is nonempty, 0 - otherwise.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        isCut = iscut(self)
        %
        % ISCUT - checks if given reach set object is a cut of another reach set.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   isCut: logical[1, 1] -
        %       1 - if self is a cut of the reach set, 0 - otherwise.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        isProj = isprojection(self)
        %
        % ISPROJECTION - checks if given reach set object is a projection.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   isProj: logical[1, 1] -
        %       1 - if self is projection, 0 - otherwise.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        plot_ea(self, varargin)
        %
        % PLOT_EA - plots external approximations of 2D and 3D reach sets.
        %
        % Input:
        %   regular:
        %       self
        %
        %   optional:
        %       colorChar: char[1, 1] - set color to plot
        %
        %       OptStruct: struct[1, 1] with fields:
        %           OptStruct.color: double[1, 3] - sets color of the
        %               picture in the form [x y z].
        %         OptStruct.width: double[1, 1] - sets line width for 2D plots.
        %         OptStruct.shade: double[1, 1] in [0; 1] interval - sets
        %             transparency level (0 - transparent, 1 - opaque).
        %         OptStruct.fill: double[1, 1] - if set to 1, reach set
        %             will be filled with color.
        %
        % Output:
        %   None.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        plot_ia(self, varargin)
        %
        % PLOT_IA - plots internal approximations of 2D and 3D reach sets.
        %
        % Input:
        %   regular:
        %       self
        %
        %   optional:
        %       colorChar: char[1, 1] - set color to plot
        %
        %       OptStruct: struct[1, 1] with fields:
        %           OptStruct.color: double[1, 3] - sets color of the
        %               picture in the form [x y z].
        %         OptStruct.width: double[1, 1] - sets line width for 2D plots.
        %         OptStruct.shade: double[1, 1] in [0; 1] interval - sets
        %             transparency level (0 - transparent, 1 - opaque).
        %         OptStruct.fill: double[1, 1] - if set to 1, reach set
        %             will be filled with color.
        %
        % Output:
        %   None.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        projObj = projection(self, projMat)
        %
        % PROJECTION - projects the reach set self onto the orthogonal
        %     basis specified by the columns of matrix projMat.
        %
        % Input:
        %   regular:
        %       self
        %       projMat: double[nRows, nCols] - projection matrix, where
        %           nRows is dimension of reach set, nCols <= nRows.
        %
        % Output:
        %   projObj: reach[1, 1] - projected reach set.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        isEmpty = isempty(self)
        %
        % ISEMPTY - checks if given reach set is an empty object.
        %
        % Input:
        %   regular:
        %       self
        %
        % Output:
        %   isEmpty: logical[1, 1] -
        %       1 - if self is empty, 0 - otherwise.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
    end
end