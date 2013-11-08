Introduction
============

Research on dynamical and hybrid systems has produced several methods
for verification and controller synthesis. A common step in these
methods is the reachability analysis of the system. Reachability
analysis is concerned with the computation of the reach set in a way
that can effectively meet requests like the following:

#. For a given target set and time, determine whether the reach set and
   the target set have nonempty intersection.

#. For specified reachable state and time, find a feasible initial
   condition and control that steers the system from this initial
   condition to the given reachable state in given time.

#. Graphically display the projection of the reach set onto any
   specified two- or three-dimensional subspace.

Except for very specific classes of systems, exact computation of reach
sets is not possible, and approximation techniques are needed. For
controlled linear systems with convex bounds on the control and initial
conditions, the efficiency and accuracy of these techniques depend on
how they represent convex sets and how well they perform the operations
of unions, intersections, geometric (Minkowski) sums and differences of
convex sets. Two basic objects are used as convex approximations:
polytopes of various types, including general polytopes, zonotopes,
parallelotopes, rectangular polytopes; and ellipsoids.

Reachability analysis for general polytopes is implemented in the Multi
Parametric Toolbox (MPT) for Matlab ([KVAS2004]_, [MPTHP]_). The reach set at every time step
is computed as the geometric sum of two polytopes. The procedure
consists in finding the vertices of the resulting polytope and
calculating their convex hull. MPT’s convex hull algorithm is based on
the Double Description method [MOTZ1953]_ and implemented in
the CDD/CDD+ package [CDDHP]_. Its complexity is
:math:`V^n`, where :math:`V` is the number of vertices and :math:`n` is
the state space dimension. Hence the use of MPT is practicable for low
dimensional systems. But even in low dimensional systems the number of
vertices in the reach set polytope can grow very large with the number
of time steps. For example, consider the system,

.. math:: x_{k+1} = Ax_k + u_k ,

with :math:`A=\left[\begin{array}{cc}\cos 1 & -\sin 1\\ \sin 1 & \cos 1\end{array}\right]`, 
:math:`\ u_k \in \{u\in {\bf R}^2 ~|~ \|u\|_{\infty}\leqslant1\}`, 
and :math:`x_0 \in \{x\in {\bf R}^2 ~|~ \|x\|_{\infty}\leqslant1\}`.

Starting with a rectangular initial set, the number of vertices of the
reach set polytope is :math:`4k + 4` at the :math:`k`\ th step.

In :math:`d/dt` [DDTHP]_, the reach set is approximated by
unions of rectangular polytopes [ASAR2000]_.

.. _ddtfig:

.. figure:: /pic/ddt.png
   :align: center
   :alt: approximation
   :figwidth: 50 %

   Reach set approximation by union of rectangles. Source: adapted from [ASAR2000]_.

The algorithm works as follows. First, given the set of initial
conditions defined as a polytope, the evolution in time of the
polytope’s extreme points is computed (:num:`figure #ddtfig` (a)).

:math:`R(t_1)` in :num:`figure #ddtfig` (a) is the reach set of the system at
time :math:`t_1`, and :math:`R[t_0, t_1]` is the set of all points that
can be reached during :math:`[t_0, t_1]`. Second, the algorithm computes
the convex hull of vertices of both, the initial polytope and
:math:`R(t_1)` (:num:`figure #ddtfig` (b)). The resulting polytope is then
bloated to include all the reachable states in :math:`[t_0,t_1]` (:num:`figure #ddtfig` (c)). 
Finally, this overapproximating polytope is in its turn
overapproximated by the union of rectangles (:num:`figure #ddtfig` (d)). The
same procedure is repeated for the next time interval :math:`[t_1,t_2]`,
and the union of both rectangular approximations is taken (:num:`figure #ddtfig` (e,f)), 
and so on. Rectangular polytopes are easy to represent
and the number of facets grows linearly with dimension, but a large
number of rectangles must be used to assure the approximation is not
overly conservative. Besides, the important part of this method is again
the convex hull calculation whose implementation relies on the same
CDD/CDD+ library. This limits the dimension of the system and time
interval for which it is feasible to calculate the reach set.

Polytopes can give arbitrarily close approximations to any convex set,
but the number of vertices can grow prohibitively large and, as shown in
[AVIS1997]_, the computation of a polytope by its
convex hull becomes intractable for large number of vertices in high
dimensions.

The method of zonotopes for approximation of reach sets ([GIR2005]_, [GIR2006]_, [MATHP]_) 
uses a special class of polytopes (see [ZONOHP]_)
of the form,

.. math::

   Z=\{x \in {\bf R}^n ~|~
   x=c+\sum_{i=1}^p\alpha_ig_i,~ -1\leqslant\alpha_i\leqslant1\},

wherein :math:`c` and :math:`g_1, ..., g_p` are vectors in
:math:`{\bf R}^n`. Thus, a zonotope :math:`Z` is represented by its
center :math:`c` and ‘generator’ vectors :math:`g_1, ..., g_p`. The
value :math:`p/n` is called the order of the zonotope. The main benefit
of zonotopes over general polytopes is that a symmetric polytope can be
represented more compactly than a general polytope. The geometric sum of
two zonotopes is a zonotope:

.. math:: Z(c_1, G_1)\oplus Z(c_2, G_2) = Z(c_1+c_2, [G_1 ~ G_2]),

wherein :math:`G_1` and :math:`G_2` are matrices whose columns are
generator vectors, and :math:`[G_1 ~ G_2]` is their concatenation. Thus,
in the reach set computation, the order of the zonotope increases by
:math:`p/n` with every time step. This difficulty can be averted by
limiting the number of generator vectors, and overapproximating
zonotopes whose number of generator vectors exceeds the limit by lower
order zonotopes. The benefits of the compact zonotype representation,
however, appear to diminish because in order to plot them or check if
they intersect with given objects and compute those intersections, these
operations are performed after converting zonotopes to polytopes.

CheckMate [CMHP]_ is a Matlab toolbox that can evaluate
specifications for trajectories starting from the set of initial
(continuous) states corresponding to the parameter values at the
vertices of the parameter set. This provides preliminary insight into
whether the specifications will be true for all parameter values. The
method of oriented rectangluar polytopes for external approximation of
reach sets is introduced in [STUR2003]_. The basic idea
is to construct an oriented rectangular hull of the reach set for every
time step, whose orientation is determined by the singular value
decomposition of the sample covariance matrix for the states reachable
from the vertices of the initial polytope. The limitation of CheckMate
and the method of oriented rectangles is that only autonomous (i.e.
uncontrolled) systems, or systems with fixed input are allowed, and only
an external approximation of the reach set is provided.

All the methods described so far employ the notion of time step, and
calculate the reach set or its approximation at each time step. This
approach can be used only with discrete-time systems. By contrast, the
analytic methods which we are about to discuss, provide a formula or
differential equation describing the (continuous) time evolution of the
reach set or its approximation.

The level set method ([MIT2000]_, [LSTHP]_) 
deals with general nonlinear controlled systems and gives
exact representation of their reach sets, but requires solving the HJB
equation and finding the set of states that belong to sub-zero level set
of the value function. The method [LSTHP]_ is
impractical for systems of dimension higher than three.

Requiem [REQHP]_ is a Mathematica notebook which, given a
linear system, the set of initial conditions and control bounds,
symbolically computes the exact reach set, using the experimental
quantifier elimination package. Quantifier elimination is the removal of
all quantifiers (the universal quantifier :math:`\forall` and the
existential quantifier :math:`\exists`) from a quantified system. Each
quantified formula is substituted with quantifier-free expression with
operations :math:`+`, :math:`\times`, :math:`=` and :math:`<`. For
example, consider the discrete-time system

.. math:: x_{k+1} = Ax_k + Bu_k

with :math:`A=\left[\begin{array}{cc}0 & 1\\0 & 0\end{array}\right]` 
and :math:`B=\left[\begin{array}{c}0\\1\end{array}\right]`. 

For initial conditions :math:`x_0\in\{x\in {\bf R}^2 ~|~ \|x\|_{\infty} \leqslant1\}` and
controls :math:`u_k\in\{u\in {\bf R} ~|~ -1\leqslant u\leqslant1\}`, the
reach set for :math:`k\geqslant0` is given by the quantified formula

.. math::

   \{ x\in{\bf R}^2 ~|~ \exists x_0, ~~ \exists k\geqslant0, ~~
   \exists u_i, ~ 0\leqslant i\leqslant k: ~~
   x = A^kx_0+\sum_{i=0}^{k-1}A^{k-i-1}Bu_i \},

which is equivalent to the quantifier-free expression

.. math:: -1\leqslant[1 ~~ 0]x\leqslant1 ~ \wedge ~ -1\leqslant[0 ~~ 1]x\leqslant1.

It is proved in [LAFF2001]_ that for
continuous-time systems, :math:`\dot{x}(t) = Ax(t) + Bu(t)`, if
:math:`A` is constant and nilpotent or is diagonalizable with rational
real or purely imaginary eigenvalues, and with suitable restrictions on
the control and initial conditions, the quantifier elimination package
returns a quantifier free formula describing the reach set. Quantifier
elimination has limited applicability.

The reach set approximation via parallelotopes [KOST2001]_ employs
the idea of parametrization described in [KUR2000]_
for ellipsoids. The reach set is represented as the intersection of
tight external, and the union of tight internal, parallelotopes. The
evolution equations for the centers and orientation matrices of both
external and internal parallelotopes are provided. This method also
finds controls that can drive the system to the boundary points of the
reach set, similarly to [VAR1998]_ and [KUR2000]_. 
It works for general linear systems. The computation to solve
the evolution equation for tight approximating parallelotopes, however,
is more involved than that for ellipsoids, and for discrete-time systems
this method does not deal with singular state transition matrices.

*Ellipsoidal Toolbox* (ET) implements in MATLAB the ellipsoidal calculus
[KUR1997]_ and its application to the reachability
analysis of continuous-time [KUR2000]_, discrete-time
[VAR2007]_, possibly time-varying linear systems, and
linear systems with disturbances [KUR2001]_,
for which ET calculates both open-loop and close-loop reach sets. The
ellipsoidal calculus provides the following benefits:

-  The complexity of the ellipsoidal representation is quadratic in the
   dimension of the state space, and linear in the number of time steps.

-  It is possible to exactly represent the reach set of linear system
   through both external and internal ellipsoids.

-  It is possible to single out individual external and internal
   approximating ellipsoids that are optimal to some given criterion
   (e.g. trace, volume, diameter), or combination of such criteria.

-  We obtain simple analytical expressions for the control that steers
   the state to a desired target.

The report is organized as follows. Chapter 2 describes the operations
of the ellipsoidal calculus: affine transformation, geometric sum,
geometric difference, intersections with hyperplane, ellipsoid,
halfspace and polytope, calculation of maximum ellipsoid, calculation of
minimum ellipsoid. Chapter 3 presents the reachability problem and
ellipsoidal methods for the reach set approximation. Chapter 4 contains
*Ellipsoidal Toolbox* installation and quick start instructions, and
lists the software packages used by the toolbox. Chapter 5 describes
structures and objects implemented and used in toolbox. Also it
describes the implementation of methods from chapters 2 and 3 and
visualization routines. Chapter 6 describes structures and objects
implemented and used in the toolbox. Chapter 6 gives examples of how to
use the toolbox. Chapter 7 collects some conclusions and plans for
future toolbox development. The functions provided by the toolbox
together with their descriptions are listed in appendix A.

Ellipsoidal Calculus
====================

Basic Notions
-------------

We start with basic definitions. 
Ellipsoid :math:`{\mathcal E}(q,Q)` in
:math:`{\bf R}^n` with center :math:`q` and shape matrix :math:`Q` is
the set

.. math::
   :label: ellipsoid

   {\mathcal E}(q,Q) = \{ x \in {\bf R}^n ~|~ \langle (x-q), Q^{-1}(x-q)\rangle\leqslant1 \},

wherein :math:`Q` is positive definite (:math:`Q=Q^T` and
:math:`\langle x, Qx\rangle>0` for all nonzero :math:`x\in{\bf R}^n`).
Here :math:`\langle\cdot,\cdot\rangle` denotes inner
product. The support function of a set
:math:`{\mathcal X}\subseteq{\bf R}^n` is

.. math:: \rho(l~|~{\mathcal X}) = \sup_{x\in{\mathcal X}} \langle l,x\rangle.

In particular, the support function of the ellipsoid :eq:`ellipsoid` is

.. math::
   :label: ellsupp

   \rho(l~|~{\mathcal E}(q,Q)) = \langle l, q\rangle + \langle l, Ql\rangle^{1/2}.

Although in :eq:`ellipsoid` :math:`Q` is assumed to be positive definite,
in practice we may deal with situations when :math:`Q` is singular, that
is, with degenerate ellipsoids flat in those directions for which the
corresponding eigenvalues are zero. Therefore, it is useful to give an
alternative definition of an ellipsoid using the expression :eq:`ellsupp`.
Ellipsoid :math:`{\mathcal E}(q,Q)` in :math:`{\bf R}^n` with center
:math:`q` and shape matrix :math:`Q` is the set

.. math::
   :label: ellipsoid2

   {\mathcal E}(q,Q) = \{ x \in {\bf R}^n ~|~
   \langle l,x\rangle\leqslant\langle l,q\rangle + \langle l,Ql\rangle^{1/2}
   \mbox{ for all } l\in{\bf R}^n \},

wherein matrix :math:`Q` is positive semidefinite (:math:`Q=Q^T` and
:math:`\langle x, Qx\rangle\geqslant0` for all :math:`x\in{\bf R}^n`).
The volume of ellipsoid :math:`{\mathcal E}(q,Q)` is

.. math::
   :label: ellvolume

   {\bf Vol}(E(q,Q)) = {\bf Vol}_{\langle x,x\rangle\leqslant1}\sqrt{\det Q},


where :math:`{\bf Vol}_{\langle x,x\rangle\leqslant1}` is the volume of
the unit ball in :math:`{\bf R}^n`:

.. math::
   :label: ellunitball

   {\bf Vol}_{\langle x,x\rangle\leqslant1} = \left\{\begin{array}{ll}
   \frac{\pi^{n/2}}{(n/2)!}, &
   \mbox{ for even } n,\\
   \frac{2^n\pi^{(n-1)/2}\left((n-1)/2\right)!}{n!}, &
   \mbox{ for odd } n. \end{array}\right.

The distance from :math:`{\mathcal E}(q,Q)` to the fixed point :math:`a`
is

.. math::
   :label: dist_point

   {\bf dist}({\mathcal E}(q,Q),a) = \max_{\langle l,l\rangle=1}\left(\langle l,a\rangle -
   \rho(l ~|~ {\mathcal E}(q,Q)) \right) =
   \max_{\langle l,l\rangle=1}\left(\langle l,a\rangle - \langle l,q\rangle -
   \langle l,Ql\rangle^{1/2}\right). 

If :math:`{\bf dist}({\mathcal E}(q,Q),a) > 0`, :math:`a` lies outside
:math:`{\mathcal E}(q,Q)`; if
:math:`{\bf dist}({\mathcal E}(q,Q),a) = 0`, :math:`a` is a boundary
point of :math:`{\mathcal E}(q,Q)`; if
:math:`{\bf dist}({\mathcal E}(q,Q),a) < 0`, :math:`a` is an internal
point of :math:`{\mathcal E}(q,Q)`.

Given two ellipsoids, :math:`{\mathcal E}(q_1,Q_1)` and
:math:`{\mathcal E}(q_2,Q_2)`, the distance between them is

.. math::
   :label: dist_ell

   \begin{aligned}
   {\bf dist}({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2)) & = \max_{\langle l,l\rangle=1}
   \left(-\rho(-l ~|~ {\mathcal E}(q_1,Q_1)) - \rho(l ~|~ {\mathcal E}(q_2,Q_2))\right) \\
   & = \max_{\langle l,l\rangle=1}\left(\langle l,q_1\rangle -
   \langle l,Q_1l\rangle^{1/2} - \langle l,q_2\rangle -
   \langle l,Q_2l\rangle^{1/2}\right).
   \end{aligned}

If :math:`{\bf dist}({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2)) > 0`,
the ellipsoids have no common points; if
:math:`{\bf dist}({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2)) = 0`, the
ellipsoids have one common point - they touch; if
:math:`{\bf dist}({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2)) < 0`, the
ellipsoids intersect.

Finding :math:`{\bf dist}({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2))`
using QCQP is

.. math:: d({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2)) = \min \langle (x-y), (x-y)\rangle

subject to:

.. math::

   \begin{aligned}
   \langle (q_1-x), Q_1^{-1}(q_1-x)\rangle & \leqslant& 1,\\
   \langle (q_2-x), Q_2^{-1}(q_2-y)\rangle & \leqslant& 1,\end{aligned}

where

.. math::

   d({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2))=\left\{\begin{array}{ll}
   {\bf dist}^2({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2)) &
   \mbox{ if } {\bf dist}({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2))>0, \\
   0 & \mbox{ otherwise}. \end{array}\right.

Checking if :math:`k` nondegenerate ellipsoids
:math:`{\mathcal E}(q_1,Q_1),\cdots,{\mathcal E}(q_k,Q_k)` have nonempty
intersection, can be cast as a quadratically constrained quadratic
programming (QCQP) problem:

.. math:: \min 0

subject to:

.. math:: \langle (x-q_i),Q_i^{-1}(x-q_i)\rangle - 1 \leqslant0, ~~~ i=1,\cdots,k.

If this problem is feasible, the intersection is nonempty. Given
compact convex set :math:`{\mathcal X}\subseteq{\bf R}^n`, its polar
set, denoted :math:`{\mathcal X}^\circ`, is

.. math:: {\mathcal X}^\circ = \{x\in{\bf R}^n ~|~ \langle x,y\rangle\leqslant1, ~ y\in{\mathcal X}\},

or, equivalently,

.. math:: {\mathcal X}^\circ = \{l\in{\bf R}^n ~|~ \rho(l ~|~ {\mathcal X})\leqslant1\}.

The properties of the polar set are

-  If :math:`{\mathcal X}` contains the origin,
   :math:`({\mathcal X}^\circ)^\circ = {\mathcal X}`;

-  If :math:`{\mathcal X}_1\subseteq{\mathcal X}_2`,
   :math:`{\mathcal X}_2^\circ\subseteq{\mathcal X}_1^\circ`;

-  For any nonsingular matrix :math:`A\in{\bf R}^{n\times n}`,
   :math:`(A{\mathcal X})^\circ = (A^T)^{-1}{\mathcal X}^\circ`.

If a nondegenerate ellipsoid :math:`{\mathcal E}(q,Q)` contains the
origin, its polar set is also an ellipsoid:

.. math::

   \begin{aligned}
   {\mathcal E}^\circ(q,Q) & = \{l\in{\bf R}^n ~|~ \langle l,q\rangle +
   \langle l,Ql\rangle^{1/2}\leqslant1 \}\\
   & = \{l\in{\bf R}^n ~|~ \langle l,(Q-qq^T)^{-1}l\rangle +
   2\langle l,q\rangle\leqslant1 \}\\
   & = \{l\in{\bf R}^n ~|~ \langle(l+(Q-qq^T)^{-1}q),
   (Q-qq^T)(l+(Q-qq^T)^{-1}q)\rangle\leqslant1+\langle q,(Q-qq^T)^{-1}q\rangle \}.\end{aligned}

The special case is

.. math:: {\mathcal E}^\circ(0,Q) = {\mathcal E}(0,Q^{-1}).

Given :math:`k` compact sets
:math:`{\mathcal X}_1, \cdots, {\mathcal X}_k\subseteq{\bf R}^n`, their
geometric (Minkowski) sum is

.. math::
   :label: minksum

   {\mathcal X}_1\oplus\cdots\oplus{\mathcal X}_k=\bigcup_{x_1\in{\mathcal X}_1}\cdots\bigcup_{x_k\in{\mathcal X}_k}
   \{x_1 + \cdots + x_k\} .  

Given two compact sets
:math:`{\mathcal X}_1, {\mathcal X}_2 \subseteq{\bf R}^n`, their
geometric (Minkowski) difference is

.. math::
   :label: minkdiff

   {\mathcal X}_1\dot{-}{\mathcal X}_2 = \{x\in{\bf R}^n ~|~ x + {\mathcal X}_2 \subseteq {\mathcal X}_1 \}.


Ellipsoidal calculus concerns the following set of operations:

-  affine transformation of ellipsoid;

-  geometric sum of finite number of ellipsoids;

-  geometric difference of two ellipsoids;

-  intersection of finite number of ellipsoids.

These operations occur in reachability calculation and verification of
piecewise affine dynamical systems. The result of all of these
operations, except for the affine transformation, is *not* generally an
ellipsoid but some convex set, for which we can compute external and
internal ellipsoidal approximations.

Additional operations implemented in the *Ellipsoidal Toolbox* include
external and internal approximations of intersections of ellipsoids with
hyperplanes, halfspaces and polytopes. Hyperplane :math:`H(c,\gamma)` in
:math:`{\bf R}^n` is the set

.. math::
   :label: hyperplane

   H = \{x\in{\bf R}^n ~|~ \langle c, x\rangle = \gamma\}


with :math:`c\in{\bf R}^n` and :math:`\gamma\in{\bf R}` fixed.
The distance from ellipsoid :math:`{\mathcal E}(q,Q)` to
hyperplane :math:`H(c,\gamma)` is

.. math::
   :label: dist_hp

   {\bf dist}({\mathcal E}(q,Q),H(c,\gamma)) =
   \frac{\left|\gamma-\langle c,q\rangle\right| -
   \langle c,Qc\rangle^{1/2}}{\langle c,c\rangle^{1/2}}.

If :math:`{\bf dist}({\mathcal E}(q,Q),H(c,\gamma))>0`, the ellipsoid
and the hyperplane do not intersect; if
:math:`{\bf dist}({\mathcal E}(q,Q),H(c,\gamma))=0`, the hyperplane is a
supporting hyperplane for the ellipsoid; if
:math:`{\bf dist}({\mathcal E}(q,Q),H(c,\gamma))<0`, the ellipsoid
intersects the hyperplane. The intersection of an ellipsoid with a
hyperplane is always an ellipsoid and can be computed directly.

Checking if the intersection of :math:`k` nondegenerate ellipsoids
:math:`E(q_1,Q_1),\cdots,{\mathcal E}(q_k,Q_k)` intersects hyperplane
:math:`H(c,\gamma)`, is equivalent to the feasibility check of the QCQP
problem:

.. math:: \min 0

subject to:

.. math::

   \begin{aligned}
   \langle (x-q_i),Q_i^{-1}(x-q_i)\rangle - 1 \leqslant0, & & i=1,\cdots,k,\\
   \langle c, x\rangle - \gamma = 0. & &\end{aligned}

A hyperplane defines two (closed) *halfspaces*:

.. math::
   :label: halfspace1

   {\bf S}_1 = \{x\in{\bf R}^n ~|~ \langle c, x\rangle \leqslant\gamma\}


and

.. math::
   :label: halfspace2

   {\bf S}_2 = \{x\in{\bf R}^n ~|~ \langle c, x\rangle \geqslant\gamma\}.

To avoid confusion, however, we shall further assume that a hyperplane
:math:`H(c,\gamma)` specifies the halfspace in the sense :eq:`halfspace1`.
In order to refer to the other halfspace, the same hyperplane should be
defined as :math:`H(-c,-\gamma)`.

The idea behind the calculation of intersection of an ellipsoid with a
halfspace is to treat the halfspace as an unbounded ellipsoid, that is,
as the ellipsoid with the shape matrix all but one of whose eigenvalues
are :math:`\infty`. 
Polytope :math:`P(C,g)` is the
intersection of a finite number of closed halfspaces:

.. math:: 
   :label: polytope

   P = \{x\in{\bf R}^n ~|~ Cx\leqslant g\},

wherein :math:`C=[c_1 ~ \cdots ~ c_m]^T\in{\bf R}^{m\times n}` and
:math:`g=[\gamma_1 ~ \cdots ~ \gamma_m]^T\in{\bf R}^m`. 
The distance
from ellipsoid :math:`{\mathcal E}(q,Q)` to the polytope :math:`P(C,g)`
is

.. math::
   :label: dist_poly

   {\bf dist}({\mathcal E}(q,Q),P(C,g))=\min_{y\in P(C,g)}{\bf dist}({\mathcal E}(q,Q),y),


where :math:`{\bf dist}({\mathcal E}(q,Q),y)` comes from
([dist:sub:`p`\ oint]). If
:math:`{\bf dist}({\mathcal E}(q,Q),P(C,g))>0`, the ellipsoid and the
polytope do not intersect; if
:math:`{\bf dist}({\mathcal E}(q,Q),P(C,g))=0`, the ellipsoid touches
the polytope; if :math:`{\bf dist}({\mathcal E}(q,Q),P(C,g))<0`, the
ellipsoid intersects the polytope.

Checking if the intersection of :math:`k` nondegenerate ellipsoids
:math:`E(q_1,Q_1),\cdots,{\mathcal E}(q_k,Q_k)` intersects polytope
:math:`P(C,g)` is equivalent to the feasibility check of the QCQP
problem:

.. math:: \min 0

subject to:

.. math::

   \begin{aligned}
   \langle (x-q_i),Q_i^{-1}(x-q_i)\rangle - 1 \leqslant0, & & i=1,\cdots,k,\\
   \langle c_j, x\rangle - \gamma_j \leqslant0, & & j=1,\cdots,m.\end{aligned}

Operations with Ellipsoids
--------------------------

Affine Transformation
~~~~~~~~~~~~~~~~~~~~~

The simplest operation with ellipsoids is an affine transformation. Let
ellipsoid :math:`{\mathcal E}(q,Q)\subseteq{\bf R}^n`, matrix
:math:`A\in{\bf R}^{m\times n}` and vector :math:`b\in{\bf R}^m`. Then

.. math:: 
   :label: affinetrans

   A{\mathcal E}(q,Q) + b = {\mathcal E}(Aq+b, AQA^T) .

Thus, ellipsoids are preserved under affine transformation. If the rows
of :math:`A` are linearly independent (which implies
:math:`m\leqslant n`), and :math:`b=0`, the affine transformation is
called *projection*.

Geometric Sum
~~~~~~~~~~~~~

Consider the geometric sum :eq:`minksum` in which
:math:`{\mathcal X}_1,\cdots`,\ :math:`{\mathcal X}_k` are nondegenerate
ellipsoids :math:`{\mathcal E}(q_1,Q_1),\cdots`,
:math:`{\mathcal E}(q_k,Q_k)\subseteq{\bf R}^n`. The resulting set is
not generally an ellipsoid. However, it can be tightly approximated by
the parametrized families of external and internal ellipsoids.

Let parameter :math:`l` be some nonzero vector in :math:`{\bf R}^n`.
Then the external approximation :math:`{\mathcal E}(q,Q_l^+)` and the
internal approximation :math:`{\mathcal E}(q,Q_l^-)` of the sum
:math:`{\mathcal E}(q_1,Q_1)\oplus\cdots\oplus{\mathcal E}(q_k,Q_k)` are
*tight* along direction :math:`l`, i.e.,

.. math::

   {\mathcal E}(q,Q_l^-)\subseteq{\mathcal E}(q_1,Q_1)\oplus\cdots\oplus{\mathcal E}(q_k,Q_k)
   \subseteq{\mathcal E}(q,Q_l^+)

and

.. math::

   \rho(\pm l ~|~ {\mathcal E}(q,Q_l^-)) =
   \rho(\pm l ~|~ {\mathcal E}(q_1,Q_1)\oplus\cdots\oplus{\mathcal E}(q_k,Q_k)) =
   \rho(\pm l ~|~ {\mathcal E}(q,Q_l^+)).

Here the center :math:`q` is

.. math:: 
   :label: minksum_c

   q = q_1 + \cdots + q_k , 

the shape matrix of the external ellipsoid :math:`Q_l^+` is

.. math::
   :label: minksum_ea

   Q_l^+ = \left(\langle l,Q_1l\rangle^{1/2} + \cdots
   + \langle l,Q_kl\rangle^{1/2}\right)
   \left(\frac{1}{\langle l,Q_1l\rangle^{1/2}}Q_1 + \cdots +
   \frac{1}{\langle l,Q_kl\rangle^{1/2}}Q_k\right), 

and the shape matrix of the internal ellipsoid :math:`Q_l^-` is

.. math::
   :label: minksum_ia

   Q_l^- = \left(Q_1^{1/2} + S_2Q_2^{1/2} + \cdots + S_kQ_k^{1/2}\right)^T
   \left(Q_1^{1/2} + S_2Q_2^{1/2} + \cdots + S_kQ_k^{1/2}\right),

with matrices :math:`S_i`, :math:`i=2,\cdots,k`, being orthogonal
(:math:`S_iS_i^T=I`) and such that vectors
:math:`Q_1^{1/2}l, S_2Q_2^{1/2}l, \cdots, S_kQ_k^{1/2}l` are parallel.

Varying vector :math:`l` we get exact external and internal
approximations,

.. math::

   \bigcup_{\langle l,l\rangle=1} {\mathcal E}(q,Q_l^-) =
   {\mathcal E}(q_1,Q_1)\oplus\cdots\oplus{\mathcal E}(q_k,Q_k) =
   \bigcap_{\langle l,l\rangle=1} {\mathcal E}(q,Q_l^+) .

For proofs of formulas given in this section, see [KUR1997]_, [KUR2000]_.

One last comment is about how to find orthogonal matrices
:math:`S_2,\cdots,S_k` that align vectors
:math:`Q_2^{1/2}l, \cdots, Q_k^{1/2}l` with :math:`Q_1^{1/2}l`. Let
:math:`v_1` and :math:`v_2` be some unit vectors in :math:`{\bf R}^n`.
We have to find matrix :math:`S` such that
:math:`Sv_2\uparrow\uparrow v_1`. 
We suggest explicit formulas for the
calculation of this matrix [DAR2012]_:

.. math::
   :label: valign1

   T = I + Q_1(S - I)Q_1^T,  

.. math::
   :label: valign2

   S = \begin{pmatrix}
        c & s\\
        -s & c
       \end{pmatrix},\quad c = \langle\hat{v_1},\ \hat{v_2}\rangle,\ \quad s = \sqrt{1 - c^2},\ \quad \hat{v_i} = \dfrac{v_i}{\|v_i\|} 

.. math::
   :label: valign3

   Q_1 = [q_1 \, q_2]\in \mathbb{R}^{n\times2},\ \quad q_1 = \hat{v_1},\ \quad q_2 = \begin{cases}
   s^{-1}(\hat{v_2} - c\hat{v_1}),& s\ne 0\\
   0,& s = 0.
   \end{cases}

Geometric Difference
~~~~~~~~~~~~~~~~~~~~

Consider the geometric difference :eq:`minkdiff` in which the sets
:math:`{\mathcal X}_1` and :math:`{\mathcal X}_2` are nondegenerate
ellipsoids :math:`{\mathcal E}(q_1,Q_1)` and
:math:`{\mathcal E}(q_2,Q_2)`. We say that ellipsoid
:math:`{\mathcal E}(q_1,Q_1)` is *bigger* than ellipsoid
:math:`{\mathcal E}(q_2,Q_2)` if

.. math:: {\mathcal E}(0,Q_2) \subseteq {\mathcal E}(0,Q_1).

If this condition is not fulfilled, the geometric difference
:math:`{\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2)` is an empty
set:

.. math::

   {\mathcal E}(0,Q_2) \not\subseteq {\mathcal E}(0,Q_1) ~~~ \Rightarrow ~~~
   {\mathcal E}(q_1,Q_1) \dot{-}{\mathcal E}(q_2,Q_2) = \emptyset.

If :math:`{\mathcal E}(q_1,Q_1)` is bigger than
:math:`{\mathcal E}(q_2,Q_2)` and :math:`{\mathcal E}(q_2,Q_2)` is
bigger than :math:`{\mathcal E}(q_1,Q_1)`, in other words, if
:math:`Q_1=Q_2`,

.. math::

   {\mathcal E}(q_1,Q_1) \dot{-}{\mathcal E}(q_2,Q_2) = \{q_1-q_2\} ~~~ \mbox{and} ~~~
   {\mathcal E}(q_2,Q_2) \dot{-}{\mathcal E}(q_1,Q_1) = \{q_2-q_1\}.

To check if ellipsoid :math:`{\mathcal E}(q_1,Q_1)` is bigger than
ellipsoid :math:`{\mathcal E}(q_2,Q_2)`, we perform simultaneous
diagonalization of matrices :math:`Q_1` and :math:`Q_2`, that is, we
find matrix :math:`T` such that

.. math:: TQ_1T^T = I ~~~ \mbox{and} ~~~ TQ_2T^T=D,

where :math:`D` is some diagonal matrix. Simultaneous diagonalization
of :math:`Q_1` and :math:`Q_2` is possible because both are symmetric
positive definite (see [GANT1960]_). To find such matrix
:math:`T`, we first do the SVD of :math:`Q_1`:

.. math:: 
   :label: simdiag1

   Q_1 = U_1\Sigma_1V_1^T .

Then the SVD of matrix
:math:`\Sigma_1^{-1/2}U_1^TQ_2U_1\Sigma_1^{-1/2}`:

.. math:: 
   :label: simdiag2
   
   \Sigma_1^{-1/2}U_1^TQ_2U_1\Sigma_1^{-1/2} = U_2\Sigma_2V_2^T. 

Now, :math:`T` is defined as

.. math:: 
   :label: simdiag3

   T = U_2^T \Sigma_1^{-1/2}U_1^T. 

If the biggest diagonal element (eigenvalue) of matrix :math:`D=TQ_2T^T`
is less than or equal to :math:`1`,
:math:`{\mathcal E}(0,Q_2)\subseteq{\mathcal E}(0,Q_1)`.

Once it is established that ellipsoid :math:`{\mathcal E}(q_1,Q_1)` is
bigger than ellipsoid :math:`{\mathcal E}(q_2,Q_2)`, we know that their
geometric difference
:math:`{\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2)` is a nonempty
convex compact set. Although it is not generally an ellipsoid, we can
find tight external and internal approximations of this set parametrized
by vector :math:`l\in{\bf R}^n`. Unlike geometric sum, however,
ellipsoidal approximations for the geometric difference do not exist for
every direction :math:`l`. Vectors for which the approximations do not
exist are called *bad directions*.

Given two ellipsoids :math:`{\mathcal E}(q_1,Q_1)` and
:math:`{\mathcal E}(q_2,Q_2)` with
:math:`{\mathcal E}(0,Q_2)\subseteq{\mathcal E}(0,Q_1)`, :math:`l` is a
bad direction if

.. math:: \frac{\langle l,Q_1l\rangle^{1/2}}{\langle l,Q_2l\rangle^{1/2}}>r,

in which :math:`r` is a minimal root of the equation

.. math:: {\bf det}(Q_1-rQ_2) = 0.

To find :math:`r`, compute matrix :math:`T` by :eq:`simdiag1`-:eq:`simdiag3`
and define

.. math:: r = \frac{1}{\max({\bf diag}(TQ_2T^T))}.

If :math:`l` is *not* a bad direction, we can find tight external and
internal ellipsoidal approximations :math:`{\mathcal E}(q,Q^+_l)` and
:math:`{\mathcal E}(q,Q^-_l)` such that

.. math:: {\mathcal E}(q,Q^-_l)\subseteq{\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2)\subseteq{\mathcal E}(q,Q^+_l)

and

.. math::

   \rho(\pm l ~|~ {\mathcal E}(q,Q_l^-)) =
   \rho(\pm l ~|~ {\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2)) =
   \rho(\pm l ~|~ {\mathcal E}(q,Q_l^+)).

The center :math:`q` is

.. math:: 
   :label: minkdiff_c

   q = q_1 - q_2;  

the shape matrix of the internal ellipsoid :math:`Q^-_l` is

.. math::

   \begin{aligned}
   && P = \frac{\sqrt{\langle l, Q_1 l\rangle}}{\sqrt{\langle l, Q_2 \rangle}};\nonumber\\
   && Q^-_l = \left(1 - \dfrac{1}{P}\right)Q_1 + \left(1 - P\right)Q_2.
   \label{minkdiff_ia}\end{aligned}

and the shape matrix of the external ellipsoid :math:`Q^+_l` is

.. math::
   :label: minkdiff_ea

   Q^+_l = \left(Q_1^{1/2} - SQ_2^{1/2}\right)^T
   \left(Q_1^{1/2} - SQ_2^{1/2}\right). 

Here :math:`S` is an orthogonal matrix such that vectors
:math:`Q_1^{1/2}l` and :math:`SQ_2^{1/2}l` are parallel. :math:`S` is
found from :eq:`valign1`-:eq:`valign3`, with :math:`v_1=Q_2^{1/2}l` and
:math:`v_2=Q_1^{1/2}l`.

Running :math:`l` over all unit directions that are not bad, we get

.. math::

   \bigcup_{\langle l,l\rangle=1} {\mathcal E}(q,Q_l^-) =
   {\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2) =
   \bigcap_{\langle l,l\rangle=1} {\mathcal E}(q,Q_l^+) .

For proofs of formulas given in this section, see [KUR1997]_.

Geometric Difference-Sum
~~~~~~~~~~~~~~~~~~~~~~~~

Given ellipsoids :math:`{\mathcal E}(q_1,Q_1)`,
:math:`{\mathcal E}(q_2,Q_2)` and :math:`{\mathcal E}(q_3,Q_3)`, it is
possible to compute families of external and internal approximating
ellipsoids for

.. math:: 
   :label: minkmp

   {\mathcal E}(q_1,Q_1) \dot{-} {\mathcal E}(q_2,Q_2) \oplus {\mathcal E}(q_3,Q_3)

parametrized by direction :math:`l`, if this set is nonempty
(:math:`{\mathcal E}(0,Q_2)\subseteq{\mathcal E}(0,Q_1)`).

First, using the result of the previous section, for any direction
:math:`l` that is not bad, we obtain tight external
:math:`{\mathcal E}(q_1-q_2, Q_l^{0+})` and internal
:math:`{\mathcal E}(q_1-q_2, Q_l^{0-})` approximations of the set
:math:`{\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2)`.

The second and last step is, using the result of section 2.2.2, to find
tight external ellipsoidal approximation
:math:`{\mathcal E}(q_1-q_2+q_3,Q_l^+)` of the sum
:math:`{\mathcal E}(q_1-q_2,Q_l^{0+})\oplus{\mathcal E}(q_3,Q_3)`, and
tight internal ellipsoidal approximation
:math:`{\mathcal E}(q_1-q_2+q_3,Q_l^-)` for the sum
:math:`{\mathcal E}(q_1-q_2,Q_l^{0-})\oplus{\mathcal E}(q_3,Q_3)`.

As a result, we get

.. math::

   {\mathcal E}(q_1-q_2+q_3,Q_l^-) \subseteq
   {\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2)\oplus{\mathcal E}(q_3,Q_3) \subseteq
   {\mathcal E}(q_1-q_2+q_3,Q_l^+)

and

.. math::

   \rho(\pm l ~|~{\mathcal E}(q_1-q_2+q_3,Q_l^-)) =
   \rho(\pm l ~|~ {\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2)\oplus{\mathcal E}(q_3,Q_3)) =
   \rho(\pm l ~|~ {\mathcal E}(q_1-q_2+q_3,Q_l^+)).

Running :math:`l` over all unit vectors that are not bad, this
translates to

.. math::

   \bigcup_{\langle l,l\rangle=1} {\mathcal E}(q_1-q_2+q_3,Q_l^-) =
   {\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2)\oplus{\mathcal E}(q_3,Q_3) =
   \bigcap_{\langle l,l\rangle=1} {\mathcal E}(q_1-q_2+q_3,Q_l^+) .

Geometric Sum-Difference
~~~~~~~~~~~~~~~~~~~~~~~~

Given ellipsoids :math:`{\mathcal E}(q_1,Q1)`,
:math:`{\mathcal E}(q_2,Q_2)` and :math:`{\mathcal E}(q_3,Q_3)`, it is
possible to compute families of external and internal approximating
ellipsoids for

.. math:: 
   :label: minkpm

   {\mathcal E}(q_1,Q_1) \oplus {\mathcal E}(q_2,Q_2) \dot{-} {\mathcal E}(q_3,Q_3)

parametrized by direction :math:`l`, if this set is nonempty
(:math:`{\mathcal E}(0,Q_3)\subseteq{\mathcal E}(0,Q_1)\oplus{\mathcal E}(0,Q_2)`).

First, using the result of section 2.2.2, we obtain tight external
:math:`{\mathcal E}(q_1+q_2,Q_l^{0+})` and internal
:math:`{\mathcal E}(q_1+q_2,Q_l^{0-})` ellipsoidal approximations of the
set :math:`{\mathcal E}(q_1,Q_1)\oplus{\mathcal E}(q_2,Q_2)`. In order
for the set :eq:`minkpm` to be nonempty, inclusion
:math:`{\mathcal E}(0,Q_3)\subseteq{\mathcal E}(0,Q_l^{0+})` must be
true for any :math:`l`. Note, however, that even if :eq:`minkpm` is
nonempty, it may be that
:math:`{\mathcal E}(0,Q_3)\not\subseteq{\mathcal E}(0,Q_l^{0-})`, then
internal approximation for this direction does not exist.

Assuming that :eq:`minkpm` is nonempty and
:math:`{\mathcal E}(0,Q_3)\subseteq{\mathcal E}(0,Q_l^{0-})`, the second
step would be, using the results of section 2.2.3, to compute tight
external ellipsoidal approximation
:math:`{\mathcal E}(q_1+q_2-q_3,Q_l^+)` of the difference
:math:`{\mathcal E}(q_1+q_2,Q_l^{0+})\dot{-}{\mathcal E}(q_3,Q_3)`,
which exists only if :math:`l` is not bad, and tight internal
ellipsoidal approximation :math:`{\mathcal E}(q_1+q_2-q_3,Q_l^-)` of the
difference
:math:`{\mathcal E}(q_1+q_2,Q_l^{0-})\dot{-}{\mathcal E}(q_3,Q_3)`,
which exists only if :math:`l` is not bad for this difference.

If approximation :math:`{\mathcal E}(q_1+q_2-q_3,Q_l^+)` exists, then

.. math::

   {\mathcal E}(q_1,Q_1)\oplus{\mathcal E}(q_2,Q_2)\dot{-}{\mathcal E}(q_3,Q_3) \subseteq
   {\mathcal E}(q_1+q_2-q_3,Q_l^+)

and

.. math::

   \rho(\pm l ~|~ {\mathcal E}(q_1,Q_1)\oplus{\mathcal E}(q_2,Q_2)\dot{-}{\mathcal E}(q_3,Q_3)) =
   \rho(\pm l ~|~ {\mathcal E}(q_1+q_2-q_3,Q_l^+)).

If approximation :math:`{\mathcal E}(q_1+q_2-q_3,Q_l^-)` exists, then

.. math::

   {\mathcal E}(q_1+q_2-q_3,Q_l^-) \subseteq
   {\mathcal E}(q_1,Q_1)\oplus{\mathcal E}(q_2,Q_2)\dot{-}{\mathcal E}(q_3,Q_3)

and

.. math::

   \rho(\pm l ~|~{\mathcal E}(q_1+q_2-q_3,Q_l^-)) =
   \rho(\pm l ~|~ {\mathcal E}(q_1,Q_1)\oplus{\mathcal E}(q_2,Q_2)\dot{-}{\mathcal E}(q_3,Q_3)) .

For any fixed direction :math:`l` it may be the case that neither
external nor internal tight ellipsoidal approximations exist.

Intersection of Ellipsoid and Hyperplane
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let nondegenerate ellipsoid :math:`{\mathcal E}(q,Q)` and hyperplane
:math:`H(c,\gamma)` be such that
:math:`{\bf dist}({\mathcal E}(q,Q),H(c,\gamma))<0`. In other words,

.. math:: {\mathcal E}_H(w,W) = {\mathcal E}(q,Q)\cap H(c,\gamma) \neq \emptyset .

The intersection of ellipsoid with hyperplane, if nonempty, is always
an ellipsoid. Here we show how to find it.

First of all, we transform the hyperplane :math:`H(c,\gamma)` into
:math:`H([1~0~\cdots~0]^T, 0)` by the affine transformation

.. math:: y = Sx - \frac{\gamma}{\langle c,c\rangle^{1/2}}Sc,

where :math:`S` is an orthogonal matrix found by :eq:`valign1`-:eq:`valign3`
with :math:`v_1=c` and :math:`v_2=[1~0~\cdots~0]^T`. The ellipsoid in
the new coordinates becomes :math:`{\mathcal E}(q',Q')` with

.. math::

   \begin{aligned}
   q' & = q-\frac{\gamma}{\langle c,c\rangle^{1/2}}Sc, \\
   Q' & = SQS^T.\end{aligned}

Define matrix :math:`M=Q'^{-1}`; :math:`m_{11}` is its element in
position :math:`(1,1)`, :math:`\bar{m}` is the first column of :math:`M`
without the first element, and :math:`\bar{M}` is the submatrix of
:math:`M` obtained by stripping :math:`M` of its first row and first
column:

.. math::

   M = \left[\begin{array}{c|cl}
   m_{11} & & \bar{m}^T\\
    & \\
   \hline
    & \\
   \bar{m} & & \bar{M}\end{array}\right].

The ellipsoid resulting from the intersection is
:math:`{\mathcal E}_H(w',W')` with

.. math::

   \begin{aligned}
   w' & = q' + q_1'\left[\begin{array}{c}
   -1\\
   \bar{M}^{-1}\bar{m}\end{array}\right],\\
   W' & = \left(1-q_1'^2(m_{11}-
   \langle\bar{m},\bar{M}^{-1}\bar{m}\rangle)\right)\left[\begin{array}{c|cl}
   0 & & {\bf 0}\\
    & \\
   \hline
    & \\
   {\bf 0} & & \bar{M}^{-1}\end{array}\right],\end{aligned}

in which :math:`q_1'` represents the first element of vector :math:`q'`.

Finally, it remains to do the inverse transform of the coordinates to
obtain ellipsoid :math:`{\mathcal E}_H(w,W)`:

.. math::

   \begin{aligned}
   w & = S^Tw' + \frac{\gamma}{\langle c,c\rangle^{1/2}}c, \\
   W & = S^TW'S.\end{aligned}

Intersection of Ellipsoid and Ellipsoid
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Given two nondegenerate ellipsoids :math:`{\mathcal E}(q_1,Q_1)` and
:math:`{\mathcal E}(q_2,Q_2)`,
:math:`{\bf dist}({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2))<0`
implies that

.. math:: {\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2)\neq\emptyset .

This intersection can be approximated by ellipsoids from the outside
and from the inside. Trivially, both :math:`{\mathcal E}(q_1,Q_1)` and
:math:`{\mathcal E}(q_2,Q_2)` are external approximations of this
intersection. Here, however, we show how to find the external
ellipsoidal approximation of minimal volume.

Define matrices

.. math:: W_1 = Q_1^{-1}, ~~~~ W_2 = Q_2^{-1} .\label{wmatrices}

Minimal volume external ellipsoidal approximation
:math:`{\mathcal E}(q+,Q^+)` of the intersection
:math:`{\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2)` is determined
from the set of equations:

.. math::
   :label: fusion1

   Q^+  = \alpha X^{-1}, \\

.. math::
   :label: fusion2

   X  =  \pi W_1 + (1-\pi)W_2,\\

.. math::
   :label: fusion3

   \alpha  =  1-\pi(1-\pi)\langle(q_2-q_1), W_2X^{-1}W_1(q_2-q_1)\rangle, \\

.. math::
   :label: fusion4

   q^+  = X^{-1}(\pi W_1q_1 + (1-\pi)W_2q_2), \\

.. math::
   :label: fusion5

   0 &=  \alpha({\bf det}(X))^2{\bf trace}(X^{-1}(W_1-W_2)) - {}\\
     &- n({\bf det}(X))^2 (2\langle q^+,W_1q_1-W_2q_2\rangle + \langle q^+,(W_2-W_1)q^+\rangle - {}\\
     &- \langle q_1,W_1q_1\rangle + \langle q_2,W_2q_2\rangle), 

with :math:`0\leqslant\pi\leqslant1`. We substitute :math:`X`,
:math:`\alpha`, :math:`q^+` defined in :eq:`fusion2`-:eq:`fusion4` into
:eq:`fusion5` and get a polynomial of degree :math:`2n-1` with respect to
:math:`\pi`, which has only one root in the interval :math:`[0,1]`,
:math:`\pi_0`. Then, substituting :math:`\pi=\pi_0` into
:eq:`fusion1`-:eq:`fusion4`, we obtain :math:`q^+` and :math:`Q^+`. Special
cases are :math:`\pi_0=1`, whence
:math:`{\mathcal E}(q^+,Q^+)={\mathcal E}(q_1,Q_1)`, and
:math:`\pi_0=0`, whence
:math:`{\mathcal E}(q^+,Q^+)={\mathcal E}(q_2,Q_2)`. These situations
may occur if, for example, one ellipsoid is contained in the other:

.. math::

   {\mathcal E}(q_1,Q_1)\subseteq{\mathcal E}(q_2,Q_2) & \Rightarrow \pi_0 = 1,\\   
   {\mathcal E}(q_2,Q_2)\subseteq{\mathcal E}(q_1,Q_1) & \Rightarrow \pi_0 = 0.

The proof that the system of equations :eq:`fusion1`-:eq:`fusion5` correctly
defines the minimal volume external ellipsoidal approximationi of the
intersection :math:`{\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2)` is
given in [ROS2002]_.

To find the internal approximating ellipsoid
:math:`{\mathcal E}(q^-,Q^-)\subseteq{\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2)`,
define

.. math::
   :label: beta1

   \beta_1 = \min_{\langle x,W_2x\rangle=1}\langle x,W_1x\rangle,

.. math::
   :label: beta2

   \beta_2 = \min_{\langle x,W_1x\rangle=1}\langle x,W_2x\rangle,

Notice that :eq:`beta1` and :eq:`beta2` are QCQP problems. Parameters
:math:`\beta_1` and :math:`\beta_2` are invariant with respect to affine
coordinate transformation and describe the position of ellipsoids
:math:`{\mathcal E}(q_1,Q_1)`, :math:`{\mathcal E}(q_2,Q_2)` with
respect to each other:

.. math::

   \beta_1\geqslant1,~\beta_2\geqslant1 & \Rightarrow
   {\bf int}({\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2))=\emptyset, \\

   \beta_1\geqslant1,~\beta_2\leqslant1 & \Rightarrow {\mathcal E}(q_1,Q_1)\subseteq{\mathcal E}(q_2,Q_2), \\

   \beta_1\leqslant1,~\beta_2\geqslant1 & \Rightarrow {\mathcal E}(q_2,Q_2)\subseteq{\mathcal E}(q_1,Q_1), \\

   \beta_1<1,~\beta_2<1 & \Rightarrow
   {\bf int}({\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2))\neq\emptyset \\

   &\mbox{and} ~ {\mathcal E}(q_1,Q_1)\not\subseteq{\mathcal E}(q_2,Q_2) \\

   &\mbox{and} ~ {\mathcal E}(q_2,Q_2)\not\subseteq{\mathcal E}(q_1,Q_1).

Define parametrized family of internal ellipsoids
:math:`{\mathcal E}(q^-_{\theta_1\theta_2},Q^-_{\theta_1\theta_2})` with

.. math::
   :label: paramell1

   q^-_{\theta_1\theta_2}  =  (\theta_1W_1 +
   \theta_2W_2)^{-1}(\theta_1W_1q_1 + \theta_2W_2q_2),\\

.. math::
   :label: paramell2

   Q^-_{\theta_1\theta_2} =  (1 - \theta_1\langle q_1,W_1q_1\rangle -
   \theta_2\langle q_2,W_2q_2\rangle +
   \langle q^-_{\theta_1\theta_2},(Q^-)^{-1}q^-_{\theta_1\theta_2}\rangle)
   (\theta_1W_1 + \theta_2W_2)^{-1} .

The best internal ellipsoid
:math:`{\mathcal E}(q^-_{\hat{\theta}_1\hat{\theta}_2},Q^-_{\hat{\theta}_1\hat{\theta}_2})`
in the class :eq:`paramell1`-:eq:`paramell2`, namely, such that

.. math::

   {\mathcal E}(q^-_{{\theta}_1{\theta}_2},Q^-_{{\theta}_1{\theta}_2})\subseteq
   {\mathcal E}(q^-_{\hat{\theta}_1\hat{\theta}_2},Q^-_{\hat{\theta}_1\hat{\theta}_2})
   \subseteq {\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2)

for all :math:`0\leqslant\theta_1,\theta_2\leqslant1`, is specified by
the parameters

.. math::
   :label: thetapar

   \hat{\theta}_1 = \frac{1-\hat{\beta}_2}{1-\hat{\beta}_1\hat{\beta}_2}, ~~~~
   \hat{\theta}_2 = \frac{1-\hat{\beta}_1}{1-\hat{\beta}_1\hat{\beta}_2},

with

.. math:: \hat{\beta}_1=\min(1,\beta_1), ~~~~ \hat{\beta}_2=\min(1,\beta_2).

It is the ellipsoid that we look for:
:math:`{\mathcal E}(q^-,Q^-)={\mathcal E}(q^-_{\hat{\theta}_1\hat{\theta}_2},Q^-_{\hat{\theta}_1\hat{\theta}_2})`.
Two special cases are

.. math::

   \hat{\theta}_1=1, ~ \hat{\theta}_2=0 ~~~ \Rightarrow ~~~
   {\mathcal E}(q_1,Q_1)\subseteq{\mathcal E}(q_2,Q_2) ~~~ \Rightarrow ~~~
   {\mathcal E}(q^-,Q^-)={\mathcal E}(q_1,Q_1),

and

.. math::

   \hat{\theta}_1=0, ~ \hat{\theta}_2=1 ~~~ \Rightarrow ~~~
   {\mathcal E}(q_2,Q_2)\subseteq{\mathcal E}(q_1,Q_1) ~~~ \Rightarrow ~~~
   {\mathcal E}(q^-,Q^-)={\mathcal E}(q_2,Q_2).

The method of finding the internal ellipsoidal approximation of the
intersection of two ellipsoids is described in [VAZ1999]_.

Intersection of Ellipsoid and Halfspace
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Finding the intersection of ellipsoid and halfspace can be reduced to
finding the intersection of two ellipsoids, one of which is unbounded.
Let :math:`{\mathcal E}(q_1,Q_1)` be a nondegenerate ellipsoid and let
:math:`H(c,\gamma)` define the halfspace

.. math:: {\bf S}(c,\gamma) = \{x\in{\bf R}^n ~|~ \langle c,x\rangle\leqslant\gamma\}.

We have to determine if the intersection
:math:`{\mathcal E}(q_1,Q_1)\cap{\bf S}(c,\gamma)` is empty, and if not,
find its external and internal ellipsoidal approximations,
:math:`{\mathcal E}(q^+,Q^+)` and :math:`{\mathcal E}(q^-,Q^-)`. Two
trivial situations are:

-  :math:`{\bf dist}({\mathcal E}(q_1,Q_1),H(c,\gamma))>0` and
   :math:`\langle c, q_1\rangle>0`, which implies that
   :math:`{\mathcal E}(q_1,Q_1)\cap{\bf S}(c,\gamma)=\emptyset`;

-  :math:`{\bf dist}({\mathcal E}(q_1,Q_1),H(c,\gamma))>0` and
   :math:`\langle c, q_1\rangle<0`, so that
   :math:`{\mathcal E}(q_1,Q_1)\subseteq{\bf S}(c,\gamma)`, and then
   :math:`{\mathcal E}(q^+,Q^+)={\mathcal E}(q^-,Q^-)={\mathcal E}(q_1,Q_1)`.

In case :math:`{\bf dist}({\mathcal E}(q_1,Q_1),H(c,\gamma)<0`, i.e. the
ellipsoid intersects the hyperplane,

.. math::

   {\mathcal E}(q_1,Q_1)\cap{\bf S}(c,\gamma) =
   {\mathcal E}(q_1,Q_1)\cap\{x ~|~ \langle (x-q_2),W_2(x-q_2)\rangle\leqslant1\},

with

.. math::
   :label: hsell1

   q_2  =  (\gamma + 2\sqrt{\overline{\lambda}})c,\\

.. math::
   :label: hsell2

   W_2  =  \frac{1}{4\overline{\lambda}}cc^T,

:math:`\overline{\lambda}` being the biggest eigenvalue of matrix
:math:`Q_1`. After defining :math:`W_1=Q_1^{-1}`, we obtain
:math:`{\mathcal E}(q^+,Q^+)` from equations :eq:`fusion1`-:eq:`fusion5`, and
:math:`{\mathcal E}(q^-,Q^-)` from :eq:`paramell1`-:eq:`paramell2`,
:eq:`thetapar`.

**Remark.** Notice that matrix :math:`W_2` has rank :math:`1`, which
makes it singular for :math:`n>1`. Nevertheless, expressions
:eq:`fusion1`-:eq:`fusion2`, :eq:`paramell1`-:eq:`paramell2` make sense because
:math:`W_1` is nonsingular, :math:`\pi_0\neq0` and
:math:`\hat{\theta}_1\neq0`.

To find the ellipsoidal approximations :math:`{\mathcal E}(q^+,Q^+)` and
:math:`{\mathcal E}(q^-,Q^-)` of the intersection of ellipsoid
:math:`{\mathcal E}(q,Q)` and polytope :math:`P(C,g)`,
:math:`C\in{\bf R}^{m\times n}`, :math:`b\in{\bf R}^m`, such that

.. math:: {\mathcal E}(q^-,Q^-)\subseteq{\mathcal E}(q,Q)\cap P(C,g)\subseteq{\mathcal E}(q^+,Q^+),

we first compute

.. math::

   {\mathcal E}(q^-_1,Q^-_1)\subseteq{\mathcal E}(q,Q)\cap{\bf S}(c_1,\gamma_1)\subseteq
   {\mathcal E}(q^+_1,Q^+_1),

wherein :math:`{\bf S}(c_1,\gamma_1)` is the halfspace defined by the
first row of matrix :math:`C`, :math:`c_1`, and the first element of
vector :math:`g`, :math:`\gamma_1`. Then, one by one, we get

.. math::

   \begin{aligned}
   & & {\mathcal E}(q^-_2,Q^-_2)\subseteq{\mathcal E}(q^-_1,Q^-_1)\cap{\bf S}(c_2,\gamma_2), ~~~
   {\mathcal E}(q^+_1,Q^+_1)\cap{\bf S}(c_2,\gamma_2)\subseteq{\mathcal E}(q^+_2,Q^+_2), \\
   & & {\mathcal E}(q^-_3,Q^-_3)\subseteq{\mathcal E}(q^-_2,Q^-_2)\cap{\bf S}(c_3,\gamma_3), ~~~
   {\mathcal E}(q^+_2,Q^+_2)\cap{\bf S}(c_3,\gamma_3)\subseteq{\mathcal E}(q^+_3,Q^+_3), \\
   & & \cdots \\
   & & {\mathcal E}(q^-_m,Q^-_m)\subseteq{\mathcal E}(q^-_{m-1},Q^-_{m-1})\cap{\bf S}(c_m,\gamma_m), ~~~
   {\mathcal E}(q^+_{m-1},Q^+_{m-1})\cap{\bf S}(c_m,\gamma_m)\subseteq{\mathcal E}(q^+_m,Q^+_m), \\\end{aligned}

The resulting ellipsoidal approximations are

.. math:: {\mathcal E}(q^+,Q^+)={\mathcal E}(q^+_m,Q^+_m), ~~~~ {\mathcal E}(q^-,Q^-)={\mathcal E}(q^-_m,Q^-_m) .

Checking if one ellipsoid contains another
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Theorem of alternatives, also known as :math:`S`-procedure [BOYD2004]_, 
states that the implication

.. math::

   \langle x, A_1x\rangle + 2\langle b_1,x\rangle + c_1 \leqslant0
   ~~ \Rightarrow ~~
   \langle x, A_2x\rangle + 2\langle b_2,x\rangle + c_2 \leqslant0,

where :math:`A_i\in{\bf R}^{n\times n}` are symmetric matrices,
:math:`b_i\in{\bf R}^n`, :math:`c_i\in{\bf R}`, :math:`i=1,2`, holds if
and only if there exists :math:`\lambda>0` such that

.. math::

   \left[\begin{array}{cc}
   A_2 & b_2\\
   b_2^T & c_2\end{array}\right]
   \preceq
   \lambda\left[\begin{array}{cc}
   A_1 & b_1\\
   b_1^T & c_1\end{array}\right].

By :math:`S`-procedure,
:math:`{\mathcal E}(q_1,Q_1)\subseteq{\mathcal E}(q_2,Q_2)` (both
ellipsoids are assumed to be nondegenerate) if and only if the following
SDP problem is feasible:

.. math:: \min 0

subject to:

.. math::

   \begin{aligned}
   \lambda & >  0, \\
   \left[\begin{array}{cc}
   Q_2^{-1} & -Q_2^{-1}q_2\\
   (-Q_2^{-1}q_2)^T & q_2^TQ_2^{-1}q_2-1\end{array}\right]
   & \preceq 
   \lambda \left[\begin{array}{cc}
   Q_1^{-1} & -Q_1^{-1}q_1\\
   (-Q_1^{-1}q_1)^T & q_1^TQ_1^{-1}q_1-1\end{array}\right]\end{aligned}

where :math:`\lambda\in{\bf R}` is the variable.

Minimum Volume Ellipsoids
~~~~~~~~~~~~~~~~~~~~~~~~~

The minimum volume ellipsoid that contains set :math:`S` is called
*Löwner-John ellipsoid* of the set :math:`S`. To characterize it we
rewrite general ellipsoid :math:`{\mathcal E}(q,Q)` as

.. math:: {\mathcal E}(q,Q) = \{x ~|~ \langle (Ax + b), (Ax + b)\rangle \},

where

.. math:: A = Q^{-1/2} ~~~ \mbox{ and } ~~~ b = -Aq .

For positive definite matrix :math:`A`, the volume of
:math:`{\mathcal E}(q,Q)` is proportional to :math:`\det A^{-1}`. So,
finding the minimum volume ellipsoid containing :math:`S` can be
expressed as semidefinite programming (SDP) problem

.. math:: \min \log \det A^{-1}

subject to:

.. math:: \sup_{v\in S} \langle (Av + b), (Av + b)\rangle \leqslant1,

where the variables are :math:`A\in{\bf R}^{n\times n}` and
:math:`b\in{\bf R}^n`, and there is an implicit constraint
:math:`A\succ 0` (:math:`A` is positive definite). The objective and
constraint functions are both convex in :math:`A` and :math:`b`, so this
problem is convex. Evaluating the constraint function, however, requires
solving a convex maximization problem, and is tractable only in certain
special cases.

For a finite set :math:`S=\{x_1,\cdots,x_m\}\subset{\bf R}^n`, an
ellipsoid covers :math:`S` if and only if it covers its convex hull. So,
finding the minimum volume ellipsoid covering :math:`S` is the same as
finding the minimum volume ellipsoid containing the polytope
:math:`{\bf conv}\{x_1,\cdots,x_m\}`. The SDP problem is

.. math:: \min \log \det A^{-1}

subject to:

.. math::

   \begin{aligned}
   A & \succ  0, \\
   \langle (Ax_i + b), (Ax_i + b)\rangle & \leqslant 1, ~~~ i=1..m.\end{aligned}

We can find the minimum volume ellipsoid containing the union of
ellipsoids :math:`\bigcup_{i=1}^m{\mathcal E}(q_i,Q_i)`. Using the fact
that for :math:`i=1..m`
:math:`{\mathcal E}(q_i,Q_i)\subseteq{\mathcal E}(q,Q)` if and only if
there exists :math:`\lambda_i>0` such that

.. math::

   \left[\begin{array}{cc}
   A^2 - \lambda_i Q_i^{-1} & Ab + \lambda_i Q_i^{-1}q_i\\
   (Ab + \lambda_i Q_i^{-1}q_i)^T & b^Tb-1 - \lambda_i (q_i^TQ_i^{-1}q_i-1) \end{array}
   \right] \preceq 0 .

Changing variable :math:`\tilde{b}=Ab`, we get convex SDP in the
variables :math:`A`, :math:`\tilde{b}`, and
:math:`\lambda_1,\cdots,\lambda_m`:

.. math:: \min \log \det A^{-1}

subject to:

.. math::

   \begin{aligned}
   \lambda_i & > 0,\\
   \left[\begin{array}{ccc}
   A^2-\lambda_iQ_i^{-1} & \tilde{b}+\lambda_iQ_i^{-1}q_i & 0 \\
   (\tilde{b}+\lambda_iQ_i^{-1}q_i)^T & -1-\lambda_i(q_i^TQ_i^{-1}q_i-1) & \tilde{b}^T \\
   0 & \tilde{b} & -A^2\end{array}\right] & \preceq 0, ~~~ i=1..m.\end{aligned}

After :math:`A` and :math:`b` are found,

.. math:: q=-A^{-1}b ~~~ \mbox{ and } ~~~ Q=(A^TA)^{-1}.

The results on the minimum volume ellipsoids are explained and proven in
[BOYD2004]_.

Maximum Volume Ellipsoids
~~~~~~~~~~~~~~~~~~~~~~~~~

Consider a problem of finding the maximum volume ellipsoid that lies
inside a bounded convex set :math:`S` with nonempty interior. To
formulate this problem we rewrite general ellipsoid
:math:`{\mathcal E}(q,Q)` as

.. math:: {\mathcal E}(q,Q) = \{Bx + q ~|~ \langle x,x\rangle\leqslant1\},

where :math:`B=Q^{1/2}`, so the volume of :math:`{\mathcal E}(q,Q)` is
proportional to :math:`\det B`.

The maximum volume ellipsoid that lies inside :math:`S` can be found by
solving the following SDP problem:

.. math:: \max \log \det B

subject to:

.. math:: \sup_{\langle v,v\rangle\leqslant1} I_S(Bv+q)\leqslant0 ,

in the variables :math:`B\in{\bf R}^{n\times n}` - symmetric matrix,
and :math:`q\in{\bf R}^n`, with implicit constraint :math:`B\succ 0`,
where :math:`I_S` is the indicator function:

.. math::

   I_S(x) = \left\{\begin{array}{ll}
   0, & \mbox{ if } x\in S,\\
   \infty, & \mbox{ otherwise.}\end{array}\right.

In case of polytope, :math:`S=P(C,g)` with :math:`P(C,g)` defined in
:eq:`polytope`, the SDP has the form

.. math:: \min \log \det B^{-1}

subject to:

.. math::

   \begin{aligned}
   B & \succ 0,\\
   \langle c_i, Bc_i\rangle + \langle c_i, q\rangle & \leqslant \gamma_i,
   ~~~ i=1..m.\end{aligned}

We can find the maximum volume ellipsoid that lies inside the
intersection of given ellipsoids
:math:`\bigcap_{i=1}^m{\mathcal E}(q_i,Q_i)`. Using the fact that for
:math:`i=1..m` :math:`{\mathcal E}(q,Q)\subseteq{\mathcal E}(q_i,Q_i)`
if and only if there exists :math:`\lambda_i>0` such that

.. math::

   \left[\begin{array}{cc}
   -\lambda_i - q^TQ_i^{-1}q + 2q_i^TQ_i^{-1}q - q_i^TQ_i^{-1}q_i + 1 & (Q_i^{-1}q-Q_i^{-1}q_i)^TB\\
   B(Q_i^{-1}q-Q_i^{-1}q_i) & \lambda_iI-BQ_i^{-1}B\end{array}\right] \succeq 0.

To find the maximum volume ellipsoid, we solve convex SDP in variables
:math:`B`, :math:`q`, and :math:`\lambda_1,\cdots,\lambda_m`:

.. math:: \min \log \det B^{-1}

subject to:

.. math::

   \begin{aligned}
   \lambda_i & >  0, \\
   \left[\begin{array}{ccc}
   1-\lambda_i & 0 & (q - q_i)^T\\
   0 & \lambda_iI & B\\
   q - q_i & B & Q_i\end{array}\right] & \succeq  0, ~~~ i=1..m.\end{aligned}

After :math:`B` and :math:`q` are found,

.. math:: Q = B^TB.

The results on the maximum volume ellipsoids are explained and proven in
[BOYD2004]_.

Reachability
============

Basics of Reachability Analysis
-------------------------------

Systems without disturbances
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider a general continuous-time

.. math::
   :label: ctds1

   \dot{x}(t) = f(t, x, u),

or discrete-time dynamical system

.. math::
   :label: dtds1

   x(t+1) = f(t, x, u),
.. \tag*{(\ref{ctds1}d)}

wherein :math:`t` is time [1]_, :math:`x\in{\bf R}^n` is the state,
:math:`u\in{\bf R}^m` is the control, and :math:`f` is a measurable
vector function taking values in :math:`{\bf R}^n`. [2]_ The control
values :math:`u(t, x(t))` are restricted to a closed compact control set
:math:`{\mathcal U}(t)\subset{\bf R}^m`. An *open-loop* control does not
depend on the state, :math:`u=u(t)`; for a *closed-loop* control,
:math:`u=u(t, x(t))`.

The (forward) reach set :math:`{\mathcal X}(t, t_0, x_0)` at time
:math:`t>t_0` from the initial position :math:`(t_0, x_0)` is the set of
all states :math:`x(t)` reachable at time :math:`t` by system :eq:`ctds1`,
or :eq:`dtds1`, with :math:`x(t_0)=x_0` through all possible controls
:math:`u(\tau, x(\tau))\in{\mathcal U}(\tau)`,
:math:`t_0\leqslant\tau< t`. For a given set of initial states
:math:`{\mathcal X}_0`, the reach set
:math:`{\mathcal X}(t, t_0, {\mathcal X}_0)` is

.. math:: {\mathcal X}(t, t_0, {\mathcal X}_0) = \bigcup_{x_0\in{\mathcal X}_0}{\mathcal X}(t, t_0, x_0).

Here are two facts about forward reach sets.

#. :math:`{\mathcal X}(t, t_0, {\mathcal X}_0)` is the same for
   open-loop and closed-loop control.

#. :math:`{\mathcal X}(t, t_0, {\mathcal X}_0)` satisfies the semigroup
   property,

   .. math::
      :label: semigroup

      {\mathcal X}(t, t_0, {\mathcal X}_0) = {\mathcal X}(t, \tau, {\mathcal X}(\tau, t_0, {\mathcal X}_0)), \;\;\;
      t_0\leqslant\tau< t.

For linear systems

.. math::
   :label: linearrhs

   f(t, x, u) = A(t)x(t) + B(t)u,


with matrices :math:`A(t)` in :math:`{\bf R}^{n\times n}` and
:math:`B(t)` in :math:`{\bf R}^{m\times n}`. For continuous-time linear
system the state transition matrix is

.. math:: \dot{\Phi}(t, t_0) = A(t)\Phi(t, t_0), \Phi(t, t) = I,

which for constant :math:`A(t)\equiv A` simplifies as

.. math:: \Phi(t, t_0) = e^{A(t-t_0)} .

For discrete-time linear system the state transition matrix is

.. math:: \Phi(t+1, t_0) = A(t)\Phi(t, t_0), \Phi(t, t) = I,

which for constant :math:`A(t)\equiv A` simplifies as

.. math:: \Phi(t, t_0) = A^{t-t_0} .

If the state transition matrix is invertible,
:math:`\Phi^{-1}(t, t_0) = \Phi(t_0, t)`. The transition matrix is
always invertible for continuous-time and for sampled discrete-time
systems. However, if for some :math:`\tau`, :math:`t_0\leqslant\tau<t`,
:math:`A(\tau)` is degenerate (singular),
:math:`\Phi(t, t_0)=\prod_{\tau=t_0}^{t-1}A(\tau)`, is also degenerate
and cannot be inverted.

Following Cauchy’s formula, the reach set
:math:`{\mathcal X}(t, t_0, {\mathcal X}_0)` for a linear system can be
expressed as

.. math::
   :label: ctlsrs

   {\mathcal X}(t, t_0, {\mathcal X}_0) =
   \Phi(t, t_0){\mathcal X}_0 \oplus \int_{t_0}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau

in continuous-time, and as

.. math::
   :label: dtlsrs

   {\mathcal X}(t, t_0, {\mathcal X}_0) =
   \Phi(t, t_0){\mathcal X}_0 \oplus \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)
.. \tag*{(\ref{ctlsrs}d)}


in discrete-time case.

The operation ‘:math:`\oplus`’ is the *geometric sum*, also known as
*Minkowski sum*. [3]_ The geometric sum and linear (or affine)
transformations preserve compactness and convexity. Hence, if the
initial set :math:`{\mathcal X}_0` and the control sets
:math:`{\mathcal U}(\tau)`, :math:`t_0\leqslant\tau<t`, are compact and
convex, so is the reach set
:math:`{\mathcal X}(t, t_0, {\mathcal X}_0)`.

The backward reach set :math:`{\mathcal Y}(t_1, t, y_1)` for the target
position :math:`(t_1, y_1)` is the set of all states :math:`y(t)` for
which there exists some control
:math:`u(\tau, x(\tau))\in{\mathcal U}(\tau)`,
:math:`t\leqslant\tau<t_1`, that steers system :eq:`ctds1`, or :eq:`dtds1` to
the state :math:`y_1` at time :math:`t_1`. For the target set
:math:`{\mathcal Y}_1` at time :math:`t_1`, the backward reach set
:math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` is

.. math:: {\mathcal Y}(t_1, t, {\mathcal Y}_1) = \bigcup_{y_1\in{\mathcal Y}_1}{\mathcal Y}(t_1, t, y_1).

The backward reach set
:math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` is the largest *weakly
invariant* set with respect to the target set :math:`{\mathcal Y}_1` and
time values :math:`t` and :math:`t_1`. [4]_

**Remark.** Backward reach set can be computed for continuous-time
system only if the solution of :eq:`ctds1` exists for :math:`t<t_1`; and
for discrete-time system only if the right hand side of :eq:`dtds1` is
invertible [5]_.

These two facts about the backward reach set :math:`{\mathcal Y}` are
similar to those for forward reach sets.

#. :math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` is the same for
   open-loop and closed-loop control.

#. :math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` satisfies the semigroup
   property,

   .. math::
      :label: semigroup_b

      {\mathcal Y}(t_1, t, {\mathcal Y}_1) = {\mathcal Y}(\tau, t, {\mathcal Y}(t_1, \tau, {\mathcal Y}_1)), \;\;\;
      t\leqslant\tau< t_1.

For the linear system :eq:`linearrhs` the backward reach set can be
expressed as

.. math::
   :label: ctlsbrs

   {\mathcal Y}(t_1, t, {\mathcal Y}_1) =
   \Phi(t, t_1){\mathcal Y}_1 \oplus \int_{t_1}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau

in the continuous-time case, and as

.. math::
   :label: dtlsbrs

   {\mathcal Y}(t_1, t, {\mathcal Y}_1) =
   \Phi(t, t_1){\mathcal Y}_1 \oplus \sum_{\tau =t}^{t_1-1}-\Phi(t, \tau)B(\tau){\mathcal U}(\tau)
.. \tag*{(\ref{ctlsbrs}d)}

in discrete-time case. The last formula makes sense only for
discrete-time linear systems with invertible state transition matrix.
Degenerate discrete-time linear systems have unbounded backward reach
sets and such sets cannot be computed with available software tools.

Just as in the case of forward reach set, the backward reach set of a
linear system :math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` is compact
and convex if the target set :math:`{\mathcal Y}_1` and the control sets
:math:`{\mathcal U}(\tau)`, :math:`t\leqslant\tau<t_1`, are compact and
convex.

**Remark.** In the computer science literature the reach set is said to
be the result of operator *post*, and the backward reach set is the
result of operator *pre*. In the control literature the backward reach
set is also called the *solvability set*.

Systems with disturbances
~~~~~~~~~~~~~~~~~~~~~~~~~

Consider the continuous-time dynamical system with disturbance

.. math::
   :label: ctds2

   \dot{x}(t) = f(t, x, u, v),

or the discrete-time dynamical system with disturbance

.. math::
   :label: dtds2

   x(t+1) = f(t, x, u, v),
.. \tag*{(\ref{ctds2}d)}


in which we also have the disturbance input :math:`v\in{\bf R}^d` with
values :math:`v(t)` restricted to a closed compact set
:math:`{\mathcal V}(t)\subset{\bf R}^d`.

In the presence of disturbances the open-loop reach set (OLRS) is
different from the closed-loop reach set (CLRS).

Given the initial time :math:`t_0`, the set of initial states
:math:`{\mathcal X}_0`, and terminal time :math:`t`, there are two types
of OLRS.

The maxmin open-loop reach set
:math:`\overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)` is the set
of all states :math:`x`, such that for any disturbance
:math:`v(\tau)\in{\mathcal V}(\tau)`, there exist an initial state
:math:`x_0\in{\mathcal X}_0` and a control
:math:`u(\tau)\in{\mathcal U}(\tau)`, :math:`t_0\leqslant\tau<t`, that
steers system :eq:`ctds2` or :eq:`dtds2` from :math:`x(t_0)=x_0` to
:math:`x(t)=x`. 

The minmax open-loop reach set
:math:`\underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)` is the set
of all states :math:`x`, such that there exists a control
:math:`u(\tau)\in{\mathcal U}(\tau)` that for all disturbances
:math:`v(\tau)\in{\mathcal V}(\tau)`, :math:`t_0\leqslant\tau<t`,
assigns an initial state :math:`x_0\in{\mathcal X}_0` and steers system
:eq:`ctds2`, or :eq:`dtds2`, from :math:`x(t_0)=x_0` to :math:`x(t)=x`.

In the maxmin case the control is chosen
*after* knowing the disturbance over the entire time interval
:math:`[t_0, t]`, whereas in the minmax case the control is chosen
*before* any knowledge of the disturbance. Consequently, the OLRS do not
satisfy the semigroup property.

The terms ‘maxmin’ and ‘minmax’ come from the fact that
:math:`\overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)` is the
subzero level set of the value function

.. math::
   :label: maxminvf

   \underline{V}(t, x) =
   \max_v\min_u\{{\bf dist}(x(t_0), {\mathcal X}_0) ~|~ x(t)=x, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t_0\leqslant\tau<t\},

i.e.,
:math:`\overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \{ x~|~\underline{V}(t, x) \leqslant0\}`,
and :math:`\underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)` is the
subzero level set of the value function

.. math::
   :label: minmaxvf

   \overline{V}(t, x) =
   \min_u\max_v\{{\bf dist}(x(t_0), {\mathcal X}_0) ~|~ x(t)=x, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t_0\leqslant\tau<t\},

in which :math:`{\bf dist}(\cdot, \cdot)` denotes Hausdorff
semidistance. [6]_ Since
:math:`\underline{V}(t, x)\leqslant\overline{V}(t, x)`,
:math:`\underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)\subseteq\overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)`.

Note that maxmin and minmax OLRS imply *guarantees*: these are states
that can be reached no matter what the disturbance is, whether it is
known in advance (maxmin case) or not (minmax case). The OLRS may be
empty.

Fixing time instant :math:`\tau_1`, :math:`t_0<\tau_1<t`, define the
*piecewise maxmin open-loop reach set with one correction*,

.. math::
   :label: maxmin1

   \overline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0) = \overline{{\mathcal X}}_{OL}(t, \tau_1, \overline{{\mathcal X}}_{OL}(\tau_1, t_0, {\mathcal X}_0)),

and the *piecewise minmax open-loop reach set with one correction*,

.. math::
   :label: minmax1

   \underline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0) = \underline{{\mathcal X}}_{OL}(t, \tau_1, \underline{{\mathcal X}}_{OL}(\tau_1, t_0, {\mathcal X}_0)).

The piecewise maxmin OLRS
:math:`\overline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0)` is the
subzero level set of the value function

.. math::
   :label: maxminvf1

   \underline{V}^1(t, x) =
   \max_v\min_u\{\underline{V}(\tau_1, x(\tau_1)) ~|~ x(t)=x, \;
   u(\tau)\in{\mathcal U}(\tau), \; v(\tau)\in{\mathcal V}(\tau), \; \tau_1\leqslant\tau<t\},

with :math:`V(\tau_1, x(\tau_1))` given by :eq:`maxminvf`, which yields

.. math:: \underline{V}^1(t, x) \geqslant\underline{V}(t, x),

and thus,

.. math:: \overline{{\mathcal X}}_{OL}^1(t, t_0 {\mathcal X}_0) \subseteq \overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) .

On the other hand, the piecewise minmax OLRS
:math:`\underline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0)` is the
subzero level set of the value function

.. math::
   :label: minmaxvf1

   \overline{V}^1(t, x) =
   \min_u\max_v\{\overline{V}(\tau_1, x(\tau_1)) ~|~ x(t)=x, \;
   u(\tau)\in{\mathcal U}(\tau), \; v(\tau)\in{\mathcal V}(\tau), \; \tau_1\leqslant\tau<t\},

with :math:`V(\tau_1, x(\tau_1))` given by :eq:`minmaxvf`, which yields

.. math:: \overline{V}(t, x) \geqslant\overline{V}^1(t, x),

and thus,

.. math:: \underline{{\mathcal X}}_{OL}(t, t_0 {\mathcal X}_0) \subseteq \underline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0) .

We can now recursively define piecewise maxmin and minmax OLRS with
:math:`k` corrections for :math:`t_0<\tau_1<\cdots<\tau_k<t`. The maxmin
piecewise OLRS with :math:`k` corrections is

.. math::
   :label: maxmink

   \overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) =
   \overline{{\mathcal X}}_{OL}(t, \tau_k, \overline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0)),


which is the subzero level set of the corresponding value function

.. math::
   :label: maxminvfk

   \begin{aligned}
   &&\underline{V}^k(t, x) = \nonumber \\
   &&\max_v\min_u\{\underline{V}^{k-1}(\tau_k, x(\tau_k)) ~|~ x(t)=x, \;
   u(\tau)\in{\mathcal U}(\tau), \; v(\tau)\in{\mathcal V}(\tau), \; \tau_k\leqslant\tau<t\}.
   \end{aligned}

The minmax piecewise OLRS with :math:`k` corrections is

.. math::
   :label: minmaxk

   \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) =
   \underline{{\mathcal X}}_{OL}(t, \tau_k, \underline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0)),


which is the subzero level set of the corresponding value function

.. math::
   :label: minmaxvfk

   \begin{aligned}
   &&\overline{V}^k(t, x) = \nonumber \\
   &&\min_u\max_v\{\overline{V}^{k-1}(\tau_k, x(\tau_k)) ~|~ x(t)=x, \;
   u(\tau)\in{\mathcal U}(\tau), \; v(\tau)\in{\mathcal V}(\tau), \; \tau_k\leqslant\tau<t\}.
   \end{aligned}

From :eq:`maxminvf1`, :eq:`minmaxvf1`, :eq:`maxminvfk` and :eq:`minmaxvfk` it
follows that

.. math::

   \underline{V}(t, x) \leqslant\underline{V}^1(t, x)\leqslant\cdots
   \leqslant\underline{V}^k(t, x) \leqslant\overline{V}^k(t, x) \leqslant\cdots
   \leqslant\overline{V}^1(t, x) \leqslant\overline{V}(t, x) .

Hence,

.. math::
   :label: olrsinclusion

   \begin{aligned}
   &&\underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) \subseteq \underline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0) \subseteq \cdots
   \subseteq \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) \subseteq \nonumber \\
   &&\overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) \subseteq \cdots \subseteq \overline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0)
   \subseteq \overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) .
   \end{aligned}

We call

.. math::
   :label: maxminclrs

   \overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0) = \overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0), \;\;
   k = \left\{\begin{array}{ll}
   \infty & \mbox{ for continuous-time system}\\
   t-t_0-1 & \mbox{ for discrete-time system}\end{array}\right.


the *maxmin closed-loop reach set* of system :eq:`ctds2` or :eq:`dtds2` at
time :math:`t`, and we call

.. math::
   :label: minmaxclrs

   \underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0) = \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0), \;\;
   k = \left\{\begin{array}{ll}
   \infty & \mbox{ for continuous-time system}\\
   t-t_0-1 & \mbox{ for discrete-time system}\end{array}\right.


the *minmax closed-loop reach set* of system :eq:`ctds2` or :eq:`dtds2` at
time :math:`t`. 
Given initial time :math:`t_0` and the set of initial
states :math:`{\mathcal X}_0`, the maxmin CLRS
:math:`\overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0)` of system
:eq:`ctds2` or :eq:`dtds2` at time :math:`t>t_0`, is the set of all states
:math:`x`, for each of which and for every disturbance
:math:`v(\tau)\in{\mathcal V}(\tau)`, there exist an initial state
:math:`x_0\in{\mathcal X}_0` and a control
:math:`u(\tau, x(\tau))\in{\mathcal U}(\tau)`, such that the trajectory
:math:`x(\tau | v(\tau), u(\tau, x(\tau)))` satisfying
:math:`x(t_0) = x_0` and

.. math::

   \dot{x}(\tau | v(\tau), u(\tau, x(\tau))) \in
   f(\tau, x(\tau), u(\tau, x(\tau)), v(\tau))

in the continuous-time case, or

.. math::

   x(\tau+1 | v(\tau), u(\tau, x(\tau))) \in
   f(\tau, x(\tau), u(\tau, x(\tau)), v(\tau))

in the discrete-time case, with :math:`t_0\leqslant\tau<t`, is such
that :math:`x(t)=x`. 
Given initial time :math:`t_0` and the set of initial states :math:`{\mathcal X}_0`, the
maxmin CLRS :math:`\underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0)` of system
:eq:`ctds2` or :eq:`dtds2`, at time :math:`t>t_0`, is the set of all states
:math:`x`, for each of which there exists a control
:math:`u(\tau, x(\tau))\in{\mathcal U}(\tau)`, and for every disturbance
:math:`v(\tau)\in{\mathcal V}(\tau)` there exists an initial state
:math:`x_0\in{\mathcal X}_0`, such that the trajectory
:math:`x(\tau, v(\tau) | u(\tau, x(\tau)))` satisfying
:math:`x(t_0) = x_0` and

.. math::

   \dot{x}(\tau, v(\tau) | u(\tau, x(\tau))) \in
   f(\tau, x(\tau), u(\tau, x(\tau)), v(\tau))

in the continuous-time case, or

.. math::

   x(\tau+1, v(\tau) | u(\tau, x(\tau))) \in
   f(\tau, x(\tau), u(\tau, x(\tau)), v(\tau))

in the discrete-time case, with :math:`t_0\leqslant\tau<t`, is such
that :math:`x(t)=x`. 
By construction, both
maxmin and minmax CLRS satisfy the semigroup property :eq:`semigroup`.

For some classes of dynamical systems and some types of constraints on
initial conditions, controls and disturbances, the maxmin and minmax
CLRS may coincide. This is the case for continuous-time linear systems
with convex compact bounds on the initial set, controls and disturbances
under the condition that the initial set :math:`{\mathcal X}_0` is large
enough to ensure that
:math:`{\mathcal X}(t_0+\epsilon, t_0, {\mathcal X}_0)` is nonempty for
some small :math:`\epsilon>0`.

Consider the linear system case,

.. math::
   :label: linearrhsdist
   
   f(t, x, u) = A(t)x(t) + B(t)u + G(t)v,


where :math:`A(t)` and :math:`B(t)` are as in :eq:`linearrhs`, and
:math:`G(t)` takes its values in :math:`{\bf R}^d`.

The maxmin OLRS for the continuous-time linear system can be expressed
through set valued integrals,

.. math::
   :label: ctlsmaxmin
   
   \begin{array}{l}
   \overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, t_0){\mathcal X}_0 \oplus
   \int_{t_0}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau\right) \dot{-} \\
   \int_{t_0}^t\Phi(t, \tau)(-G(\tau)){\mathcal V}(\tau)d\tau,
   \end{array}


and for discrete-time linear system through set-valued sums,

.. math::
   :label: dtlsmaxmin 
   
   \begin{array}{l}
   \overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, t_0){\mathcal X}_0 \oplus \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)\right) \dot{-} \\
   \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)(-G(\tau)){\mathcal V}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsmaxmin}d)}


Similarly, the minmax OLRS for the continuous-time linear system is

.. math::
   :label: ctlsminmax

   \begin{array}{l}
   \underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, t_0){\mathcal X}_0 \dot{-}
   \int_{t_0}^t\Phi(t, \tau)(-G(\tau)){\mathcal V}(\tau)d\tau\right)
   \oplus \\
   \int_{t_0}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau,
   \end{array}


and for the discrete-time linear system it is

.. math::
   :label: dtlsminmax

   \begin{array}{l}
   \underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, t_0){\mathcal X}_0 \dot{-} \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)(-G(\tau)){\mathcal V}(\tau)\right) \oplus \\
   \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsminmax}d)}


The operation ‘:math:`\dot{-}`’ is *geometric difference*, also known as
*Minkowski difference*. [7]_

Now consider the piecewise OLRS with :math:`k` corrections. Expression
:eq:`maxmink` translates into

.. math::
   :label: ctlsmaxmink

   \begin{array}{l}
   \overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0) \oplus
   \int_{\tau_k}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau\right) \dot{-} \\
   \int_{\tau_k}^t\Phi(t, \tau)(-G(\tau)){\mathcal V}(\tau)d\tau,
   \end{array}


in the continuous-time case, and for the discrete-time case into

.. math::
   :label: dtlsmaxmink

   \begin{array}{l}
   \overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0) \oplus
   \sum_{\tau=\tau_k}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)\right) \dot{-} \\
   \sum_{\tau=\tau_k}^{t-1}\Phi(t, \tau+1)(-G(\tau)){\mathcal V}(\tau).
   \end{array}

Expression :eq:`minmaxk` translates into

.. math::
   :label: ctlsminmaxk

   \begin{array}{l}
   \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, \tau_k)\underline{{\mathcal X}}_{OL}^{k-1}(t, t_0, {\mathcal X}_0) \dot{-}
   \int_{\tau_k}^t\Phi(t, \tau)(-G(\tau)){\mathcal V}(\tau)d\tau\right)
   \oplus \\
   \int_{\tau_k}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau,
   \end{array}

in the continuous-time case, and for the discrete-time case into

.. math::
   :label: dtlsminmaxk

   \begin{array}{l}
   \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, \tau_k)\underline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0) \dot{-}
   \sum_{\tau=\tau_k}^{t-1}\Phi(t, \tau+1)(-G(\tau)){\mathcal V}(\tau)\right)
   \oplus \\
   \sum_{\tau=\tau_k}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau).
   \end{array}

Since for any
:math:`{\mathcal W}_1, {\mathcal W}_2, {\mathcal W}_3 \subseteq {\bf R}^n`
it is true that

.. math::

   ({\mathcal W}_1 \dot{-} {\mathcal W}_2) \oplus {\mathcal W}_3 =
   ({\mathcal W}_1 \oplus {\mathcal W}_3) \dot{-} ({\mathcal W}_2 \oplus {\mathcal W}_3) \subseteq
   ({\mathcal W}_1 \oplus {\mathcal W}_3) \dot{-} {\mathcal W}_2,

from :eq:`ctlsmaxmink`, :eq:`ctlsminmaxk` and from :eq:`dtlsmaxmink`,
:eq:`dtlsminmaxk`, it is clear that :eq:`olrsinclusion` is true.
For linear systems, if the initial set :math:`{\mathcal X}_0`, control
bounds :math:`{\mathcal U}(\tau)` and disturbance bounds
:math:`{\mathcal V}(\tau)`, :math:`t_0\leqslant\tau<t`, are compact and
convex, the CLRS
:math:`\overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0)` and
:math:`\underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0)` are
compact and convex, provided they are nonempty. For continuous-time
linear systems,
:math:`\overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0) = \underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0) = {\mathcal X}_{CL}(t, t_0, {\mathcal X}_0)`.

Just as for forward reach sets, the backward reach sets can be open-loop
(OLBRS) or closed-loop (CLBRS).

Given the terminal time :math:`t_1` and target set
:math:`{\mathcal Y}_1`, the maxmin open-loop backward reach set
:math:`\overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1)` of system
:eq:`ctds2` or :eq:`dtds2` at time :math:`t<t_1`, is the set of all :math:`y`,
such that for any disturbance :math:`v(\tau)\in{\mathcal V}(\tau)` there
exists a terminal state :math:`y_1\in{\mathcal Y}_1` and control
:math:`u(\tau)\in{\mathcal U}(\tau)`, :math:`t\leqslant\tau<t_1`, which
steers the system from :math:`y(t)=y` to :math:`y(t_1)=y_1`.

:math:`\overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1)` is the
subzero level set of the value function

.. math::
   :label: maxminvfb

   \begin{aligned}
   &&\underline{V}_b(t, y) = \nonumber \\
   &&\max_v\min_u\{{\bf dist}(y(t_1), {\mathcal Y}_1) ~|~ y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<t_1\},
   \end{aligned}

Given the terminal time :math:`t_1` and target set
:math:`{\mathcal Y}_1`, the minmax open-loop backward reach set
:math:`\underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1)` of system
:eq:`ctds2` or :eq:`dtds2` at time :math:`t<t_1`, is the set of all :math:`y`,
such that there exists a control :math:`u(\tau)\in{\mathcal U}(\tau)`
that for all disturbances :math:`v(\tau\in{\mathcal V}(\tau)`,
:math:`t\leqslant\tau<t_1`, assigns a terminal state
:math:`y_1\in{\mathcal Y}_1` and steers the system from :math:`y(t)=y`
to :math:`y(t_1)=y_1`. 
:math:`\underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1)` is the
subzero level set of the value function

.. math::
   :label: minmaxvfb 

   \begin{aligned}
   &&\overline{V}_b(t, y) = \nonumber \\
   &&\min_u\max_v\{{\bf dist}(y(t_1), {\mathcal Y}_1) ~|~ y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<t_1\},
   \end{aligned}

**Remark.** The backward reach set can be computed for a continuous-time
system only if the solution of :eq:`ctds2` exists for :math:`t<t_1`, and
for a discrete-time system only if the right hand side of :eq:`dtds2` is
invertible.

Similarly to the forward reachability case, we construct piecewise OLBRS
with one correction at time :math:`\tau_1`, :math:`t<\tau_1<t_1`. The
piecewise maxmin OLBRS with one correction is

.. math::
   :label: maxminb1

   \overline{{\mathcal Y}}_{OL}^1(t_1, t, {\mathcal Y}_1) = \overline{{\mathcal Y}}_{OL}(\tau_1, t, \overline{{\mathcal Y}}_{OL}(t_1, \tau_1, {\mathcal Y}_1)),


and it is the subzero level set of the function

.. math::
   :label: maxminvfb1 

   \begin{aligned}
   &&\underline{V}^1_b(t, y) = \nonumber \\
   &&\max_v\min_u\{\underline{V}_b(\tau_1, y(\tau_1)) ~|~
   y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<\tau_1\}.
   \end{aligned}

The piecewise minmax OLBRS with one correction is

.. math::
   :label: minmaxb1

   \underline{{\mathcal Y}}_{OL}^1(t_1, t, {\mathcal Y}_1) = \underline{{\mathcal Y}}_{OL}(\tau_1, t, \underline{{\mathcal Y}}_{OL}(t_1, \tau_1, {\mathcal Y}_1)),


and it is the subzero level set of the function

.. math::
   :label: minmaxvfb1

   \begin{aligned}
   &&\overline{V}^1_b(t, y) = \nonumber \\
   &&\min_u\max_v\{\overline{V}_b(\tau_1, y(\tau_1)) ~|~
   y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<\tau_1\},
   \end{aligned}

Recursively define maxmin and minmax OLBRS with :math:`k` corrections
for :math:`t<\tau_k<\cdots<\tau_1<t_1`. The maxmin OLBRS with :math:`k`
corrections is

.. math::
   :label: maxminbk

   \overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \overline{{\mathcal Y}}_{OL}(\tau_k, t, \overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1)),


which is the subzero level set of function

.. math::
   :label: maxminvfbk

   \begin{aligned}
   &&\underline{V}^k_b(t, y) = \nonumber \\
   &&\max_v\min_u\{\underline{V}^{k-1}_b(\tau_k, y(\tau_k)) ~|~
   y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<\tau_k\}.
   \end{aligned}

The minmax OLBRS with :math:`k` corrections is

.. math::
   :label: minmaxbk

   \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \underline{{\mathcal Y}}_{OL}(\tau_k, t, \underline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1)),


which is the subzero level set of the function

.. math::
   :label: minmaxvfbk

   \begin{aligned}
   &&\overline{V}^k_b(t, y) = \nonumber \\
   &&\min_u\max_v\{\overline{V}^{k-1}_b(\tau_k, y(\tau_k)) ~|~
   y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<\tau_k\},
   \end{aligned}

From :eq:`maxminvfb1`, :eq:`minmaxvfb1`, :eq:`maxminvfbk` and :eq:`minmaxvfbk`
it follows that

.. math::

   \underline{V}_b(t, y) \leqslant\underline{V}^1_b(t, y)\leqslant\cdots
   \leqslant\underline{V}^k_b(t, y) \leqslant\overline{V}^k_b(t, y) \leqslant\cdots
   \leqslant\overline{V}^1_b(t, y) \leqslant\overline{V}_b(t, y) .

Hence,

.. math::
   :label: olbrsinclusion

   \begin{aligned}
   &&\underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) \subseteq \underline{{\mathcal Y}}_{OL}^1(t_1, t, {\mathcal Y}_1) \subseteq \cdots
   \subseteq \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) \subseteq \nonumber \\
   &&\overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) \subseteq \cdots \subseteq \overline{{\mathcal Y}}_{OL}^1(t_1, t, {\mathcal Y}_1)
   \subseteq \overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) .
   \end{aligned}

We say that

.. math::
   :label: maxminclbrs

   \overline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1) = \overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1), \;\;
   k = \left\{\begin{array}{ll}
   \infty & \mbox{ for continuous-time system}\\
   t_1-t-1 & \mbox{ for discrete-time system}\end{array}\right.


is the *maxmin closed-loop backward reach set* of system :eq:`ctds2` or
:eq:`dtds2` at time :math:`t`.

We say that

.. math::
   :label: minmaxclbrs

   \underline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1) = \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1), \;\;
   k = \left\{\begin{array}{ll}
   \infty & \mbox{ for continuous-time system}\\
   t_1-t-1 & \mbox{ for discrete-time system}\end{array}\right.


is the *minmax closed-loop backward reach set* of system :eq:`ctds2` or
:eq:`dtds2` at time :math:`t`. 

Given the terminal time :math:`t_1` and
target set :math:`{\mathcal Y}_1`, the maxmin CLBRS
:math:`\overline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1)` of system
:eq:`ctds2` or :eq:`dtds2` at time :math:`t<t_1`, is the set of all states
:math:`y`, for each of which for every disturbance
:math:`v(\tau)\in{\mathcal V}(\tau)` there exists terminal state
:math:`y_1\in{\mathcal Y}_1` and control
:math:`u(\tau, y(\tau))\in{\mathcal U}(\tau)` that assigns trajectory
:math:`y(\tau, | v(\tau), u(\tau, y(\tau)))` satisfying

.. math::

   \dot{y}(\tau | v(\tau), u(\tau, y(\tau))) \in
   f(\tau, y(\tau), u(\tau, y(\tau)), v(\tau))

in continuous-time case, or

.. math::

   y(\tau+1 | v(\tau), u(\tau, y(\tau))) \in
   f(\tau, y(\tau), u(\tau, y(\tau)), v(\tau))

in discrete-time case, with :math:`t\leqslant\tau<t_1`, such that
:math:`y(t) = y` and :math:`y(t_1)=y_1`. 

Given the terminal time :math:`t_1` and target set :math:`{\mathcal Y}_1`, the
minmax CLBRS :math:`\underline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1)` of system
([ctds2]) or [dtds2] at time :math:`t<t_1`, is the set of all states
:math:`y`, for each of which there exists control
:math:`u(\tau, y(\tau))\in{\mathcal U}(\tau)` that for every disturbance
:math:`v(\tau)\in{\mathcal V}(\tau)` assigns terminal state
:math:`y_1\in{\mathcal Y}_1` and trajectory
:math:`y(\tau, v(\tau) | u(\tau, y(\tau)))` satisfying

.. math::

   \dot{y}(\tau, v(\tau) | u(\tau, y(\tau))) \in
   f(\tau, y(\tau), u(\tau, y(\tau)), v(\tau))

in the continuous-time case, or

.. math::

   y(\tau+1, v(\tau) | u(\tau, y(\tau))) \in
   f(\tau, y(\tau), u(\tau, y(\tau)), v(\tau))

in the discrete-time case, with :math:`t\leqslant\tau<t_1`, such that
:math:`y(t) = y` and :math:`y(t_1)=y_1`. 

Both
maxmin and minmax CLBRS satisfy the semigroup property
:eq:`semigroup_b`.

The maxmin OLBRS for the continuous-time linear system can be expressed
through set valued integrals,

.. math::
   :label: ctlsmaxminb

   \begin{array}{l}
   \overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, t_1){\mathcal Y}_1 \oplus
   \int_{t_1}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau\right) \dot{-} \\
   \int_{t}^{t_1}\Phi(t, \tau)G(\tau){\mathcal V}(\tau)d\tau,
   \end{array}


and for the discrete-time linear system through set-valued sums,

.. math::
   :label: dtlsmaxminb

   \begin{array}{l}
   \overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, t_1){\mathcal Y}_1 \oplus
   \sum_{\tau=t}^{t_1-1}-\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)\right) \dot{-} \\
   \sum_{\tau=t}^{t_1-1}\Phi(t, \tau+1)G(\tau){\mathcal V}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsmaxminb}d)}


Similarly, the minmax OLBRS for the continuous-time linear system is

.. math::
   :label: ctlsminmaxb

   \begin{array}{l}
   \underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, t_1){\mathcal Y}_1 \dot{-}
   \int_{t}^{t_1}\Phi(t, \tau)G(\tau){\mathcal V}(\tau)d\tau\right)
   \oplus \\
   \int_{t_1}^{t}\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau,
   \end{array}


and for the discrete-time linear system it is

.. math::
   :label: dtlsminmaxb

   \begin{array}{l}
   \underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, t_1){\mathcal Y}_1 \dot{-}
   \sum_{\tau=t}^{t_1-1}\Phi(t, \tau+1)G(\tau){\mathcal V}(\tau)\right)
   \oplus \\
   \sum_{\tau=t}^{t_1-1}-\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsminmaxb}d)}


Now consider piecewise OLBRS with :math:`k` corrections. Expression
:eq:`maxminbk` translates into

.. math::
   :label: ctlsmaxminbk

   \begin{array}{l}
   \overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1) \oplus
   \int_{\tau_k}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau\right) \dot{-} \\
   \int^{\tau_k}_t\Phi(t, \tau)G(\tau){\mathcal V}(\tau)d\tau,
   \end{array}


in the continuous-time case, and for the discrete-time case into

.. math::
   :label: dtlsmaxminbk

   \begin{array}{l}
   \overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1) \oplus
   \sum_{\tau=t}^{\tau_k-1}-\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)\right) \dot{-} \\
   \sum_{\tau=t}^{\tau_k-1}\Phi(t, \tau+1)G(\tau){\mathcal V}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsmaxminbk}d)}


Expression :eq:`minmaxbk` translates into

.. math::
   :label: ctlsminmaxbk

   \begin{array}{l}
   \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1) \dot{-}
   \int^{\tau_k}_t\Phi(t, \tau)G(\tau){\mathcal V}(\tau)d\tau\right)
   \oplus \\
   \int_{\tau_k}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau,
   \end{array}

in the continuous-time case, and for the discrete-time case into

.. math::
   :label: dtlsminmaxbk

   \begin{array}{l}
   \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \\
   (\Phi(t, \tau_k)\overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1) \dot{-}
   \sum_{\tau=t}^{\tau_k-1}\Phi(t, \tau+1)G(\tau){\mathcal V}(\tau))
   \oplus \\
   \sum_{\tau=t}^{\tau_k-1}-\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsminmaxk}d)}


For continuous-time linear systems
:math:`\overline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1) = \underline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1) = {\mathcal Y}_{CL}(t_1, t, {\mathcal Y}_1)`
under the condition that the target set :math:`{\mathcal Y}_1` is large
enough to ensure that
:math:`\underline{{\mathcal Y}}_{CL}(t_1, t_1-\epsilon, {\mathcal Y}_1)`
is nonempty for some small :math:`\epsilon>0`.

Computation of backward reach sets for discrete-time linear systems
makes sense only if the state transition matrix :math:`\Phi(t_1, t)` is
invertible.

If the target set :math:`{\mathcal Y}_1`, control sets
:math:`{\mathcal U}(\tau)` and disturbance sets
:math:`{\mathcal V}(\tau)`, :math:`t\leqslant\tau<t_1`, are compact and
convex, then CLBRS
:math:`\overline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1)` and
:math:`\underline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1)` are
compact and convex, if they are nonempty.

Reachability problem
~~~~~~~~~~~~~~~~~~~~

Reachability analysis is concerned with the computation of the forward
:math:`{\mathcal X}(t, t_0, {\mathcal X}_0)` and backward
:math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` reach sets (the reach sets
may be maxmin or minmax) in a way that can effectively meet requests
like the following:

#. For the given time interval :math:`[t_0, t]`, determine whether the
   system can be steered into the given target set
   :math:`{\mathcal Y}_1`. In other words, is the set
   :math:`{\mathcal Y}_1\cap\bigcup_{t_0 \leqslant\tau\leqslant t}{\mathcal X}(\tau, t_0, {\mathcal X}_0)`
   nonempty? And if the answer is ‘yes’, find a control that steers the
   system to the target set (or avoids the target set). [8]_

#. If the target set :math:`{\mathcal Y}_1` is reachable from the given
   initial condition :math:`\{t_0, {\mathcal X}_0\}` in the time
   interval :math:`[t_0, t]`, find the shortest time to reach
   :math:`{\mathcal Y}_1`,

   .. math::

      \arg\min_{\tau}
      \{{\mathcal X}(\tau,t_0,{\mathcal X}_0)\cap{\mathcal Y}_1\neq\emptyset ~|~ t_0\leqslant\tau\leqslant t\}.

#. Given the terminal time :math:`t_1`, target set
   :math:`{\mathcal Y}_1` and time :math:`t<t_1` find the set of states
   starting at time :math:`t` from which the system can reach
   :math:`{\mathcal Y}_1` within time interval :math:`[t, t_1]`. In
   other words, find
   :math:`\bigcup_{t\leqslant\tau<t_1}{\mathcal Y}(t_1, \tau, {\mathcal Y}_1)`.

#. Find a closed-loop control that steers a system with disturbances to
   the given target set in given time.

#. Graphically display the projection of the reach set along any
   specified two- or three-dimensional subspace.

For linear systems, if the initial set :math:`{\mathcal X}_0`, target
set :math:`{\mathcal Y}_1`, control bounds :math:`{\mathcal U}(\cdot)`
and disturbance bounds :math:`{\mathcal V}(\cdot)` are compact and
convex, so are the forward :math:`{\mathcal X}(t, t_0, {\mathcal X}_0)`
and backward :math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` reach sets.
Hence reachability analysis requires the computationally effective
manipulation of convex sets, and performing the set-valued operations of
unions, intersections, geometric sums and differences.

Existing reach set computation tools can deal reliably only with linear
systems with convex constraints. A claim that certain tool or method can
be used *effectively* for nonlinear systems must be treated with
caution, and the first question to ask is for what class of nonlinear
systems and with what limit on the state space dimension does this tool
work? Some “reachability methods for nonlinear systems” reduce to the
local linearization of a system followed by the use of well-tested
techniques for linear system reach set computation. Thus these
approaches in fact use reachability methods for linear systems.

Ellipsoidal Method
------------------

Continuous-time systems
~~~~~~~~~~~~~~~~~~~~~~~

Consider the system

.. math:: 
   :label: ctsystem
   
   \dot{x}(t) = A(t)x(t) + B(t)u + G(t)v,

in which :math:`x\in{\bf R}^n` is the state, :math:`u\in{\bf R}^m` is
the control and :math:`v\in{\bf R}^d` is the disturbance. :math:`A(t)`,
:math:`B(t)` and :math:`G(t)` are continuous and take their values in
:math:`{\bf R}^{n\times n}`, :math:`{\bf R}^{n\times m}` and
:math:`{\bf R}^{n\times d}` respectively. Control :math:`u(t,x(t))` and
disturbance :math:`v(t)` are measurable functions restricted by
ellipsoidal constraints: :math:`u(t,x(t)) \in {\mathcal E}(p(t), P(t))`
and :math:`v(t) \in {\mathcal E}(q(t), Q(t))`. The set of initial states
at initial time :math:`t_0` is assumed to be the ellipsoid
:math:`{\mathcal E}(x_0,X_0)`.

The reach sets for systems with disturbances computed by the Ellipsoidal
Toolbox are CLRS. Henceforth, when describing backward reachability,
reach sets refer to CLRS or CLBRS. Recall that for continuous-time
linear systems maxmin and minmax CLRS coincide, and the same is true for
maxmin and minmax CLBRS.

If the matrix :math:`Q(\cdot)=0`, the system :eq:`ctsystem` becomes an
ordinary affine system with known :math:`v(\cdot)=q(\cdot)`. If
:math:`G(\cdot) = 0`, the system becomes linear. For these two cases
(:math:`Q(\cdot)=0` or :math:`G(\cdot)=0`) the reach set is as given in
Definition [def:sub:`o`\ lrs], and so the reach set will be denoted as
:math:`{\mathcal X}_{CL}(t, t_0, {\mathcal E}(x_0, X_0)) = {\mathcal X}(t, t_0, {\mathcal E}(x_0,X_0))`.

The reach set :math:`{\mathcal X}(t,t_0,{\mathcal E}(x_0,X_0))` is a
symmetric compact convex set, whose center evolves in time according to

.. math::
   :label: fwdcenter

   \dot{x}_c(t) = A(t)x_c(t) + B(t)p(t) + G(t)q(t), \;\;\;
   x_c(t_0)=x_0. 

Fix a vector :math:`l_0\in{\bf R}^n`, and consider the solution
:math:`l(t)` of the adjoint equation

.. math::
   :label: adjointct
   
   \dot{l}(t) = -A^T(t)l(t), \;\;\; l(t_0) = l_0,


which is equivalent to

.. math:: l(t) = \Phi^T(t_0, t)l_0.

If the reach set :math:`{\mathcal X}(t, t_0, {\mathcal E}(x_0,X_0))` is
nonempty, there exist tight external and tight internal approximating
ellipsoids :math:`{\mathcal E}(x_c(t), X^+_l(t))` and
:math:`{\mathcal E}(x_c(t), X^-_l(t))`, respectively, such that

.. math::
   :label: fwdinclusion

   {\mathcal E}(x_c(t), X^-_l(t))\subseteq{\mathcal X}(t,t_0,{\mathcal E}(x_0,X_0))
   \subseteq {\mathcal E}(x_c(t), X^+_l(t)),


and

.. math::
   :label: fwdtightness


   \rho(l(t) ~|~ {\mathcal E}(x_c(t), X^-_l(t))) =
   \rho(l(t) ~|~ {\mathcal X}(t, t_0, {\mathcal E}(x_0,X_0))) =
   \rho(l(t) ~|~ {\mathcal E}(x_c(t), X^+_l(t))) .

The equation for the shape matrix of the external ellipsoid is

.. math::
   :label: fwdext1 

   \dot{X}^+_l(t) & = A(t)X^+_l(t) + X^+_l(t)A^T(t) +\nonumber \\
   &\pi_l(t)X^+_l(t) + \frac{1}{\pi_l(t)}B(t)P(t)B^T(t) -\nonumber \\
   & (X_l^{+}(t))^{1/2}S_l(t)(G(t)Q(t)G^T(t))^{1/2} \nonumber -\\
   & (G(t)Q(t)G^T(t))^{1/2}S_l^T(t)(X_l^{+}(t))^{1/2}, \\

.. math::
   :label: fwdext2
   
   X^+_l(t_0) =X_0,

in which

.. math::

   \pi_l(t) = \frac{\langle l(t),
   B(t)P(t)B^T(t)l(t)\rangle^{1/2}}{\langle l(t), X^+_l(t)l(t)\rangle^{1/2}},

and the orthogonal matrix :math:`S_l(t)` (:math:`S_l(t)S_l^T(t) = I`)
is determined by the equation

.. math::

   S_l(t)(G(t)Q(t)G^T(t))^{1/2}l(t) = \frac{\langle l(t),
   G(t)Q(t)G^T(t)l(t)\rangle^{1/2}}{\langle l(t),
   X_l^+(t)l(t)\rangle^{1/2}}(X_l^{+}(t))^{1/2}l(t).

In the presence of disturbance, if the reach set is empty, the matrix
:math:`X^+_l(t)` becomes sign indefinite. For a system without
disturbance, the terms containing :math:`G(t)` and :math:`Q(t)` vanish
from the equation :eq:`fwdext1`.

The equation for the shape matrix of the internal ellipsoid is

.. math::
   :label: fwdint1 

   \dot{X}^-_l(t) & = A(t)X^-_l(t) + X^-_l(t)A^T(t) +\nonumber \\
   & (X_l^{-}(t))^{1/2}T_l(t)(B(t)P(t)B^T(t))^{1/2} +\nonumber \\
   & (B(t)P(t)B^T(t))^{1/2}T_l^T(t)(X_l^{-}(t))^{1/2} -\nonumber \\
   & \eta_l(t)X^-_l(t) - \frac{1}{\eta_l(t)}G(t)Q(t)G^T(t), \\

.. math::
   :label: fwdint2
   
   X^-_l(t_0) = X_0, 

in which

.. math::

   \eta_l(t) = \frac{\langle l(t),
   G(t)Q(t)G^T(t)l(t)\rangle^{1/2}}{\langle l(t), X^+_l(t)l(t)\rangle^{1/2}},

and the orthogonal matrix :math:`T_l(t)` is determined by the equation

.. math::

   T_l(t)(B(t)P(t)B^T(t))^{1/2}l(t) = \frac{\langle l(t),
   B(t)P(t)B^T(t)l(t)\rangle^{1/2}}{\langle l(t),
   X_l^-(t)l(t)\rangle^{1/2}}(X_l^{-}(t))^{1/2}l(t).

Similarly to the external case, the terms containing :math:`G(t)` and
:math:`Q(t)` vanish from the equation ([fwdint1]) for a system without
disturbance.

The point where the external and internal ellipsoids touch the boundary
of the reach set is given by

.. math::

   x_l^*(t) = x_c(t) +
   \frac{X^+_l(t)l(t)}{\langle l(t), X^+_l(t)l(t)\rangle^{1/2}} .

The boundary points :math:`x^*_l(t)` form trajectories, which we call
*extremal trajectories*. Due to the nonsingular nature of the state
transition matrix :math:`\Phi(t,t_0)`, every boundary point of the reach
set belongs to an extremal trajectory. To follow an extremal trajectory
specified by parameter :math:`l_0`, the system has to start at time
:math:`t_0` at initial state

.. math:: 
   :label: x0lct
   
   x^0_l = x_0 + \frac{X_0l_0}{\langle l_0,X_0l_0\rangle^{1/2}}. 

In the absence of disturbances, the open-loop control

.. math::
   :label: uct

   u_l(t) = p(t) + \frac{P(t)B^T(t)l(t)}{\langle l(t),
   B(t)P(t)B^T(t)l(t)\rangle^{1/2}}. 

steers the system along the extremal trajectory defined by the vector
:math:`l_0`. When a disturbance is present, this control keeps the
system on an extremal trajectory if and only if the disturbance plays
against the control always taking its extreme values.

Expressions :eq:`fwdinclusion` and :eq:`fwdtightness` lead to the following
fact,

.. math::

   \bigcup_{\langle l_0,l_0\rangle=1}{\mathcal E}(x_c(t),X^-_l(t)) =
   {\mathcal X}(t,t_0,{\mathcal E}(x_0,X_0)) =
   \bigcap_{\langle l_0,l_0\rangle=1}{\mathcal E}(x_c(t),X^+_l(t)).

In practice this means that the more values of :math:`l_0` we use to
compute :math:`X^+_l(t)` and :math:`X^-_l(t)`, the better will be our
approximation.

Analogous results hold for the backward reach set.

Given the terminal time :math:`t_1` and ellipsoidal target set
:math:`{\mathcal E}_(y_1,Y_1)`, the CLBRS
:math:`{\mathcal Y}_{CL}(t_1, t, {\mathcal Y}_1)={\mathcal Y}(t_1, t, {\mathcal Y}_1)`,
:math:`t<t_1`, if it is nonempty, is a symmetric compact convex set
whose center is governed by

.. math:: 
   :label: bckcenter

   y_c(t) = Ay_c(t) + B(t)p(t) + G(t)q(t), \;\;\; y_c(t_1) = y_1.

Fix a vector :math:`l_1\in{\bf R}^n`, and consider

.. math::
   :label: bckadjoint
   
   l(t) = \Phi(t_1, t)^Tl_1 .


If the backward reach set
:math:`{\mathcal Y}(t_1, t, {\mathcal E}(y_1,Y_1))` is nonempty, there
exist tight external and tight internal approximating ellipsoids
:math:`{\mathcal E}(y_c(t), Y^+_l(t))` and
:math:`{\mathcal E}(y_c(t), Y^-_l(t))` respectively, such that

.. math::
   :label: bckinclusion
   
   {\mathcal E}(y_c(t), Y^-_l(t))\subseteq{\mathcal Y}(t_1,t,{\mathcal E}(y_1,Y_1))
   \subseteq {\mathcal E}(y_c(t), Y^+_l(t)),


and

.. math::
   :label: bcktightness
   
   \rho(l(t) ~|~ {\mathcal E}(y_c(t), Y^-_l(t))) =
   \rho(l(t) ~|~ {\mathcal Y}(t_1, t, {\mathcal E}(y_0,Y_0))) =
   \rho(l(t) ~|~ {\mathcal E}(y_c(t), Y^+_l(t))) .


The equation for the shape matrix of the external ellipsoid is

.. math::
   :label: bckext1

   \dot{Y}^+_l(t) & = A(t)Y^+_l(t) + Y^+_l(t)A^T(t) -\nonumber \\
   & \pi_l(t)Y^+_l(t) - \frac{1}{\pi_l(t)}B(t)P(t)B^T(t) +\nonumber \\
   & (Y_l^{+}(t))^{1/2}S_l(t)(G(t)Q(t)G^T(t))^{1/2} +\nonumber \\
   & (G(t)Q(t)G^T(t))^{1/2}S_l^T(t)(Y_l^{+}(t))^{1/2},\\

.. math::
   :label: bckext2

   Y^+_l(t_1)  = Y_1,

in which

.. math::

   \pi_l(t) = \frac{\langle l(t),
   B(t)P(t)B^T(t)l(t)\rangle^{1/2}}{\langle l(t),
   Y^+_l(t)l(t)\rangle^{1/2}},

and the orthogonal matrix :math:`S_l(t)` satisfies the equation

.. math::

   S_l(t)(G(t)Q(t)G^T(t))^{1/2}l(t) = \frac{\langle l(t),
   G(t)Q(t)G^T(t)l(t)\rangle^{1/2}}{\langle l(t),
   Y_l^+(t)l(t)\rangle^{1/2}}(Y_l^{+}(t))^{1/2}l(t).

The equation for the shape matrix of the internal ellipsoid is

.. math::
   :label: bckint1 

   \dot{Y}^-_l(t) & =  A(t)Y^-_l(t) + Y^-_l(t)A^T(t) -\nonumber \\
   & (Y_l^{-}(t))^{1/2}T_l(t)(B(t)P(t)B^T(t))^{1/2} -\nonumber \\
   & (B(t)P(t)B^T(t))^{1/2}T_l^T(t)(Y_l^{-}(t))^{1/2} +\nonumber \\
   & \eta_l(t)Y^-_l(t) + \frac{1}{\eta_l(t)}G(t)Q(t)G^T(t),\\
   
.. math::
   :label: bckint2
 
   Y^-_l(t_1) & = Y_1,

in which

.. math::

   \eta_l(t) = \frac{\langle l(t),
   G(t)Q(t)G^T(t)l(t)\rangle^{1/2}}{\langle l(t),
   Y^+_l(t)l(t)\rangle^{1/2}},

and the orthogonal matrix :math:`T_l(t)` is determined by the equation

.. math::

   T_l(t)(B(t)P(t)B^T(t))^{1/2}l(t) = \frac{\langle l(t),
   B(t)P(t)B^T(t)l(t)\rangle^{1/2}}{\langle l(t),
   Y_l^-(t)l(t)\rangle^{1/2}}(Y_l^{-}(t))^{1/2}l(t).

Just as in the forward reachability case, the terms containing
:math:`G(t)` and :math:`Q(t)` vanish from equations :eq:`bckext1` and
:eq:`bckint1` in the absence of disturbances. The boundary value problems
:eq:`bckcenter`, :eq:`bckext1` and :eq:`bckint1` are converted to the initial
value problems by the change of variables :math:`s = -t`.

Due to :eq:`bckinclusion` and :eq:`bcktightness`,

.. math::

   \bigcup_{\langle l_1,l_1\rangle=1}{\mathcal E}(y_c(t),Y^-_l(t)) =
   {\mathcal Y}(t_1,t,{\mathcal E}(y_1,Y_1)) =
   \bigcap_{\langle l_1,l_1\rangle=1}{\mathcal E}(y_c(t),Y^+_l(t)).

**Remark.** In expressions :eq:`fwdext1`, :eq:`fwdint1`, :eq:`bckext1` and
:eq:`bckint1` the terms :math:`\frac{1}{\pi_l(t)}` and
:math:`\frac{1}{\eta_l(t)}` may not be well defined for some vectors
:math:`l`, because matrices :math:`B(t)P(t)B^T(t)` and
:math:`G(t)Q(t)G^T(t)` may be singular. In such cases, we set these
entire expressions to zero.

Discrete-time systems
~~~~~~~~~~~~~~~~~~~~~

Consider the discrete-time linear system,

.. math::
   :label: dtsystem

   x(t+1) = A(t)x(t) + B(t)u(t,x(t)) + G(t)v(t),



in which :math:`x(t)\in{\bf R}^n` is the state,
:math:`u(t, x(t))\in{\bf R}^m` is the control bounded by the ellipsoid
:math:`{\mathcal E}(p(t),P(t))`, :math:`v(t)\in{\bf R}^d` is disturbance
bounded by ellipsoid :math:`{\mathcal E}(q(t),Q(t))`, and matrices
:math:`A(t)`, :math:`B(t)`, :math:`G(t)` are in
:math:`{\bf R}^{n\times n}`, :math:`{\bf R}^{n\times m}`,
:math:`{\bf R}^{n\times d}` respectively. Here we shall assume
:math:`A(t)` to be nonsingular. [9]_ The set of initial conditions at
initial time :math:`t_0` is ellipsoid :math:`{\mathcal E}(x_0,X_0)`.

Ellipsoidal Toolbox computes maxmin and minmax CLRS
:math:`\overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0, X_0)` and
:math:`\underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0, X_0)` for
discrete-time systems.

If matrix :math:`Q(\cdot)=0`, the system :eq:`dtsystem` becomes an
ordinary affine system with known :math:`v(\cdot)=q(\cdot)`. If matrix
:math:`G(\cdot)=0`, the system reduces to a linear controlled system. In
the absence of disturbance (:math:`Q(\cdot)=0` or :math:`G(\cdot)=0`),
:math:`\overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))=\underline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))={\mathcal X}(t,t_0,{\mathcal E}(x_0,X_0))`,
the reach set is as in Definition.

Maxmin and minmax CLRS
:math:`\overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0, X_0)` and
:math:`\underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0, X_0)`, if
nonempty, are symmetric convex and compact, with the center evolving in
time according to

.. math::
   :label: fwdcenterd

   x_c(t+1) = A(t)x_c(t) + B(t)p(t) + G(t)v(t), \\
   x_c(t_0)= x_0.


Fix some vector :math:`l_0\in{\bf R}^n` and consider :math:`l(t)` that
satisfies the discrete-time adjoint equation, [10]_

.. math::
   :label: adjointdt
   
   l(t+1) = \left(A^T\right)^{-1}(t)l(t), \\ 
   l(t_0) = l_0,


or, equivalently

.. math:: l(t) = \Phi^T(t_0, t)l_0 .

There exist tight external ellipsoids
:math:`{\mathcal E}(x_c(t), \overline{X}^+_l(t))`,
:math:`{\mathcal E}(x_c(t), \underline{X}^+_l(t))` and tight internal
ellipsoids :math:`{\mathcal E}(x_c(t), \overline{X}^-_l(t))`,
:math:`{\mathcal E}(x_c(t), \underline{X}^-_l(t))` such that

.. math::
   :label: maxmininclusion

   {\mathcal E}(x_c(t), \overline{X}^-_l(t))\subseteq\overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))
   \subseteq {\mathcal E}(x_c(t), \overline{X}^+_l(t)),


.. math::
   :label: maxmintightness

   \rho(l(t) ~|~ {\mathcal E}(x_c(t), \overline{X}^-_l(t))) =
   \rho(l(t) ~|~ \overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0,X_0))) =
   \rho(l(t) ~|~ {\mathcal E}(x_c(t), \overline{X}^+_l(t))) .

and

.. math::
   :label: minmaxinclusion

   {\mathcal E}(x_c(t), \underline{X}^-_l(t))\subseteq\underline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))
   \subseteq {\mathcal E}(x_c(t), \underline{X}^+_l(t)),


.. math::
   :label: minmaxtightness
   
   \rho(l(t) ~|~ {\mathcal E}(x_c(t), \underline{X}^-_l(t))) =
   \rho(l(t) ~|~ \underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0,X_0))) =
   \rho(l(t) ~|~ {\mathcal E}(x_c(t), \underline{X}^+_l(t))) .


The shape matrix of the external ellipsoid for maxmin reach set is
determined from

.. math::
   :label: fwdextmaxmin1

   \hat{X}^+_l(t) & = (1+\overline{\pi}_l(t))A(t)\overline{X}^+_l(t)A^T(t) +
   \left(1+\frac{1}{\overline{\pi}_l(t)}\right)
   B(t)P(t)B^T(t),  \\

.. math::
   :label: fwdextmaxmin2
   
   
   \overline{X}^+_l(t+1) & = \left((\hat{X}^+_l(t))^{1/2} +
   \overline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}\right)^T
   \times \nonumber \\
   & \left((\hat{X}^+_l(t))^{1/2} + \overline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}\right),\\
   
.. math::
   :label: fwdextmaxmin3

   \overline{X}^+_l(t_0) & = X_0,

wherein

.. math::

   \overline{\pi}_l(t) = \frac{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}{\langle l(t),
   \overline{X}^+_l(t)l(t)\rangle^{1/2}},

and the orthogonal matrix :math:`\overline{S}_l(t)` is determined by
the equation

.. math::

   \begin{aligned}
   & & \overline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}l(t+1) = \\
   & & \frac{\langle l(t+1),
   G(t)Q(t)G^T(t)l(t+1)\rangle^{1/2}}{\langle l(t+1),
   \hat{X}^+_l(t)l(t+1)\rangle^{1/2}}(\hat{X}^+_l(t))^{1/2}l(t+1).\end{aligned}

Equation :eq:`fwdextmaxmin2` is valid only if
:math:`{\mathcal E}(0,G(t)Q(t)G^T(t))\subseteq{\mathcal E}(0,\hat{X}^+_l(t))`,
otherwise the maxmin CLRS
:math:`\overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))` is
empty.

The shape matrix of the external ellipsoid for minmax reach set is
determined from

.. math::
   :label: fwdextminmax1
   
   \breve{X}^+_l(t) & =
   \left((A(t)\underline{X}^+_l(t)A^T(t))^{1/2} +
   \underline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}\right)^T
   \times \nonumber \\
   &\left((A(t)\underline{X}^+_l(t)A^T(t))^{1/2} +
   \underline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}\right)\\

.. math::   
   :label: fwdextminmax2 

   \underline{X}^+_l(t+1) & = 
   (1+\underline{\pi}_l(t))\breve{X}^+_l(t) +
   \left(1+\frac{1}{\underline{\pi}_l(t)}\right)
   B(t)P(t)B^T(t),\\

.. math::
   :label: fwdextminmax3

   \underline{X}^+_l(t_0) & = X_0, 

where

.. math::

   \underline{\pi}_l(t) = \frac{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}{\langle l(t+1),
   \breve{X}^+_l(t)l(t+1)\rangle^{1/2}},

and :math:`\underline{S}_l(t)` is orthogonal matrix determined from the
equation

.. math::

   \begin{aligned}
   & \underline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}l(t+1) = \\
   & \frac{\langle l(t+1),
   G(t)Q(t)G^T(t)l(t+1)\rangle^{1/2}}{\langle l(t),
   \underline{X}^+_l(t)l(t)\rangle^{1/2}}(A(t)\underline{X}^+_l(t)A^T(t))^{1/2}l(t+1).\end{aligned}

Equations :eq:`fwdextminmax1`, :eq:`fwdextminmax2` are valid only if
:math:`{\mathcal E}(0,G(t)Q(t)G^T(t)\subseteq{\mathcal E}(0,A(t)\underline{X}^+_l(t)A^T(t))`,
otherwise minmax CLRS
:math:`\underline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))` is
empty.

The shape matrix of the internal ellipsoid for maxmin reach set is
determined from

.. math::
   :label: fwdintmaxmin1
   
   \hat{X}^-_l(t) & = 
   \left((A(t)\overline{X}^-_l(t)A^T(t))^{1/2} +
   \overline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}\right)^T
   \times \nonumber \\
   & \left((A(t)\overline{X}^-_l(t)A^T(t))^{1/2} +
   \overline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}\right)\\

.. math::
   :label: fwdintmaxmin2
   
   \overline{X}^-_l(t+1) & = 
   (1+\overline{\eta}_l(t))\hat{X}^-_l(t) +
   \left(1+\frac{1}{\underline{\eta}_l(t)}\right)
   G(t)Q(t)G^T(t), \\
   
.. math::
   :label: fwdintmaxmin3

   \overline{X}^-_l(t_0) & = X_0, 

where

.. math::

   \overline{\eta}_l(t) = \frac{\langle l(t+1),
   G(t)Q(t)G^T(t)l(t+1)\rangle^{1/2}}{\langle l(t+1),
   \hat{X}^-_l(t)l(t+1)\rangle^{1/2}},

and :math:`\overline{T}_l(t)` is orthogonal matrix determined from the
equation

.. math::

   \begin{aligned}
   & \overline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}l(t+1) = \\
   & \frac{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}{\langle l(t),
   \overline{X}^-_l(t)l(t)\rangle^{1/2}}(A(t)\overline{X}^-_l(t)A^T(t))^{1/2}l(t+1).\end{aligned}

Equation :eq:`fwdintmaxmin2` is valid only if
:math:`{\mathcal E}(0,G(t)Q(t)G^T(t)\subseteq{\mathcal E}(0,\hat{X}^-_l(t))`.

The shape matrix of the internal ellipsoid for the minmax reach set is
determined by

.. math::
   :label: fwdintminmax1 

   \breve{X}^-_l(t) & = (1+\underline{\eta}_l(t))A(t)\underline{X}^-_l(t)A^T(t) +
   \left(1+\frac{1}{\underline{\eta}_l(t)}\right)
   G(t)Q(t)G^T(t),\\
   
.. math::
   :label: fwdintminmax2

   \underline{X}^-_l(t+1) & = \left((\breve{X}^-_l(t))^{1/2} +
   \underline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}\right)^T
   \times \nonumber \\
   &\left((\breve{X}^-_l(t))^{1/2} + \underline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}\right),\\
   
.. math::
   :label: fwdintminmax3

   \underline{X}^-_l(t_0) & = X_0,

wherein

.. math::

   \underline{\eta}_l(t) = \frac{\langle l(t+1),
   G(t)Q(t)G^T(t)l(t+1)\rangle^{1/2}}{\langle l(t),
   \underline{X}^-_l(t)l(t)\rangle^{1/2}},

and the orthogonal matrix :math:`\underline{T}_l(t)` is determined by
the equation

.. math::

   \begin{aligned}
   &\underline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}l(t+1) = \\
   & \frac{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}{\langle l(t+1),
   \breve{X}^-_l(t)l(t+1)\rangle^{1/2}}(\breve{X}^-_l(t))^{1/2}l(t+1).\end{aligned}

Equations :eq:`fwdintminmax1`, :eq:`fwdintminmax2` are valid only if
:math:`{\mathcal E}(0,G(t)Q(t)G^T(t)\subseteq{\mathcal E}(0,A(t)\underline{X}^-_l(t)A^T(t))`.

The point where the external and the internal ellipsoids both touch the
boundary of the maxmin CLRS is

.. math::

   x_l^+(t) = x_c(t) + \frac{\overline{X}^+_l(t)l(t)}{\langle l(t),
   \overline{X}^+_l(t)l(t)\rangle^{1/2}} ,

and the bounday point of minmax CLRS is

.. math::

   x_l^-(t) = x_c(t) + \frac{\overline{X}^-_l(t)l(t)}{\langle l(t),
   \overline{X}^-_l(t)l(t)\rangle^{1/2}} .

Points :math:`x^{\pm}_l(t)`, :math:`t\geqslant t_0`, form extremal
trajectories. In order for the system to follow the extremal trajectory
specified by some vector :math:`l_0`, the initial state must be

.. math:: 
   :label: dx01
   
   x_l^0 = x_0 + \frac{X_0l_0}{\langle l_0, X_0l_0\rangle^{1/2}}. 

When there is no disturbance (:math:`G(t)=0` or :math:`Q(t)=0`),
:math:`\overline{X}^+_l(t)=\underline{X}^+_l(t)` and
:math:`\overline{X}^-_l(t)=\underline{X}^-_l(t)`, and the open-loop
control that steers the system along the extremal trajectory defined by
:math:`l_0` is

.. math::
   :label: udt

   u_l(t) = p(t) + \frac{P(t)B^T(t)l(t+1)}{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}. 

Each choice of :math:`l_0` defines an external and internal
approximation. If :math:`\overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))` is
nonempty,

.. math::

   \bigcup_{\langle l_0,l_0\rangle=1}{\mathcal E}(x_c(t),\overline{X}^-_l(t)) =
   \overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0)) =
   \bigcap_{\langle l_0,l_0\rangle=1}{\mathcal E}(x_c(t),\overline{X}^+_l(t)).

Similarly for
:math:`\underline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))`,

.. math::

   \bigcup_{\langle l_0,l_0\rangle=1}{\mathcal E}(x_c(t),\underline{X}^-_l(t)) =
   \underline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0)) =
   \bigcap_{\langle l_0,l_0\rangle=1}{\mathcal E}(x_c(t),\underline{X}^+_l(t)).

Similarly, tight ellipsoidal approximations of maxmin and minmax CLBRS
with terminating conditions :math:`(t_1, {\mathcal E}(y_1,Y_1))` can be
obtained for those directions :math:`l(t)` satisfying

.. math::
   :label: bckadjointd

   l(t) = \Phi^T(t_1,t)l_1,


with some fixed :math:`l_1`, for which they exist.

With boundary conditions

.. math::
   :label: bndconds

   y_c(t_1)=y_1, ~~~ \overline{Y}^+_l(t_1)=\overline{Y}^-_l(t_1)=\underline{Y}^+_l(t_1)=\underline{Y}^-_l(t_1)=Y_1,


external and internal ellipsoids for maxmin CLBRS
:math:`\overline{{\mathcal Y}}_{CL}(t_1,t,{\mathcal E}(y_1,Y_1))` at
time :math:`t`, :math:`{\mathcal E}(y_c(t),\overline{Y}^+_l(t))` and
:math:`{\mathcal E}(y_c(t),\overline{Y}^-_l(t))`, are computed as
external and internal ellipsoidal approximations of the geometric
sum-difference

.. math::

   A^{-1}(t)\left(
   {\mathcal E}(y_c(t+1),\overline{Y}^+_l(t+1)) \oplus B(t){\mathcal E}(-p(t),P(t))
   \dot{-}G(t){\mathcal E}(-q(t),Q(t))
   \right)

and

.. math::

   A^{-1}(t)\left(
   {\mathcal E}(y_c(t+1),\overline{Y}^-_l(t+1)) \oplus B(t){\mathcal E}(-p(t),P(t))
   \dot{-}G(t){\mathcal E}(-q(t),Q(t))
   \right)

in direction :math:`l(t)` from :eq:`bckadjointd`. Section
`Geometric Sum-Difference`_ describes the operation of geometric
sum-difference for ellipsoids. 

External and internal ellipsoids for minmax CLBRS
:math:`\underline{{\mathcal Y}}_{CL}(t_1,t,{\mathcal E}(y_1,Y_1))` at
time :math:`t`, :math:`{\mathcal E}(y_c(t),\underline{Y}^+_l(t))` and
:math:`{\mathcal E}(y_c(t),\underline{Y}^-_l(t))`, are computed as
external and internal ellipsoidal approximations of the geometric
difference-sum

.. math::

   A^{-1}(t)\left(
   {\mathcal E}(y_c(t+1),\underline{Y}^+_l(t+1))
   \dot{-}G(t){\mathcal E}(-q(t),Q(t))
   \oplus B(t){\mathcal E}(-p(t),P(t))
   \right)

and

.. math::

   A^{-1}(t)\left(
   {\mathcal E}(y_c(t+1),\underline{Y}^-_l(t+1))
   \dot{-}G(t){\mathcal E}(-q(t),Q(t))
   \oplus B(t){\mathcal E}(-p(t),P(t))
   \right)

in direction :math:`l(t)` from :eq:`bckadjointd`. Section
`Geometric Difference-Sum`_ describes the operation of geometric
difference-sum for ellipsoids.

.. [1]
   In discrete-time case :math:`t` assumes integer values.

.. [2]
   We are being general when giving the basic definitions. However, it
   is important to understand that for any specific *continuous-time*
   dynamical system it must be determined whether the solution exists
   and is unique, and in which class of solutions these conditions are
   met. Here we shall assume that function :math:`f` is such that the
   solution of the differential equation :eq:`ctds1` exists and is unique
   in Fillipov sense. This allows the right-hand side to be
   discontinuous. For discrete-time systems this problem does not exist.

.. [3]
   Minkowski sum of sets
   :math:`{\mathcal W}, {\mathcal Z}\subseteq {\bf R}^n` is defined as
   :math:`{\mathcal W}\oplus {\mathcal Z}= \{w+z ~|~ w\in{\mathcal W}, ~ z\in{\mathcal Z}\}`.
   Set :math:`{\mathcal W}\oplus{\mathcal Z}` is nonempty if and only if
   both, :math:`{\mathcal W}` and :math:`{\mathcal Z}` are nonempty. If
   :math:`{\mathcal W}` and :math:`{\mathcal Z}` are convex, set
   :math:`{\mathcal W}\oplus{\mathcal Z}` is convex.

.. [4]
   :math:`{\mathcal M}` is weakly invariant with respect to the target
   set :math:`{\mathcal Y}_1` and times :math:`t_0` and :math:`t`, if
   for every state :math:`x_0\in{\mathcal M}` there exists a control
   :math:`u(\tau, x(\tau))\in{\mathcal U}(\tau)`,
   :math:`t_0\leqslant\tau< t`, that steers the system from :math:`x_0`
   at time :math:`t_0` to some state in :math:`{\mathcal Y}_1` at time
   :math:`t`. If *all* controls in :math:`{\mathcal U}(\tau)`,
   :math:`t_0\leqslant\tau<t` steer the system from every
   :math:`x_0\in{\mathcal M}` at time :math:`t_0` to
   :math:`{\mathcal Y}_1` at time :math:`t`, set :math:`{\mathcal M}` is
   said to be *strongly* invariant with respect to
   :math:`{\mathcal Y}_1`, :math:`t_0` and :math:`t`.

.. [5]
   There exists :math:`f^{-1}(t,x,u)` such that
   :math:`x(t)=f^{-1}(t, x(t+1), u, v)`.

.. [6]
   Hausdorff semidistance between compact sets
   :math:`{\mathcal W}, {\mathcal Z}\subseteq {\bf R}^n` is defined as

   .. math::

      {\bf dist}({\mathcal W}, {\mathcal Z}) = \min\{\langle w-z, w-z\rangle^{1/2}
      ~|~ w\in{\mathcal W}, \; z\in{\mathcal Z}\},

   where :math:`\langle\cdot, \cdot\rangle` denotes inner product.

.. [7]
   The Minkowski difference of sets
   :math:`{\mathcal W}, {\mathcal Z}\in{\bf R}^n` is defined as
   :math:`{\mathcal W}\dot{-}{\mathcal Z}= \left\{\xi\in{\bf R}^n ~|~
   \xi \oplus {\mathcal Z}\subseteq {\mathcal W}\right\}`. If
   :math:`{\mathcal W}` and :math:`{\mathcal Z}` are convex,
   :math:`{\mathcal W}\dot{-}{\mathcal Z}` is convex if it is nonempty.

.. [8]
   So-called verification problems often consist in ensuring that the
   system is unable to reach an ‘unsafe’ target set within a given time
   interval.

.. [9]
   The case when :math:`A(t)` is singular is described in [VAR2007]_. 
   The idea is to substitute :math:`A(t)` with the
   nonsingular :math:`A_\delta(t) = A(t) + \delta U(t)W(t)`, in which
   :math:`U(t)` and :math:`W(t)` are obtained from the singular value
   decomposition

   .. math:: A(t) = U(t)\Sigma(t)V(t) .

   The parameter :math:`\delta` can be chosen based on the number of
   time steps for which the reach set must be computed and the required
   accuracy. The issue of inverting ill-conditioned matrices is also
   addressed in [VAR2007]_.

.. [10]
   Note that for :eq:`adjointdt` :math:`A(t)` must be invertible.
   
Installation
============

Additional Software
-------------------

These packages aren’t included in the ET distribution. So, you need to
download them separately.

CVX
~~~

Some methods of the *Ellipsoidal Toolbox*, namely,

-  distance

-  intersect

-  isInside

-  doesContain

-  ellintersection\_ia

-  ellunion\_ea

require solving semidefinite programming (SDP) problems. 
We use CVX [CVXHP]_ as an interface to an external SDP solver. CVX is a
reliable toolbox for solving SDP problems of high dimensionality. CVX is
implemented in Matlab, effectively turning Matlab into an optimization
modeling language. Model specifications are constructed using common
Matlab operations and functions, and standard Matlab code can be freely
mixed with these specifications. This combination makes it simple to
perform the calculations needed to form optimization problems, or to
process the results obtained from their solution. CVX distribution
includes two freeware solvers: SeDuMi ([STUR1999]_, [SDMHP]_)
and SDPT3 [SDPT3HP]_. The default solver used in the toolbox
is SeDuMi.

MPT
~~~

Multi-Parametric Toolbox [MPTHP]_ - a
Matlab toolbox for multi-parametric optimization and computational
geometry. MPT is a toolbox that defines polytope class used in *ET*. We
need MPT for the following methods operating with polytopes.

-  distance

-  intersect

-  intersection\_ia

-  intersection\_ea

-  isInside

-  hyperplane2polytope

-  polytope2hyperplane

Installation and Quick Start
----------------------------

#. Go to http://code.google.com/p/ellipsoids and download the *Ellipsoidal Toolbox*.

#. Unzip the distribution file into the directory where you would like
   the toolbox to be.

#. Unzip CVX into cvx folder next to products folder.

#. Unzip MPT into mpt folder next to products folder.

#. Read the copyright notice.

#. In MATLAB command window change the working directory to the one
   where you unzipped the toolbox and type
   
.. literalinclude:: /mcodesnippets/s_chapter04_section01_snippet01.m
   :language: matlab
   :linenos:

#. At this point, the directory tree of the *Ellipsoidal Toolbox* is
   added to the MATLAB path list. In order to save the updated path
   list, in your MATLAB window menu go to File :math:`\rightarrow` Set
   Path... and click Save.

#. To get an idea of what the toolbox is about, type

.. literalinclude:: /mcodesnippets/s_chapter04_section01_snippet02.m
   :language: matlab
   :linenos:


This will produce a demo of basic *ET* functionality: how to create
and manipulate ellipsoids.

Type

.. literalinclude:: /mcodesnippets/s_chapter04_section01_snippet03.m
   :language: matlab
   :linenos:


to learn how to plot ellipsoids and hyperplanes in 2 and 3D. For a
quick tutorial on how to use the toolbox for reachability analysis
and verification, type
   
.. literalinclude:: /mcodesnippets/s_chapter04_section01_snippet04.m
   :language: matlab
   :linenos:
   
Implementation
==============

Operations with ellipsoids
--------------------------

In the *Ellipsoidal Toolbox* we define a new class ellipsoid inside the
MATLAB programming environment. The following three commands define the
same ellipsoid :math:`{\mathcal E}(q,Q)`, with :math:`q\in{\bf R}^n` and
:math:`Q\in{\bf R}^{n\times n}` being symmetric positive semidefinite:

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet01.m
   :language: matlab
   :linenos:
   
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
   
.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet02.m
   :language: matlab
   :linenos:

To access individual elements of the array, the usual MATLAB subindexing is used:

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet03.m
   :language: matlab
   :linenos:
   
Sometimes it may be useful to modify the shape of the ellipsoid without
affecting its center. Say, we would like to bloat or squeeze the
ellipsoid: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet04.m
   :language: matlab
   :linenos:

Since function shape does not change the center of the
ellipsoid, it only accepts scalars or square matrices as its second
input parameter. Several functions access the internal data of the
ellipsoid object: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet05.m
   :language: matlab
   :linenos:
   
.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet06.m
   :language: matlab
   :linenos:
   
.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet07.m
   :language: matlab
   :linenos:


One way to check if two ellipsoids intersect, is to
compute the distance between them ([STANHP]_, [LIN2002]_): 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet08.m
   :language: matlab
   :linenos:

This result indicates that the ellipsoid
thirdEllObj does not intersect with the ellipsoid ellMat(2, 2), with all
the other ellipsoids in ellMat it has nonempty intersection. If the
intersection of the two ellipsoids is nonempty, it can be approximated
by ellipsoids from the outside as well as from the inside. See
[ROS2002]_
for more information about these methods. 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet09.m
   :language: matlab
   :linenos:

It can be checked that
resulting ellipsoid externalEllObj contains the given intersection,
whereas internalEllObj is contained in this intersection: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet10.m
   :language: matlab
   :linenos:
   
.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet11.m
   :language: matlab
   :linenos:
   


Function
isInside in general checks if the intersection of ellipsoids in the
given array contains the union or intersection of ellipsoids or
polytopes.

It is also possible to solve the feasibility problem, that is, to check
if the intersection of more than two ellipsoids is empty: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet12.m
   :language: matlab
   :linenos:
   

In this
particular example the result :math:`-1` indicates that the intersection
of ellipsoids in ellMat is empty. Function intersect in general checks
if an ellipsoid, hyperplane or polytope intersects the union or the
intersection of ellipsoids in the given array: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet13.m
   :language: matlab
   :linenos:
   
.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet14.m
   :language: matlab
   :linenos:   


For the ellipsoids in
:math:`{\bf R}`, :math:`{\bf R}^2` and :math:`{\bf R}^3` the geometric
sum can be computed explicitely and plotted: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet15.m
   :language: matlab
   :linenos:

.. _minksumpic:

.. figure:: /pic/minksum.png
   :alt: approximation
   :figwidth: 40 %

   The geometric sum of ellipsoids.


Figure :num:`#minksumpic` displays the geometric sum of ellipsoids. If
the dimension of the space in which the ellipsoids are defined exceeds
:math:`3`, an error is returned. The result of the geometric sum
operation is not generally an ellipsoid, but it can be approximated by
families of external and internal ellipsoids parametrized by the
direction vector: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet16.m
   :language: matlab
   :linenos:

Functions minksum\_ea and minksum\_ia work for
ellipsoids of arbitrary dimension. They should be used for general
computations whereas minksum is there merely for visualization purposes.

If the geometric difference of two ellipsoids is not an empty set, it
can be computed explicitely and plotted for ellipsoids in
:math:`{\bf R}`, :math:`{\bf R}^2` and :math:`{\bf R}^3`: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet17.m
   :language: matlab
   :linenos:
   
.. _minkdiffpic:

.. figure:: /pic/minkdiff.png
   :alt: approximation
   :figwidth: 40 %

   The geometric difference of ellipsoids.


Figure :num:`#minkdiffpic` shows the geometric difference of ellipsoids.

Similar to minksum, minkdiff is there for visualization purpose. It
works only for dimensions :math:`1`, :math:`2` and :math:`3`, and for
higher dimensions it returns an error. For arbitrary dimensions, the
geometric difference can be approximated by families of external and
internal ellipsoids parametrized by the direction vector, provided this
direction is not bad: 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet18.m
   :language: matlab
   :linenos:

Operation ’difference-sum’ described in section
2.2.4 is implemented in functions minkmp, minkmp\_ea, minkmp\_ia, the
first one of which is used for visualization and works for dimensions
not higher than :math:`3`, whereas the last two can deal with ellipsoids
of arbitrary dimension. 

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet19.m
   :language: matlab
   :linenos:
   
.. _minkpmpic:

.. figure:: /pic/minkpm.png
.. :align: left
   :alt: approximation
   :figwidth: 40 %

   Implementation of an operation 'sum-difference'.

.. _minkmppic:

.. figure:: /pic/minkmp.png
.. :align: left
   :alt: approximation
   :figwidth: 40 %

   Implementation of an operation 'difference-sum'.
   

Figures :num:`#minkpmpic` and :num:`#minkmppic` display results of
the implementation of minkpm and minkmp operations. 

Similarly, operation ’sum-difference’ described in section `Geometric sum-difference`_ is implemented in functions
minkpm, minkpm\_ea, minkpm\_ia, the first one of which is used for
visualization and works for dimensions not higher than :math:`3`,
whereas the last two can deal with ellipsoids of arbitrary dimension.

.. literalinclude:: /mcodesnippets/s_chapter05_section01_snippet20.m
   :language: matlab
   :linenos:


Operations with hyperplanes
---------------------------

The class hyperplane of the *Ellipsoidal Toolbox* is used to describe
hyperplanes and halfspaces. The following two commands define one and
the same hyperplane but two different halfspaces:

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet01.m
   :language: matlab
   :linenos:

The following functions and operators are overloaded for the hyperplane
class:

-  isempty(hypObj) -- checks if hypObj is an empty hyperplane.

-  display(hypObj) -- displays the details of hyperplane
   :math:`H(c,\gamma)`, namely, its normal :math:`c` and the scalar
   :math:`\gamma`.

-  plot(hypObj) -- plots hyperplane :math:`H(c,\gamma)` if the dimension
   of the space in which it is defined is not greater than 3.

-  firstHypObj == secHypObj -- checks if hyperplanes
   :math:`H(c_1,\gamma_1)` and :math:`H(c_2,\gamma_2)` are equal.

-  firstHypObj = secHypObj -- checks if hyperplanes
   :math:`H(c_1,\gamma_1)` and :math:`H(c_2,\gamma_2)` are not equal.

-  [ , ] -- concatenates the hyperplanes into the horizontal array, e.g. hypVec
   = [firstHypObj secHypObj thirdHypObj].

-  [ ; ] -- concatenates the hyperplanes into the vertical array, e.g. hypMat =
   [firstHypObj secHypObj; thirdHypObj fourthHypObj] -- defines
   :math:`2\times 2` array of hyperplanes.

-  -hypObj -- defines hyperplane :math:`H(-c,-\gamma)`, which is the same
   as :math:`H(c,\gamma)` but specifies different halfspace.

There are several ways to access the internal data of the hyperplane
object: 

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet02.m
   :language: matlab
   :linenos:

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet03.m
   :language: matlab
   :linenos:

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet04.m
   :language: matlab
   :linenos:



All the functions of *Ellipsoidal Toolbox* that accept
hyperplane object as parameter, work with single hyperplanes as well as
with hyperplane arrays. One exception is the function parameters that
allows only single hyperplane object.

An array of hyperplanes can be converted to the polytope object of the
Multi-Parametric Toolbox ([KVAS2004]_, [MPTHP]_), and back: 

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet05.m
   :language: matlab
   :linenos:


Functions hyperplane2polytope and
polytope2hyperplane require the Multi-Parametric Toolbox to be
installed.

We can compute distance from ellipsoids to hyperplanes and polytopes: 

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet06.m
   :language: matlab
   :linenos:


A negative distance value in the case of ellipsoid and hyperplane means
that the ellipsoid intersects the hyperplane. As we see in this example,
ellipsoid firstEllObj intersects hyperplanes hypVec(1) and hypVec(3) and
has no common points with hypVec(2) and hypVec(4). When distance
function has a polytope as a parameter, it always returns nonnegative
values to be consistent with distance function of the Multi-Parametric
Toolbox. Here, the zero distance values mean that each ellipsoid in
ellMat has nonempty intersection with polytope firstPolObj.

It can be checked if the union or intersection of given ellipsoids
intersects given hyperplanes or polytopes:


.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet07.m
   :language: matlab
   :linenos:

   
.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet08.m
   :language: matlab
   :linenos:

   
.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet09.m
   :language: matlab
   :linenos:


The intersection of ellipsoid and hyperplane can be computed exactly:

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet10.m
   :language: matlab
   :linenos:


Functions intersection\_ea and intersection\_ia can be used with
hyperplane objects, which in this case define halfspaces and polytope
objects:

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet11.m
   :language: matlab
   :linenos:


Function isInside can be used to check if a polytope or union of
polytopes is contained in the intersection of given ellipsoids:

.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet12.m
   :language: matlab
   :linenos:
   
.. literalinclude:: /mcodesnippets/s_chapter05_section02_snippet13.m
   :language: matlab
   :linenos:

Functions distance, intersect, intersection\_ia and isInside use the CVX
interface ([CVXHP]_) to the external optimization package. The
default optimization package included in the distribution of the
*Ellipsoidal Toolbox* is SeDuMi ([STUR1999]_, [SDMHP]_).

Operations with ellipsoidal tubes
---------------------------------

There are several classes in *Ellipsoidal Toolbox* for operations with
ellipsoidal tubes. The class gras.ellapx.smartdb.rels.EllTube is used to
describe ellipsoidal tubes. The class
gras.ellapx.smartdb.rels.EllUnionTube is used to store tubes by the
instant of time:

.. math:: {\mathcal X}_{U}[t]=\bigcup \limits_{\tau\leqslant t}{\mathcal X}[\tau],

where :math:`{\mathcal X}[\tau]` is single ellipsoidal tube. The class
gras.ellapx.smartdb.rels.EllTubeProj is used to describe the projection
of the ellipsoidal tubes onto time dependent subspaces.There are two
types of projection: static and dynamic. Also there is class
gras.ellapx.smartdb.rels.EllUnionTubeStaticProj for description of the
projection on static plane tubes by the instant of time. Next we provide
some examples of the operations with ellipsoidal tubes. 

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet01.m
   :language: matlab
   :linenos:

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet02.m
   :language: matlab
   :linenos:

We may be
interested in the data about ellipsoidal tube in some particular time
interval, smaller than the one for which the ellipsoidal tube was
computed, say :math:`2\leqslant t\leqslant4`. This data can be extracted
by the cut function: 

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet03.m
   :language: matlab
   :linenos:
   
.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet04.m
   :language: matlab
   :linenos:

We can compute the projection of the ellipsoidal
tube onto time-dependent subspace.

.. _stat-proj:

.. figure:: /pic/reachTubeStatProj.png
.. :align: center
   :alt: approximation
   :figwidth: 50 %

   Static projection of the ellipsoidal tube.

.. _dyn-proj:

.. figure:: /pic/reachTubeDynProj.png
.. :align: center
   :alt: approximation
   :figwidth: 50 %

   Dynamic projection of the ellipsoidal tube.

Figures :num:`#stat-proj` and :num:`#dyn-proj` display static and dynamic projections.
Also we can see projections of good directions for ellipsoidal tubes.

We can compute tubes by the instant of time using methodfromEllTubes:

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet05.m
   :language: matlab
   :linenos:
   
.. _uniontubestatproj:

.. figure:: /pic/unionTubeStatProj.png
.. :align: center
   :alt: approximation
   :figwidth: 50 %

   Ellipsoidal tubes by the instant of time.
   
Figure :num:`#uniontubestatproj` shows projection of ellipsoidal
tubes by the instant of time.

Also we can get initial data from the resulting tube: 

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet06.m
   :language: matlab
   :linenos:
   
There is a method
to display a content of ellipsoidal tubes. 

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet07.m
   :language: matlab
   :linenos:
   
.. _disppic:

.. figure:: /pic/dispPic.png
.. :align: center
   :alt: approximation
   :figwidth: 40 %

   Content of the ellipsoidal tube.

   
Figure :num:`#disppic`
displays all fields of the ellipsoidal tube.

There are several methods to find the tubes with necessary parameters.

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet08.m
   :language: matlab
   :linenos:
   
Also you can use the method display to see the result of the method’s
work. 

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet09.m
   :language: matlab
   :linenos:

We can sort our tubes by certain fields:

.. literalinclude:: /mcodesnippets/s_chapter05_section03_snippet10.m
   :language: matlab
   :linenos:

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

is done by the following sequence of commands: 

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet01.m
   :language: matlab
   :linenos:

If matrices :math:`A` or
:math:`B` depend on time, say :math:`A(t)=\left[\begin{array}{cc}
0 & 1-\cos(2t)\\
-\frac{1}{t} & 0\end{array}\right]`, then matrix aMat should be
symbolic:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet02.m
   :language: matlab
   :linenos:


To describe the system with disturbance

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
:math:`-1\leqslant v(t)\leqslant1`, we type: 

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet03.m
   :language: matlab
   :linenos:

Control and disturbance
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
   1\end{array}\right]u[k], ~~~ -1\leqslant u[k]\leqslant1,

we use LinSysDiscrete constructor: 

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet04.m
   :language: matlab
   :linenos:

Once the LinSysDiscrete object is
created, we need to specify the set of initial conditions, the time
interval and values of the direction vector, for which the reach set
approximations must be computed: 

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet05.m
   :language: matlab
   :linenos:

The reach set approximation is computed
by calling the constructor of the ReachContinuous object: 

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet06.m
   :language: matlab
   :linenos:

At this point,
variable firstRsObj contains the reach set approximations for the
specified continuous-time system, time interval and set of initial
conditions computed for given directions. Both external and internal
approximations are computed. The reach set approximation data can be
extracted in the form of arrays of ellipsoids:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet07.m
   :language: matlab
   :linenos:


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
was computed, say :math:`3\leqslant t\leqslant5`. This data can be
extracted and returned in the form of ReachContinuous object by the cut
function:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet08.m
   :language: matlab
   :linenos:

To obtain a snap shot of the reach set at given time, the same function
cut is used: 

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet09.m
   :language: matlab
   :linenos:

It can be checked if the external or internal reach set
approximation intersects with given ellipsoids, hyperplanes or
polytopes:


.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet10.m
   :language: matlab
   :linenos:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet11.m
   :language: matlab
   :linenos:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet12.m
   :language: matlab
   :linenos:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet13.m
   :language: matlab
   :linenos:


If a given set intersects with the internal approximation of the reach
set, then this set intersects with the actual reach set. If the given
set does not intersect with external approximation, this set does not
intersect the actual reach set. There are situations, however, when the
given set intersects with the external approximation but does not
intersect with the internal one. In our example above, ellipsoid ellObj
is such a case: the quality of the approximation does not allow us to
determine whether or not ellObj intersects with the actual reach set. To
improve the quality of approximation, refine function should be used:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet14.m
   :language: matlab
   :linenos:


Now we are sure that ellipsoid ellObj intersects with the actual reach
set. However, to use the refine function, the reach set object must
contain all calculated data, otherwise, an error is returned.

Having a reach set object resulting from the ReachContinuous, cut or
refine operations, we can obtain the trajectory of the center of the
reach set and the good curves along which the actual reach set is
touched by its ellipsoidal approximations:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet15.m
   :language: matlab
   :linenos:


Variable ctrMat here is a matrix whose columns are the points ofthe
reach set center trajectory evaluated at time values returned in the
array ttVec. Variable gcCMat contains :math:`4` matrices each of which
corresponds to a good curve (columns of such matrix are points of the
good curve evaluated at time values in ttVec). The analytic expression
for the control driving the system along a good curve is given by
formula :eq:`uct`.

We computed the reach set up to time :math:`10`. It is possible to
continue the reach set computation for a longer time horizon using the
reach set data at time :math:`10` as initial condition. It is also
possible that the dynamics and inputs of the system change at certain
time, and from that point on the system evolves according to the new
system of differential equations. For example, starting at time
:math:`10`, our reach set may evolve in time according to the
time-variant system sys\_t defined above. Switched systems are a special
case of this situation. To compute the further evolution in time of the
existing reach set, function evolve should be used: 

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet16.m
   :language: matlab
   :linenos:

Function evolve can
be viewed as an implementation of the semigroup property.

To compute the backward reach set for some specified target set, we
declare the time interval so that the terminating time comes first:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet17.m
   :language: matlab
   :linenos:


Reach set and backward reach set computation for discrete-time systems
and manipulations with the resulting reach set object are performed
using the same functions as for continuous-time systems:

.. literalinclude:: /mcodesnippets/s_chapter05_section04_snippet18.m
   :language: matlab
   :linenos:


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
utilities: 

.. literalinclude:: /mcodesnippets/s_chapter05_section05_snippet01.m
   :language: matlab
   :linenos:

Here we list system parameters available from the ’default’
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
parameters. 

.. literalinclude:: /mcodesnippets/s_chapter05_section05_snippet02.m
   :language: matlab
   :linenos:

Some of the parameters can be changed in run-time via
setters.

.. literalinclude:: /mcodesnippets/s_chapter05_section05_snippet03.m
   :language: matlab
   :linenos:

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

.. literalinclude:: /mcodesnippets/s_chapter05_section06_snippet01.m
   :language: matlab
   :linenos:


Since the operation of projection is linear, the projection of the
geometric sum of ellipsoids equals the geometric sum of the projected
ellipsoids. The same is true for the geometric difference of two
ellipsoids.

Function projection exists also for the
ReachContinuous\ :math:`\backslash`\ ReachDiscrete objects:

.. literalinclude:: /mcodesnippets/s_chapter05_section06_snippet02.m
   :language: matlab
   :linenos:


The quality of the ellipsoid and reach set plots is controlled by the
parameters nPlot2dPoints and nPlot3dPoints, which are available from
getters of ellipsoid class.

Examples
========

Ellipsoids vs. Polytopes
------------------------

Depending on the particular dynamical system, certain methods of reach
set computation may be more suitable than others. Even for a simple
2-dimensional discrete-time linear time-invariant system, application of
ellipsoidal methods may be more effective than using polytopes.

Consider the system from chapter 1:

.. math::

   \left[\begin{array}{c}
   x_1[k+1]\\
   x_2[k+1]\end{array}\right] = \left[\begin{array}{cc}
   \cos(1) & \sin(1)\\
   -\sin(1) & \cos(1)\end{array}\right]\left[\begin{array}{c}
   x_1[k]\\
   x_2[k]\end{array}\right] + \left[\begin{array}{c}\
   u_1[k]\\
   u_2[k]\end{array}\right], ~~~ x[0]\in{\mathcal X}_0, ~~~ u[k]\in U, ~~~ k\geqslant0,

where :math:`{\mathcal X}_0` is the set of initial conditions, and
:math:`U` is the control set.

.. _ellpolyfig:

.. figure:: /pic/ellpoly.png
   :alt: approximation
   :figwidth: 70 %

   Reach set computation performance comparison.


Let :math:`{\mathcal X}_0` and :math:`U` be unit boxes in
:math:`{\bf R}^2`, and compute the reach set using the polytope method
implemented in MPT [MPTHP]_. With every
time step the number of vertices of the reach set polytope increases by
:math:`4`. The complexity of the convex hull computation increases
exponentially with number of vertices. In :num:`figure #ellpolyfig`, the time
required to compute the reach set for different time steps using
polytopes is shown in red.

To compute the reach set of the system using *Ellipsoidal Toolbox*, we
assume :math:`{\mathcal X}_0` and :math:`U` to be unit balls in
:math:`{\bf R}^2`, fix any number of initial direction values that
corresponds to the number of ellipsoidal approximations, and obtain
external and internal ellipsoidal approximations of the reach set:

.. literalinclude:: /mcodesnippets/s_chapter06_section01_snippet01.m
   :language: matlab
   :linenos:

In :num:`figure #ellpolyfig`, the time required to compute both external and
internal ellipsoidal approximations, with :math:`32` ellipsoids each,
for different number of time steps is shown in blue.

:num:`Figure #ellpolyfig` illustrates the fact that the complexity of polytope
method grows exponentially with number of time steps, whereas the
complexity of ellipsoidal method grows linearly.

System with Disturbance
-----------------------

.. _springmassfig:

.. figure:: /pic/springmass.png
   :alt: spmass
   :figwidth: 50 %

   Spring-mass system.


The mechanical system presented in :num:`figure #springmassfig`, is described
by the following system of equations:

.. math:: 
   :label: spmass1

   m_1\ddot{x}_1+(k_1+k_2)x_1-k_2x_2 & = u_1, 

.. math::
   :label: spmass2
   
   m_2\ddot{x}_2-k_2x_1+(k_1+k_2)x_2 & = u_2 . 

Here :math:`u_1` and :math:`u_2` are the forces applied to masses
:math:`m_1` and :math:`m_2`, and we shall assume
:math:`[u_1 ~~ u_2]^T\in{\mathcal E}(0,I)`. The initial conditions can
be taken as :math:`x_1(0)=0`, :math:`x_2(0)=2`. Defining
:math:`x_3=\dot{x}_1` and :math:`x_4=\dot{x}_2`, we can rewrite
:eq:`spmass1`-:eq:`spmass2` as a linear system in standard form:

.. math::
   :label: spmassls

   \left[\begin{array}{c}
   \dot{x}_1 \\
   \dot{x}_2 \\
   \dot{x}_3 \\
   \dot{x}_4 \end{array}\right] = \left[\begin{array}{cccc}
   0 & 0 & 1 & 0\\
   0 & 0 & 0 & 1\\
   -\frac{k_1+k_2}{m_1} & \frac{k_2}{m_1} & 0 & 0\\
   \frac{k_2}{m_2} & -\frac{k_1+k_2}{m_2} & 0 & 0\end{array}\right]
   \left[\begin{array}{c}
   x_1 \\
   x_2 \\
   x_3 \\
   x_4 \end{array}\right] + \left[\begin{array}{cc}
   0 & 0\\
   0 & 0\\
   \frac{1}{m_1} & 0\\
   0 & \frac{1}{m_2}\end{array}\right]\left[\begin{array}{c}
   u_1\\
   u_2\end{array}\right]. 

Now we can compute the reach set of system :eq:`spmass1`-:eq:`spmass2` for
given time by computing the reach set of the linear system :eq:`spmassls`
and taking its projection onto :math:`(x_1, x_2)` subspace. 

.. _mechreachfig:

.. figure:: /pic/reachmech.png
   :alt: reachmech
   :figwidth: 40 %

   Spring-mass system without disturbance:
   (a) reach tube for time :math:`t\in[0,4]`; (b) reach set at time :math:`t=4`.
   Spring-mass system with disturbance:
   (c) reach tube for time :math:`t\in[0,4]`; (d) reach set at time :math:`t=4`.

.. literalinclude:: /mcodesnippets/s_chapter06_section02_snippet01.m
   :language: matlab
   :linenos:

  
Figure :num:`#mechreachfig` (a) shows the reach set of the system
:eq:`spmass1`-:eq:`spmass2` evolving in time from :math:`t=0` to :math:`t=4`.
Figure :num:`#mechreachfig` (b) presents a snapshot of this reach set at time
:math:`t=4`.

So far we considered an ideal system without any disturbance, such as
friction. We introduce disturbance to :eq:`spmass1`-:eq:`spmass2` by adding
extra terms, :math:`v_1` and :math:`v_2`,

.. math::
   :label: smdist1

   m_1\ddot{x}_1+(k_1+k_2)x_1-k_2x_2 & = u_1 + v_1,
   
.. math::
   :label: smdist2
   
   m_2\ddot{x}_2-k_2x_1+(k_1+k_2)x_2 & = u_2 + v_2,

which results in equation :eq:`spmassls` getting an extra term

.. math::

   \left[\begin{array}{cc}
   0 & 0\\
   0 & 0\\
   1 & 0\\
   0 & 1\end{array}\right]\left[\begin{array}{c}
   v_1\\
   v_2\end{array}\right].

Assuming that :math:`[v_1 ~~ v_2]^T` is unknown but bounded by
ellipsoid :math:`{\mathcal E}(0, \frac{1}{4}I)`, we can compute the
closed-loop reach set of the system with disturbance.

.. literalinclude:: /mcodesnippets/s_chapter06_section02_snippet02.m
   :language: matlab
   :linenos:


:num:`Figure #mechreachfig` (c) shows the reach set of the system
:eq:`smdist1`-:eq:`smdist2` evolving in time from :math:`t=0` to :math:`t=4`.
:num:`Figure #mechreachfig` (d) presents a snapshot of this reach set at time
:math:`t=4`.

Switched System
---------------

.. _rlcfig:

.. figure:: /pic/rlc.png
   :alt: rlc
   :figwidth: 60 %

   RLC circuit with two inputs.

By *switched systems* we mean systems whose dynamics changes at known
times. Consider the RLC circuit shown in :num:`figure #rlcfig`. It has two
inputs - the voltage (:math:`v`) and current (:math:`i`) sources. Define

-  :math:`x_1` - voltage across capacitor :math:`C_1`, so
   :math:`C_1\dot{x}_1` is the corresponding current;

-  :math:`x_2` - voltage across capacitor :math:`C_2`, so the
   corresponding current is :math:`C_2\dot{x}_2`.

-  :math:`x_3` - current through the inductor :math:`L`, so the voltage
   across the inductor is :math:`L\dot{x}_3`.

Applying Kirchoff current and voltage laws we arrive at the linear
system,

.. math::
   :label: rlceq

   \left[\begin{array}{c}
   \dot{x}_1\\
   \dot{x}_2\\
   \dot{x}_3\end{array}\right] = \left[\begin{array}{ccc}
   -\frac{1}{R_1C_1} & 0 & -\frac{1}{C_1}\\
   0 & 0 & \frac{1}{C_2}\\
   \frac{1}{L} & -\frac{1}{L} & -\frac{R_2}{L}\end{array}\right]
   \left[\begin{array}{c}
   x_1\\
   x_2\\
   x_3\end{array}\right] + \left[\begin{array}{cc}
   \frac{1}{R_1C_1} & \frac{1}{C_1}\\
   0 & 0\\
   0 & 0\end{array}\right]\left[\begin{array}{c}
   v\\
   i\end{array}\right].

The parameters :math:`R_1`, :math:`R_2`, :math:`C_1`, :math:`C_2` and
:math:`L`, as well as the inputs, may depend on time. Suppose, for time
:math:`0\leqslant t<2`, :math:`R_1=2` Ohm, :math:`R_2=1` Ohm,
:math:`C_1=3` F, :math:`C_2=7` F, :math:`L=2` H, both inputs, :math:`v`
and :math:`i` are present and bounded by ellipsoid
:math:`{\mathcal E}(0,I)`; and for time :math:`t\geqslant2`,
:math:`R_1=R_2=2` Ohm, :math:`C_1=C_2=3` F, :math:`L=6` H, the current
source is turned off, and :math:`|v|\leqslant1`. Then, system :eq:`rlceq`
can be rewritten as

.. math::
   :label: rlceq2

   \left[\begin{array}{c}
   \dot{x}_1\\
   \dot{x}_2\\
   \dot{x}_3\end{array}\right] = \left\{\begin{array}{ll}
   \left[\begin{array}{ccc}
   -\frac{1}{6} & 0 & -\frac{1}{3}\\
   0 & 0 & \frac{1}{7}\\
   \frac{1}{2} & -\frac{1}{2} & -\frac{1}{2}\end{array}\right]
   \left[\begin{array}{c}
   x_1\\
   x_2\\
   x_3\end{array}\right] + \left[\begin{array}{cc}
   \frac{1}{6} & \frac{1}{3}\\
   0 & 0\\
   0 & 0\end{array}\right]\left[\begin{array}{c}
   v\\
   i\end{array}\right], & 0\leqslant t< 2, \\
   \left[\begin{array}{ccc}
   -\frac{1}{6} & 0 & -\frac{1}{3}\\
   0 & 0 & \frac{1}{3}\\
   \frac{1}{6} & -\frac{1}{6} & -\frac{1}{3}\end{array}\right]
   \left[\begin{array}{c}
   x_1\\
   x_2\\
   x_3\end{array}\right] + \left[\begin{array}{c}
   \frac{1}{6} \\
   0 \\
   0 \end{array}\right]v, & 2\leqslant t. \end{array}\right.


We can compute the reach set of :eq:`rlceq2` for some time :math:`t>2`,
say, :math:`t=3`.

.. literalinclude:: /mcodesnippets/s_chapter06_section03_snippet01.m
   :language: matlab
   :linenos:
   
.. _rlcreachfig:

.. figure:: /pic/rlcreach.png
   :alt: rlcreach
   :scale: 70 %

   Forward and backward reach sets of the switched system
   (external and internal approximations).


:num:`Figure #rlcreachfig` (a) shows how the reach set projection onto
:math:`(x_1, x_2)` of system :eq:`rlceq2` evolves in time from :math:`t=0`
to :math:`t=3`. The external reach set approximation for the first
dynamics is in red, the internal approximation is in green. The dynamics
switches at :math:`t=2`. The external reach set approximation for the
second dynamics is in yellow, its internal approximation is in blue. The
full three-dimensional external (yellow) and internal (blue)
approximations of the reach set are shown in :num:`figure #rlcreachfig` (b).

To find out where the system should start at time :math:`t=0` in order
to reach a neighborhood M of the origin at time :math:`t=3`, we compute
the backward reach set from :math:`t=3` to :math:`t=0`. 

.. literalinclude:: /mcodesnippets/s_chapter06_section03_snippet02.m
   :language: matlab
   :linenos:

:num:`Figure #rlcreachfig` (c) presents the evolution of the reach set projection onto
:math:`(x_1, x_2)` in backward time. Again, external and internal
approximations corresponding to the first dynamics are shown in red and
green, and to the second dynamics in yellow and blue. The full
dimensional backward reach set external and internal approximations of
system :eq:`rlceq2` at time :math:`t=0` is shown in :num:`figure #rlcreachfig` (d).

Hybrid System
-------------

.. _hwfig:

.. figure:: /pic/hw.png
   :alt: highway
   :figwidth: 60 %

   Highway model. Adapted from [SUN2003]_.

There is no explicit implementation of the reachability analysis for
hybrid systems in the *Ellipsoidal Toolbox*. Nonetheless, the operations
of intersection available in the toolbox allow us to work with certain
class of hybrid systems, namely, hybrid systems with affine continuous
dynamics whose guards are ellipsoids, hyperplanes, halfspaces or
polytopes.

We consider the *switching-mode model* of highway traffic presented in
[SUN2003]_. The highway segment is divided into :math:`N`
cells as shown in :num:`figure #hwfig`. In this particular case, :math:`N=4`.
The traffic density in cell :math:`i` is :math:`x_i` vehicles per mile,
:math:`i=1,2,3,4`.

Define

-  :math:`v_i` - average speed in mph, in the :math:`i`-th cell,
   :math:`i=1,2,3,4`;

-  :math:`w_i` - backward congestion wave propagation speed in mph, in
   the :math:`i`-th highway cell, :math:`i=1,2,3,4`;

-  :math:`x_{Mi}` - maximum allowed density in the :math:`i`-th cell;
   when this velue is reached, there is a traffic jam,
   :math:`i=1,2,3,4`;

-  :math:`d_i` - length of :math:`i`-th cell in miles,
   :math:`i=1,2,3,4`;

-  :math:`T_s` - sampling time in hours;

-  :math:`b` - split ratio for the off-ramp;

-  :math:`u_1` - traffic flow coming into the highway segment, in
   vehicles per hour (vph);

-  :math:`u_2` - traffic flow coming out of the highway segment (vph);

-  :math:`u_3` - on-ramp traffic flow (vph).

Highway traffic operates in two modes: *free-flow* in normal operation;
and *congested* mode, when there is a jam. Traffic flow in free-flow
mode is described by

.. math::
   :label: fflow

   \begin{aligned}
   \left[\begin{array}{c}
   x_1[t+1]\\
   x_2[t+1]\\
   x_3[t+1]\\
   x_4[t+1]\end{array}\right] & = & \left[\begin{array}{cccc}
   1-\frac{v_1T_s}{d_1} & 0 & 0 & 0\\
   \frac{v_1T_s}{d_2} & 1-\frac{v_2T_s}{d_2} & 0 & 0\\
   0 & \frac{v_2T_s}{d_3} & 1-\frac{v_3T_s}{d_3} & 0\\
   0 & 0 & (1-b)\frac{v_3T_s}{d_4} & 1-\frac{v_4T_s}{d_4}\end{array}\right]
   \left[\begin{array}{c}
   x_1[t]\\
   x_2[t]\\
   x_3[t]\\
   x_4[t]\end{array}\right] \nonumber\\
   & + & \left[\begin{array}{ccc}
   \frac{v_1T_s}{d_1} & 0 & 0\\
   0 & 0 & \frac{v_2T_s}{d_2}\\
   0 & 0 & 0\\
   0 & 0 & 0\end{array}\right]\left[\begin{array}{c}
   u_1\\
   u_2\\
   u_3\end{array}\right].\end{aligned}

The equation for the congested mode is

.. math::
   :label: cflow

   \begin{aligned}
   \left[\begin{array}{c}
   x_1[t+1]\\
   x_2[t+1]\\
   x_3[t+1]\\
   x_4[t+1]\end{array}\right] & = & \left[\begin{array}{cccc}
   1-\frac{w_1T_s}{d_1} & \frac{w_2T_s}{d_1} & 0 & 0\\
   0 & 1-\frac{w_2T_s}{d_2} & \frac{w_3T_s}{d_2} & 0\\
   0 & 0 & 1-\frac{w_3T_s}{d_3} & \frac{1}{1-b}\frac{w_4T_s}{d_3}\\
   0 & 0 & 0 & 1-\frac{w_4T_s}{d_4}\end{array}\right]
   \left[\begin{array}{c}
   x_1[t]\\
   x_2[t]\\
   x_3[t]\\
   x_4[t]\end{array}\right] \nonumber\\
   & + & \left[\begin{array}{ccc}
   0 & 0 & \frac{w_1T_s}{d_1}\\
   0 & 0 & 0\\
   0 & 0 & 0\\
   0 & -\frac{w_4T_s}{d_4} & 0\end{array}\right]\left[\begin{array}{c}
   u_1\\
   u_2\\
   u_3\end{array}\right] \nonumber\\
   & + & \left[\begin{array}{cccc}
   \frac{w_1T_s}{d_1} & -\frac{w_2T_s}{d_1} & 0 & 0\\
   0 & \frac{w_2T_s}{d_2} & -\frac{w_3T_s}{d_2} & 0\\
   0 & 0 & \frac{w_3T_s}{d_3} & -\frac{1}{1-b}\frac{w_4T_s}{d_3}\\
   0 & 0 & 0 & \frac{w_4T_s}{d_4}\end{array}\right]
   \left[\begin{array}{c}
   x_{M1}\\
   x_{M2}\\
   x_{M3}\\
   x_{M4}\end{array}\right].\end{aligned}

The switch from the free-flow to the congested mode occurs when the
density :math:`x_2` reaches :math:`x_{M2}`. In other words, the
hyperplane :math:`H([0 ~ 1 ~ 0 ~ 0]^T, x_{M2})` is the guard.

We indicate how to implement the reach set computation of this hybrid
system. We first define the two linear systems and the guard.

.. literalinclude:: /mcodesnippets/s_chapter06_section04_snippet01.m
   :language: matlab
   :linenos:

We assume that initially the system is in free-flow mode. Given a set of
initial conditions, we compute the reach set according to dynamics
:eq:`fflow` for certain number of time steps. We will consider the
external approximation of the reach set by a single ellipsoid.

.. literalinclude:: /mcodesnippets/s_chapter06_section04_snippet02.m
   :language: matlab
   :linenos:

Having obtained the ellipsoidal array externalEllMat representing the
reach set evolving in time, we determine the ellipsoids in the array
that intersect the guard.

.. literalinclude:: /mcodesnippets/s_chapter06_section04_snippet03.m
   :language: matlab
   :linenos:
   
.. _hwreachfig:

.. figure:: /pic/hwreach.png
   :alt: highway
   :figwidth: 70 %

   Reach set of the free-flow system is blue, reach set of the congested
   system is green, the guard is red.
   (a) Reach set of the free-flow system at :math:`t = 10`, before reaching the guard
   (projection onto :math:`(x_1,x_2,x_3)`).
   (b) Reach set of the free-flow system at :math:`t = 50`, crossing the guard.
   (projection onto :math:`(x_1,x_2,x_3)`).
   (c) Reach set of the free-flow system at :math:`t = 80`, after the guard is crossed.
   (projection onto :math:`(x_1,x_2,x_3)`).
   (d) Reach set trace from :math:`t=0` to `t=100`, free-flow system in blue,
   congested system in green; bounds of initial conditions are marked with magenta
   (projection onto :math:`(x_1,x_2)`).

Analyzing the values in array dVec, we conclude that the free-flow reach
set has nonempty intersection with hyperplane grdHyp at :math:`t=18` for
the first time, and at :math:`t=68` for the last time. Between
:math:`t=18` and :math:`t=68` it crosses the guard. :num:`Figure #hwreachfig` (a) 
shows the free-flow reach set projection onto
:math:`(x_1,x_2,x_3)` subspace for :math:`t=10`, before the guard
crossing; :num:`figure #hwreachfig` (b) for :math:`t=50`, during the guard
crossing; and :num:`figure #hwreachfig` (c) for :math:`t=80`, after the guard
was crossed.

For each time step that the intersection of the free-flow reach set and
the guard is nonempty, we establish a new initial time and a set of
initial conditions for the reach set computation according to dynamics
:eq:`cflow`. The initial time is the array index minus one, and the set of
initial conditions is the intersection of the free-flow reach set with
the guard.

.. literalinclude:: /mcodesnippets/s_chapter06_section04_snippet04.m
   :language: matlab
   :linenos:

The union of reach sets in array crs forms the reach set for the
congested dynamics.

A summary of the reach set computation of the linear hybrid system
:eq:`fflow`-:eq:`cflow` for :math:`N=100` time steps with one guard crossing
is given in :num:`figure #hwreachfig` (d), which shows the projection of the
reach set trace onto :math:`(x_1,x_2)` subspace. The system starts
evolving in time in free-flow mode from a set of initial conditions at
:math:`t=0`, whose boundary is shown in magenta. The free-flow reach set
evolving from :math:`t=0` to :math:`t=100` is shown in blue. Between
:math:`t=18` and :math:`t=68` the free-flow reach set crosses the guard.
The guard is shown in red. For each nonempty intersection of the
free-flow reach set and the guard, the congested mode reach set starts
evolving in time until :math:`t=100`. All the congested mode reach sets
are shown in green. Observe that in the congested mode, the density
:math:`x_2` in the congested part decreases slightly, while the density
:math:`x_1` upstream of the congested part increases. The blue set above
the guard is not actually reached, because the state evolves according
to the green region.

Summary and Outlook
===================

Although some of the operations with ellipsoids are present in the
commercial Geometric Bounding Toolbox Veres et al. (2001; “Geometric
Bounding Toolbox Homepage”), the ellipsoid-related functionality of that
toolbox is rather limited.

*Ellipsoidal Toolbox* is the first free MATLAB package that implements
ellipsoidal calculus and uses ellipsoidal methods for reachability
analysis of continuous- and discrete-time affine systems,
continuous-time linear systems with disturbances and switched systems,
whose dynamics changes at known times. The reach set computation for
hybrid systems whose guards are hyperplanes or polyhedra is not
implemented explicitly, but the tool for such computation exists,
namely, the operations of intersection of ellipsoid with hyperplane and
ellipsoid with halfspace.

Acknowledgement
===============

The authors would like to thank Alexander B. Kurzhanski, Manfred Morari,
Johan Löfberg, Michal Kvasnica and Goran Frehse for their support of
this work by useful advice and encouragement.


.. [CVXHP] CVX homepage. http://cvxr.com/cvx.

.. [SDPT3HP] SDPT3 homepage. http://www.math.nus.edu.sg/~mattohkc/sdpt3.html.

.. [SDMHP] SeDuMi homepage. http://sedumi.mcmaster.ca.

.. [GEOMHP] Geometric Bounding Toolbox Homepage. www.sysbrain.com/gbt.

.. [MATHP] MATISSE homepage. http://www.seas.upenn.edu/~agirard/Software/MATISSE.

.. [ZONOHP] Zonotope methods on Wolfgang Kühn homepage. http://www.decatur.de.

.. [MPTHP] Multi-Parametric Toolbox homepage. http://control.ee.ethz.ch/~mpt.

.. [CDDHP] CDD/CDD+ homepage. http://www.cs.mcgill.ca/~fukuda/soft/cdd_home/cdd.html.

.. [DDTHP] :math:`d/dt` homepage. http://www-verimag.imag.fr/~tdang/ddt.html.

.. [CMHP] CheckMate homepage. http://www.ece.cmu.edu/~webk/checkmate.

.. [LSTHP] Level Set Toolbox homepage. http://www.cs.ubc.ca/~mitchell/ToolboxLS.

.. [REQHP] Requiem homepage. http://www.seas.upenn.edu/~hybrid/requiem/requiem.html.

.. [STANHP] Stanley Chan Article Homepage. http://videoprocessing.ucsd.edu/~stanleychan/publication/unpublished/Ellipse.pdf.

.. [KVAS2004] M. Kvasnica, P. Grieder, M. Baotic, and M. Morari. Multi-Parametric Toolbox (MPT). In
   R. Alur and G. J. Pappas, editors, *Hybrid Systems: Computation and Control*, volume 2993 of
   *Lecture Notes in Computer Science*, pages 448–462. Springer, 2004.

.. [MOTZ1953] T. S. Motzkin, H. Raiffa, G. L. Thompson, and R. M. Thrall. The double description method.
   In H. W. Kuhn and A. W. Tucker, editors, *Conttributions to Theory of Games*, volume 2.
   Princeton University Press, 1953.

.. [ASAR2000] E.Asarin, O.Bournez, T.Dang, and O.Maler. Approximate reachability analysis of piecewise
   linear dynamical systems. In N.Lynch and B.H.Krogh, editors, *Hybrid Systems: Computation
   and Control*, volume 1790 of *Lecture Notes in Computer Science*, pages 482–497. Springer, 2000.

.. [GIR2005] A. Girard. Reachability of uncertain linear systems using zonotopes. In M. Morari, L. Thiele,
   and F. Rossi, editors, *Hybrid Systems: Computation and Control*, volume 3414 of *Lecture Notes
   in Computer Science*, pages 291–305. Springer, 2005.

.. [GIR2006] A.Girard, C.Le Guernic, and O.Maler. Computation of reachable sets of linear time-invariant
   systems with inputs. In J.Hespanha and A.Tiwari, editors, *Hybrid Systems: Computation and
   Control*, volume 3927 of *Lecture Notes in Computer Science*, pages 257–271. Springer, 2006.
   
.. [AVIS1997] D. Avis, D. Bremner, and R. Seidel. How good are convex hull algorithms? *Computational
   Geometry: Theory and Applications*, 7:265–301, 1997.
   
.. [STUR2003] O. Stursberg and B. H. Krogh. Efficient representation and computation of reachable sets for
   hybrid systems. In O. Maler and A. Pnueli, editors, *Hybrid Systems: Computation and Control*,
   volume 2623 of *Lecture Notes in Computer Science*, pages 482–497. Springer, 2003.
   
.. [MIT2000] I. Mitchell and C. Tomlin. Level set methods for computation in hybrid systems. In N. Lynch
   and B. H. Krogh, editors, *Hybrid Systems: Computation and Control*, volume 1790 of *Lecture
   Notes in Computer Science*, pages 21–31. Springer, 2000.
   
.. [LAFF2001] G. Lafferriere, G. J. Pappas, and S. Yovine. Symbolic reachability computation for families of
   linear vector fields. *Journal of Symbolic Computation*, 32:231–253, 2001.
 
.. [KOST2001] E. K. Kostousova. Control synthesis via parallelotopes: optimization and parallel computations.
   *Optimization Methods and Software*, 14(4):267–310, 2001.
   
.. [KUR2000] A. B. Kurzhanski and P. Varaiya. On ellipsoidal techniques for reachability analysis. *Optimization
   Methods and Software*, 17:177–237, 2000.
   
.. [VAR1998] P. Varaiya. Reach set computation using optimal control. Proc. of KITWorkshop on Verification
   on Hybrid Systems. Verimag, Grenoble., 1998.

.. [KUR1997] A. B. Kurzhanski and I. Vályi. *Ellipsoidal Calculus for Estimation and Control*. ser. SCFA.
   Birkhäuser, 1997.
   
.. [VAR2007] P. Varaiya A. A. Kurzhanskiy. Ellipsoidal techniques for reachability analysis of discrete-time
   linear systems. *IEEE Transactions on Automatic Control*, 52(1):26–38, 2007.

.. [KUR2001] A.B.Kurzhanski and P.Varaiya. Reachability analysis for uncertain systems - the ellipsoidal
   technique. *Dynamics of Continuous, Discrete and Impulsive Systems Series B: Applications
   and Algorithms*, 9:347–367, 2001.  
   
.. [DAR2012] A. N. Dariyn and A. B. Kurzhanski. Method of invariant sets for linear systems of high dimensionality
   under uncertain disturbances. *Doklady Akademii Nauk*, 446(6):607–611, 2012.
   
.. [GANT1960] F. R. Gantmacher. *Matrix Theory, I-II. Chelsea*, 1960.

.. [ROS2002] F. Thomas L. Ros, A. Sabater. An Ellipsoidal Calculus Based on Propagation and Fusion.
   *IEEE Transactions on Systems, Man and Cybernetics, Part B: Cybernetics*, 32(4), 2002.

.. [VAZ1999] A. Yu. Vazhentsev. On Internal Ellipsoidal Approximations for Problems of Control and Synthesis
   with Bounded Coordinates. *Izvestiya Rossiiskoi Akademii Nauk. Teoriya i Systemi Upravleniya*.,
   1999.
   
.. [BOYD2004] S. Boyd and L. Vandenberghe. *Convex Optimization*. Cambridge University Press, 2004.

.. [STUR1999] Sturm, J. F. 1999. “Using SeDuMi 1.02, A MATLAB Toolbox for Optimization
   over Symmetric Cones.” *Optimization Methods and Software* 11-12: 625–653.
   
.. [LIN2002] Lin, A., and S. Han. 2002. On the Distance Between Two Ellipsoids.
   *SIAM Journal on Optimization* 13 (1): 298–308.
   
.. [SUN2003] L.Muñoz, X.Sun, R.Horowitz, and L.Alvarez. 2003. Traffic Density
   Estimation with the Cell Transmission Model. In *Proceedings of the
   American Control Conference*, 3750–3755. Denver, Colorado, USA.
   
.. [VER2001] Veres, S. M., A. V. Kuntsevich, I. V. Vályi, S. Hermsmeyer, and D. S.
   Wall. 2001. Geometric Bounding Toolbox for MATLAB. *MATLAB/Simulink
   Connections Catalogue*.
   
   

