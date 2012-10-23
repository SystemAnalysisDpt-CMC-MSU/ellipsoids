function subFunctionMethod(self)
subFunction();

    function subFunction()
        [methodName className]=modgen.common.getcallernameext(1);
        self.setCallerInfo(methodName,className);
    end
end