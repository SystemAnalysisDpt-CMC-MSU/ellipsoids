classdef GetCallerNameExtTestClassB<handle
    
    properties (Access=private,Hidden)
        methodName
        className
    end
    
    methods
        function self=GetCallerNameExtTestClassB(varargin)
            [self.methodName self.className]=modgen.common.getcallernameext(1);
        end
        
        function [methodName className]=getCallerInfo(self)
            methodName=self.methodName;
            className=self.className;
        end
    end
    
    methods (Access=protected,Hidden)
        function setCallerInfo(self,methodName,className)
            self.className=className;
            self.methodName=methodName;
        end
    end
end