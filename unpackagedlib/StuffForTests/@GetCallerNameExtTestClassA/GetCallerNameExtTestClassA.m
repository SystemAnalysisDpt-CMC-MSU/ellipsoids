function obj=GetCallerExtTestClassA(varargin)

obj=struct;
[obj.methodName obj.className]=modgen.common.getcallernameext(1);
obj=class(obj,'GetCallerNameExtTestClassA');