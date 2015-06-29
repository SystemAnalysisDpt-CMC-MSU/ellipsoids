function rev= getrevision(varargin)
rev=modgen.scm.subversion.getrevisionbypath(fileparts(mfilename('fullpath')),varargin{:});
end