function [userName,hostName]=getuserhost()
persistent hostNameCached userNameCached
if nargout>1
    if isempty(hostNameCached)
        hostNameCached=char(java.net.InetAddress.getLocalHost().getCanonicalHostName());
    end
    hostName=hostNameCached;
end
if isempty(userNameCached)
    userNameCached=char(java.lang.System.getProperty('user.name'));
end
userName=userNameCached;
