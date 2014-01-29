function obj=simpleMethod(obj)
[methodName className]=modgen.common.getcallernameext(1);
obj=setCallerInfo(obj,methodName,className);