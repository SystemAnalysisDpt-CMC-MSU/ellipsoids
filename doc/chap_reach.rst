Reachability
============

Basics of Reachability Analysis
-------------------------------

Systems without disturbances
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider a general continuous-time

.. math::

   \dot{x}(t) = f(t, x, u),
   \label{ctds1}

or discrete-time dynamical system

.. math::

   x(t+1) = f(t, x, u),
   \tag*{(\ref{ctds1}d)}
   \label{dtds1}

wherein :math:`t` is time [1]_, :math:`x\in{\bf R}^n` is the state,
:math:`u\in{\bf R}^m` is the control, and :math:`f` is a measurable
vector function taking values in :math:`{\bf R}^n`. [2]_ The control
values :math:`u(t, x(t))` are restricted to a closed compact control set
:math:`{\mathcal U}(t)\subset{\bf R}^m`. An *open-loop* control does not
depend on the state, :math:`u=u(t)`; for a *closed-loop* control,
:math:`u=u(t, x(t))`.

The (forward) reach set :math:`{\mathcal X}(t, t_0, x_0)` at time
:math:`t>t_0` from the initial position :math:`(t_0, x_0)` is the set of
all states :math:`x(t)` reachable at time :math:`t` by system ([ctds1]),
or [dtds1], with :math:`x(t_0)=x_0` through all possible controls
:math:`u(\tau, x(\tau))\in{\mathcal U}(\tau)`,
:math:`t_0\leqslant\tau< t`. For a given set of initial states
:math:`{\mathcal X}_0`, the reach set
:math:`{\mathcal X}(t, t_0, {\mathcal X}_0)` is

.. math:: {\mathcal X}(t, t_0, {\mathcal X}_0) = \bigcup_{x_0\in{\mathcal X}_0}{\mathcal X}(t, t_0, x_0).

[def:sub:`o`\ lrs] Here are two facts about forward reach sets.

#. :math:`{\mathcal X}(t, t_0, {\mathcal X}_0)` is the same for
   open-loop and closed-loop control.

#. :math:`{\mathcal X}(t, t_0, {\mathcal X}_0)` satisfies the semigroup
   property,

   .. math::

      {\mathcal X}(t, t_0, {\mathcal X}_0) = {\mathcal X}(t, \tau, {\mathcal X}(\tau, t_0, {\mathcal X}_0)), \;\;\;
      t_0\leqslant\tau< t.
      \label{semigroup}

For linear systems

.. math::

   f(t, x, u) = A(t)x(t) + B(t)u,
   \label{linearrhs}

with matrices :math:`A(t)` in :math:`{\bf R}^{n\times n}` and
:math:`B(t)` in :math:`{\bf R}^{m\times n}`. For continuous-time linear
system the state transition matrix is

.. math:: \dot{\Phi}(t, t_0) = A(t)\Phi(t, t_0), \;\;\; \Phi(t, t) = I,

which for constant :math:`A(t)\equiv A` simplifies as

.. math:: \Phi(t, t_0) = e^{A(t-t_0)} .

For discrete-time linear system the state transition matrix is

.. math:: \Phi(t+1, t_0) = A(t)\Phi(t, t_0), \;\;\; \Phi(t, t) = I,

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

   {\mathcal X}(t, t_0, {\mathcal X}_0) =
   \Phi(t, t_0){\mathcal X}_0 \oplus \int_{t_0}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau
   \label{ctlsrs}

in continuous-time, and as

.. math::

   {\mathcal X}(t, t_0, {\mathcal X}_0) =
   \Phi(t, t_0){\mathcal X}_0 \oplus \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)
   \tag*{(\ref{ctlsrs}d)}
   \label{dtlsrs}

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
:math:`t\leqslant\tau<t_1`, that steers system ([ctds1]), or [dtds1] to
the state :math:`y_1` at time :math:`t_1`. For the target set
:math:`{\mathcal Y}_1` at time :math:`t_1`, the backward reach set
:math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` is

.. math:: {\mathcal Y}(t_1, t, {\mathcal Y}_1) = \bigcup_{y_1\in{\mathcal Y}_1}{\mathcal Y}(t_1, t, y_1).

[def:sub:`o`\ lbrs] The backward reach set
:math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` is the largest *weakly
invariant* set with respect to the target set :math:`{\mathcal Y}_1` and
time values :math:`t` and :math:`t_1`. [4]_

**Remark.** Backward reach set can be computed for continuous-time
system only if the solution of ([ctds1]) exists for :math:`t<t_1`; and
for discrete-time system only if the right hand side of [dtds1] is
invertible [5]_.

These two facts about the backward reach set :math:`{\mathcal Y}` are
similar to those for forward reach sets.

#. :math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` is the same for
   open-loop and closed-loop control.

#. :math:`{\mathcal Y}(t_1, t, {\mathcal Y}_1)` satisfies the semigroup
   property,

   .. math::

      {\mathcal Y}(t_1, t, {\mathcal Y}_1) = {\mathcal Y}(\tau, t, {\mathcal Y}(t_1, \tau, {\mathcal Y}_1)), \;\;\;
      t\leqslant\tau< t_1.
      \label{semigroup_b}

For the linear system ([linearrhs]) the backward reach set can be
expressed as

.. math::

   {\mathcal Y}(t_1, t, {\mathcal Y}_1) =
   \Phi(t, t_1){\mathcal Y}_1 \oplus \int_{t_1}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau
   \label{ctlsbrs}

in the continuous-time case, and as

.. math::

   {\mathcal Y}(t_1, t, {\mathcal Y}_1) =
   \Phi(t, t_1){\mathcal Y}_1 \oplus \sum_{\tau =t}^{t_1-1}-\Phi(t, \tau)B(\tau){\mathcal U}(\tau)
   \tag*{(\ref{ctlsbrs}d)}
   \label{dtlsbrs}

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

   \dot{x}(t) = f(t, x, u, v),
   \label{ctds2}

or the discrete-time dynamical system with disturbance

.. math::

   x(t+1) = f(t, x, u, v),
   \tag*{(\ref{ctds2}d)}
   \label{dtds2}

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
steers system ([ctds2]) or [dtds2] from :math:`x(t_0)=x_0` to
:math:`x(t)=x`. [def:sub:`m`\ axminolrs] The minmax open-loop reach set
:math:`\underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)` is the set
of all states :math:`x`, such that there exists a control
:math:`u(\tau)\in{\mathcal U}(\tau)` that for all disturbances
:math:`v(\tau)\in{\mathcal V}(\tau)`, :math:`t_0\leqslant\tau<t`,
assigns an initial state :math:`x_0\in{\mathcal X}_0` and steers system
([ctds2]), or [dtds2], from :math:`x(t_0)=x_0` to :math:`x(t)=x`.
[def:sub:`m`\ inmaxolrs] In the maxmin case the control is chosen
*after* knowing the disturbance over the entire time interval
:math:`[t_0, t]`, whereas in the minmax case the control is chosen
*before* any knowledge of the disturbance. Consequently, the OLRS do not
satisfy the semigroup property.

The terms ‘maxmin’ and ‘minmax’ come from the fact that
:math:`\overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)` is the
subzero level set of the value function

.. math::

   \underline{V}(t, x) =
   \max_v\min_u\{{\bf dist}(x(t_0), {\mathcal X}_0) ~|~ x(t)=x, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t_0\leqslant\tau<t\},
   \label{maxminvf}

i.e.,
:math:`\overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \{ x~|~\underline{V}(t, x) \leqslant0\}`,
and :math:`\underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0)` is the
subzero level set of the value function

.. math::

   \overline{V}(t, x) =
   \min_u\max_v\{{\bf dist}(x(t_0), {\mathcal X}_0) ~|~ x(t)=x, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t_0\leqslant\tau<t\},
   \label{minmaxvf}

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

   \overline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0) = \overline{{\mathcal X}}_{OL}(t, \tau_1, \overline{{\mathcal X}}_{OL}(\tau_1, t_0, {\mathcal X}_0)),
   \label{maxmin1}

and the *piecewise minmax open-loop reach set with one correction*,

.. math::

   \underline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0) = \underline{{\mathcal X}}_{OL}(t, \tau_1, \underline{{\mathcal X}}_{OL}(\tau_1, t_0, {\mathcal X}_0)).
   \label{minmax1}

The piecewise maxmin OLRS
:math:`\overline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0)` is the
subzero level set of the value function

.. math::

   \underline{V}^1(t, x) =
   \max_v\min_u\{\underline{V}(\tau_1, x(\tau_1)) ~|~ x(t)=x, \;
   u(\tau)\in{\mathcal U}(\tau), \; v(\tau)\in{\mathcal V}(\tau), \; \tau_1\leqslant\tau<t\},
   \label{maxminvf1}

with :math:`V(\tau_1, x(\tau_1))` given by ([maxminvf]), which yields

.. math:: \underline{V}^1(t, x) \geqslant\underline{V}(t, x),

and thus,

.. math:: \overline{{\mathcal X}}_{OL}^1(t, t_0 {\mathcal X}_0) \subseteq \overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) .

On the other hand, the piecewise minmax OLRS
:math:`\underline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0)` is the
subzero level set of the value function

.. math::

   \overline{V}^1(t, x) =
   \min_u\max_v\{\overline{V}(\tau_1, x(\tau_1)) ~|~ x(t)=x, \;
   u(\tau)\in{\mathcal U}(\tau), \; v(\tau)\in{\mathcal V}(\tau), \; \tau_1\leqslant\tau<t\},
   \label{minmaxvf1}

with :math:`V(\tau_1, x(\tau_1))` given by ([minmaxvf]), which yields

.. math:: \overline{V}(t, x) \geqslant\overline{V}^1(t, x),

and thus,

.. math:: \underline{{\mathcal X}}_{OL}(t, t_0 {\mathcal X}_0) \subseteq \underline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0) .

We can now recursively define piecewise maxmin and minmax OLRS with
:math:`k` corrections for :math:`t_0<\tau_1<\cdots<\tau_k<t`. The maxmin
piecewise OLRS with :math:`k` corrections is

.. math::

   \overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) =
   \overline{{\mathcal X}}_{OL}(t, \tau_k, \overline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0)),
   \label{maxmink}

which is the subzero level set of the corresponding value function

.. math::

   \begin{aligned}
   &&\underline{V}^k(t, x) = \nonumber \\
   &&\max_v\min_u\{\underline{V}^{k-1}(\tau_k, x(\tau_k)) ~|~ x(t)=x, \;
   u(\tau)\in{\mathcal U}(\tau), \; v(\tau)\in{\mathcal V}(\tau), \; \tau_k\leqslant\tau<t\}.
   \label{maxminvfk}\end{aligned}

The minmax piecewise OLRS with :math:`k` corrections is

.. math::

   \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) =
   \underline{{\mathcal X}}_{OL}(t, \tau_k, \underline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0)),
   \label{minmaxk}

which is the subzero level set of the corresponding value function

.. math::

   \begin{aligned}
   &&\overline{V}^k(t, x) = \nonumber \\
   &&\min_u\max_v\{\overline{V}^{k-1}(\tau_k, x(\tau_k)) ~|~ x(t)=x, \;
   u(\tau)\in{\mathcal U}(\tau), \; v(\tau)\in{\mathcal V}(\tau), \; \tau_k\leqslant\tau<t\}.
   \label{minmaxvfk}\end{aligned}

From ([maxminvf1]), ([minmaxvf1]), ([maxminvfk]) and ([minmaxvfk]) it
follows that

.. math::

   \underline{V}(t, x) \leqslant\underline{V}^1(t, x)\leqslant\cdots
   \leqslant\underline{V}^k(t, x) \leqslant\overline{V}^k(t, x) \leqslant\cdots
   \leqslant\overline{V}^1(t, x) \leqslant\overline{V}(t, x) .

Hence,

.. math::

   \begin{aligned}
   &&\underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) \subseteq \underline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0) \subseteq \cdots
   \subseteq \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) \subseteq \nonumber \\
   &&\overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) \subseteq \cdots \subseteq \overline{{\mathcal X}}_{OL}^1(t, t_0, {\mathcal X}_0)
   \subseteq \overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) .
   \label{olrsinclusion}\end{aligned}

We call

.. math::

   \overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0) = \overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0), \;\;
   k = \left\{\begin{array}{ll}
   \infty & \mbox{ for continuous-time system}\\
   t-t_0-1 & \mbox{ for discrete-time system}\end{array}\right.
   \label{maxminclrs}

the *maxmin closed-loop reach set* of system ([ctds2]) or [dtds2] at
time :math:`t`, and we call

.. math::

   \underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0) = \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0), \;\;
   k = \left\{\begin{array}{ll}
   \infty & \mbox{ for continuous-time system}\\
   t-t_0-1 & \mbox{ for discrete-time system}\end{array}\right.
   \label{minmaxclrs}

the *minmax closed-loop reach set* of system ([ctds2]) or [dtds2] at
time :math:`t`. Given initial time :math:`t_0` and the set of initial
states :math:`{\mathcal X}_0`, the maxmin CLRS
:math:`\overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0)` of system
([ctds2]) or [dtds2] at time :math:`t>t_0`, is the set of all states
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
that :math:`x(t)=x`. [def:sub:`m`\ axminclrs] Given initial time
:math:`t_0` and the set of initial states :math:`{\mathcal X}_0`, the
maxmin CLRS
:math:`\underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal X}_0)` of system
([ctds2]) or [dtds2], at time :math:`t>t_0`, is the set of all states
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
that :math:`x(t)=x`. [def:sub:`m`\ inmaxclrs] By construction, both
maxmin and minmax CLRS satisfy the semigroup property ([semigroup]).

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

   f(t, x, u) = A(t)x(t) + B(t)u + G(t)v,
   \label{linearrhsdist}

where :math:`A(t)` and :math:`B(t)` are as in ([linearrhs]), and
:math:`G(t)` takes its values in :math:`{\bf R}^d`.

The maxmin OLRS for the continuous-time linear system can be expressed
through set valued integrals,

.. math::

   \begin{array}{l}
   \overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, t_0){\mathcal X}_0 \oplus
   \int_{t_0}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau\right) \dot{-} \\
   \int_{t_0}^t\Phi(t, \tau)(-G(\tau)){\mathcal V}(\tau)d\tau,
   \end{array}
   \label{ctlsmaxmin}

and for discrete-time linear system through set-valued sums,

.. math::
   \begin{array}{l}
   \overline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \\
   (\Phi(t, t_0){\mathcal X}_0 \oplus \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)) \dot{-} \\
   \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)(-G(\tau)){\mathcal V}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsmaxmin}d)}
   \label{dtlsmaxmin}

Similarly, the minmax OLRS for the continuous-time linear system is

.. math::

   \begin{array}{l}
   \underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, t_0){\mathcal X}_0 \dot{-}
   \int_{t_0}^t\Phi(t, \tau)(-G(\tau)){\mathcal V}(\tau)d\tau\right)
   \oplus \\
   \int_{t_0}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau,
   \end{array}
   \label{ctlsminmax}

and for the discrete-time linear system it is

.. math::

   \begin{array}{l}
   \underline{{\mathcal X}}_{OL}(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, t_0){\mathcal X}_0 \dot{-} \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)(-G(\tau)){\mathcal V}(\tau)\right) \oplus \\
   \sum_{\tau=t_0}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsminmax}d)}
   \label{dtlsminmax}

The operation ‘:math:`\dot{-}`’ is *geometric difference*, also known as
*Minkowski difference*. [7]_

Now consider the piecewise OLRS with :math:`k` corrections. Expression
([maxmink]) translates into

.. math::

   \begin{array}{l}
   \overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0) \oplus
   \int_{\tau_k}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau\right) \dot{-} \\
   \int_{\tau_k}^t\Phi(t, \tau)(-G(\tau)){\mathcal V}(\tau)d\tau,
   \end{array}
   \label{ctlsmaxmink}

in the continuous-time case, and for the discrete-time case into

.. math::

   \begin{array}{l}
   \overline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0) \oplus
   \sum_{\tau=\tau_k}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)\right) \dot{-} \\
   \sum_{\tau=\tau_k}^{t-1}\Phi(t, \tau+1)(-G(\tau)){\mathcal V}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsmaxmink}d)}
   \label{dtlsmaxmink}

Expression ([minmaxk]) translates into

.. math::

   \begin{array}{l}
   \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) = \\
   (\Phi(t, \tau_k)\underline{{\mathcal X}}_{OL}^{k-1}(t, t_0, {\mathcal X}_0) \dot{-}
   \int_{\tau_k}^t\Phi(t, \tau)(-G(\tau)){\mathcal V}(\tau)d\tau)
   \oplus \\
   \int_{\tau_k}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau,
   \end{array}

   \label{ctlsminmaxk}

in the continuous-time case, and for the discrete-time case into

.. math::

   \begin{array}{l}
   \underline{{\mathcal X}}_{OL}^k(t, t_0, {\mathcal X}_0) = \\
   \left(\Phi(t, \tau_k)\underline{{\mathcal X}}_{OL}^{k-1}(\tau_k, t_0, {\mathcal X}_0) \dot{-}
   \sum_{\tau=\tau_k}^{t-1}\Phi(t, \tau+1)(-G(\tau)){\mathcal V}(\tau)\right)
   \oplus \\
   \sum_{\tau=\tau_k}^{t-1}\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsminmaxk}d)}
   \label{dtlsminmaxk}

Since for any
:math:`{\mathcal W}_1, {\mathcal W}_2, {\mathcal W}_3 \subseteq {\bf R}^n`
it is true that

.. math::

   ({\mathcal W}_1 \dot{-} {\mathcal W}_2) \oplus {\mathcal W}_3 =
   ({\mathcal W}_1 \oplus {\mathcal W}_3) \dot{-} ({\mathcal W}_2 \oplus {\mathcal W}_3) \subseteq
   ({\mathcal W}_1 \oplus {\mathcal W}_3) \dot{-} {\mathcal W}_2,

from ([ctlsmaxmink]), ([ctlsminmaxk]) and from [dtlsmaxmink],
[dtlsminmaxk], it is clear that ([olrsinclusion]) is true.
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
([ctds2]) or [dtds2] at time :math:`t<t_1`, is the set of all :math:`y`,
such that for any disturbance :math:`v(\tau)\in{\mathcal V}(\tau)` there
exists a terminal state :math:`y_1\in{\mathcal Y}_1` and control
:math:`u(\tau)\in{\mathcal U}(\tau)`, :math:`t\leqslant\tau<t_1`, which
steers the system from :math:`y(t)=y` to :math:`y(t_1)=y_1`.
[def:sub:`m`\ axminolbrs]
:math:`\overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1)` is the
subzero level set of the value function

.. math::

   \begin{aligned}
   &&\underline{V}_b(t, y) = \nonumber \\
   &&\max_v\min_u\{{\bf dist}(y(t_1), {\mathcal Y}_1) ~|~ y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<t_1\},
   \label{maxminvfb}\end{aligned}

Given the terminal time :math:`t_1` and target set
:math:`{\mathcal Y}_1`, the minmax open-loop backward reach set
:math:`\underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1)` of system
([ctds2]) or [dtds2] at time :math:`t<t_1`, is the set of all :math:`y`,
such that there exists a control :math:`u(\tau)\in{\mathcal U}(\tau)`
that for all disturbances :math:`v(\tau\in{\mathcal V}(\tau)`,
:math:`t\leqslant\tau<t_1`, assigns a terminal state
:math:`y_1\in{\mathcal Y}_1` and steers the system from :math:`y(t)=y`
to :math:`y(t_1)=y_1`. [def:sub:`m`\ inmaxolbrs]
:math:`\underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1)` is the
subzero level set of the value function

.. math::

   \begin{aligned}
   &&\overline{V}_b(t, y) = \nonumber \\
   &&\min_u\max_v\{{\bf dist}(y(t_1), {\mathcal Y}_1) ~|~ y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<t_1\},
   \label{minmaxvfb}\end{aligned}

**Remark.** The backward reach set can be computed for a continuous-time
system only if the solution of ([ctds2]) exists for :math:`t<t_1`, and
for a discrete-time system only if the right hand side of [dtds2] is
invertible.

Similarly to the forward reachability case, we construct piecewise OLBRS
with one correction at time :math:`\tau_1`, :math:`t<\tau_1<t_1`. The
piecewise maxmin OLBRS with one correction is

.. math::

   \overline{{\mathcal Y}}_{OL}^1(t_1, t, {\mathcal Y}_1) = \overline{{\mathcal Y}}_{OL}(\tau_1, t, \overline{{\mathcal Y}}_{OL}(t_1, \tau_1, {\mathcal Y}_1)),
   \label{maxminb1}

and it is the subzero level set of the function

.. math::

   \begin{aligned}
   &&\underline{V}^1_b(t, y) = \nonumber \\
   &&\max_v\min_u\{\underline{V}_b(\tau_1, y(\tau_1)) ~|~
   y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<\tau_1\}.
   \label{maxminvfb1}\end{aligned}

The piecewise minmax OLBRS with one correction is

.. math::

   \underline{{\mathcal Y}}_{OL}^1(t_1, t, {\mathcal Y}_1) = \underline{{\mathcal Y}}_{OL}(\tau_1, t, \underline{{\mathcal Y}}_{OL}(t_1, \tau_1, {\mathcal Y}_1)),
   \label{minmaxb1}

and it is the subzero level set of the function

.. math::

   \begin{aligned}
   &&\overline{V}^1_b(t, y) = \nonumber \\
   &&\min_u\max_v\{\overline{V}_b(\tau_1, y(\tau_1)) ~|~
   y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<\tau_1\},
   \label{minmaxvfb1}\end{aligned}

Recursively define maxmin and minmax OLBRS with :math:`k` corrections
for :math:`t<\tau_k<\cdots<\tau_1<t_1`. The maxmin OLBRS with :math:`k`
corrections is

.. math::

   \overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \overline{{\mathcal Y}}_{OL}(\tau_k, t, \overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1)),
   \label{maxminbk}

which is the subzero level set of function

.. math::

   \begin{aligned}
   &&\underline{V}^k_b(t, y) = \nonumber \\
   &&\max_v\min_u\{\underline{V}^{k-1}_b(\tau_k, y(\tau_k)) ~|~
   y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<\tau_k\}.
   \label{maxminvfbk}\end{aligned}

The minmax OLBRS with :math:`k` corrections is

.. math::

   \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \underline{{\mathcal Y}}_{OL}(\tau_k, t, \underline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1)),
   \label{minmaxbk}

which is the subzero level set of the function

.. math::

   \begin{aligned}
   &&\overline{V}^k_b(t, y) = \nonumber \\
   &&\min_u\max_v\{\overline{V}^{k-1}_b(\tau_k, y(\tau_k)) ~|~
   y(t)=y, \; u(\tau)\in{\mathcal U}(\tau), \;
   v(\tau)\in{\mathcal V}(\tau), \; t\leqslant\tau<\tau_k\},
   \label{minmaxvfbk}\end{aligned}

From ([maxminvfb1]), ([minmaxvfb1]), ([maxminvfbk]) and ([minmaxvfbk])
it follows that

.. math::

   \underline{V}_b(t, y) \leqslant\underline{V}^1_b(t, y)\leqslant\cdots
   \leqslant\underline{V}^k_b(t, y) \leqslant\overline{V}^k_b(t, y) \leqslant\cdots
   \leqslant\overline{V}^1_b(t, y) \leqslant\overline{V}_b(t, y) .

Hence,

.. math::

   \begin{aligned}
   &&\underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) \subseteq \underline{{\mathcal Y}}_{OL}^1(t_1, t, {\mathcal Y}_1) \subseteq \cdots
   \subseteq \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) \subseteq \nonumber \\
   &&\overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) \subseteq \cdots \subseteq \overline{{\mathcal Y}}_{OL}^1(t_1, t, {\mathcal Y}_1)
   \subseteq \overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) .
   \label{olbrsinclusion}\end{aligned}

We say that

.. math::

   \overline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1) = \overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1), \;\;
   k = \left\{\begin{array}{ll}
   \infty & \mbox{ for continuous-time system}\\
   t_1-t-1 & \mbox{ for discrete-time system}\end{array}\right.
   \label{maxminclbrs}

is the *maxmin closed-loop backward reach set* of system ([ctds2]) or
[dtds2] at time :math:`t`.

We say that

.. math::

   \underline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1) = \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1), \;\;
   k = \left\{\begin{array}{ll}
   \infty & \mbox{ for continuous-time system}\\
   t_1-t-1 & \mbox{ for discrete-time system}\end{array}\right.
   \label{minmaxclbrs}

is the *minmax closed-loop backward reach set* of system ([ctds2]) or
[dtds2] at time :math:`t`. Given the terminal time :math:`t_1` and
target set :math:`{\mathcal Y}_1`, the maxmin CLBRS
:math:`\overline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1)` of system
([ctds2]) or [dtds2] at time :math:`t<t_1`, is the set of all states
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
:math:`y(t) = y` and :math:`y(t_1)=y_1`. [def:sub:`m`\ axminclbrs] Given
the terminal time :math:`t_1` and target set :math:`{\mathcal Y}_1`, the
minmax CLBRS
:math:`\underline{{\mathcal Y}}_{CL}(t_1, t, {\mathcal Y}_1)` of system
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
:math:`y(t) = y` and :math:`y(t_1)=y_1`. [def:sub:`m`\ inmaxclbrs] Both
maxmin and minmax CLBRS satisfy the semigroup property
([semigroup:sub:`b`]).

The maxmin OLBRS for the continuous-time linear system can be expressed
through set valued integrals,

.. math::

   \begin{array}{l}
   \overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, t_1){\mathcal Y}_1 \oplus
   \int_{t_1}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau\right) \dot{-} \\
   \int_{t}^{t_1}\Phi(t, \tau)G(\tau){\mathcal V}(\tau)d\tau,
   \end{array}
   \label{ctlsmaxminb}

and for the discrete-time linear system through set-valued sums,

.. math::

   \begin{array}{l}
   \overline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, t_1){\mathcal Y}_1 \oplus
   \sum_{\tau=t}^{t_1-1}-\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)\right) \dot{-} \\
   \sum_{\tau=t}^{t_1-1}\Phi(t, \tau+1)G(\tau){\mathcal V}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsmaxminb}d)}
   \label{dtlsmaxminb}

Similarly, the minmax OLBRS for the continuous-time linear system is

.. math::

   \begin{array}{l}
   \underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, t_1){\mathcal Y}_1 \dot{-}
   \int_{t}^{t_1}\Phi(t, \tau)G(\tau){\mathcal V}(\tau)d\tau\right)
   \oplus \\
   \int_{t_1}^{t}\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau,
   \end{array}
   \label{ctlsminmaxb}

and for the discrete-time linear system it is

.. math::

   \begin{array}{l}
   \underline{{\mathcal Y}}_{OL}(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, t_1){\mathcal Y}_1 \dot{-}
   \sum_{\tau=t}^{t_1-1}\Phi(t, \tau+1)G(\tau){\mathcal V}(\tau)\right)
   \oplus \\
   \sum_{\tau=t}^{t_1-1}-\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsminmaxb}d)}
   \label{dtlsminmaxb}

Now consider piecewise OLBRS with :math:`k` corrections. Expression
([maxminbk]) translates into

.. math::

   \begin{array}{l}
   \overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1) \oplus
   \int_{\tau_k}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau\right) \dot{-} \\
   \int^{\tau_k}_t\Phi(t, \tau)G(\tau){\mathcal V}(\tau)d\tau,
   \end{array}
   \label{ctlsmaxminbk}

in the continuous-time case, and for the discrete-time case into

.. math::

   \begin{array}{l}
   \overline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \\
   \left(\Phi(t, \tau_k)\overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1) \oplus
   \sum_{\tau=t}^{\tau_k-1}-\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau)\right) \dot{-} \\
   \sum_{\tau=t}^{\tau_k-1}\Phi(t, \tau+1)G(\tau){\mathcal V}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsmaxminbk}d)}
   \label{dtlsmaxminbk}

Expression ([minmaxbk]) translates into

.. math::

   \begin{array}{l}
   \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \\
   (\Phi(t, \tau_k)\overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1) \dot{-}
   \int^{\tau_k}_t\Phi(t, \tau)G(\tau){\mathcal V}(\tau)d\tau)
   \oplus \\
   \int_{\tau_k}^t\Phi(t, \tau)B(\tau){\mathcal U}(\tau)d\tau,
   \end{array}
   \label{ctlsminmaxbk}

in the continuous-time case, and for the discrete-time case into

.. math::

   \begin{array}{l}
   \underline{{\mathcal Y}}_{OL}^k(t_1, t, {\mathcal Y}_1) = \\
   (\Phi(t, \tau_k)\overline{{\mathcal Y}}_{OL}^{k-1}(t_1, \tau_k, {\mathcal Y}_1) \dot{-}
   \sum_{\tau=t}^{\tau_k-1}\Phi(t, \tau+1)G(\tau){\mathcal V}(\tau))
   \oplus \\
   \sum_{\tau=t}^{\tau_k-1}-\Phi(t, \tau+1)B(\tau){\mathcal U}(\tau).
   \end{array}
.. \tag*{(\ref{ctlsminmaxk}d)}
   \label{dtlsminmaxbk}

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
   :math:`{\mathcal Y}_1\cap\bigcup_{t_0 \leqslant\tau\leqslantt}{\mathcal X}(\tau, t_0, {\mathcal X}_0)`
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

.. math:: \dot{x}(t) = A(t)x(t) + B(t)u + G(t)v, \label{ctsystem}

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

If the matrix :math:`Q(\cdot)=0`, the system ([ctsystem]) becomes an
ordinary affine system with known :math:`v(\cdot)=q(\cdot)`. If
:math:`G(\cdot) = 0`, the system becomes linear. For these two cases
(:math:`Q(\cdot)=0` or :math:`G(\cdot)=0`) the reach set is as given in
Definition [def:sub:`o`\ lrs], and so the reach set will be denoted as
:math:`{\mathcal X}_{CL}(t, t_0, {\mathcal E}(x_0, X_0)) = {\mathcal X}(t, t_0, {\mathcal E}(x_0,X_0))`.

The reach set :math:`{\mathcal X}(t,t_0,{\mathcal E}(x_0,X_0))` is a
symmetric compact convex set, whose center evolves in time according to

.. math::

   \dot{x}_c(t) = A(t)x_c(t) + B(t)p(t) + G(t)q(t), \;\;\;
   x_c(t_0)=x_0. \label{fwdcenter}

Fix a vector :math:`l_0\in{\bf R}^n`, and consider the solution
:math:`l(t)` of the adjoint equation

.. math::

   \dot{l}(t) = -A^T(t)l(t), \;\;\; l(t_0) = l_0,
   \label{adjointct}

which is equivalent to

.. math:: l(t) = \Phi^T(t_0, t)l_0.

If the reach set :math:`{\mathcal X}(t, t_0, {\mathcal E}(x_0,X_0))` is
nonempty, there exist tight external and tight internal approximating
ellipsoids :math:`{\mathcal E}(x_c(t), X^+_l(t))` and
:math:`{\mathcal E}(x_c(t), X^-_l(t))`, respectively, such that

.. math::

   {\mathcal E}(x_c(t), X^-_l(t))\subseteq{\mathcal X}(t,t_0,{\mathcal E}(x_0,X_0))
   \subseteq {\mathcal E}(x_c(t), X^+_l(t)),
   \label{fwdinclusion}

and

.. math::

   \rho(l(t) ~|~ {\mathcal E}(x_c(t), X^-_l(t))) =
   \rho(l(t) ~|~ {\mathcal X}(t, t_0, {\mathcal E}(x_0,X_0))) =
   \rho(l(t) ~|~ {\mathcal E}(x_c(t), X^+_l(t))) .
   \label{fwdtightness}

The equation for the shape matrix of the external ellipsoid is

.. math::

   \dot{X}^+_l(t) & = & A(t)X^+_l(t) + X^+_l(t)A^T(t) +\nonumber \\
   & & \pi_l(t)X^+_l(t) + \frac{1}{\pi_l(t)}B(t)P(t)B^T(t) -\nonumber \\
   & & (X_l^{+}(t))^{1/2}S_l(t)(G(t)Q(t)G^T(t))^{1/2} \nonumber -\\
   & & (G(t)Q(t)G^T(t))^{1/2}S_l^T(t)(X_l^{+}(t))^{1/2}, \label{fwdext1} \\

.. math::
   
   X^+_l(t_0) & = & X_0, \label{fwdext2}

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
from the equation ([fwdext1]).

The equation for the shape matrix of the internal ellipsoid is

.. math::

   \dot{X}^-_l(t) & = & A(t)X^-_l(t) + X^-_l(t)A^T(t) +\nonumber \\
   & & (X_l^{-}(t))^{1/2}T_l(t)(B(t)P(t)B^T(t))^{1/2} +\nonumber \\
   & & (B(t)P(t)B^T(t))^{1/2}T_l^T(t)(X_l^{-}(t))^{1/2} -\nonumber \\
   & & \eta_l(t)X^-_l(t) - \frac{1}{\eta_l(t)}G(t)Q(t)G^T(t), \label{fwdint1} \\

   X^-_l(t_0) & = & X_0, \label{fwdint2}

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

.. math:: x^0_l = x_0 + \frac{X_0l_0}{\langle l_0,X_0l_0\rangle^{1/2}}. \label{x0lct}

In the absence of disturbances, the open-loop control

.. math::

   u_l(t) = p(t) + \frac{P(t)B^T(t)l(t)}{\langle l(t),
   B(t)P(t)B^T(t)l(t)\rangle^{1/2}}. \label{uct}

steers the system along the extremal trajectory defined by the vector
:math:`l_0`. When a disturbance is present, this control keeps the
system on an extremal trajectory if and only if the disturbance plays
against the control always taking its extreme values.

Expressions ([fwdinclusion]) and ([fwdtightness]) lead to the following
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

.. math:: y_c(t) = Ay_c(t) + B(t)p(t) + G(t)q(t), \;\;\; y_c(t_1) = y_1.\label{bckcenter}

Fix a vector :math:`l_1\in{\bf R}^n`, and consider

.. math::

   l(t) = \Phi(t_1, t)^Tl_1 .
   \label{bckadjoint}

If the backward reach set
:math:`{\mathcal Y}(t_1, t, {\mathcal E}(y_1,Y_1))` is nonempty, there
exist tight external and tight internal approximating ellipsoids
:math:`{\mathcal E}(y_c(t), Y^+_l(t))` and
:math:`{\mathcal E}(y_c(t), Y^-_l(t))` respectively, such that

.. math::

   {\mathcal E}(y_c(t), Y^-_l(t))\subseteq{\mathcal Y}(t_1,t,{\mathcal E}(y_1,Y_1))
   \subseteq {\mathcal E}(y_c(t), Y^+_l(t)),
   \label{bckinclusion}

and

.. math::

   \rho(l(t) ~|~ {\mathcal E}(y_c(t), Y^-_l(t))) =
   \rho(l(t) ~|~ {\mathcal Y}(t_1, t, {\mathcal E}(y_0,Y_0))) =
   \rho(l(t) ~|~ {\mathcal E}(y_c(t), Y^+_l(t))) .
   \label{bcktightness}

The equation for the shape matrix of the external ellipsoid is

.. math::

   \dot{Y}^+_l(t) & = & A(t)Y^+_l(t) + Y^+_l(t)A^T(t) -\nonumber \\
   & & \pi_l(t)Y^+_l(t) - \frac{1}{\pi_l(t)}B(t)P(t)B^T(t) +\nonumber \\
   & & (Y_l^{+}(t))^{1/2}S_l(t)(G(t)Q(t)G^T(t))^{1/2} +\nonumber \\
   & & (G(t)Q(t)G^T(t))^{1/2}S_l^T(t)(Y_l^{+}(t))^{1/2}, \label{bckext1} \\

.. math::

   Y^+_l(t_1) & = & Y_1, \label{bckext2}

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

   \dot{Y}^-_l(t) & = & A(t)Y^-_l(t) + Y^-_l(t)A^T(t) -\nonumber \\
   & & (Y_l^{-}(t))^{1/2}T_l(t)(B(t)P(t)B^T(t))^{1/2} -\nonumber \\
   & & (B(t)P(t)B^T(t))^{1/2}T_l^T(t)(Y_l^{-}(t))^{1/2} +\nonumber \\
   & & \eta_l(t)Y^-_l(t) + \frac{1}{\eta_l(t)}G(t)Q(t)G^T(t), \label{bckint1} \\
 
   Y^-_l(t_1) & = & Y_1, \label{bckint2}

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
:math:`G(t)` and :math:`Q(t)` vanish from equations ([bckext1]) and
([bckint1]) in the absence of disturbances. The boundary value problems
([bckcenter]), ([bckext1]) and ([bckint1]) are converted to the initial
value problems by the change of variables :math:`s = -t`.

Due to ([bckinclusion]) and ([bcktightness]),

.. math::

   \bigcup_{\langle l_1,l_1\rangle=1}{\mathcal E}(y_c(t),Y^-_l(t)) =
   {\mathcal Y}(t_1,t,{\mathcal E}(y_1,Y_1)) =
   \bigcap_{\langle l_1,l_1\rangle=1}{\mathcal E}(y_c(t),Y^+_l(t)).

**Remark.** In expressions ([fwdext1]), ([fwdint1]), ([bckext1]) and
([bckint1]) the terms :math:`\frac{1}{\pi_l(t)}` and
:math:`\frac{1}{\eta_l(t)}` may not be well defined for some vectors
:math:`l`, because matrices :math:`B(t)P(t)B^T(t)` and
:math:`G(t)Q(t)G^T(t)` may be singular. In such cases, we set these
entire expressions to zero.

Discrete-time systems
~~~~~~~~~~~~~~~~~~~~~

Consider the discrete-time linear system,

.. math::

   x(t+1) = A(t)x(t) + B(t)u(t,x(t)) + G(t)v(t),
..   \tag*{(\ref{ctsystem})}
   \label{dtsystem}

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

If matrix :math:`Q(\cdot)=0`, the system ([dtsystem]) becomes an
ordinary affine system with known :math:`v(\cdot)=q(\cdot)`. If matrix
:math:`G(\cdot)=0`, the system reduces to a linear controlled system. In
the absence of disturbance (:math:`Q(\cdot)=0` or :math:`G(\cdot)=0`),
:math:`\overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))=\underline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))={\mathcal X}(t,t_0,{\mathcal E}(x_0,X_0))`,
the reach set is as in Definition [def:sub:`o`\ lrs].

Maxmin and minmax CLRS
:math:`\overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0, X_0)` and
:math:`\underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0, X_0)`, if
nonempty, are symmetric convex and compact, with the center evolving in
time according to

.. math::

   x_c(t+1) = A(t)x_c(t) + B(t)p(t) + G(t)v(t), \;\;\; x_c(t_0)=x_0.
   \label{fwdcenterd}

Fix some vector :math:`l_0\in{\bf R}^n` and consider :math:`l(t)` that
satisfies the discrete-time adjoint equation, [10]_

.. math::

   l(t+1) = \left(A^T\right)^{-1}(t)l(t), \;\;\; l(t_0) = l_0,
   \label{adjointdt}

or, equivalently

.. math:: l(t) = \Phi^T(t_0, t)l_0 .

There exist tight external ellipsoids
:math:`{\mathcal E}(x_c(t), \overline{X}^+_l(t))`,
:math:`{\mathcal E}(x_c(t), \underline{X}^+_l(t))` and tight internal
ellipsoids :math:`{\mathcal E}(x_c(t), \overline{X}^-_l(t))`,
:math:`{\mathcal E}(x_c(t), \underline{X}^-_l(t))` such that

.. math::

   {\mathcal E}(x_c(t), \overline{X}^-_l(t))\subseteq\overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))
   \subseteq {\mathcal E}(x_c(t), \overline{X}^+_l(t)),
   \label{maxmininclusion}

.. math::

   \rho(l(t) ~|~ {\mathcal E}(x_c(t), \overline{X}^-_l(t))) =
   \rho(l(t) ~|~ \overline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0,X_0))) =
   \rho(l(t) ~|~ {\mathcal E}(x_c(t), \overline{X}^+_l(t))) .
   \label{maxmintightness}

and

.. math::

   {\mathcal E}(x_c(t), \underline{X}^-_l(t))\subseteq\underline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))
   \subseteq {\mathcal E}(x_c(t), \underline{X}^+_l(t)),
   \label{minmaxinclusion}

.. math::

   \rho(l(t) ~|~ {\mathcal E}(x_c(t), \underline{X}^-_l(t))) =
   \rho(l(t) ~|~ \underline{{\mathcal X}}_{CL}(t, t_0, {\mathcal E}(x_0,X_0))) =
   \rho(l(t) ~|~ {\mathcal E}(x_c(t), \underline{X}^+_l(t))) .
   \label{minmaxtightness}

The shape matrix of the external ellipsoid for maxmin reach set is
determined from

.. math::

   \hat{X}^+_l(t) & = & (1+\overline{\pi}_l(t))A(t)\overline{X}^+_l(t)A^T(t) +
   \left(1+\frac{1}{\overline{\pi}_l(t)}\right)
   B(t)P(t)B^T(t), \label{fwdextmaxmin1} \\

   \overline{X}^+_l(t+1) & = & \left((\hat{X}^+_l(t))^{1/2} +
   \overline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}\right)^T
   \times \nonumber \\
   & &\left((\hat{X}^+_l(t))^{1/2} + \overline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}\right), \label{fwdextmaxmin2}\\

   \overline{X}^+_l(t_0) & = & X_0, \label{fwdextmaxmin3}

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

Equation ([fwdextmaxmin2]) is valid only if
:math:`{\mathcal E}(0,G(t)Q(t)G^T(t))\subseteq{\mathcal E}(0,\hat{X}^+_l(t))`,
otherwise the maxmin CLRS
:math:`\overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))` is
empty.

The shape matrix of the external ellipsoid for minmax reach set is
determined from

.. math::

   \breve{X}^+_l(t) & = &
   \left((A(t)\underline{X}^+_l(t)A^T(t))^{1/2} +
   \underline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}\right)^T
   \times \nonumber \\
   & &\left((A(t)\underline{X}^+_l(t)A^T(t))^{1/2} +
   \underline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}\right)
   \label{fwdextminmax1}\\

   \underline{X}^+_l(t+1) & = &
   (1+\underline{\pi}_l(t))\breve{X}^+_l(t) +
   \left(1+\frac{1}{\underline{\pi}_l(t)}\right)
   B(t)P(t)B^T(t), \label{fwdextminmax2} \\

   \underline{X}^+_l(t_0) & = & X_0, \label{fwdextminmax3}

where

.. math::

   \underline{\pi}_l(t) = \frac{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}{\langle l(t+1),
   \breve{X}^+_l(t)l(t+1)\rangle^{1/2}},

and :math:`\underline{S}_l(t)` is orthogonal matrix determined from the
equation

.. math::

   \begin{aligned}
   & & \underline{S}_l(t)(G(t)Q(t)G^T(t))^{1/2}l(t+1) = \\
   & & \frac{\langle l(t+1),
   G(t)Q(t)G^T(t)l(t+1)\rangle^{1/2}}{\langle l(t),
   \underline{X}^+_l(t)l(t)\rangle^{1/2}}(A(t)\underline{X}^+_l(t)A^T(t))^{1/2}l(t+1).\end{aligned}

Equations ([fwdextminmax1]), ([fwdextminmax2]) are valid only if
:math:`{\mathcal E}(0,G(t)Q(t)G^T(t)\subseteq{\mathcal E}(0,A(t)\underline{X}^+_l(t)A^T(t))`,
otherwise minmax CLRS
:math:`\underline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))` is
empty.

The shape matrix of the internal ellipsoid for maxmin reach set is
determined from

.. math::

   \hat{X}^-_l(t) & = &
   \left((A(t)\overline{X}^-_l(t)A^T(t))^{1/2} +
   \overline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}\right)^T
   \times \nonumber \\
   & &\left((A(t)\overline{X}^-_l(t)A^T(t))^{1/2} +
   \overline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}\right)
   \label{fwdintmaxmin1}\\

   \overline{X}^-_l(t+1) & = &
   (1+\overline{\eta}_l(t))\hat{X}^-_l(t) +
   \left(1+\frac{1}{\underline{\eta}_l(t)}\right)
   G(t)Q(t)G^T(t), \label{fwdintmaxmin2} \\

   \overline{X}^-_l(t_0) & = & X_0, \label{fwdintmaxmin3}

where

.. math::

   \overline{\eta}_l(t) = \frac{\langle l(t+1),
   G(t)Q(t)G^T(t)l(t+1)\rangle^{1/2}}{\langle l(t+1),
   \hat{X}^-_l(t)l(t+1)\rangle^{1/2}},

and :math:`\overline{T}_l(t)` is orthogonal matrix determined from the
equation

.. math::

   \begin{aligned}
   & & \overline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}l(t+1) = \\
   & & \frac{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}{\langle l(t),
   \overline{X}^-_l(t)l(t)\rangle^{1/2}}(A(t)\overline{X}^-_l(t)A^T(t))^{1/2}l(t+1).\end{aligned}

Equation ([fwdintmaxmin2]) is valid only if
:math:`{\mathcal E}(0,G(t)Q(t)G^T(t)\subseteq{\mathcal E}(0,\hat{X}^-_l(t))`.

The shape matrix of the internal ellipsoid for the minmax reach set is
determined by

.. math::

   \breve{X}^-_l(t) & = & (1+\underline{\eta}_l(t))A(t)\underline{X}^-_l(t)A^T(t) +
   \left(1+\frac{1}{\underline{\eta}_l(t)}\right)
   G(t)Q(t)G^T(t), \label{fwdintminmax1} \\

   \underline{X}^-_l(t+1) & = & \left((\breve{X}^-_l(t))^{1/2} +
   \underline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}\right)^T
   \times \nonumber \\
   & &\left((\breve{X}^-_l(t))^{1/2} + \underline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}\right),
   \label{fwdintminmax2}\\

   \underline{X}^-_l(t_0) & = & X_0, \label{fwdintminmax3}

wherein

.. math::

   \underline{\eta}_l(t) = \frac{\langle l(t+1),
   G(t)Q(t)G^T(t)l(t+1)\rangle^{1/2}}{\langle l(t),
   \underline{X}^-_l(t)l(t)\rangle^{1/2}},

and the orthogonal matrix :math:`\underline{T}_l(t)` is determined by
the equation

.. math::

   \begin{aligned}
   & & \underline{T}_l(t)(B(t)P(t)B^T(t))^{1/2}l(t+1) = \\
   & & \frac{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}{\langle l(t+1),
   \breve{X}^-_l(t)l(t+1)\rangle^{1/2}}(\breve{X}^-_l(t))^{1/2}l(t+1).\end{aligned}

Equations ([fwdintminmax1]), ([fwdintminmax2]) are valid only if
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

Points :math:`x^{\pm}_l(t)`, :math:`t\geqslantt_0`, form extremal
trajectories. In order for the system to follow the extremal trajectory
specified by some vector :math:`l_0`, the initial state must be

.. math:: x_l^0 = x_0 + \frac{X_0l_0}{\langle l_0, X_0l_0\rangle^{1/2}}. \label{dx0l}

When there is no disturbance (:math:`G(t)=0` or :math:`Q(t)=0`),
:math:`\overline{X}^+_l(t)=\underline{X}^+_l(t)` and
:math:`\overline{X}^-_l(t)=\underline{X}^-_l(t)`, and the open-loop
control that steers the system along the extremal trajectory defined by
:math:`l_0` is

.. math::

   u_l(t) = p(t) + \frac{P(t)B^T(t)l(t+1)}{\langle l(t+1),
   B(t)P(t)B^T(t)l(t+1)\rangle^{1/2}}. \label{udt}

Each choice of :math:`l_0` defines an external and internal
approximation. If
:math:`\overline{{\mathcal X}}_{CL}(t,t_0,{\mathcal E}(x_0,X_0))` is
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

   l(t) = \Phi^T(t_1,t)l_1,
..   \tag*{(\ref{bckadjoint})}
   \label{bckadjointd}

with some fixed :math:`l_1`, for which they exist.

With boundary conditions

.. math::

   y_c(t_1)=y_1, ~~~ \overline{Y}^+_l(t_1)=\overline{Y}^-_l(t_1)=\underline{Y}^+_l(t_1)=\underline{Y}^-_l(t_1)=Y_1,
   \label{bndconds}

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

in direction :math:`l(t)` from [bckadjointd]. Section
[subsec:sub:`s`\ umdiff] describes the operation of geometric
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

in direction :math:`l(t)` from [bckadjointd]. Section
[subsec:sub:`d`\ iffsum] describes the operation of geometric
difference-sum for ellipsoids.

.. raw:: html

   <div class="references">

A. A. Kurzhanskiy, P. Varaiya. 2007. “Ellipsoidal Techniques for
Reachability Analysis of Discrete-time Linear Systems.” *IEEE
Transactions on Automatic Control* 52 (1): 26–38.

.. raw:: html

   </div>

.. [1]
   In discrete-time case :math:`t` assumes integer values.

.. [2]
   We are being general when giving the basic definitions. However, it
   is important to understand that for any specific *continuous-time*
   dynamical system it must be determined whether the solution exists
   and is unique, and in which class of solutions these conditions are
   met. Here we shall assume that function :math:`f` is such that the
   solution of the differential equation ([ctds1]) exists and is unique
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
   The case when :math:`A(t)` is singular is described in A. A.
   Kurzhanskiy (2007). The idea is to substitute :math:`A(t)` with the
   nonsingular :math:`A_\delta(t) = A(t) + \delta U(t)W(t)`, in which
   :math:`U(t)` and :math:`W(t)` are obtained from the singular value
   decomposition

   .. math:: A(t) = U(t)\Sigma(t)V(t) .

   The parameter :math:`\delta` can be chosen based on the number of
   time steps for which the reach set must be computed and the required
   accuracy. The issue of inverting ill-conditioned matrices is also
   addressed in A. A. Kurzhanskiy (2007).

.. [10]
   Note that for ([adjointdt]) :math:`A(t)` must be invertible.
