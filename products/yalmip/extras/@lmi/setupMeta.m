function F = setupMeta(F,operator,varargin)

F.clauses{1}.type = 56;
F.clauses{1}.data = {operator, varargin{:}};
F.LMIid = yalmip('lmiid');
