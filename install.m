function install(root)
%
% Install Ellipsoidal Toolbox.
%

  fprintf('Installing Ellipsoidal Toolbox version 1.1.2 ...\n\n');

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
  adddir([root '/solvers/SeDuMi_1_1']);
  adddir([root '/solvers/SeDuMi_1_1/conversion']);
  adddir([root '/solvers/SeDuMi_1_1/doc']);
  adddir([root '/solvers/SeDuMi_1_1/examples']);
  adddir([root '/yalmip']);
  adddir([root '/yalmip/demos']);
  adddir([root '/yalmip/extras']);
  adddir([root '/yalmip/modules']);
  adddir([root '/yalmip/modules/global']);
  adddir([root '/yalmip/modules/moment']);
  adddir([root '/yalmip/modules/parametric']);
  adddir([root '/yalmip/modules/robust']);
  adddir([root '/yalmip/modules/sos']);
  adddir([root '/yalmip/operators']);
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
