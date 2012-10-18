function y = blkdiag(varargin)
%BLKDIAG (overloaded)

% Author Johan L�fberg
% $Id: blkdiag.m,v 1.13 2010-01-13 13:49:20 joloef Exp $

if nargin<2
    y=varargin{1};
    return
end

keep = ones(1,length(varargin));
for i = 1:length(varargin)
    if isempty(varargin{i})
        keep(i) = 0;
    end
end
varargin = {varargin{find(keep)}};

% Get dimensions
n = zeros(length(varargin),1);
m = zeros(length(varargin),1);
isasdpvar = zeros(length(varargin),1);
%Symmetric = zeros(nargin,1);
for i = 1:length(varargin)
    if isa(varargin{i},'sdpvar')
        isasdpvar(i) = 1;
        n(i)=varargin{i}.dim(1);
        m(i)=varargin{i}.dim(2);
    else
        [n(i) m(i)] = size(varargin{i});
    end
end

% Find all free variables used
all_lmi_variables = [];
for i = 1:length(varargin)
    all_lmi_variables = [all_lmi_variables getvariables(varargin{i})];
end
all_lmi_variables = unique(all_lmi_variables);

% Create an SDPVAR
y=sdpvar(1,1,'rect',all_lmi_variables,[]);


% Some indexation tricks
msums = cumsum([0; m]);
nsums = cumsum([0; n]);
summ=sum(m);
sumn=sum(n);
indextable = reshape(1:sumn*summ,sumn,summ);

is = [];
js = [];
ss = [];
for j = 1:length(varargin)
    nnindex = indextable(1+nsums(j):nsums(j+1),1+msums(j):msums(j+1));
    if isasdpvar(j)
        this_uses = find(ismembc(all_lmi_variables,varargin{j}.lmi_variables));
        mindex = [1 this_uses+1];

        [a,b,d] = find(varargin{j}.basis');
        is = [is(:);reshape(mindex(a),[],1)];
        js = [js(:);reshape(nnindex(b),[],1)];
        ss = [ss(:);d(:)];
    else
        [a,b,d] = find( varargin{j}(:)');
        is = [is;ones(length(a),1)];
        js = [js;reshape(nnindex(b),[],1)];
        ss = [ss(:);d(:)];       
    end
end

y.basis = sparse(js,is,ss,sum(m)*sum(n),1+length(all_lmi_variables));
y.dim(1) = sumn;
y.dim(2) = summ;
% Reset info about conic terms
y.conicinfo = [0 0];

y = unfactor(y);
% Update the factors
doublehere = 0;
for i = 1:length(varargin)
    if isa(varargin{i},'sdpvar')
        if length(varargin{i}.leftfactors)==0
            y = flush(y);
            return
        end
        for j = 1:length(varargin{i}.leftfactors)
            y.rightfactors{end+1} = [zeros(size(varargin{i}.rightfactors{j},1),sum(m(1:1:i-1))) varargin{i}.rightfactors{j} zeros(size(varargin{i}.rightfactors{j},1),sum(m(i+1:1:end)))];
            y.leftfactors{end+1} = [zeros(sum(n(1:1:i-1)),size(varargin{i}.leftfactors{j},2)); varargin{i}.leftfactors{j}; zeros(sum(n(i+1:1:end)),size(varargin{i}.leftfactors{j},2))];
            y.midfactors{end+1} = varargin{i}.midfactors{j};
        end
    elseif isa(varargin{i},'double')       
        here = length(y.midfactors)+1;
        y.rightfactors{here} = [zeros(m(i),sum(m(1:1:i-1))) eye(m(i)) zeros(m(i),sum(m(i+1:1:end)))];
        y.leftfactors{here} = [zeros(sum(n(1:1:i-1)),size(varargin{i},1)); eye(size(varargin{i},1)); zeros(sum(n(i+1:1:end)),size(varargin{i},1))];
        y.midfactors{here}  = varargin{i};
    end
end
y = cleandoublefactors(y);


