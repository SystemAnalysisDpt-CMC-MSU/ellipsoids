function obj=subFunctionMethod(obj)
subFunction();

    function subFunction()
        [methodName className]=modgen.common.getcallernameext(1);
        obj=setCallerInfo(obj,methodName,className);
    end
end