.. role:: math(raw)
   :format: html latex
..

Ellipsoidal Calculus
====================

Basic Notions
-------------

We start with basic definitions. Ellipsoid :math:`{\mathcal E}(q,Q)` in
:math:`{\bf R}^n` with center :math:`q` and shape matrix :math:`Q` is
the set

.. math::

   {\mathcal E}(q,Q) = \{ x \in {\bf R}^n ~|~ \langle (x-q), Q^{-1}(x-q)\rangle\leqslant1 \},
   \label{ellipsoid}

wherein :math:`Q` is positive definite (:math:`Q=Q^T` and
:math:`\langle x, Qx\rangle>0` for all nonzero :math:`x\in{\bf R}^n`).
[ellipsoiddef0] Here :math:`\langle\cdot,\cdot\rangle` denotes inner
product. The support function of a set
:math:`{\mathcal X}\subseteq{\bf R}^n` is

.. math:: \rho(l~|~{\mathcal X}) = \sup_{x\in{\mathcal X}} \langle l,x\rangle.

In particular, the support function of the ellipsoid ([ellipsoid]) is

.. math::

   \rho(l~|~{\mathcal E}(q,Q)) = \langle l, q\rangle + \langle l, Ql\rangle^{1/2}.
   \label{ellsupp}

Although in ([ellipsoid]) :math:`Q` is assumed to be positive definite,
in practice we may deal with situations when :math:`Q` is singular, that
is, with degenerate ellipsoids flat in those directions for which the
corresponding eigenvalues are zero. Therefore, it is useful to give an
alternative definition of an ellipsoid using the expression ([ellsupp]).
Ellipsoid :math:`{\mathcal E}(q,Q)` in :math:`{\bf R}^n` with center
:math:`q` and shape matrix :math:`Q` is the set

.. math::

   {\mathcal E}(q,Q) = \{ x \in {\bf R}^n ~|~
   \langle l,x\rangle\leqslant\langle l,q\rangle + \langle l,Ql\rangle^{1/2}
   \mbox{ for all } l\in{\bf R}^n \},
   \label{ellipsoid2}

wherein matrix :math:`Q` is positive semidefinite (:math:`Q=Q^T` and
:math:`\langle x, Qx\rangle\geqslant0` for all :math:`x\in{\bf R}^n`).
[ellipsoiddef] The volume of ellipsoid :math:`{\mathcal E}(q,Q)` is

.. math::

   {\bf Vol}(E(q,Q)) = {\bf Vol}_{\langle x,x\rangle\leqslant1}\sqrt{\det Q},
   \label{ellvolume}

where :math:`{\bf Vol}_{\langle x,x\rangle\leqslant1}` is the volume of
the unit ball in :math:`{\bf R}^n`:

.. math::

   {\bf Vol}_{\langle x,x\rangle\leqslant1} = \left\{\begin{array}{ll}
   \frac{\pi^{n/2}}{(n/2)!}, &
   \mbox{ for even } n,\\
   \frac{2^n\pi^{(n-1)/2}\left((n-1)/2\right)!}{n!}, &
   \mbox{ for odd } n. \end{array}\right.
   \label{ellunitball}

The distance from :math:`{\mathcal E}(q,Q)` to the fixed point :math:`a`
is

.. math::

   {\bf dist}({\mathcal E}(q,Q),a) = \max_{\langle l,l\rangle=1}\left(\langle l,a\rangle -
   \rho(l ~|~ {\mathcal E}(q,Q)) \right) =
   \max_{\langle l,l\rangle=1}\left(\langle l,a\rangle - \langle l,q\rangle -
   \langle l,Ql\rangle^{1/2}\right). \label{dist_point}

If :math:`{\bf dist}({\mathcal E}(q,Q),a) > 0`, :math:`a` lies outside
:math:`{\mathcal E}(q,Q)`; if
:math:`{\bf dist}({\mathcal E}(q,Q),a) = 0`, :math:`a` is a boundary
point of :math:`{\mathcal E}(q,Q)`; if
:math:`{\bf dist}({\mathcal E}(q,Q),a) < 0`, :math:`a` is an internal
point of :math:`{\mathcal E}(q,Q)`.

Given two ellipsoids, :math:`{\mathcal E}(q_1,Q_1)` and
:math:`{\mathcal E}(q_2,Q_2)`, the distance between them is

.. math::

   \begin{aligned}
   {\bf dist}({\mathcal E}(q_1,Q_1),{\mathcal E}(q_2,Q_2)) & = & \max_{\langle l,l\rangle=1}
   \left(-\rho(-l ~|~ {\mathcal E}(q_1,Q_1)) - \rho(l ~|~ {\mathcal E}(q_2,Q_2))\right) \\
   & = & \max_{\langle l,l\rangle=1}\left(\langle l,q_1\rangle -
   \langle l,Q_1l\rangle^{1/2} - \langle l,q_2\rangle -
   \langle l,Q_2l\rangle^{1/2}\right). \label{dist_ell}\end{aligned}

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
   {\mathcal E}^\circ(q,Q) & = & \{l\in{\bf R}^n ~|~ \langle l,q\rangle +
   \langle l,Ql\rangle^{1/2}\leqslant1 \}\\
   & = & \{l\in{\bf R}^n ~|~ \langle l,(Q-qq^T)^{-1}l\rangle +
   2\langle l,q\rangle\leqslant1 \}\\
   & = & \{l\in{\bf R}^n ~|~ \langle(l+(Q-qq^T)^{-1}q),
   (Q-qq^T)(l+(Q-qq^T)^{-1}q)\rangle\leqslant1+\langle q,(Q-qq^T)^{-1}q\rangle \}.\end{aligned}

The special case is

.. math:: {\mathcal E}^\circ(0,Q) = {\mathcal E}(0,Q^{-1}).

Given :math:`k` compact sets
:math:`{\mathcal X}_1, \cdots, {\mathcal X}_k\subseteq{\bf R}^n`, their
geometric (Minkowski) sum is

.. math::

   {\mathcal X}_1\oplus\cdots\oplus{\mathcal X}_k=\bigcup_{x_1\in{\mathcal X}_1}\cdots\bigcup_{x_k\in{\mathcal X}_k}
   \{x_1 + \cdots + x_k\} .  \label{minksum}

Given two compact sets
:math:`{\mathcal X}_1, {\mathcal X}_2 \subseteq{\bf R}^n`, their
geometric (Minkowski) difference is

.. math::

   {\mathcal X}_1\dot{-}{\mathcal X}_2 = \{x\in{\bf R}^n ~|~ x + {\mathcal X}_2 \subseteq {\mathcal X}_1 \}.
   \label{minkdiff}

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

   H = \{x\in{\bf R}^n ~|~ \langle c, x\rangle = \gamma\}
   \label{hyperplane}

with :math:`c\in{\bf R}^n` and :math:`\gamma\in{\bf R}` fixed.
[hyperplanedef] The distance from ellipsoid :math:`{\mathcal E}(q,Q)` to
hyperplane :math:`H(c,\gamma)` is

.. math::

   {\bf dist}({\mathcal E}(q,Q),H(c,\gamma)) =
   \frac{\left|\gamma-\langle c,q\rangle\right| -
   \langle c,Qc\rangle^{1/2}}{\langle c,c\rangle^{1/2}}. \label{dist_hp}

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

   {\bf S}_1 = \{x\in{\bf R}^n ~|~ \langle c, x\rangle \leqslant\gamma\}
   \label{halfspace1}

and

.. math::

   {\bf S}_2 = \{x\in{\bf R}^n ~|~ \langle c, x\rangle \geqslant\gamma\}.
   \label{halfspace2}

To avoid confusion, however, we shall further assume that a hyperplane
:math:`H(c,\gamma)` specifies the halfspace in the sense ([halfspace1]).
In order to refer to the other halfspace, the same hyperplane should be
defined as :math:`H(-c,-\gamma)`.

The idea behind the calculation of intersection of an ellipsoid with a
halfspace is to treat the halfspace as an unbounded ellipsoid, that is,
as the ellipsoid with the shape matrix all but one of whose eigenvalues
are :math:`\infty`. [polytope] Polytope :math:`P(C,g)` is the
intersection of a finite number of closed halfspaces:

.. math:: P = \{x\in{\bf R}^n ~|~ Cx\leqslant g\},

wherein :math:`C=[c_1 ~ \cdots ~ c_m]^T\in{\bf R}^{m\times n}` and
:math:`g=[\gamma_1 ~ \cdots ~ \gamma_m]^T\in{\bf R}^m`. The distance
from ellipsoid :math:`{\mathcal E}(q,Q)` to the polytope :math:`P(C,g)`
is

.. math::

   {\bf dist}({\mathcal E}(q,Q),P(C,g))=\min_{y\in P(C,g)}{\bf dist}({\mathcal E}(q,Q),y),
   \label{dist_poly}

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

.. math:: A{\mathcal E}(q,Q) + b = {\mathcal E}(Aq+b, AQA^T) .\label{affinetrans}

Thus, ellipsoids are preserved under affine transformation. If the rows
of :math:`A` are linearly independent (which implies
:math:`m\leqslantn`), and :math:`b=0`, the affine transformation is
called *projection*.

Geometric Sum
~~~~~~~~~~~~~

Consider the geometric sum ([minksum]) in which
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

.. math:: q = q_1 + \cdots + q_k , \label{minksum_c}

the shape matrix of the external ellipsoid :math:`Q_l^+` is

.. math::

   Q_l^+ = \left(\langle l,Q_1l\rangle^{1/2} + \cdots
   + \langle l,Q_kl\rangle^{1/2}\right)
   \left(\frac{1}{\langle l,Q_1l\rangle^{1/2}}Q_1 + \cdots +
   \frac{1}{\langle l,Q_kl\rangle^{1/2}}Q_k\right), \label{minksum_ea}

and the shape matrix of the internal ellipsoid :math:`Q_l^-` is

.. math::

   Q_l^- = \left(Q_1^{1/2} + S_2Q_2^{1/2} + \cdots + S_kQ_k^{1/2}\right)^T
   \left(Q_1^{1/2} + S_2Q_2^{1/2} + \cdots + S_kQ_k^{1/2}\right),\label{minksum_ia}

with matrices :math:`S_i`, :math:`i=2,\cdots,k`, being orthogonal
(:math:`S_iS_i^T=I`) and such that vectors
:math:`Q_1^{1/2}l, S_2Q_2^{1/2}l, \cdots, S_kQ_k^{1/2}l` are parallel.

Varying vector :math:`l` we get exact external and internal
approximations,

.. math::

   \bigcup_{\langle l,l\rangle=1} {\mathcal E}(q,Q_l^-) =
   {\mathcal E}(q_1,Q_1)\oplus\cdots\oplus{\mathcal E}(q_k,Q_k) =
   \bigcap_{\langle l,l\rangle=1} {\mathcal E}(q,Q_l^+) .

For proofs of formulas given in this section, see Kurzhanski and Vályi
(1997), Kurzhanski and Varaiya (2000).

One last comment is about how to find orthogonal matrices
:math:`S_2,\cdots,S_k` that align vectors
:math:`Q_2^{1/2}l, \cdots, Q_k^{1/2}l` with :math:`Q_1^{1/2}l`. Let
:math:`v_1` and :math:`v_2` be some unit vectors in :math:`{\bf R}^n`.
We have to find matrix :math:`S` such that
:math:`Sv_2\uparrow\uparrow v_1`. We suggest explicit formulas for the
calculation of this matrix ( Dariyn and Kurzhanski (2012)):

.. math::

   &&T = I + Q_1(S - I)Q_1^T \label{valign1}, \\ 

   &&S = \begin{pmatrix}
        c & s\\
        -s & c
       \end{pmatrix},\quad c = \langle\hat{v_1},\ \hat{v_2}\rangle,\ \quad s = \sqrt{1 - c^2},\ \quad \hat{v_i} = \dfrac{v_i}{\|v_i\|} \label{valign2}\\ 
  
   &&Q_1 = [q_1 \, q_2]\in \mathbb{R}^{n\times2},\ \quad q_1 = \hat{v_1},\ \quad q_2 = \begin{cases}
   s^{-1}(\hat{v_2} - c\hat{v_1}),& s\ne 0\\
   0,& s = 0.
   \end{cases} \label{valign3}

Geometric Difference
~~~~~~~~~~~~~~~~~~~~

Consider the geometric difference ([minkdiff]) in which the sets
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
positive definite (see Gantmacher (1960)). To find such matrix
:math:`T`, we first do the SVD of :math:`Q_1`:

.. math:: Q_1 = U_1\Sigma_1V_1^T . \label{simdiag1}

Then the SVD of matrix
:math:`\Sigma_1^{-1/2}U_1^TQ_2U_1\Sigma_1^{-1/2}`:

.. math:: \Sigma_1^{-1/2}U_1^TQ_2U_1\Sigma_1^{-1/2} = U_2\Sigma_2V_2^T. \label{simdiag2}

Now, :math:`T` is defined as

.. math:: T = U_2^T \Sigma_1^{-1/2}U_1^T.  \label{simdiag3}

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

To find :math:`r`, compute matrix :math:`T` by ([simdiag1]-[simdiag3])
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

.. math:: q = q_1 - q_2;  \label{minkdiff_c}

the shape matrix of the internal ellipsoid :math:`Q^-_l` is

.. math::

   \begin{aligned}
   && P = \frac{\sqrt{\langle l, Q_1 l\rangle}}{\sqrt{\langle l, Q_2 \rangle}};\nonumber\\
   && Q^-_l = \left(1 - \dfrac{1}{P}\right)Q_1 + \left(1 - P\right)Q_2.
   \label{minkdiff_ia}\end{aligned}

and the shape matrix of the external ellipsoid :math:`Q^+_l` is

.. math::

   Q^+_l = \left(Q_1^{1/2} - SQ_2^{1/2}\right)^T
   \left(Q_1^{1/2} - SQ_2^{1/2}\right).  \label{minkdiff_ea}

Here :math:`S` is an orthogonal matrix such that vectors
:math:`Q_1^{1/2}l` and :math:`SQ_2^{1/2}l` are parallel. :math:`S` is
found from ([valign1]-[valign3]), with :math:`v_1=Q_2^{1/2}l` and
:math:`v_2=Q_1^{1/2}l`.

Running :math:`l` over all unit directions that are not bad, we get

.. math::

   \bigcup_{\langle l,l\rangle=1} {\mathcal E}(q,Q_l^-) =
   {\mathcal E}(q_1,Q_1)\dot{-}{\mathcal E}(q_2,Q_2) =
   \bigcap_{\langle l,l\rangle=1} {\mathcal E}(q,Q_l^+) .

For proofs of formulas given in this section, see Kurzhanski and Vályi
(1997).

Geometric Difference-Sum
~~~~~~~~~~~~~~~~~~~~~~~~

Given ellipsoids :math:`{\mathcal E}(q_1,Q_1)`,
:math:`{\mathcal E}(q_2,Q_2)` and :math:`{\mathcal E}(q_3,Q_3)`, it is
possible to compute families of external and internal approximating
ellipsoids for

.. math:: {\mathcal E}(q_1,Q_1) \dot{-} {\mathcal E}(q_2,Q_2) \oplus {\mathcal E}(q_3,Q_3) \label{minkmp}

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

.. math:: {\mathcal E}(q_1,Q_1) \oplus {\mathcal E}(q_2,Q_2) \dot{-} {\mathcal E}(q_3,Q_3) \label{minkpm}

parametrized by direction :math:`l`, if this set is nonempty
(:math:`{\mathcal E}(0,Q_3)\subseteq{\mathcal E}(0,Q_1)\oplus{\mathcal E}(0,Q_2)`).

First, using the result of section 2.2.2, we obtain tight external
:math:`{\mathcal E}(q_1+q_2,Q_l^{0+})` and internal
:math:`{\mathcal E}(q_1+q_2,Q_l^{0-})` ellipsoidal approximations of the
set :math:`{\mathcal E}(q_1,Q_1)\oplus{\mathcal E}(q_2,Q_2)`. In order
for the set ([minkpm]) to be nonempty, inclusion
:math:`{\mathcal E}(0,Q_3)\subseteq{\mathcal E}(0,Q_l^{0+})` must be
true for any :math:`l`. Note, however, that even if ([minkpm]) is
nonempty, it may be that
:math:`{\mathcal E}(0,Q_3)\not\subseteq{\mathcal E}(0,Q_l^{0-})`, then
internal approximation for this direction does not exist.

Assuming that ([minkpm]) is nonempty and
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

where :math:`S` is an orthogonal matrix found by ([valign1]-[valign3])
with :math:`v_1=c` and :math:`v_2=[1~0~\cdots~0]^T`. The ellipsoid in
the new coordinates becomes :math:`{\mathcal E}(q',Q')` with

.. math::

   \begin{aligned}
   q' & = & q-\frac{\gamma}{\langle c,c\rangle^{1/2}}Sc, \\
   Q' & = & SQS^T.\end{aligned}

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
   w' & = & q' + q_1'\left[\begin{array}{c}
   -1\\
   \bar{M}^{-1}\bar{m}\end{array}\right],\\
   W' & = & \left(1-q_1'^2(m_{11}-
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
   w & = & S^Tw' + \frac{\gamma}{\langle c,c\rangle^{1/2}}c, \\
   W & = & S^TW'S.\end{aligned}

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

   Q^+  = \alpha X^{-1}, \label{fusion1} \\

   X  =  \pi W_1 + (1-\pi)W_2, \label{fusion2} \\

   \alpha  =  1-\pi(1-\pi)\langle(q_2-q_1), W_2X^{-1}W_1(q_2-q_1)\rangle \label{fusion3}, \\

   q^+  = X^{-1}(\pi W_1q_1 + (1-\pi)W_2q_2) \label{fusion4}, \\

   0 =  \alpha({\bf det}(X))^2{\bf trace}(X^{-1}(W_1-W_2)) - \\
   & &  - n({\bf det}(X))^2 \big{(}2\langle q^+,W_1q_1-W_2q_2\rangle + \langle q^+,(W_2-W_1)q^+\rangle - \\
   & &  - \langle q_1,W_1q_1\rangle + \langle q_2,W_2q_2\rangle\big{)}, \label{fusion5}

with :math:`0\leqslant\pi\leqslant1`. We substitute :math:`X`,
:math:`\alpha`, :math:`q^+` defined in ([fusion2]-[fusion4]) into
([fusion5]) and get a polynomial of degree :math:`2n-1` with respect to
:math:`\pi`, which has only one root in the interval :math:`[0,1]`,
:math:`\pi_0`. Then, substituting :math:`\pi=\pi_0` into
([fusion1]-[fusion4]), we obtain :math:`q^+` and :math:`Q^+`. Special
cases are :math:`\pi_0=1`, whence
:math:`{\mathcal E}(q^+,Q^+)={\mathcal E}(q_1,Q_1)`, and
:math:`\pi_0=0`, whence
:math:`{\mathcal E}(q^+,Q^+)={\mathcal E}(q_2,Q_2)`. These situations
may occur if, for example, one ellipsoid is contained in the other:

.. math::

   {\mathcal E}(q_1,Q_1)\subseteq{\mathcal E}(q_2,Q_2) & \Rightarrow & \pi_0 = 1,\\

   {\mathcal E}(q_2,Q_2)\subseteq{\mathcal E}(q_1,Q_1) & \Rightarrow & \pi_0 = 0.\\

The proof that the system of equations ([fusion1]-[fusion5]) correctly
defines the minimal volume external ellipsoidal approximationi of the
intersection :math:`{\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2)` is
given in L. Ros (2002).

To find the internal approximating ellipsoid
:math:`{\mathcal E}(q^-,Q^-)\subseteq{\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2)`,
define

.. math::

   \beta_1 & = & \min_{\langle x,W_2x\rangle=1}\langle x,W_1x\rangle, \label{beta1}\\

   \beta_2 & = & \min_{\langle x,W_1x\rangle=1}\langle x,W_2x\rangle, \label{beta2}

Notice that ([beta1]) and ([beta2]) are QCQP problems. Parameters
:math:`\beta_1` and :math:`\beta_2` are invariant with respect to affine
coordinate transformation and describe the position of ellipsoids
:math:`{\mathcal E}(q_1,Q_1)`, :math:`{\mathcal E}(q_2,Q_2)` with
respect to each other:

.. math::

   \beta_1\geqslant1,~\beta_2\geqslant1 & \Rightarrow &
   {\bf int}({\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2))=\emptyset, \\

   \beta_1\geqslant1,~\beta_2\leqslant1 & \Rightarrow & {\mathcal E}(q_1,Q_1)\subseteq{\mathcal E}(q_2,Q_2), \\

   \beta_1\leqslant1,~\beta_2\geqslant1 & \Rightarrow & {\mathcal E}(q_2,Q_2)\subseteq{\mathcal E}(q_1,Q_1), \\

   \beta_1<1,~\beta_2<1 & \Rightarrow &
   {\bf int}({\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2))\neq\emptyset \\

   & & \mbox{and} ~ {\mathcal E}(q_1,Q_1)\not\subseteq{\mathcal E}(q_2,Q_2) \\

   & & \mbox{and} ~ {\mathcal E}(q_2,Q_2)\not\subseteq{\mathcal E}(q_1,Q_1).

Define parametrized family of internal ellipsoids
:math:`{\mathcal E}(q^-_{\theta_1\theta_2},Q^-_{\theta_1\theta_2})` with

.. math::

   q^-_{\theta_1\theta_2}  =  (\theta_1W_1 +
   \theta_2W_2)^{-1}(\theta_1W_1q_1 + \theta_2W_2q_2), \label{paramell1} \\

   Q^-_{\theta_1\theta_2} =  (1 - \theta_1\langle q_1,W_1q_1\rangle -
   \theta_2\langle q_2,W_2q_2\rangle +
   \langle q^-_{\theta_1\theta_2},(Q^-)^{-1}q^-_{\theta_1\theta_2}\rangle)
   (\theta_1W_1 + \theta_2W_2)^{-1} .\label{paramell2}

The best internal ellipsoid
:math:`{\mathcal E}(q^-_{\hat{\theta}_1\hat{\theta}_2},Q^-_{\hat{\theta}_1\hat{\theta}_2})`
in the class ([paramell1]-[paramell2]), namely, such that

.. math::

   {\mathcal E}(q^-_{{\theta}_1{\theta}_2},Q^-_{{\theta}_1{\theta}_2})\subseteq
   {\mathcal E}(q^-_{\hat{\theta}_1\hat{\theta}_2},Q^-_{\hat{\theta}_1\hat{\theta}_2})
   \subseteq {\mathcal E}(q_1,Q_1)\cap{\mathcal E}(q_2,Q_2)

for all :math:`0\leqslant\theta_1,\theta_2\leqslant1`, is specified by
the parameters

.. math::

   \hat{\theta}_1 = \frac{1-\hat{\beta}_2}{1-\hat{\beta}_1\hat{\beta}_2}, ~~~~
   \hat{\theta}_2 = \frac{1-\hat{\beta}_1}{1-\hat{\beta}_1\hat{\beta}_2},
   \label{thetapar}

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
intersection of two ellipsoids is described in Vazhentsev (1999).

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

   q_2  =  (\gamma + 2\sqrt{\overline{\lambda}})c,\label{hsell1} \\

   W_2  =  \frac{1}{4\overline{\lambda}}cc^T,\label{hsell2}

:math:`\overline{\lambda}` being the biggest eigenvalue of matrix
:math:`Q_1`. After defining :math:`W_1=Q_1^{-1}`, we obtain
:math:`{\mathcal E}(q^+,Q^+)` from equations ([fusion1]-[fusion5]), and
:math:`{\mathcal E}(q^-,Q^-)` from ([paramell1]-[paramell2]),
([thetapar]).

**Remark.** Notice that matrix :math:`W_2` has rank :math:`1`, which
makes it singular for :math:`n>1`. Nevertheless, expressions
([fusion1]-[fusion2]), ([paramell1]-[paramell2]) make sense because
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

Checking if 
~~~~~~~~~~~~

Theorem of alternatives, also known as *:math:`S`-procedure* Boyd and
Vandenberghe (2004), states that the implication

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
   \lambda & > & 0, \\
   \left[\begin{array}{cc}
   Q_2^{-1} & -Q_2^{-1}q_2\\
   (-Q_2^{-1}q_2)^T & q_2^TQ_2^{-1}q_2-1\end{array}\right]
   & \preceq &
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
   A & \succ & 0, \\
   \langle (Ax_i + b), (Ax_i + b)\rangle & \leqslant& 1, ~~~ i=1..m.\end{aligned}

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
   \lambda_i & > & 0,\\
   \left[\begin{array}{ccc}
   A^2-\lambda_iQ_i^{-1} & \tilde{b}+\lambda_iQ_i^{-1}q_i & 0 \\
   (\tilde{b}+\lambda_iQ_i^{-1}q_i)^T & -1-\lambda_i(q_i^TQ_i^{-1}q_i-1) & \tilde{b}^T \\
   0 & \tilde{b} & -A^2\end{array}\right] & \preceq & 0, ~~~ i=1..m.\end{aligned}

After :math:`A` and :math:`b` are found,

.. math:: q=-A^{-1}b ~~~ \mbox{ and } ~~~ Q=(A^TA)^{-1}.

The results on the minimum volume ellipsoids are explained and proven in
Boyd and Vandenberghe (2004).

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
([polytope]), the SDP has the form

.. math:: \min \log \det B^{-1}

subject to:

.. math::

   \begin{aligned}
   B & \succ & 0,\\
   \langle c_i, Bc_i\rangle + \langle c_i, q\rangle & \leqslant& \gamma_i,
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
   \lambda_i & > & 0, \\
   \left[\begin{array}{ccc}
   1-\lambda_i & 0 & (q - q_i)^T\\
   0 & \lambda_iI & B\\
   q - q_i & B & Q_i\end{array}\right] & \succeq & 0, ~~~ i=1..m.\end{aligned}

After :math:`B` and :math:`q` are found,

.. math:: Q = B^TB.

The results on the maximum volume ellipsoids are explained and proven in
Boyd and Vandenberghe (2004).

