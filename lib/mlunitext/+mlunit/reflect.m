classdef reflect<handle
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
    
    properties (Access=private)
        metaClass
        shortClassName
        isMethodListCached=false
        methodNameList
    end
    
    methods
        function self = reflect(fullClassName)
            mc=meta.class.fromName(fullClassName);
            if isempty(mc)
                modgen.common.throwerror('noSuchClass',...
                    'No such class: %s', fullClassName);
            else
                self.metaClass=mc;
            end
            classNamePartList = regexp(fullClassName, '\.', 'split');
            self.shortClassName=classNamePartList{end};
        end
        %
        function methodNameList = get_methods(self)
            % GET_METHODS returns the list of methods of the
            %   'reflected' class.
            %
            %  Example:
            %         r = reflect('test_case');
            %         get_methods(r);           % Returns a cell array
            %                                   % with all methods of the
            %                                   % class test_case
            %
            %  See also MLUNIT.REFLECT.
            %
            if self.isMethodListCached
                methodNameList=self.methodNameList;
            else
                methodNameList={self.metaClass.MethodList.Name}.';
                methodNameList=unique(methodNameList);
                isConstrVec=cellfun(@(x)isequal(x,self.shortClassName),...
                    methodNameList);
                methodNameList=methodNameList(~isConstrVec);
                self.isMethodListCached=true;
                self.methodNameList=methodNameList;
            end
        end
        
        function isPositive = method_exists(self, methodName)
            % METHOD_EXISTS returns true, if a method with the name
            % method_name exists in the 'reflected' class.
            %
            % Input:
            %   regular:
            %       self:
            %       method_name: char[1,] - name of the method to check
            %
            % Example:
            %   r = reflect('test_case');
            %   method_exists(r, 'run');  % Return true
            %   method_exists(r, 'fail'); % Returns false
            %
            %  See also MLUNIT.REFLECT.
            import modgen.common.ismembercellstr;
            isPositive=any(cellfun(@(x)isequal(x,methodName),...
                self.get_methods()));
        end
    end
end