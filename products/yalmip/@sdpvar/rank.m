function varargout=rank(varargin)
%RANK (overloaded)

% Author Johan L�fberg
% $Id: rank.m,v 1.8 2007-08-02 19:17:36 joloef Exp $

% *************************************************************************
% This file defines a nonlinear operator for YALMIP
% Rank is a bit non-standard, so don't look here to learn
% % ***********************************************************************
switch class(varargin{1})

    case 'double' 
        % SHOULD NEVER HAPPEN, THIS SHOULD BE CAUGHT BY BUILT-IN
        error('Overloaded SDPVAR/RANK CALLED WITH DOUBLE. Report error')

    case 'sdpvar' 
        varargout{1} = yalmip('define',mfilename,varargin{1});

    case 'char'
        varargout{1} = set([]);
        properties = struct('convexity','none','monotonicity','none','definiteness','none','model','exact');
        varargout{2} = properties;
        varargout{3} = varargin{3};

    otherwise
        error('Strange type on first argument in SDPVAR/RANK');
end
