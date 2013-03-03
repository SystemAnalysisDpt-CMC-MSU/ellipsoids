function [SInfo,isVersioned]=getfileinfo(fullFileName)
% GETFILEINFO generates a structure with svn file methadata including
% revision, last modification date etc.
%
% Input:
%   regular:
%       fullFileName: char[1,] - full file name
%
% Output:
%   SInfo: struct[1,1] - resulting file info
%   isVersioned: logical[1,1] - indicates whether the specified file is
%       versioned
%
% Example:
%
% SInfo=modgen.subversion.getfileinfo('C:\MySVNWorkingCopy\myfile.m')
%
%        returns
%
% SInfo=
%
%                    path: 'C:\MySVNWorkingCopy\myfile.m'
%                    name: 'myfile.m'
%     workingCopyRootPath: 'MySVNWorkingCopy'
%                     uRL: [1x81 char]
%          repositoryRoot: 'https://mysvnserveraddress.com'
%          repositoryUUID: 'ad8adf1d-3c4f-4f16-b4fd-ec115ca36637'
%                revision: '53'
%                nodeKind: 'file'
%                schedule: 'normal'
%       lastChangedAuthor: 'dane'
%          lastChangedRev: '53'
%         lastChangedDate: [1x44 char]
%         textLastUpdated: [1x44 char]
%                checksum: 'd53792175d11aedff70c799ab925297ea55820bb'
%
% $Author: Peter Gagarinov $	$Date: 2012/10/13 20:34:16 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import modgen.subversion.svncall;
import modgen.subversion.getrevisionbypath;
rev=getrevisionbypath(fullFileName);
if strcmp(rev,'unversioned')
    SInfo=struct();
    isVersioned=false;
else
    isVersioned=true;
    propNameValueList=svncall(sprintf('info "%s@"',fullFileName));
    
    %
    propNameValueCList=cellfun(@(x)strsplit(x,': '),...
        propNameValueList(1:end-1),...
        'UniformOutput',false);
    propNameValueCMat=vertcat(propNameValueCList{:});
    propNameValueCMat(:,1)=cellfun(@formFieldName,propNameValueCMat(:,1),...
        'UniformOutput',false);
    %
    propNameValueCMat=transpose(propNameValueCMat);
    %
    SInfo=struct(propNameValueCMat{:});
end
end
function fieldName=formFieldName(inputStr)
fieldName=strrep(inputStr,' ','');
fieldName(1)=lower(fieldName(1));
end
