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

.. figure:: /pic/chapter06_section01_ellpoly.png
   :alt: ellpoly
   :width: 50 %

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

.. literalinclude:: ../products/+elltool/+doc/+snip//s_chapter06_section01_snippet01.m
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

.. figure:: /pic/chapter06_section02_springmass.png
   :alt: spmass
   :width: 30 %

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

.. figure:: /pic/chapter06_section02_reachmech.png
   :alt: reachmech
   :width: 70 %

   Spring-mass system without disturbance:
   (a) reach tube for time :math:`t\in[0,4]`; (b) reach set at time :math:`t=4`.
   Spring-mass system with disturbance:
   (c) reach tube for time :math:`t\in[0,4]`; (d) reach set at time :math:`t=4`.

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter06_section02_snippet01.m
   :language: matlab
   :linenos:

  
:num:`Figure #mechreachfig` (a) shows the reach set of the system
:eq:`spmass1`-:eq:`spmass2` evolving in time from :math:`t=0` to :math:`t=4`.
:num:`Figure #mechreachfig` (b) presents a snapshot of this reach set at time
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

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter06_section02_snippet02.m
   :language: matlab
   :linenos:


:num:`Figure #mechreachfig` (c) shows the reach set of the system
:eq:`smdist1`-:eq:`smdist2` evolving in time from :math:`t=0` to :math:`t=4`.
:num:`Figure #mechreachfig` (d) presents a snapshot of this reach set at time
:math:`t=4`.

Switched System
---------------

.. _rlcfig:

.. figure:: /pic/chapter06_section03_rlc.png
   :alt: rlc
   :width: 30 %

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

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter06_section03_snippet01.m
   :language: matlab
   :linenos:
   
.. _rlcreachfig:

.. figure:: /pic/chapter06_section03_rlcreach.png
   :alt: rlcreach
   :width: 80 %

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

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter06_section03_snippet02.m
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

.. figure:: /pic/chapter06_section04_hw.png
   :alt: highway
   :width: 30 %

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

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter06_section04_snippet01.m
   :language: matlab
   :linenos:

We assume that initially the system is in free-flow mode. Given a set of
initial conditions, we compute the reach set according to dynamics
:eq:`fflow` for certain number of time steps. We will consider the
external approximation of the reach set by a single ellipsoid.

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter06_section04_snippet02.m
   :language: matlab
   :linenos:

Having obtained the ellipsoidal array externalEllMat representing the
reach set evolving in time, we determine the ellipsoids in the array
that intersect the guard.

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter06_section04_snippet03.m
   :language: matlab
   :linenos:
   
.. _hwreachfig:

.. figure:: /pic/chapter06_section04_hwreach.png
   :alt: highway
   :width: 80 %

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

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter06_section04_snippet04.m
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

Pendulum with a flywheel
-------------------------

.. _pendulungfig:

.. figure::  _static/chapter06_section06_pendulung.png
   :alt: pendulung
   :width: 30 %

   Pendulum with a flywheel

Consider a system consisting of a rod weight :math:`{m}_1` attached to the fixed base at the point :math:`O`
and to the flywheel at the point :math:`A`. The flywheel is a disk of weight :math:`{m}_2`.
Define

-  :math:`l` - length of the rod :math:`OA`,
-  :math:`r` - radius of the disc,
-  :math:`a` - distance from point O to point C (the center of mass of the rod),
-  :math:`\theta` - angle of deviation of the rod from horizontal,
-  :math:`\phi` - angle of rotation of the flywheel relative to the rod,
-  :math:`J_1` -  moment of inertia of rod, rotating about point C,
-  :math:`J_2` - moment of inertia of disk, rotating about point A,
-  :math:`k_1, k_2` - coefficients of friction.

.. _forcesfig:

.. figure::  _static/chapter06_section06_forces.png
   :alt: forces
   :width: 60 %

   Active, reaction and inertial forces

The mechanical system presented in :num:`figure #forcesfig` is described by the following system of equations:

.. math:: 
   
    \left\{
   \begin{aligned}
   & m_1 \ddot{x}_{C} = F^{01}_{x} - F^{12}_{x},\\
   & m_1 \ddot{y}_{C} = F^{01}_{y} - F^{12}_{x} - m_1g,\\
   & J_1 \ddot{\theta} = F^{01}_{x}a \sin \theta - F^{01}_{y}a \cos \theta + F^{12}_{x}a \sin \theta - F^{12}_{y}a \cos \theta - M,\\
   & m_2 \ddot{x}_{A} = F^{12}_{x},\\
   & m_2 \ddot{y}_{A} = F^{12}_{y} - m_2 g,\\
   & J_2 (\ddot{\theta} + \ddot{\phi}) = M.\\
   \end{aligned}
   \right.

In order to obtain a closed system we add four relating equations:

.. math:: 
   
    \left\{
   \begin{aligned}
   & x_{C} = a \cos \theta,\\
   & y_{C} = a \sin \theta,\\
   \end{aligned}
    \right.
   \;\;\;
    \left\{
    \begin{aligned} 
   & x_{A} = l \cos \theta,\\
   & y_{A} = l \sin \theta.\\
   \end{aligned}
   \right.

Remembering that :math:`l = 2a`, we get:

.. math:: 
   :label: frictionless
   
    \left\{
   \begin{aligned}
   & (J_1 + J_2 + m_1 a^2 + m_2 l^2)\ddot{\theta} + J_2 \ddot{\phi} = -(m_1a + m_2 l) g \cos\theta,\\
   & J_2 (\ddot{\theta} + \ddot{\phi}) = M.\\
   \end{aligned}
   \right.

Equations :eq:`frictionless` don't include friction. Add the moment of force of friction that is proportional to the
angular velocity:

.. math:: 
   :label: whithfriction
   
    \left\{
   \begin{aligned}
   & (J_1 + J_2 + m_1 a^2 + m_2 l^2)\ddot{\theta} + J_2 \ddot{\phi} =k_2 \dot{\phi} - k_1 \dot{\theta} -(m_1a + m_2 l) g \cos\theta,\\
   & J_2 (\ddot{\theta} + \ddot{\phi}) = M - k_2 \dot{\phi}.\\
   \end{aligned}
   \right.

Let's linearize system :eq:`whithfriction`, supposing that the system is in a small neighborhood of unstable 
equilibrium :math:`\theta \sim \frac{\pi}{2}`. Linearization gives:

.. math:: 
   :label: lineariztheta
   
    \left\{
   \begin{aligned}
   & (J_1 + J_2 + m_1 a^2 + m_2 l^2)\ddot{\theta} + J_2 \ddot{\phi} =k_2 \dot{\phi} - k_1 \dot{\theta} - (m_1a + m_2 l) g \left(\frac{\pi}{2} - \theta \right),\\
   & J_2 (\ddot{\theta} + \ddot{\phi}) = M - k_2 \dot{\phi}.\\
   \end{aligned}
   \right.

Defining :math:`\dot{\theta} = \omega_1` and :math:`\dot{\phi} = \omega_2`, we can rewrite :eq:`lineariztheta` in standard form: 

.. math:: 
   :label: standform
   
    \left\{
   \begin{aligned}
   & \dot{\theta} = \omega_1, \\
   & \dot{\phi} = \omega_2, \\
   & \dot{\omega}_1 = \frac{2 k_2 \omega_2 - k_1 \omega_1 - M - (m_1a + m_2 l) g \left(\frac{\pi}{2} - \theta \right)}{J_1 + m_1 a^2 + m_2 l^2},\\
   & \dot{\omega}_2 = \frac{M - k_2 \omega_2}{J_2} - \frac{2 k_2 \omega_2 - k_1 \omega_1 - M- (m_1a + m_2 l) g \left(\frac{\pi}{2} - \theta \right)}{J_1 + m_1 a^2 + m_2 l^2}.\\
   \end{aligned}
   \right.

.. raw:: html

	<h2>References</h2>

.. [SUN2003] L.Muñoz, X.Sun, R.Horowitz, and L.Alvarez. 2003. Traffic Density
   Estimation with the Cell Transmission Model. In *Proceedings of the
   American Control Conference*, 3750–3755. Denver, Colorado, USA.


LMI-based three-vehicle platoon
-------------------------------

A platoon of vehicles includes typically a leader and a number
of followers. In a controlled platoon the controllers are
designed to maintain constant relative distances between
autonomous vehicles by tracking the trajectory of the
leader. The latter is manually driven and can be considered
as a reference input to the whole system. We are concerned
with the longitudinal control of a platoon of vehicles engaged
in following each other longitudinally by exchanging
information via a wireless local area network (WLAN) (see
Fig.1).

.. _platoonfig1:

.. figure:: /pic/chapter06_section08_platoon.png
   :alt: platoon
   :width: 50 %

   Platoon struture and notations.

The spacing errors :math:`e_i` are defined as the difference
between the actual distance to the predecessor and a
(fixed) reference distance:
:math:`e_i(t) = d_i(t) - dref_i.`
Bounds for these reference distances will be stipulated by the result of
our safety verification. The effective acceleration ai of each
vehicle within the platoon is governed by the drivetrain
dynamics.According to Fig. 1 and with
the further approximation the resulting platoon model is
given by:

.. math::
   :label: platoon1

   \ddot{e}_i & = a_{i-1} - a_i.

.. math::
   :label: platoon2

   a_i & = -\frac{a_i}{\tau_i} + \frac{v_i}{\tau_i}

where :math:`\tau_i` is the time constant of the drivetrain considered
here to be constant and vi the input signal. The
dynamics of the whole platoon with a state vector
:math:`x =[. . . e_i, \dot{e}_i, a_i . . .]^T`
can be expressed in state space form as
follows:

.. math::
   :label: platoon3

   \dot{x} & = A_sx+B_1a_L+B_2v.

where the leading vehicle’s acceleration aL enters the dynamics
as a disturbance. The goal thereby is to stabilize
the platoon and realize a good disturbance rejection in
terms of small spacing errors at reasonable control effort.
These constraints comprise in particular maximum (absolute)
spacing errors to prevent collisions among platoon
members but also maximum amplification of velocity or
acceleration values to account for the existing saturation
effects that arise due to force limitation between road
and tire. This optimal control problem is applied to a
state feedback structure assuming that each vehicle has
information access to all other vehicles states. We obtain
as result an optimal matrix K verifying:


.. math::
   :label: platoon4

   v & = K x

The closed loop system is hence given by:

.. math::
   :label: platoon5

   \dot{x} & = Ax + Bu.

where :math:`A = (A_s + B_2K), B = B_1` and  :math:`u = a_L`.

The main goal of this work, is to investigate the impact
of disturbances of the communication network on the performance
of the cooperative platoon. We are particularly
interested in worst cases, in which a loss of communication
between two/many or all vehicles occurs. The theory of
hybrid systems offers a convenient framework to model this
kind of systems. A hybrid automaton consists of states described
by continuous dynamics and discrete events which
trigger transitions between these states. Our application
can be modeled by a hybrid automaton. The controlled
platoon dynamics constitute thereby the continuous states
and the communication breakdowns trigger the discrete
switches from one continuous state to another. The interconnection
topology within the platoon is modeled with
a directed graph :math:`G = (V,E)`, defined by vertices V and
edges :math:`E`. The ith vertex represents the ith vehicle and
the edge (i, j) indicates that vehicle j receives information
from vehicle i. This graph is represented by the adjacent
matrix :math:`R = [r_{ij}]` referred to as the communication matrix
of the platoon.

To take into account the communication failures in the
controller design, the loss of information is expressed by
forcing zeros in :math:`K`. Depending on the topology and the configuration
of the communication between vehicles given by
the matrix :math:`R`, many communication scenarios are possible.
Consequently, the hybrid automaton modeling this kind
of system will be complex. We focus our study on safetycritical
worst case scenarios.We consider the worst case in
Fig.2, in which the system switches from a full to a total
dropout of the communication between the vehicles within
the platoon. In general, our controlled hybrid automaton
has continuous states.

.. _platoonfig2:

.. figure:: /pic/chapter06_section08_automat.png
   :alt: automat
   :width: 50 %

   Hybrid automata modeling the worst case scenario.

To each continuous state :math:`q` corresponds a new :math:`K_q` and consequently new
matrices :math:`A_q` and :math:`B_q` verifying the equation

.. math::
   :label: platoon6

   \dot{x}(t) = A_qx(t) + B_qu(t)

where :math:`x(t) \in R^9` denotes the state vector,  :math:`u(t) = a_L \in R` is

the input vector and  :math:`q \in {1, 2}` is the mode described
by  :math:`(A_q,B_q) \in R^{9 \times 9} \times  R^9.`

Next, we give the brief description of the algorithm of the program and the program code itself. 
First, we define the matrices and parameters of the linearized system (matrices, vectors, intervals). 
Next, we solve the resulting system by methods of the Ellipsoidal Toolbox. 
We build a tube of reachability, and simultaneously evolve the system where the situation requires. 
Then we project the reach tube to the previously defined hyperplanes. 
To test the system for a collision, we will follow the intersection of the tube and the hyperplane :math:`l_{1},\; l_{2},\; l_{3}`. 
That is, if there is a crossing, then a collision is inevitable.

.. literalinclude:: ../products/+elltool/+doc/+snip//s_chapter06_section08_snippet01.m
   :language: matlab
   :linenos:

to demonstrate a qualitatively different situation in the further consideration of the collision problem, 
let us set the other parameters of the system:

.. literalinclude:: ../products/+elltool/+doc/+snip//s_chapter06_section08_snippet03.m
   :language: matlab
   :linenos:

Construction of reachability tube:

.. literalinclude:: ../products/+elltool/+doc/+snip//s_chapter06_section08_snippet02.m
   :language: matlab
   :linenos:


.. _tubefig1:

.. figure:: /pic/chapter06_section08_tube1.png
   :alt: tube1
   :width: 50 %

   Reach set for the first block of parameters.


.. _tubefig2:

.. figure:: /pic/chapter06_section08_tube2.png
   :alt: tube2
   :width: 50 %

   Reach set for the second block of parameters.

Solving collision problem:

.. literalinclude:: ../products/+elltool/+doc/+snip//s_chapter06_section08_snippet06.m
   :language: matlab
   :linenos:


.. literalinclude:: ../products/+elltool/+doc/+snip//s_chapter06_section08_snippet04.m
   :language: matlab
   :linenos:

.. _colfig1:

.. figure:: /pic/chapter06_section08_col1.png
   :alt: col1
   :width: 50 %

   Result of solving collision problem. There are 3 intersections of planes of :math:`(e_1,e_2),\; (e_2,e_3),\; (e_3,e_1)` (red color) and our 
   reach set of system (blue color). According to geometrical interpretation of system this intersections means the conclisions. 


.. raw:: html
	<h2>References</h2>

.. [1] Ibtissem Ben Makhlouf, Hilal Diab, Stefan Kowalewski. Safety Verification of a Controlled
   Cooperative Platoon Under Loss of
   Communication Using Zonotopes. Proceedings of the 4th IFAC Conference on
   Analysis and Design of Hybrid Systems (ADHS 12)
   June 6-8, 2012

.. [2] Jan P. Maschuw, Günter C. Keßler, D. Abel. LMI-based control of vehicle platoons for
   robust longitudinal guidance. Proceedings of the 17th World Congress
   The International Federation of Automatic Control
   Seoul, Korea, July 6-11, 2008


Blending tank with delay
------------------------

There is a tank, that is being filled with two streams. Each stream contains a soluble 
substance with constant concentration :math:`c_1` and :math:`c_2`. Streams 
have flow rates :math:`F_1(t)` and :math:`F_2(t)`. But streams don't pour into
the tank immediately. Firstly, they blend in a tube, and then substance gets into the tank.
Substance in the tank is blended and after that it flows out with a flow rate :math:`F(t)`.

.. _tankfig:

.. figure:: /pic/chapter06_section09_tank.png
   :alt: tank
   :width: 50 %

   Blending tank with delay.

At the initial time flow rates of streams are :math:`F_{10}` and :math:`F_{20}`; 
output flow rate is :math:`F_0`; substance volume is :math:`V_0`; substance concentration in the tank is :math:`c_0`. Then we add some small deviations:

.. math::
   F_1(t) = F_{10} + \mu_1(t), \\
   F_2(t) = F_{20} + \mu_2(t), \\
   V(t) = V_0 + \xi_1(t), \\
   c(t) = c_0 + \xi_2(t),

where :math:`\mu_1(t)` and :math:`\mu_2(t)` are input variables, and :math:`\xi_1(t)` 
and :math:`\xi_2(t)` are state variables. So :math:`\xi_1(t)` means change in volume, 
:math:`\xi_2(t)` means change in concentration; :math:`\mu_1(t)` and :math:`\mu_2(t)` 
mean changes in flow rates of input streams (we can control them).
Under assuming that these four parameters are small, 
the linearization leads to the following equations (derivation of the equations can be found in [Kwakernaak]_):

.. math::
   :label: tank_continuous

   \dot{\xi_1} (t) = -\frac{1}{2\theta} \xi_1(t) + \mu_1(t) + \mu_2(t), \\
   \dot{\xi_2} (t) = -\frac{1}{\theta} \xi_2(t) + \frac{c_1 - c_0}{V_0} \mu_1(t - \tau) + \frac{c_2 - c_0}{V_0} \mu_2(t - \tau),

where :math:`\theta = \frac{V_0}{F_0}`. Write in vector form:

.. math::
   :label: tank_continuous_vec

   \dot{x} (t) = \begin{bmatrix} -\frac{1}{2\theta} & 0 \\ 0 & -\frac{1}{\theta} \end{bmatrix} x(t) + 
   \begin{bmatrix} 1 & 1 \\ 0 & 0 \end{bmatrix} u(t) + 
   \begin{bmatrix} 0 & 0 \\ \frac{c_1 - c_0}{V_0} & \frac{c_2 - c_0}{V_0} \end{bmatrix} u(t - \tau),

where :math:`x(t) = [\xi_1(t), \xi_2(t)]^T`, :math:`u(t) = [\mu_1(t), \mu_2(t)]^T`.

Now we will discretize this system. We assume that the adjustment of 
the valves occurs at time instants (by a certain interval :math:`\Delta`) and time delay is 
:math:`k\Delta`. Then the system takes form: 

.. math::
   :label: tank_discrete

   x^+(i+1) = A x^+(i) + B_1 u^+ (i) + B_2 u^+ (i - k), 

where matrices :math:`A`, :math:`B_1` and :math:`B_2` mean the same as in the previous formula. 

Finally we will exclude the delay by using the extended state vector: 

.. math::
   x_{ext}(i) = \begin{bmatrix} \xi_1^+(i) \\ \xi_2^+(i) \\ \mu_1^+(i-1) \\ 
   \mu_2^+(i-1) \\ \mu_1^+(i-2) \\ \mu_2^+(i-2) \\ \dots \\ \mu_1^+(i-k) \\\mu_2^+(i-k) \end{bmatrix} 
   \in \mathbb{R}^{2k+2}

Matrices take form:

.. math::
   A_{ext} = \begin{bmatrix} 
   A & \Theta & \Theta & \Theta & \dots & \Theta & B_2 \\ 
   \Theta & \Theta & \Theta & \Theta & \dots & \Theta & \Theta \\
   \Theta & I & \Theta & \Theta & \dots & \Theta & \Theta \\
   \Theta & \Theta & I & \Theta & \dots & \Theta & \Theta \\
   & & & \dots \\
   \Theta & \Theta & \Theta & \dots & \Theta & I & \Theta 
   \end{bmatrix} \in \mathbb{R}^{(2k+2) \times (2k+2)} \;\;\;\;
   B_{ext} = \begin{bmatrix} 
   B_1 \\ 
   I \\
   \Theta \\
   \dots \\
   \Theta 
   \end{bmatrix} \in \mathbb{R}^{(2k+2) \times 2}

And the final system takes form:

.. math::
   :label: tank_discrete_fin

   x_{ext}(i+1) = A_{ext} x_{ext}(i) + B_{ext} u^+(i)

Now we will consider the  problem statement. The initial concentration :math:`c_0` and volume 
:math:`V_0` are given. The problem is to specify whether it is possible to reach certain volume :math:`V`
and concentration :math:`c` at a certain time instant.

The following is the code that defines a linear discrete system. It takes initial conditions on input and then transforms system with delay into linear system according to the theoretical calculations, which were held above. Using ellipsoidal toolbox this program constructs reach tube and calculates a projection of it on subspace :math:`(V, c)`: 

.. literalinclude:: ../products/+elltool/+doc/+snip//s_chapter06_section09_snippet01.m
   :language: matlab
   :linenos:

As a result of this programm's calculations, we will have an illustration of reach tube's projection on subspace :math:`(V, c)`.

.. _pic1fig:

.. figure:: /pic/chapter06_section09_pic1.png
   :alt: pic1
   :width: 100 %

   Ellipsoidal reach tube, projection on subspace  :math:`(V, c)`.

This code below helps us to identify the possibility of this system to reach certain volume and concentration at a certain time instant. If we set up initial conditions in the way we made it above, it gives us the positive answer, which means that the problem is solvable and the system reaches required condition.

.. literalinclude:: ../products/+elltool/+doc/+snip//s_chapter06_section09_snippet02.m
   :language: matlab
   :linenos:

.. raw:: html
   <h2>References</h2>

.. [Kwakernaak] \H. Kwakernaak, R. Sivan. Linear Optimal Control Systems. John Wiley & Sons , 1972.


