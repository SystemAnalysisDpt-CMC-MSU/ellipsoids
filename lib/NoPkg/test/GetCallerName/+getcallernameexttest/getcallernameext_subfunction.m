function [methodName callerName]=getcallernameext_subfunction()
subfunction();

    function subfunction()
        [methodName callerName]=modgen.common.getcallernameext(1);
    end
end