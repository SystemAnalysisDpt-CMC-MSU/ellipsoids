function [pidHostStr,pidVal,hostName]=getpidhost()
%GETPIDHOST returns process id (PID) of current Matlab instance along with
%a host name it is running on
%
% Output:
%   pidHostStr: char[1,] - pid/host string in pid@host format  
%   pid: double[1,1] - pid of current Matlab instance
%   hostName: char[1,] - host name
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
pidHostStr=char(...
    java.lang.management.ManagementFactory.getRuntimeMXBean().getName());
if nargout>1
    resCell=strsplit(pidHostStr,'@');
    pidVal=str2double(resCell{1});
    hostName=resCell{2};
end