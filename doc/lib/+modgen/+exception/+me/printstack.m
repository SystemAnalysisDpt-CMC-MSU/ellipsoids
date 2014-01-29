function stackTraceStr = printstack(StackVec,varargin)
% PRINTSTACK returns a string representation of the stack trace object
% returned by dbstack
%
% Input:
%   regular:
%     stackTrace: struct [n,1] - structure array returned by dbstack
%   properties:
%     useHyperlink: logical [1,1] - print hyperlinks suitable for Matlab
%       screen output. Default = true.
%     prefixStr: char [1,n] - prefix to put at the beginning of each line
%       of the stack trace. Default = ''.
% Output:
%   regular:
%     stackTraceStr: char [m,n] - string representation of the stack trace
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

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
for i = 1:size(StackVec, 1)
    linktext=sprintf('in %s at line %d',StackVec(i).file,...
        StackVec(i).line);
    if useHyperlink
        stackTraceStr = [stackTraceStr, sprintf('\n'), prefixStr, ...
            ['<a href="error:' StackVec(i).file ','...
            num2str(StackVec(i).line) ',' 1, '">' linktext '</a>']];
    else
        stackTraceStr = [stackTraceStr, sprintf('\n'),...
            prefixStr, linktext];
    end
end