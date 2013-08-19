function [errStr, StackVec] = parsemessage(errStr, StackVec)
% PARSEERROR parses special errors to extract
% further information for the stacktrace.
%
REF_AS_ERR_MSG_REG_EXP=['Error: <a.*opentoline\(''(.*)'',\d+,\d+\).*',...
    'File:\ ([\w\ \.,$&/\\:@]*.m)\ Line: (\w*)\ Column: (\w*)</a>\n*(.*)'];
%
tokens = regexp(errStr,REF_AS_ERR_MSG_REG_EXP,'tokens','once');
if ~isempty(tokens)
    fullFileName=tokens{1};
    shortFileName=tokens{2};
    lineNumber=tokens{3};
    errStr=tokens{5};
    StackEntry=struct('file',fullFileName,'name',shortFileName,...
        'line',str2double(lineNumber));
    StackVec=[StackEntry;StackVec];
else
    [tokens] = regexp(errStr,...
        'Error using ==> <a href.*>(.*)</a>\n(.*)', 'tokens', 'once');
    if (length(tokens) == 2)
        errStr = char(tokens(2));
    end
end