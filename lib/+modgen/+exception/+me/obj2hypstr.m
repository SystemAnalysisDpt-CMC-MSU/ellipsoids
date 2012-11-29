function errMsg=obj2hypstr(meObj,varargin)
%OBJ2HYPSTR does the same as OBJ2PLAINSTR but WITH the hyper-references
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-11-28 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
[message,stacktrace]=modgen.exception.me.obj2str(meObj);
%
stacktrace = sprintf('%s\n', stacktrace);
errMsg=['Traceback (most recent call first): ', ...
    stacktrace, ...,
    'Error: ', ...
    message ', Identifier: ',meObj.identifier];
