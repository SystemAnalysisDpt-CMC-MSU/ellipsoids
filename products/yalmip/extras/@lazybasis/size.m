function varargout=size(varargin)
%SIZE (overloaded)

% Author Johan L�fberg 
% $Id: size.m,v 1.1 2005-10-12 16:05:54 joloef Exp $   

if nargin == 1    
  bsize  = [varargin{1}.n varargin{1}.m];
  switch (nargout)
  case 0
    varargout{1} = bsize;
  case 1
    varargout{1} = bsize;
  case 2
    varargout{1} = bsize(1);
    varargout{2} = bsize(2);
  otherwise
    error('>2 outputs in size?');
  end
else
	switch varargin{2}
	case 1
		varargout{1} = varargin{1}.n;
	case 2
		varargout{1} = varargin{1}.m;
	otherwise
		error('Report bug in size')
	end
end
