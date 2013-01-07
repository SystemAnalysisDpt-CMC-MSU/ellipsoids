classdef IReach < handle
    methods (Abstract)
        cutObj = cut(self, cutTimeVec)
        %
        % CUT - extracts the piece of reach tube from given start time to given end time.
        % Given reach set self, find states that are reachable within
        %     time interval specified by cutTimeVec.
        %     If cutTimeVec is a scalar, then reach set at given time is returned.
        %
        % Input:
        %     self
        %     cutTimeVec: double[1, 2] or double[1, 1]  
        %
        % Output:
        %     cutObj - reach set resulting from the CUT operation.
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
        %     self
        %
        % Output:
        %
        %     RSdim - reach set dimension.
        %     SSdim - state space dimension (optionally).
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
        %     self
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
        %     Case1:
        %         self
        %         newEndTime: double[1, 1] - new end time
        %
        %     Case2:
        %         self
        %         newEndTime: double[1, 1] - new end time
        %         linSys: elltool.linsys.LinSys[1, 1] - new linear system
        %
        % Output:	
        %     newReachObj - reach set on time interval [oldT0 newEndTime]
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
        %     self
        %
        % Output:
        %     trCenterMat - array of points that form the trajectory of the reach set center.
        %     timeVec - array of time values (optionally).
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
        %     self
        %
        % Output:
        %     directionsCVec - array of cells, where each cell is
        %         a sequence of direction vector values that correspond
        %         to the time values of the grid.
        %     timeVec - array of time values (optionally).
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
        %     self
        %
        % Output:
        %     eaEllMat - m x n array of ellipsoids, where m is the number
        %         of approximations, and n - number of time values
        %         for which the reach set approximation is computed.
        %     timeVec - array of corresponding time values (optionally).
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
        %     self
        %
        % Output:
        %     goodCurvesCVec - array of cells, where each cell is array
        %     of points that form a 'good curve'.
        %     timeVec - array of time values (optionally).
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
        %     self
        %
        % Output:
        %     iaEllMat - m x n array of ellipsoids, where m is the number
        %         of approximations, and n - number of time values
        %         for which the reach set approximation is computed.
        %     timeVec - array of corresponding time values (optionally).
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
        %     self
        %
        % Output:
        %     linSys - linear system object.
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
        %     self
        %     intersectObj: ellipsoid, hyperplane or polytop.
        %     approxTypeChar: 'e' (default) - external approximation,
        %         'i' - internal approximation.
        %
        % Output:
        %     isEmptyIntersect: 1 - if intersection is nonempty, 0 - otherwise.
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
        %     self
        %
        % Output:
        %     isCut: 1 - if RS is a cut of the reach set, 0 - otherwise.
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
        %     self
        %
        % Output:
        %     isProj: 1 - if self is projection, 0 - otherwise.
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
        %     Case1:
        %         self
        %
        %     Case2:
        %         self
        %         OptStruct: structure with fields described below
        %
        %     Case3:
        %         self
        %         'r': plot approximation in red color
        %         OptStruct: structure with fields described below
        %
        %     OptStruct's fields:
        %         OptStruct.color - sets color of the picture in the form [x y z].
        %         OptStruct.width - sets line width for 2D plots.
        %         OptStruct.shade: 0-1 - sets transparency level (0 - transparent, 1 - opaque).
        %         OptStruct.fill - if set to 1, reach set will be filled with color.
        %
        % Output:
        %     None.
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
        %     Case1:
        %         self
        %
        %     Case2:
        %         self
        %         OptStruct: structure with fields described below
        %
        %     Case3:
        %         self
        %         'r': plot approximation in red color
        %         OptStruct: structure with fields described below
        %
        %     OptStruct's fields:
        %         OptStruct.color - sets color of the picture in the form [x y z].
        %         OptStruct.width - sets line width for 2D plots.
        %         OptStruct.shade: 0-1 - sets transparency level (0 - transparent, 1 - opaque).
        %         OptStruct.fill - if set to 1, reach set will be filled with color.
        %
        % Output:
        %     None.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
        projObj = projection(self, projMat)
        %
        % PROJECTION - projects the reach set self onto the orthogonal
        %     basis specified by the columns of matrix B.
        %
        % Input:
        %     self
        %     projMat: matrix of double 
        %
        % Output:
        %     projObj - projected reach set.
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
        %     self
        %
        % Output:
        %     isEmpty: 1 - if self is empty, 0 - otherwise.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
    end
end