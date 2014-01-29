classdef GetCallerNameExtTestClassC<GetCallerNameExtTestClassB
    methods
        function self=GetCallerNameExtTestClassC(isParent,varargin)
            if nargin==0,
                isParent=true;
            end
            self=self@GetCallerNameExtTestClassB(varargin{:});
            if ~isParent,
                [methodName className]=modgen.common.getcallernameext(1);
                self.setCallerInfo(methodName,className);
            end
        end
        
        function simpleMethod(self)
            [methodName className]=modgen.common.getcallernameext(1);
            self.setCallerInfo(methodName,className);
        end
        
        function subFunctionMethod(self)
            subFunction();
            
            function subFunction()
                [methodName className]=modgen.common.getcallernameext(1);
                self.setCallerInfo(methodName,className);
            end
        end
        
        function subFunctionMethod3(self)
            subFunction();
            
            function subFunction()
                subFunction2();
                
                function subFunction2()
                    [methodName className]=modgen.common.getcallernameext(1);
                    self.setCallerInfo(methodName,className);
                end
            end
        end
    end
end