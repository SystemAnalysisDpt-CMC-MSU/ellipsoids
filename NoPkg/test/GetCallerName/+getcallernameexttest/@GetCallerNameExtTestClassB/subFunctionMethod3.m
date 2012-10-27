function subFunctionMethod3(self)
subFunction(self);
end

function subFunction(self)
    subFunction2();

    function subFunction2()
        [methodName className]=modgen.common.getcallernameext(1);
        self.setCallerInfo(methodName,className);
    end
end