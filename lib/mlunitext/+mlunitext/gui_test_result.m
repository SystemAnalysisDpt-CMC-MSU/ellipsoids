classdef gui_test_result < mlunit.gui_test_result
    % GUI_TEST_RESULT CLASS.
    % The class gui_test_result is inherited from test_result and shows
    % the test results and the progress at the mlUnit gui. Normally an
    % instance of the class is only created by gui_test_runner, but not
    % by the user.
    %
    %  Example:
    %    A gui_test_result is created in gui_test_runner/gui:
    %         result = gui_test_result(handles.gui_progress_bar, ...
    %             handles.gui_text_runs, ...
    %             handles.gui_error_list, ...
    %             0);
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    methods
        function self = gui_test_result(varargin)
            % GUI_TEST_RESULT creates an object of the class
            %   gui_test_result with the following parameters:
            % 
            % Input:
            %   regular:
            %       progress_bar: handle[1,1] - handle of the progess bar.
            %       text_runs: handle[1,1] - handle of the text area, which 
            %           shows the
            %           number of test ran, errors and failures.
            %       error_listbox: handle[1,1] -handle of the listbox, 
            %           which contains the
            %                   list of all errors and failures.
            %       max_number_of_tests: double[1,1] - the number of tests.
            %
            %  Example:
            %    A gui_test_result is created in gui_test_runner/gui:
            %         result = gui_test_result(handles.gui_progress_bar, ...
            %             handles.gui_text_runs, ...
            %             handles.gui_error_list, ...
            %             0);
            
            self = self@mlunit.gui_test_result(varargin{:});
        end

end