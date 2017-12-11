%%
%LMI-based three-vehicle platoon

%system parameters
%elltool.setconf('default');
elltool.conf.Properties.setNTimeGridPoints(150);
%elltool.conf.Properties.setRelTol(1e-3);

%initial conditions(1)

% define system 1

%In case of no communication problems, these matrices are given as follows
firstAMat = [     0      1      0        0      0       0       0      0       0
                  0      0      -1       0      0       0       0      0       0
             1.6050 4.8680 -3.5754 -0.8198 0.4270 -0.0450 -0.1942 0.3626 -0.0946
                  0      0       0       0      1       0       0      0       0
                  0      0       1       0      0      -1       0      0       0
             0.8718 3.8140 -0.0754  1.1936 3.6258 -3.2396 -0.5950 0.1294 -0.0796
                  0      0       0       0      0       0       0      1       0
                  0      0       0       0      0       1       0      0      -1
             0.7132 3.5730 -0.0964  0.8472 3.2568 -0.0876  1.2726 3.0720 -3.1356];
         
       
firstBMat = [0 1 0 0 0 0 0 0 0]';

%if we want to specify the interval [a, b]
%for control constraints a_L

a = 2;
b = 9;

firstUBoundsEllObj = ellipsoid((b+a)/2,(b-a)/2);

% define system 2

%In case of total disruption of the communication, the matrices describing
%the system are given by
secAMat = [    0 1.0000       0       0      0       0       0      0       0
               0      0 -1.0000       0      0       0       0      0       0
          1.6050 4.8680 -3.5754       0      0       0       0      0       0
               0      0       0       0 1.0000       0       0      0       0
               0      0  1.0000       0      0 -1.0000       0      0       0
               0      0       0  1.1936 3.6258 -3.2396       0      0       0 
               0      0       0       0      0       0       0 1.0000       0
               0      0       0       0      0  1.0000       0      0 -1.0000
          0.7132 3.5730 -0.0964  0.8472 3.2568 -0.0876  1.2726 3.0720 -3.1356];
      

secBMat = [0 1 0 0 0 0 0 0 0]';

%if we want to specify the interval [a, b]
%for control constraints a_L

secUBoundsEllObj = ellipsoid((b+a)/2,(b-a)/2);

%time options

% time horizon T after which the controlled system reaches a stable state

T = 2.5;


%switching time from the first discrete state

switchTimeFirst = 0.1;
switchTimeSec = 1;

%e_i options
e_1 = 0;
e_2 = 0;
e_3 = 0;

%vector that shows that we start without collisions
% set of initial conditions

 VecIn = [2 0 0 2 0 0 2 0 0];
