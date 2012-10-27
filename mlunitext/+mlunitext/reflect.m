classdef reflect<mlunit.reflect
    % REFLECT class.
    % The class reflect helps to find out which methods to a class belong.
    % In fact it is simply a wrapper for the Matlab methods function,
    % providing a method checking whether a method within a class exists
    % or not, and a method returning all methods of a class as a cell
    % array.
    %
    % Example:
    %     r = reflect('test_case');
    %     method_exists(r, 'run');  % Return true
    %     method_exists(r, 'fail'); % Returns false
    %     get_methods(r);           % Returns a cell array with all
    %                               % methods of the class test_case
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    methods
        function self = reflect(varargin)
            self=self@mlunit.reflect(varargin{:});
        end
    end
end