function X = sdpvar(F)

if isa(F.clauses{1}.data,'double')
    X = F.clauses{1}.data;
else
    X = [];
    for i = 1:size(F.clauses,2)
       
        Xi = F.clauses{i}.data;
       
        if size(F.clauses,2)>1
        if isempty(X)
            X = reshape(Xi,[],1);
        else
            X = [X;reshape(Xi,[],1)];
        end
        else
            X = Xi;
        end
       
    end
end

X = sethackflag(X,0);