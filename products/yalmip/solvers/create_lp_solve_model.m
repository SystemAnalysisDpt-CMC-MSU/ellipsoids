function lp = create_lp_solve_model(A,b,f,xint,LB,UB,e,options);

[m,n] = size(A);
lp = mxlpsolve('make_lp', m, n);

mxlpsolve('set_mat', lp, A);
mxlpsolve('set_rh_vec', lp, b);
mxlpsolve('set_obj_fn', lp, f);
mxlpsolve('set_maxim', lp); % default is solving minimum lp.
for i = 1:length(e)
    if e(i) < 0
        con_type = 1;
    elseif e(i) == 0
        con_type = 3;
    else
        con_type = 2;
    end
    mxlpsolve('set_constr_type', lp, i, con_type);
end
for i = 1:length(LB)
    %if ~isinf(LB(i))
        mxlpsolve('set_lowbo', lp, i, LB(i));    
    %end
end
for i = 1:length(UB)    
   if ~isinf(UB(i))
        mxlpsolve('set_upbo', lp, i, UB(i));    
   end
end
for i = 1:length(xint)
    mxlpsolve('set_int', lp, xint(i), 1);
end

if options.lpsolve.scalemode~=0
    mxlpsolve('set_scaling', lp, scalemode);
end

% for i = 1:length(sos)
%     mxlpsolve('add_SOS', lp, ['dummy' num2str(i)], 1, i, sos{i}, 1:length(sos{i}));
% end


switch options.verbose
    case 0
        mxlpsolve('set_verbose', lp, 0);%options.verbose)
    case 1
        mxlpsolve('set_verbose', lp, 4);%options.verbose)
    case 2
        mxlpsolve('set_verbose', lp, 5);%options.verbose)
    otherwise
        mxlpsolve('set_verbose', lp, 6);%options.verbose)
end
