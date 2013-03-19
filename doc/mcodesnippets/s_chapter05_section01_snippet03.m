A = [0 1; -2 0]; b = [3; 0];  % A - 2x2 real matrix, b - vector in R^2
AT = A * EE(:, 2) + b;  % affine transformation of ellipsoids 
                            %in the second column of EE
