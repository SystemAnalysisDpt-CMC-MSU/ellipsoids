function resultVec = run_tests(varargin)
resultList{2}=elltool.control.test.run_disc_tests(varargin{:});
%resultList{1}=elltool.control.test.run_cont_tests(varargin{:});
resultVec=[resultList{:}];