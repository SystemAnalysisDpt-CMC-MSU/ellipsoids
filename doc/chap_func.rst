Function Reference
==================

ellipsoid
---------

::

    CALCGRID - computes grid of 2d or 3d sphere and vertices for each face
               in the grid with number of points taken from ellObj
               nPlot2dPoints or nPlot3dPoints parameters

::

    CHECKISME - determine whether input object is ellipsoid. And display
                message and abort function if input object
                is not ellipsoid

    Input:
      regular:
          someObjArr: any[] - any type array of objects.

    Example:
      ellObj = ellipsoid([1; 2], eye(2));
      ellipsoid.checkIsMe(ellObj)

::

    Ellipsoid library of the Ellipsoidal Toolbox.


    Constructor and data accessing functions:
    -----------------------------------------
     ellipsoid    - Constructor of ellipsoid object.
     double       - Returns parameters of ellipsoid, i.e. center and shape
                    matrix.
     parameters   - Same function as 'double'(legacy matter).
     dimension    - Returns dimension of ellipsoid and its rank.
     isdegenerate - Checks if ellipsoid is degenerate.
     isempty      - Checks if ellipsoid is empty.
     maxeig       - Returns the biggest eigenvalue of the ellipsoid.
     mineig       - Returns the smallest eigenvalue of the ellipsoid.
     trace        - Returns the trace of the ellipsoid.
     volume       - Returns the volume of the ellipsoid.


    Overloaded operators and functions:
    -----------------------------------
     eq      - Checks if two ellipsoids are equal.
     ne      - The opposite of 'eq'.
     gt, ge  - E1 > E2 (E1 >= E2) checks if, given the same center ellipsoid
               E1 contains E2.
     lt, le  - E1 < E2 (E1 <= E2) checks if, given the same center ellipsoid
               E2 contains E1.
     mtimes  - Given matrix A in R^(mxn) and ellipsoid E in R^n, returns
               (A * E).
     plus    - Given vector b in R^n and ellipsoid E in R^n, returns (E + b).
     minus   - Given vector b in R^n and ellipsoid E in R^n, returns (E - b).
     uminus  - Changes the sign of the center of ellipsoid.
     display - Displays the details about given ellipsoid object.
     inv     - inverts the shape matrix of the ellipsoid.
     plot    - Plots ellipsoid in 1D, 2D and 3D.


    Geometry functions:
    -------------------
     move2origin        - Moves the center of ellipsoid to the origin.
     shape              - Same as 'mtimes', but modifies only shape matrix of
                          the ellipsoid leaving its center as is.
     rho                - Computes the value of support function and
                          corresponding boundary point of the ellipsoid in
                          the given direction.
     polar              - Computes the polar ellipsoid to an ellipsoid that
                          contains the origin.
     projection         - Projects the ellipsoid onto a subspace specified
                          by  orthogonal basis vectors.
     minksum            - Computes and plots the geometric (Minkowski) sum of
                          given ellipsoids in 1D, 2D and 3D.
     minksum_ea         - Computes the external ellipsoidal approximation of
                          geometric sum of given ellipsoids in given
                          direction.
     minksum_ia         - Computes the internal ellipsoidal approximation of
                          geometric sum of given ellipsoids in given
                          direction.
     minkdiff           - Computes and plots the geometric (Minkowski)
                          difference of given ellipsoids in 1D, 2D and 3D.
     minkdiff_ea        - Computes the external ellipsoidal approximation of
                          geometric difference of two ellipsoids in given
                          direction.
     minkdiff_ia        - Computes the internal ellipsoidal approximation of
                          geometric difference of two ellipsoids in given
                          direction
     minkpm             - Computes and plots the geometric (Minkowski)
                          difference of a geometric sum of ellipsoids and a
                          single ellipsoid in 1D, 2D and 3D.
     minkpm_ea          - Computes the external ellipsoidal approximation of
                          the geometric difference of a geometric sum of
                          ellipsoids and a single ellipsoid in given
                          direction.
     minkpm_ia          - Computes the internal ellipsoidal approximation of
                          the geometric difference of a geometric sum of
                          ellipsoids and a single ellipsoid in given
                          direction.
     minkmp             - Computes and plots the geometric (Minkowski) sum of
                          a geometric difference of two single ellipsoids and
                          a geometric sum of ellipsoids in 1D, 2D and 3D.
     minkmp_ea          - Computes the external ellipsoidal approximation of
                          the geometric sum of a geometric difference of two
                          single ellipsoids and a geometric sum of ellipsoids
                          in given direction.
     minkmp_ia          -  Computes the internal ellipsoidal approximation of
                          the geometric sum of a geometric difference of
                          two single ellipsoids and a geometric sum of ellipsoids
                          in given direction.
     isbaddirection     - Checks if ellipsoidal approximation of geometric difference
                          of two ellipsoids in the given direction can be computed.
     doesIntersectionContain           - Checks if the union or intersection of
                          ellipsoids or polytopes lies inside the intersection
                          of given ellipsoids.
     isinternal         - Checks if given vector belongs to the union or intersection
                          of given ellipsoids.
     distance           - Computes the distance from ellipsoid to given point,
                          ellipsoid, hyperplane or polytope.
     intersect          - Checks if the union or intersection of ellipsoids intersects
                          with given ellipsoid, hyperplane, or polytope.
     intersection_ea    - Computes the minimal volume ellipsoid containing intersection
                          of two ellipsoids, ellipsoid and halfspace, or ellipsoid
                          and polytope.
     intersection_ia    - Computes the maximal ellipsoid contained inside the
                          intersection of two ellipsoids, ellipsoid and halfspace
                          or ellipsoid and polytope.
     ellintersection_ia - Computes maximum volume ellipsoid that is contained
                          in the intersection of given ellipsoids (can be more than 2).
     ellunion_ea        - Computes minimum volume ellipsoid that contains
                          the union of given ellipsoids.
     hpintersection     - Computes the intersection of ellipsoid with hyperplane.

::

    DIMENSION - returns the dimension of the space in which the ellipsoid is
                defined and the actual dimension of the ellipsoid.

    Input:
      regular:
        myEllArr: ellipsoid[nDims1,nDims2,...,nDimsN] - array of ellipsoids.

    Output:
      regular:
        dimArr: double[nDims1,nDims2,...,nDimsN] - space dimensions.

      optional:
        rankArr: double[nDims1,nDims2,...,nDimsN] - dimensions of the
               ellipsoids in myEllArr.

    Example:
      firstEllObj = ellipsoid();
      tempMatObj = [3 1; 0 1; -2 1];
      secEllObj = ellipsoid([1; -1; 1], tempMatObj*tempMatObj');
      thirdEllObj = ellipsoid(eye(2));
      fourthEllObj = ellipsoid(0);
      ellMat = [firstEllObj secEllObj; thirdEllObj fourthEllObj];
      [dimMat, rankMat] = ellMat.dimension()

      dimMat =

         0     3
         2     1

      rankMat =

         0     2
         2     0

::

    DISP - Displays ellipsoid object.

    Input:
      regular:
        myEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.

    Example:
      ellObj = ellipsoid([-2; -1], [2 -1; -1 1]);
      disp(ellObj)

      Ellipsoid with parameters
      Center:
          -2
          -1

      Shape Matrix:
           2    -1
          -1     1

::

    DISPLAY - Displays the details of the ellipsoid object.

    Input:
      regular:
          myEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.

    Example:
      ellObj = ellipsoid([-2; -1], [2 -1; -1 1]);
      display(ellObj)

      ellObj =

      Center:
          -2
          -1

      Shape Matrix:
           2    -1
          -1     1

      Nondegenerate ellipsoid in R^2.

::

    DISTANCE - computes distance between the given ellipsoid (or array of
               ellipsoids) to the specified object (or arrays of objects):
               vector, ellipsoid, hyperplane or polytope.

    Input:
      regular:
          ellObjArr: ellipsoid [nDims1, nDims2,..., nDimsN] -  array of
             ellipsoids of the same dimension.
          objArray: double / ellipsoid / hyperplane / polytope [nDims1,
              nDims2,..., nDimsN] - array of vectors or ellipsoids or
              hyperplanes or polytopes. If number of elements in objArray
              is more than 1, then it must be equal to the number of elements
              in ellObjArr.

      optional:
          isFlagOn: logical[1,1] - if true then distance is  computed in
              ellipsoidal metric, if false - in Euclidean metric (by default
              isFlagOn=false).

    Output:
      regular:
        distValArray: double [nDims1, nDims2,..., nDimsN] - array of pairwise
              calculated distances.
              Negative distance value means
                  for ellipsoid and vector: vector belongs to the ellipsoid,
                  for ellipsoid and hyperplane: ellipsoid intersects the
                      hyperplane.
                  Zero distance value means for ellipsoid and vector: vector
                      is aboundary point of the ellipsoid,
                  for ellipsoid and hyperplane: ellipsoid  touches the
                      hyperplane.
      optional:
          statusArray: double [nDims1, nDims2,..., nDimsN] - array of time of
              computation of ellipsoids-vectors or ellipsoids-ellipsoids
              distances, or status of cvx solver for ellipsoids-polytopes
              distances.

    Literature:
     1. Lin, A. and Han, S. On the Distance between Two Ellipsoids.
        SIAM Journal on Optimization, 2002, Vol. 13, No. 1 : pp. 298-308
     2. Stanley Chan, "Numerical method for Finding Minimum Distance to an
        Ellipsoid".
        http://videoprocessing.ucsd.edu/~stanleychan/publication/...
        unpublished/Ellipse.pdf

    Example:
      ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      tempMat = [1 1; 1 -1; -1 1; -1 -1]';
      distVec = ellObj.distance(tempMat)

      distVec =

           2.3428    1.0855    1.3799    -1.0000

::

    DOESCONTAIN - checks if one ellipsoid contains the other ellipsoid or
                  polytope. The condition for E1 = firstEllArr to contain
                  E2 = secondEllArr is
                  min(rho(l | E1) - rho(l | E2)) > 0, subject to <l, l> = 1.
                  How checked if ellipsoid contains polytope is explained in
                  doesContainPoly.
    Input:
      regular:
          firstEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - first
              array of ellipsoids.
          secondObjArr: ellipsoid [nDims1,nDims2,...,nDimsN]/
              polytope[nDims1,nDims2,...,nDimsN]/[1,1] - array of the same
              size as firstEllArr or single ellipsoid or polytope.

       properties:
          mode: char[1, 1] - 'u' or 'i', go to description.
          computeMode: char[1,] - 'highDimFast' or 'lowDimFast'. Determines,
              which way function is computed, when secObjArr is polytope. If
              secObjArr is ellipsoid computeMode is ignored. 'highDimFast'
              works  faster for  high dimensions, 'lowDimFast' for low. If
              this property is omitted if dimension of ellipsoids is greater
              then 10, then 'hightDimFast' is choosen, otherwise -
              'lowDimFast'

    Output:
      isPosArr: logical[nDims1,nDims2,...,nDimsN],
          resArr(iCount) = true - firstEllArr(iCount)
          contains secondObjArr(iCount), false - otherwise.

    Example:
      firstEllObj = ellipsoid([-2; -1], [2 -1; -1 1]);
      secEllObj = ellipsoid([-1;0], eye(2));
      doesContain(firstEllObj,secEllObj)

      ans =

           0

::

    DOESINTERSECTIONCONTAIN - checks if the intersection of ellipsoids
                              contains the union or intersection of given
                              ellipsoids or polytopes.

      res = DOESINTERSECTIONCONTAIN(fstEllArr, secEllArr, mode)
          Checks if the union
          (mode = 'u') or intersection (mode = 'i') of ellipsoids in
          secEllArr lies inside the intersection of ellipsoids in
          fstEllArr. Ellipsoids in fstEllArr and secEllArr must be
          of the same dimension. mode = 'u' (default) - union of
          ellipsoids in secEllArr. mode = 'i' - intersection.
      res = DOESINTERSECTIONCONTAIN(fstEllArr, secPolyArr, mode)
           Checks if the union
          (mode = 'u') or intersection (mode = 'i')  of polytopes in
          secPolyArr lies inside the intersection of ellipsoids in
          fstEllArr. Ellipsoids in fstEllArr and polytopes in secPolyArr
          must be of the same dimension. mode = 'u' (default) - union of
          polytopes in secPolyMat. mode = 'i' - intersection.

      To check if the union of ellipsoids secEllArr belongs to the
      intersection of ellipsoids fstEllArr, it is enough to check that
      every ellipsoid of secEllMat is contained in every
      ellipsoid of fstEllArr.
      Checking if the intersection of ellipsoids in secEllMat is inside
      intersection fstEllMat can be formulated as quadratically
      constrained quadratic programming (QCQP) problem.

      Let fstEllArr(iEll) = E(q, Q) be an ellipsoid with center q and shape
      matrix Q. To check if this ellipsoid contains the intersection of
      ellipsoids in secObjArr:
      E(q1, Q1), E(q2, Q2), ..., E(qn, Qn), we define the QCQP problem:
                        J(x) = <(x - q), Q^(-1)(x - q)> --> max
      with constraints:
                        <(x - q1), Q1^(-1)(x - q1)> <= 1   (1)
                        <(x - q2), Q2^(-1)(x - q2)> <= 1   (2)
                        ................................
                        <(x - qn), Qn^(-1)(x - qn)> <= 1   (n)

      If this problem is feasible, i.e. inequalities (1)-(n) do not
      contradict, or, in other words, intersection of ellipsoids
      E(q1, Q1), E(q2, Q2), ..., E(qn, Qn) is nonempty, then we can find
      vector y such that it satisfies inequalities (1)-(n)
      and maximizes function J. If J(y) <= 1, then ellipsoid E(q, Q)
      contains the given intersection, otherwise, it does not.

      The intersection of polytopes is a polytope, which is computed
      by the standard routine of MPT. How checked if intersection of
      ellipsoids contains polytope is explained in doesContainPoly.

      Checking if the union of polytopes belongs to the intersection
      of ellipsoids is the same as checking if its convex hull belongs
      to this intersection.

    Input:
      regular:
          fstEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
              of the same size.
          secEllArr: ellipsoid /
              polytope [nDims1,nDims2,...,nDimsN] - array of ellipsoids or
              polytopes of the same sizes.

              note: if mode == 'i', then fstEllArr, secEllVec should be
                  array.

      properties:
          mode: char[1, 1] - 'u' or 'i', go to description.
          computeMode: char[1,] - 'highDimFast' or 'lowDimFast'. Determines,
              which way function is computed, when secObjArr is polytope. If
              secObjArr is ellipsoid computeMode is ignored. 'highDimFast'
              works  faster for  high dimensions, 'lowDimFast' for low. If
              this property is omitted if dimension of ellipsoids is greater
              then 10, then 'hightDimFast' is choosen, otherwise -
              'lowDimFast'


    Output:
      res: double[1, 1] - result:
          -1 - problem is infeasible, for example, if s = 'i',
              but the intersection of ellipsoids in E2 is an empty set;
          0 - intersection is empty;
          1 - if intersection is nonempty.
      status: double[0, 0]/double[1, 1] - status variable. status is empty
          if mode == 'u' or mSecRows == nSecCols == 1.

    Example:
      firstEllObj = [0 ; 0] + ellipsoid(eye(2, 2));
      secEllObj = [0 ; 0] + ellipsoid(2*eye(2, 2));
      thirdEllObj = [1; 0] + ellipsoid(0.5 * eye(2, 2));
      secEllObj.doesIntersectionContain([firstEllObj secEllObj], 'i')

      ans =

           1

::

    DOUBLE - returns parameters of the ellipsoid.

    Input:
      regular:
          myEll: ellipsoid [1, 1] - single ellipsoid of dimention nDims.


    Output:
      myEllCentVec: double[nDims, 1] - center of the ellipsoid myEll.

      myEllShMat: double[nDims, nDims] - shape matrix of the ellipsoid myEll.

    Example:
      ellObj = ellipsoid([-2; -1], [2 -1; -1 1]);
      [centVec, shapeMat] = double(ellObj)
      centVec =

          -2
          -1


      shapeMat =

           2    -1
          -1     1

::

    ELLBNDR_2D - compute the boundary of 2D ellipsoid. Private method.

    Input:
      regular:
          myEll: ellipsoid [1, 1]- ellipsoid of the dimention 2.
      optional:
          nPoints: number of boundary points

    Output:
      regular:
          bpMat: double[nPoints,2] - boundary points of ellipsoid
      optional:
          fVec: double[1,nFaces] - indices of points in each face of
              bpMat graph

::

    ELLBNDR_3D - compute the boundary of 3D ellipsoid.

    Input:
      regular:
          myEll: ellipsoid [1, 1]- ellipsoid of the dimention 3.

      optional:
          nPoints: number of boundary points

    Output:
      regular:
          bpMat: double[nPoints,3] - boundary points of ellipsoid
      optional:
          fMat: double[nFaces,3] - indices of face verties in bpMat

::

    ELLINTERSECTION_IA - computes maximum volume ellipsoid that is contained
                         in the intersection of given ellipsoids.


    Input:
      regular:
          inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
              ellipsoids of the same dimentions.

    Output:
      outEll: ellipsoid [1, 1] - resulting maximum volume ellipsoid.

    Example:
      firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
      secEllObj = ellipsoid([1 2], eye(2);
      ellVec = [firstEllObj secEllObj];
      resEllObj = ellintersection_ia(ellVec)

      resEllObj =

      Center:
          0.1847
          1.6914

      Shape Matrix:
          0.0340   -0.0607
         -0.0607    0.1713

      Nondegenerate ellipsoid in R^2.

::

    ELLIPSOID - constructor of the ellipsoid object.

      Ellipsoid E = { x in R^n : <(x - q), Q^(-1)(x - q)> <= 1 }, with current
          "Properties". Here q is a vector in R^n, and Q in R^(nxn) is positive
          semi-definite matrix

      ell = ELLIPSOID - Creates an empty ellipsoid

      ell = ELLIPSOID(shMat) - creates an ellipsoid with shape matrix shMat,
          centered at 0

       ell = ELLIPSOID(centVec, shMat) - creates an ellipsoid with shape matrix
          shMat and center centVec

      ell = ELLIPSOID(centVec, shMat, 'propName1', propVal1,...,
          'propNameN',propValN) - creates an ellipsoid with shape
          matrix shMat, center centVec and propName1 = propVal1,...,
          propNameN = propValN. In other cases "Properties"
          are taken from current values stored in
          elltool.conf.Properties.
      ellMat = Ellipsoid(centVecArray, shMatArray,
          ['propName1', propVal1,...,'propNameN',propValN]) -
          creates an array (possibly multidimensional) of
          ellipsoids with centers centVecArray(:,dim1,...,dimn)
          and matrices shMatArray(:,:,dim1,...dimn) with
          properties if given.

      These parameters can be accessed by DOUBLE(E) function call.
      Also, DIMENSION(E) function call returns the dimension of
      the space in which ellipsoid E is defined and the actual
      dimension of the ellipsoid; function ISEMPTY(E) checks if
      ellipsoid E is empty; function ISDEGENERATE(E) checks if
      ellipsoid E is degenerate.

    Input:
      Case1:
        regular:
          shMatArray: double [nDim, nDim] /
              double [nDim, nDim, nDim1,...,nDimn] -
              shape matrices array

      Case2:
        regular:
          centVecArray: double [nDim,1] /
              double [nDim, 1, nDim1,...,nDimn] -
              centers array
          shMatArray: double [nDim, nDim] /
              double [nDim, nDim, nDim1,...,nDimn] -
              shape matrices array


      properties:
          absTol: double [1,1] - absolute tolerance with default value 10^(-7)
          relTol: double [1,1] - relative tolerance with default value 10^(-5)
          nPlot2dPoints: double [1,1] - number of points for 2D plot with
              default value 200
          nPlot3dPoints: double [1,1] - number of points for 3D plot with
               default value 200.

    Output:
      ellMat: ellipsoid [1,1] / ellipsoid [nDim1,...nDimn] -
          ellipsoid with specified properties
          or multidimensional array of ellipsoids.

    Example:
      ellObj = ellipsoid([1 0 -1 6]', 9*eye(4));

::

    ELLUNION_EA - computes minimum volume ellipsoid that contains union
                  of given ellipsoids.

    Input:
      regular:
          inpEllMat: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
              ellipsoids of the same dimentions.

    Output:
      outEll: ellipsoid [1, 1] - resulting minimum volume ellipsoid.

    Example:
      firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
      secEllObj = ellipsoid([1 2], eye(2));
      ellVec = [firstEllObj secEllObj];
      resEllObj = ellunion_ea(ellVec)
      resEllObj =

      Center:
         -0.3188
          1.2936

      Shape Matrix:
          5.4573    1.3386
          1.3386    4.1037

      Nondegenerate ellipsoid in R^2.

::

    FROMREPMAT - returns array of equal ellipsoids the same
                 size as stated in sizeVec argument

      ellArr = fromRepMat(sizeVec) - creates an array  size
               sizeVec of empty ellipsoids.

      ellArr = fromRepMat(shMat,sizeVec) - creates an array
               size sizeVec of ellipsoids with shape matrix
               shMat.

      ellArr = fromRepMat(cVec,shMat,sizeVec) - creates an
               array size sizeVec of ellipsoids with shape
               matrix shMat and center cVec.

    Input:
      Case1:
          regular:
              sizeVec: double[1,n] - vector of size, have
              integer values.

      Case2:
          regular:
              shMat: double[nDim, nDim] - shape matrix of
              ellipsoids.
              sizeVec: double[1,n] - vector of size, have
              integer values.

      Case3:
          regular:
              cVec: double[nDim,1] - center vector of
              ellipsoids
              shMat: double[nDim, nDim] - shape matrix of
              ellipsoids.
              sizeVec: double[1,n] - vector of size, have
              integer values.

      properties:
          absTol: double [1,1] - absolute tolerance with default
              value 10^(-7)
          relTol: double [1,1] - relative tolerance with default
              value 10^(-5)
          nPlot2dPoints: double [1,1] - number of points for 2D plot
              with default value 200
          nPlot3dPoints: double [1,1] - number of points for 3D plot
              with default value 200.

::

    fromStruct -- converts structure array into ellipsoid array.

    Input:
      regular:
          SEllArr: struct [nDim1, nDim2, ...] - array
              of structures with the following fields:

          q: double[1, nEllDim] - the center of ellipsoid
          Q: double[nEllDim, nEllDim] - the shape matrix of ellipsoid
    Output:
          ellArr: ellipsoid [nDim1, nDim2, ...] - ellipsoid array with size of
              SEllArr.

    Example:
    s = struct('Q', eye(2), 'q', [0 0]);
    ellipsoid.fromStruct(s)

    -------ellipsoid object-------
    Properties:
       |
       |-- actualClass : 'ellipsoid'
       |--------- size : [1, 1]

    Fields (name, type, description):
        'Q'    'double'    'Configuration matrix'
        'q'    'double'    'Center'

    Data:
       |
       |-- q : [0 0]
       |       -----
       |-- Q : |1|0|
       |       |0|1|
       |       -----

::

    GETABSTOL - gives the array of absTol for all elements in ellArr

    Input:
      regular:
          ellArr: ellipsoid[nDim1, nDim2, ...] - multidimension array
              of ellipsoids
      optional
          fAbsTolFun: function_handle[1,1] - function that apply
              to the absTolArr. The default is @min.

    Output:
      regular:
          absTolArr: double [absTol1, absTol2, ...] - return absTol for
              each element in ellArr
      optional:
          absTol: double[1,1] - return result of work fAbsTolFun with
              the absTolArr

    Usage:
      use [~,absTol] = ellArr.getAbsTol() if you want get only
          absTol,
      use [absTolArr,absTol] = ellArr.getAbsTol() if you want get
          absTolArr and absTol,
      use absTolArr = ellArr.getAbsTol() if you want get only absTolArr

    Example:
      firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
      secEllObj = ellipsoid([1 2], eye(2));
      ellVec = [firstEllObj secEllObj];
      absTolVec = ellVec.getAbsTol()

      absTolVec =

         1.0e-07 *

          1.0000    1.0000

::

    GETBOUNDARY - computes the boundary of an ellipsoid.

    Input:
      regular:
          myEll: ellipsoid [1, 1]- ellipsoid of the dimention 2 or 3.
      optional:
          nPoints: number of boundary points

    Output:
      regular:
          bpMat: double[nPoints,nDim] - boundary points of ellipsoid
      optional:
          fVec: double[1,nFaces]/double[nFacex,nDim] - indices of points in
              each face of bpMat graph

::

      GETBOUNDARYBYFACTOR - computes grid of 2d or 3d ellipsoid and vertices
                            for each face in the grid

::

    GETCENTERVEC - returns centerVec vector of given ellipsoid

    Input:
      regular:
         self: ellipsoid[1,1]

    Output:
      centerVecVec: double[nDims,1] - centerVec of ellipsoid

    Example:
      ellObj = ellipsoid([1; 2], eye(2));
      getCenterVec(ellObj)

      ans =

           1
           2

::

    GETCOPY - gives array the same size as ellArr with copies of elements of
              ellArr.

    Input:
      regular:
          ellArr: ellipsoid[nDim1, nDim2,...] - multidimensional array of
              ellipsoids.

    Output:
      copyEllArr: ellipsoid[nDim1, nDim2,...] - multidimension array of
          copies of elements of ellArr.

    Example:
      firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
      secEllObj = ellipsoid([1; 2], eye(2));
      ellVec = [firstEllObj secEllObj];
      copyEllVec = getCopy(ellVec)

      copyEllVec =
      1x2 array of ellipsoids.

::

    GETINV - do the same as INV method: inverts shape matrices of ellipsoids
          in the given array, with only difference, that it doesn't modify
          input array of ellipsoids.

    Input:
      regular:
        myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids.

    Output:
       invEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
          with inverted shape matrices.

    Example:
      ellObj = ellipsoid([1; 1], [4 -1; -1 5]);
      invEllObj = ellObj.getInv()

      invEllObj =

      Center:
           1
           1

      Shape Matrix:
          0.2632    0.0526
          0.0526    0.2105

      Nondegenerate ellipsoid in R^2.

::

    GETMOVE2ORIGIN - do the same as MOVE2ORIGIN method: moves ellipsoids in
          the given array to the origin, with only difference, that it doesn't
          modify input array of ellipsoids.

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
              ellipsoids.

    Output:
      outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
          with the same shapes as in inpEllArr centered at the origin.

    Example:
      ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      outEllObj = ellObj.getMove2Origin()

      outEllObj =

      Center:
           0
           0

      Shape:
           4    -1
          -1     1

      Nondegenerate ellipsoid in R^2.

::

    GETNPLOT2DPOINTS - gives value of nPlot2dPoints property of ellipsoids
                       in ellArr

    Input:
      regular:
          ellArr: ellipsoid[nDim1, nDim2,...] - mltidimensional array of
              ellipsoids

    Output:
          nPlot2dPointsArr: double[nDim1, nDim2,...] - multidimension array
              of nPlot2dPoints property for ellipsoids in ellArr
    Example:
      firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
      secEllObj = ellipsoid([1 ;2], eye(2));
      ellVec = [firstEllObj secEllObj];
      ellVec.getNPlot2dPoints()

      ans =

         200   200

::

    GETNPLOT3DPOINTS - gives value of nPlot3dPoints property of ellipsoids
                       in ellArr

    Input:
      regular:
          ellArr: ellipsoid[nDim1, nDim2,...] - mltidimensional array  of
             ellipsoids

    Output:
          nPlot2dPointsArr: double[nDim1, nDim2,...] - multidimension array
              of nPlot3dPoints property for ellipsoids in ellArr

    Example:
      firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
      secEllObj = ellipsoid([1 ;2], eye(2));
      ellVec = [firstEllObj secEllObj];
      ellVec.getNPlot3dPoints()

      ans =

         200   200

::

    GETPROJECTION - do the same as PROJECTION method: computes projection of
          the ellipsoid onto the given subspace, with only difference, that
          it doesn't modify input array of ellipsoids.

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
              of ellipsoids.
          basisMat: double[nDim, nSubSpDim] - matrix of orthogonal basis
              vectors

    Output:
      projEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
          projected ellipsoids, generally, of lower dimension.

    Example:
      ellObj = ellipsoid([-2; -1; 4], [4 -1 0; -1 1 0; 0 0 9]);
      basisMat = [0 1 0; 0 0 1]';
      outEllObj = ellObj.getProjection(basisMat)

      outEllObj =

      Center:
          -1
           4

      Shape:
          1     0
          0     9

      Nondegenerate ellipsoid in R^2.

::

    GETRELTOL - gives the array of relTol for all elements in ellArr

    Input:
      regular:
          ellArr: ellipsoid[nDim1, nDim2, ...] - multidimension array
              of ellipsoids
      optional:
          fRelTolFun: function_handle[1,1] - function that apply
              to the relTolArr. The default is @min.
    Output:
      regular:
          relTolArr: double [relTol1, relTol2, ...] - return relTol for
              each element in ellArr
      optional:
          relTol: double[1,1] - return result of work fRelTolFun with
              the relTolArr

    Usage:
      use [~,relTol] = ellArr.getRelTol() if you want get only
          relTol,
      use [relTolArr,relTol] = ellArr.getRelTol() if you want get
          relTolArr and relTol,
      use relTolArr = ellArr.getRelTol() if you want get only relTolArr

    Example:
      firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
      secEllObj = ellipsoid([1 ;2], eye(2));
      ellVec = [firstEllObj secEllObj];
      ellVec.getRelTol()

      ans =

         1.0e-05 *

          1.0000    1.0000

::

    GETSHAPE -  do the same as SHAPE method: modifies the shape matrix of the
       ellipsoid without changing its center, with only difference, that
       it doesn't modify input array of ellipsoids.

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
              of ellipsoids.
          modMat: double[nDim, nDim]/[1,1] - square matrix or scalar

    Output:
       outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of modified
          ellipsoids.

    Example:
      ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      tempMat = [0 1; -1 0];
      outEllObj = ellObj.getShape(tempMat)

      outEllObj =

      Center:
          -2
          -1

      Shape:
          1     1
          1     4

      Nondegenerate ellipsoid in R^2.

::

    GETSHAPEMAT - returns shapeMat matrix of given ellipsoid

    Input:
      regular:
         self: ellipsoid[1,1]

    Output:
      shMat: double[nDims,nDims] - shapeMat matrix of ellipsoid

    Example:
      ellObj = ellipsoid([1; 2], eye(2));
      getShapeMat(ellObj)

      ans =

           1     0
           0     1

::

    HPINTERSECTION - computes the intersection of ellipsoid with hyperplane.

    Input:
      regular:
          myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
              of ellipsoids.
          myHypArr: hyperplane [nDims1,nDims2,...,nDimsN]/[1,1] - array
              of hyperplanes of the same size.

    Output:
      intEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
          resulting from intersections.

      isnIntersectedArr: logical [nDims1,nDims2,...,nDimsN].
          isnIntersectedArr(iCount) = true, if myEllArr(iCount)
          doesn't intersect myHipArr(iCount),
          isnIntersectedArr(iCount) = false, otherwise.

    Example:
      ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      hypMat = [hyperplane([0 -1; -1 0]', 1); hyperplane([0 -2; -1 0]', 1)];
      ellMat = ellObj.hpintersection(hypMat)

      ellMat =
      2x2 array of ellipsoids.

::

    INTERSECT - checks if the union or intersection of ellipsoids intersects
                given ellipsoid, hyperplane or polytope.

      resArr = INTERSECT(myEllArr, objArr, mode) - Checks if the union
          (mode = 'u') or intersection (mode = 'i') of ellipsoids
          in myEllArr intersects with objects in objArr.
          objArr can be array of ellipsoids, array of hyperplanes,
          or array of polytopes.
          Ellipsoids, hyperplanes or polytopes in objMat must have
          the same dimension as ellipsoids in myEllArr.
          mode = 'u' (default) - union of ellipsoids in myEllArr.
          mode = 'i' - intersection.

      If we need to check the intersection of union of ellipsoids in
      myEllArr (mode = 'u'), or if myEllMat is a single ellipsoid,
      it can be done by calling distance function for each of the
      ellipsoids in myEllArr and objMat, and if it returns negative value,
      the intersection is nonempty. Checking if the intersection of
      ellipsoids in myEllArr (with size of myEllMat greater than 1)
      intersects with ellipsoids or hyperplanes in objArr is more
      difficult. This problem can be formulated as quadratically
      constrained quadratic programming (QCQP) problem.

      Let objArr(iObj) = E(q, Q) be an ellipsoid with center q and shape
      matrix Q. To check if this ellipsoid intersects (or touches) the
      intersection of ellipsoids in meEllArr: E(q1, Q1), E(q2, Q2), ...,
      E(qn, Qn), we define the QCQP problem:
                        J(x) = <(x - q), Q^(-1)(x - q)> --> min
      with constraints:
                         <(x - q1), Q1^(-1)(x - q1)> <= 1   (1)
                         <(x - q2), Q2^(-1)(x - q2)> <= 1   (2)
                         ................................
                         <(x - qn), Qn^(-1)(x - qn)> <= 1   (n)

      If this problem is feasible, i.e. inequalities (1)-(n) do not
      contradict, or, in other words, intersection of ellipsoids
      E(q1, Q1), E(q2, Q2), ..., E(qn, Qn) is nonempty, then we can find
      vector y such that it satisfies inequalities (1)-(n) and minimizes
      function J. If J(y) <= 1, then ellipsoid E(q, Q) intersects or touches
      the given intersection, otherwise, it does not. To check if E(q, Q)
      intersects the union of E(q1, Q1), E(q2, Q2), ..., E(qn, Qn),
      we compute the distances from this ellipsoids to those in the union.
      If at least one such distance is negative,
      then E(q, Q) does intersect the union.

      If we check the intersection of ellipsoids with hyperplane
      objArr = H(v, c), it is enough to check the feasibility
      of the problem
                          1'x --> min
      with constraints (1)-(n), plus
                        <v, x> - c = 0.

      Checking the intersection of ellipsoids with polytope
      objArr = P(A, b) reduces to checking if there any x, satisfying
      constraints (1)-(n) and
                           Ax <= b.

    Input:
      regular:
          myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
               ellipsoids.
          objArr: ellipsoid / hyperplane /
              / polytope [nDims1,nDims2,...,nDimsN] - array of ellipsoids or
              hyperplanes or polytopes of the same sizes.

      optional:
          mode: char[1, 1] - 'u' or 'i', go to description.

              note: If mode == 'u', then mRows, nCols should be equal to 1.

    Output:
      resArr: double[nDims1,nDims2,...,nDimsN] - return:
          resArr(iCount) = -1 in case parameter mode is set
              to 'i' and the intersection of ellipsoids in myEllArr
              is empty.
          resArr(iCount) = 0 if the union or intersection of
              ellipsoids in myEllArr does not intersect the object
              in objArr(iCount).
          resArr(iCount) = 1 if the union or intersection of
              ellipsoids in myEllArr and the object in objArr(iCount)
              have nonempty intersection.
      statusArr: double[0, 0]/double[nDims1,nDims2,...,nDimsN] - status
          variable. statusArr is empty if mode = 'u'.

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = firstEllObj + [5; 5];
      hypObj  = hyperplane([1; -1]);
      ellVec = [firstEllObj secEllObj];
      ellVec.intersect(hypObj)

      ans =

           1

      ellVec.intersect(hypObj, 'i')

      ans =

          -1

::

    INTERSECTION_EA - external ellipsoidal approximation of the
                      intersection of two ellipsoids, or ellipsoid and
                      halfspace, or ellipsoid and polytope.

      outEllArr = INTERSECTION_EA(myEllArr, objArr) Given two ellipsoidal
          matrixes of equal sizes, myEllArr and objArr = ellArr, or,
          alternatively, myEllArr or ellMat must be a single ellipsoid,
          computes the ellipsoid that contains the intersection of two
          corresponding ellipsoids from myEllArr and from ellArr.
      outEllArr = INTERSECTION_EA(myEllArr, objArr) Given matrix of
          ellipsoids myEllArr and matrix of hyperplanes objArr = hypArr
          whose sizes match, computes the external ellipsoidal
          approximations of intersections of ellipsoids
          and halfspaces defined by hyperplanes in hypArr.
          If v is normal vector of hyperplane and c - shift,
          then this hyperplane defines halfspace
                  <v, x> <= c.
      outEllArr = INTERSECTION_EA(myEllArr, objArr) Given matrix of
          ellipsoids myEllArr and matrix of polytopes objArr = polyArr
          whose sizes match, computes the external ellipsoidal
          approximations of intersections of ellipsoids myEllMat and
          polytopes polyArr.

      The method used to compute the minimal volume overapproximating
      ellipsoid is described in "Ellipsoidal Calculus Based on
      Propagation and Fusion" by Lluis Ros, Assumpta Sabater and
      Federico Thomas; IEEE Transactions on Systems, Man and Cybernetics,
      Vol.32, No.4, pp.430-442, 2002. For more information, visit
      http://www-iri.upc.es/people/ros/ellipsoids.html

      For polytopes this method won't give the minimal volume
      overapproximating ellipsoid, but just some overapproximating ellipsoid.

    Input:
      regular:
          myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
              of ellipsoids.
          objArr: ellipsoid / hyperplane /
              / polytope [nDims1,nDims2,...,nDimsN]/[1,1]  - array of
              ellipsoids or hyperplanes or polytopes of the same sizes.

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = firstEllObj + [5; 5];
      ellVec = [firstEllObj secEllObj];
      thirdEllObj  = ell_unitball(2);
      externalEllVec = ellVec.intersection_ea(thirdEllObj)

      externalEllVec =
      1x2 array of ellipsoids.

::

    INTERSECTION_IA - internal ellipsoidal approximation of the
                      intersection of ellipsoid and ellipsoid,
                      or ellipsoid and halfspace, or ellipsoid
                      and polytope.

      outEllArr = INTERSECTION_IA(myEllArr, objArr) - Given two
          ellipsoidal matrixes of equal sizes, myEllArr and
          objArr = ellArr, or, alternatively, myEllMat or ellMat must be
          a single ellipsoid, comuptes the internal ellipsoidal
          approximations of intersections of two corresponding ellipsoids
          from myEllMat and from ellMat.
      outEllArr = INTERSECTION_IA(myEllArr, objArr) - Given matrix of
          ellipsoids myEllArr and matrix of hyperplanes objArr = hypArr
          whose sizes match, computes the internal ellipsoidal
          approximations of intersections of ellipsoids and halfspaces
          defined by hyperplanes in hypMat.
          If v is normal vector of hyperplane and c - shift,
          then this hyperplane defines halfspace
                     <v, x> <= c.
      outEllArr = INTERSECTION_IA(myEllArr, objArr) - Given matrix of
          ellipsoids  myEllArr and matrix of polytopes objArr = polyArr
          whose sizes match, computes the internal ellipsoidal
          approximations of intersections of ellipsoids myEllArr
          and polytopes polyArr.

      The method used to compute the minimal volume overapproximating
      ellipsoid is described in "Ellipsoidal Calculus Based on
      Propagation and Fusion" by Lluis Ros, Assumpta Sabater and
      Federico Thomas; IEEE Transactions on Systems, Man and Cybernetics,
      Vol.32, No.4, pp.430-442, 2002. For more information, visit
      http://www-iri.upc.es/people/ros/ellipsoids.html

      The method used to compute maximum volume ellipsoid inscribed in
      intersection of ellipsoid and polytope, is modified version of
      algorithm of finding maximum volume ellipsoid inscribed in intersection
      of ellipsoids discribed in Stephen Boyd and Lieven Vandenberghe "Convex
      Optimization". It works properly for nondegenerate ellipsoid, but for
      degenerate ellipsoid result would not lie in this ellipsoid. The result
      considered as empty ellipsoid, when maximum absolute velue of element
      in its matrix is less than myEllipsoid.getAbsTol().

    Input:
      regular:
          myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
              of ellipsoids.
          objArr: ellipsoid / hyperplane /
              / polytope [nDims1,nDims2,...,nDimsN]/[1,1]  - array of
              ellipsoids or hyperplanes or polytopes of the same sizes.

    Output:
       outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of internal
          approximating ellipsoids; entries can be empty ellipsoids
          if the corresponding intersection is empty.

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = firstEllObj + [5; 5];
      ellVec = [firstEllObj secEllObj];
      thirdEllObj  = ell_unitball(2);
      internalEllVec = ellVec.intersection_ia(thirdEllObj)

      internalEllVec =
      1x2 array of ellipsoids.

::

    INV - inverts shape matrices of ellipsoids in the given array,
          modified given array is on output (not its copy).


      invEllArr = INV(myEllArr)  Inverts shape matrices of ellipsoids
          in the array myEllMat. In case shape matrix is sigular, it is
          regularized before inversion.

    Input:
      regular:
        myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids.

    Output:
       myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
          with inverted shape matrices.

    Example:
      ellObj = ellipsoid([1; 1], [4 -1; -1 5]);
      ellObj.inv()

      ans =

      Center:
           1
           1

      Shape Matrix:
          0.2632    0.0526
          0.0526    0.2105

      Nondegenerate ellipsoid in R^2.

::

    ISEMPTY - checks if the ellipsoid object is empty.

    Input:
      regular:
          myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
               ellipsoids.

    Output:
      isPositiveArr: logical[nDims1,nDims2,...,nDimsN],
          isPositiveArr(iCount) = true - if ellipsoid
          myEllMat(iCount) is empty, false - otherwise.

    Example:
      ellObj = ellipsoid();
      isempty(ellObj)

      ans =

           1

::

    ISEQUAL - produces logical array the same size as
              ellFirstArr/ellFirstArr (if they have the same).
              isEqualArr[iDim1, iDim2,...] is true if corresponding
              ellipsoids are equal and false otherwise.

    Input:
      regular:
          ellFirstArr: ellipsoid[nDim1, nDim2,...] - multidimensional array
              of ellipsoids.
          ellSecArr: ellipsoid[nDim1, nDim2,...] - multidimensional array
              of ellipsoids.
      properties:
          'isPropIncluded': makes to compare second value properties, such as
          absTol etc.
    Output:
      isEqualArr: logical[nDim1, nDim2,...] - multidimension array of
          logical values. isEqualArr[iDim1, iDim2,...] is true if
          corresponding ellipsoids are equal and false otherwise.

      reportStr: char[1,] - comparison report.

::

    ISINSIDE - checks if given ellipsoid(or array of
               ellipsoids) lies inside given object(or array
               of objects): ellipsoid or polytope.

    Input:
      regular:
          ellArr: ellipsoid[nDims1,nDims2,...,nDimsN] - array
                  of ellipsoids of the same dimension.
          objArr: ellipsoid/
                  polytope[nDims1,nDims2,...,nDimsN] of
                  objects of the same dimension. If
                  ellArr and objArr both non-scalar, than
                  size of ellArr must be the same as size of
                  objArr. Note that polytopes could be
                  combined only in vector of size [1,N].
    Output:
      regular:
          resArr: logical[nDims1,nDims2,...,nDimsN] array of
                  results. resArr[iDim1,...,iDimN] = true, if
                  ellArr[iDim1,...,iDimN] lies inside
                  objArr[iDim1,...,iDimN].

    Example:
      firstEllObj = [0 ; 0] + ellipsoid(eye(2, 2));
      secEllObj = [0 ; 0] + ellipsoid(2*eye(2, 2));
      firstEllObj.isInside(secEllObj)

      ans =

           1

::

    ISBADDIRECTION - checks if ellipsoidal approximations of geometric
                     difference of two ellipsoids can be computed for
                     given directions.
      isBadDirVec = ISBADDIRECTION(fstEll, secEll, dirsMat) - Checks if
          it is possible to build ellipsoidal approximation of the
          geometric difference of two ellipsoids fstEll - secEll in
          directions specified by matrix dirsMat (columns of dirsMat
          are direction vectors). Type 'help minkdiff_ea' or
          'help minkdiff_ia' for more information.

    Input:
      regular:
          fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose nDim - space
              dimension.
          secEll: ellipsoid [1, 1] - second ellipsoid of the same dimention.
          dirsMat: numeric[nDims, nCols] - matrix whose columns are
              direction vectors that need to be checked.
          absTol: double [1,1] - absolute tolerance

    Output:
       isBadDirVec: logical[1, nCols] - array of true or false with length
          being equal to the number of columns in matrix dirsMat.
          ture marks direction vector as bad - ellipsoidal approximation
          true marks direction vector as bad - ellipsoidal approximation
          cannot be computed for this direction. false means the opposite.

::

    ISBIGGER - checks if one ellipsoid would contain the other if their
               centers would coincide.

      isPositive = ISBIGGER(fstEll, secEll) - Given two single ellipsoids
          of the same dimension, fstEll and secEll, check if fstEll
          would contain secEll inside if they were both
          centered at origin.

    Input:
      regular:
          fstEll: ellipsoid [1, 1] - first ellipsoid.
          secEll: ellipsoid [1, 1] - second ellipsoid
              of the same dimention.

    Output:
      isPositive: logical[1, 1], true - if ellipsoid fstEll
          would contain secEll inside, false - otherwise.

    Example:
      firstEllObj = ellipsoid([1; 1], eye(2));
      secEllObj = ellipsoid([1; 1], [4 -1; -1 5]);
      isbigger(firstEllObj, secEllObj)

      ans =

           0

::

    ISDEGENERATE - checks if the ellipsoid is degenerate.

    Input:
      regular:
          myEllArr: ellipsoid[nDims1,nDims2,...,nDimsN] - array of ellipsoids.

    Output:
      isPositiveArr: logical[nDims1,nDims2,...,nDimsN],
          isPositiveArr(iCount) = true if ellipsoid myEllMat(iCount)
          is degenerate, false - otherwise.

    Example:
      ellObj = ellipsoid([1; 1], eye(2));
      isdegenerate(ellObj)

      ans =

           0

::

    ISINTERNAL - checks if given points belong to the union or intersection
                 of ellipsoids in the given array.

      isPositiveVec = ISINTERNAL(myEllArr,  matrixOfVecMat, mode) - Checks
          if vectors specified as columns of matrix matrixOfVecMat
          belong to the union (mode = 'u'), or intersection (mode = 'i')
          of the ellipsoids in myEllArr. If myEllArr is a single
          ellipsoid, then this function checks if points in matrixOfVecMat
          belong to myEllArr or not. Ellipsoids in myEllArr must be
          of the same dimension. Column size of matrix  matrixOfVecMat
          should match the dimension of ellipsoids.

       Let myEllArr(iEll) = E(q, Q) be an ellipsoid with center q and shape
       matrix Q. Checking if given vector matrixOfVecMat = x belongs
       to E(q, Q) is equivalent to checking if inequality
                       <(x - q), Q^(-1)(x - q)> <= 1
       holds.
       If x belongs to at least one of the ellipsoids in the array, then it
       belongs to the union of these ellipsoids. If x belongs to all
       ellipsoids in the array,
       then it belongs to the intersection of these ellipsoids.
       The default value of the specifier s = 'u'.

       WARNING: be careful with degenerate ellipsoids.

    Input:
      regular:
          myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
              of ellipsoids.
          matrixOfVecMat: double [mRows, nColsOfVec] - matrix which
              specifiy points.

      optional:
          mode: char[1, 1] - 'u' or 'i', go to description.

    Output:
       isPositiveVec: logical[1, nColsOfVec] -
          true - if vector belongs to the union or intersection
          of ellipsoids, false - otherwise.

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = firstEllObj + [5; 5];
      ellVec = [firstEllObj secEllObj];
      ellVec.isinternal([-2 3; -1 4], 'i')

      ans =

           0     0

      ellVec.isinternal([-2 3; -1 4])

      ans =

           1     1

::

    MAXEIG - return the maximal eigenvalue of the ellipsoid.

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
               ellipsoids.

    Output:
      maxEigArr: double[nDims1,nDims2,...,nDimsN] - array of maximal
          eigenvalues of ellipsoids in the input matrix inpEllMat.

    Example:
      ellObj = ellipsoid([-2; 4], [4 -1; -1 5]);
      maxEig = maxeig(ellObj)

      maxEig =

          5.6180

::

    MINEIG - return the minimal eigenvalue of the ellipsoid.

    Input:
       regular:
          inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
            ellipsoids.

    Output:
       minEigArr: double[nDims1,nDims2,...,nDimsN] - array of minimal
          eigenvalues of ellipsoids in the input array inpEllMat.

    Example:
      ellObj = ellipsoid([-2; 4], [4 -1; -1 5]);
      minEig = mineig(ellObj)

      minEig =

          3.3820

::

    MINKCOMMONACTION - plot Minkowski operation  of ellipsoids in 2D or 3D.
    Usage:
    minkCommonAction(getEllArr,fCalcBodyTriArr,...
       fCalcCenterTriArr,varargin) -  plot Minkowski operation  of
               ellipsoids in 2D or 3D, using triangulation  of output object

    Input:
      regular:
          getEllArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
                   array of 2D or 3D Ellipsoids objects. All ellipsoids in
                   ellArr must be either 2D or 3D simutaneously.
    fCalcBodyTriArr - function, calculeted triangulation of output object
       fCalcCenterTriArr - function, calculeted center  of output object
               properties:
          'shawAll': logical[1,1] - if 1, plot all ellArr.
                       Default value is 0.
          'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
                  if 1, ellipsoids in 2D will be filled with color.
                  Default value is 0.
          'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                       line width for 1D and 2D plots. Default value is 1.
          'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
                   sets default colors in the form [x y z].
                  Default value is [1 0 0].
          'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                   level of transparency between 0 and 1
                      (0 - transparent, 1 - opaque).
                   Default value is 0.4.
          'relDataPlotter' - relation data plotter object.

    Output:
      centVec: double[nDim, 1] - center of the resulting set.
      boundPointMat: double[nDim, nBoundPoints] - set of boundary
          points (vertices) of resulting set.

::

    MINKDIFF - computes geometric (Minkowski) difference of two
                ellipsoids in 2D or 3D.
     Usage:
    MINKDIFF(inpEllMat,'Property',PropValue,...) - Computes
    geometric difference of two ellipsoids in the array inpEllMat, if
    1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
           and plots it if no output arguments are specified.

       [centVec, boundPointMat] = MINKDIFF(inpEllMat) - Computes
           geometric difference of two ellipsoids in inpEllMat.
           Here centVec is
           the center, and boundPointMat - array of boundary points.
       MINKDIFF(inpEllMat) - Plots geometric differencr of two
       ellipsoids in inpEllMat in default (red) color.
       MINKDIFF(inpEllMat, 'Property',PropValue,...) -
        Plots geometric sum of inpEllMat
           with setting properties.

       In order for the geometric difference to be nonempty set,
       ellipsoid fstEll must be bigger than secEll in the sense that
       if fstEll and secEll had the same centerVec, secEll would be
       contained inside fstEll.
     Input:
       regular:
           ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
                    array of 2D or 3D Ellipsoids objects. All ellipsoids in ellArr
                    must be either 2D or 3D simutaneously.

       properties:
           'shawAll': logical[1,1] - if 1, plot all ellArr.
                        Default value is 0.
           'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
                   if 1, ellipsoids in 2D will be filled with color.
                   Default value is 0.
           'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                        line width for 1D and 2D plots. Default value is 1.
           'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
                    sets default colors in the form [x y z].
                   Default value is [1 0 0].
           'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                    level of transparency between 0 and 1
                       (0 - transparent, 1 - opaque).
                    Default value is 0.4.
           'relDataPlotter' - relation data plotter object.
           Notice that property vector could have different dimensions, only
           total number of elements must be the same.

     Output:
       centVec: double[nDim, 1] - center of the resulting set.
       boundPointMat: double[nDim, nBoundPoints] - set of boundary
           points (vertices) of resulting set.

     Example:
       firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
       secEllObj = ellipsoid([1 2], eye(2));
       [centVec, boundPointMat] = minkdiff(firstEllObj, secEllObj);

::

    MINKDIFF_EA - computation of external approximating ellipsoids
                  of the geometric difference of two ellipsoids along
                  given directions.

      extApprEllVec = MINKDIFF_EA(fstEll, secEll, directionsMat) -
          Computes external approximating ellipsoids of the
          geometric difference of two ellipsoids fstEll - secEll
          along directions specified by columns of matrix directionsMat

      First condition for the approximations to be computed, is that
      ellipsoid fstEll = E1 must be bigger than ellipsoid secEll = E2
      in the sense that if they had the same center, E2 would be contained
      inside E1. Otherwise, the geometric difference E1 - E2
      is an empty set.
      Second condition for the approximation in the given direction l
      to exist, is the following. Given
          P = sqrt(<l, Q1 l>)/sqrt(<l, Q2 l>)
      where Q1 is the shape matrix of ellipsoid E1, and
      Q2 - shape matrix of E2, and R being minimal root of the equation
          det(Q1 - R Q2) = 0,
      parameter P should be less than R.
      If both of these conditions are satisfied, then external
      approximating ellipsoid is defined by its shape matrix
          Q = (Q1^(1/2) + S Q2^(1/2))' (Q1^(1/2) + S Q2^(1/2)),
      where S is orthogonal matrix such that vectors
          Q1^(1/2)l and SQ2^(1/2)l
      are parallel, and its center
          q = q1 - q2,
      where q1 is center of ellipsoid E1 and q2 - center of E2.

    Input:
      regular:
          fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
              nDim - space dimension.
          secEll: ellipsoid [1, 1] - second ellipsoid
              of the same dimention.
          directionsMat: double[nDim, nCols] - matrix whose columns
              specify the directions for which the approximations
              should be computed.

    Output:
      extApprEllVec: ellipsoid [1, nCols] - array of external
          approximating ellipsoids (empty, if for all specified
          directions approximations cannot be computed).

    Example:
      firstEllObj= ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = 3*ell_unitball(2);
      dirsMat = [1 0; 1 1; 0 1; -1 1]';
      externalEllVec = secEllObj.minkdiff_ea(firstEllObj, dirsMat)

      externalEllVec =
      1x2 array of ellipsoids.

::

    MINKDIFF_IA - computation of internal approximating ellipsoids
                  of the geometric difference of two ellipsoids along
                  given directions.

      intApprEllVec = MINKDIFF_IA(fstEll, secEll, directionsMat) -
          Computes internal approximating ellipsoids of the geometric
          difference of two ellipsoids fstEll - secEll along directions
          specified by columns of matrix directionsMat.

      First condition for the approximations to be computed, is that
      ellipsoid fstEll = E1 must be bigger than ellipsoid secEll = E2
      in the sense that if they had the same center, E2 would be contained
      inside E1. Otherwise, the geometric difference E1 - E2 is an
      empty set. Second condition for the approximation in the given
      direction l to exist, is the following. Given
          P = sqrt(<l, Q1 l>)/sqrt(<l, Q2 l>)
      where Q1 is the shape matrix of ellipsoid E1,
      and Q2 - shape matrix of E2, and R being minimal root of the equation
          det(Q1 - R Q2) = 0,
      parameter P should be less than R.
      If these two conditions are satisfied, then internal approximating
      ellipsoid for the geometric difference E1 - E2 along the
      direction l is defined by its shape matrix
          Q = (1 - (1/P)) Q1 + (1 - P) Q2
      and its center
          q = q1 - q2,
      where q1 is center of E1 and q2 - center of E2.

    Input:
      regular:
          fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
              nDim - space dimension.
          secEll: ellipsoid [1, 1] - second ellipsoid
              of the same dimention.
          directionsMat: double[nDim, nCols] - matrix whose columns
              specify the directions for which the approximations
              should be computed.

    Output:
      intApprEllVec: ellipsoid [1, nCols] - array of internal
          approximating ellipsoids (empty, if for all specified directions
          approximations cannot be computed).

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = 3*ell_unitball(2);
      dirsMat = [1 0; 1 1; 0 1; -1 1]';
      internalEllVec = secEllObj.minkdiff_ia(firstEllObj, dirsMat)

      internalEllVec =
      1x2 array of ellipsoids.

::

    MINKMP - computes and plots geometric (Minkowski) sum of the
             geometric difference of two ellipsoids and the geometric
             sum of n ellipsoids in 2D or 3D:
             (E - Em) + (E1 + E2 + ... + En),
             where E = firstEll, Em = secondEll,
             E1, E2, ..., En - are ellipsoids in sumEllArr

    Usage:
      MINKMP(firEll,secEll,ellMat,'Property',PropValue,...) -
              Computes (E1 - E2) + (E3 + E4+ ... + En), if
          1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
          and plots it if no output arguments are specified.

      [centVec, boundPointMat] = MINKMP(firEll,secEll,ellMat) - Computes
         (E1 - E2) + (E3 + E4+ ... + En). Here centVec is
          the center, and boundPointMat - array of boundary points.
    Input:
      regular:
          ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
              array of 2D or 3D Ellipsoids objects. All ellipsoids in ellArr
                   must be either 2D or 3D simutaneously.

      properties:
          'showAll': logical[1,1] - if 1, plot all ellArr.
                       Default value is 0.
          'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
                  if 1, ellipsoids in 2D will be filled with color.
                  Default value is 0.
          'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]-
                       line width for 1D and 2D plots. Default value is 1.
          'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
                   sets default colors in the form [x y z].
                      Default value is [1 0 0].
          'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                   level of transparency between 0 and 1
                  (0 - transparent, 1 - opaque).
                   Default value is 0.4.
          'relDataPlotter' - relation data plotter object.
          Notice that property vector could have different dimensions, only
          total number of elements must be the same.

    Output:
      centVec: double[nDim, 1] - center of the resulting set.
      boundPointMat: double[nDim, nBoundPoints] - set of boundary
          points (vertices) of resulting set.

    Example:
      firstEllObj = ellipsoid([-2; -1], [2 -1; -1 1]);
      secEllObj = ell_unitball(2);
      ellVec = [firstEllObj secEllObj ellipsoid([-3; 1], eye(2))];
      minkmp(firstEllObj, secEllObj, ellVec);

::

    MINKMP_EA - computation of external approximating ellipsoids
                of (E - Em) + (E1 + ... + En) along given directions.
                where E = fstEll, Em = secEll,
                E1, E2, ..., En - are ellipsoids in sumEllArr

      extApprEllVec = MINKMP_EA(fstEll, secEll, sumEllArr, dirMat) -
          Computes external approximating
          ellipsoids of (E - Em) + (E1 + E2 + ... + En),
          where E1, E2, ..., En are ellipsoids in array sumEllArr,
          E = fstEll, Em = secEll,
          along directions specified by columns of matrix dirMat.

    Input:
      regular:
          fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
              nDims - space dimension.
          secEll: ellipsoid [1, 1] - second ellipsoid
              of the same dimention.
          sumEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array of
              ellipsoids of the same dimentions nDims.
          dirMat: double[nDims, nCols] - matrix whose columns specify the
              directions for which the approximations should be computed.

    Output:
      extApprEllVec: ellipsoid [1, nCols] - array of external
          approximating ellipsoids (empty, if for all specified
          directions approximations cannot be computed).

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = 3*ell_unitball(2);
      dirsMat = [1 0; 1 1; 0 1; -1 1]';
      bufEllVec = [secEllObj firstEllObj];
      externalEllVec = secEllObj.minkmp_ea(firstEllObj, bufEllVec, dirsMat)

      externalEllVec =
      1x2 array of ellipsoids.

::

    MINKMP_IA - computation of internal approximating ellipsoids
                of (E - Em) + (E1 + ... + En) along given directions.
                where E = fstEll, Em = secEll,
                E1, E2, ..., En - are ellipsoids in sumEllArr

      intApprEllVec = MINKMP_IA(fstEll, secEll, sumEllArr, dirMat) -
          Computes internal approximating
          ellipsoids of (E - Em) + (E1 + E2 + ... + En),
          where E1, E2, ..., En are ellipsoids in array sumEllArr,
          E = fstEll, Em = secEll,
          along directions specified by columns of matrix dirMat.

    Input:
      regular:
          fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
              nDim - space dimension.
          secEll: ellipsoid [1, 1] - second ellipsoid
              of the same dimention.
          sumEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array of
              ellipsoids of the same dimentions.
          dirMat: double[nDim, nCols] - matrix whose columns specify the
              directions for which the approximations should be computed.

    Output:
      intApprEllVec: ellipsoid [1, nCols] - array of internal
          approximating ellipsoids (empty, if for all specified
          directions approximations cannot be computed).

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = 3*ell_unitball(2);
      dirsMat = [1 0; 1 1; 0 1; -1 1]';
      bufEllVec = [secEllObj firstEllObj];
      internalEllVec = secEllObj.minkmp_ia(firstEllObj, bufEllVec, dirsMat)

      internalEllVec =
      1x2 array of ellipsoids.

::

    MINKPM - computes and plots geometric (Minkowski) difference
             of the geometric sum of ellipsoids and a single ellipsoid
             in 2D or 3D: (E1 + E2 + ... + En) - E,
             where E = inpEll,
             E1, E2, ... En - are ellipsoids in inpEllArr.

      MINKPM(inpEllArr, inpEll, OPTIONS)  Computes geometric difference
          of the geometric sum of ellipsoids in inpEllMat and
          ellipsoid inpEll, if
          1 <= dimension(inpEllArr) = dimension(inpArr) <= 3,
          and plots it if no output arguments are specified.

      [centVec, boundPointMat] = MINKPM(inpEllArr, inpEll) - pomputes
          (geometric sum of ellipsoids in inpEllArr) - inpEll.
          Here centVec is the center, and boundPointMat - array
          of boundary points.
      MINKPM(inpEllArr, inpEll) - plots (geometric sum of ellipsoids
          in inpEllArr) - inpEll in default (red) color.
      MINKPM(inpEllArr, inpEll, Options) - plots
          (geometric sum of ellipsoids in inpEllArr) - inpEll using
          options given in the Options structure.

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array of
              ellipsoids of the same dimentions 2D or 3D.
          inpEll: ellipsoid [1, 1] - ellipsoid of the same
              dimention 2D or 3D.

      optional:
          Options: structure[1, 1] - fields:
              show_all: double[1, 1] - if 1, displays
                  also ellipsoids fstEll and secEll.
              newfigure: double[1, 1] - if 1, each plot
                  command will open a new figure window.
              fill: double[1, 1] - if 1, the resulting
                  set in 2D will be filled with color.
              color: double[1, 3] - sets default colors
                  in the form [x y z].
              shade: double[1, 1] = 0-1 - level of transparency
                  (0 - transparent, 1 - opaque).

    Output:
       centVec: double[nDim, 1]/double[0, 0] - center of the resulting set.
          centerVec may be empty.
       boundPointMat: double[nDim, ]/double[0, 0] - set of boundary
          points (vertices) of resulting set. boundPointMat may be empty.

::

    MINKPM_EA - computation of external approximating ellipsoids
                of (E1 + E2 + ... + En) - E along given directions.
                where E = inpEll,
                E1, E2, ... En - are ellipsoids in inpEllArr.

      ExtApprEllVec = MINKPM_EA(inpEllArr, inpEll, dirMat) - Computes
          external approximating ellipsoids of
          (E1 + E2 + ... + En) - E, where E1, E2, ..., En are ellipsoids
          in array inpEllArr, E = inpEll,
          along directions specified by columns of matrix dirMat.

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] -
              array of ellipsoids of the same dimentions.
          inpEll: ellipsoid [1, 1] - ellipsoid of the same dimention.
          dirMat: double[nDim, nCols] - matrix whose columns specify
              the directions for which the approximations
              should be computed.

    Output:
      extApprEllVec: ellipsoid [1, nCols]/[0, 0] - array of external
          approximating ellipsoids. Empty, if for all specified
          directions approximations cannot be computed.

    Example:
      firstEllObj = ellipsoid([2; -1], [9 -5; -5 4]);
      secEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      thirdEllObj = ell_unitball(2);
      dirsMat = [1 0; 1 1; 0 1; -1 1]';
      ellVec = [thirdEllObj firstEllObj];
      externalEllVec = ellVec.minkpm_ea(secEllObj, dirsMat)

      externalEllVec =
      1x4 array of ellipsoids.

::

    MINKPM_IA - computation of internal approximating ellipsoids
                of (E1 + E2 + ... + En) - E along given directions.
                where E = inpEll,
                E1, E2, ... En - are ellipsoids in inpEllArr.

      intApprEllVec = MINKPM_IA(inpEllArr, inpEll, dirMat) - Computes
          internal approximating ellipsoids of
          (E1 + E2 + ... + En) - E, where E1, E2, ..., En are ellipsoids
          in array inpEllArr, E = inpEll,
          along directions specified by columns of matrix dirArr.

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] -
              array of ellipsoids of the same dimentions.
          inpEll: ellipsoid [1, 1] - ellipsoid of the same dimention.
          dirMat: double[nDim, nCols] - matrix whose columns specify
              the directions for which the approximations
              should be computed.

    Output:
      intApprEllVec: ellipsoid [1, nCols]/[0, 0] - array of internal
          approximating ellipsoids. Empty, if for all specified
          directions approximations cannot be computed.

    Example:
      firstEllObj = ellipsoid([2; -1], [9 -5; -5 4]);
      secEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      thirdEllObj = ell_unitball(2);
      ellVec = [thirdEllObj firstEllObj];
      dirsMat = [1 0; 1 1; 0 1; -1 1]';
      internalEllVec = ellVec.minkpm_ia(secEllObj, dirsMat)

      internalEllVec =
      1x3 array of ellipsoids.

::

    MINKSUM - computes geometric (Minkowski) sum of ellipsoids in 2D or 3D.

    Usage:
      MINKSUM(inpEllMat,'Property',PropValue,...) - Computes geometric sum of
          ellipsoids in the array inpEllMat, if
          1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
          and plots it if no output arguments are specified.

      [centVec, boundPointMat] = MINKSUM(inpEllMat) - Computes
          geometric sum of ellipsoids in inpEllMat. Here centVec is
          the center, and boundPointMat - array of boundary points.
      MINKSUM(inpEllMat) - Plots geometric sum of ellipsoids in
          inpEllMat in default (red) color.
      MINKSUM(inpEllMat, 'Property',PropValue,...) - Plots geometric sum of
      inpEllMat with setting properties.

    Input:
      regular:
          ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
                   array of 2D or 3D Ellipsoids objects. All ellipsoids
                   in ellArr must be either 2D or 3D simutaneously.

      properties:
       'showAll': logical[1,1] - if 1, plot all ellArr.
                       Default value is 0.
       'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
                  if 1, ellipsoids in 2D will be filled with color. Default
                  value is 0.
       'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]-
                       line width for 1D and 2D plots. Default value is 1.
       'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
           sets default colors in the form [x y z]. Default value is [1 0 0].
       'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
         level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
                   Default value is 0.4.
          'relDataPlotter' - relation data plotter object.
          Notice that property vector could have different dimensions, only
          total number of elements must be the same.

    Output:
      centVec: double[nDim, 1] - center of the resulting set.
      boundPointMat: double[nDim, nBoundPoints] - set of boundary
          points (vertices) of resulting set.

    Example:
      firstEllObj = ellipsoid([-2; -1], [2 -1; -1 1]);
      secEllObj = ell_unitball(2);
      ellVec = [firstEllObj, secellObj]
      sumVec = minksum(ellVec);

::

    MINKSUM_EA - computation of external approximating ellipsoids
                 of the geometric sum of ellipsoids along given directions.

      extApprEllVec = MINKSUM_EA(inpEllArr, dirMat) - Computes
          tight external approximating ellipsoids for the geometric
          sum of the ellipsoids in the array inpEllArr along directions
          specified by columns of dirMat.
          If ellipsoids in inpEllArr are n-dimensional, matrix
          dirMat must have dimension (n x k) where k can be
          arbitrarily chosen.
          In this case, the output of the function will contain k
          ellipsoids computed for k directions specified in dirMat.

      Let inpEllArr consists of E(q1, Q1), E(q2, Q2), ..., E(qm, Qm) -
      ellipsoids in R^n, and dirMat(:, iCol) = l - some vector in R^n.
      Then tight external approximating ellipsoid E(q, Q) for the
      geometric sum E(q1, Q1) + E(q2, Q2) + ... + E(qm, Qm)
      along direction l, is such that
          rho(l | E(q, Q)) = rho(l | (E(q1, Q1) + ... + E(qm, Qm)))
      and is defined as follows:
          q = q1 + q2 + ... + qm,
          Q = (p1 + ... + pm)((1/p1)Q1 + ... + (1/pm)Qm),
      where
          p1 = sqrt(<l, Q1l>), ..., pm = sqrt(<l, Qml>).

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array
              of ellipsoids of the same dimentions.
          dirMat: double[nDims, nCols] - matrix whose columns specify
              the directions for which the approximations
              should be computed.

    Output:
      extApprEllVec: ellipsoid [1, nCols] - array of external
          approximating ellipsoids.

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = ell_unitball(2);
      ellVec = [firstEllObj secEllObj firstEllObj.inv()];
      dirsMat = [1 0; 1 1; 0 1; -1 1]';
      externalEllVec = ellVec.minksum_ea(dirsMat)

      externalEllVec =
      1x4 array of ellipsoids.

::

    MINKSUM_IA - computation of internal approximating ellipsoids
                 of the geometric sum of ellipsoids along given directions.

      intApprEllVec = MINKSUM_IA(inpEllArr, dirMat) - Computes
          tight internal approximating ellipsoids for the geometric
          sum of the ellipsoids in the array inpEllArr along directions
          specified by columns of dirMat. If ellipsoids in
          inpEllArr are n-dimensional, matrix dirMat must have
          dimension (n x k) where k can be arbitrarily chosen.
          In this case, the output of the function will contain k
          ellipsoids computed for k directions specified in dirMat.

      Let inpEllArr consist of E(q1, Q1), E(q2, Q2), ..., E(qm, Qm) -
      ellipsoids in R^n, and dirMat(:, iCol) = l - some vector in R^n.
      Then tight internal approximating ellipsoid E(q, Q) for the
      geometric sum E(q1, Q1) + E(q2, Q2) + ... + E(qm, Qm) along
      direction l, is such that
          rho(l | E(q, Q)) = rho(l | (E(q1, Q1) + ... + E(qm, Qm)))
      and is defined as follows:
          q = q1 + q2 + ... + qm,
          Q = (S1 Q1^(1/2) + ... + Sm Qm^(1/2))' *
              * (S1 Q1^(1/2) + ... + Sm Qm^(1/2)),
      where S1 = I (identity), and S2, ..., Sm are orthogonal
      matrices such that vectors
      (S1 Q1^(1/2) l), ..., (Sm Qm^(1/2) l) are parallel.

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array
              of ellipsoids of the same dimentions.
          dirMat: double[nDim, nCols] - matrix whose columns specify the
              directions for which the approximations should be computed.

    Output:
      intApprEllVec: ellipsoid [1, nCols] - array of internal
          approximating ellipsoids.

    Example:
      firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      secEllObj = ell_unitball(2);
      ellVec = [firstEllObj secEllObj firstEllObj.inv()];
      dirsMat = [1 0; 1 1; 0 1; -1 1]';
      internalEllVec = ellVec.minksum_ia(dirsMat)

      internalEllVec =
      1x4 array of ellipsoids.

::

    MINUS - overloaded operator '-'

      outEllArr = MINUS(inpEllArr, inpVec) implements E(q, Q) - b
          for each ellipsoid E(q, Q) in inpEllArr.
      outEllArr = MINUS(inpVec, inpEllArr) implements b - E(q, Q)
          for each ellipsoid E(q, Q) in inpEllArr.

      Operation E - b where E = inpEll is an ellipsoid in R^n,
      and b = inpVec - vector in R^n. If E(q, Q) is an ellipsoid
      with center q and shape matrix Q, then
      E(q, Q) - b = E(q - b, Q).

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
              ellipsoids of the same dimentions nDims.
          inpVec: double[nDims, 1] - vector.

    Output:
       outEllVec: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
          with same shapes as inpEllVec, but with centers shifted by vectors
          in -inpVec.

    Example:
      ellVec  = [ellipsoid([-2; -1], [4 -1; -1 1]) ell_unitball(2)];
      outEllVec = ellVec - [1; 1];
      outEllVec(1)

      ans =

      Center:
          -3
          -2

      Shape:
           4    -1
          -1     1

      Nondegenerate ellipsoid in R^2.

      outEllVec(2)

      ans =

      Center:
          -1
          -1

      Shape:
           1     0
           0     1

      Nondegenerate ellipsoid in R^2.

::

    MOVE2ORIGIN - moves ellipsoids in the given array to the origin. Modified
                  given array is on output (not its copy).

      outEllArr = MOVE2ORIGIN(inpEll) - Replaces the centers of
          ellipsoids in inpEllArr with zero vectors.

    Input:
      regular:
          inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
              ellipsoids.

    Output:
      inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
          with the same shapes as in inpEllArr centered at the origin.

    Example:
      ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      outEllObj = ellObj.move2origin()

      outEllObj =

      Center:
           0
           0

      Shape:
           4    -1
          -1     1

      Nondegenerate ellipsoid in R^2.

::

    MTIMES - overloaded operator '*'.

      Multiplication of the ellipsoid by a matrix or a scalar.
      If inpEllVec(iEll) = E(q, Q) is an ellipsoid, and
      multMat = A - matrix of suitable dimensions,
      then A E(q, Q) = E(Aq, AQA').

    Input:
      regular:
          multMat: double[mRows, nDims]/[1, 1] - scalar or
              matrix in R^{mRows x nDim}
          inpEllVec: ellipsoid [1, nCols] - array of ellipsoids.

    Output:
      outEllVec: ellipsoid [1, nCols] - resulting ellipsoids.

    Example:
      ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      tempMat = [0 1; -1 0];
      outEllObj = tempMat*ellObj

      outEllObj =

      Center:
          -1
           2

      Shape:
           1     1
           1     4

      Nondegenerate ellipsoid in R^2.

::

    PARAMETERS - returns parameters of the ellipsoid.

    Input:
      regular:
          myEll: ellipsoid [1, 1] - single ellipsoid of dimention nDims.

    Output:
      myEllCenterVec: double[nDims, 1] - center of the ellipsoid myEll.
      myEllShapeMat: double[nDims, nDims] - shape matrix
          of the ellipsoid myEll.

    Example:
      ellObj = ellipsoid([-2; 4], [4 -1; -1 5]);
      [centVec shapeMat] = parameters(ellObj)
      centVec =

          -2
           4

      shapeMat =

          4    -1
         -1     5

::

    PLOT - plots ellipsoids in 2D or 3D.


    Usage:
          plot(ell) - plots ellipsoid ell in default (red) color.
          plot(ellArr) - plots an array of ellipsoids.
          plot(ellArr, 'Property',PropValue,...) - plots ellArr with setting
                                                   properties.

    Input:
      regular:
          ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
                   array of 2D or 3D Ellipsoids objects. All ellipsoids in ellArr
                   must be either 2D or 3D simutaneously.
      optional:
          color1Spec: char[1,1] - color specification code, can be 'r','g',
                                  etc (any code supported by built-in Matlab function).
          ell2Arr: Ellipsoid: [dim21Size,dim22Size,...,dim2kSize] -
                                              second ellipsoid array...
          color2Spec: char[1,1] - same as color1Spec but for ell2Arr
          ....
          ellNArr: Ellipsoid: [dimN1Size,dim22Size,...,dimNkSize] -
                                               N-th ellipsoid array
          colorNSpec - same as color1Spec but for ellNArr.
      properties:
          'newFigure': logical[1,1] - if 1, each plot command will open a new figure window.
                       Default value is 0.
          'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
                  if 1, ellipsoids in 2D will be filled with color. Default value is 0.
          'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                       line width for 1D and 2D plots. Default value is 1.
          'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
                   sets default colors in the form [x y z]. Default value is [1 0 0].
          'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                   level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
                   Default value is 0.4.
          'relDataPlotter' - relation data plotter object.
          Notice that property vector could have different dimensions, only
          total number of elements must be the same.
    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

    Examples:
          plot([ell1, ell2, ell3], 'color', [1, 0, 1; 0, 0, 1; 1, 0, 0]);
          plot([ell1, ell2, ell3], 'color', [1; 0; 1; 0; 0; 1; 1; 0; 0]);
          plot([ell1, ell2, ell3; ell1, ell2, ell3], 'shade', [1, 1, 1; 1, 1,
          1]);
          plot([ell1, ell2, ell3; ell1, ell2, ell3], 'shade', [1; 1; 1; 1; 1;
          1]);
          plot([ell1, ell2, ell3], 'shade', 0.5);
          plot([ell1, ell2, ell3], 'lineWidth', 1.5);
          plot([ell1, ell2, ell3], 'lineWidth', [1.5, 0.5, 3]);

::

    PLUS - overloaded operator '+'

      outEllArr = PLUS(inpEllArr, inpVec) implements E(q, Q) + b
          for each ellipsoid E(q, Q) in inpEllArr.
      outEllArr = PLUS(inpVec, inpEllArr) implements b + E(q, Q)
          for each ellipsoid E(q, Q) in inpEllArr.

       Operation E + b (or b+E) where E = inpEll is an ellipsoid in R^n,
      and b=inpVec - vector in R^n. If E(q, Q) is an ellipsoid
      with center q and shape matrix Q, then
      E(q, Q) + b = b + E(q,Q) = E(q + b, Q).

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
              of the same dimentions nDims.
          bVec: double[nDims, 1] - vector.

    Output:
      outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
          with same shapes as ellVec, but with centers shifted by vectors
          in inpVec.

    Example:
      ellVec  = [ellipsoid([-2; -1], [4 -1; -1 1]) ell_unitball(2)];
      outEllVec = ellVec + [1; 1];
      outEllVec(1)

      ans =

      Center:
          -1
           0

      Shape:
          4    -1
         -1     1

      Nondegenerate ellipsoid in R^2.

      outEllVec(2)

      ans =

      Center:
           1
           1

      Shape:
          1     0
          0     1

      Nondegenerate ellipsoid in R^2.

::

    POLAR - computes the polar ellipsoids.

      polEllArr = POLAR(ellArr)  Computes the polar ellipsoids for those
          ellipsoids in ellArr, for which the origin is an interior point.
          For those ellipsoids in E, for which this condition does not hold,
          an empty ellipsoid is returned.

      Given ellipsoid E(q, Q) where q is its center, and Q - its shape matrix,
      the polar set to E(q, Q) is defined as follows:
      P = { l in R^n  | <l, q> + sqrt(<l, Q l>) <= 1 }
      If the origin is an interior point of ellipsoid E(q, Q),
      then its polar set P is an ellipsoid.

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
              of ellipsoids.

    Output:
      polEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
           polar ellipsoids.

    Example:
      ellObj = ellipsoid([4 -1; -1 1]);
      ellObj.polar() == ellObj.inv()

      ans =

          1

::

    PROJECTION - computes projection of the ellipsoid onto the given subspace.
                 modified given array is on output (not its copy).

      projEllArr = projection(ellArr, basisMat)  Computes projection of the
          ellipsoid ellArr onto a subspace, specified by orthogonal
          basis vectors basisMat. ellArr can be an array of ellipsoids of
          the same dimension. Columns of B must be orthogonal vectors.

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
              of ellipsoids.
          basisMat: double[nDim, nSubSpDim] - matrix of orthogonal basis
              vectors

    Output:
      ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
          projected ellipsoids, generally, of lower dimension.

    Example:
      ellObj = ellipsoid([-2; -1; 4], [4 -1 0; -1 1 0; 0 0 9]);
      basisMat = [0 1 0; 0 0 1]';
      outEllObj = ellObj.projection(basisMat)

      outEllObj =

      Center:
          -1
           4

      Shape:
          1     0
          0     9

      Nondegenerate ellipsoid in R^2.

::

    REPMAT - is analogous to built-in repmat function with one exception - it
             copies the objects, not just the handles

    Example:
      firstEllObj = ellipsoid([1; 2], eye(2));
      secEllObj = ellipsoid([1; 1], 2*eye(2));
      ellVec = [firstEllObj secEllObj];
      repMat(ellVec)

      ans =
      1x2 array of ellipsoids.

::

    RHO - computes the values of the support function for given ellipsoid
          and given direction.

          supArr = RHO(ellArr, dirsMat)  Computes the support function of the
          ellipsoid ellArr in directions specified by the columns of matrix
          dirsMat. Or, if ellArr is array of ellipsoids, dirsMat is expected
          to be a single vector.

          [supArr, bpArr] = RHO(ellArr, dirstMat)  Computes the support function
          of the ellipsoid ellArr in directions specified by the columns of
          matrix dirsMat, and boundary points bpArr of this ellipsoid that
          correspond to directions in dirsMat. Or, if ellArr is array of
          ellipsoids, and dirsMat - single vector, then support functions and
          corresponding boundary points are computed for all the given
          ellipsoids in the array in the specified direction dirsMat.

          The support function is defined as
      (1)  rho(l | E) = sup { <l, x> : x belongs to E }.
          For ellipsoid E(q,Q), where q is its center and Q - shape matrix,
      it is simplified to
      (2)  rho(l | E) = <q, l> + sqrt(<l, Ql>)
      Vector x, at which the maximum at (1) is achieved is defined by
      (3)  q + Ql/sqrt(<l, Ql>)

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
              of ellipsoids.
          dirsMat: double[nDim,nDims1,nDims2,...,nDimsN]/
              double[nDim,nDirs]/[nDim,1] - array or matrix of directions.

    Output:
          supArr: double [nDims1,nDims2,...,nDimsN]/[1,nDirs] - support function
          of the ellArr in directions specified by the columns of matrix
          dirsMat. Or, if ellArr is array of ellipsoids, support function of
          each ellipsoid in ellArr specified by dirsMat direction.

      bpArr: double[nDim,nDims1,nDims2,...,nDimsN]/
              double[nDim,nDirs]/[nDim,1] - array or matrix of boundary points

    Example:
      ellObj = ellipsoid([-2; 4], [4 -1; -1 1]);
      dirsMat = [-2 5; 5 1];
      suppFuncVec = rho(ellObj, dirsMat)

      suppFuncVec =

          31.8102    3.5394

::

    SHAPE - modifies the shape matrix of the ellipsoid without
      changing its center. Modified given array is on output (not its copy).

       modEllArr = SHAPE(ellArr, modMat)  Modifies the shape matrices of
          the ellipsoids in the ellipsoidal array ellArr. The centers
          remain untouched - that is the difference of the function SHAPE and
          linear transformation modMat*ellArr. modMat is expected to be a
          scalar or a square matrix of suitable dimension.

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
              of ellipsoids.
          modMat: double[nDim, nDim]/[1,1] - square matrix or scalar

    Output:
       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of modified
          ellipsoids.

    Example:
      ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
      tempMat = [0 1; -1 0];
      outEllObj = shape(ellObj, tempMat)

      outEllObj =

      Center:
          -2
          -1

      Shape:
          1     1
          1     4

      Nondegenerate ellipsoid in R^2.

::

    TOPOLYTOPE - for ellipsoid ell makes polytope object represanting the
                 boundary of ell

    Input:
      regular:
          ell: ellipsoid[1,1] - ellipsoid in 3D or 2D.
      optional:
          nPoints: double[1,1] - number of boundary points.
                   Actually number of points in resulting
                   polytope will be ecual to lowest
                   number of points of icosaeder, that greater
                   than nPoints.

    Output:
      regular:
          poly: polytope[1,1] - polytop in 3D or 2D.

::

    toStruct -- converts ellipsoid array into structural array.

    Input:
      regular:
          ellArr: ellipsoid [nDim1, nDim2, ...] - array
              of ellipsoids.
    Output:
      SDataArr: struct[nDims1,...,nDimsk] - structure array same size, as
          ellArr, contain all data.
      SFieldNiceNames: struct[1,1] - structure with the same fields as SDataArr. Field values
          contain the nice names.
      SFieldDescr: struct[1,1] - structure with same fields as SDataArr,
          values contain field descriptions.

          q: double[1, nEllDim] - the center of ellipsoid
          Q: double[nEllDim, nEllDim] - the shape matrix of ellipsoid

    Example:
      ellObj = ellipsoid([1 1]', eye(2));
      ellObj.toStruct()

      ans =

      Q: [2x2 double]
      q: [1 1]

::

    TRACE - returns the trace of the ellipsoid.

       trArr = TRACE(ellArr)  Computes the trace of ellipsoids in
          ellipsoidal array ellArr.

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
              of ellipsoids.

    Output:
       trArr: double [nDims1,nDims2,...,nDimsN] - array of trace values,
          same size as ellArr.

    Example:
      firstEllObj = ellipsoid([4 -1; -1 1]);
      secEllObj = ell_unitball(2);
      ellVec = [firstEllObj secEllObj];
      trVec = ellVec.trace()

      trVec =

          5     2

::

    UMINUS - changes the sign of the centerVec of ellipsoid.

    Input:
       regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids.


    Output:
       outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids,
           same size as ellArr.

    Example:
      ellObj = -ellipsoid([-2; -1], [4 -1; -1 1])

      ellObj =

      Center:
           2
           1

      Shape:
           4    -1
          -1     1

      Nondegenerate ellipsoid in R^2.

::

    VOLUME - returns the volume of the ellipsoid.

       volArr = VOLUME(ellArr)  Computes the volume of ellipsoids in
          ellipsoidal array ellArr.

       The volume of ellipsoid E(q, Q) with center q and shape matrix Q
       is given by V = S sqrt(det(Q)) where S is the volume of unit ball.

    Input:
      regular:
          ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
              of ellipsoids.

    Output:
       volArr: double [nDims1,nDims2,...,nDimsN] - array of
          volume values, same size as ellArr.

    Example:
      firstEllObj = ellipsoid([4 -1; -1 1]);
      secEllObj = ell_unitball(2);
      ellVec = [firstEllObj secEllObj]
      volVec = ellVec.volume()

      volVec =

          5.4414     3.1416

hyperplane
----------

::

    CHECKISME - determine whether input object is hyperplane. And display
                message and abort function if input object
                is not hyperplane

    Input:
      regular:
          someObjArr: any[] - any type array of objects.

    Example:
      hypObj = hyperplane([-2, 0]);
      hyperplane.checkIsMe(hypObj)

::

    CONTAINS - checks if given vectors belong to the hyperplanes.

      isPosArr = CONTAINS(myHypArr, xArr) - Checks if vectors specified
          by columns xArr(:, hpDim1, hpDim2, ...) belong
          to hyperplanes in myHypArr.

    Input:
      regular:
          myHypArr: hyperplane [nCols, 1]/[1, nCols]/
              /[hpDim1, hpDim2, ...]/[1, 1] - array of hyperplanes
              of the same dimentions nDims.
          xArr: double[nDims, nCols]/[nDims, hpDim1, hpDim2, ...]/
              /[nDims, 1]/[nDims, nVecArrDim1, nVecArrDim2, ...] - array
              whose columns represent the vectors needed to be checked.

              note: if size of myHypArr is [hpDim1, hpDim2, ...], then
                  size of xArr is [nDims, hpDim1, hpDim2, ...]
                  or [nDims, 1], if size of myHypArr [1, 1], then xArr
                  can be any size [nDims, nVecArrDim1, nVecArrDim2, ...],
                  in this case output variable will has
                  size [1, nVecArrDim1, nVecArrDim2, ...]. If size of
                  xArr is [nDims, nCols], then size of myHypArr may be
                  [nCols, 1] or [1, nCols] or [1, 1], output variable
                  will has size respectively
                  [nCols, 1] or [1, nCols] or [nCols, 1].

    Output:
      isPosArr: logical[hpDim1, hpDim2,...] /
          / logical[1, nVecArrDim1, nVecArrDim2, ...],
          isPosArr(iDim1, iDim2, ...) = true - myHypArr(iDim1, iDim2, ...)
          contains xArr(:, iDim1, iDim2, ...), false - otherwise.

    Example:
      hypObj = hyperplane([-1; 1]);
      tempMat = [100 -1 2; 100 1 2];
      hypObj.contains(tempMat)

      ans =

           1
           0
           1

::

    Hyperplane object of the Ellipsoidal Toolbox.


    Functions:
    ----------
     hyperplane - Constructor of hyperplane object.
     double     - Returns parameters of hyperplane, i.e. normal vector and
                  shift.
     parameters - Same function as 'double' (legacy matter).
     dimension  - Returns dimension of hyperplane.
     isempty    - Checks if hyperplane is empty.
     isparallel - Checks if one hyperplane is parallel to the other one.
     contains   - Check if hyperplane contains given point.


    Overloaded operators and functions:
    -----------------------------------
     eq      - Checks if two hyperplanes are equal.
     ne      - The opposite of 'eq'.
     uminus  - Switches signs of normal and shift parameters to the opposite.
     display - Displays the details about given hyperplane object.
     plot    - Plots hyperplane in 2D and 3D.

::

    DIMENSION - returns dimensions of hyperplanes in the array.

      dimsArr = DIMENSION(hypArr) - returns dimensions of hyperplanes
          described by hyperplane structures in the array hypArr.

    Input:
      regular:
          hypArr: hyperplane [nDims1, nDims2, ...] - array
              of hyperplanes.

    Output:
          dimsArr: double[nDims1, nDims2, ...] - dimensions
              of hyperplanes.

    Example:
      firstHypObj = hyperplane([-1; 1]);
      secHypObj = hyperplane([-1; 1; 8; -2; 3], 7);
      thirdHypObj = hyperplane([1; 2; 0], -1);
      hypVec = [firstHypObj secHypObj thirdHypObj];
      dimsVec  = hypVec.dimension()

      dimsVec =

         2     5     3

::

    DISPLAY - Displays hyperplane object.

    Input:
      regular:
          myHypArr: hyperplane [hpDim1, hpDim2, ...] - array
              of hyperplanes.

    Example:
      hypObj = hyperplane([-1; 1]);
      display(hypObj)

      hypObj =
      size: [1 1]

      Element: [1 1]
      Normal:
          -1
           1

      Shift:
           0

      Hyperplane in R^2.

::

    DOUBLE - return parameters of hyperplane - normal vector and shift.

      [normVec, hypScal] = DOUBLE(myHyp) - returns normal vector
          and scalar value of the hyperplane.

    Input:
      regular:
          myHyp: hyperplane [1, 1] - single hyperplane of dimention nDims.

    Output:
      normVec: double[nDims, 1] - normal vector of the hyperplane myHyp.
      hypScal: double[1, 1] - scalar of the hyperplane myHyp.

    Example:
      hypObj = hyperplane([-1; 1]);
      [normVec, hypScal] = double(hypObj)

      normVec =

          -1
           1

      hypScal =

           0

::

    FROMREPMAT - returns array of equal hyperplanes the same
                 size as stated in sizeVec argument

      hpArr = fromRepMat(sizeVec) - creates an array  size
               sizeVec of empty hyperplanes.

      hpArr = fromRepMat(normalVec,sizeVec) - creates an array
               size sizeVec of hyperplanes with normal
               normalVec.

      hpArr = fromRepMat(normalVec,shift,sizeVec) - creates an
               array size sizeVec of hyperplanes with normal normalVec
               and hyperplane shift shift.

    Input:
      Case1:
          regular:
              sizeVec: double[1,n] - vector of size, have
              integer values.

      Case2:
          regular:
              normalVec: double[nDim, 1] - normal of
              hyperplanes.
              sizeVec: double[1, n] - vector of size, have
              integer values.

      Case3:
          regular:
              normalVec: double[nDim, 1] - normal of
              hyperplanes.
              shift: double[1, 1] - shift of hyperplane.
              sizeVec: double[1,n] - vector of size, have
              integer values.

      properties:
          absTol: double [1,1] - absolute tolerance with default
              value 10^(-7)

::

    fromStruct -- converts structural array into hyperplanes array.

    Input:
      regular:
      SHpArr: struct [hpDim1, hpDim2, ...] -  structural array with following fields:

           normal: double[nHpDim, 1] - the normal of hyperplane
           shift: double[1, 1] - the shift of hyperplane

    Output:
      hpArr : hyperplane [nDim1, nDim2, ...] - hyperplane array with size of
          SHpArr.


    Example:
      hpObj = hyperplane([1 1]', 1);
      hpObj.toStruct()

      ans =

      normal: [2x1 double]
      shift: 0.7071

::

    GETABSTOL - gives the array of absTol for all elements in hplaneArr

    Input:
      regular:
          ellArr: hyperplane[nDim1, nDim2, ...] - multidimension array
              of hyperplane
      optional
          fAbsTolFun: function_handle[1,1] - function that apply
              to the absTolArr. The default is @min.

    Output:
      regular:
          absTolArr: double [absTol1, absTol2, ...] - return absTol for
              each element in hplaneArr
      optional:
          absTol: double[1, 1] - return result of work fAbsTolFun with
              the absTolArr

    Usage:
      use [~,absTol] = hplaneArr.getAbsTol() if you want get only
          absTol,
      use [absTolArr,absTol] = hplaneArr.getAbsTol() if you want get
          absTolArr and absTol,
      use absTolArr = hplaneArr.getAbsTol() if you want get only absTolArr

    Example:
      firstHypObj = hyperplane([-1; 1]);
      secHypObj = hyperplane([-2; 5]);
      hypVec = [firstHypObj secHypObj];
      hypVec.getAbsTol()

      ans =

         1.0e-07 *

          1.0000    1.0000

::

    GETCOPY - gives array the same size as hpArr with copies of elements of
              hpArr.

    Input:
      regular:
          hpArr: hyperplane[nDim1, nDim2,...] - multidimensional array of
              hyperplanes.

    Output:
      copyHpArr: hyperplane[nDim1, nDim2,...] - multidimension array of
          copies of elements of hpArr.

    Example:
      firstHpObj = hyperplane([-1; 1], [2 0; 0 3]);
      secHpObj = hyperplane([1; 2], eye(2));
      hpVec = [firstHpObj secHpObj];
      copyHpVec = getCopy(hpVec)

      copyHpVec =
      1x2 array of hyperplanes.

::

    GETPROPERTY - gives array the same size as hpArr with values of
                  propName properties for each hyperplane in hpArr.
                  Private method, used in every public property getter.

    Input:
      regular:
          hpArr: hyperplane[nDim1, nDim2,...] - mltidimensional array
              of hyperplanes
          propName: char[1,N] - name property
      optional:
          fPropFun: function_handle[1,1] - function that apply
              to the propArr. The default is @min.

    Output:
      regular:
          propArr: double[nDim1, nDim2,...] - multidimension array of
              propName properties for hyperplanes in rsArr
      optional:
          propVal: double[1, 1] - return result of work fPropFun with
              the propArr

::

    GETRELTOL - gives the array of relTol for all elements in hpArr

    Input:
      regular:
          hpArr: hyperplane[nDim1, nDim2, ...] - multidimension array
              of hyperplanes
      optional:
          fRelTolFun: function_handle[1,1] - function that apply
              to the relTolArr. The default is @min.
    Output:
      regular:
          relTolArr: double [relTol1, relTol2, ...] - return relTol for
              each element in hpArr
      optional:
          relTol: double[1,1] - return result of work fRelTolFun with
              the relTolArr

    Usage:
      use [~,relTol] = hpArr.getRelTol() if you want get only
          relTol,
      use [relTolArr,relTol] = hpArr.getRelTol() if you want get
          relTolArr and relTol,
      use relTolArr = hpArr.getRelTol() if you want get only relTolArr

    Example:
      firsthpObj = hyperplane([-1; 1], 1);
      sechpObj = hyperplane([1 ;2], 2);
      hpVec = [firsthpObj sechpObj];
      hpVec.getRelTol()

      ans =

         1.0e-05 *

          1.0000    1.0000

::

    HYPERPLANE - creates hyperplane structure
                 (or array of hyperplane structures).

      Hyperplane H = { x in R^n : <v, x> = c },
      with current "Properties"..
      Here v must be vector in R^n, and c - scalar.

      hypH = HYPERPLANE - create empty hyperplane.

      hypH = HYPERPLANE(hypNormVec) - create
          hyperplane object hypH with properties:
              hypH.normal = hypNormVec,
              hypH.shift = 0.

      hypH = HYPERPLANE(hypNormVec, hypConst) - create
          hyperplane object hypH with properties:
              hypH.normal = hypNormVec,
              hypH.shift = hypConst.

      hypH = HYPERPLANE(hypNormVec, hypConst, ...
          'absTol', absTolVal) - create
          hyperplane object hypH with properties:
              hypH.normal = hypNormVec,
              hypH.shift = hypConst.
              hypH.absTol = absTolVal

      hypObjArr = HYPERPLANE(hypNormArr, hypConstArr) - create
          array of hyperplanes object just as
          hyperplane(hypNormVec, hypConst).

      hypObjArr = HYPERPLANE(hypNormArr, hypConstArr, ...
          'absTol', absTolValArr) - create
          array of hyperplanes object just as
          hyperplane(hypNormVec, hypConst, 'absTol', absTolVal).

    Input:
      Case1:
        regular:
          hypNormArr: double[hpDims, nDims1, nDims2,...] -
              array of vectors in R^hpDims. There hpDims -
              hyperplane dimension.

      Case2:
        regular:
          hypNormArr: double[hpDims, nCols] /
              / [hpDims, nDims1, nDims2,...] /
              / [hpDims, 1] - array of vectors
              in R^hpDims. There hpDims - hyperplane dimension.
          hypConstArr: double[1, nCols] / [nCols, 1] /
              / [nDims1, nDims2,...] /
              / [nVecArrDim1, nVecArrDim2,...] -
              array of scalar.

      Case3:
        regular:
          hypNormArr: double[hpDims, nCols] /
              / [hpDims, nDims1, nDims2,...] /
              / [hpDims, 1] - array of vectors
              in R^hpDims. There hpDims - hyperplane dimension.
          hypConstArr: double[1, nCols] / [nCols, 1] /
              / [nDims1, nDims2,...] /
              / [nVecArrDim1, nVecArrDim2,...] -
              array of scalar.
          absTolValArr: double[1, 1] - value of
              absTol propeties.

        properties:
          propMode: char[1,] - property mode, the following
              modes are supported:
              'absTol' - name of absTol properties.

              note: if size of hypNormArr is
                  [hpDims, nDims1, nDims2,...], then size of
                  hypConstArr is [nDims1, nDims2, ...] or
                  [1, 1], if size of hypNormArr [hpDims, 1],
                  then hypConstArr can be any size
                  [nVecArrDim1, nVecArrDim2, ...],
                  in this case output variable will has
                  size [nVecArrDim1, nVecArrDim2, ...].
                  If size of hypNormArr is [hpDims, nCols],
                  then size of hypConstArr may be
                  [1, nCols] or [nCols, 1],
                  output variable will has size
                  respectively [1, nCols] or [nCols, 1].

    Output:
      hypObjArr: hyperplane [nDims1, nDims2...] /
          / hyperplane [nVecArrDim1, nVecArrDim2, ...] -
          array of hyperplane structure hypH:
              hypH.normal - vector in R^hpDims,
              hypH.shift  - scalar.

    Example:
      hypNormMat = [1 1 1; 1 1 1];
      hypConstVec = [1 -5 0];
      hypObj = hyperplane(hypNormMat, hypConstVec);

::

    ISEMPTY - checks if hyperplanes in H are empty.

    Input:
      regular:
          myHypArr: hyperplane [nDims1, nDims2, ...] - array
              of hyperplanes.

    Output:
      isPositiveArr: logical[nDims1, nDims2, ...],
          isPositiveArr(iDim1, iDim2, ...) = true - if ellipsoid
          myHypArr(iDim1, iDim2, ...) is empty, false - otherwise.

    Example:
      hypObj = hyperplane();
      isempty(hypObj)

      ans =

           1

::

    ISEQUAL - produces logical array the same size as
              ellFirstArr/ellFirstArr (if they have the same).
              isEqualArr[iDim1, iDim2,...] is true if corresponding
              ellipsoids are equal and false otherwise.

    Input:
      regular:
          ellFirstArr: ellipsoid[nDim1, nDim2,...] - multidimensional array
              of ellipsoids.
          ellSecArr: ellipsoid[nDim1, nDim2,...] - multidimensional array
              of ellipsoids.
      properties:
          'isPropIncluded': makes to compare second value properties, such as
          absTol etc.
    Output:
      isEqualArr: logical[nDim1, nDim2,...] - multidimension array of
          logical values. isEqualArr[iDim1, iDim2,...] is true if
          corresponding ellipsoids are equal and false otherwise.

      reportStr: char[1,] - comparison report.

::

    ISPARALLEL - check if two hyperplanes are parallel.

      isResArr = ISPARALLEL(fstHypArr, secHypArr) - Checks if hyperplanes
          in fstHypArr are parallel to hyperplanes in secHypArr and
          returns array of true and false of the size corresponding
          to the sizes of fstHypArr and secHypArr.

    Input:
      regular:
          fstHypArr: hyperplane [nDims1, nDims2, ...] - first array
              of hyperplanes
          secHypArr: hyperplane [nDims1, nDims2, ...] - second array
              of hyperplanes

    Output:
      isPosArr: logical[nDims1, nDims2, ...] -
          isPosArr(iFstDim, iSecDim, ...) = true -
          if fstHypArr(iFstDim, iSecDim, ...) is parallel
          secHypArr(iFstDim, iSecDim, ...), false - otherwise.

    Example:
      hypObj = hyperplane([-1 1 1; 1 1 1; 1 1 1], [2 1 0]);
      hypObj.isparallel(hypObj(2))

      ans =

           0     1     1

::

    PARAMETERS - return parameters of hyperplane - normal vector and shift.

      [normVec, hypScal] = PARAMETERS(myHyp) - returns normal vector
          and scalar value of the hyperplane.

    Input:
      regular:
          myHyp: hyperplane [1, 1] - single hyperplane of dimention nDims.

    Output:
      normVec: double[nDims, 1] - normal vector of the hyperplane myHyp.
      hypScal: double[1, 1] - scalar of the hyperplane myHyp.

    Example:
      hypObj = hyperplane([-1; 1]);
      [normVec, hypScal] = parameters(hypObj)

      normVec =

          -1
           1


      hypScal =

           0

::

    PLOT - plots hyperplaces in 2D or 3D.


    Usage:
          plot(hyp) - plots hyperplace hyp in default (red) color.
          plot(hypArr) - plots an array of hyperplaces.
          plot(hypArr, 'Property',PropValue,...) - plots hypArr with setting
                                                   properties.

    Input:
      regular:
          hypArr:  Hyperplace: [dim11Size,dim12Size,...,dim1kSize] -
                   array of 2D or 3D hyperplace objects. All hyperplaces in hypArr
                   must be either 2D or 3D simutaneously.
      optional:
          color1Spec: char[1,1] - color specification code, can be 'r','g',
                                  etc (any code supported by built-in Matlab function).
          hyp2Arr: Hyperplane: [dim21Size,dim22Size,...,dim2kSize] -
                                              second Hyperplane array...
          color2Spec: char[1,1] - same as color1Spec but for hyp2Arr
          ....
          hypNArr: Hyperplane: [dimN1Size,dim22Size,...,dimNkSize] -
                                               N-th Hyperplane array
          colorNSpec - same as color1Spec but for hypNArr.
      properties:
          'newFigure': logical[1,1] - if 1, each plot command will open a new figure window.
                       Default value is 0.
          'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
                  if 1, ellipsoids in 2D will be filled with color. Default value is 0.
          'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                       line width for 1D and 2D plots. Default value is 1.
          'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
                   sets default colors in the form [x y z]. Default value is [1 0 0].
          'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                   level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
                   Default value is 0.4.
          'size': double[1,1] - length of the line segment in 2D, or square diagonal in 3D.
          'center': double[1,dimHyp] - center of the line segment in 2D, of the square in 3D
          'relDataPlotter' - relation data plotter object.
          Notice that property vector could have different dimensions, only
          total number of elements must be the same.
    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

::

    toStruct -- converts hyperplanes array into structural array.

    Input:
      regular:
          hpArr: hyperplane [hpDim1, hpDim2, ...] - array
              of hyperplanes.

    Output:
      ShpArr : struct[nDim1, nDim2, ...] - structural array with size of
          hpArr with the following fields:

          normal: double[nHpDim, 1] - the normal of hyperplane
          shift: double[1, 1] - the shift of hyperplane

::

    UMINUS - switch signs of normal vector and the shift scalar
             to the opposite.

    Input:
      regular:
          inpHypArr: hyperplane [nDims1, nDims2, ...] - array
              of hyperplanes.

    Output:
      outHypArr: hyperplane [nDims1, nDims2, ...] - array
          of the same hyperplanes as in inpHypArr whose
          normals and scalars are multiplied by -1.

    Example:
      hypObj = -hyperplane([-1; 1], 1)

      hypObj =
      size: [1 1]

      Element: [1 1]
      Normal:
           1
          -1

      Shift:
          -1

      Hyperplane in R^2.

elltool.conf.Properties
-----------------------

::

    PROPERTIES - a static class, providing emulation of static properties for
                 toolbox.

::

    Example:
      elltool.conf.Properties.checkSettings()

::

    Example:
      elltool.conf.Properties.getAbsTol();

::

    Example:
      elltool.conf.Properties.getConfRepoMgr()

      ans =

        elltool.conf.ConfRepoMgr handle
        Package: elltool.conf

        Properties:
          DEFAULT_STORAGE_BRANCH_KEY: '_default'

::

    Example:
      elltool.conf.Properties.getIsEnabledOdeSolverOptions();

::

    Example:
      elltool.conf.Properties.getIsODENormControl();

::

    Example:
      elltool.conf.Properties.getIsVerbose();

::

    Example:
      elltool.conf.Properties.getNPlot2dPoints();

::

    Example:
      elltool.conf.Properties.getNPlot3dPoints();

::

    Example:
      elltool.conf.Properties.getNTimeGridPoints();

::

    Example:
      elltool.conf.Properties.getODESolverName();

::

    Example:
      elltool.conf.Properties.getConfRepoMgr.getCurConf()

      ans =

                        version: '1.4dev'
                      isVerbose: 0
                         absTol: 1.0000e-07
                         relTol: 1.0000e-05
                nTimeGridPoints: 200
                  ODESolverName: 'ode45'
               isODENormControl: 'on'
      isEnabledOdeSolverOptions: 0
                  nPlot2dPoints: 200
                  nPlot3dPoints: 200
                        logging: [1x1 struct]

::

::

::

    Example:
      elltool.conf.Properties.getVersion();

::

    Example:
      elltool.conf.Properties.init()

::

    PARSEPROP - parses input into cell array with values of properties listed
               in neededPropNameList.
               Values are  taken from args or, if there no value for some
               property in args, in current Properties.


    Input:
      regular:
          args: cell[1,] of any[] - cell array of arguments that
              should be parsed.
      optional
          neededPropNameList: cell[1,nProp] of char[1,] - cell array of strings
              containing names of parameters, that output should consist of.
              The following properties are supported:
                  version
                  isVerbose
                  absTol
                  relTol
                  regTol
                  ODESolverName
                  isODENormControl
                  isEnabledOdeSolverOptions
                  nPlot2dPoints
                  nPlot3dPoints
                  nTimeGridPoints
              trying to specify other properties would be result in error
              If neededPropNameList is not specified, the list of all
              supported properties is assumed.

    Output:
      propVal1:  - value of the first property specified
                                 in neededPropNameList in the same order as
                                 they listed in neededPropNameList
          ....
      propValN:  - value of the last property from neededPropNameList
      restList: cell[1,nRest] - list of the input arguments that were not
          recognized as properties

    Example:
        testAbsTol = 1;
        testRelTol = 2;
        nPlot2dPoints = 3;
        someArg = 4;
        args = {'absTol',testAbsTol, 'relTol',testRelTol,'nPlot2dPoints',...
            nPlot2dPoints, 'someOtherArg', someArg};
        neededPropList = {'absTol','relTol'};
        [absTol, relTol,resList]=elltool.conf.Properties.parseProp(args,...
            neededPropList)

        absTol =

             1


        relTol =

             2


        resList =

            'nPlot2dPoints'    [3]    'someOtherArg'    [4]

::

    Example:
      prevConfRepo = Properties.getConfRepoMgr();
      prevAbsTol = prevConfRepo.getParam('absTol');
      elltool.conf.Properties.setConfRepoMgr(prevConfRepo);

::

    Example:
      elltool.conf.Properties.setIsVerbose(true);

::

    Example:
      elltool.conf.Properties.setNPlot2dPoints(300);

::

    Example:
      elltool.conf.Properties.setNTimeGridPoints(300);

::

    SETRELTOL - set global relative tolerance

    Input
    relTol: double[1,1]

elltool.core.GenEllipsoid
-------------------------

::

    GENELLIPSOID - class of generalized ellipsoids

    Input:
      Case1:
        regular:
          qVec: double[nDim,1] - ellipsoid center
          qMat: double[nDim,nDim] / qVec: double[nDim,1] - ellipsoid matrix
              or diagonal vector of eigenvalues, that may contain infinite
              or zero elements

      Case2:
        regular:
          qMat: double[nDim,nDim] / qVec: double[nDim,1] - diagonal matrix or
              vector, may contain infinite or zero elements

      Case3:
        regular:
          qVec: double[nDim,1] - ellipsoid center
          dMat: double[nDim,nDim] / dVec: double[nDim,1] - diagonal matrix or
              vector, may contain infinite or zero elements
          wMat: double[nDim,nDim] - any square matrix


    Output:
      self: GenEllipsoid[1,1] - created generalized ellipsoid

    Example:
      ellObj = elltool.core.GenEllipsoid([5;2], eye(2));
      ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);

::

    Example:
      firstEllObj = elltool.core.GenEllipsoid([1; 1], eye(2));
      secEllObj = elltool.core.GenEllipsoid([0; 5], 2*eye(2));
      ellVec = [firstEllObj secEllObj];
      ellVec.dimension()

      ans =

           2     2

::

    Example:
      ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
      ellObj.display()
         |
         |----- q : [5 2]
         |          -------
         |----- Q : |10|19|
         |          |19|41|
         |          -------
         |          -----
         |-- QInf : |0|0|
         |          |0|0|
         |          -----

::

    Example:
      ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
      ellObj.getCenter()

      ans =

           5
           2

::

    Example:
      ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
      ellObj.getCheckTol()

      ans =

         1.0000e-09

::

    Example:
      ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
      ellObj.getDiagMat()

      ans =

          0.9796         0
               0   50.0204

::

    Example:
      ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
      ellObj.getEigvMat()

      ans =

          0.9034   -0.4289
         -0.4289   -0.9034

::

    Example:
      firstEllObj = elltool.core.GenEllipsoid([10;0], 2*eye(2));
      secEllObj = elltool.core.GenEllipsoid([0;0], [1 0; 0 0.1]);
      curDirMat = [1; 0];
      isOk=getIsGoodDir(firstEllObj,secEllObj,dirsMat)

      isOk =

           1

::

    INV - create generalized ellipsoid whose matrix in pseudoinverse
          to the matrix of input generalized ellipsoid

    Input:
      regular:
          ellObj: GenEllipsoid: [1,1] - generalized ellipsoid

    Output:
      ellInvObj: GenEllipsoid: [1,1] - inverse generalized ellipsoid

    Example:
      ellObj = elltool.core.GenEllipsoid([5;2], [1 0; 0 0.7]);
      ellObj.inv()
         |
         |----- q : [5 2]
         |          -----------------
         |----- Q : |1      |0      |
         |          |0      |1.42857|
         |          -----------------
         |          -----
         |-- QInf : |0|0|
         |          |0|0|
         |          -----

::

    MINKDIFFEA - computes tight external ellipsoidal approximation for
                 Minkowsky difference of two generalized ellipsoids

    Input:
      regular:
          ellObj1: GenEllipsoid: [1,1] - first generalized ellipsoid
          ellObj2: GenEllipsoid: [1,1] - second generalized ellipsoid
          dirMat: double[nDim,nDir] - matrix whose columns specify
              directions for which approximations should be computed
    Output:
      resEllVec: GenEllipsoid[1,nDir] - vector of generalized ellipsoids of
          external approximation of the dirrence of first and second
          generalized ellipsoids (may contain empty ellipsoids if in specified
          directions approximation cannot be computed)

    Example:
      firstEllObj = elltool.core.GenEllipsoid([10;0], 2*eye(2));
      secEllObj = elltool.core.GenEllipsoid([0;0], [1 0; 0 0.1]);
      dirsMat = [1,0].';
      resEllVec  = minkDiffEa( firstEllObj, secEllObj, dirsMat)
         |
         |----- q : [10 0]
         |          -------------------
         |----- Q : |0.171573|0       |
         |          |0       |1.20557 |
         |          -------------------
         |          -----
         |-- QInf : |0|0|
         |          |0|0|
         |          -----

::

    MINKDIFFIA - computes tight internal ellipsoidal approximation for
                 Minkowsky difference of two generalized ellipsoids

    Input:
      regular:
          ellObj1: GenEllipsoid: [1,1] - first generalized ellipsoid
          ellObj2: GenEllipsoid: [1,1] - second generalized ellipsoid
          dirMat: double[nDim,nDir] - matrix whose columns specify
              directions for which approximations should be computed
    Output:
      resEllVec: GenEllipsoid[1,nDir] - vector of generalized ellipsoids of
          internal approximation of the dirrence of first and second
          generalized ellipsoids

    Example:
      firstEllObj = elltool.core.GenEllipsoid([10;0], 2*eye(2));
      secEllObj = elltool.core.GenEllipsoid([0;0], [1 0; 0 0.1]);
      dirsMat = [1,0].';
      resEllVec  = minkDiffIa( firstEllObj, secEllObj, dirsMat)
         |
         |----- q : [10 0]
         |          -------------------
         |----- Q : |0.171573|0       |
         |          |0       |0.544365|
         |          -------------------
         |          -----
         |-- QInf : |0|0|
         |          |0|0|
         |          -----

::

    MINKSUMEA - computes tight external ellipsoidal approximation for
                Minkowsky sum of the set of generalized ellipsoids

    Input:
      regular:
          ellObjVec: GenEllipsoid: [kSize,mSize] - vector of  generalized
                                              ellipsoid
          dirMat: double[nDim,nDir] - matrix whose columns specify
              directions for which approximations should be computed
    Output:
      ellResVec: GenEllipsoid[1,nDir] - vector of generalized ellipsoids of
          external approximation of the dirrence of first and second
          generalized ellipsoids

    Example:
      firstEllObj = elltool.core.GenEllipsoid([1;1],eye(2));
      secEllObj = elltool.core.GenEllipsoid([5;0],[3 0; 0 2]);
      ellVec = [firstEllObj secEllObj];
      dirsMat = [1 3; 2 4];
      ellResVec  = minkSumEa(ellVec, dirsMat )

      Structure(1)
         |
         |----- q : [6 1]
         |          -----------------
         |----- Q : |7.50584|0      |
         |          |0      |5.83164|
         |          -----------------
         |          -----
         |-- QInf : |0|0|
         |          |0|0|
         |          -----
         O

      Structure(2)
         |
         |----- q : [6 1]
         |          -----------------
         |----- Q : |7.48906|0      |
         |          |0      |5.83812|
         |          -----------------
         |          -----
         |-- QInf : |0|0|
         |          |0|0|
         |          -----
         O

::

    MINKSUMIA - computes tight internal ellipsoidal approximation for
                Minkowsky sum of the set of generalized ellipsoids

    Input:
      regular:
          ellObjVec: GenEllipsoid: [kSize,mSize] - vector of  generalized
                                              ellipsoid
          dirMat: double[nDim,nDir] - matrix whose columns specify
              directions for which approximations should be computed
    Output:
      ellResVec: GenEllipsoid[1,nDir] - vector of generalized ellipsoids of
          internal approximation of the dirrence of first and second
          generalized ellipsoids

    Example:
      firstEllObj = elltool.core.GenEllipsoid([1;1],eye(2));
      secEllObj = elltool.core.GenEllipsoid([5;0],[3 0; 0 2]);
      ellVec = [firstEllObj secEllObj];
      dirsMat = [1 3; 2 4];
      ellResVec  = minkSumIa(ellVec, dirsMat )

      Structure(1)
         |
         |----- q : [6 1]
         |          ---------------------
         |----- Q : |7.45135  |0.0272432|
         |          |0.0272432|5.81802  |
         |          ---------------------
         |          -----
         |-- QInf : |0|0|
         |          |0|0|
         |          -----
         O

      Structure(2)
         |
         |----- q : [6 1]
         |          ---------------------
         |----- Q : |7.44698  |0.0315642|
         |          |0.0315642|5.81445  |
         |          ---------------------
         |          -----
         |-- QInf : |0|0|
         |          |0|0|
         |          -----
         O

::

    PLOT - plots ellipsoids in 2D or 3D.


    Usage:
          plot(ell) - plots generic ellipsoid ell in default (red) color.
          plot(ellArr) - plots an array of generic ellipsoids.
          plot(ellArr, 'Property',PropValue,...) - plots ellArr with setting
                                                   properties.

    Input:
      regular:
          ellArr:  elltool.core.GenEllipsoid: [dim11Size,dim12Size,...,
                   dim1kSize] - array of 2D or 3D GenEllipsoids objects.
                   All ellipsoids in ellArr  must be either 2D or 3D
                   simutaneously.
      optional:
          color1Spec: char[1,1] - color specification code, can be 'r','g',
                                  etc (any code supported by built-in Matlab
                                  function).
          ell2Arr: elltool.core.GenEllipsoid: [dim21Size,dim22Size,...,
                                  dim2kSize] - second ellipsoid array...
          color2Spec: char[1,1] - same as color1Spec but for ell2Arr
          ....
          ellNArr: elltool.core.GenEllipsoid: [dimN1Size,dim22Size,...,
                                   dimNkSize] - N-th ellipsoid array
          colorNSpec - same as color1Spec but for ellNArr.
      properties:
          'newFigure': logical[1,1] - if 1, each plot command will open a new .
                       figure window Default value is 0.
          'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
                  if 1, ellipsoids in 2D will be filled with color.
                  Default value is 0.
          'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                   line width for 1D and 2D plots.
                   Default value is 1.
          'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
                   sets default colors in the form [x y z].
                   Default value is [1 0 0].
          'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
                   level of transparency between 0 and 1 (0 - transparent,
                   1 - opaque).
                   Default value is 0.4.
          'relDataPlotter' - relation data plotter object.
          Notice that property vector could have different dimensions, only
          total number of elements must be the same.
    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

    Examples:
      plot([ell1, ell2, ell3], 'color', [1, 0, 1; 0, 0, 1; 1, 0, 0]);
      plot([ell1, ell2, ell3], 'color', [1; 0; 1; 0; 0; 1; 1; 0; 0]);
      plot([ell1, ell2, ell3; ell1, ell2, ell3], 'shade', [1, 1, 1; 1, 1,
        1]);
      plot([ell1, ell2, ell3; ell1, ell2, ell3], 'shade', [1; 1; 1; 1; 1;
          1]);
      plot([ell1, ell2, ell3], 'shade', 0.5);
      plot([ell1, ell2, ell3], 'lineWidth', 1.5);
      plot([ell1, ell2, ell3], 'lineWidth', [1.5, 0.5, 3]);

::

    Example:
      ellObj = elltool.core.GenEllipsoid([1;1],eye(2));
      dirsVec = [1; 0];
      [resRho, bndPVec] = rho(ellObj, dirsVec)

      resRho =

           2

     bndPVec =

           2
           1

smartdb.relations.ATypifiedStaticRelation
-----------------------------------------

::

    ATYPIFIEDSTATICRELATION is a constructor of static relation class
    object

    Usage: self=AStaticRelation(obj) or
           self=AStaticRelation(varargin)

    Input:
      optional
        inpObj: ARelation[1,1]/SData: struct[1,1]
            structure with values of all fields
            for all tuples

        SIsNull: struct [1,1] - structure of fields with is-null
           information for the field content, it can be logical for
           plain real numbers of cell of logicals for cell strs or
           cell of cell of str for more complex types

        SIsValueNull: struct [1,1] - structure with logicals
            determining whether value corresponding to each field
            and each tuple is null or not

      properties:
          fillMissingFieldsWithNulls: logical[1,1] - if true,
              the relation fields absent in the input data
              structures are filled with null values

    Output:
      regular:
        self: ATYPIFIEDSTATICRELATION [1,1] - constructed class object

    Note: In the case the first interface is used, SData and
          SIsNull are taken from class object obj

::

    ADDDATA - adds a set of field values to existing data in a form of new
              tuples

    Input:
      regular:
         self:ARelation [1,1] - class object

::

    ADDDATAALONGDIM - adds a set of field values to existing data using
                      a concatenation along a specified dimension

    Input:
      regular:
          self: CubeStruct [1,1] - the object

::

    ADDTUPLES - adds a set of new tuples to the relation

    Usage: addTuplesInternal(self,varargin)

    input:
      regular:
          self: ARelation [1,1] - class object
          SData: struct [1,1] - structure with values of all fields  for all
           tuples
      optional:
          SIsNull: struct [1,1] - structure of fields with is-null
            information for the field content, it can be logical for plain
            real numbers of cell of logicals for cell strs or cell of cell of
            str for more complex types

          SIsValueNull: struct [1,1] - structure with logicals determining
            whether value corresponding to each field and each tuple is null
            or not

      properties:
          checkConsistency: logical[1,1], if true, a consistency between the
             input structures is not checked, true by default

::

    APPLYGETFUNC - applies a function to the specified fields as columns, i.e.
                   the function is applied to each field as whole, not to
                   each cell separately

    Input:
      regular:
          hFunc: function_handle[1,1] - function to apply to each of the
             field values
      optional:
          toFieldNameList: char/cell[1,] of char - a list of fields to which
             the function specified by hFunc is to be applied

        Note: hFunc can optionally be specified after toFieldNameList
              parameter

    Notes: this function currently has a lots of limitations:
      1) it assumes that the output is uniform
      2) the function is applies to SData part of field value
      3) no additional arguments can be passed
      All this limitations will eventually go away though so stay tuned...

::

    APPLYSETFUNC - applies some function to each cell of the specified fields
                   of a given CubeStruct object

    Usage: applySetFunc(self,toFieldNameList,hFunc)
           applySetFunc(self,hFunc,toFieldNameList)

    Input:
      regular:
          self: CubeStruct [1,1] - class object

          hFunc: function handle [1,1] - handle of function to be
            applied to fields, the function is assumed to
              1) have the same number of input/output arguments
              2) the number of input arguments should be
                 length(structNameList)*length(fieldNameList)
              3) the input arguments should be ordered according to the
              following rule
                  (x_struct_1_field_1,x_struct_1_field_2,...,struct_n_field1,
                  ...,struct_n_field_m)

      optional:

          toFieldNameList: char or char cell [1,nFields] - list of
            field names to which given function should be applied

            Note1: field lists of length>1 are not currently supported !
            Note2: it is possible to specify toFieldNameList before hFunc in
               which case the parameters will be recognized automatically

      properties:
          uniformOutput: logical[1,1] - specifies if the result
             of the function is uniform to be stored in non-cell
             field, by default it is false for cell fileds and
             true for non-cell fields

          structNameList: char[1,]/cell[1,], name of data structure/list of
            data structure names to which the function is to
                 be applied, can be composed from the following values

               SData - data itself

               SIsNull - contains is-null indicator information for data
                 values

               SIsValueNull - contains is-null indicators for CubeStruct
                  cells (not for cell values)

            structNameList={'SData'} by default

          inferIsNull: logical[1,2] - if the first(second) element is true,
              SIsNull(SIsValueNull) indicators are inferred from SData,
              i.e. with this indicator set to true it is sufficient to apply
              the function only to SData while the rest of the structures
              will be adjusted automatically.

          inputType: char[1,] - specifies a way in which the field value is
             partitioned into individual cells before being passed as an
             input parameter to hFunc. This parameter directly corresponds to
             outputType parameter of toArray method, see its documentation
             for a list of supported input types.

::

    APPLYTUPLEGETFUNC - applies a function to the specified fields
                        separately to each tuple

    Input:
      regular:
          hFunc: function_handle[1,1] - function to apply to the specified
             fields
      optional:
          toFieldNameList: char/cell[1,] of char - a list of fields to which
             the function specified by hFunc is to be applied

      properties:
          uniformOutput: logical[1,1] - if true, output is expected to be
              uniform as in cellfun with 'UniformOutput'=true, default
               value is true

    Output:
      funcOut1Arr: <type1>[] - array corresponding to the first output of the
          applied function
              ....
      funcOutNArr: <typeN>[] - array corresponding to the last output of the
          applied function


    Notes: this function currently has a lots of limitations:
      1) the function is applies to SData part of field value
      2) no additional arguments can be passed
      All this limitations will eventually go away though so stay tuned...

::

    CLEARDATA - deletes all the data from the object

    Usage: self.clearData(self)

    Input:
      regular:
        self: CubeStruct [1,1] - class object

::

    CLONE - creates a copy of a specified object via calling
            a copy constructor for the object class

    Input:
      regular:
        self: any [] - current object
      optional
        any parameters applicable for relation constructor

    Ouput:
      self: any [] - constructed object

::

    COPYFROM - reconstruct CubeStruct object within a current object using the
               input CubeStruct object as a prototype

    Input:
      regular:
        self: CubeStruct [n_1,...,n_k]
        obj: any [] - internal representation of the object

      optional:
        fieldNameList: cell[1,nFields] - list of fields to copy

::

    CREATEINSTANCE - returns an object of the same class by calling a default
                     constructor (with no parameters)

    Usage: resObj=getInstance(self)

    input:
      regular:
        self: any [] - current object
      optional
        any parameters applicable for relation constructor

    Ouput:
      self: any [] - constructed object

::

    DISPONUI - displays a content of the given relation as a data grid UI
               component.

    Input:
      regular:
          self:
      properties:
          tableType: char[1,] - type of table used for displaying the data,
              the following types are supported:
              'sciJavaGrid' - proprietary Java-based data grid component
                  is used
              'uitable'  - Matlab built-in uitable component is used.
                  if not specified, the method tries to use sciJavaGrid
                  if it is available, if not - uitable is used.

    Output:
      hFigure: double[1,1] - figure handle containing the component
      gridObj: smartdb.relations.disp.UIDataGrid[1,1] - data grid component
          instance used for displaying a content of the relation object

::

    DISPLAY - puts some textual information about CubeStruct object in screen

    Input:
     regular:
         self.

::

    FROMSTRUCTLIST - creates a dynamic relation from a list of structures
                     interpreting each structure as the data for
                     several tuples.

    Input:
      regular:
          className: name of object class which will be created,
              the class constructor should accept 2 properties:
              'fieldNameList' and 'fieldTypeSpecList'

          structList: cell[] of struct[1,1] - list of structures

    Output:
      relDataObj: smartdb.relations.DynamicRelation[1,1] -
         constructed relation

::

    GETCOPY - returns an object copy

    Usage: resObj=getCopy(self)

    Input:
      regular:
        self: CubeStruct [1,1] - current CubeStruct object
      optional:
        same as for getData

::

    GETDATA - returns an indexed projection of CubeStruct object's content

    Input:
      regular:
          self: CubeStruct [1,1] - the object

      optional:

          subIndCVec:
            Case#1: numeric[1,]/numeric[,1]

            Case#2: cell[1,nDims]/cell[nDims,1] of double [nSubElem_i,1]
                  for i=1,...,nDims

              -array of indices of field value slices that are selected
              to be returned; if not given (default),
              no indexation is performed

            Note!: numeric components of subIndVec are allowed to contain
               zeros which are be treated as they were references to null
               data slices

          dimVec: numeric[1,nDims]/numeric[nDims,1] - vector of dimension
              numbers corresponding to subIndCVec

      properties:

          fieldNameList: char[1,]/cell[1,nFields] of char[1,]
              list of field names to return

          structNameList: char[1,]/cell[1,nStructs] of char[1,]
              list of internal structures to return (by default it
              is {SData, SIsNull, SIsValueNull}

          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values uniformly across all the cells,
                  default value is false

          nullReplacements: cell[1,nReplacedFields]  - list of null
              replacements for each of the fields

          nullReplacementFields: cell[1,nReplacedFields] - list of fields in
             which the nulls are to be replaced with the specified values,
             if not specified it is assumed that all fields are to be
             replaced

             NOTE!: all fields not listed in this parameter are replaced with
             the default values

          checkInputs: logical[1,1] - true by default (input arguments are
             checked for correctness

    Output:
      regular:
        SData: struct [1,1] - structure containing values of
            fields at the selected slices, each field is an array
            containing values of the corresponding type

        SIsNull: struct [1,1] - structure containing a nested
            array with is-null indicators for each CubeStruct cell content

        SIsValueNull: struct [1,1] - structure containing a
           logical array [] for each of the fields (true
           means that a corresponding cell doesn't not contain
              any value

::

    GETFIELDDESCRLIST - returns the list of CubeStruct field descriptions

    Usage: value=getFieldDescrList(self)

    Input:
      regular:
          self: CubeStruct [1,1]
      optional:
          fieldNameList: cell[1,nSpecFields] of char[1,] - field names for
             which descriptions should be returned

    Output:
      regular:
        value: char cell [1,nFields] - list of CubeStruct object field
            descriptions

::

    GETFIELDISNULL - returns for given field a nested logical/cell array
                     containing is-null indicators for cell content

    Usage: fieldIsNullCVec=getFieldIsNull(self,fieldName)

    Input:
      regular:
        self: CubeStruct [1,1]
        fieldName: char - field name
    Output:
      regular:
        fieldIsCVec: logical/cell[] - nested cell/logical array containing
           is-null indicators for content of the field

::

    GETFIELDISVALUENULL - returns for given field logical vector determining
                          whether value of this field in each cell is null
                          or not.

    BEWARE OF confusing this with getFieldIsNull method which returns is-null
       indicators for a field content

    Usage: isNullVec=getFieldValueIsNull(self,fieldName)

    Input:
      regular:
        self: CubeStruct [1,1]
        fieldName: char - field name

    Output:
      regular:
        isValueNullVec: logical[] - array of isValueNull indicators for the
           specified field

::

    GETFIELDNAMELIST - returns the list of CubeStruct object field names

    Usage: value=getFieldNameList(self)

    Input:
      regular:
        self: CubeStruct [1,1]
    Iutput:
      regular:
        value: char cell [1,nFields] - list of CubeStruct object field
            names

::

    GETFIELDPROJECTION - project object with specified fields.

    Input:
      regular:
          self: ARelation[1,1] - original object
          fieldNameList: cell[1,nFields] of char[1,] - field name list

    Output:
      obj: DynamicRelation[1,1] - projected object

::

    GETFIELDTYPELIST - returns list of field types in given CubeStruct object

    Usage: fieldTypeList=getFieldTypeList(self)

    Input:
      regular:
          self: CubeStruct [1,1]

      optional:
          fieldNameList: cell[1,nFields] - list of field names

    Output:
     regular:
      fieldTypeList: cell [1,nFields] of smartdb.cubes.ACubeStructFieldType[1,1]
          - list of field types

::

    GETFIELDTYPESPECLIST - returns a list of field type specifications. Field
                           type specification is a sequence of type names
                           corresponding to field value types starting with
                           the top level and going down into the nested
                           content of a field (for a field having a complex
                           type).

    Input:
      regular:
          self:
      optional:
          fieldNameList: cell [1,nFields] of char[1,] - list of field names
      properties:
          uniformOutput: logical[1,1] - if true, the result is concatenated
             across all the specified fields

    Output:
      typeSpecList:
           Case#1: uniformOutput=false
              cell[1,nFields] of cell[1,nNestedLevels_i] of char[1,.]
           Case#2: uniformOutput=true
              cell[1,nFields*prod(nNestedLevelsVec)] of char[1,.]
           - list of field type specifications

::

    GETFIELDVALUESIZEMAT - returns a matrix composed from the size vectors
                           for the specified fields

    Input:
      regular:
          self:

      optional:
          fieldNameList: cell[1,nFields] - a list of fileds for which the size
             matrix is to be generated

      properties:
          skipMinDimensions: logical[1,1] - if true, the dimensions from 1 up
              to minDimensionality are skipped

          minDimension: numeric[1,1] - minimum dimension which definies a
             minimum number of columns in the resulting matrix

    Output:
      sizeMat: double[nFields,nMaxDims]

::

    GETISFIELDVALUENULL - returns a vector indicating whether a particular
                          field is composed of null values completely

    Usage: isValueNullVec=getIsFieldValueNull(self,fieldNameList)

    Input:
      regular:
        self: CubeStruct [1,1]

      optional:
        fieldNameList: cell[1,nFields] of char[1,] - list of field names

    Output:
      regular:
        isValueNullVec: logical[1,nFields]

::

    GETJOINWITH - returns a result of INNER join of given relation with
                  another relation by the specified key fields

    LIMITATION: key fields by which the join is peformed are required to form
    a unique key in the given relation

    Input:
      regular:
          self:
          otherRel: smartdb.relations.ARelation[1,1]
          keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]

      properties:
          joinType: char[1,] - type of join, can be
              'inner' (DEFAULT)
              'leftOuter'

    Output:
      resRel: smartdb.relations.ARelation[1,1] - join result

::

    GETMINDIMENSIONSIZE - returns a size vector for the specified
                          dimensions. If no dimensions are specified, a size
                          vector for all dimensions up to minimum CubeStruct
                          dimension is returned

    Input:
      regular:
          self:
      optional:
          dimNumVec: numeric[1,nDims] - a vector of dimension
              numbers

    Output:
      minDimensionSizeVec: double [1,nDims] - a size vector for
         the requested dimensions

::

    GETMINDIMENSIONALITY - returns a minimum dimensionality for a given
                           object

    Input:
      regular:
          self

    Output:
      minDimensionality: double[1,1] - minimum dimensionality of
         self object

::

    GETNELEMS - returns a number of elements in a given object
    Input:
      regular:
         self:

    Output:
      nElems:double[1, 1] - number of elements in a given object

::

    GETNFIELDS - returns number of fields in given object

    Usage: nFields=getNFields(self)

    Input:
      regular:
        self: CubeStruct [1,1]
    Output:
      regular:
        nFields: double [1,1] - number of fields in given object

::

    GETNTUPLES - returns number of tuples in given relation

    Usage: nTuples=getNTuples(self)

    input:
      regular:
        self: ARelation [1,1] - class object
    output:
      regular:
        nTuples: double [1,1] - number of tuples in given  relation

::

    GETSORTINDEX - gets sort index for all tuples of given relation with
                   respect to some of its fields

    Usage: sortInd=getSortIndex(self,sortFieldNameList,varargin)

    input:
      regular:
        self: ARelation [1,1] - class object
        sortFieldNameList: char or char cell [1,nFields] - list of field
           names with respect to which tuples are sorted

      properties:
        Direction: char or char cell [1,nFields] - direction of sorting for
            all fields (if one value is given) or for each field separately;
            each value may be 'asc' or 'desc'
    output:
      regular:
       sortIndex: double [nTuples,1] - sort index for all tuples such that if
           fieldValueVec is a vector of values for some field of given
           relation, then fieldValueVec(sortIndex) is a vector of values for
           this field when tuples of the relation are sorted

::

    GETTUPLES - selects tuples with given indices from given relation and
                returns the result as new relation

    Usage: obj=getTuples(self,subIndVec)

    input:
      regular:
        self: ARelation [1,1] - class object
        subIndVec: double [nSubTuples,1]/logical[nTuples,1] - array of
            indices for tuples that are selected
    output:
      regular:
        obj: ARelation [1,1] - new class object containing only selected
            tuples

::

    GETTUPLESFILTEREDBY - selects tuples from given relation such that a
                          fixed index field contains values from a given set
                          of value and returns the result as new relation

    Input:
      regular:
        self: ARelation [1,1] - class object
        filterFieldName: char - name of index field
        filterValueVec: numeric/ cell of char [nValues,1] - vector of index
            values

      properties:
        keepNulls: logical[1,1] - if true, null values are not filteed out,
           and removed otherwise,
              default: false

    Output:
      regular:
        obj: ARelation [1,1] - new class object containing only selected
            tuples
        isThereVec: logical[nTuples,1] - contains true for the kept tuples

::

     GETTUPLESINDEXEDBY - selects tuples from given relation such that fixed
                          index field contains given in a specified order
                          values and returns the result as new relation.
                          It is required that the original relation
                          contains only one record for each field value

     input:
       regular:
         self: ARelation [1,1] - class object
         indexFieldName: char - name of index field
         indexValueVec: numeric or char cell [nValues,1] - vector of index
             values
     output:
       regular:
         obj: ARelation [1,1] - new class object containing only selected
             tuples

    TODO add type check

::

    GETTUPLESJOINEDWITH - returns the tuples of the given relation
                          INNER-joined with other relation by the specified
                          key fields

    Input:
      regular:
          self:
          otherRel: smartdb.relations.ARelation[1,1]
          keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]

      properties:
          joinType: char[1,] - type of join, can be
              'inner' (DEFAULT) - inner join
              'leftOuter' - left outer join
              'rightOuter' - right outer join
              'fullOuter' - full outer join

          fieldDescrSource: char[1,] - defines where the field descriptions
             are taken from, can be
              'useOriginal' - field descriptions are taken from the left hand
                  side argument of the join operation
              'useOther' - field descriptions are taken from the right hand
                  side of the join operation

    Output:
      resRel: smartdb.relations.ARelation[1,1] - join result

::

    GETUNIQUEDATA - returns internal representation for a set of unique
                    tuples for given relation

    Usage: [SData,SIsNull,SIsValueNull]=getUniqueData(self,varargin)

    Input:
      regular:
        self: ARelation [1,1] - class object
      properties
          fieldNameList: list of field names used for finding the unique
              elements; only the specified fields are returned in SData,
              SIsNull,SIsValueNull structures
          structNameList: list of internal structures to return (by default it
              is {SData, SIsNull, SIsValueNull}
          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values uniformly across all the tuples
                  default value is false

    Output:
      regular:

        SData: struct [1,1] - structure containing values of fields in
            selected tuples, each field is an array containing values of the
            corresponding type

        SIsNull: struct [1,1] - structure containing info whether each value
            in selected tuples is null or not, each field is either logical
            array or cell array containing logical arrays

        SIsValueNull: struct [1,1] - structure containing a
           logical array [nTuples,1] for each of the fields (true
           means that a corresponding cell doesn't not contain
              any value

        indForward: double[1,nUniqueTuples] - indices of unique entries in
           the original tuple set

        indBackward: double[1,nTuples] - indices that map the unique tuple
           set back to the original tuple set

::

    GETUNIQUEDATAALONGDIM - returns internal representation of CubeStruct

    Input:
      regular:
        self:
        catDim: double[1,1] - dimension number along which uniqueness is
           checked

      properties
          fieldNameList: list of field names used for finding the unique
              elements; only the specified fields are returned in SData,
              SIsNull,SIsValueNull structures
          structNameList: list of internal structures to return (by default
              it is {SData, SIsNull, SIsValueNull}
          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values uniformly across all CubeStruct cells
                  default value is false
          checkInputs: logical[1,1] - if true, the input parameters are
             checked for consistency

    Output:
      regular:
        SData: struct [1,1] - structure containing values of fields

        SIsNull: struct [1,1] - structure containing info whether each value
            in selected cells is null or not, each field is either logical
            array or cell array containing logical arrays

        SIsValueNull: struct [1,1] - structure containing a
           logical array [nSlices,1] for each of the fields (true
           means that a corresponding cell doesn't not contain
              any value

        indForwardVec: double[nUniqueSlices,1] - indices of unique entries in
           the original CubeStruct data set

        indBackwardVec: double[nSlices,1] - indices that map the unique data
           set back to the original data setdata set unique along a specified
           dimension

::

    GETUNIQUETUPLES - returns a relation containing the unique tuples from
                      the original relation

    Usage: [resRel,indForwardVec,indBackwardVec]=getUniqueTuples(self,varargin)

    Input:
      regular:
        self: ARelation [1,1] - class object
      properties
          fieldNameList: list of field names used for finding the unique
             tuples
          structNameList: list of internal structures to return (by default it
              is {SData, SIsNull, SIsValueNull}
          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values uniformly across all the tuples
                  default value is false

    Output:
      regular:

        resRel: ARelation[1,1] - resulting relation

        indForward: double[1,nUniqueTuples] - indices of unique entries in
           the original tuple set

        indBackward: double[1,nTuples] - indices that map the unique tuple
           set back to the original tuple set

::

    INITBYEMPTYDATASET - initializes cube struct object with null value arrays
                         of specified size based on minDimVec specified.

    For instance, if minDimVec=[2,3,4,5,6] and minDimensionality of cube
    struct object cb is 2, then cb.initByEmptyDataSet(minDimVec) will create
    a cube struct object with element array of [2,3] size where each element
    has size of [4,5,6,0]

    Input:
      regular:
          self:
      optional
          minDimVec: double[1,nDims] - size vector of null value arrays

::

    INITBYDEFAULTDATASET - initializes cube struct object with null value
                           arrays of specified size based on minDimVec
                           specified.

    For instance, if minDimVec=[2,3,4,5,6] and minDimensionality of cube
    struct object cb is 2, then cb.initByEmptyDataSet(minDimVec) will create
    a cube struct object with element array of [2,3] size where each element
    has size of [4,5,6]

    Input:
      regular:
          self:
      optional
          minDimVec: double[1,nDims] - size vector of null value arrays

::

    ISEQUAL - compares current relation object with other relation object and
              returns true if they are equal, otherwise it returns false


    Usage: isEq=isEqual(self,otherObj)

    Input:
      regular:
        self: ARelation [1,1] - current relation object
        otherObj: ARelation [1,1] - other relation object

      properties:
        checkFieldOrder/isFieldOrderCheck: logical [1,1] - if true, then fields
            in compared relations must be in the same order, otherwise the
            order is not  important (false by default)
        checkTupleOrder: logical[1,1] -  if true, then the tuples in the
            compared relations are expected to be in the same order,
            otherwise the order is not important (false by default)

        maxTolerance: double [1,1] - maximum allowed tolerance

        compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            referenced from the meta data objects are also compared

        maxRelativeTolerance: double [1,1] - maximum allowed
        relative tolerance

    Output:
      isEq: logical[1,1] - result of comparison
      reportStr: char[1,] - report of comparsion

::

     ISFIELDS - returns whether all fields whose names are given in the input
                list are in the field list of given object or not

     Usage: isPositive=isFields(self,fieldList)

     Input:
       regular:
         self: CubeStruct [1,1]
         fieldList: char or char cell [1,nFields]/[nFields,1] - input list of
             given field names
     Output:
       isPositive: logical [1,1] - true if all gields whose
           names are given in the input list are in the field
           list of given object, false otherwise

       isUniqueNames: logical[1,1] - true if the specified names contain
          unique field values

       isThereVec: logical[1,nFields] - each element indicate whether the
           corresponding field is present in the cube

    TODO allow for varargins

::

    ISMEMBERALONGDIM - performs ismember operation of CubeStruct data slices
                       along the specified dimension
    Input:
      regular:
        self: ARelation [1,1] - class object
        other: ARelation [1,1] - other class object
        dim: double[1,1] - dimension number for ismember operation

      properties:
        keyFieldNameList/fieldNameList: char or char cell [1,nKeyFields] -
            list  of fields to which ismember is applied; by default all
            fields of first (self) object are used


    Output:
      regular:
        isThere: logical [nSlices,1] - determines for each data slice of the
            first (self) object whether combination of values for key fields
            is in the second (other) object or not
        indTheres: double [nSlices,1] - zero if the corresponding coordinate
            of isThere is false, otherwise the highest index of the
            corresponding data slice in the second (other) object

::

    ISMEMBER - performs ismember operation for tuples of two relations by key
               fields given by special list

    Usage: isTuple=isMemberTuples(self,otherRel,keyFieldNameList) or
           [isTuple indTuples]=isMemberTuples(self,otherRel,keyFieldNameList)

    Input:
      regular:
        self: ARelation [1,1] - class object
        other: ARelation [1,1] - other class object
      optional:
        keyFieldNameList: char or char cell [1,nKeyFields] - list of fields
            to which ismember is applied; by default all fields of first
            (self) object are used
    Output:
      regular:
        isTuple: logical [nTuples,1] - determines for each tuple of first
            (self) object whether combination of values for key fields is in
            the second (other) relation or not
        indTuples: double [nTuples,1] - zero if the corresponding coordinate
            of isTuple is false, otherwise the highest index of the
            corresponding tuple in the second (other) relation

::

    ISUNIQUEKEY - checks if a specified set of fields forms a unique key

    Usage: isPositive=self.isUniqueKey(fieldNameList)

    Input:
      regular:
          self: ARelation [1,1] - class object
          fieldNameList: cell[1,nFields] - list of field names for a unique
              key candidate
    Output:
      isPositive: logical[1,1] - true means that a specified set of fields is
         a unique key

::

    ISEQUAL - compares current relation object with other relation object and
              returns true if they are equal, otherwise it returns false


    Usage: isEq=isEqual(self,otherObj)

    Input:
      regular:
        self: ARelation [1,1] - current relation object
        otherObj: ARelation [1,1] - other relation object

      properties:
        checkFieldOrder/isFieldOrderCheck: logical [1,1] - if true, then fields
            in compared relations must be in the same order, otherwise the
            order is not  important (false by default)
        checkTupleOrder: logical[1,1] -  if true, then the tuples in the
            compared relations are expected to be in the same order,
            otherwise the order is not important (false by default)

        maxTolerance: double [1,1] - maximum allowed tolerance

        compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            referenced from the meta data objects are also compared

        maxRelativeTolerance: double [1,1] - maximum allowed
        relative tolerance

    Output:
      isEq: logical[1,1] - result of comparison
      reportStr: char[1,] - report of comparsion

::

    REMOVEDUPLICATETUPLES - removes all duplicate tuples from the relation

    Usage: [indForwardVec,indBackwardVec]=...
               removeDuplicateTuples(self,varargin)

    Input:
      regular:
        self: ARelation [1,1] - class object

      properties:
          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values for all fields uniformly across all
              relation tuples
                  default value is false

    Output:
      optional:
        indForwardVec: double[nUniqueSlices,1] - indices of unique tuples in
           the original relation

        indBackwardVec: double[nSlices,1] - indices that map the unique
           tuples back to the original tuples

::

    REMOVETUPLES - removes tuples with given indices from given relation

    Usage: self.removeTuples(subIndVec)

    Input:
      regular:
        self: ARelation [1,1] - class object
        subIndVec: double [nSubTuples,1]/logical[nTuples,1] - array of
           indices for tuples that are selected to be removed

::

    REORDERDATA - reorders cells of CubeStruct object along the specified
                  dimensions according to the specified index vectors

    Input:
      regular:
          self: CubeStruct [1,1] - the object
          subIndCVec: numeric[1,]/cell[1,nDims] of double [nSubElem_i,1]
              for i=1,...,nDims array of indices of field value slices that
              are selected to be returned;
              if not given (default), no indexation is performed

      optional:
          dimVec: numeric[1,nDims] - vector of dimension numbers
              corresponding to subIndCVec

::

    SAVEOBJ- transforms given CubeStruct object into structure containing
             internal representation of object properties

    Input:
      regular:
        self: CubeStruct [nDim1,...,nDim2]


    Output:
      regular:
        SObjectData: struct [n1,...,n_k] - structure containing an internal
           representation of the specified object

::

    SETDATA - sets values of all cells for all fields

    Input:
      regular:
        self: CubeStruct[1,1]

      optional:
        SData: struct [1,1] - structure with values of all cells for
            all fields

        SIsNull: struct [1,1] - structure of fields with is-null
           information for the field content, it can be logical for
           plain real numbers of cell of logicals for cell strs or
           cell of cell of str for more complex types

        SIsValueNull: struct [1,1] - structure with logicals
            determining whether value corresponding to each field
            and field cell is null or not

      properties:
          fieldNameList: cell[1,] of char[1,] - list of fields for which data
              should be generated, if not specified, all fields from the
              relation are taken

          isConsistencyCheckedVec: logical [1,1]/[1,2]/[1,3] -
              the first element defines if a consistency between the value
                  elements (data, isNull and isValueNull) is checked;
              the second element (if specified) defines if
                  value's type is checked.
              the third element defines if consistency between of sizes
                  between different fields is checked
                If isConsistencyCheckedVec
                  if scalar, it is automatically replicated to form a
                      3-element vector
                  if the third element is not specified it is assumed
                      to be true

          transactionSafe: logical[1,1], if true, the operation is performed
             in a transaction-safe manner

          checkStruct: logical[1,nStruct] - an array of indicators which when
             all true force checking of structure content (including presence
             of required fields). The first element correspod to SData, the
             second and the third (if specified) to SIsNull and SIsValueNull
             correspondingly

          structNameList: char[1,]/cell[1,], name of data structure/list of
            data structure names to which the function is to
                 be applied, can be composed from the following values

               SData - data itself

               SIsNull - contains is-null indicator information for data
                    values

               SIsValueNull - contains is-null indicators for CubeStruct cells
                   (not for cell values)
            structNameList={'SData'} by default

          fieldMetaData: smartdb.cubes.CubeStructFieldInfo[1,] - field meta
             data array which is used for data validity checking and for
             replacing the existing meta-data

          mdFieldNameList: cell[1,] of char - list of names of fields for
             which meta data is specified

          dataChangeIsComplete: logical[1,1] - indicates whether a change
              performed by the function is complete

    Note: call of setData with an empty list of arguments clears
       the data

::

    SETFIELDINTERNAL - sets values of all cells for given field

    Usage: setFieldInternal(self,fieldName,value)

    Input:
      regular:
        self: CubeStruct [1,1]
        fieldName: char - name of field
        value: array [] of some type - field values

      optional:
        isNull: logical/cell[]
        isValueNull: logical[]

      properties:
        structNameList: list of internal structures to return (by default it
          is {SData, SIsNull, SIsValueNull}

        inferIsNull: logical[1,2] - the first (second) element = false
          means that IsNull (IsValueNull) indicator for a field in question
              is kept intact (default = [true,true])

          Note: if structNameList contains 'SIsValueNull' entry,
           inferIsValueNull parameter is overwritten by false

::

    SORTBY - sorts all tuples of given relation with respect to some of its
             fields

    Usage: sortBy(self,sortFieldNameList,varargin)

    input:
      regular:
        self: ARelation [1,1] - class object
        sortFieldNameList: char or char cell [1,nFields] - list of field
            names with respect to which tuples are sorted
      properties:
        direction: char or char cell [1,nFields] - direction of sorting for
            all fields (if one value is given) or for each field separately;
            each value may be 'asc' or 'desc'

::

    SORTBYALONGDIM -  sorts data of given CubeStruct object along the
                      specified dimension using the specified fields

    Usage: sortByInternal(self,sortFieldNameList,varargin)

    input:
      regular:
        self: CubeStruct [1,1] - class object
        sortFieldNameList: char or char cell [1,nFields] - list of field
            names with respect to which field content is sorted
        sortDim: numeric[1,1] - dimension number along which the sorting is
           to be performed
        properties:
        direction: char or char cell [1,nFields] - direction of sorting for
            all fields (if one value is given) or for each field separately;
            each value may be 'asc' or 'desc'

::

    TOARRAY - transforms values of all CubeStruct cells into a multi-
              dimentional array

    Usage: resCArray=toArray(self,varargin)

    Input:
      regular:
        self: CubeStruct [1,1]

      properties:
        checkInputs: logical[1,1] - if false, the method skips checking the
           input parameters for consistency

        fieldNameList: cell[1,] - list of filed names to return

        structNameList: cell[1,]/char[1,], data structure list
           for which the data is to be taken from, can consist of the
           following values

          SData - data itself
          SIsNull - contains is-null indicator information for data values
          SIsValueNull - contains is-null indicators for CubeStruct cells
             (not for cell values)

        groupByColumns: logical[1,1], if true, each column is returned in a
           separate cell

        outputType: char[1,] - method of formign an output array, the
           following methods are supported:
               'uniformMat' - the field values are concatenated without any
                       type/size transformations. As a result, this method
                       will fail if the specified fields have different types
                       or/and sizes along any dimension apart from catDim

               'uniformCell' - not-cell fields are converted to cells
                       element-wise but no size-transformations is performed.
                       This method will fail if the specified fields have
                       different sizes along any dimension apart from catDim

               'notUniform' - this method doesn't make any assumptions about
                       size or type of the fields. Each field value is wrapped
                       into cell in a such way that a size of resulting cell
                       is minDimensionSizeVec for each field. Thus if for
                       instance is size of cube object is [2,3,4] and a field
                       size is [2,4,5,10,30] its value is splitted into 2*4*5
                       pieces with each piece of size [1,1,1,10,30] put it
                       its separate cell
               'adaptiveCell' - functions similarly to 'nonUniform' except for
                       the cases when a field value size equals
                       minDimensionSizeVec exactly i.e. the field takes only
                       scalar values. In such cases no wrapping into cell is
                       performed which allows to get a more transparent
                       output.

        catDim: double[1,1] - dimension number for
           concatenating outputs when groupByColumns is false


        replaceNull: logical[1,1], if true, null values from SData are
           replaced by null replacement, = true by default

        nullTopReplacement: - can be of any type and currently only applicable
          when  UniformOutput=false and of
          the corresponding column type if UniformOutput=true.

          Note!: this parameter is disregarded for any dataStructure different
             from 'SData'.

          Note!: the main difference between this parameter and the following
             parameters is that nullTopReplacement can violate field type
             constraints thus allowing to replace doubles with strings for
             instance (for non-uniform output types only of course)


        nullReplacements: cell[1,nReplacedFields]  - list of null
           replacements for each of the fields

        nullReplacementFields: cell[1,nReplacedFields] - list of fields in
           which the nulls are to be replaced with the specified values,
           if not specified it is assumed that all fields are to be replaced

           NOTE!: all fields not listed in this parameter are replaced with
           the default values


    Output:
      Case1 (one output is requested and length(structNameList)==1):

          resCMat: matrix/cell[]  with values of all fields (or
            fields selected by optional arguments) for all CubeStruct
            data cells

      Case2 (multiple outputs are requested and their number =
        length(structNameList) each output is assigned resCMat for the
        corresponding struct

      Case3 (2 outputs is requested or length(structNameList)+1 outputs is
      requested). In this case the last output argument is

           isConvertedToCell: logical[nFields,nStructs] -  matrix with true
              values on the positions which correspond to fields converted to
              cells

::

    TOCELL - transforms values of all fields for all tuples into two
             dimensional cell array

    Usage: resCMat=toCell(self,varargin)

    input:
      regular:
        self: ARelation [1,1] - class object
      optional:
        fieldName1: char - name of first field
        ...
        fieldNameN: char - name of N-th field
    output:
      resCMat: cell [nTuples,nFields(N)] - cell with values of all fields (or
          fields selected by optional arguments) for all tuples

    FIXME - order fields in setData method

::

    TOCELLISNULL - transforms is-null indicators of all fields for all tuples
                   into two dimensional cell array

    Usage: resCMat=toCell(self,varargin)

    input:
      regular:
        self: ARelation [1,1] - class object
      optional:
        fieldName1: char - name of first field
        ...
        fieldNameN: char - name of N-th field
    output:
      resCMat: cell [nTuples,nFields(N)] - cell with values of all fields (or
          fields selected by optional arguments) for all tuples

    FIXME - order fields in setData method

::

    TODISPCELL - transforms values of all fields into their character
                 representation

    Usage: resCMat=toDispCell(self)

    Input:
      regular:
        self: ARelation [1,1] - class object

      properties:
          nullTopReplacement: any[1,1] - value used to replace null values
          fieldNameList: cell[1,] of char[1,] - field name list

    Output:
      dataCell: cell[nRows,nCols] of char[1,] - cell array containing the
          character representation of field values

::

    TOMAT - transforms values of all fields for all tuples into two
            dimensional array

    Usage: resCMat=toMat(self,varargin)

    input:
      regular:
        self: ARelation [1,1] - class object

      optional:
        fieldNameList: cell[1,] - list of filed names to return

        uniformOutput: logical[1,1], true - cell is returned, false - the
           functions tries to return a result as a matrix

        groupByColumns: logical[1,1], if true, each column is returned in a
           separate cell

        structNameList/dataStructure: char[1,], data structure for which the
           data is to be taken from, can have one of the following values

          SData - data itself
          SIsNull - contains is-null indicator information for data values
          SIsValueNull - contains is-null indicators for relation cells (not
             for cell values

        replaceNull: logical[1,1], if true, null values from SData are
           replaced by null replacement, = true by default

        nullTopReplacement: - can be of any type and currently only applicable
          when  UniformOutput=false and of
          the corresponding column type if UniformOutput=true.

          Note!: this parameter is disregarded for any dataStructure different
             from 'SData'.

          Note!: the main difference between this parameter and the following
             parameters is that nullTopReplacement can violate field type
             constraints thus allowing to replace doubles with strings for
             instance (for non-uniform output types only of course)


        nullReplacements: cell[1,nReplacedFields]  - list of null
           replacements for each of the fields

        nullReplacementFields: cell[1,nReplacedFields] - list of fields in
           which the nulls are to be replaced with the specified values,
           if not specified it is assumed that all fields are to be replaced

           NOTE!: all fields not listed in this parameter are replaced with
           the default values

    output:
      resCMat:  [nTuples,nFields(N)] - matrix/cell with values of all fields
          (or fields selected by optional arguments) for all tuples

::

    TOSTRUCT - transforms given CubeStruct object into structure

    Input:
      regular:
        self: CubeStruct [nDim1,...,nDim2]


    Output:
      regular:
        SObjectData: struct [n1,...,n_k] - structure containing an internal
           representation of the specified object

::

    UNIONWITH - adds tuples of the input relation to the set of tuples of the
                original relation
    Usage: self.unionWith(inpRel)

    Input:
      regular:
        self: ARelation [1,1] - class object
        inpRel1: ARelation [1,1] - object to get the additional tuples from
          ...
        inpRelN: ARelation [1,1] - object to get the additional tuples from

      properties:
          checkType: logical[1,1] - if true, union is only performed when the
              types of relations is the same. Default value is false

          checkStruct: logical[1,nStruct] - an array of indicators which when
             true force checking of structure content (including presence
             of all required fields). The first element correspod to SData,
             the second and the third (if specified) to SIsNull and
             SIsValueNull correspondingly

          checkConsistency: logical [1,1]/[1,2] - the
              first element defines if a consistency between the value
              elements (data, isNull and isValueNull) is checked;
              the second element (if specified) defines if
              value's type is checked. If isConsistencyChecked
              is scalar, it is automatically replicated to form a
              two-element vector.
              Note: default value is true

::

    UNIONWITHALONGDIM - adds data from the input CubeStructs

    Usage: self.unionWithAlongDim(unionDim,inpCube)

    Input:
      regular:
      self:
          inpCube1: CubeStruct [1,1] - object to get the additional data from
              ...
          inpCubeN: CubeStruct [1,1] - object to get the additional data from

      properties:
          checkType: logical[1,1] - if true, union is only performed when the
              types of relations is the same. Default value is false

          checkStruct: logical[1,nStruct] - an array of indicators which when
             true force checking of structure content (including presence of
    all required fields). The first element correspod to SData, the
             second and the third (if specified) to SIsNull and SIsValueNull
             correspondingly

          checkConsistency: logical [1,1]/[1,2] - the
              first element defines if a consistency between the value
              elements (data, isNull and isValueNull) is checked;
              the second element (if specified) defines if
              value's type is checked. If isConsistencyChecked
              is scalar, it is automatically replicated to form a
              two-element vector.
              Note: default value is true

::

    WRITETOCSV - writes a content of relation into Excel spreadsheet file
    Input:
      regular:
          self:
          filePath: char[1,] - file path

    Output:
      none

::

    WRITETOXLS - writes a content of relation into Excel spreadsheet file
    Input:
      regular:
          self:
          filePath: char[1,] - file path

    Output:
      fileName: char[1,] - resulting file name, may not match with filePath
          when Excel is not available and csv format is used instead

gras.ellapx.smartdb.rels.EllTube
--------------------------------

::

    EllTube - class which keeps ellipsoidal tubes

    Fields:
      QArray:cell[1, nElem] - Array of ellipsoid matrices
      aMat:cell[1, nElem] - Array of ellipsoid centers
      scaleFactor:double[1, 1] - Tube scale factor
      MArray:cell[1, nElem] - Array of regularization ellipsoid matrices
      dim :double[1, 1] - Dimensionality
      sTime:double[1, 1] - Time s
      approxSchemaName:cell[1,] - Name
      approxSchemaDescr:cell[1,] - Description
      approxType:gras.ellapx.enums.EApproxType - Type of approximation
                    (external, internal, not defined)
      timeVec:cell[1, m] - Time vector
      calcPrecision:double[1, 1] - Calculation precision
      indSTime:double[1, 1]  - index of sTime within timeVec
      ltGoodDirMat:cell[1, nElem] - Good direction curve
      lsGoodDirVec:cell[1, nElem] - Good direction at time s
      ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve
      lsGoodDirNorm:double[1, 1] - Norm of good direction at time s
      xTouchCurveMat:cell[1, nElem] - Touch point curve for good
                                      direction
      xTouchOpCurveMat:cell[1, nElem] - Touch point curve for direction
                                        opposite to good direction
      xsTouchVec:cell[1, nElem]  - Touch point at time s
      xsTouchOpVec :cell[1, nElem] - Touch point at time s

      TODO: correct description of the fields in gras.ellapx.smartdb.rels.EllTube

See the description of the following methods in section
[secClassDescr:smartdb.relations.ATypifiedStaticRelation] for
smartdb.relations.ATypifiedStaticRelation:

::

    CAT  - concatenates data from relation objects.

    Input:
      regular:
          self.
          newEllTubeRel: smartdb.relation.StaticRelation[1, 1]/
              smartdb.relation.DynamicRelation[1, 1] - relation object
      properties:
          isReplacedByNew: logical[1,1] - if true, sTime and
              values of properties corresponding to sTime are taken
              from newEllTubeRel. Common times in self and
              newEllTubeRel are allowed, however the values for
              those times are taken either from self or from
              newEllTubeRel depending on value of isReplacedByNew
              property

          isCommonValuesChecked: logical[1,1] - if true, values
              at common times (if such are found) are checked for
              strong equality (with zero precision). If not equal
              - an exception is thrown. True by default.

          commonTimeAbsTol: double[1,1] - absolute tolerance used
              for comparing values at common times, =0 by default

          commonTimeRelTol: double[1,1] - absolute tolerance used
              for comparing values at common times, =0 by default

    Output:
      catEllTubeRel:smartdb.relation.StaticRelation[1, 1]/
          smartdb.relation.DynamicRelation[1, 1] - relation object
          resulting from CAT operation

::

    FROMELLARRAY  - creates a relation object using an array of ellipsoids

    Input:
      regular:
        qEllArray: ellipsoid[nDim1, nDim2, ..., nDimN] - array of ellipsoids

      optional:
       timeVec:cell[1, m] - time vector
       ltGoodDirArray:cell[1, nElem] - good direction at time s
       sTime:double[1, 1] - time s
       approxType:gras.ellapx.enums.EApproxType - type of approximation
                    (external, internal, not defined)
       approxSchemaName:cell[1,] - name of the schema
       approxSchemaDescr:cell[1,] - description of the schema
       calcPrecision:double[1, 1] - calculation precision

    Output:
       ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
           object

::

    FROMELLMARRAY  - creates a relation object using an array of ellipsoids.
                     This method uses regularizer in the form of a matrix
                     function.

    Input:
      regular:
        qEllArray: ellipsoid[nDim1, nDim2, ..., nDimN] - array of ellipsoids
        ellMArr: double[nDim1, nDim2, ..., nDimN] - regularization ellipsoid
            matrices

      optional:
       timeVec:cell[1, m] - time vector
       ltGoodDirArray:cell[1, nElem] - good direction at time s
       sTime:double[1, 1] - time s
       approxType:gras.ellapx.enums.EApproxType - type of approximation
                    (external, internal, not defined)
       approxSchemaName:cell[1,] - name of the schema
       approxSchemaDescr:cell[1,] - description of the schema
       calcPrecision:double[1, 1] - calculation precision

    Output:
       ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
             object

::

    FROMQARRAYS  - creates a relation object using an array of ellipsoids,
                   described by the array of ellipsoid matrices and
                   array of ellipsoid centers.This method used default
                   scale factor.

    Input:
      regular:
        QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            matrices
        aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers

    Optional:
       MArrayList:cell[1, nElem] - array of regularization ellipsoid matrices
       timeVec:cell[1, m] - time vector
       ltGoodDirArray:cell[1, nElem] - good direction at time s
       sTime:double[1, 1] - time s
       approxType:gras.ellapx.enums.EApproxType - type of approximation
                    (external, internal, not defined)
       approxSchemaName:cell[1,] - name of the schema
       approxSchemaDescr:cell[1,] - description of the schema
       calcPrecision:double[1, 1] - calculation precision

    Output:
       ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
           object

::

    FROMQMARRAYS  - creates a relation object using an array of ellipsoids,
                    described by the array of ellipsoid matrices and
                    array of ellipsoid centers. Also this method uses
                    regularizer in the form of a matrix function. This method
                    used default scale factor.

    Input:
      regular:
      QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            matrices
      aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers
      MArrayList: double[nDim1, nDim2, ..., nDimN] - ellipsoid  matrices of
            regularization

     optional:
       timeVec:cell[1, m] - time vector
       ltGoodDirArray:cell[1, nElem] - good direction at time s
       sTime:double[1, 1] - time s
       approxType:gras.ellapx.enums.EApproxType - type of approximation
                    (external, internal, not defined)
       approxSchemaName:cell[1,] - name of the schema
       approxSchemaDescr:cell[1,] - description of the schema
       calcPrecision:double[1, 1] - calculation precision

    Output:
       ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
             object

::

    FROMQMSCALEDARRAYS  - creates a relation object using an array of ellipsoids,
                          described by the array of ellipsoid matrices and
                          array of ellipsoid centers. Also this method uses
                          regularizer in the form of a matrix function.


    Input:
      regular:
        QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            matrices
        aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers
        MArrayList: double[nDim1, nDim2, ..., nDimN] - ellipsoid matrices
                  of regularization
        scaleFactor:double[1, 1] - tube scale factor

     optional:
       timeVec:cell[1, m] - time vector
       ltGoodDirArray:cell[1, nElem] - good direction at time s
       sTime:double[1, 1] - time s
       approxType:gras.ellapx.enums.EApproxType - type of approximation
                    (external, internal, not defined)
       approxSchemaName:cell[1,] - name of the schema
       approxSchemaDescr:cell[1,] - description of the schema
       calcPrecision:double[1, 1] - calculation precision

    Output:
       ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
             object

::

    GETDATA - returns an indexed projection of CubeStruct object's content

    Input:
      regular:
          self: CubeStruct [1,1] - the object

      optional:

          subIndCVec:
            Case#1: numeric[1,]/numeric[,1]

            Case#2: cell[1,nDims]/cell[nDims,1] of double [nSubElem_i,1]
                  for i=1,...,nDims

              -array of indices of field value slices that are selected
              to be returned; if not given (default),
              no indexation is performed

            Note!: numeric components of subIndVec are allowed to contain
               zeros which are be treated as they were references to null
               data slices

          dimVec: numeric[1,nDims]/numeric[nDims,1] - vector of dimension
              numbers corresponding to subIndCVec

      properties:

          fieldNameList: char[1,]/cell[1,nFields] of char[1,]
              list of field names to return

          structNameList: char[1,]/cell[1,nStructs] of char[1,]
              list of internal structures to return (by default it
              is {SData, SIsNull, SIsValueNull}

          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values uniformly across all the cells,
                  default value is false

          nullReplacements: cell[1,nReplacedFields]  - list of null
              replacements for each of the fields

          nullReplacementFields: cell[1,nReplacedFields] - list of fields in
             which the nulls are to be replaced with the specified values,
             if not specified it is assumed that all fields are to be
             replaced

             NOTE!: all fields not listed in this parameter are replaced with
             the default values

          checkInputs: logical[1,1] - true by default (input arguments are
             checked for correctness

    Output:
      regular:
        SData: struct [1,1] - structure containing values of
            fields at the selected slices, each field is an array
            containing values of the corresponding type

        SIsNull: struct [1,1] - structure containing a nested
            array with is-null indicators for each CubeStruct cell content

        SIsValueNull: struct [1,1] - structure containing a
           logical array [] for each of the fields (true
           means that a corresponding cell doesn't not contain
              any value

::

    GETELLARRAY - returns array of matrix's ellipsoid according to
                  approxType

    Input:
     regular:
        self.
        approxType:char[1,] - type of approximation(internal/external)

    Output:
      apprEllMat:double[nDim1,..., nDimN] - array of array of ellipsoid's
               matrices

::

    GETJOINWITH - returns a result of INNER join of given relation with
                  another relation by the specified key fields

    LIMITATION: key fields by which the join is peformed are required to form
    a unique key in the given relation

    Input:
      regular:
          self:
          otherRel: smartdb.relations.ARelation[1,1]
          keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]

      properties:
          joinType: char[1,] - type of join, can be
              'inner' (DEFAULT)
              'leftOuter'

    Output:
      resRel: smartdb.relations.ARelation[1,1] - join result

::

::

::

    ISEQUAL - compares current relation object with other relation object and
              returns true if they are equal, otherwise it returns false


    Usage: isEq=isEqual(self,otherObj)

    Input:
      regular:
        self: ARelation [1,1] - current relation object
        otherObj: ARelation [1,1] - other relation object

      properties:
        checkFieldOrder/isFieldOrderCheck: logical [1,1] - if true, then fields
            in compared relations must be in the same order, otherwise the
            order is not  important (false by default)
        checkTupleOrder: logical[1,1] -  if true, then the tuples in the
            compared relations are expected to be in the same order,
            otherwise the order is not important (false by default)

        maxTolerance: double [1,1] - maximum allowed tolerance

        compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            referenced from the meta data objects are also compared

        maxRelativeTolerance: double [1,1] - maximum allowed
        relative tolerance

    Output:
      isEq: logical[1,1] - result of comparison
      reportStr: char[1,] - report of comparsion

::

    PLOT - displays ellipsoidal tubes using the specified RelationDataPlotter


    Input:
      regular:
          self:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
              object used for displaying ellipsoidal tubes

::

    PROJECT - computes projection of the relation object onto given time
              dependent subspase
    Input:
      regular:
          self.
          projType: gras.ellapx.enums.EProjType[1,1] -
              type of the projection, can be
              'Static' and 'DynamicAlongGoodCurve'
          projMatList: cell[1,nProj] of double[nSpDim,nDim] - list of
              projection matrices, not necessarily orthogonal
       fGetProjMat: function_handle[1,1] - function which creates
          vector of the projection
                matrices
           Input:
            regular:
              projMat:double[nDim, mDim] - matrix of the projection at the
                instant of time
              timeVec:double[1, nDim] - time interval
            optional:
               sTime:double[1,1] - instant of time
           Output:
              projOrthMatArray:double[1, nSpDim] - vector of the projection
                matrices
              projOrthMatTransArray:double[nSpDim, 1] - transposed vector of
                the projection matrices
    Output:
       ellTubeProjRel: gras.ellapx.smartdb.rels.EllTubeProj[1, 1]/
           gras.ellapx.smartdb.rels.EllTubeUnionProj[1, 1] -
              projected ellipsoidal tube

       indProj2OrigVec:cell[nDim, 1] - index of the line number from
                which is obtained the projection

    Example:
      function example
       aMat = [0 1; 0 0]; bMat = eye(2);
       SUBounds = struct();
       SUBounds.center = {'sin(t)'; 'cos(t)'};
       SUBounds.shape = [9 0; 0 2];
       sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
       x0EllObj = ell_unitball(2);
       timeVec = [0 10];
       dirsMat = [1 0; 0 1]';
       rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
       ellTubeObj = rsObj.getEllTubeRel();
       unionEllTube = ...
        gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(ellTubeObj);
       projMatList = {[1 0;0 1]};
       projType = gras.ellapx.enums.EProjType.Static;
       statEllTubeProj = unionEllTube.project(projType,projMatList,...
          @fGetProjMat);
       plObj=smartdb.disp.RelationDataPlotter();
       statEllTubeProj.plot(plObj);
    end

    function [projOrthMatArray,projOrthMatTransArray]=fGetProjMat(projMat,...
        timeVec,varargin)
      nTimePoints=length(timeVec);
      projOrthMatArray=repmat(projMat,[1,1,nTimePoints]);
      projOrthMatTransArray=repmat(projMat.',[1,1,nTimePoints]);
     end

::

    PROJECTTOORTHS - project elltube onto subspace defined by
    vectors of standart basis with indices specified in indVec

    Input:
      regular:
          self: gras.ellapx.smartdb.rels.EllTube[1, 1] - elltube
              object
          indVec: double[1, nProjDims] - indices specifying a subset of
              standart basis
      optional:
          projType: gras.ellapx.enums.EProjType[1, 1] -  type of
              projection

    Output:
      regular:
          ellTubeProjRel: gras.ellapx.smartdb.rels.EllTubeProj[1, 1] -
              elltube projection

    Example:
      ellTubeProjRel = ellTubeRel.projectToOrths([1,2])
      projType = gras.ellapx.enums.EProjType.DynamicAlongGoodCurve
      ellTubeProjRel = ellTubeRel.projectToOrths([3,4,5], projType)

::

    SCALE - scales relation object

     Input:
      regular:
         self.
         fCalcFactor - function which calculates factor for
                        fields in fieldNameList
           Input:
             regular:
               fieldNameList: char/cell[1,] of char - a list of fields
                      for which factor will be calculated
            Output:
                factor:double[1, 1] - calculated factor

          fieldNameList:cell[1,nElem]/char[1,] - names of the fields

     Output:
          none

    Example:
      nPoints=5;
      calcPrecision=0.001;
      approxSchemaDescr=char.empty(1,0);
      approxSchemaName=char.empty(1,0);
      nDims=3;
      nTubes=1;
      lsGoodDirVec=[1;0;1];
      aMat=zeros(nDims,nPoints);
      timeVec=1:nPoints;
      sTime=nPoints;
      approxType=gras.ellapx.enums.EApproxType.Internal;
      qArrayList=repmat({repmat(diag([1 2 3]),[1,1,nPoints])},1,nTubes);
      ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
      fromMatEllTube=...
            gras.ellapx.smartdb.rels.EllTube.fromQArrays(qArrayList,...
            aMat, timeVec,ltGoodDirArray, sTime, approxType,...
            approxSchemaName, approxSchemaDescr, calcPrecision);
      fromMatEllTube.scale(@(varargin)2,{});

::

::

gras.ellapx.smartdb.rels.EllTubeProj
------------------------------------

::

    EllTubeProj - class which keeps ellipsoidal tube's projection

    Fields:
      QArray:cell[1, nElem] - Array of ellipsoid matrices
      aMat:cell[1, nElem] - Array of ellipsoid centers
      scaleFactor:double[1, 1] - Tube scale factor
      MArray:cell[1, nElem] - Array of regularization ellipsoid matrices
      dim :double[1, 1] - Dimensionality
      sTime:double[1, 1] - Time s
      approxSchemaName:cell[1,] - Name
      approxSchemaDescr:cell[1,] - Description
      approxType:gras.ellapx.enums.EApproxType - Type of approximation
                    (external, internal, not defined)
      timeVec:cell[1, m] - Time vector
      calcPrecision:double[1, 1] - Calculation precision
      indSTime:double[1, 1]  - index of sTime within timeVec
      ltGoodDirMat:cell[1, nElem] - Good direction curve
      lsGoodDirVec:cell[1, nElem] - Good direction at time s
      ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve
      lsGoodDirNorm:double[1, 1] - Norm of good direction at time s
      xTouchCurveMat:cell[1, nElem] - Touch point curve for good
                                      direction
      xTouchOpCurveMat:cell[1, nElem] - Touch point curve for direction
                                        opposite to good direction
      xsTouchVec:cell[1, nElem]  - Touch point at time s
      xsTouchOpVec:cell[1, nElem] - Touch point at time s
      projSTimeMat: cell[1, 1] - Projection matrix at time s
      projType:gras.ellapx.enums.EProjType - Projection type
      ltGoodDirNormOrigVec:cell[1, 1] - Norm of the original (not
                                        projected) good direction curve
      lsGoodDirNormOrig:double[1, 1] - Norm of the original (not
                                       projected)good direction at time s
      lsGoodDirOrigVec:cell[1, 1] - Original (not projected) good
                                    direction at time s

    TODO: correct description of the fields in
        gras.ellapx.smartdb.rels.EllTubeProj

See the description of the following methods in section
[secClassDescr:smartdb.relations.ATypifiedStaticRelation] for
smartdb.relations.ATypifiedStaticRelation:

::

    GETDATA - returns an indexed projection of CubeStruct object's content

    Input:
      regular:
          self: CubeStruct [1,1] - the object

      optional:

          subIndCVec:
            Case#1: numeric[1,]/numeric[,1]

            Case#2: cell[1,nDims]/cell[nDims,1] of double [nSubElem_i,1]
                  for i=1,...,nDims

              -array of indices of field value slices that are selected
              to be returned; if not given (default),
              no indexation is performed

            Note!: numeric components of subIndVec are allowed to contain
               zeros which are be treated as they were references to null
               data slices

          dimVec: numeric[1,nDims]/numeric[nDims,1] - vector of dimension
              numbers corresponding to subIndCVec

      properties:

          fieldNameList: char[1,]/cell[1,nFields] of char[1,]
              list of field names to return

          structNameList: char[1,]/cell[1,nStructs] of char[1,]
              list of internal structures to return (by default it
              is {SData, SIsNull, SIsValueNull}

          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values uniformly across all the cells,
                  default value is false

          nullReplacements: cell[1,nReplacedFields]  - list of null
              replacements for each of the fields

          nullReplacementFields: cell[1,nReplacedFields] - list of fields in
             which the nulls are to be replaced with the specified values,
             if not specified it is assumed that all fields are to be
             replaced

             NOTE!: all fields not listed in this parameter are replaced with
             the default values

          checkInputs: logical[1,1] - true by default (input arguments are
             checked for correctness

    Output:
      regular:
        SData: struct [1,1] - structure containing values of
            fields at the selected slices, each field is an array
            containing values of the corresponding type

        SIsNull: struct [1,1] - structure containing a nested
            array with is-null indicators for each CubeStruct cell content

        SIsValueNull: struct [1,1] - structure containing a
           logical array [] for each of the fields (true
           means that a corresponding cell doesn't not contain
              any value

::

    GETELLARRAY - returns array of matrix's ellipsoid according to
                  approxType

    Input:
     regular:
        self.
        approxType:char[1,] - type of approximation(internal/external)

    Output:
      apprEllMat:double[nDim1,..., nDimN] - array of array of ellipsoid's
               matrices

::

    GETJOINWITH - returns a result of INNER join of given relation with
                  another relation by the specified key fields

    LIMITATION: key fields by which the join is peformed are required to form
    a unique key in the given relation

    Input:
      regular:
          self:
          otherRel: smartdb.relations.ARelation[1,1]
          keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]

      properties:
          joinType: char[1,] - type of join, can be
              'inner' (DEFAULT)
              'leftOuter'

    Output:
      resRel: smartdb.relations.ARelation[1,1] - join result

::

    GETREACHTUBEANEPREFIX - return prefix of the reach tube

    Input:
      regular:
         self.

::

    GETREGTUBEANEPREFIX - return prefix of the reg tube

    Input:
      regular:
         self.


::

    ISEQUAL - compares current relation object with other relation object and
              returns true if they are equal, otherwise it returns false


    Usage: isEq=isEqual(self,otherObj)

    Input:
      regular:
        self: ARelation [1,1] - current relation object
        otherObj: ARelation [1,1] - other relation object

      properties:
        checkFieldOrder/isFieldOrderCheck: logical [1,1] - if true, then fields
            in compared relations must be in the same order, otherwise the
            order is not  important (false by default)
        checkTupleOrder: logical[1,1] -  if true, then the tuples in the
            compared relations are expected to be in the same order,
            otherwise the order is not important (false by default)

        maxTolerance: double [1,1] - maximum allowed tolerance

        compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            referenced from the meta data objects are also compared

        maxRelativeTolerance: double [1,1] - maximum allowed
        relative tolerance

    Output:
      isEq: logical[1,1] - result of comparison
      reportStr: char[1,] - report of comparsion

::

    PLOT - displays ellipsoidal tubes using the specified
      RelationDataPlotter

    Input:
      regular:
          self:
      optional:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
              object used for displaying ellipsoidal tubes
      properties:
          fGetColor: function_handle[1, 1] -
              function that specified colorVec for
              ellipsoidal tubes
          fGetAlpha: function_handle[1, 1] -
              function that specified transparency
              value for ellipsoidal tubes
          fGetLineWidth: function_handle[1, 1] -
              function that specified lineWidth for good curves
          fGetFill: function_handle[1, 1] - this
              property not used in this version
          colorFieldList: cell[nColorFields, ] of char[1, ] -
              list of parameters for color function
          alphaFieldList: cell[nAlphaFields, ] of char[1, ] -
              list of parameters for transparency function
          lineWidthFieldList: cell[nLineWidthFields, ]
              of char[1, ] - list of parameters for lineWidth
              function
          fillFieldList: cell[nIsFillFields, ] of char[1, ] -
              list of parameters for fill function
          plotSpecFieldList: cell[nPlotFields, ] of char[1, ] -
              defaul list of parameters. If for any function in
              properties not specified list of parameters,
              this one will be used

    Output:
      plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
              object used for displaying ellipsoidal tubes

::

    PLOTEXT - plots external approximation of ellTube.


    Usage:
          obj.plotExt() - plots external approximation of ellTube.
          obj.plotExt('Property',PropValue,...) - plots external approximation
                                                  of ellTube with setting
                                                  properties.

    Input:
      regular:
          obj:  EllTubeProj: EllTubeProj object
      optional:
          relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
          colorSpec: char[1,1] - color specification code, can be 'r','g',
                       etc (any code supported by built-in Matlab function).

      properties:

          fGetColor: function_handle[1, 1] -
              function that specified colorVec for
              ellipsoidal tubes
          fGetAlpha: function_handle[1, 1] -
              function that specified transparency
              value for ellipsoidal tubes
          fGetLineWidth: function_handle[1, 1] -
              function that specified lineWidth for good curves
          fGetFill: function_handle[1, 1] - this
              property not used in this version
          colorFieldList: cell[nColorFields, ] of char[1, ] -
              list of parameters for color function
          alphaFieldList: cell[nAlphaFields, ] of char[1, ] -
              list of parameters for transparency function
          lineWidthFieldList: cell[nLineWidthFields, ]
              of char[1, ] - list of parameters for lineWidth
              function
          fillFieldList: cell[nIsFillFields, ] of char[1, ] -
              list of parameters for fill function
          plotSpecFieldList: cell[nPlotFields, ] of char[1, ] -
              defaul list of parameters. If for any function in
              properties not specified list of parameters,
              this one will be used
          'showDiscrete':logical[1,1]  -
              if true, approximation in 3D will be filled in every time slice
          'nSpacePartPoins': double[1,1] -
              number of points in every time slice.
    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

::

    PLOTINT - plots internal approximation of ellTube.


    Usage:
          obj.plotInt() - plots internal approximation of ellTube.
          obj.plotInt('Property',PropValue,...) - plots internal approximation
                                                  of ellTube with setting
                                                  properties.

    Input:
      regular:
          obj:  EllTubeProj: EllTubeProj object
      optional:
          relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
          colorSpec: char[1,1] - color specification code, can be 'r','g',
                       etc (any code supported by built-in Matlab function).

      properties:

          fGetColor: function_handle[1, 1] -
              function that specified colorVec for
              ellipsoidal tubes
          fGetAlpha: function_handle[1, 1] -
              function that specified transparency
              value for ellipsoidal tubes
          fGetLineWidth: function_handle[1, 1] -
              function that specified lineWidth for good curves
          fGetFill: function_handle[1, 1] - this
              property not used in this version
          colorFieldList: cell[nColorFields, ] of char[1, ] -
              list of parameters for color function
          alphaFieldList: cell[nAlphaFields, ] of char[1, ] -
              list of parameters for transparency function
          lineWidthFieldList: cell[nLineWidthFields, ]
              of char[1, ] - list of parameters for lineWidth
              function
          fillFieldList: cell[nIsFillFields, ] of char[1, ] -
              list of parameters for fill function
          plotSpecFieldList: cell[nPlotFields, ] of char[1, ] -
              defaul list of parameters. If for any function in
              properties not specified list of parameters,
              this one will be used
          'showDiscrete':logical[1,1]  -
              if true, approximation in 3D will be filled in every time slice
          'nSpacePartPoins': double[1,1] -
              number of points in every time slice.
    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

::

::

::

::

gras.ellapx.smartdb.rels.EllUnionTube
-------------------------------------

::

    EllUionTube - class which keeps ellipsoidal tubes by the instant of
                  time

    Fields:
      QArray:cell[1, nElem] - Array of ellipsoid matrices
      aMat:cell[1, nElem] - Array of ellipsoid centers
      scaleFactor:double[1, 1] - Tube scale factor
      MArray:cell[1, nElem] - Array of regularization ellipsoid matrices
      dim :double[1, 1] - Dimensionality
      sTime:double[1, 1] - Time s
      approxSchemaName:cell[1,] - Name
      approxSchemaDescr:cell[1,] - Description
      approxType:gras.ellapx.enums.EApproxType - Type of approximation
                    (external, internal, not defined
      timeVec:cell[1, m] - Time vector
      calcPrecision:double[1, 1] - Calculation precision
      indSTime:double[1, 1]  - index of sTime within timeVec
      ltGoodDirMat:cell[1, nElem] - Good direction curve
      lsGoodDirVec:cell[1, nElem] - Good direction at time s
      ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve
      lsGoodDirNorm:double[1, 1] - Norm of good direction at time s
      xTouchCurveMat:cell[1, nElem] - Touch point curve for good
                                      direction
      xTouchOpCurveMat:cell[1, nElem] - Touch point curve for direction
                                        opposite to good direction
      xsTouchVec:cell[1, nElem]  - Touch point at time s
      xsTouchOpVec :cell[1, nElem] - Touch point at time s
      ellUnionTimeDirection:gras.ellapx.enums.EEllUnionTimeDirection -
                         Direction in time along which union is performed
      isLsTouch:logical[1, 1] - Indicates whether a touch takes place
                                along LS
      isLsTouchOp:logical[1, 1] - Indicates whether a touch takes place
                                  along LS opposite
      isLtTouchVec:cell[1, nElem] - Indicates whether a touch takes place
                                    along LT
      isLtTouchOpVec:cell[1, nElem] - Indicates whether a touch takes
                                      place along LT opposite
      timeTouchEndVec:cell[1, nElem] - Touch point curve for good
                                       direction
      timeTouchOpEndVec:cell[1, nElem] - Touch point curve for good
                                         direction

    TODO: correct description of the fields in
        gras.ellapx.smartdb.rels.EllUnionTube

See the description of the following methods in section
[secClassDescr:smartdb.relations.ATypifiedStaticRelation] for
smartdb.relations.ATypifiedStaticRelation:

::

    FROMELLTUBES - returns union of the ellipsoidal tubes on time

    Input:
       ellTubeRel: smartdb.relation.StaticRelation[1, 1]/
          smartdb.relation.DynamicRelation[1, 1] - relation
          object

    Output:
    ellUnionTubeRel: ellapx.smartdb.rel.EllUnionTube - union of the
                ellipsoidal tubes

::

    GETDATA - returns an indexed projection of CubeStruct object's content

    Input:
      regular:
          self: CubeStruct [1,1] - the object

      optional:

          subIndCVec:
            Case#1: numeric[1,]/numeric[,1]

            Case#2: cell[1,nDims]/cell[nDims,1] of double [nSubElem_i,1]
                  for i=1,...,nDims

              -array of indices of field value slices that are selected
              to be returned; if not given (default),
              no indexation is performed

            Note!: numeric components of subIndVec are allowed to contain
               zeros which are be treated as they were references to null
               data slices

          dimVec: numeric[1,nDims]/numeric[nDims,1] - vector of dimension
              numbers corresponding to subIndCVec

      properties:

          fieldNameList: char[1,]/cell[1,nFields] of char[1,]
              list of field names to return

          structNameList: char[1,]/cell[1,nStructs] of char[1,]
              list of internal structures to return (by default it
              is {SData, SIsNull, SIsValueNull}

          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values uniformly across all the cells,
                  default value is false

          nullReplacements: cell[1,nReplacedFields]  - list of null
              replacements for each of the fields

          nullReplacementFields: cell[1,nReplacedFields] - list of fields in
             which the nulls are to be replaced with the specified values,
             if not specified it is assumed that all fields are to be
             replaced

             NOTE!: all fields not listed in this parameter are replaced with
             the default values

          checkInputs: logical[1,1] - true by default (input arguments are
             checked for correctness

    Output:
      regular:
        SData: struct [1,1] - structure containing values of
            fields at the selected slices, each field is an array
            containing values of the corresponding type

        SIsNull: struct [1,1] - structure containing a nested
            array with is-null indicators for each CubeStruct cell content

        SIsValueNull: struct [1,1] - structure containing a
           logical array [] for each of the fields (true
           means that a corresponding cell doesn't not contain
              any value

::

    GETELLARRAY - returns array of matrix's ellipsoid according to
                  approxType

    Input:
     regular:
        self.
        approxType:char[1,] - type of approximation(internal/external)

    Output:
      apprEllMat:double[nDim1,..., nDimN] - array of array of ellipsoid's
               matrices

::

    GETJOINWITH - returns a result of INNER join of given relation with
                  another relation by the specified key fields

    LIMITATION: key fields by which the join is peformed are required to form
    a unique key in the given relation

    Input:
      regular:
          self:
          otherRel: smartdb.relations.ARelation[1,1]
          keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]

      properties:
          joinType: char[1,] - type of join, can be
              'inner' (DEFAULT)
              'leftOuter'

    Output:
      resRel: smartdb.relations.ARelation[1,1] - join result

::

::

::

    ISEQUAL - compares current relation object with other relation object and
              returns true if they are equal, otherwise it returns false


    Usage: isEq=isEqual(self,otherObj)

    Input:
      regular:
        self: ARelation [1,1] - current relation object
        otherObj: ARelation [1,1] - other relation object

      properties:
        checkFieldOrder/isFieldOrderCheck: logical [1,1] - if true, then fields
            in compared relations must be in the same order, otherwise the
            order is not  important (false by default)
        checkTupleOrder: logical[1,1] -  if true, then the tuples in the
            compared relations are expected to be in the same order,
            otherwise the order is not important (false by default)

        maxTolerance: double [1,1] - maximum allowed tolerance

        compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            referenced from the meta data objects are also compared

        maxRelativeTolerance: double [1,1] - maximum allowed
        relative tolerance

    Output:
      isEq: logical[1,1] - result of comparison
      reportStr: char[1,] - report of comparsion

::

    PROJECT - computes projection of the relation object onto given time
              dependent subspase
    Input:
      regular:
          self.
          projType: gras.ellapx.enums.EProjType[1,1] -
              type of the projection, can be
              'Static' and 'DynamicAlongGoodCurve'
          projMatList: cell[1,nProj] of double[nSpDim,nDim] - list of
              projection matrices, not necessarily orthogonal
       fGetProjMat: function_handle[1,1] - function which creates
          vector of the projection
                matrices
           Input:
            regular:
              projMat:double[nDim, mDim] - matrix of the projection at the
                instant of time
              timeVec:double[1, nDim] - time interval
            optional:
               sTime:double[1,1] - instant of time
           Output:
              projOrthMatArray:double[1, nSpDim] - vector of the projection
                matrices
              projOrthMatTransArray:double[nSpDim, 1] - transposed vector of
                the projection matrices
    Output:
       ellTubeProjRel: gras.ellapx.smartdb.rels.EllTubeProj[1, 1]/
           gras.ellapx.smartdb.rels.EllTubeUnionProj[1, 1] -
              projected ellipsoidal tube

       indProj2OrigVec:cell[nDim, 1] - index of the line number from
                which is obtained the projection

    Example:
      function example
       aMat = [0 1; 0 0]; bMat = eye(2);
       SUBounds = struct();
       SUBounds.center = {'sin(t)'; 'cos(t)'};
       SUBounds.shape = [9 0; 0 2];
       sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
       x0EllObj = ell_unitball(2);
       timeVec = [0 10];
       dirsMat = [1 0; 0 1]';
       rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
       ellTubeObj = rsObj.getEllTubeRel();
       unionEllTube = ...
        gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(ellTubeObj);
       projMatList = {[1 0;0 1]};
       projType = gras.ellapx.enums.EProjType.Static;
       statEllTubeProj = unionEllTube.project(projType,projMatList,...
          @fGetProjMat);
       plObj=smartdb.disp.RelationDataPlotter();
       statEllTubeProj.plot(plObj);
    end

    function [projOrthMatArray,projOrthMatTransArray]=fGetProjMat(projMat,...
        timeVec,varargin)
      nTimePoints=length(timeVec);
      projOrthMatArray=repmat(projMat,[1,1,nTimePoints]);
      projOrthMatTransArray=repmat(projMat.',[1,1,nTimePoints]);
     end

gras.ellapx.smartdb.rels.EllUnionTubeStaticProj
-----------------------------------------------

::

    EllUnionTubeStaticProj - class which keeps projection on static plane
                             union of ellipsoid tubes

    Fields:
      QArray:cell[1, nElem] - Array of ellipsoid matrices
      aMat:cell[1, nElem] - Array of ellipsoid centers
      scaleFactor:double[1, 1] - Tube scale factor
      MArray:cell[1, nElem] - Array of regularization ellipsoid matrices
      dim :double[1, 1] - Dimensionality
      sTime:double[1, 1] - Time s
      approxSchemaName:cell[1,] - Name
      approxSchemaDescr:cell[1,] - Description
      approxType:gras.ellapx.enums.EApproxType - Type of approximation
                    (external, internal, not defined
      timeVec:cell[1, m] - Time vector
      calcPrecision:double[1, 1] - Calculation precision
      indSTime:double[1, 1]  - index of sTime within timeVec
      ltGoodDirMat:cell[1, nElem] - Good direction curve
      lsGoodDirVec:cell[1, nElem] - Good direction at time s
      ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve
      lsGoodDirNorm:double[1, 1] - Norm of good direction at time s
      xTouchCurveMat:cell[1, nElem] - Touch point curve for good
                                      direction
      xTouchOpCurveMat:cell[1, nElem] - Touch point curve for direction
                                        opposite to good direction
      xsTouchVec:cell[1, nElem]  - Touch point at time s
      xsTouchOpVec :cell[1, nElem] - Touch point at time s
      projSTimeMat: cell[1, 1] - Projection matrix at time s
      projType:gras.ellapx.enums.EProjType - Projection type
      ltGoodDirNormOrigVec:cell[1, 1] - Norm of the original (not
                                        projected) good direction curve
      lsGoodDirNormOrig:double[1, 1] - Norm of the original (not
                                       projected)good direction at time s
      lsGoodDirOrigVec:cell[1, 1] - Original (not projected) good
                                    direction at time s
      ellUnionTimeDirection:gras.ellapx.enums.EEllUnionTimeDirection -
                         Direction in time along which union is performed
      isLsTouch:logical[1, 1] - Indicates whether a touch takes place
                                along LS
      isLsTouchOp:logical[1, 1] - Indicates whether a touch takes place
                                  along LS opposite
      isLtTouchVec:cell[1, nElem] - Indicates whether a touch takes place
                                    along LT
      isLtTouchOpVec:cell[1, nElem] - Indicates whether a touch takes
                                      place along LT opposite
      timeTouchEndVec:cell[1, nElem] - Touch point curve for good
                                       direction
      timeTouchOpEndVec:cell[1, nElem] - Touch point curve for good
                                         direction

      TODO: correct description of the fields in
        gras.ellapx.smartdb.rels.EllUnionTubeStaticProj

See the description of the following methods in section
[secClassDescr:smartdb.relations.ATypifiedStaticRelation] for
smartdb.relations.ATypifiedStaticRelation:

::

    FROMELLTUBES - returns union of the ellipsoidal tubes on time

    Input:
       ellTubeRel: smartdb.relation.StaticRelation[1, 1]/
          smartdb.relation.DynamicRelation[1, 1] - relation
          object

    Output:
    ellUnionTubeRel: ellapx.smartdb.rel.EllUnionTube - union of the
                ellipsoidal tubes

::

    GETDATA - returns an indexed projection of CubeStruct object's content

    Input:
      regular:
          self: CubeStruct [1,1] - the object

      optional:

          subIndCVec:
            Case#1: numeric[1,]/numeric[,1]

            Case#2: cell[1,nDims]/cell[nDims,1] of double [nSubElem_i,1]
                  for i=1,...,nDims

              -array of indices of field value slices that are selected
              to be returned; if not given (default),
              no indexation is performed

            Note!: numeric components of subIndVec are allowed to contain
               zeros which are be treated as they were references to null
               data slices

          dimVec: numeric[1,nDims]/numeric[nDims,1] - vector of dimension
              numbers corresponding to subIndCVec

      properties:

          fieldNameList: char[1,]/cell[1,nFields] of char[1,]
              list of field names to return

          structNameList: char[1,]/cell[1,nStructs] of char[1,]
              list of internal structures to return (by default it
              is {SData, SIsNull, SIsValueNull}

          replaceNull: logical[1,1] if true, null values are replaced with
              certain default values uniformly across all the cells,
                  default value is false

          nullReplacements: cell[1,nReplacedFields]  - list of null
              replacements for each of the fields

          nullReplacementFields: cell[1,nReplacedFields] - list of fields in
             which the nulls are to be replaced with the specified values,
             if not specified it is assumed that all fields are to be
             replaced

             NOTE!: all fields not listed in this parameter are replaced with
             the default values

          checkInputs: logical[1,1] - true by default (input arguments are
             checked for correctness

    Output:
      regular:
        SData: struct [1,1] - structure containing values of
            fields at the selected slices, each field is an array
            containing values of the corresponding type

        SIsNull: struct [1,1] - structure containing a nested
            array with is-null indicators for each CubeStruct cell content

        SIsValueNull: struct [1,1] - structure containing a
           logical array [] for each of the fields (true
           means that a corresponding cell doesn't not contain
              any value

::

    GETELLARRAY - returns array of matrix's ellipsoid according to
                  approxType

    Input:
     regular:
        self.
        approxType:char[1,] - type of approximation(internal/external)

    Output:
      apprEllMat:double[nDim1,..., nDimN] - array of array of ellipsoid's
               matrices

::

    GETJOINWITH - returns a result of INNER join of given relation with
                  another relation by the specified key fields

    LIMITATION: key fields by which the join is peformed are required to form
    a unique key in the given relation

    Input:
      regular:
          self:
          otherRel: smartdb.relations.ARelation[1,1]
          keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]

      properties:
          joinType: char[1,] - type of join, can be
              'inner' (DEFAULT)
              'leftOuter'

    Output:
      resRel: smartdb.relations.ARelation[1,1] - join result

::

    GETREACHTUBEANEPREFIX - return prefix of the reach tube

    Input:
      regular:
         self.

::

    GETREGTUBEANEPREFIX - return prefix of the reg tube

    Input:
      regular:
         self.

::

    ISEQUAL - compares current relation object with other relation object and
              returns true if they are equal, otherwise it returns false


    Usage: isEq=isEqual(self,otherObj)

    Input:
      regular:
        self: ARelation [1,1] - current relation object
        otherObj: ARelation [1,1] - other relation object

      properties:
        checkFieldOrder/isFieldOrderCheck: logical [1,1] - if true, then fields
            in compared relations must be in the same order, otherwise the
            order is not  important (false by default)
        checkTupleOrder: logical[1,1] -  if true, then the tuples in the
            compared relations are expected to be in the same order,
            otherwise the order is not important (false by default)

        maxTolerance: double [1,1] - maximum allowed tolerance

        compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            referenced from the meta data objects are also compared

        maxRelativeTolerance: double [1,1] - maximum allowed
        relative tolerance

    Output:
      isEq: logical[1,1] - result of comparison
      reportStr: char[1,] - report of comparsion

::

    PLOT - displays ellipsoidal tubes using the specified
      RelationDataPlotter

    Input:
      regular:
          self:
      optional:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
              object used for displaying ellipsoidal tubes
      properties:
          fGetColor: function_handle[1, 1] -
              function that specified colorVec for
              ellipsoidal tubes
          fGetAlpha: function_handle[1, 1] -
              function that specified transparency
              value for ellipsoidal tubes
          fGetLineWidth: function_handle[1, 1] -
              function that specified lineWidth for good curves
          fGetFill: function_handle[1, 1] - this
              property not used in this version
          colorFieldList: cell[nColorFields, ] of char[1, ] -
              list of parameters for color function
          alphaFieldList: cell[nAlphaFields, ] of char[1, ] -
              list of parameters for transparency function
          lineWidthFieldList: cell[nLineWidthFields, ]
              of char[1, ] - list of parameters for lineWidth
              function
          fillFieldList: cell[nIsFillFields, ] of char[1, ] -
              list of parameters for fill function
          plotSpecFieldList: cell[nPlotFields, ] of char[1, ] -
              defaul list of parameters. If for any function in
              properties not specified list of parameters,
              this one will be used

    Output:
      plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
              object used for displaying ellipsoidal tubes

::

    PLOTEXT - plots external approximation of ellTube.


    Usage:
          obj.plotExt() - plots external approximation of ellTube.
          obj.plotExt('Property',PropValue,...) - plots external approximation
                                                  of ellTube with setting
                                                  properties.

    Input:
      regular:
          obj:  EllTubeProj: EllTubeProj object
      optional:
          relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
          colorSpec: char[1,1] - color specification code, can be 'r','g',
                       etc (any code supported by built-in Matlab function).

      properties:

          fGetColor: function_handle[1, 1] -
              function that specified colorVec for
              ellipsoidal tubes
          fGetAlpha: function_handle[1, 1] -
              function that specified transparency
              value for ellipsoidal tubes
          fGetLineWidth: function_handle[1, 1] -
              function that specified lineWidth for good curves
          fGetFill: function_handle[1, 1] - this
              property not used in this version
          colorFieldList: cell[nColorFields, ] of char[1, ] -
              list of parameters for color function
          alphaFieldList: cell[nAlphaFields, ] of char[1, ] -
              list of parameters for transparency function
          lineWidthFieldList: cell[nLineWidthFields, ]
              of char[1, ] - list of parameters for lineWidth
              function
          fillFieldList: cell[nIsFillFields, ] of char[1, ] -
              list of parameters for fill function
          plotSpecFieldList: cell[nPlotFields, ] of char[1, ] -
              defaul list of parameters. If for any function in
              properties not specified list of parameters,
              this one will be used
          'showDiscrete':logical[1,1]  -
              if true, approximation in 3D will be filled in every time slice
          'nSpacePartPoins': double[1,1] -
              number of points in every time slice.
    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

::

    PLOTINT - plots internal approximation of ellTube.


    Usage:
          obj.plotInt() - plots internal approximation of ellTube.
          obj.plotInt('Property',PropValue,...) - plots internal approximation
                                                  of ellTube with setting
                                                  properties.

    Input:
      regular:
          obj:  EllTubeProj: EllTubeProj object
      optional:
          relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
          colorSpec: char[1,1] - color specification code, can be 'r','g',
                       etc (any code supported by built-in Matlab function).

      properties:

          fGetColor: function_handle[1, 1] -
              function that specified colorVec for
              ellipsoidal tubes
          fGetAlpha: function_handle[1, 1] -
              function that specified transparency
              value for ellipsoidal tubes
          fGetLineWidth: function_handle[1, 1] -
              function that specified lineWidth for good curves
          fGetFill: function_handle[1, 1] - this
              property not used in this version
          colorFieldList: cell[nColorFields, ] of char[1, ] -
              list of parameters for color function
          alphaFieldList: cell[nAlphaFields, ] of char[1, ] -
              list of parameters for transparency function
          lineWidthFieldList: cell[nLineWidthFields, ]
              of char[1, ] - list of parameters for lineWidth
              function
          fillFieldList: cell[nIsFillFields, ] of char[1, ] -
              list of parameters for fill function
          plotSpecFieldList: cell[nPlotFields, ] of char[1, ] -
              defaul list of parameters. If for any function in
              properties not specified list of parameters,
              this one will be used
          'showDiscrete':logical[1,1]  -
              if true, approximation in 3D will be filled in every time slice
          'nSpacePartPoins': double[1,1] -
              number of points in every time slice.
    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

elltool.reach.AReach
--------------------

::

    CUT - extracts the piece of reach tube from given start time to given
          end time. Given reach set self, find states that are reachable
          within time interval specified by cutTimeVec. If cutTimeVec
          is a scalar, then reach set at given time is returned.

    Input:
      regular:
          self.

       cutTimeVec: double[1, 2]/double[1, 1] - time interval to cut.

    Output:
      cutObj: elltool.reach.IReach[1, 1] - reach set resulting from the CUT
            operation.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      cutObj = rsObj.cut([3 5]);
      dRsObj = elltool.reach.ReachDiscrete(dtsys, x0EllObj, dirsMat, timeVec);
      dCutObj = dRsObj.cut([3 5]);

::


    DIMENSION - returns array of dimensions of given reach set array.

    Input:
      regular:
          self - multidimensional array of
                 ReachContinuous/ReachDiscrete objects

    Output:
      rSdimArr: double[nDim1, nDim2,...] - array of reach set dimensions.
      sSdimArr: double[nDim1, nDim2,...] - array of state space dimensions.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObjArr = rsObj.repMat(1,2);
      [rSdim sSdim] = rsObj.dimension()

      rSdim =

               2


      sSdim =

               2

      [rSdim sSdim] = rsObjArr.dimension()

      rSdim =
              [ 2  2 ]

      sSdim =
              [ 2  2 ]

::


    DISPLAY - displays the reach set object.

    Input:
      regular:
          self.

    Output:
      None.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObj.display()

      rsObj =
      Reach set of the continuous-time linear system in R^2 in the time...
           interval [0, 10].

      Initial set at time t0 = 0:
      Ellipsoid with parameters
      Center:
           0
           0

      Shape Matrix:
           1     0
           0     1

      Number of external approximations: 2
      Number of internal approximations: 2

::


    EVOLVE - computes further evolution in time of the
             already existing reach set.

    Input:
      regular:
          self.

          newEndTime: double[1, 1] - new end time.

      optional:
          linSys: elltool.linsys.LinSys[1, 1] - new linear system.

    Output:
      newReachObj: reach[1, 1] - reach set on time  interval
            [oldT0 newEndTime].

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      dRsObj = elltool.reach.ReachDiscrete(dsys, x0EllObj, dirsMat, timeVec);
      newRsObj = rsObj.evolve(12);
      newDRsObj = dRsObj.evolve(11);

::

    GETABSTOL - gives the array of absTol for all elements
      in rsArr

    Input:
      regular:
          rsArr: elltool.reach.AReach[nDim1, nDim2, ...] -
              multidimension array of reach sets
      optional:
          fAbsTolFun: function_handle[1,1] - function that is
              applied to the absTolArr. The default is @min.

    Output:
      regular:
          absTolArr: double [absTol1, absTol2, ...] - return
              absTol for each element in rsArr
      optional:
          absTol: double[1,1] - return result of work fAbsTolFun
              with the absTolArr

    Usage:
      use [~,absTol] = rsArr.getAbsTol() if you want get only
          absTol,
      use [absTolArr,absTol] = rsArr.getAbsTol() if you want
          get absTolArr and absTol,
      use absTolArr = rsArr.getAbsTol() if you want get only
          absTolArr

::

    Input:
      regular:
          self:
      properties:
          l0Mat: double[nDims,nDirs] - matrix of good
              directions at time s
          isIntExtApxVec: logical[1,2] - two element vector with the
             first element corresponding to internal approximations
            and second - to external ones. An element equal to
             false means that the corresponding approximation type
             is filtered out. Default value is [true,true]
    Example:
        aMat = [0 1; 0 0]; bMat = eye(2);
        SUBounds = struct();
        SUBounds.center = {'sin(t)'; 'cos(t)'};
        SUBounds.shape = [9 0; 0 2];
        sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        x0EllObj = ell_unitball(2);
        timeVec = [0 10];
        dirsMat = [1 0; 0 1; 1 1;1 2]';
        rsObj = elltool.reach.ReachContinuous(sys, x0EllObj,...
          dirsMat, timeVec);

        copyRsObj = rsObj.getCopy()

        Reach set of the continuous-time linear system in R^2 in
          the time interval [0, 10].

        Initial set at time k0 = 0:
        Ellipsoid with parameters
        Center:
             0
             0

        Shape Matrix:
             1     0
             0     1

        Number of external approximations: 4
        Number of internal approximations: 4

        copyRsObj = rsObj.getCopy('l0Mat',[0;1],'approxType',...
          [true,false])

        Reach set of the continuous-time linear system in R^2 in
          the time interval [0, 10].

        Initial set at time k0 = 0:
        Ellipsoid with parameters
        Center:
             0
             0

        Shape Matrix:
             1     0
             0     1

        Number of external approximations: 1
        Number of internal approximations: 1

::

    GET_EASCALEFACTOR - return the scale factor for external approximation
                        of reach tube

    Input:
      regular:
          self.

    Output:
      regular:
          eaScaleFactor: double[1, 1] - scale factor.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [10 0];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObj.getEaScaleFactor()

      ans =

          1.0200

::

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObj.getEllTubeRel();

::

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      getEllTubeUnionRel(rsObj);

::

    GET_IASCALEFACTOR - return the scale factor for internal approximation
                        of reach tube

    Input:
      regular:
          self.

    Output:
      regular:
          iaScaleFactor: double[1, 1] - scale factor.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [10 0];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObj.getIaScaleFactor()

      ans =

          1.0200

::

    GETINITIALSET - return the initial set for linear system, which is solved
                    for building reach tube.

    Input:
      regular:
          self.

    Output:
      regular:
          x0Ell: ellipsoid[1, 1] - ellipsoid x0, which was initial set for
              linear system.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [10 0];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      x0Ell = rsObj.getInitialSet()

      x0Ell =

      Center:
           0
           0

      Shape Matrix:
           1     0
           0     1

      Nondegenerate ellipsoid in R^2.

::

    GETNPLOT2DPOINTS - gives array  the same size as rsArr of
      value of nPlot2dPoints property for each element in rsArr -
      array of reach sets

    Input:
      regular:
        rsArr:elltool.reach.AReach[nDims1,nDims2,...] - reach
          set array

    Output:
      nPlot2dPointsArr:double[nDims1,nDims2,...] - array of
          values of nTimeGridPoints property for each reach set
          in rsArr

::

    GETNPLOT3DPOINTS - gives array  the same size as rsArr of
      value of nPlot3dPoints property for each element in rsArr
      array of reach sets

    Input:
      regular:
          rsArr:reach[nDims1,nDims2,...] - reach set array

    Output:
      nPlot3dPointsArr:double[nDims1,nDims2,...]- array of values
          of nPlot3dPoints property for each reach set in rsArr

::

    GETNTIMEGRIDPOINTS - gives array  the same size as rsArr of
      value of nTimeGridPoints property for each element in rsArr
      array of reach sets

    Input:
      regular:
          rsArr: elltool.reach.AReach [nDims1,nDims2,...] - reach
              set array

    Output:
      nTimeGridPointsArr: double[nDims1,nDims2,...]- array of
          values of nTimeGridPoints property for each reach set
          in rsArr

::

    GETRELTOL - gives the array of relTol for all elements in
    ellArr

    Input:
      regular:
          rsArr: elltool.reach.AReach[nDim1,nDim2, ...] -
              multidimension array of reach sets.
      optional
          fRelTolFun: function_handle[1,1] - function that is
              applied to the relTolArr. The default is @min.

    Output:
      regular:
          relTolArr: double [relTol1, relTol2, ...] - return
              relTol for each element in rsArr.
      optional:
          relTol: double[1,1] - return result of work fRelTolFun
              with the relTolArr

    Usage:
      use [~,relTol] = rsArr.getRelTol() if you want get only
          relTol,
      use [relTolArr,relTol] = rsArr.getRelTol() if you want get
          relTolArr and relTol,
      use relTolArr = rsArr.getRelTol() if you want get only
          relTolArr

::


    GET_CENTER - returns the trajectory of the center of the reach set.

    Input:
      regular:
          self.

    Output:
      trCenterMat: double[nDim, nPoints] - array of points that form the
          trajectory of the reach set center, where nDim is reach set
          dimentsion, nPoints - number of points in time grid.

      timeVec: double[1, nPoints] - array of time values.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      [trCenterMat timeVec] = rsObj.get_center();

::


    GET_DIRECTIONS - returns the values of direction vectors for time grid
                     values.

    Input:
      regular:
          self.

    Output:
      directionsCVec: cell[1, nPoints] of double [nDim, nDir] - array of
          cells, where each cell is a sequence of direction vector values
          that correspond to the time values of the grid, where nPoints is
          number of points in time grid.

      timeVec: double[1, nPoints] - array of time values.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      [directionsCVec timeVec] = rsObj.get_directions();

::


    GET_EA - returns array of ellipsoid objects representing external
             approximation of the reach  tube.

    Input:
      regular:
          self.

    Output:
      eaEllMat: ellipsoid[nAppr, nPoints] - array of ellipsoids, where nAppr
          is the number of approximations, nPoints is number of points in time
          grid.

       timeVec: double[1, nPoints] - array of time values.
       l0Mat: double[nDirs,nDims] - matrix of good directions at t0

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      [eaEllMat timeVec] = rsObj.get_ea();

      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
      [eaEllMat timeVec] = dRsObj.get_ea();

::

    GET_GOODCURVES - returns the 'good curve' trajectories of the reach set.

    Input:
      regular:
          self.

    Output:
      goodCurvesCVec: cell[1, nPoints] of double [x, y] - array of cells,
          where each cell is array of points that form a 'good curve'.

      timeVec: double[1, nPoints] - array of time values.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      [goodCurvesCVec timeVec] = rsObj.get_goodcurves();

      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
      [goodCurvesCVec timeVec] = dRsObj.get_goodcurves();

::


    GET_IA - returns array of ellipsoid objects representing internal
             approximation of the  reach tube.

    Input:
      regular:
          self.

    Output:
      iaEllMat: ellipsoid[nAppr, nPoints] - array of ellipsoids, where nAppr
          is the number of approximations, nPoints is number of points in time
          grid.

      timeVec: double[1, nPoints] - array of time values.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      [iaEllMat timeVec] = rsObj.get_ia();

::


    GET_SYSTEM - returns the linear system for which the reach set is
                 computed.

    Input:
      regular:
          self.

    Output:
      linSys: elltool.linsys.LinSys[1, 1] - linear system object.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      linSys = rsObj.get_system()

      self =
      A:
           0     1
           0     0


      B:
           1     0
           0     1


      Control bounds:
         2-dimensional ellipsoid with center
          'sin(t)'
          'cos(t)'

         and shape matrix
           9     0
           0     2


      C:
           1     0
           0     1

      2-input, 2-output continuous-time linear time-invariant system of
              dimension 2:
      dx/dt  =  A x(t)  +  B u(t)
       y(t)  =  C x(t)

      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
      dRsObj.get_system();

::

    INTERSECT - checks if its external (s = 'e'), or internal (s = 'i')
                approximation intersects with given ellipsoid, hyperplane
                or polytop.

    Input:
      regular:
          self.

          intersectObj: ellipsoid[1, 1]/hyperplane[1,1]/polytop[1, 1].

          approxTypeChar: char[1, 1] - 'e' (default) - external approximation,
                                       'i' - internal approximation.

    Output:
      isEmptyIntersect: logical[1, 1] -  true - if intersection is nonempty,
                                         false - otherwise.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      ellObj = ellipsoid([0; 0], 2*eye(2));
      isEmptyIntersect = intersect(rsObj, ellObj)

      isEmptyIntersect =

                      1

::


    ISEMPTY - checks if given reach set array is an array of empty objects.

    Input:
      regular:
          self - multidimensional array of
                 ReachContinuous/ReachDiscrete objects

    Output:
      isEmptyArr: logical[nDim1, nDim2, nDim3,...] -
                  isEmpty(iDim1, iDim2, iDim3,...) = true - if self(iDim1, iDim2, iDim3,...) is empty,
                                                   = false - otherwise.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
      rsObjArr = rsObj.repMat(1,2);
      dRsObjArr = dRsObj.repMat(1,2);
      dRsObj.isEmpty();
      rsObj.isEmpty()

      ans =

           0

      dRsObjArr.isEmpty();
      rsObjArr.isEmpty()

      ans =
          [ 0  0 ]

::

    ISEQUAL - checks for equality given reach set objects

    Input:
      regular:
          self.
          reachObj:
              elltool.reach.AReach[1, 1] - each set object, which
               compare with self.
      optional:
          indTupleVec: double[1,] - tube numbers that are
              compared
          approxType: gras.ellapx.enums.EApproxType[1, 1] -  type of
              approximation, which will be compared.
      properties:
          notComparedFieldList: cell[1,k] - fields not to compare
              in tubes. Default: LT_GOOD_DIR_*, LS_GOOD_DIR_*,
              IND_S_TIME, S_TIME, TIME_VEC
          areTimeBoundsCompared: logical[1,1] - treat tubes with
              different timebounds as inequal if 'true'.
              Default: false

    Output:
      regular:
          ISEQUAL: logical[1, 1] - true - if reach set objects are equal.
              false - otherwise.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      copyRsObj = rsObj.getCopy();
      isEqual = isEqual(rsObj, copyRsObj)

      isEqual =

              1

::

    ISBACKWARD - checks if given reach set object was obtained by solving
                 the system in reverse time.

    Input:
      regular:
          self.

    Output:
      regular:
          isBackward: logical[1, 1] - true - if self was obtained by solving
              in reverse time, false - otherwise.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [10 0];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObj.isbackward()

      ans =

           1

::

    ISCUT - checks if given array of reach set objects is a cut of
            another reach set object's array.

    Input:
      regular:
          self - multidimensional array of
                 ReachContinuous/ReachDiscrete objects

    Output:
      isCutArr: logical[nDim1, nDim2, nDim3 ...] -
                isCut(iDim1, iDim2, iDim3,..) = true - if self(iDim1, iDim2, iDim3,...) is a cut of the reach set,
                                              = false - otherwise.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
      cutObj = rsObj.cut([3 5]);
      cutObjArr = cutObj.repMat(2,3,4);
      iscut(cutObj);
      iscut(cutObjArr);
      cutObj = dRsObj.cut([4 8]);
      cutObjArr = cutObj.repMat(1,2);
      iscut(cutObjArr);
      iscut(cutObj);

::


    ISPROJECTION - checks if given array of reach set objects is projections.

    Input:
      regular:
          self - multidimensional array of
                 ReachContinuous/ReachDiscrete objects

    Output:
      isProjArr: logical[nDim1, nDim2, nDim3, ...] -
                 isProj(iDim1, iDim2, iDim3,...) = true - if self(iDim1, iDim2, iDim3,...) is projection,
                                                 = false - otherwise.


    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      dRsObj = elltool.reach.ReachRiscrete(dsys, x0EllObj, dirsMat, timeVec);
      projMat = eye(2);
      projObj = rsObj.projection(projMat);
      projObjArr = projObj.repMat(3,2,2);
      isprojection(projObj);
      isprojection(projObjArr);
      projObj = dRsObj.projection(projMat);
      projObjArr = projObj.repMat(1,2);
      isprojection(projObj);
      isprojection(projObjArr);

::

    plotByEa - plots external approximation of reach tube.


    Usage:
          plotByEa(self,'Property',PropValue,...)
          - plots external approximation of reach tube
               with  setting properties

    Input:
      regular:
          self: - reach tube

      optional:
          relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
          charColor: char[1,1]  - color specification code, can be 'r','g',
                         etc (any code supported by built-in Matlab function).
      properties:

          'fill': logical[1,1]  -
                  if 1, tube in 2D will be filled with color.
                  Default value is true.
          'lineWidth': double[1,1]  -
                       line width for 2D plots. Default value is 2.
          'color': double[1,3] -
                   sets default colors in the form [x y z].
                      Default value is [0 0 1].
          'shade': double[1,1]  -
         level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
                   Default value is 0.3.

    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

::

    plotByIa - plots internal approximation of reach tube.


    Usage:
          plotByIa(self,'Property',PropValue,...)
          - plots internal approximation of reach tube
               with  setting properties

    Input:
      regular:
          self: - reach tube

      optional:
          relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
          charColor: char[1,1]  - color specification code, can be 'r','g',
                         etc (any code supported by built-in Matlab function).
      properties:

          'fill': logical[1,1]  -
                  if 1, tube in 2D will be filled with color.
                  Default value is true.
          'lineWidth': double[1,1]  -
                       line width for 2D plots. Default value is 2.
          'color': double[1,3] -
                   sets default colors in the form [x y z].
                      Default value is [0 1 0].
          'shade': double[1,1]  -
         level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
                   Default value is 0.1.

    Output:
      regular:
          plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
          data plotter object.

::


    PLOT_EA - plots external approximations of 2D and 3D reach sets.

    Input:
      regular:
          self.

      optional:
          colorSpec: char[1, 1] - set color to plot in following way:
                                 'r' - red color,
                                 'g' - green color,
                                 'b' - blue color,
                                 'y' - yellow color,
                                 'c' - cyan color,
                                 'm' - magenta color,
                                 'w' - white color.

          OptStruct: struct[1, 1] with fields:
              color: double[1, 3] - sets color of the picture in the form
                    [x y z].
              width: double[1, 1] - sets line width for 2D plots.
              shade: double[1, 1] in [0; 1] interval - sets transparency level
                    (0 - transparent, 1 - opaque).
               fill: double[1, 1] - if set to 1, reach set will be filled with
                     color.

    Output:
      None.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObj.plotEa();
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);

      dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
      dRsObj.plotEa();

::


    PLOTIA - plots internal approximations of 2D and 3D reach sets.

    Input:
      regular:
          self.

      optional:
          colorSpec: char[1, 1] - set color to plot in following way:
                                 'r' - red color,
                                 'g' - green color,
                                 'b' - blue color,
                                 'y' - yellow color,
                                 'c' - cyan color,
                                 'm' - magenta color,
                                 'w' - white color.

          OptStruct: struct[1, 1] with fields:
              color: double[1, 3] - sets color of the picture in the form
                    [x y z].
              width: double[1, 1] - sets line width for 2D plots.
              shade: double[1, 1] in [0; 1] interval - sets transparency level
                    (0 - transparent, 1 - opaque).
               fill: double[1, 1] - if set to 1, reach set will be filled with
                    color.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObj.plotIa();
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      dRsObj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, timeVec);
      dRsObj.plotIa();


::


    REFINE - adds new approximations computed for the specified directions
             to the given reach set or to the projection of reach set.

    Input:
      regular:
          self.
          l0Mat: double[nDim, nDir] - matrix of directions for new
              approximation

    Output:
      regular:
          reachObj: reach[1,1] - refine reach set for the directions
              specified in l0Mat

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      newDirsMat = [1; -1];
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
      rsObj = rsObj.refine(newDirsMat);

::


    REPMAT - is analogous to built-in repmat function with one exception - it
             copies the objects, not just the handles

    Input:
      regular:
          self.

    Output:
      Array of given ReachContinuous/ReachDiscrete object's copies.

     Example:
       aMat = [0 1; 0 0]; bMat = eye(2);
       SUBounds = struct();
       SUBounds.center = {'sin(t)'; 'cos(t)'};
       SUBounds.shape = [9 0; 0 2];
       sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
       x0EllObj = ell_unitball(2);
       timeVec = [0 10];
       dirsMat = [1 0; 0 1]';
       reachObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
       reachObjArr = reachObj.repMat(1,2);

       reachObjArr = 1x2 array of ReachContinuous objects

elltool.reach.ReachContinuous
-----------------------------

::

    ReachContinuous - computes reach set approximation of the continuous
        linear system for the given time interval.
    Input:
        regular:
          linSys: elltool.linsys.LinSys object -
              given linear system .
          x0Ell: ellipsoid[1, 1] - ellipsoidal set of
              initial conditions.
          l0Mat: double[nRows, nColumns] - initial good directions
              matrix.
          timeVec: double[1, 2] - time interval.

        properties:
          isRegEnabled: logical[1, 1] - if it is 'true' constructor
              is allowed to use regularization.
          isJustCheck: logical[1, 1] - if it is 'true' constructor
              just check if square matrices are degenerate, if it is
              'false' all degenerate matrices will be regularized.
          regTol: double[1, 1] - regularization precision.

    Output:
      regular:
        self - reach set object.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);

See the description of the following methods in section
[secClassDescr:elltool.reach.AReach] for elltool.reach.AReach:

elltool.reach.ReachDiscrete
---------------------------

::

    ReachDiscrete - computes reach set approximation of the discrete linear
                    system for the given time interval.


    Input:
        linSys: elltool.linsys.LinSys object - given linear system
        x0Ell: ellipsoid[1, 1] - ellipsoidal set of initial conditions
        l0Mat: double[nRows, nColumns] - initial good directions
              matrix.
        timeVec: double[1, 2] - time interval
        properties:
          isRegEnabled: logical[1, 1] - if it is 'true' constructor
              is allowed to use regularization.
          isJustCheck: logical[1, 1] - if it is 'true' constructor
              just check if square matrices are degenerate, if it is
              'false' all degenerate matrices will be regularized.
          regTol: double[1, 1] - regularization precision.
          minmax: logical[1, 1] - field, which:
              = 1 compute minmax reach set,
              = 0 (default) compute maxmin reach set.

    Output:
      regular:
        self - reach set object.
    Example:
      adMat = [0 1; -1 -0.5];
      bdMat = [0; 1];
      udBoundsEllObj  = ellipsoid(1);
      dtsys = elltool.linsys.LinSysDiscrete(adMat, bdMat, udBoundsEllObj);
      x0EllObj = ell_unitball(2);
      timeVec = [0 10];
      dirsMat = [1 0; 0 1]';
      dRsObj = elltool.reach.ReachDiscrete(dtsys, x0EllObj, dirsMat, timeVec);

See the description of the following methods in section
[secClassDescr:elltool.reach.AReach] for elltool.reach.AReach:

elltool.reach.ReachFactory
--------------------------

::

    Example:
      import elltool.reach.ReachFactory;
      crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
      crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
      rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);

::

    Example:
      import elltool.reach.ReachFactory;
      crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
      crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
      rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
      reachObj = rsObj.createInstance();

::

    Example:
      import elltool.reach.ReachFactory;
      crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
      crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
      rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
      dim = rsObj.getDim();

::

    Example:
      import elltool.reach.ReachFactory;
      crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
      crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
      rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
      l0Mat = rsObj.getL0Mat()

      l0Mat =

           1     0
           0     1

::

    Example:
      import elltool.reach.ReachFactory;
      crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
      crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
      rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
      linSys = rsObj.getLinSys();

::

    Example:
      import elltool.reach.ReachFactory;
      crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
      crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
      rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
      tVec = rsObj.getTVec()

      tVec =

           0    10

::

    Example:
      import elltool.reach.ReachFactory;
      crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
      crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
      rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
      X0Ell = rsObj.getX0Ell()

      X0Ell =

      Center:
           0
           0

      Shape Matrix:
          0.0100         0
               0    0.0100

      Nondegenerate ellipsoid in R^2.

elltool.linsys.ALinSys
----------------------

::

    ALinSys - constructor abstract class of linear system.

    Continuous-time linear system:
              dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  C(t) v(t)

    Discrete-time linear system:
              x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  C[k] v[k]

    Input:
      regular:
          atInpMat: double[nDim, nDim]/cell[nDim, nDim] - matrix A.

          btInpMat: double[nDim, kDim]/cell[nDim, kDim] - matrix B.

          uBoundsEll: ellipsoid[1, 1]/struct[1, 1] - control bounds
              ellipsoid.

          ctInpMat: double[nDim, lDim]/cell[nDim, lDim] - matrix G.

          vBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds
              ellipsoid.
          discrFlag: char[1, 1] - if discrFlag set:
              'd' - to discrete-time linSys
              not 'd' - to continuous-time linSys.

    Output:
      self: elltool.linsys.ALinSys[1, 1] -
          linear system.

::


    DIMENSION - returns dimensions of state, input, output and disturbance
                spaces.
    Input:
      regular:
          self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of
                linear systems.

    Output:
      stateDimArr: double[nDims1, nDims2,...] - array of state space
          dimensions.

      inpDimArr: double[nDims1, nDims2,...] - array of input dimensions.

      distDimArr: double[nDims1, nDims2,...] - array of disturbance
            dimensions.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      [stateDimArr, inpDimArr, outDimArr, distDimArr] = sys.dimension()

      stateDimArr =

           2


      inpDimArr =

           2



      distDimArr =

           0

      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      dsys.dimension();

::

    DISPLAY - displays the details of linear system object.

    Input:
      regular:
          self: elltool.linsys.ALinSys[1, 1] - linear system.

    Output:
      None.

::


    GETABSTOL - gives array the same size as linsysArr with values of absTol
                properties for each hyperplane in hplaneArr.


    Input:
      regular:
          self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of linear
                systems.

    Output:
      absTolArr: double[nDims1, nDims2,...] - array of absTol properties for
          linear systems in self.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      sys.getAbsTol();
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      dsys.getAbsTol();

::


    Input:
      regular:
          self: elltool.linsys.ILinSys[1, 1] - linear system.

    Output:
      aMat: double[aMatDim, aMatDim]/cell[nDim, nDim] - matrix A.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      aMat = dsys.getAtMat();

::


    Input:
      regular:
          self: elltool.linsys.ILinSys[1, 1] - linear system.

    Output:
      bMat: double[bMatDim, bMatDim]/cell[bMatDim, bMatDim] - matrix B.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      bMat = dsys.getBtMat();

::


    GETCOPY - gives array the same size as linsysArr with with copies of
              elements of self.

    Input:
      regular:
          self: elltool.linsys.ALinSys[nDims1, nDims2,...] - an array of
                linear systems.

    Output:
      copyLinSysArr: elltool.linsys.LinSys[nDims1, nDims2,...] -  an array of
         copies of elements of self.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      newSys = sys.getCopy();
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      newDSys = dsys.getCopy();

::


    Input:
      regular:
          self: elltool.linsys.ILinSys[1, 1] - linear system.

    Output:
      cMat: double[cMatDim, cMatDim]/cell[cMatDim, cMatDim] - matrix C.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      gMat = sys.getCtMat();

::


    Input:
      regular:
          self: elltool.linsys.ILinSys[1, 1] - linear system.

    Output:
      distEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds ellipsoid.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      distEll = sys.getDistBoundsEll();

::


    Input:
      regular:
          self: elltool.linsys.ILinSys[1, 1] - linear system.

    Output:
      uEll: ellipsoid[1, 1]/struct[1, 1] - control bounds ellipsoid.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      uEll = dsys.getUBoundsEll();

::

    HASDISTURBANCE - returns true if system has disturbance

    Input:
      regular:
          self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of
                linear systems.
      optional:
          isMeaningful: logical[1,1] - if true(default), treat constant
                        disturbance vector as absence of disturbance

    Output:
      isDisturbanceArr: logical[nDims1, nDims2,...] - array such that it's
          element at each position is true if corresponding linear system
          has disturbance, and false otherwise.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      sys.hasDisturbance()

      ans =

           0
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      dsys.hasDisturbance();

::



    ISEMPTY - checks if linear system is empty.

    Input:
      regular:
          self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of linear
                systems.

    Output:
      isEmptyMat: logical[nDims1, nDims2,...] - array such that it's element at
          each position is true if corresponding linear system is empty, and
          false otherwise.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      sys.isEmpty()

      ans =

           0
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      dsys.isEmpty();

::


    ISEQUAL - produces produces logical array the same size as
              self/compLinSysArr (if they have the same).
              isEqualArr[iDim1, iDim2,...] is true if corresponding
              linear systems are equal and false otherwise.

    Input:
      regular:
          self: elltool.linsys.ILinSys[nDims1, nDims2,...] -  an array of
               linear systems.
          compLinSysArr: elltool.linsys.ILinSys[nDims1,...nDims2,...] - an
               array of linear systems.

    Output:
      isEqualArr: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of
          logical values.
          isEqualArr[iDim1, iDim2,...] is true if corresponding linear systems
          are equal and false otherwise.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      newSys = sys.getCopy();
      isEqual = sys.isEqual(newSys)

      isEqual =

           1
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      newDSys = sys.getCopy();
      isEqual = dsys.isEqual(newDSys)

      isEqual =

           1

::


    ISLTI - checks if linear system is time-invariant.

    Input:
      regular:
          self: elltool.linsys.LinSys[nDims1, nDims2,...] - an array of linear
                systems.

    Output:
      isLtiMat: logical[nDims1, nDims2,...] -array such that it's element at
          each position is true if corresponding linear system is
          time-invariant, and false otherwise.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
      isLtiArr = sys.isLti();
      dsys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds);
      isLtiArr = dsys.isLti();

elltool.linsys.LinSysContinuous
-------------------------------

::

    LINSYSCONTINUOUS - Constructor of continuous linear system object.

    Continuous-time linear system:
              dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  C(t) v(t)

    Input:
      regular:
          atInpMat: double[nDim, nDim]/cell[nDim, nDim] - matrix A.

          btInpMat: double[nDim, kDim]/cell[nDim, kDim] - matrix B.

      optional:
          uBoundsEll: ellipsoid[1, 1]/struct[1, 1] - control bounds
                ellipsoid.

          ctInpMat: double[nDim, lDim]/cell[nDim, lDim] - matrix G.

          distBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance
                bounds ellipsoid.

          discrFlag: char[1, 1] - if discrFlag set:
                 'd' - to discrete-time linSys,
                 not 'd' - to continuous-time linSys.


    Output:
      self: elltool.linsys.LinSysContinuous[1, 1] - continuous linear
                system.

    Example:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);

See the description of the following methods in section
[secClassDescr:elltool.linsys.ALinSys] for elltool.linsys.ALinSys:

elltool.linsys.LinSysDiscrete
-----------------------------

::

    LINSYSDISCRETE - constructor of discrete linear system object.

    Discrete-time linear system:
              x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  C[k] v[k]

    Input:
      regular:
          atInpMat: double[nDim, nDim]/cell[nDim, nDim] - matrix A.

          btInpMat: double[nDim, kDim]/cell[nDim, kDim] - matrix B.
      optional:
          uBoundsEll: ellipsoid[1, 1]/struct[1, 1] - control bounds
              ellipsoid.

          ctInpMat: double[nDim, lDim]/cell[nDim, lDim] - matrix G.

          distBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds
              ellipsoid.

          discrFlag: char[1, 1] - if discrFlag set:
               'd' - to discrete-time linSys
               not 'd' - to continuous-time linSys.

    Output:
      self: elltool.linsys.LinSysDiscrete[1, 1] - discrete linear system.

    Example:
      for k = 1:20
         atMat = {'0' '1 + cos(pi*k/2)'; '-2' '0'};
         btMat =  [0; 1];
         uBoundsEllObj = ellipsoid(4);
         ctMat = [1; 0];
         distBounds = 1/(k+1);
         lsys = elltool.linsys.LinSysDiscrete(atMat, btMat,...
             uBoundsEllObj, ctMat,distBounds);
      end

See the description of the following methods in section
[secClassDescr:elltool.linsys.ALinSys] for elltool.linsys.ALinSys:

elltool.linsys.LinSysFactory
----------------------------

::

    Factory class of linear system objects of the Ellipsoidal Toolbox.

::

    CREATE - returns linear system object.

    Continuous-time linear system:
              dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  C(t) v(t)

    Discrete-time linear system:
              x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  C[k] v[k]

    Input:
      regular:
          atInpMat: double[nDim, nDim]/cell[nDim, nDim] - matrix A.

          btInpMat: double[nDim, kDim]/cell[nDim, kDim] - matrix B.

          uBoundsEll: ellipsoid[1, 1]/struct[1, 1] - control bounds
              ellipsoid.

          ctInpMat: double[nDim, lDim]/cell[nDim, lDim] - matrix G.

          distBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds
              ellipsoid.

          discrFlag: char[1, 1] - if discrFlag set:
              'd' - to discrete-time linSys
              not 'd' - to continuous-time linSys.

    Output:
      linSys: elltool.linsys.LinSysContinuous[1, 1]/
          elltool.linsys.LinSysDiscrete[1, 1] - linear system.

    Examples:
      aMat = [0 1; 0 0]; bMat = eye(2);
      SUBounds = struct();
      SUBounds.center = {'sin(t)'; 'cos(t)'};
      SUBounds.shape = [9 0; 0 2];
      sys = elltool.linsys.LinSysFactory.create(aMat, bMat,SUBounds);

.. raw:: html

   <div class="references">

.. raw:: html

   </div>
