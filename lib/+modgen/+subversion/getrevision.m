function rev= getrevision(varargin)
rev=modgen.subversion.getrevisionbypath(fileparts(mfilename('fullpath')),varargin{:});
end