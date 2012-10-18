function output = calllmilab(interfacedata)

% Author Johan L�fberg
% $Id: calllmilab.m,v 1.4 2005-05-07 13:53:20 joloef Exp $

% Retrieve needed data
options = interfacedata.options;
F_struc = interfacedata.F_struc;
c       = interfacedata.c;
K       = interfacedata.K;
x0      = interfacedata.x0;
ub      = interfacedata.ub;
lb      = interfacedata.lb;

% Bounded variables converted to constraints
if ~isempty(ub)
    [F_struc,K] = addbounds(F_struc,K,ub,lb);
end

% Define lmilab variables (is this the way to do it?)
setlmis([])
for i = 1:length(c)
    [X,ndec,Xdec] = lmivar(2,[1 1]);
end
 
% Can't linear constraints be defined more easily?
lmicount = 1;
top = 1;
if K.l>0
    for i = 1:K.l
        lmiterm([-lmicount 1 1 0],F_struc(i,1));
        for j = 1:length(c)
            lmiterm([-lmicount 1 1 j],F_struc(i,j+1),1);
        end
        lmicount = lmicount+1;
    end
    top = top + K.l;
end

% The LMIs
if K.s(1)>0        
    for i = 1:length(K.s)
        n = K.s(i);
        lmiterm([-lmicount 1 1 0],full(reshape(F_struc(top:top+n^2-1,1),n,n)));
        for j = 1:length(c)
           lmiterm([-lmicount 1 1 j],full(reshape(F_struc(top:top+n^2-1,j+1),n,n)),1);
        end
        top = top+n^2;
        lmicount = lmicount+1;
    end
end
lmisys=getlmis;

% Convert options
ops = struct2cell(options.lmilab);ops = [ops{1:end}];
if options.verbose>0
    ops = [ops 0];
else
    ops = [ops 1];
end

if options.savedebug
    save lmilabdebug lmisys c ops
end

% Solve...
if options.showprogress;showprogress(['Calling ' interfacedata.solver.tag],options.showprogress);end
solvertime = clock; 
if nnz(c)==0
    [copt,x]=feasp(lmisys,ops);
else
    [copt,x]=mincx(lmisys,full(c),ops);
end
solvertime = etime(clock,solvertime);

% No status
if isempty(x)
    problem = 1;
    x = repmat(nan,length(c),1);
else
    problem = 0;
end
infostr = yalmiperror(problem,interfacedata.solver.tag);

% No duals...
D_struc = [];

if options.savesolveroutput
	solveroutput.copt = copt;
	solveroutput.x = x;
else
	solveroutput = [];
end

if options.savesolverinput
	solverinput.lmisys = lmisys;
	solverinput.c = c;
 	solverinput.ops = ops;
else
	solverinput = [];
end

% Standard interface 
output.Primal      = x;
output.Dual        = D_struc;
output.Slack       = [];
output.problem     = problem;
output.infostr     = infostr;
output.solverinput = solverinput;
output.solveroutput= solveroutput;
output.solvertime  = solvertime;