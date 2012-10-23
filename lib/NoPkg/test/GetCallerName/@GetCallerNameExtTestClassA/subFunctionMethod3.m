function obj=subFunctionMethod3(obj)
obj=subFunction(obj);
end

function obj=subFunction(obj)
    subFunction2();

    function subFunction2()
        [methodName className]=modgen.common.getcallernameext(1);
        obj=setCallerInfo(obj,methodName,className);
    end
end