function xstr = xmlformat(V, att_switch, name, level,metaData)
% XMLFORMAT formats the variable V into a name-based tag XML string xstr
%
% Input:
%   regular:
%      V: struct[...] - Matlab variable or structure.
%            The data types we can deal with are:
%              char, numeric, complex, struct, sparse, cell, logical/boolean
%            Not handled are data types:
%              function_handle, single, intxx, uintxx, java objects
%
%   optional:
%       att_switch: char[1,]-   optional, 'on'- writes attributes,
%           'off'- writes "plain" XML
%       name: char[1,] - optional, give root element a specific name,
%           eg. 'books'
%       level: double[1,1] -  internal, increases tab padding at
%           beginning of xstr
%       metaData: struct[1,1] - structure with meta information for
%           a root tag
%
% Output:
%   xstr: char[1,] - string, containing XML description of variable V
%
% See also
%   xmlhelp, xmlparse, xmlload, xmlsave, (xmlread, xmlwrite)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-26 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
% set XML TB version number
xml_tb_version = '2.0';

% check input parameters
if (nargin<1)
    error([mfilename, ' needs at least 1 parameter.']);
end

if nargin<2
    att_switch = 'on';
else
    att_switch=lower(att_switch);
end
isForceAtt=strcmpi(att_switch,'forceon');
isAtt=isForceAtt||strcmpi(att_switch,'on');

if ((nargin<3) || isempty(name)),  name = 'root'; end
if ((nargin<4) || isempty(level)), level = 0; end
if nargin<5
    metaData=struct();
end

% ----------------
% string definitions
xstr = '';
if level==0
    padd=char.empty(1,0);
else
    padd(1,level)=' ';
    padd(:)=sprintf('\t');
end
%padd = repmat(sprintf('\t'),1,level); % indentation
%
NL = sprintf('\n'); % newline
attributes = '';

% determine variable properties
att.name = name;
att.type = typeclass(V);

% add entry tag for level=0
if level==0
    fieldNameList=fieldnames(metaData);
    nFields=length(fieldNameList);
    attributes='';
    for iField=1:nFields
        fieldName=fieldNameList{iField};
        attributes=[attributes,' ',fieldName,'=','"',metaData.(fieldName),...
            '"'];
    end
    if isAtt
        attributes = [attributes, ' xml_tb_version="',xml_tb_version,'" ', ...
            'type="', att.type, '" '];
        if notisrow(V)
            sizeVec=size(V);
            att.size = mynum2str(sizeVec);
            attributes=[attributes, ...
                'size="', att.size,'"'];
        end
    end
    xstr = [xstr, '<', name, attributes];
end

if isempty(V)
    xstr = [xstr, '/> ', NL];
    return
end

% ------------------
switch lower(att.type)
    
    case {'char', 'string'}
        % substitute functional characters &<> etc. with their ascii equivalent
        content = V(:).';
        %
        content=strrep(content,'&','&amp;');
        content=strrep(content,'<','&lt;');
        content=strrep(content,'>','&gt;');
        content=strrep(content,'''','&apos;');
        content=strrep(content,'"','&quot;');
        xstr = [xstr, '>', content, '</', name, '>', NL];
        
    case 'struct'
        xstr = [xstr, '>', NL];
        
        N = fieldnames(V);
        nElem=numel(V);
        for cV = 1:nElem
            for n = 1:length(N)
                % get content
                child.content = V(cV).(N{n});
                child.attributes = '';
                % write attributes
                if isAtt
                    child.att.idx = cV;
                    child.att.type = typeclass(child.content);
                    %
                    child.attributes = [' type="', child.att.type, '" '];
                    if (nElem>1)
                        child.attributes = [' idx="', sprintf('%d',cV), '"', ...
                            child.attributes];
                    end
                    if notisrow(child.content)
                        sizeVec=size(child.content);
                        child.att.size = deblank(sprintf('%d ', sizeVec));
                        child.attributes=[child.attributes,...
                            'size="', child.att.size,'"'];
                    end
                end
                % write header
                xstr = [xstr, padd, '<', N{n}, child.attributes];
                % write content
                str =xmlformat(child.content, att_switch, N{n}, level+1);
                xstr = [xstr, str];
            end
        end
        xstr = [xstr, padd(1:end-1), '</', name, '>', NL];
        
    case 'cell'
        xstr = [xstr, '>', NL];
        nElem=numel(V);
        for n=1:nElem
            child.content = V{n};
            % write header
            xstr = [xstr, padd, '<item'];
            if isAtt
                child.att.idx = n;
                child.att.type = typeclass(child.content);
                child.attributes = [' type="', child.att.type, '" '];
                %
                %        if nElem>1
                %             child.attributes = [' idx="', sprintf('%d',child.att.idx), '"',...
                %                 child.attributes];
                %         end
                if notisrow(child.content)
                    child.att.size = mynum2str(size(child.content));
                    child.attributes=[child.attributes, 'size="', child.att.size,'"'];
                end
                xstr = [xstr, child.attributes];
            end
            % write content
            xstr = [xstr, xmlformat(child.content, att_switch, 'item', level+1)];
        end
        xstr = [xstr, padd(1:end-1), '</', name, '>', NL];
        
    case 'sparse'
        % save three arrays: indices i, indices j, entries (i,j) as cell arrays
        xstr = [xstr, '> ', NL];
        [i,j,k] = find(V);
        if numel(i) > 0
            L = sprintf('%d ', size(i)); % = size(j) = size(k)
            
            xstr = [xstr, padd, '<item'];
            if isAtt
                xstr = [xstr, sprintf(' type="double" idx="1" size="%s"', L(1:end-1))];
            end
            xstr = [xstr, xmlformat(i, att_switch, 'item', level+1)];
            
            xstr = [xstr, padd, '<item'];
            if isAtt
                xstr = [xstr, sprintf(' type="double" idx="2" size="%s"', L(1:end-1))];
            end
            xstr = [xstr, xmlformat(j, att_switch, 'item', level+1)];
            
            xstr = [xstr, padd, '<item'];
            if isAtt
                xstr = [xstr, sprintf(' type="%s" idx="3" size="%s"', typeclass(k), L(1:end-1))];
            end
            xstr = [xstr, xmlformat(k, att_switch, 'item', level+1)];
        end
        xstr = [xstr, padd(1:end-1), '</', name, '>', NL];
        
    case 'complex'
        % save two arrays: real and imag as cell arrays
        xstr = [xstr, '> ', NL];
        R = real(V);
        I = imag(V);
        if numel(R) > 0
            L = sprintf('%d ', size(R)); % = size(I)
            
            xstr = [xstr, padd, '<item'];
            if isAtt
                xstr = [xstr, sprintf(' type="double" idx="1" size="%s"', L(1:end-1))];
            end
            xstr = [xstr, xmlformat(R, att_switch, 'item', level+1)];
            
            xstr = [xstr, padd, '<item'];
            if isAtt
                xstr = [xstr, sprintf(' type="double" idx="2" size="%s"', L(1:end-1))];
            end
            xstr = [xstr, xmlformat(I, att_switch, 'item', level+1)];
        end
        xstr = [xstr, padd(1:end-1), '</', name, '>', NL];
        
    otherwise %numeric type
        try
            content = sprintf('%0.16g ', V(:));
        catch meObj
            newObj=modgen.common.throwerror('wrongInput:wrongType',...
                'type %s is not supported',att.type);
            newObj=addCause(newObj,meObj);
            throw(newObj);
        end
        xstr = [xstr, '>', content(1:end-1), '</', name, '>', NL];
end

return

% ==========================================================
    function C = typeclass(V)
        % handled classes are
        %  char, numeric, complex, struct, sparse, cell, logical
        % not handled yet are:
        %  function_handle, single, intxx, uintxx, java objects
        
        C = class(V);
        
        if ischar(V)
            C = 'char';   % char
            return
        end
        
        if isstruct(V)
            C = 'struct'; % struct
            return
        end
        
        if iscell(V)
            C = 'cell';   % cell
            return
        end
        
        if isnumeric(V)
            if ~isreal(V)
                modgen.common.throwerror('wrongInput:wrongType',...
                    'complex numbers are not supported');
            elseif issparse(V)
                modgen.common.throwerror('wrongInput:wrongType',...
                    'sparse double arrays are not supported');
            end
            %
            C=class(V);
            return;
        end
        %
        if islogical(V)     % logical / boolean
            C = 'boolean';
            return
        end
    end
    function isPositive=notisrow(inpArray)
        isPositive=isForceAtt||(size(inpArray,1)~=1||...
            numel(inpArray)~=length(inpArray)||...
            ndims(inpArray)~=2||isempty(inpArray));
    end
    function s=mynum2str(aVec)
        s=sprintf('%d ',aVec);
        s=s(1:end-1);
    end
end