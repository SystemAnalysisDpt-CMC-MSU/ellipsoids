function [X,metaData] = xmlload( file )
% XMLLOAD loads XML file and converts it into Matlab structure or variable.
%
% Input: 
%   regular:
%       file: char[1,] -  filename of xml file written with xmlsave
%
% Output:
%   X: anysupportedtype[...] - structure variable containing file contents
%       metaData: struct[1,1] - structure containing a meta-infromation loaded
%       from the specified file at the root level
%
% See also:
%   xmlformat, xmlparse, xmlsave, (xmlread, xmlwrite)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

% set XML TB version number
xml_tb_version = '2.0';

% check input parameters
if (nargin<1)
  error([mfilename,' requires 1 parameter: filename.']);
end

% append '.xml'
if ~exist(file)
  if isempty(findstr(lower(file),'.xml'))
    file = strcat(file, '.xml');
  end
end

%-----------------------------------------------
% check existence of file
if (~exist(file))
  error([mfilename, ': could not find ', file]);
end
%-----------------------------------------------
%Use java parser as a temporary tool to check that xml is well-formed
try
    evalc('xmlread(file)');
catch meObj
    newMeObj=MException([upper(mfilename),':wrongInput'],...
        'xml is not well formed');
    newMeObj=newMeObj.addCause(meObj);
    throw(newMeObj);
end
%-----------------------------------------------
fid = fopen(file, 'r');
if fid==-1
  error(['Error while opening file ', file, ' for reading.']);
end

% parse file content into blocks
str = char( fread(fid)' ); % read in whole file
fclose( fid );

if (length(str)<3)
  error([file, ' does not seem to be a valid xml file.']);
end

%-----------------------------------------------
% parse content, identify blocks
[X,metaData] = xmlparse(str);