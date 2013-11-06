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
implemented in MPT (“Multi-Parametric Toolbox Homepage”). With every
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

.. literalinclude:: /mcodesnippets/s_chapter06_section02_snippet02.m
   :language: matlab
   :linenos:


:num:`Figure #mechreachfig`(c) shows the reach set of the system
:eq:`smdist1`-:eq:`smdist2` evolving in time from :math:`t=0` to :math:`t=4`.
:num:`Figure #mechreachfig`(d) presents a snapshot of this reach set at time
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

   Highway model. Adapted from L.Muñoz et al. (2003).

There is no explicit implementation of the reachability analysis for
hybrid systems in the *Ellipsoidal Toolbox*. Nonetheless, the operations
of intersection available in the toolbox allow us to work with certain
class of hybrid systems, namely, hybrid systems with affine continuous
dynamics whose guards are ellipsoids, hyperplanes, halfspaces or
polytopes.

We consider the *switching-mode model* of highway traffic presented in
L.Muñoz et al. (2003). The highway segment is divided into :math:`N`
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

.. raw:: html

   <div class="references">

“Multi-Parametric Toolbox Homepage.” control.ee.ethz.ch/\\~mpt.

L.Muñoz, X.Sun, R.Horowitz, and L.Alvarez. 2003. “Traffic Density
Estimation with the Cell Transmission Model.” In *Proceedings of the
American Control Conference*, 3750–3755. Denver, Colorado, USA.

.. raw:: html

   </div>
