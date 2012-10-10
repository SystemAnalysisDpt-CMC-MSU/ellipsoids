classdef gui_test_result < mlunit.test_result
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
    
    properties
        progress_bar
        text_runs
        error_listbox
        max_number_of_tests
    end
    
    methods
        function self = gui_test_result(progress_bar, ...
                text_runs, error_listbox, max_number_of_tests)
            %gui_test_result contructor.
            %
            %  The constructor creates an object of the class
            %  gui_test_result with the following parameters:
            %    progress_bar: handle of the progess bar.
            %    text_runs: handle of the text area, which shows the
            %               number of test ran, errors and failures.
            %    error_listbox: handle of the listbox, which contains the
            %                   list of all errors and failures.
            %    max_number_of_tests: the number of tests.
            %
            %  Example:
            %    A gui_test_result is created in gui_test_runner/gui:
            %         result = gui_test_result(handles.gui_progress_bar, ...
            %             handles.gui_text_runs, ...
            %             handles.gui_error_list, ...
            %             0);
            
            self = self@mlunit.test_result();
            self.progress_bar = progress_bar;
            self.text_runs = text_runs;
            self.error_listbox = error_listbox;
            self.max_number_of_tests = max_number_of_tests;
            
            reset_progress_bar(self);
            reset_texts(self);
        end
        
        function self = add_error(self, test, error)
            %gui_test_result.add_error calls the inherited method from
            %test_result and the update method, which updates the
            %different gui objects.
            %
            %  Example:
            %    add_error is usually only called by the run method of
            %    test_case, see test_case.run:
            %         result = add_error(result, self, stacktrace);
            %
            %  See also MLUNIT.TEST_RESULT.ADD_ERROR,
            %           MLUNIT.TEST_CASE.RUN.
            
            self = add_error@mlunit.test_result(self, test, error);
            self = update(self);
        end
        
        function self = add_failure(self, test, failure)
            %gui_test_result.add_failure calls the inherited method from
            %test_result and the update method, which updates the different
            %gui objects.
            %
            %  Example:
            %    add_failure is usually only called by the run method of
            %    test_case, see test_case.run:
            %         result = add_failure(result, self, errmsg);
            %
            %  See also MLUNIT.TEST_RESULT.ADD_FAILURE,
            %           MLUNIT.TEST_CASE.RUN.
            
            self = add_failure@mlunit.test_result(self, test, failure);
            self = update(self);
        end
        
        function self = add_success(self, test)
            %gui_test_result.add_success calls the inherited method from
            %test_result and the update method, which updates the
            %different gui objects.
            %
            %  Example:
            %    add_success is usually only called by the run method of
            %    test_case, see test_case.run:
            %         result = add_success(result, self);
            %
            %  See also MLUNIT.TEST_RESULT.ADD_SUCCESS,
            %           MLUNIT.TEST_CASE.RUN.
            
            self = add_success@mlunit.test_result(self, test);
            self = update(self);
        end
        
        function description = get_description(self, test) %#ok
            %gui_test_result.get_description returns the name of the test.
            %
            %  Example:
            %    get_description is called by print_error_list to get the
            %    name of the test, in which an error or failure occured.
            %    See gui_test_result.print_error_list:
            %         get_description(self, errors{i, 1})
            %
            %  See also MLUNIT.GUI_TEST_RESULT.PRINT_ERROR_LIST.
            
            description = str(test);
        end
        
        function print_error_list(self, prefix, errors, reset_list)
            %gui_test_result.print_error_list is a helper function for
            %gui_test_result.print_errors.
            %  It iterates through all errors in errors, creates a cell
            %  array containing the error title and a cell array
            %  containing the description. The first is saved as String,
            %  the second as UserData of the listbox, which is shown when
            %  selecting an error.
            %
            %  Example:
            %    print_error_list is called twice in
            %    gui_test_result.print_errors, e.g. for the list of
            %    failures:
            %         print_error_list(self, 'FAILURE', get_failure_list(self));
            %
            %  See also MLUNIT.GUI_TEST_RESULT.PRINT_ERRORS.
            
            if (nargin == 3)
                reset_list = 0;
            end;
            
            list = get(self.error_listbox, 'String');
            data = get(self.error_listbox, 'UserData');
            if ((isempty(list)) || (reset_list == 1))
                list = cell(0);
                data = cell(0);
            end;
            
            for i = 1:size(errors, 1)
                idx = length(list) + 1;
                list{idx} = sprintf('%s: %s', ...
                    prefix, ...
                    errors{i, 1});
                data{idx} = errors{i, 2};
            end;
            
            set(self.error_listbox, 'String', list);
            set(self.error_listbox, 'UserData', data);
            set(self.error_listbox, 'Value', 1);
        end
        
        function print_errors(self)
            %gui_test_result.print_errors creates the list and description
            %of all errors and failures and set them to the listbox of
            %errors and failures.
            %
            %  Example:
            %    print_errors is called for example from
            %    gui_test_result.update:
            %         print_errors(self);
            %
            %  See also MLUNIT.GUI_TEST_RESULT.UPDATE.
            
            print_error_list(self, 'ERROR', get_error_list(self), 1);
            print_error_list(self, 'FAIL', get_failure_list(self));
        end
        
        function update_progress_bar(self)
            %gui_test_result.update_progres_bar updates the progress bar
            %of the mlUnit gui.
            %  The length of the progress bar is defined through the number
            %  of tests and with each executed tests the progress is
            %  increased.
            %
            %  Example:
            %    update_progress_bar is called from gui_test_result.update:
            %         update_progress_bar(self);
            %
            %  See also MLUNIT.GUI_TEST_RESULT.UPDATE.
            
            runs = get_tests_run(self);
            axes(self.progress_bar);
            if ((get_errors(self) > 0) || (get_failures(self) > 0))
                barh(1, runs, 'FaceColor', [1 0 0]);
            else
                barh(1, runs, 'FaceColor', [0 1 0]);
            end;
            
            set(self.progress_bar, 'XLim', [0 self.max_number_of_tests]);
            set(self.progress_bar, 'YLim', [0.6 1.4]);
            set(self.progress_bar, 'XTick', [], 'XTickLabel', []);
            set(self.progress_bar, 'YTick', [], 'YTickLabel', []);
        end
        
        function reset_progress_bar(self)
            %gui_test_result.reset_progress_bar resets the progress bar.
            %
            %  Example:
            %    reset_progress_bar is called for example from the
            %    constructor of gui_test_result:
            %         reset_progress_bar(self);
            %
            %  See also MLUNIT.GUI_TEST_RESULT.GUI_TEST_RESULT.
            
            barh(1, 1, 'FaceColor', [1 1 1]);
            set(self.progress_bar, 'XLim', [0 1]);
            set(self.progress_bar, 'YLim', [0.6 1.4]);
            set(self.progress_bar, 'XTick', [], 'XTickLabel', []);
            set(self.progress_bar, 'YTick', [], 'YTickLabel', []);
            drawnow;
        end
        
        function reset_texts(self)
            %gui_test_result.reset_texts resets the text area.
            %
            %  Example:
            %    reset_texts is called for example from the constructor of
            %    gui_test_result:
            %         reset_texts(self);
            %
            %  See also MLUNIT.GUI_TEST_RESULT.GUI_TEST_RESULT.
            
            set(self.text_runs, 'String', ['Runs: 0', ...
                ' / Errors: 0', ...
                ' / Failures: 0']);
        end
        
        function texts(self)
            %gui_test_result.texts creates the text area with the number
            %of tests ran, the number of errors and the number of failures.
            %
            %  Example:
            %    texts is called for example from gui_test_result.update:
            %         texts(self);
            %
            %  See also MLUNIT.GUI_TEST_RESULT.UPDATE.
            
            set(self.text_runs, 'String', ...
                ['Runs: ', num2str(get_tests_run(self)), ...
                ' / Errors: ', num2str(get_errors(self)), ...
                ' / Failures: ', num2str(get_failures(self))]);
        end
        
        function self = update(self)
            %gui_test_result.update update the different gui object: the
            %progress bar, the text area with the number of test ran etc.,
            %and the listbox with all errors and failures.
            %
            %  Example:
            %    update is called after the adding of each error, failure
            %    or success in add_error, etc:
            %         self = update(self);
            %
            %  See also MLUNIT.GUI_TEST_RESULT.ADD_ERROR,
            %           MLUNIT.GUI_TEST_RESULT.ADD_FAILURE,
            %           MLUNIT.GUI_TEST_RESULT.ADD_SUCCESS.
            
            update_progress_bar(self);
            texts(self);
            print_errors(self);
            drawnow;
        end
    end
end