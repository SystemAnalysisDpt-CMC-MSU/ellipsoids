function [errStr, StackVec] = parsemessage(errStr, StackVec)
% PARSEERROR parses special errors to extract
% further information for the stacktrace.
%

if (~isempty(strfind(errStr,...
        'Unbalanced or misused parentheses or brackets.')) || ...
        ~isempty(strfind(errStr,...
        'Unbalanced or unexpected parenthesis or bracket.')))
    [tokens] = regexp(errStr,...
        'Error:.*opentoline\(''(.*)'',\d+,\d+\).*File:\ ([\w\ \.,$&/\\:@]*.m)\ Line: (\w*)\ Column: (\w*).*',...
        'tokens','once');
    fullFileName=tokens{1};
    shortFileName=tokens{2};
    lineNumber=tokens{3};
    errStr = 'Unbalanced or misused parentheses or brackets.';
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