firstHypObj = hyperplane([-1; 1]);
secHypObj = hyperplane([-1; 1; 8; -2; 3], 7);
thirdHypObj = hyperplane([1; 2; 0], -1);
hypVec = [firstHypObj secHypObj thirdHypObj];
dimsVec  = hypVec.dimension()

% dimsVec =
% 
%    2     5     3