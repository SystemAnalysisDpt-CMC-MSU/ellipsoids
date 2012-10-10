Ellipsoidal Toolbox
    http://code.google.com/p/ellipsoids/


The Ellipsoidal Toolbox is a standalone set of easy-to-use configurable
MATLAB routines to perform operations with ellipsoids and hyperplanes
of arbitrary dimensions. It computes the external and internal ellipsoidal
approximations of geometric (Minkowski) sums and differences of ellipsoids,
intersections of ellipsoids and intersections of ellipsoids with halfspaces;
distances between ellipsoids, between ellipsoids and hyperplanes;
and projections onto given subspaces.

Ellipsoidal methods are used to compute forward and backward reach sets
of continuous- and discrete-time piecewise affine systems.
Forward and backward reach sets can be also computed for piece-wise linear
systems with disturbances.
It can be verified if computed reach sets intersect with given ellipsoids
and hyperplanes.

The toolbox provides efficient plotting routines for ellipsoids, hyperplanes
and reach sets.

Required software: MATLAB 2012a (or higher).





What's new
----------

04/17/2011: version 1.4 IN DEVELOPMENT
				

04/17/2011: version 1.1.3
            * Bug fixes.

06/06/2009: version 1.1.2
            * Bug fixes.

11/01/2008: Version 1.1.1
            * Bug fixes in distance and containment functions.
            * Updated manual.

12/10/2006: Version 1.1
            * New operations with ellipsoids.
            * Maxmin and minmax reach sets for discrete-time systems with
              disturbances.
            * Numerous bug fixes.

01/23/2006: Version 1.03
            * Proper documentation.
            * Minor bug fixes.

11/01/2005: Version 1.02
            * Added the interface to the Multi-Parametric Toolbox (MPT).
              The following functions now accept polytope object of MPT
              as parameter:
               - ellipsoid/distance,
               - ellipsoid/intersect,
               - reach/intersect,
               - ellipsoid/intersection_ea,
               - ellipsoid/intersection_ia,
               - ellipsoid/isinside.
              New functions are:
               - polytope2hyperplane - converts polytope object of MPT to array
                                       of hyperplanes,
               - hyperplane2polytope - converts array of hyperplanes into
                                       the polytope object.
            * New configuration parameter added to ellipsoids_init.m:
               - sdpsettings - settings used by YALMIP.

10/01/2005: Version 1.01
            * Fixed a bug in ellipsoid constructor which sometimes allowed
              nonsymmetric matrices.
            * Fixed minor bugs in ell_demo1 and ell_demo3.
            * Got rid of dependence on GLOPTIPOLY. Now we use YALMIP as 
              optimization package. YALMIP supports variety of solvers.
              Our default is SeDuMi, but the user can choose whatever
              he/she likes best.
              YALMIP is used in the following functions:
               - ellipsoid/intersect,
               - ellipsoid/isinside,
               - ellipsoid/intersection_ia.





Installation
------------

1. If you have a previous version of Ellipsoidal Toolbox installed,
   remove it completely.

2. Download the Ellipsoidal Toolbox.

3. Unzip the file 'ellipsoids_14.zip' or 'ellipsoids_14_lite.zip'
   into the directory where you want your toolbox to be.

4. Read the 'COPYRIGHT.txt' file.

5. In your MATLAB command window change the working directory to the one
   where you unzipped the distribution file and type:

    >> s_install

6. At this point, the directory tree of the Ellipsoidal Toolbox is added
   to the MATLAB path list. In order to save the updated path list,
   in your MATLAB window menu go to 'File' --> 'Set Path...' and click 'Save'.

7. All done. If you do not know what to do next, please, read the next section.





Quick start
-----------

Currently there is no proper documentation for the Ellipsoidal Toolbox.
To get an idea how to start using the toolbox after the installation,
in the MATLAB command window type:

 >> ell_demo1

This will produce a short tutorial-demo for the ellipsoidal calculus functions.

 >> ell_demo2

This demo explains how to plot ellipsoids and hyperplanes.

 >> ell_demo3

The third demo shows how to co compute forward and backward reach sets
for different types of linear systems.

To obtain a list of functions dealing with ellipsoids, type

 >> help ellipsoid/contents;

with hyperplanes, type:

 >> help hyperplane/contents;

with linear systems and reachability, type:

 >> help linsys/contents
and
 >> help reach/contents

For information about particular function, type:

 >> help _function_

Final remark.
Computation and plotting within the Ellipsoidal Toolbox use the parameters
described in the global structure 'ellOptions'. This structure is initialized
automatically when you start using the toolbox. To configure these parameters,
edit the file ~ellipsoids/ellipsoids_init.m, then in MATLAB command window
type:

 >> clear global ellOptions

in order for the changes to take effect.
Another way to modify these parameters, is to access the fields of 'ellOptions'
structure directly from your MATLAB program and/or MATLAB command line.





Known bugs and limitations
--------------------------

* Currently, there is no proper way of expressing empty reach sets that can
  occur in the reachability analysis of systems with disturbances.





Software used by Ellipsoidal Toolbox
------------------------------------

* YALMIP - high-level package for rapid optimization code development:
  control.ee.ethz.ch/~joloef/yalmip.php

* SeDuMi - SDP solver:
  sedumi.mcmaster.ca





Related links
-------------

* Multi-Parametric Toolbox (MPT):
  control.ee.ethz.ch/~mpt

* Ellipsoidal calculus based on propagation and fusion:
  www-iri.upc.es/people/ros/ellipsoids.html

* Geometric Bounding Toolbox (GBT):
  www.sysbrain.com/gbt

* Level Set Toolbox:
  www.cs.ubc.ca/~mitchell/ToolboxLS

* Polyhedral Hybrid Automaton Verifier (PHAVer):
  www.cs.ru.nl/~goranf

* CheckMate - hybrid system verification toolbox for MATLAB:
  www.ece.cmu.edu/~webk/checkmate





For questions and bug reports,
please, contact Alex Kurzhanskiy <alexk at lihodeev dot com>.
				Peter Gagarinov <pgagarinov at gmail dot com>


