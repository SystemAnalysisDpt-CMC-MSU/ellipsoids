function Y=plot(varargin)
%DOMAIN  Extract domain for PWA variable

% Author Johan L�fberg 
% $Id: domain.m,v 1.1 2006-08-10 18:00:19 joloef Exp $   

% Fast version for plotting simple PWA objects
if nargin == 1
    X = varargin{1};
    if isa(varargin{1},'sdpvar')
        if length(X) == 1
            if length(getvariables(X))==1
                extstruct = yalmip('extstruct',getvariables(X));
                if ~isempty(extstruct)
                    if isequal(extstruct.fcn,'pwa_yalmip') | isequal(extstruct.fcn,'pwq_yalmip')
                        Y = [];
                        for i = 1:length(extstruct.arg{1})
                            Y = [Y extstruct.arg{1}{i}.Pn];
                        end
                        return
                    end
                end
            end
        end
    end
end
error('DOMAIN can only be applied to simple MPT related PWA objects')