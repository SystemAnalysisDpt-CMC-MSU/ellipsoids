function [message,stacktrace]=obj2str(err,varargin)
% OBJ2STR returns string representations of an MException object
%
% input:
%   regular:
%     err: MException [1,1]
%   properties:
%     useHyperlink: logical [1,1] - print hyperlinks suitable for Matlab
%       screen output. Default = true.
%     prefixStr: char [1,n] - prefix to put at the beginning of each line
%       of the stack trace. Default = ''.
% output:
%   regular:
%     message: char [1,n] - error message
%     stacktrace: char [m,n] - string representation of the stack trace
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%


[message, Stack] = modgen.exception.me.parsemessage(err.message, err.stack);
stacktrace = modgen.exception.me.printstack(Stack,varargin{:});
stacktrace = sprintf('%s\n', stacktrace);
nCause=length(err.cause);
for iCause=1:nCause
    [messageCause,stacktraceCause]=modgen.exception.me.obj2str(err.cause{iCause},varargin{:});
    message=[message,sprintf('\n\tCause(%d): %s',iCause,messageCause)];
    stacktrace=[stacktrace,sprintf('\tCause(%d): %s',iCause,stacktraceCause)];
end