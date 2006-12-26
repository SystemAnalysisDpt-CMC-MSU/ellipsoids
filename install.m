function install(root)
%
% Install Ellipsoidal Toolbox.
%

  fprintf('Installing Ellipsoidal Toolbox version 1.1 ...\n\n');

  if ~exist('root', 'var')
    root = pwd;
  end

  adddir([root]);
  adddir([root '/auxiliary']);
  adddir([root '/control']);
  adddir([root '/control/auxiliary']);
  adddir([root '/demo']);
  adddir([root '/graphics']);
  adddir([root '/solvers']);
  adddir([root '/solvers/gradient']);
  adddir([root '/solvers/SeDuMi105']);
  adddir([root '/solvers/SeDuMi105/conversion']);
  adddir([root '/yalmip']);
  adddir([root '/yalmip/demos']);
  adddir([root '/yalmip/extras']);
  adddir([root '/yalmip/solvers']);
  
  fprintf('To finish the installation, go to ''File'' --> ''Set Path...'' and click ''Save''.\n\n');

  return;



  

%%%%%%%%

function adddir(directory)

  if isempty(dir(directory))
    error(['Directory ' directory ' not found!']);
  else
    addpath(directory);
  end

  return;
