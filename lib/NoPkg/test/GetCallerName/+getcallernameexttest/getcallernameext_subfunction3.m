function [methodName callerName]=getcallernameext_subfunction3()
[methodName callerName]=subfunction();
end

function [methodName callerName]=subfunction()
subfunction2();

    function subfunction2()
        [methodName callerName]=modgen.common.getcallernameext(1);
    end
end