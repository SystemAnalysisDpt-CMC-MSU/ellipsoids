ellipsoids
==========
**Ellipsoidal Toolbox (ET)** is a standalone set of easy-to-use configurable MATLAB routines and classes to perform 
operations with ellipsoids and hyperplanes of arbitrary dimensions. It computes the external and internal 
ellipsoidal approximations of geometric (Minkowski) sums and differences of ellipsoids, intersections of 
ellipsoids and intersections of ellipsoids with halfspaces and polytopes; distances between ellipsoids, 
between ellipsoids and hyperplanes, between ellipsoids and polytopes; and projections onto given subspaces.

Ellipsoidal methods are used to compute forward and backward reach sets of continuous- and discrete-time 
piecewise affine systems. Forward and backward reach sets can be also computed for piecewise linear systems 
ith disturbances. It can be verified if computed reach sets intersect with given ellipsoids, hyperplanes, 
or polytopes. 

Getting Started with Ellipsoidal Toolbox
------------------------------

### Prerequisites

You're going to need:

- **Matlab, version 2015b or newer** — older versions may work, but are unsupported. Ellipsoidal toolbox has 100% compatibility with Linux, Windows and Mac OS X (tested on Linux Mint 17.3 "Rosa", Windows 10, macOS Sierra 10.12.6, macOS High Sierra 10.13.1).

Also the following toolboxes are required:

- **Matlab Optimization Toolbox**. This toolbox is used by MPT (see below) for solving the quadratic programming problems.
- **Matlab Curve Fitting Toolbox**
- **CVX 2.1 build 1116** and **MPT 3.1.2**. No need to download these toolboxes manually, just let the installation script to download them.

**For more information please refer to [Ellipsoidal Toolbox website](http://systemanalysisdpt-cmc-msu.github.io/ellipsoids)**

Getting Set Up
------------------------------

- Fork this repository on Github.
- Clone *your forked repository* (not our original one) to your hard drive with 

```shell
git clone https://github.com/YOURUSERNAME/ellipsoids.git
```

- Run the suitable script related to your OS version and Matlab version. This will:
   * start Matlab
   * automatically download CVX and MPT
   * add all necessary files to Matlab path and configure CVX and MPT
   * add a few entries to javaclasspath.txt file located in "install" subfolder. Jar files with java classes need to be on static class path. Static java class path can only be loaded once when Matlab starts. Thus Matlab needs to be closed and the suitable script needs to be ran again. This needs to be done only once.
   * Close Matlab and start suitable script again. This needs to be done only once.
   * Run `elltool.test.run_tests` to make sure that everything works. All tests should pass.




Contact/Support
------------------------------

-   Found *ET* useful for something?
-   Found a bug and wish to report it?
-   Have questions, suggestions or feature requests?
-   Wish to contribute to the *ET* development? 

Please, contact [Peter Gagarinov](https://github.com/pgagarinov), [Alex Kurzhanskiy](http://lihodeev.com) or [report an issue](https://github.com/SystemAnalysisDpt-CMC-MSU/ellipsoids/issues).


