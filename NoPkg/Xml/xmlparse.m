function [X, metaData] = xmlparse(str, att_switch, X, level,typeOnTop)
% XMLPARSE parses XML string str and returns matlab variable/structure.
% This is a non-validating parser!
%
% Input:
%   regular:
%       str: char[1,] -  xml string, possibly from file with function xmlload.m
%
%   optional:
%       att_switch: char[1,]  'on'- reads attributes, 'off'- ignores attributes
%       X: anysupportedtype[...]        Optional. Variable which gets extended or whose
%                   substructure parameters get overridden by entries in
%                   the string.
%       level: double[1,1] - internal xml level. Should not be used by user.
%
% Output:
%   
%   X: anysupportedtype[...] - matlab variable or structure
%   metaData structure with meta data stored in the root tag
%
% RELATED
%   xmlformat, xmlload, xmlsave, (xmlread, xmlwrite)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-20 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   vast small changes that effect performance
%
%   added support for multi-line comments, simplified xml layout which
%   improves a human-readability
% ----------------------------------------------------------
% Initialisation and checks on input parameters

% set XML TB version number
xml_tb_version = '2.0';
% define persistent (static) variable in which read-in
% xml_tb_version number gets stored
persistent xmlTBVersion;
% check input parameters
if (nargin<1), error([mfilename, ' needs at least 1 input parameter.']); end
% default attribute switch setting
if ((nargin<2) || ~strcmp(att_switch, 'off')), att_switch = 'on'; end
% default base variable setting
if (nargin<3),  X = struct([]); end
% default root level setting
if (nargin<4), level = 0; end
% check input string
if (nargin<5)
    isCellOnTopForSure=false; 
else
    isCellOnTopForSure=strcmp(typeOnTop,'cell');
end
if isempty(str), return; end
% define variables
xmlVersion = '';
%
if level==0
    metaData=struct();
end
%---------------------------
% remove all <! execute and comment entries from str by blanking out
execpos = findstr(str, '<!--');
if ~isempty(execpos)
    allclose = findstr(str, '-->');
    for x=1:length(execpos)
        xstart   = execpos(x);
        idxclose = find(allclose > xstart);
        xend     = allclose(idxclose(1));
        str(xstart:(xend+2)) = blanks(xend-xstart+3);
    end
end

%---------------------------
% find xml string elements
popen = find(str=='<'&[str(2:end)~='/',true]);

pclose = sort( [strfind(str, '</'), ...
    strfind(str, '/>'), ...
    strfind(str, '-->'), ...
    strfind(str, '?>')] );

% check for correct number of start and end tags
if length(popen) ~= length(pclose)
    error('XML parse error: Number of element start and end tags does not match.');
end

np = length(popen);
openCloseIndVec=[-ones(np,1);ones(np,1)];
[pcIndVec,sortIndVec]=sort([popen,pclose]);
pidx=[pcIndVec.',openCloseIndVec(sortIndVec)];

% loop through all elements identified (on level 0 only root
% which will call further instances of this function)
i=1;
sumparenths = 0;
itemCount=0;
while i<=size(pidx,1)
    itemCount=itemCount+1;
    entrystart = pidx(i,1);
    sumparenths = sumparenths + pidx(i,2);
    while sumparenths ~= 0
        i = i+1;
        sumparenths = sumparenths + pidx(i,2);
    end
    entryend = pidx(i,1);
    tmp = str(entrystart+1:entryend-1);
    
    TYPE = ''; NAME = ''; IDX=[]; FIELDS=[];
    TAG = '';
    
    headsep = findstr(tmp, '>');
    if isempty(headsep)
        % deal with "/>" empty elements by using the whole tmp string
        headsep = length(tmp);
    end
    
    namesep = min([findstr(tmp, ' '), findstr(tmp, '>')]);
    if isempty(namesep)
        TAG = tmp;
    else
        TAG = tmp(1:namesep-1);
    end
    
    header  = tmp(namesep+1:headsep);
    content = tmp(headsep+1:end);
    
    % make sure that we have size [0 0] and not [1 0]
    if isempty(content)
        content = '';
    end
    
    % parse header for attributes
    att_lst = header;
    %
    tokens=regexp([' ' att_lst],'\s([^=]*)="([^"]*)"','tokens');
    %
    isSizeSpecified=false;
    if strcmp(att_switch, 'on')
        for k=1:1:length(tokens)
            switch(tokens{k}{1})
                case 'idx'
                    IDX = str2double(tokens{k}{2});
                case 'name'
                    NAME = tokens{k}{2};
                case 'size'
                    SIZE = str2num(tokens{k}{2});
                    isSizeSpecified=true;
                case 'fields'
                    FIELDS = strsplit(tokens{k}{2},' ');
                case 'type'
                    TYPE = tokens{k}{2};
                    %case 'value'
                    % deal with this case like with any other attributes
                    % in XML Toolbox Version 3.0
                otherwise,
                    if level==0
                        switch (tokens{k}{1})
                            case 'xml_tb_version'
                                xmlTBVersion = str2num(tokens{k}{2});                    
                            otherwise,
                                metaData.(tokens{k}{1})=tokens{k}{2};
                        end
                    end
            end
        end
    end
    if ~isSizeSpecified
        if strcmpi(TYPE,'struct')
            SIZE=[1 1];
        else
            SIZE=[0 0];
        end
    end
    N_ELEMS=prod(SIZE);
    %ISN_EMPTY=N_ELEMS>0;
    ISN_EMPTY=~all(SIZE==0);
    % special names
    switch (TAG(1))
        case {'?', '!'}
            % ignore entity declarations and processing instructions
            % Note: we also ignore the <?xml ...> entry with version number.
            i=i+1;
            continue;
    end
    
    if isempty(xmlTBVersion) && (level==0)
        % this is possibly a version 1.x XML string
        if (strcmp(TAG, 'struct') || ...
                strcmp(TAG, 'double') || ...
                strcmp(TAG, 'char') || ...
                strcmp(TAG, 'boolean') || ...
                strcmp(TAG, 'complex') || ...
                strcmp(TAG, 'sparse') || ...
                strcmp(TAG, 'cell'))
            xmlTBVersion = 1.0;
            NAME = 'root';
        else
            % att_switch is probably set to 'off'
            xmlTBVersion = 2.0;
        end
    end
    
    if (xmlTBVersion >= 2.0)
        % from version 2.0 we have NAME = TAG and TYPE is
        % usually given, except when using att_switch=off
        NAME = TAG;
        if isempty(TYPE)
            TYPE = 'char';
        end
    else % (xmlTBVersion < 2.0)
        % version 1.0 has type as tag and name as attribute.
        % if no name is given, assign 'item'
        TYPE = TAG;
        if isempty(NAME)
            NAME = 'item';
        end
    end
    
    % remove namespace from NAME
    f = findstr(NAME, ':');
    if ~isempty(f)
        NAME = NAME(f+1:end);
    end
    
    % remove namespace from TYPE
    f = find(TYPE==':');
    if ~isempty(f)
        TYPE = TYPE(f+1:end);
    end
    
    % make sure TYPE is valid
    if isempty(NAME) || isempty(TYPE)
        error('NAME or TYPE is empty!')
    end
    
    % check if type is correct
    if strcmp(TYPE, 'char') && any(content=='<')
        if strcmp(att_switch, 'on')
            TYPE = 'struct';
        else
            TYPE = 'parent';
        end
    end
    
    % check if index is correct
    if IDX==0
        IDX = [];
    end
    
    if ~isempty(X) && isfield(X, NAME) && isempty(IDX)
        cont_list = {X.(NAME)};
        found = 0;
        % this loop makes sure that the current entry is inserted
        % after the last non-empty entry in the content vector cont_list
        for cc=length(cont_list):-1:1
            if ~isempty(cont_list{cc})
                found=1;
                break
            end
        end
        if ~found
            IDX = max(cc-1,1);
        else
            IDX = cc+1;
        end
    end
    
    if isempty(IDX) && ~isempty(X) && strcmp(NAME, 'item')
        % make sure that when we have a character array the IDX of the
        % new vector is set to 2 and not to the end+1 index of the string.
        if isa(X, 'char')
            IDX = 2;
        else
            IDX = length(X)+1;
        end
    end
    
    if isempty(IDX)
        if isCellOnTopForSure
            %IDX=fix(i*0.5);
            IDX=itemCount;
        else
            % if everything else did not produce a result, assign IDX=1
            IDX = 1;
        end
     end
    
    % switch board which decides how to convert contents according to TYPE
    switch lower(TYPE)
        
        % ========================
        case '?xml'
            % xml version definition
            % NOTE: this is never reached from xml_tb_version >= 2.0
            xmlVersion = content;
            
            % ========================
        case '!--'
            % comment, just ignore
            i = i+1;
            continue
            
            % ========================
        case {'logical', 'boolean'}
            c = logical(str2num(content));
            if ISN_EMPTY
                c = reshape(c, SIZE);
            end
            
            % ========================
        case {'char', 'string'}
            c = charunsubst(content);
            if isempty(c) && (length(c) ~= N_ELEMS)
                % this is a string containing only spaces
                c = blanks(N_ELEMS);
            end
            %
            if ISN_EMPTY
                c = reshape(c, SIZE);
            end
            
            % ========================
        case {'struct' , 'parent'}
            c = xmlparse(content, att_switch, struct(), level+1);
            
            if ~(N_ELEMS==1)
                c = reshape(c, SIZE);
            end
            
            if isfield(c, 'item') && strcmp(TYPE, 'struct')
                c = {c.item};
            end
            
            % ========================
        case 'cell'
            tmp_c = xmlparse(content, att_switch, {}, level+1,TYPE);
            
            if ISN_EMPTY
                tmp_c = reshape(tmp_c, SIZE);
            end
            
            if ~isempty(tmp_c)
                if isfield(tmp_c, 'item')
                    c = {tmp_c.item};
                else
                    % otherwise leave as is.
                    c = tmp_c;
                end
            else
                c = {};
            end
            % ========================
            % NUMERIC TYPE
        otherwise
            %c = feval(TYPE,str2num(content));
            c = feval(TYPE,sscanf(content,'%f').');
            if ISN_EMPTY
                c = reshape(c, SIZE);
            end
    end
    
    % now c contains the content variable
    
    if isempty(X) && IDX==1 && level==0
        if strcmp(NAME, 'item')
            % s = '<item>aaa</item>'
            X = {};
            X(IDX) = {c};
        else
            % s = '<root>aaa</root>'
            X = c;
        end
        
    elseif isempty(X) && IDX==1 && level>0
        if strcmp(NAME, 'item')
            % s = '<root><item>bbb</item></root>'
            % s = '<root><item idx="1">a</item><item idx="2">b</item></root>'
            X = {};
            X(IDX) = {c};
        else
            % s = '<root><a>bbb</a></root>'
            %X = setfield(X, {IDX}, NAME, c);
            X(IDX).(NAME)=c;
        end
        
    elseif isempty(X) && IDX>1 && level==0
        % s = '<root idx="4">hello</root>'
        % s = '<item idx="4">hello</item>'
        X = {};
        X(IDX) = {c};
        
    elseif isempty(X) && IDX>1 && level>0
        % s = '<root><ch idx="4">aaaa</ch></root>'
        % s = '<item><ch idx="4">aaaa</ch></item>'
        if strcmp(NAME, 'item')
            X = {};
            X(IDX) = {c};
        else
            %X = setfield(X, {IDX}, NAME, c);
            X(IDX).(NAME)=c;
        end
        
    elseif ~isempty(X) && IDX==1 && level==0
        % s = '<item idx="3">aaa</item><item idx="1">bbb</item>'
        if strcmp(NAME, 'item')
            X(IDX) = {c};
        else
            if ~(nargin<3)
                % Example: a.b = 111; d = xmlparse(str, '', a);
                % this only works if both are structs and X is not empty
                if isempty(X) || ~(isa(X, 'struct') && isa(c, 'struct'))
                    X = c;
                else
                    % transfer all fields from c to X
                    N = fieldnames(c);
                    for n=1:length(N)
                        %X = setfield(X, {IDX}, N{n}, c.(N{n}));
                        X(IDX).(N{n})=c.(N{n});
                    end
                end
            else
                % s = '<root idx="3">aaa</root><root idx="1">bbb</root>'
                % s = '<root>aaa</root><root>bbb</root>'
                % s = '<a><b>444</b></a><a><b>555</b></a>'
                error(['XML string cannot have two ''root'' entries at root level! \n',...
                    'Possible solution: Use ''item'' tags instead.']);
            end
        end
        
    elseif ~isempty(X) && IDX==1 && level>0
        
        if strcmp(NAME, 'item')
            % s = '<root><item idx="2">bbb</item><item idx="1">ccc</item></root>'
            X(IDX) = {c};
        else
            % s = '<root><a idx="2">bbb</a><a idx="1">ccc</a></root>'
            %X = setfield(X, {IDX}, NAME, c);
            %idxCell=num2cell(IDX);
            X(IDX).(NAME)=c;
        end
        % BUT:
        % s = '<root><a idx="2"><b>ccc</b></a><a idx="1">ccc</a></root>'
        % fails because struct a has different content!
        
    elseif ~isempty(X) && IDX>1 && level==0
        
        % s = '<item idx="1">a</item><item idx="2">b</item>'
        % s = '<item idx="1">a</item><item idx="2">b</item><item idx="3">c</item>'
        if isa(X,'char')
            % s = '<item idx="1">a</item><item idx="2">b</item>'
            X = {X};
            %else (if not char) we would have eg the third entry as X
            %s = '<item idx="1">a</item><item idx="2">b</item><item idx="3">c</item>'
            %and do not need to take action
        end
        X(IDX) = {c};
        
    elseif ~isempty(X) && IDX>1 && level>0
        
        % s = '<root><item idx="1">a</item><item idx="2">b</item><item idx="3">c</item></root>'
        if strcmp(NAME, 'item')
            if isa(X,'char')
                % s = '<root><item idx="1">a</item><item idx="2">b</item></root>'
                X = {X};
            end
            X(IDX) = {c};
        else
            % s = '<root><a>bbb</a><a>ccc</a></root>'
            %X = setfield(X, {IDX}, NAME, c);
            X(IDX).(NAME)=c;
        end
        
    else
        
        disp('This case cannot be processed:')
        disp(['isempty(X) = ', num2str(isempty(X))])
        disp(['class(X)   = ', class(X)])
        disp(['class(c)   = ', class(c)])
        disp(['IDX        = ', num2str(IDX)])
        disp(['LEVEL      = ', num2str(level)])
        disp('Please contact the author m.molinari@soton.ac.uk!');
    end
    
    clear c;
    i = i+1;
    
end

if level == 0
    % before we finally leave we should clean up variable
    % xmlTBVersion used as persistent in this function
    clear xmlTBVersion
end




% ==========================================================
function V = charunsubst(V)
% re-substitutes functional characters
% e.g. from '&lt;' to '<'.
%
V=strrep(V,'&amp;','&');
V=strrep(V,'&lt;','<');
V=strrep(V,'&gt;','>');
V=strrep(V,'&apos;','''');
V=strrep(V,'&quot;','"');
%

% ==========================================================
function f = strfind(longstr, str)
% find positions of occurences of string str in longstr
if size(longstr,2) < size(str,2)
    f=[];
    return
else
    f = findstr(str, longstr);
end