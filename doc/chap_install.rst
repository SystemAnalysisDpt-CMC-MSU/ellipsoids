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
   
.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter04_section01_snippet01.m
   :language: matlab
   :linenos:

#. At this point, the directory tree of the *Ellipsoidal Toolbox* is
   added to the MATLAB path list. In order to save the updated path
   list, in your MATLAB window menu go to File :math:`\rightarrow` Set
   Path... and click Save.

#. To get an idea of what the toolbox is about, type

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter04_section01_snippet02.m
   :language: matlab
   :linenos:


This will produce a demo of basic *ET* functionality: how to create
and manipulate ellipsoids.

Type

.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter04_section01_snippet03.m
   :language: matlab
   :linenos:


to learn how to plot ellipsoids and hyperplanes in 2 and 3D. For a
quick tutorial on how to use the toolbox for reachability analysis
and verification, type
   
.. literalinclude:: ../products/+elltool/+doc/+snip/s_chapter04_section01_snippet04.m
   :language: matlab
   :linenos:


.. raw:: html

	<h2>References</h2>   
 
.. [MPTHP] Multi-Parametric Toolbox homepage. http://control.ee.ethz.ch/~mpt.
   
.. [CVXHP] CVX homepage. http://cvxr.com/cvx.

.. [SDMHP] SeDuMi homepage. http://sedumi.mcmaster.ca.

.. [STUR1999] Sturm, J. F. 1999. Using SeDuMi 1.02, A MATLAB Toolbox for Optimization
   over Symmetric Cones. *Optimization Methods and Software* 11-12: 625–653.

.. [SDPT3HP] SDPT3 homepage. http://www.math.nus.edu.sg/~mattohkc/sdpt3.html.

