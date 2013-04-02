rs2 = evolve(rs, 15);  % reach set from time 10 to 15 with the same dynamics
rs2 = evolve(rs, 15, sys_t);  % reach set from time 10 to 15 with new dynamics

% not only the dynamics, but the inputs can change as well,
% from time 15 to 20 disturbance is added to the system:
rs3 = evolve(rs2, 20, sys_d);  % sys_d - system with disturbance defined above
