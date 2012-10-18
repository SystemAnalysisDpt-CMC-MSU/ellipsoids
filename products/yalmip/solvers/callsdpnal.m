function output = callsdpnal(interfacedata)

% Author Johan L�fberg
% $Id: callsdpnal.m,v 1.21 2010-01-13 13:49:21 joloef Exp $ 

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

[blk,A,C,b,oldKs]=sedumi2sdpt3(F_struc(:,1),F_struc(:,2:end),c,K,options.sdpt3.smallblkdim);

if options.savedebug
    ops = options.sdpnal;
    save sdpnaldebug blk A C b ops -v6
end

if options.showprogress;showprogress(['Calling ' interfacedata.solver.tag],options.showprogress);end
solvertime = clock;
if options.verbose==0
   evalc('[obj,X,y,Z,info,runhist] =  sdpnal(blk,A,C,b,options.sdpnal);');
else
    [obj,X,y,Z,info,runhist] =  sdpnal(blk,A,C,b,options.sdpnal);            
end

% Create YALMIP dual variable and slack
Dual = [];
Slack = [];
top = 1;
if K.f>0
    Dual = [Dual;X{top}(:)];
    Slack = [Slack;Z{top}(:)];
    top = top+1;
end
if K.l>0
    Dual = [Dual;X{top}(:)];
    Slack = [Slack;Z{top}(:)];
    top = top + 1;
end
if K.q(1)>0
    Dual = [Dual;X{top}(:)];
    Slack = [Slack;Z{top}(:)];
    top = top + 1;
end
if K.s(1)>0  
    % Messy format in SDPT3 to block and sort small SDPs
    u = blk(:,1);
    u = find([u{:}]=='s');
    s = 1;
    for top = u
        ns = blk(top,2);ns = ns{1};
        k = 1;
        for i = 1:length(ns)
            Xi{oldKs(s)} = X{top}(k:k+ns(i)-1,k:k+ns(i)-1);
            Zi{oldKs(s)} = Z{top}(k:k+ns(i)-1,k:k+ns(i)-1);
            s = s + 1;                 
            k = k+ns(i);
        end
    end 
    for i = 1:length(Xi)
        Dual = [Dual;Xi{i}(:)];     
        Slack = [Slack;Zi{i}(:)];     
    end
end

solvertime = etime(clock,solvertime);
Primal = -y;  % Primal variable in YALMIP

% No error code available
switch info.termcode
    case -1
        problem = 4;
    case 0
        problem = 0;
    case 1
        problem = 5;
    case 2
        problem = 3;   
    otherwise
        problem = 11;
end
infostr = yalmiperror(problem,interfacedata.solver.tag);

if options.savesolveroutput
    solveroutput.obj = obj;
    solveroutput.X = X;
    solveroutput.y = y;
    solveroutput.Z = Z;
    solveroutput.info = info;
    solveroutput.runhist = runhist;
 else
    solveroutput = [];
end

if options.savesolverinput
    solverinput.blk = blk;
    solverinput.A   = A;
    solverinput.C   = C;
    solverinput.b   = b;
    solverinput.options   = options.sdpnal;
else
    solverinput = [];
end

% Standard interface 
output.Primal      = Primal;
output.Dual        = Dual;
output.Slack       = Slack;
output.problem     = problem;
output.infostr     = infostr;
output.solverinput = solverinput;
output.solveroutput= solveroutput;
output.solvertime  = solvertime;

function [F_struc,K] = deblock(F_struc,K);
X = any(F_struc(end-K.s(end)^2+1:end,:),2);
X = reshape(X,K.s(end),K.s(end));
[v,dummy,r,dummy2]=dmperm(X);
blks = diff(r);

lint = F_struc(1:end-K.s(end)^2,:);
logt = F_struc(end-K.s(end)^2+1:end,:);

newlogt = [];
for i = 1:size(logt,2)
    temp = reshape(logt(:,i),K.s(end),K.s(end));
    temp = temp(v,v);
    newlogt = [newlogt temp(:)];
end
logt = newlogt;

pattern = [];
for i = 1:length(blks)
    pattern = blkdiag(pattern,ones(blks(i)));
end

F_struc = [lint;logt(find(pattern),:)];
K.s(end) = [];
K.s = [K.s blks];
K.m = blks;
