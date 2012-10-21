function simpleMethod(self)
[methodName className]=modgen.common.getcallernameext(1);
self.setCallerInfo(methodName,className);