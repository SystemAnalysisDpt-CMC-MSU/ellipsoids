function  varargout = yalmip(varargin)
%YALMIP Returns various information about YALMIP
%
%   YALMIP can be used to check version numbers and
%   find the SDPVAR and SET objects available in workspace
%
%   EXAMPLES
%    V = YALMIP('version')     % Returns version
%    YALMIP('nvars')           % Returns total number of declared variables
%    YALMIP('info')            % Display basic info.
%    YALMIP('solver','tag')    % Sets the solver 'solvertag' (see sdpsettings) as default solver
%
%
% If you want information on how to use YALMIP, you are advised to check out
% http://users.isy.liu.se/johanl/yalmip/
%
%   See also YALMIPTEST, YALMIPDEMO

% Author Johan L�fberg

persistent prefered_solver internal_sdpvarstate internal_setstate

if nargin==0
    help yalmip
    return
end

if isempty(internal_sdpvarstate)
    internal_sdpvarstate.monomtable = spalloc(0,0,0);   % Polynomial powers table
    internal_sdpvarstate.hashedmonomtable = [];         % Hashed polynomial powers table
    internal_sdpvarstate.hash = [];
    internal_sdpvarstate.boundlist = [];
    internal_sdpvarstate.variabletype = spalloc(0,0,0); % Pre-calc linear/quadratic/polynomial/sigmonial
    internal_sdpvarstate.intVariables = [];   % ID of integer variables
    internal_sdpvarstate.binVariables = [];   % ID of binary variables
    internal_sdpvarstate.semicontVariables = [];
    internal_sdpvarstate.uncVariables = [];   % ID of uncertain variables (not used)
    internal_sdpvarstate.parVariables = [];   % ID of parametric variables (not used)
    internal_sdpvarstate.extVariables = [];   % ID of extended variables (for max,min,norm,sin, etc)
    internal_sdpvarstate.auxVariables = [];   % ID of auxilliary variables (introduced when modelling extended variables)
    internal_sdpvarstate.auxVariablesW = [];   % ID of uncertain auxilliary variables (introduced when modelling uncertain extended variables)
    internal_sdpvarstate.logicVariables = []; % ID of extended logic variables (for or, nnz, alldifferent etc)
    internal_sdpvarstate.complexpair = [];
    internal_sdpvarstate.internalconstraints = [];
    internal_sdpvarstate.ExtendedMap = [];
    internal_sdpvarstate.DependencyMap = sparse(0);
    internal_sdpvarstate.DependencyMapUser = sparse(0);
    internal_sdpvarstate.sosid = 0;
    internal_sdpvarstate.sos_index = [];
    internal_sdpvarstate.sos_data = [];
    internal_sdpvarstate.sos_ParV = [];
    internal_sdpvarstate.sos_Q = [];
    internal_sdpvarstate.sos_v = [];
    internal_sdpvarstate.optSolution{1}.info = 'Initialized by YALMIP';
    internal_sdpvarstate.optSolution{1}.variables = [];
    internal_sdpvarstate.optSolution{1}.optvar  =[];
    internal_sdpvarstate.optSolution{1}.values  =[];
    internal_sdpvarstate.activeSolution = 1;

    internal_sdpvarstate.nonCommutingTable = [];
    internal_sdpvarstate.nonHermitiannonCommutingTable = [];
end
if isempty(internal_setstate)
    internal_setstate.LMIid = 0;
    internal_setstate.duals_index = [];
    internal_setstate.duals_data = [];
    internal_setstate.duals_associated_index = [];
    internal_setstate.duals_associated_data  = [];
end

switch varargin{1}

    case 'clearsolution'
         internal_sdpvarstate.optSolution{1}.variables = [];
    internal_sdpvarstate.optSolution{1}.optvar  =[];
    internal_sdpvarstate.optSolution{1}.values  =[];
    internal_sdpvarstate.activeSolution = 1;
    
    case 'monomtable'
        varargout{1} = internal_sdpvarstate.monomtable;
        n = size(internal_sdpvarstate.monomtable,1);
        if size(internal_sdpvarstate.monomtable,2) < n
            % Normalize the monomtalbe. Some external functions presume the
            % table is square
            varargout{1}(n,n) = 0;
            internal_sdpvarstate.monomtable = varargout{1};
            need_new = size(internal_sdpvarstate.monomtable,1) - length(internal_sdpvarstate.hash);
            internal_sdpvarstate.hash = [internal_sdpvarstate.hash ; 3*rand_hash(size(internal_sdpvarstate.monomtable,1),need_new,1)];
            internal_sdpvarstate.hashedmonomtable = internal_sdpvarstate.monomtable*internal_sdpvarstate.hash;
        end
        if nargout == 2
            varargout{2} = internal_sdpvarstate.variabletype;
        elseif nargout == 4
            varargout{2} = internal_sdpvarstate.variabletype;
            varargout{3} = internal_sdpvarstate.hashedmonomtable;
            varargout{4} = internal_sdpvarstate.hash;
        end

    case 'setmonomtable'
        % New monom table
        internal_sdpvarstate.monomtable = varargin{2};
        if nargin>=4
            % User has up-dated the hash tables him self.
            internal_sdpvarstate.hashedmonomtable=varargin{4};
            internal_sdpvarstate.hash = varargin{5};
        end
        if size(internal_sdpvarstate.monomtable,2)>length(internal_sdpvarstate.hash)
            need_new = size(internal_sdpvarstate.monomtable,1) - length(internal_sdpvarstate.hash);
            internal_sdpvarstate.hash = [internal_sdpvarstate.hash ; 3*rand_hash(size(internal_sdpvarstate.monomtable,1),need_new,1)];
        end
        if size(internal_sdpvarstate.monomtable,1)>size(internal_sdpvarstate.hashedmonomtable,1)
            % Need to add some hash values
            need_new = size(internal_sdpvarstate.monomtable,1) - size(internal_sdpvarstate.hashedmonomtable,1);
            temp = internal_sdpvarstate.monomtable(end-need_new+1:end,:);
            internal_sdpvarstate.hashedmonomtable = [internal_sdpvarstate.hashedmonomtable;temp*internal_sdpvarstate.hash];
        end
        if nargin >= 3
            internal_sdpvarstate.variabletype = varargin{3};
            if length(internal_sdpvarstate.variabletype) ~=size(internal_sdpvarstate.monomtable,1)
                error('ASSERT')
            end
        else
            internal_sdpvarstate.variabletype = zeros(size(internal_sdpvarstate.monomtable,1),1)';
            nonlinear = ~(sum(internal_sdpvarstate.monomtable,2)==1 & sum(internal_sdpvarstate.monomtable~=0,2)==1);
            if ~isempty(nonlinear)
                %mt = internal_sdpvarstate.monomtable;
                internal_sdpvarstate.variabletype(nonlinear) = 3;
                quadratic = sum(internal_sdpvarstate.monomtable,2)==2;
                internal_sdpvarstate.variabletype(quadratic) = 2;
                bilinear = max(internal_sdpvarstate.monomtable,[],2)<=1;
                internal_sdpvarstate.variabletype(bilinear & quadratic) = 1;
                sigmonial = any(0>internal_sdpvarstate.monomtable,2) | any(internal_sdpvarstate.monomtable-fix(internal_sdpvarstate.monomtable),2);
                internal_sdpvarstate.variabletype(sigmonial) = 4;
            end
        end
       
    case 'variabletype'
        varargout{1} = internal_sdpvarstate.variabletype;
        
    case {'addextendedvariable','addEvalVariable'}
        varargin{2}
        disp('Obsolete use of the terms addextendedvariable and addEvalVariable');
        error('Obsolete use of the terms addextendedvariable and addEvalVariable');
        
    case {'define','definemulti'}

        if strcmpi(varargin{1},'define')
            multioutput = 0;
            nout = [1 1];
        else
            multioutput = 1;
            nout = varargin{end};
            varargin = {varargin{1:end-1}};
            %nargin = length(varargin);%nargin - 1;
        end
        
        varargin{2} = strrep(varargin{2},'sdpvar/',''); % Clean due to different behaviour of the function mfilename in ML 5,6 and 7

        % Is this operator variable already defined
        correct_operator = [];
        if ~isempty(internal_sdpvarstate.ExtendedMap)
            i = 1;
            correct_operator = strcmp(varargin{2},{internal_sdpvarstate.ExtendedMap(:).fcn});
            arg1 = varargin{2};
            arg2 = {varargin{3:end}};
            this_hash = create_trivial_hash(varargin{3});            
            for i = find(correct_operator)
                if this_hash == internal_sdpvarstate.ExtendedMap(i).Hash
                    if isequal(arg2, {internal_sdpvarstate.ExtendedMap(i).arg{1:end-1}});
                        if length(internal_sdpvarstate.ExtendedMap(i).computes)>1
                            varargout{1} =  recover(internal_sdpvarstate.ExtendedMap(i).computes);
                        else
                            varargout{1} =  internal_sdpvarstate.ExtendedMap(i).var;
                        end
                        varargout{1} = setoperatorname(varargout{1},varargin{2});
                        return
                    end
                end
            end
        else
             this_hash = create_trivial_hash(varargin{3});
        end

        switch varargin{2}

            case {'max_internal'}
                % MAX is a bit special since we need one
                % new variable for each column...
                % (can be implemented standard way, but this is better
                % for performance, and since MAX is so common...
                X = varargin{3:end};
                [n,m] = size(X);
                if min([n m]) == 1
                    y = sdpvar(1,1);
                    internal_sdpvarstate.ExtendedMap(end+1).fcn = varargin{2};
                    internal_sdpvarstate.ExtendedMap(end).arg = {varargin{3:end},[]};
                    internal_sdpvarstate.ExtendedMap(end).var = y;
                    internal_sdpvarstate.ExtendedMap(end).computes = getvariables(y);
                    internal_sdpvarstate.extVariables = [internal_sdpvarstate.extVariables getvariables(y)];
                    internal_sdpvarstate.ExtendedMap(end).Hash = this_hash;
                else
                    y = sdpvar(1,m);
                    for i = 1:m
                        internal_sdpvarstate.ExtendedMap(end+1).fcn = varargin{2};
                        internal_sdpvarstate.ExtendedMap(end).arg = {X(:,i),[]};
                        internal_sdpvarstate.ExtendedMap(end).var = y(i);
                        internal_sdpvarstate.ExtendedMap(end).computes = getvariables(y(i));                        
                        internal_sdpvarstate.ExtendedMap(end).Hash = create_trivial_hash(X(:,i));
                    end
                    internal_sdpvarstate.extVariables = [internal_sdpvarstate.extVariables getvariables(y)];
                end
                y = setoperatorname(y,varargin{2});

            case {'abs'}
                % ABS is a bit special since we need one
                % new variable for each element...
                X = varargin{3:end};
                y = sdpvar(numel(X),1);
                allNewExtended = [];
                allNewExtendedIndex = [];
                allPreviouslyDefinedExtendedToIndex = [];
                allPreviouslyDefinedExtendedFromIndex = [];
                if numel(X)==1
                    found = 0;
                    if ~isempty(correct_operator)
                        this_hash = create_trivial_hash(X);
                        for j = find(correct_operator)
                            if this_hash == internal_sdpvarstate.ExtendedMap(j).Hash
                                if isequal(X,internal_sdpvarstate.ExtendedMap(j).arg{1},1)                                  
                                  %  y = internal_sdpvarstate.ExtendedMap(j).var;
                                    allPreviouslyDefinedExtendedToIndex = [1];
                                    allPreviouslyDefinedExtendedFromIndex = [j];
                                    found = 1;
                                    break
                                end
                            end
                        end
                    end
                    if ~found
                        internal_sdpvarstate.ExtendedMap(end+1).fcn = varargin{2};
                        internal_sdpvarstate.ExtendedMap(end).arg = {X,binvar(1),[]};
                        internal_sdpvarstate.ExtendedMap(end).var = y;
                        internal_sdpvarstate.ExtendedMap(end).computes = getvariables(y);                        
                        internal_sdpvarstate.ExtendedMap(end).Hash = create_trivial_hash(X);
                        allNewExtended = y;
                        allNewExtendedIndex = 1;
                    end
                else
                    aux_bin = binvar(numel(X),1);
                    for i = 1:numel(X)                       
                        % This is a bummer. If we scalarize the abs-operator,
                        % we have to search through all scalar abs-operators
                        % to find this single element
                        found = 0;
                        Xi = X(i);
                        if isa(Xi,'double')
                            found = 1;
                            y(i) = Xi;
                        else
                            if ~isempty(correct_operator)
                                this_hash = create_trivial_hash(Xi);
                                for j = find(correct_operator)
                                    if this_hash == internal_sdpvarstate.ExtendedMap(j).Hash                                       
                                        if isequal(Xi,internal_sdpvarstate.ExtendedMap(j).arg{1},1)
                                          %  y(i) = internal_sdpvarstate.ExtendedMap(j).var;
                                            allPreviouslyDefinedExtendedToIndex = [allPreviouslyDefinedExtendedToIndex i];
                                            allPreviouslyDefinedExtendedFromIndex = [allPreviouslyDefinedExtendedFromIndex j];
                                            found = 1;
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        if ~found
                            yi = y(i);
                            internal_sdpvarstate.ExtendedMap(end+1).fcn = varargin{2};
                            internal_sdpvarstate.ExtendedMap(end).arg = {Xi,aux_bin(i),[]};
                            internal_sdpvarstate.ExtendedMap(end).var = yi;
                            internal_sdpvarstate.ExtendedMap(end).computes = getvariables(yi);
                            internal_sdpvarstate.ExtendedMap(end).Hash = create_trivial_hash(Xi);
                            %allNewExtended = [allNewExtended yi];
                            allNewExtendedIndex = [allNewExtendedIndex i];
                        end
                    end
                end
                y(allPreviouslyDefinedExtendedToIndex) = [internal_sdpvarstate.ExtendedMap(allPreviouslyDefinedExtendedFromIndex).var];
                allNewExtended = y(allNewExtendedIndex);
                y_vars = getvariables(allNewExtended);
                internal_sdpvarstate.extVariables = [internal_sdpvarstate.extVariables y_vars];
                y = reshape(y,size(X,1),size(X,2));
                y = setoperatorname(y,varargin{2});
               

            otherwise
                % This is the standard operators. INPUTS -> 1 scalar output
                if isequal(varargin{2},'or') | isequal(varargin{2},'xor') | isequal(varargin{2},'and')
                    y = binvar(1,1);                    
                else
                    y = sdpvar(nout(1),nout(2));
                end
                if ~strcmpi({'sort'},varargin{2})
                    % Oh fuck is this ugly. Sort assumes ordering on some
                    % variables, and thus assumes no z in between. This
                    % will be generalized when R^n -> R^m is supported for
                    % real
                    z = sdpvar(size(varargin{3},1),size(varargin{3},2),'full'); % Standard format     y=f(z),z==arg
                    internal_sdpvarstate.auxVariables = [ internal_sdpvarstate.auxVariables  getvariables(z)];
                    internal_sdpvarstate.auxVariables = [ internal_sdpvarstate.auxVariables  getvariables(y)];
                else
                    z = [];
                end
                for i = 1:nout
                    internal_sdpvarstate.ExtendedMap(end+1).fcn = varargin{2};
                    internal_sdpvarstate.ExtendedMap(end).arg = {varargin{3:end},z};
                    internal_sdpvarstate.ExtendedMap(end).var = y(i);
                    internal_sdpvarstate.ExtendedMap(end).computes = getvariables(y);
                    internal_sdpvarstate.ExtendedMap(end).Hash = this_hash;
                    internal_sdpvarstate.extVariables = [internal_sdpvarstate.extVariables getvariables(y(i))];                
                end
                y = setoperatorname(y,varargin{2});
        end
        for i = 3:length(varargin)%nargin
            if isa(varargin{i},'sdpvar')
                yalmip('setdependence',getvariables(y),getvariables(varargin{i}));
            end
        end
        varargout{1} = y;
        return

    case 'setdependence'
        if ~isempty(varargin{2}) & ~isempty(varargin{3})
            if isa(varargin{2},'sdpvar')
                varargin{2} = getvariables(varargin{2});
            end
            if isa(varargin{3},'sdpvar')
                varargin{3} = getvariables(varargin{3});
            end
            % This dies not work since the arguments have different
            % ordering. Try for instance x=sdpvar(2),[x>=0,abs(x)>=0]
            % nx = max(size(internal_sdpvarstate.DependencyMap,1),max(varargin{2}));
            % ny = max(size(internal_sdpvarstate.DependencyMap,2),max(varargin{3}));
            % index = sub2ind([nx ny], varargin{2},varargin{3});
            % if size(internal_sdpvarstate.DependencyMap,1) < nx | size(internal_sdpvarstate.DependencyMap,2) < ny
            %     internal_sdpvarstate.DependencyMap(nx,ny) = 0;
            % end
            % internal_sdpvarstate.DependencyMap(index) = 1; 
            internal_sdpvarstate.DependencyMap(varargin{2},varargin{3}) = 1;                
            n = size(internal_sdpvarstate.monomtable,1);
            if size(internal_sdpvarstate.DependencyMap,1) < n
                internal_sdpvarstate.DependencyMap(n,1)=0;
            end
            if size(internal_sdpvarstate.DependencyMap,2) < n
                internal_sdpvarstate.DependencyMap(end,n)=0;
            end
        end

    case 'setdependenceUser'
        if ~isempty(varargin{2}) & ~isempty(varargin{3})
            if isa(varargin{2},'sdpvar')
                varargin{2} = getvariables(varargin{2});
            end
            if isa(varargin{3},'sdpvar')
                varargin{3} = getvariables(varargin{3});
            end                    
            internal_sdpvarstate.DependencyMapUser(varargin{2},varargin{3}) = 1;                
            n = size(internal_sdpvarstate.monomtable,1);
            if size(internal_sdpvarstate.DependencyMapUser,1) < n
                internal_sdpvarstate.DependencyMapUser(n,1)=0;
            end
            if size(internal_sdpvarstate.DependencyMapUser,2) < n
                internal_sdpvarstate.DependencyMapUser(end,n)=0;
            end
        end
        
    case 'getdependence'
        varargout{1} =   internal_sdpvarstate.DependencyMap;
        n =  size(internal_sdpvarstate.monomtable,1);
        if size(varargout{1},1) < n | size(varargout{1},2)<n
            varargout{1}(n,n) = 0;
        end
        
    case 'getdependenceUser'
        varargout{1} =   internal_sdpvarstate.DependencyMapUser;
        n =  size(internal_sdpvarstate.monomtable,1);
        if size(varargout{1},1) < n | size(varargout{1},2)<n
            varargout{1}(n,n) = 0;
        end
        
        
    case 'getarguments'
        varargout{1} = yalmip('extstruct',getvariables(varargin{2}));

   case 'auxvariables'
        varargout{1} = internal_sdpvarstate.auxVariables;
   
    case 'auxvariablesW'
        varargout{1} = internal_sdpvarstate.auxVariablesW;        

    case 'extvariables'
        varargout{1} = internal_sdpvarstate.extVariables;

    case 'extstruct'
        if nargin == 1
            varargout{1} = internal_sdpvarstate.ExtendedMap;
        elseif length(varargin{2})==1
            found = 0;
            varargout{1} = [];
            i = 1;
            while ~found & i <=length(internal_sdpvarstate.ExtendedMap)
                if varargin{2} == getvariables(internal_sdpvarstate.ExtendedMap(i).var)
                    found = 1;
                    varargout{1} = internal_sdpvarstate.ExtendedMap(i);
                end
                i = i + 1;
            end
        else
            % If requests several extended variables, returns as cell
            found = zeros(1,length(varargin{2}));
            varargout{1} = cell(0,length(varargin{2}));
            i = 1;
            while ~all(found) & i <=length(internal_sdpvarstate.ExtendedMap)
                j = find(varargin{2} == getvariables(internal_sdpvarstate.ExtendedMap(i).var));
                if ~isempty(j)
                    found(j) = 1;
                    varargout{1}{j} = internal_sdpvarstate.ExtendedMap(i);
                end
                i = i + 1;
            end
        end

    case 'rankvariables'
        i = 1;
        rankvariables     = [];
        dualrankvariables = [];
        for i = 1:length(internal_sdpvarstate.ExtendedMap)
            if strcmpi('rank',internal_sdpvarstate.ExtendedMap(i).fcn)
                rankvariables = [rankvariables getvariables(internal_sdpvarstate.ExtendedMap(i).var)];
            end
            if strcmpi('dualrank',internal_sdpvarstate.ExtendedMap(i).fcn)
                dualrankvariables = [dualrankvariables getvariables(internal_sdpvarstate.ExtendedMap(i).var)];
            end            
        end
        varargout{1} = rankvariables;
        varargout{2} = dualrankvariables;
            
    case {'lmiid','ConstraintID'}
        if not(isempty(internal_setstate.LMIid))
            internal_setstate.LMIid = internal_setstate.LMIid+1;
            varargout{1}=internal_setstate.LMIid;
        else
            internal_setstate.LMIid=1;
            varargout{1}=internal_setstate.LMIid;
        end

    case 'setnonlinearvariables'
        error('Internal error (ref. setnonlinearvariables). Report please.')

    case {'clear'}
        W = evalin('caller','whos');
        for i = 1:size(W,1)
            if strcmp(W(i).class,'sdpvar') | strcmp(W(i).class,'lmi')
                evalin('caller', ['clear ' W(i).name ';']);
            end
        end

        internal_setstate.LMIid = 0;
        internal_setstate.duals_index = [];
        internal_setstate.duals_data = [];
        internal_setstate.duals_associated_index = [];
        internal_setstate.duals_associated_data  = [];


        internal_sdpvarstate.sosid = 0;
        internal_sdpvarstate.sos_index = [];
        internal_sdpvarstate.sos_data = [];
        internal_sdpvarstate.sos_ParV = [];
        internal_sdpvarstate.sos_Q    = [];
        internal_sdpvarstate.sos_v    = [];

        internal_sdpvarstate.monomtable = spalloc(0,0,0);
        internal_sdpvarstate.hashedmonomtable = [];
        internal_sdpvarstate.hash = [];
        internal_sdpvarstate.boundlist = [];
        internal_sdpvarstate.variabletype = spalloc(0,0,0);
        internal_sdpvarstate.intVariables = [];
        internal_sdpvarstate.binVariables = [];
        internal_sdpvarstate.semicontVariables = [];
        internal_sdpvarstate.uncVariables = [];
        internal_sdpvarstate.parVariables = [];
        internal_sdpvarstate.extVariables = [];
        internal_sdpvarstate.auxVariables = [];
        internal_sdpvarstate.auxVariablesW = [];
        internal_sdpvarstate.logicVariables = [];
        ;internal_sdpvarstate.complexpair = [];
        internal_sdpvarstate.internalconstraints = [];
        internal_sdpvarstate.ExtendedMap = [];
        internal_sdpvarstate.DependencyMap = sparse(0);
        internal_sdpvarstate.DependencyMapUser = sparse(0);
        internal_sdpvarstate.optSolution{1}.info = 'Initialized by YALMIP';
        internal_sdpvarstate.optSolution{1}.variables = [];
        internal_sdpvarstate.optSolution{1}.optvar = [];
        internal_sdpvarstate.optSolution{1}.values = [];
        internal_sdpvarstate.activeSolution = 1;

        internal_sdpvarstate.nonCommutingTable = [];

    case 'cleardual'
        if nargin==1
            internal_setstate.duals_index = [];
            internal_setstate.duals_data = [];
            internal_setstate.duals_associated_index = [];
            internal_setstate.duals_associated_data = [];
        else
            if ~isempty(internal_setstate.duals_index)
                internal_setstate.lmiid = varargin{2};
                for i = 1:length(varargin{2})
                    j = find(internal_setstate.duals_index==internal_setstate.lmiid(i));
                    if ~isempty(j)
                        internal_setstate.duals_index = internal_setstate.duals_index([1:1:j-1 j+1:1:length(internal_setstate.duals_index)]);
                        internal_setstate.duals_data = {internal_setstate.duals_data{[1:1:j-1 j+1:1:length(internal_setstate.duals_data)]}};
                    end
                end
            end
        end

    case 'associatedual'
        internal_setstate.duals_associated_index = [internal_setstate.duals_associated_index varargin{2}];
        internal_setstate.duals_associated_data{end+1} = varargin{3};

    case 'addcomplexpair'
        internal_sdpvarstate.complexpair = [internal_sdpvarstate.complexpair;varargin{2}];

    case 'getcomplexpair'
        varargout{1} = internal_sdpvarstate.complexpair;
        return

    case 'setallsolution'
        internal_sdpvarstate.optSolution{internal_sdpvarstate.activeSolution}.optvar = varargin{2}.optvar;
        internal_sdpvarstate.optSolution{internal_sdpvarstate.activeSolution}.variables = varargin{2}.variables;
        internal_sdpvarstate.optSolution{internal_sdpvarstate.activeSolution}.values = [];
        return

    case 'setvalues'
        internal_sdpvarstate.optSolution{internal_sdpvarstate.activeSolution}.values = varargin{2};

    case 'selectsolution'
        if length(internal_sdpvarstate.optSolution)>=varargin{2}
            internal_sdpvarstate.activeSolution = varargin{2};
        else
            error('Solution not available');
        end
        
    case 'setsolution'
        if nargin < 3
            solutionIndex = 1;           
        else
            solutionIndex = varargin{3};
        end
        internal_sdpvarstate.activeSolution = 1;
        
        % Clear trailing solutions
        if solutionIndex < length(internal_sdpvarstate.optSolution)
            internal_sdpvarstate.optSolution = {internal_sdpvarstate.optSolution{1:solutionIndex}};
        elseif solutionIndex > length(internal_sdpvarstate.optSolution)+1
            for j = length(internal_sdpvarstate.optSolution)+1:solutionIndex
                internal_sdpvarstate.optSolution{j}.optvar=[];
                internal_sdpvarstate.optSolution{j}.variables=[];
                internal_sdpvarstate.optSolution{j}.values=[];
            end
        elseif solutionIndex == length(internal_sdpvarstate.optSolution)+1
            internal_sdpvarstate.optSolution{solutionIndex}.optvar=[];
            internal_sdpvarstate.optSolution{solutionIndex}.variables=[];
            internal_sdpvarstate.optSolution{solutionIndex}.values=[];
        end
        
        if isempty(internal_sdpvarstate.optSolution{solutionIndex}.variables)
            internal_sdpvarstate.optSolution{solutionIndex} = varargin{2};
        else
            % Just save some stuff first
            newSolution = varargin{2};
            oldSolution = internal_sdpvarstate.optSolution{solutionIndex};
            optSolution = varargin{2};
            keep_these = find(~ismember(oldSolution.variables,newSolution.variables));
            internal_sdpvarstate.optSolution{solutionIndex}.optvar    = [oldSolution.optvar(keep_these);newSolution.optvar(:)];
            internal_sdpvarstate.optSolution{solutionIndex}.variables = [oldSolution.variables(keep_these);newSolution.variables(:)];
        end
        % clear evaluated values (only used cache-wise)
        internal_sdpvarstate.optSolution{solutionIndex}.values = [];
        return
        
%    case 'setsolution'
%                
%         if isempty(internal_sdpvarstate.optSolution.variables)
%             internal_sdpvarstate.optSolution = varargin{2};
%         else
%             % Just save some stuff first
%             newSolution = varargin{2};
%             oldSolution = internal_sdpvarstate.optSolution;
%             optSolution = varargin{2};
%             keep_these = find(~ismember(oldSolution.variables,newSolution.variables));
%             internal_sdpvarstate.optSolution.optvar    = [oldSolution.optvar(keep_these);newSolution.optvar(:)];
%             internal_sdpvarstate.optSolution.variables = [oldSolution.variables(keep_these);newSolution.variables(:)];
%         end
%         % clear evaluated values (only used cache-wise)
%         internal_sdpvarstate.optSolution.values = [];
%         return    

    case 'addauxvariables'
        internal_sdpvarstate.auxVariables = [internal_sdpvarstate.auxVariables varargin{2}(:)'];
    
    case 'addauxvariablesW'
        internal_sdpvarstate.auxVariablesW = [internal_sdpvarstate.auxVariablesW varargin{2}(:)'];
    
        
    case 'getsolution'
        varargout{1} = internal_sdpvarstate.optSolution{internal_sdpvarstate.activeSolution};
        return

    case 'setdual'
        internal_setstate.duals_index = varargin{2};
        internal_setstate.duals_data = varargin{3};

        if ~isempty(internal_setstate.duals_associated_index)
            if ~isempty(intersect(internal_setstate.duals_index,internal_setstate.duals_associated_index))
                for i = 1:length(internal_setstate.duals_index)
                    itshere = find(internal_setstate.duals_associated_index==internal_setstate.duals_index(i));
                    if ~isempty(itshere)
                        assign(internal_setstate.duals_associated_data{itshere},internal_setstate.duals_data{i});
                    end
                end
            end
        end

    case 'dual'
        if isempty(internal_setstate.duals_index)
            varargout{1}=[];
        else
            LMIid = varargin{2};
            index_to_dual = find(LMIid==internal_setstate.duals_index);
            if isempty(index_to_dual)
                varargout{1}=[];
            else
                varargout{1} = internal_setstate.duals_data{index_to_dual};
            end
        end

    case 'clearsos'
        if nargin==1
            internal_sdpvarstate.sos_index = [];
            internal_sdpvarstate.sos_data = [];
            internal_sdpvarstate.sos_ParV = [];
            internal_sdpvarstate.sos_Q    = [];
            internal_sdpvarstate.sos_v    = [];

        end

    case 'setsos'
        if ~isempty(internal_sdpvarstate.sos_index)
            where = find(internal_sdpvarstate.sos_index==varargin{2});
            if ~isempty(where)
                internal_sdpvarstate.sos_index(where) = varargin{2};
                internal_sdpvarstate.sos_data{where} = varargin{3};
                internal_sdpvarstate.sos_ParV{where} = varargin{4};
                internal_sdpvarstate.sos_Q{where} = varargin{5};
                internal_sdpvarstate.sos_v{where} = varargin{6};

            else
                internal_sdpvarstate.sos_index(end+1) = varargin{2};
                internal_sdpvarstate.sos_data{end+1} = varargin{3};
                internal_sdpvarstate.sos_ParV{end+1} = varargin{4};
                internal_sdpvarstate.sos_Q{end+1} = varargin{5};
                internal_sdpvarstate.sos_v{end+1} = varargin{6};

            end
        else
            internal_sdpvarstate.sos_index(end+1) = varargin{2};
            internal_sdpvarstate.sos_data{end+1} = varargin{3};
            internal_sdpvarstate.sos_ParV{end+1} = varargin{4};
            internal_sdpvarstate.sos_Q{end+1} = varargin{5};
            internal_sdpvarstate.sos_v{end+1} = varargin{6};
        end

    case 'sosid'
        if not(isempty(internal_sdpvarstate.sosid))
            internal_sdpvarstate.sosid = internal_sdpvarstate.sosid+1;
            varargout{1}=internal_sdpvarstate.sosid;
        else
            internal_sdpvarstate.sosid=1;
            varargout{1}=internal_sdpvarstate.sosid;
        end

    case 'getsos'
        if isempty(internal_sdpvarstate.sos_index)
            varargout{1}=[];
            varargout{2}=[];
            varargout{3}=[];
            varargout{4}=[];
        else
            SOSid = varargin{2};
            index_to_sos = find(SOSid==internal_sdpvarstate.sos_index);
            if isempty(index_to_sos)
                varargout{1}=[];
                varargout{2}=[];
                varargout{3}=[];
                varargout{4}=[];
            else
                varargout{1} = internal_sdpvarstate.sos_data{index_to_sos};
                varargout{2} = internal_sdpvarstate.sos_ParV{index_to_sos};
                varargout{3} = internal_sdpvarstate.sos_Q{index_to_sos};
                varargout{4} = internal_sdpvarstate.sos_v{index_to_sos};
                % FIX
            end
        end


    case 'getinternalsetstate'
        varargout{1} = internal_setstate; % Get internal state, called from saveobj

    case 'setinternalsetstate'
        internal_setstate = varargin{2}; % Set internal state, called from loadobj

    case 'getinternalsdpvarstate'
        varargout{1} = internal_sdpvarstate; % Get internal state, called from saveobj

    case 'setinternalsdpvarstate'
        internal_sdpvarstate = varargin{2}; % Set internal state, called from loadobj

        % Back-wards compability....
        if ~isfield(internal_sdpvarstate,'extVariables')
            internal_sdpvarstate.extVariables = [];
        end
        if ~isfield(internal_sdpvarstate,'ExtendedMap')
            internal_sdpvarstate.ExtendedMap = [];
        end
        if ~isfield(internal_sdpvarstate,'variabletype')
            internal_sdpvarstate.variabletype = ~(sum(internal_sdpvarstate.monomtable,2)==1 & sum(internal_sdpvarstate.monomtable~=0,2)==1);
        end
        if ~isfield(internal_sdpvarstate,'hash')
            internal_sdpvarstate.hash=[];
            internal_sdpvarstate.hashedmonomtable=[];
        end

        % Re-compute some stuff for safety
        internal_sdpvarstate.variabletype = internal_sdpvarstate.variabletype(:)';
        internal_sdpvarstate.variabletype = spalloc(size(internal_sdpvarstate.monomtable,1),1,0)';
        nonlinear = ~(sum(internal_sdpvarstate.monomtable,2)==1 & sum(internal_sdpvarstate.monomtable~=0,2)==1);
        if ~isempty(nonlinear)
            mt = internal_sdpvarstate.monomtable;
            internal_sdpvarstate.variabletype(nonlinear) = 3;
            quadratic = sum(internal_sdpvarstate.monomtable,2)==2;
            internal_sdpvarstate.variabletype(quadratic) = 2;
            bilinear = max(internal_sdpvarstate.monomtable,[],2)<=1;
            internal_sdpvarstate.variabletype(bilinear & quadratic) = 1;
            sigmonial = any(0>internal_sdpvarstate.monomtable,2) | any(internal_sdpvarstate.monomtable-fix(internal_sdpvarstate.monomtable),2);
            internal_sdpvarstate.variabletype(sigmonial) = 4;
        end

        [n,m] = size(internal_sdpvarstate.monomtable);
        if n>m
            internal_sdpvarstate.monomtable(n,n) = 0;
        end

        if size(internal_sdpvarstate.monomtable,2)>length(internal_sdpvarstate.hash)
            % Need new hash-keys
            internal_sdpvarstate.hash = [internal_sdpvarstate.hash ; 3*rand_hash(size(internal_sdpvarstate.monomtable,1),need_new,1)];
        end
        if size(internal_sdpvarstate.monomtable,1)>size(internal_sdpvarstate.hashedmonomtable,1)
            % Need to add some hash values
            need_new = size(internal_sdpvarstate.monomtable,1) - size(internal_sdpvarstate.hashedmonomtable,1);
            internal_sdpvarstate.hashedmonomtable = [internal_sdpvarstate.hashedmonomtable;internal_sdpvarstate.monomtable(end-need_new+1:end,:)*internal_sdpvarstate.hash];
        end



    case {'version','ver'}
        varargout{1} = '20120926';        

    case 'setintvariables'
        internal_sdpvarstate.intVariables = varargin{2};

    case 'intvariables'
        varargout{1} = internal_sdpvarstate.intVariables;

    case 'setbinvariables'
        internal_sdpvarstate.binVariables = varargin{2};

    case 'binvariables'
        varargout{1} = internal_sdpvarstate.binVariables;
        
    case 'quantvariables'
        varargout{1} = [internal_sdpvarstate.binVariables internal_sdpvarstate.intVariables];        

    case 'setsemicontvariables'
        internal_sdpvarstate.semicontVariables = varargin{2};

    case 'semicontvariables'
        varargout{1} = internal_sdpvarstate.semicontVariables;
        
    case 'setuncvariables'
        internal_sdpvarstate.uncVariables = varargin{2};

    case 'uncvariables'
        varargout{1} = internal_sdpvarstate.uncVariables;

    case 'setparvariables'
        internal_sdpvarstate.parVariables = varargin{2};

    case 'parvariables'
        varargout{1} = internal_sdpvarstate.parVariables;

    case 'nonCommutingTable'
        if nargin == 2
            internal_sdpvarstate.nonCommutingTable = varargin{2};
        else
            varargout{1} = internal_sdpvarstate.nonCommutingTable;
        end

    case 'nonlinearvariables'
        error('Internal error (ref. nonlinear variables). Report!')
        varargout{1} = internal_sdpvarstate.nonlinearvariables;
        if nargout==2
            varargout{2} = internal_sdpvarstate.nonlinearvariablesCompressed;
        end
        %
    case {'addinternal'}
        internal_sdpvarstate.internalconstraints{end+1} = varargin{1};

        %  case {'setnvars'}
        %      sdpvar('setnvars',varargin{2});

    case {'nvars'}
        varargout{1} = size(internal_sdpvarstate.monomtable,1);
        % varargout{1} = sdpvar('nvars');

    case {'info'}
        [version,release] = yalmip('version');
        currentversion = num2str(version(1));
        i = 1;
        while i<length(version)
            i = i+1;
            currentversion = [currentversion '.' num2str(version(i))];
        end

        info_str = ['- - - - YALMIP ' currentversion ' ' num2str(release) ' - - - -'];

        disp(' ');
        disp(char(repmat(double('*'),1,length(info_str))));
        disp(info_str)
        disp(char(repmat(double('*'),1,length(info_str))));
        disp(' ');
        disp(['Variable     Size'])
        spaces = ['                                    '];
        ws = evalin('caller','whos');
        n = 0;
        for i = 1:size(ws,1)
            if strcmp(ws(i).class,'sdpvar')
                n = n+1;
                wsname = ws(i).name;
                wssize = [num2str(ws(i).size(1)) 'x' num2str(ws(i).size(2))];
                disp([wsname spaces(1:13-length(wsname)) wssize]);
            end
        end
        if n == 0
            disp('No SDPVAR objects found');
        end
        disp(' ');
        disp(['LMI']);
        n = 0;
        for i = 1:size(ws,1)
            if strcmp(ws(i).class,'lmi')
                n = n+1;
                wsname = ws(i).name;
                disp([wsname]);
            end
        end
        if n == 0
            disp('No SET objects found');
        end

    case 'getbounds'
        if ~isfield(internal_sdpvarstate,'boundlist')
            internal_sdpvarstate.boundlist = inf*repmat([-1 1],size(internal_sdpvarstate.monomtable,1),1);
        elseif isempty(internal_sdpvarstate.boundlist)
            internal_sdpvarstate.boundlist = inf*repmat([-1 1],size(internal_sdpvarstate.monomtable,1),1);
        end
        indicies = varargin{2};
        if max(indicies)>size(internal_sdpvarstate.boundlist,1)
            need_new = max(indicies)-size(internal_sdpvarstate.boundlist,1);
            internal_sdpvarstate.boundlist = [internal_sdpvarstate.boundlist;inf*repmat([-1 1],size(internal_sdpvarstate.monomtable,1),1)];
        end
        varargout{1} = internal_sdpvarstate.boundlist(indicies,:);
        varargout{2} = internal_sdpvarstate.boundlist(indicies,:);

    case 'setbounds'
        if ~isfield(internal_sdpvarstate,'boundlist')
            internal_sdpvarstate.boundlist = inf*repmat([-1 1],size(internal_sdpvarstate.monomtable,1),1);
        elseif isempty(internal_sdpvarstate.boundlist)
            internal_sdpvarstate.boundlist = inf*repmat([-1 1],size(internal_sdpvarstate.monomtable,1),1);
        end
        indicies = varargin{2};
        if size(internal_sdpvarstate.boundlist,1)<min(indicies)
            internal_sdpvarstate.boundlist = [internal_sdpvarstate.boundlist;repmat([-inf inf],max(indicies)-size(internal_sdpvarstate.boundlist,1),1)];
        end
        internal_sdpvarstate.boundlist(indicies,1) = -inf ;
        internal_sdpvarstate.boundlist(indicies,2) = inf;

        internal_sdpvarstate.boundlist(indicies(:),1) = varargin{3};
        internal_sdpvarstate.boundlist(indicies(:),2) = varargin{4};
        varargout{1}=0;

    case  'logicextvariables'
        logicextvariables = [];
        for i = 1:length(internal_sdpvarstate.ExtendedMap)
            %            if ismember(internal_sdpvarstate.ExtendedMap(i).fcn,{'or','and'})
            if isequal(internal_sdpvarstate.ExtendedMap(i).fcn,'or') | isequal(internal_sdpvarstate.ExtendedMap(i).fcn,'and')
                logicextvariables = [logicextvariables internal_sdpvarstate.extVariables(i)];
            end
        end
        varargout{1} = logicextvariables;

    case 'logicVariables'
        varargout{1} = internal_sdpvarstate.logicVariables;

    case 'addlogicvariable'
        % This code essentially the same as the addextended code. The only
        % difference is that we keep track of logic variables in order to
        % know when we have to collect bounds for the big-M relaxations.

        varargin{2} = strrep(varargin{2},'sdpvar/','');

        % Is this operator variable already defined
        if ~isempty(internal_sdpvarstate.ExtendedMap)
            i = 1;
            while i<=length(internal_sdpvarstate.ExtendedMap)
                if isequal(varargin{2},internal_sdpvarstate.ExtendedMap(i).fcn) & isequal({varargin{3:end}}, {internal_sdpvarstate.ExtendedMap(i).arg{1:end-1}})
                    varargout{1} =  internal_sdpvarstate.ExtendedMap(i).var;
                    return
                end
                i = i + 1;
            end
        end

        % This is the standard operators. INPUTS -> 1 scalar output
        y = sdpvar(1,1);
        internal_sdpvarstate.ExtendedMap(end+1).fcn = varargin{2};
        internal_sdpvarstate.ExtendedMap(end).arg = {varargin{3:end}};
        internal_sdpvarstate.ExtendedMap(end).var = y;
        internal_sdpvarstate.extVariables = [internal_sdpvarstate.extVariables getvariables(y)];
        internal_sdpvarstate.logicVariables = [internal_sdpvarstate.logicVariables getvariables(y)];
        varargout{1} = y;
        return

    case 'setNonHermitianNonCommuting'
        internal_sdpvarstate.nonHermitiannonCommutingTable(varargin{2}) = 1;        
        
    case 'solver'
        if (nargin==2)
            if isa(varargin{2},'char')
                solver = varargin{2};
                prefered_solver = solver;
            else
                error('Second argument should be a string with solver name');
            end
        else
            if isempty(prefered_solver)
                varargout{1}='';
            else
                varargout{1} = prefered_solver;
            end
        end
    otherwise
        if isa(varargin{1},'char')
            disp(['The command ''' varargin{1} ''' is not valid in YALMIP.m']);
        else
            disp('The first argument should be a string');
        end
end

function r = rand_hash(k,n,m);
try
    % Previous approach does not work with parallell toolbox!
    s = rng;
    rng(k);
    r = rand(n,m);
    rng(s);
catch
    % but rng is not available in all versions...
    s = rand('state');
    rand('state',k)
    r = rand(n,m);
    rand('state',s);
end

function h = create_trivial_hash(x)
try
    h = sum(getvariables(x)) + sum(sum(getbase(x)));
catch
    h = 0;
end

