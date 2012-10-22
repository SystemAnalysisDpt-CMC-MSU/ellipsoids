function subFunctionMethod2(self)
subFunction(self);
end

function subFunction(self)
[methodName className]=modgen.common.getcallernameext(1);
self.setCallerInfo(methodName,className);
end