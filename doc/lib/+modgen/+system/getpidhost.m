function [pidHostStr,pidVal,hostName]=getpidhost()
%GETPIDHOST returns process id (PID) of current Matlab instance along with
%a host name it is running on
%
% Output:
%   pidHostStr: char[1,] - pid/host string in pid@host format  
%   pid: double[1,1] - pid of current Matlab instance
%   hostName: char[1,] - host name
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
pidHostStr=char(...
    java.lang.management.ManagementFactory.getRuntimeMXBean().getName());
if nargout>1
    resCell=strsplit(pidHostStr,'@');
    pidVal=str2double(resCell{1});
    hostName=resCell{2};
end