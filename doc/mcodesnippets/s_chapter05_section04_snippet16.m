% reach set from time 10 to 15 with the same dynamics
secRsObj = firstRsObj.evolve(15); 
% reach set from time 10 to 15 with new dynamics
secRsObj = firstRsObj.evolve(15, sys_t);  

% not only the dynamics, but the inputs can change as well,
% from time 15 to 20 disturbance is added to the system:

% sys_d - system with disturbance defined above
thirdRsObj = secRsObj.evolve(20, sys_d);  