function cstr = strsplit(strarr, ch)
%function cstr = strsplit(strarr, ch)
%
% FUNCTIONALITY 
% Splits string <strarr> at positions where substring <ch>
% occurs. If <ch> is not given, then ascii character 10 
% (newline) is the splitting position. 
% This would split for example a read-in file into its lines.
%
% INPUT 
%   strarr     string to split
%   ch         optional, character or substring at which to split, 
%              default is character ascii 10 = 'newline'
%
% OUTPUT 
%   cstr       cell array of strings, all leading and trailing
%              spaces are deleted. Substring ch is removed from string.
%
% EXAMPLES 
%   a = strsplit('aaa bbb ccc ', ' ')
%   Result: a{1}='aaa', a{2}='bbb', a{3}='ccc'
%   a = strsplit('user@server', '@')
%   Result: a{1}='user', a{3}='server'
%   a = strsplit('aabbccddeeffgg', 'dd')
%   Result: a{1}='aabbcc', a{2} = 'eeffgg'
%
% SEE ALSO: strfun
%
% -------------------------------------------------------
% Copyright Marc Molinari 2002, University of Southampton

% VERSION CONTROL 
%  0.1 16/06/2002 stringify created by <m.molinari@soton.ac.uk>
%  0.2 26/09/2002 extended ignored comments to ';','%'
%  0.3 27/09/2002 renamed to strsplit.m
%  0.4 13/10/2002 extended to also accept strings in ch
%  0.5 18/12/2002 adapted return value to return [''] if string is empty

if nargin<2
  ch = 10; % find ascii 10
end
cstr = [''];

f = findstr(strarr, ch);

if isempty(f)
  temp = deblank(strarr(end:-1:1));
  temp = deblank(temp(end:-1:1));
  if ~isempty(temp)
    cstr = {temp};
  end
  return
end

f(end+1) = length(strarr)+1;

if f(1) > 1
  str = deblank(strarr(1:f(1)-1));
  temp = deblank(str(end:-1:1));
  str = temp(end:-1:1);
  if ~isempty(str), cstr = {str}; end
end

for l=2:length(f)
  nstr = deblank( strarr( f(l-1)+length(ch) : f(l)-1 ) );
  temp = deblank( nstr(end:-1:1) );
  nstr = temp(end:-1:1);
  if ~isempty(nstr)
    cstr = [cstr, {nstr}];
  end
end