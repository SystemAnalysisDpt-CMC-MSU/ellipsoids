function [error, stacktrace] = parsemessage(error, stacktrace)
% PARSEERROR parses special errors to extract
% further information for the stacktrace.
%

if (~isempty(strfind(error, 'Unbalanced or misused parentheses or brackets.')) || ...
        ~isempty(strfind(error, 'Unbalanced or unexpected parenthesis or bracket.')))
    [tokens] = regexp(error, 'Error:.*File:\ ([\w\ \.,$&/\\:@]*.m)\ Line: (\w*)\ Column: (\w*).*', 'tokens', 'once');
    if (length(tokens) == 3)
        fullname = which(char(tokens(1)));
        if (~isempty(fullname))
            stacktrace = sprintf('\n  In %s at line %s%s', ...
                fullname, char(tokens(2)), ...
                stacktrace);
        else
            stacktrace = sprintf('\n  In %s at line %s%s', ...
                char(tokens(1)), char(tokens(2)), ...
                stacktrace);
        end;
        error = 'Unbalanced or misused parentheses or brackets.';
    end;
else
    [tokens] = regexp(error, 'Error using ==> <a href.*>(.*)</a>\n(.*)', 'tokens', 'once');
    if (length(tokens) == 2)
        error = char(tokens(2));
    end;
end;
end