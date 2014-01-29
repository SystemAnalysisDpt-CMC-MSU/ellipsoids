% reach set from time 10 to 14 with the same dynamics
secRsObj = firstRsObj.evolve(14); 
% reach set from time 10 to 12 with new dynamics
secRsObj = firstRsObj.evolve(12, sys_t);  

% not only the dynamics, but the inputs can change as well,
% from time 12 to 13 disturbance is added to the system:

% sys_d - system with disturbance defined above
thirdRsObj = secRsObj.evolve(13, sys_d);  