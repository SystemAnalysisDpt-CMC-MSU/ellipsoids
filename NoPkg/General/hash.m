function hashVec=hash(objB,methodName)
% OBJECTHASH counts the hash of the 
% complicated object
%
% Usage: hashVec=objecthash(objB)
%
% input:
%   regular:
%       objB: object, a cell a struct or a double(logical, int32 e.t.c)
%       methodName: string, one of theese {'MD2','MD5','SHA-1','SHA-256','SHA-384','SHA-512'}
%
% output:
%   hashVec: hash of the complicated object.
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
if nargin<2
    methodName='SHA-1';
end
switch (class(objB))
    case 'struct', 
        hashVec=structhash(objB,methodName);
    case 'cell',
        hashVec=cellhash(objB,methodName);
    otherwise,
        if ~isempty(objB)    
            hashVec=hashinner(objB,methodName);
        else
            hashVec=hashinner('valueisemptynohash',methodName);
        end
end


function hashVec=structhash(structB,methodName)
fieldNames=fieldnames(structB);
hashMat=hash([{'itisastruct';num2str(size(structB))};fieldNames],methodName);
%for iField=1:length(fieldNames)
%    hashMat=[hashMat; hash(structB.(fieldNames{iField}),methodName)];
%end
hashMat=[hashMat;cellhash(struct2cell(structB),methodName)];
hashVec=hash(hashMat,methodName);

function hashVec=cellhash(cellB,methodName)
%
hashCell=cellfun(@(x)hash(x,methodName),cellB,'UniformOutput',false);
hashCell=reshape(hashCell,[],1);
hashMat=cell2mat(hashCell);
hashMat=[hash(['itisacell' num2str(size(cellB))]);hashMat];
hashVec=hash(hashMat,methodName);


function h = hashinner(inp,meth)
% HASH - Convert an input variable into a message digest using any of
%        several common hash algorithms
%
% USAGE: h = hash(inp,'meth')
%
% inp  = input variable, of any of the following classes:
%        char, uint8, logical, double, single, int8, uint8,
%        int16, uint16, int32, uint32, int64, uint64
% h    = hash digest output, in hexadecimal notation
% meth = hash algorithm, which is one of the following:
%        MD2, MD5, SHA-1, SHA-256, SHA-384, or SHA-512 
%
% NOTES: (1) If the input is a string or uint8 variable, it is hashed
%            as usual for a byte stream. Other classes are converted into
%            their byte-stream values. In other words, the hash of the
%            following will be identical:
%                     'abc'
%                     uint8('abc')
%                     char([97 98 99])
%            The hash of the follwing will be different from the above,
%            because class "double" uses eight byte elements:
%                     double('abc')
%                     [97 98 99]
%            You can avoid this issue by making sure that your inputs
%            are strings or uint8 arrays.
%        (2) The name of the hash algorithm may be specified in lowercase
%            and/or without the hyphen, if desired. For example,
%            h=hash('my text to hash','sha256');
%        (3) Carefully tested, but no warranty. Use at your own risk.
%        (4) Michael Kleder, Nov 2005
%
% EXAMPLE:
%
% algs={'MD2','MD5','SHA-1','SHA-256','SHA-384','SHA-512'};
% for n=1:6
%     h=hash('my sample text',algs{n});
%     disp([algs{n} ' (' num2str(length(h)*4) ' bits):'])
%     disp(h)
% end
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2006 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2006 $

inp=inp(:);
% convert strings and logicals into uint8 format
if ischar(inp) || islogical(inp)
    inp=uint8(inp);
else % convert everything else into uint8 format without loss of data
    
    inp=typecast(inp,'uint8');
end

% verify hash method, with some syntactical forgiveness:
meth=upper(meth);
switch meth
    case 'SHA1'
        meth='SHA-1';
    case 'SHA256'
        meth='SHA-256';
    case 'SHA384'
        meth='SHA-384';
    case 'SHA512'
        meth='SHA-512';
    otherwise
end
algs={'MD2','MD5','SHA-1','SHA-256','SHA-384','SHA-512'};
if isempty(strmatch(meth,algs,'exact'))
    error(['Hash algorithm must be ' ...
        'MD2, MD5, SHA-1, SHA-256, SHA-384, or SHA-512']);
end

% create hash
x=java.security.MessageDigest.getInstance(meth);
x.update(inp);
h=typecast(x.digest,'uint8');
h=dec2hex(h)';
if(size(h,1))==1 % remote possibility: all hash bytes < 128, so pad:
    h=[repmat('0',[1 size(h,2)]);h];
end
h=lower(h(:)');
clear x
return