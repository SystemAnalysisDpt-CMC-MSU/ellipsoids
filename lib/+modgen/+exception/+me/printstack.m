function stackTraceStr = printstack(strackTrace,varargin)
% PRINTSTACK returns a string representation of the stack trace object
% returned by dbstack
%
% input:
%   regular:
%     stackTrace: struct [n,1] - structure array returned by dbstack
%   properties:
%     useHyperlink: logical [1,1] - print hyperlinks suitable for Matlab
%       screen output. Default = true.
%     prefixStr: char [1,n] - prefix to put at the beginning of each line
%       of the stack trace. Default = ''.
% output:
%   regular:
%     stackTraceStr: char [m,n] - string representation of the stack trace
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 12-October-2012, <pgagarinov@gmail.com>$

useHyperlink = true;
prefixStr = sprintf('');
[~,prop]=parseparams(varargin);
nProp=length(prop);
for k=1:2:nProp
    switch lower(prop{k})
        case 'usehyperlink',
            useHyperlink=prop{k+1};
        case 'prefixstr',
            prefixStr=prop{k+1};
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'unknown property %s',prop{k});
    end
end
%
stackTraceStr = '';
for i = 1:size(strackTrace, 1)
    linktext=sprintf('in %s at line %d',strackTrace(i).file,strackTrace(i).line);
    if useHyperlink
        stackTraceStr = [stackTraceStr, sprintf('\n'), prefixStr, ...
           ['<a href="error:' strackTrace(i).file ',' num2str(strackTrace(i).line) ',' 1, '">' linktext '</a>']];
    else
        stackTraceStr = [stackTraceStr, sprintf('\n'), prefixStr, linktext];
    end
end