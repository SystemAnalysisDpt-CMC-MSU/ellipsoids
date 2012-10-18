function varargout = gammainc(varargin)
%GAMMAINC (overloaded)

% Author Johan L�fberg
% $Id: gammainc.m,v 1.8 2007-08-02 18:16:26 joloef Exp $

if nargin ~= 2
    error('Not enough input arguments.');
end

switch class(varargin{1})
    case 'double'
        
        if isa(varargin{2},'sdpvar')
            varargout{1} = InstantiateElementWise('gammainc_a',varargin{2:-1:1});
        else
            error('gammainc only supported for one SDPVAR arguments')
        end
        
    case 'sdpvar'
        
        if isa(varargin{2},'double')
            if varargin{2}<0
                error('A must be real and non-negative');
            end
            varargout{1} = InstantiateElementWise('gammainc_x',varargin{:});       
        else
            error('gammainc only supported for one SDPVAR arguments')
        end
            
    otherwise
        error('SDPVAR/GAMMAINC called with strange argument?');
end