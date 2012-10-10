function start(dock)
% START executes the the graphical user interface of MLUNIT.
%
% Input:
%   regular:
%       dock: logical[1,1] - specifies if docked mode should be used
%
%  Example:
%         mlunit.start;    % Run in window mode
%         mlunit.start(true); % Run in docked mode
%
%  See also MLUNIT.GUI_TEST_RUNNER.RUN.

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

switch (nargin)
    case 0
        run(mlunit.gui_test_runner, '', 0);
    case 1
        run(mlunit.gui_test_runner, '', dock);
    otherwise
        % Do nothing
end;
