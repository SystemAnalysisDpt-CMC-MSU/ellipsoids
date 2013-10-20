Implementation
==============

Operations with ellipsoids
--------------------------

In the *Ellipsoidal Toolbox* we define a new class ellipsoid inside the
MATLAB programming environment. The following three commands define the
same ellipsoid :math:`{\mathcal E}(q,Q)`, with :math:`q\in{\bf R}^n` and
:math:`Q\in{\bf R}^{n\times n}` being symmetric positive semidefinite:
For the ellipsoid class we overload the following functions and
operators:

*  isEmpty(ellObj) - checks if :math:`{\mathcal E}(q,Q)` is an empty
   ellipsoid.

*  display(ellObj) - displays the details of ellipsoid
   :math:`{\mathcal E}(q,Q)`, namely, its center :math:`q` and the shape
   matrix :math:`Q`.

*  plot(ellObj) - plots ellipsoid :math:`{\mathcal E}(q,Q)` if its
   dimension is not greater than 3.

*  firstEllObj == secEllObj - checks if ellipsoids
   :math:`{\mathcal E}(q_1,Q_1)` and :math:`{\mathcal E}(q_2,Q_2)` are
   equal.

*  firstEllObj ~= secEllObj - checks if ellipsoids
   :math:`{\mathcal E}(q_1,Q_1)` and :math:`{\mathcal E}(q_2,Q_2)` are
   not equal.

*  [ , ] - concatenates the ellipsoids into the horizontal array, e.g. ellVec
   = [firstEllObj secEllObj thirdEllObj].

*  [ ; ] - concatenates the ellipsoids into the vertical array, e.g. ellMat =
   [firstEllObj secEllObj; thirdEllObj fourthEllObj] defines
   :math:`2\times 2` array of ellipsoids.

*  firstEllObj >= secEllObj - checks if the ellipsoid firstEllObj is
   bigger than the ellipsoid secEllObj, or equivalently
   :math:`{\mathcal E}(0,Q_1)\subseteq{\mathcal E}(0,Q_2)`.

*  firstEllObj <= secEllObj - checks if
   :math:`{\mathcal E}(0,Q_2)\subseteq{\mathcal E}(0,Q_1)`.

*  -ellObj - defines ellipsoid :math:`{\mathcal E}(-q,Q)`.

*  ellObj + bScal - defines ellipsoid :math:`{\mathcal E}(q+b,Q)`.

*  ellObj - bScal - defines ellipsoid :math:`{\mathcal E}(q-b,Q)`.

*  aMat \* ellObj - defines ellipsoid :math:`{\mathcal E}(q,AQA^T)`.

*  ellObj.inv() - inverts the shape matrix of the ellipsoid:
   :math:`{\mathcal E}(q,Q^{-1})`.

All the listed operations can be applied to a single ellipsoid as well
as to a two-dimensional array of ellipsoids. For example, 


To access individual elements of the array, the usual MATLAB subindexing is used:



Sometimes it may be useful to modify the shape of the ellipsoid without
affecting its center. Say, we would like to bloat or squeeze the
ellipsoid: 

Since function shape does not change the center of the
ellipsoid, it only accepts scalars or square matrices as its second
input parameter. Several functions access the internal data of the
ellipsoid object: 


One way to check if two ellipsoids intersect, is to
compute the distance between them ( (“Stanley Chan Article Homepage”),
Lin and Han (2002)): 


This result indicates that the ellipsoid
thirdEllObj does not intersect with the ellipsoid ellMat(2, 2), with all
the other ellipsoids in ellMat it has nonempty intersection. If the
intersection of the two ellipsoids is nonempty, it can be approximated
by ellipsoids from the outside as well as from the inside. See
:math:`\mbox{\!\!\@OldCite{ROS_SABATER_THOMAS_EN_ELLIPSOIDAL_CALCULUS_BASED_ON_PROPAGATION_AND_FUSION}}`
for more information about these methods. It can be checked that
resulting ellipsoid externalEllObj contains the given intersection,
whereas internalEllObj is contained in this intersection: 


Function
isInside in general checks if the intersection of ellipsoids in the
given array contains the union or intersection of ellipsoids or
polytopes.

It is also possible to solve the feasibility problem, that is, to check
if the intersection of more than two ellipsoids is empty: In this
particular example the result :math:`-1` indicates that the intersection
of ellipsoids in ellMat is empty. Function intersect in general checks
if an ellipsoid, hyperplane or polytope intersects the union or the
intersection of ellipsoids in the given array: For the ellipsoids in
:math:`{\bf R}`, :math:`{\bf R}^2` and :math:`{\bf R}^3` the geometric
sum can be computed explicitely and plotted: Figure
:math:`\ref{minksumPic}` displays the geometric sum of ellipsoids. If
the dimension of the space in which the ellipsoids are defined exceeds
:math:`3`, an error is returned. The result of the geometric sum
operation is not generally an ellipsoid, but it can be approximated by
families of external and internal ellipsoids parametrized by the
direction vector: Functions minksum\_ea and minksum\_ia work for
ellipsoids of arbitrary dimension. They should be used for general
computations whereas minksum is there merely for visualization purposes.

If the geometric difference of two ellipsoids is not an empty set, it
can be computed explicitely and plotted for ellipsoids in
:math:`{\bf R}`, :math:`{\bf R}^2` and :math:`{\bf R}^3`: Figure
:math:`\ref{minkdiffPic}` shows the geometric difference of ellipsoids.
Similar to minksum, minkdiff is there for visualization purpose. It
works only for dimensions :math:`1`, :math:`2` and :math:`3`, and for
higher dimensions it returns an error. For arbitrary dimensions, the
geometric difference can be approximated by families of external and
internal ellipsoids parametrized by the direction vector, provided this
direction is not bad: Operation ’difference-sum’ described in section
2.2.4 is implemented in functions minkmp, minkmp\_ea, minkmp\_ia, the
first one of which is used for visualization and works for dimensions
not higher than :math:`3`, whereas the last two can deal with ellipsoids
of arbitrary dimension. Figure :math:`\ref{minkPic}` displays results of
the implementation of minkpm and minkmp operations. Similarly, operation
’sum-difference’ described in section 2.2.5 is implemented in functions
minkpm, minkpm\_ea, minkpm\_ia, the first one of which is used for
visualization and works for dimensions not higher than :math:`3`,
whereas the last two can deal with ellipsoids of arbitrary dimension.

Operations with hyperplanes
---------------------------

The class hyperplane of the *Ellipsoidal Toolbox* is used to describe
hyperplanes and halfspaces. The following two commands define one and
the same hyperplane but two different halfspaces:

The following functions and operators are overloaded for the hyperplane
class:

-  isempty(hypObj) - checks if hypObj is an empty hyperplane.

-  display(hypObj) - displays the details of hyperplane
   :math:`H(c,\gamma)`, namely, its normal :math:`c` and the scalar
   :math:`\gamma`.

-  plot(hypObj) - plots hyperplane :math:`H(c,\gamma)` if the dimension
   of the space in which it is defined is not greater than 3.

-  firstHypObj == secHypObj - checks if hyperplanes
   :math:`H(c_1,\gamma_1)` and :math:`H(c_2,\gamma_2)` are equal.

-  firstHypObj = secHypObj - checks if hyperplanes
   :math:`H(c_1,\gamma_1)` and :math:`H(c_2,\gamma_2)` are not equal.

-  - concatenates the hyperplanes into the horizontal array, e.g. hypVec
   = [firstHypObj secHypObj thirdHypObj].

-  - concatenates the hyperplanes into the vertical array, e.g. hypMat =
   [firstHypObj secHypObj; thirdHypObj fourthHypObj] - defines
   :math:`2\times 2` array of hyperplanes.

-  -hypObj - defines hyperplane :math:`H(-c,-\gamma)`, which is the same
   as :math:`H(c,\gamma)` but specifies different halfspace.

There are several ways to access the internal data of the hyperplane
object: All the functions of *Ellipsoidal Toolbox* that accept
hyperplane object as parameter, work with single hyperplanes as well as
with hyperplane arrays. One exception is the function parameters that
allows only single hyperplane object.

An array of hyperplanes can be converted to the polytope object of the
Multi-Parametric Toolbox (Kvasnica et al. (2004), (“Multi-Parametric
Toolbox Homepage”)), and back: Functions hyperplane2polytope and
polytope2hyperplane require the Multi-Parametric Toolbox to be
installed.

We can compute distance from ellipsoids to hyperplanes and polytopes: A
negative distance value in the case of ellipsoid and hyperplane means
that the ellipsoid intersects the hyperplane. As we see in this example,
ellipsoid firstEllObj intersects hyperplanes hypVec(1) and hypVec(3) and
has no common points with hypVec(2) and hypVec(4). When distance
function has a polytope as a parameter, it always returns nonnegative
values to be consistent with distance function of the Multi-Parametric
Toolbox. Here, the zero distance values mean that each ellipsoid in
ellMat has nonempty intersection with polytope firstPolObj.

It can be checked if the union or intersection of given ellipsoids
intersects given hyperplanes or polytopes:

The intersection of ellipsoid and hyperplane can be computed exactly:
Functions intersection\_ea and intersection\_ia can be used with
hyperplane objects, which in this case define halfspaces and polytope
objects:

Function isInside can be used to check if a polytope or union of
polytopes is contained in the intersection of given ellipsoids:

Functions distance, intersect, intersection\_ia and isInside use the CVX
interface ( (“CVX Homepage”)) to the external optimization package. The
default optimization package included in the distribution of the
*Ellipsoidal Toolbox* is SeDuMi (Sturm (1999), (“SeDuMi Homepage”)).

Operations with ellipsoidal tubes
---------------------------------

There are several classes in *Ellipsoidal Toolbox* for operations with
ellipsoidal tubes. The class gras.ellapx.smartdb.rels.EllTube is used to
describe ellipsoidal tubes. The class
gras.ellapx.smartdb.rels.EllUnionTube is used to store tubes by the
instant of time:

.. math:: {\mathcal X}_{U}[t]=\bigcup \limits_{\tau\leqslantt}{\mathcal X}[\tau],

 where :math:`{\mathcal X}[\tau]` is single ellipsoidal tube. The class
gras.ellapx.smartdb.rels.EllTubeProj is used to describe the projection
of the ellipsoidal tubes onto time dependent subspaces.There are two
types of projection: static and dynamic. Also there is class
gras.ellapx.smartdb.rels.EllUnionTubeStaticProj for description of the
projection on static plane tubes by the instant of time. Next we provide
some examples of the operations with ellipsoidal tubes. We may be
interested in the data about ellipsoidal tube in some particular time
interval, smaller than the one for which the ellipsoidal tube was
computed, say :math:`2\leqslantt\leqslant4`. This data can be extracted
by the cut function: We can compute the projection of the ellipsoidal
tube onto time-dependent subspace.

Figure :math:`\ref{project}` displays static and dynamic projections.
Also we can see projections of good directions for ellipsoidal tubes.

We can compute tubes by the instant of time using methodfromEllTubes:
Figure :math:`\ref{unionTubeStatProj}` shows projection of ellipsoidal
tubes by the instant of time. ellipsoidal tutbes.

Also we can get initial data from the resulting tube: There is a method
to display a content of ellipsoidal tubes. Figure :math:`\ref{dispPic}`
displays all fields of the ellipsoidal tube.

There are several methods to find the tubes with necessary parameters.
Also you can use the method display to see the result of the method’s
work. We can sort our tubes by certain fields:

Reachability
------------

To compute the reach sets of the systems described in chapter 3, we
define few new classes in the *Ellipsoidal Toolbox*: class
LinSysContinuous for the continuous-time system description, class
LinSysDiscrete for the discrete-time system description and classes
ReachContinuous\ :math:`\backslash`\ ReachDiscrete for the reach set
data. We start by explaining how to define a system using
LinSysContinuous object. Also we can use LinSysFactory class for the
description of this system. Through it’s method create user can get
LinSysContinuous or LinSysDiscrete object. For example, description of
the system

.. math::

   \left[\begin{array}{cc}
   \dot{x}_1\\
   \dot{x}_2\end{array}\right] = \left[\begin{array}{cc}
   0 & 1\\
   0 & 0\end{array}\right]\left[\begin{array}{c}
   x_1\\
   x_2\end{array}\right] + \left[\begin{array}{c}
   u_1(t)\\
   u_2(t)\end{array}\right], ~~~ u(t)\in{\mathcal E}(p(t), P)

 with

.. math::

   p(t) = \left[\begin{array}{c}
   \sin(t)\\
   \cos(t)\end{array}\right], ~~~ P = \left[\begin{array}{cc}
   9 & 0\\
   0 & 2\end{array}\right],

 is done by the following sequence of commands: If matrices :math:`A` or
:math:`B` depend on time, say :math:`A(t)=\left[\begin{array}{cc}
0 & 1-\cos(2t)\\
-\frac{1}{t} & 0\end{array}\right]`, then matrix aMat should be
symbolic: To describe the system with disturbance

.. math::

   \left[\begin{array}{cc}
   \dot{x}_1\\
   \dot{x}_2\end{array}\right] = \left[\begin{array}{cc}
   0 & 1\\
   0 & 0\end{array}\right]\left[\begin{array}{c}
   x_1\\
   x_2\end{array}\right] + \left[\begin{array}{c}
   u_1(t)\\
   u_2(t)\end{array}\right] + \left[\begin{array}{c}
   0\\
   1\end{array}\right]v(t),

 with bounds on control as before, and disturbance being
:math:`-1\leqslantv(t)\leqslant1`, we type: Control and disturbance
bounds SUBounds and vEllObj can have different types. If the bound is
constant, it should be described by ellipsoid object. If the bound
depends on time, then it is represented by a structure with fields
center and shape, one or both of which are symbolic. In system sys, the
control bound SUBounds is defined as such a structure. Finally, if the
control or disturbance is known and fixed, it should be defined as a
vector, of type double if constant, or symbolic, if it depends on time.

To declare a discrete-time system

.. math::

   \left[\begin{array}{c}
   x_1[k+1]\\
   x_2[k+1]\end{array}\right] = \left[\begin{array}{cc}
   0 & 1\\
   -1 & -0.5\end{array}\right]\left[\begin{array}{c}
   x_1[k]\\
   x_2[k]\end{array}\right] + \left[\begin{array}{c}
   0\\
   1\end{array}\right]u[k], ~~~ -1\leqslantu[k]\leqslant1,

 we use LinSysDiscrete constructor: Once the LinSysDiscrete object is
created, we need to specify the set of initial conditions, the time
interval and values of the direction vector, for which the reach set
approximations must be computed: The reach set approximation is computed
by calling the constructor of the ReachContinuous object: At this point,
variable firstRsObj contains the reach set approximations for the
specified continuous-time system, time interval and set of initial
conditions computed for given directions. Both external and internal
approximations are computed. The reach set approximation data can be
extracted in the form of arrays of ellipsoids:

Ellipsoidal arrays externallEllMat and internalEllMat have :math:`4`
rows because we computed the reach set approximations for :math:`4`
directions. Each row of ellipsoids corresponds to one direction. The
number of columns in externallEllMat and internalEllMat is defined by
the nTimeGridPoints parameter, which is available from
elltool.conf.Properties static class (see chapter 6 for details). It
represents the number of time values in our time interval, at which the
approximations are evaluated. These time values are returned in the
optinal output parameter, array timeVec, whose length is the same as the
number of columns in externallEllMat and internalEllMat. Intersection of
ellipsoids in a particular column of externallEllMat gives external
ellipsoidal approximation of the reach set at corresponding time.
Internal ellipsoidal approximation of this set at this time is given by
the union of ellipsoids in the same column of internalEllMat.

We may be interested in the reachability data of our system in some
particular time interval, smaller than the one for which the reach set
was computed, say :math:`3\leqslantt\leqslant5`. This data can be
extracted and returned in the form of ReachContinuous object by the cut
function:

To obtain a snap shot of the reach set at given time, the same function
cut is used: It can be checked if the external or internal reach set
approximation intersects with given ellipsoids, hyperplanes or
polytopes:

If a given set intersects with the internal approximation of the reach
set, then this set intersects with the actual reach set. If the given
set does not intersect with external approximation, this set does not
intersect the actual reach set. There are situations, however, when the
given set intersects with the external approximation but does not
intersect with the internal one. In our example above, ellipsoid ellObj
is such a case: the quality of the approximation does not allow us to
determine whether or not ellObj intersects with the actual reach set. To
improve the quality of approximation, refine function should be used:

Now we are sure that ellipsoid ellObj intersects with the actual reach
set. However, to use the refine function, the reach set object must
contain all calculated data, otherwise, an error is returned.

Having a reach set object resulting from the ReachContinuous, cut or
refine operations, we can obtain the trajectory of the center of the
reach set and the good curves along which the actual reach set is
touched by its ellipsoidal approximations:

Variable ctrMat here is a matrix whose columns are the points ofthe
reach set center trajectory evaluated at time values returned in the
array ttVec. Variable gcCMat contains :math:`4` matrices each of which
corresponds to a good curve (columns of such matrix are points of the
good curve evaluated at time values in ttVec). The analytic expression
for the control driving the system along a good curve is given by
formula ([uct]).

We computed the reach set up to time :math:`10`. It is possible to
continue the reach set computation for a longer time horizon using the
reach set data at time :math:`10` as initial condition. It is also
possible that the dynamics and inputs of the system change at certain
time, and from that point on the system evolves according to the new
system of differential equations. For example, starting at time
:math:`10`, our reach set may evolve in time according to the
time-variant system sys\_t defined above. Switched systems are a special
case of this situation. To compute the further evolution in time of the
existing reach set, function evolve should be used: Function evolve can
be viewed as an implementation of the semigroup property.

To compute the backward reach set for some specified target set, we
declare the time interval so that the terminating time comes first:

Reach set and backward reach set computation for discrete-time systems
and manipulations with the resulting reach set object are performed
using the same functions as for continuous-time systems:

Number of columns in the ellipsoidal arrays externalEllMat and
internalEllMat is :math:`51` because the backward reach set is computed
for :math:`50` time steps, and the first column of these arrays contains
:math:`3` ellipsoids yEllObj - the terminating condition.

When dealing with discrete-time systems, all functions that accept time
or time interval as an input parameter, round the time values and treat
them as integers.

Properties
----------

Functions of the *Ellipsoidal Toolbox* can be called with user-specified
values of certain global parameters. System of the parameters are
configured using xml files, which available from a set of command-line
utilities: Here we list system parameters available from the ’default’
configuration:

#. version = ’1.4dev’ - current version of *ET*.

#. isVerbose = false - makes all the calls to *ET* routines silent, and
   no information except errors is displayed.

#. absTol = 1e-7 - absolute tolerance.

#. relTol = 1e-5 - relative tolerance.

#. nTimeGridPoints = 200 - density of the time grid for the continuous
   time reach set computation. This parameter directly affects the
   number of ellipsoids to be stored in the
   ReachContinuous\ :math:`\backslash`\ ReachDiscrete object.

#. ODESolverName = ode45 - specifies the ODE solver for continuous time
   reach set computation.

#. isODENormControl = ’on’ - switches on and off the norm control in the
   ODE solver. When turned on, it slows down the computation, but
   improves the accuracy.

#. isEnabledOdeSolverOptions = false - when set to false, calls the ODE
   solver without any additional options like norm control. It makes the
   computation faster but less accurate. Otherwise, it is assumed to be
   true, and only in this case the previous option makes a difference.

#. nPlot2dPoints = 200 - the number of points used to plot a 2D
   ellipsoid. This parameter also affects the quality of 2D reach tube
   and reach set plots.

#. nPlot3dPoints = 200 - the number of points used to plot a 3D
   ellipsoid. This parameter also affects the quality of 3D reach set
   plots.

Once the configuration is loaded, the system parameters are available
through elltool.conf.Properties. elltool.conf.Properties is a static
class, providing emulation of static properties for toolbox. It has two
function types: setters and getters. Using getters we obtain system
parameters. Some of the parameters can be changed in run-time via
setters.

Visualization
-------------

*Ellipsoidal Toolbox* has several plotting routines:

-  ellipsoid/plot - plots one or more ellipsoids, or arrays of
   ellipsoids, defined in :math:`{\bf R}`, :math:`{\bf R}^2` or
   :math:`{\bf R}^3`.

-  ellipsoid/minksum - plots geometric sum of finite number of
   ellipsoids defined in :math:`{\bf R}`, :math:`{\bf R}^2` or
   :math:`{\bf R}^3`.

-  ellipsoid/minkdiff - plots geometric difference (if it is not an
   empty set) of two ellipsoids defined in :math:`{\bf R}`,
   :math:`{\bf R}^2` or :math:`{\bf R}^3`.

-  ellipsoid/minkmp - plots geometric (Minkowski) sum of the geometric
   difference of two ellipsoids and the geometric sum of :math:`n`
   ellipsoids defined in :math:`{\bf R}`, :math:`{\bf R}^2` or
   :math:`{\bf R}^3`.

-  ellipsoid/minkpm - plots geometric (Minkowski) difference of the
   geometric sum of ellipsoids and a single ellipsoid defined in
   :math:`{\bf R}`, :math:`{\bf R}^2` or :math:`{\bf R}^3`.

-  hyperplane/plot - plots one or more hyperplanes, or arrays of
   hyperplanes, defined in :math:`{\bf R}^2` or :math:`{\bf R}^3`.

-  reach/plot\_ea - plots external approximation of the reach set whose
   dimension is :math:`2` or :math:`3`.

-  reach/plot\_ia - plots internal approximation of the reach set whose
   dimension is :math:`2` or :math:`3`.

All these functions allow the user to specify the color of the plotted
objects, line width for 1D and 2D plots, and transparency level of the
3D objects. Hyperplanes are displayed as line segments in 2D and square
facets in 3D. In the hyperplane/plot method it is possible to specify
the center of the line segment or facet and its size.

Ellipsoids of dimensions higher than three must be projected onto a two-
or three-dimensional subspace before being plotted. This is done by
means of projection function:

Since the operation of projection is linear, the projection of the
geometric sum of ellipsoids equals the geometric sum of the projected
ellipsoids. The same is true for the geometric difference of two
ellipsoids.

Function projection exists also for the
ReachContinuous\ :math:`\backslash`\ ReachDiscrete objects:

The quality of the ellipsoid and reach set plots is controlled by the
parameters nPlot2dPoints and nPlot3dPoints, which are available from
getters of ellipsoid class.

.. raw:: html

   <div class="references">

“CVX Homepage.” cvxr.com/cvx.

“Multi-Parametric Toolbox Homepage.” control.ee.ethz.ch/\\~mpt.

“SeDuMi Homepage.” sedumi.mcmaster.ca.

“Stanley Chan Article Homepage.”
http://videoprocessing.ucsd.edu/~stanleychan/publication/unpublished/Ellipse.pdf.

Kvasnica, M., P. Grieder, M. Baotić, and M. Morari. 2004.
“Multi-Parametric Toolbox (MPT).” In *Hybrid Systems: Computation and
Control*, edited by R. Alur and G. J. Pappas, 2993:448–462. Springer.

Lin, A., and S. Han. 2002. “On the Distance Between Two Ellipsoids.”
*SIAM Journal on Optimization* 13 (1): 298–308.

Sturm, J. F. 1999. “Using SeDuMi 1.02, A MATLAB Toolbox for Optimization
over Symmetric Cones.” *Optimization Methods and Software* 11-12:
625–653.

.. raw:: html

   </div>
