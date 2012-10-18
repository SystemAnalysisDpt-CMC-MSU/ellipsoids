function F = shift(F,shifttol)
  
% Author Johan L�fberg 
% $Id: shift.m,v 1.4 2005-02-04 10:10:27 johanl Exp $
  
for i = 1:size(F.clauses,2)
    switch F.clauses{i}.type
    case {1,9}
        n = length(F.clauses{i}.data);
        if F.clauses{i}.strict
        F.clauses{i}.data = F.clauses{i}.data - speye(n)*shifttol;
        end
    case 2
        [n,m] = size(F.clauses{i}.data);
        if F.clauses{i}.strict
        F.clauses{i}.data = F.clauses{i}.data - ones(n,m)*shifttol;        
        end
    case 4
        n = length(F.clauses{i}.data);
        if F.clauses{i}.strict
        F.clauses{i}.data = F.clauses{i}.data - eye(n,1)*shifttol;        
        end
    otherwise
    end
end