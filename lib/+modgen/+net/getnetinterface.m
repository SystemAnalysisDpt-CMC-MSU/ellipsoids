function netStruct=getnetinterface(varargin)
% GETNETINTERFACE returns information about all network interfaces
% connected to this computer and their addresses
%
% input:
%   properties:
%     IPv4Only: logical [1,1] - return only IPv4 addresses. Default = false
%     noLoopback: logical [1,1] - do not return loopback addresses.
%       Default = false
%     mustHaveAddress: logical [1,1] - return only interfaces that have at
%       least one address. This filter is applied after all address filters
%       are applied
% output:
%   regular:
%     netStruct: struct [,1] - each element of this structure vector is an
%       interface description with the following fields:
%         interfaceName: char [1,] - short name
%         interfaceDisplayName: char [1,] - long name
%         hardwareAddress: char [1,] - hardware address (usually MAC
%           address)
%         ipAddresses: struct [,1] - IP addresses for this interface
%       The struct vector ipAddresses has the following fields:
%         hostName: char [1,] - qualified host name, if available,
%           otherwise the same as ipAddress
%         ipVersion: char [1,] - IP version (IPv4 or IPv6)
%         ipAddress: char [1,] - IP address
%         networkPrefixLength: double [1,1] - network prefix length (number
%           of 1-bits in the subnet mask)
%         netMask: char [1,] - subnet mask (IPv4 only)
%         broadcastAddress: char [1,] - broadcast address (IPv4 only)
%         isLoopbackAddress: logical [1,1] - true if the address is a
%           loopback address
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

persistent netInterfaceCVec inetAddressCArray
%
%% Parse arguments
%
isIPv4Only = false;
isNoLoopback = false;
isMustHaveAddress = false;
%
[reg,prop]=modgen.common.parseparams(varargin,[],0);
if ~isempty(reg)
    error([upper(mfilename),':wrongInput'], 'Invalid regular argument');
end
nProp=length(prop);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'ipv4only',
            isIPv4Only = prop{k+1};
        case 'noloopback',
            isNoLoopback = prop{k+1};
        case 'musthaveaddress',
            isMustHaveAddress = prop{k+1};
        otherwise,
            error([upper(mfilename),':wrongInput'], ...
                'unidentified property name: %s ',prop{k});
    end
end
%
%% Get network info
%
if isempty(netInterfaceCVec) || isempty(inetAddressCArray)
    % Get all network interfaces for this machine
    netInterfaceList = java.util.Collections.list(...
        java.net.NetworkInterface.getNetworkInterfaces() );
    netInterfaceCVec = listToCell(netInterfaceList);
    % Get IP addresses for each interface
    inetAddressCArray = cellfun(@(x)listToCell(x.getInterfaceAddresses()),...
        netInterfaceCVec, 'UniformOutput', false);
end
%
%% Init the struct and fill out network interface fields
%
interfaceFieldsCVec = {'interfaceName','interfaceDisplayName','hardwareAddress','ipAddresses'};
nInterfaces = length(netInterfaceCVec);
netStruct = cell2struct(cell(length(interfaceFieldsCVec), nInterfaces), interfaceFieldsCVec, 1);
%
nameCVec = cellfun(@(x)char(x.getName()), netInterfaceCVec,...
    'UniformOutput', false);
displayNameCVec = cellfun(@(x)char(x.getDisplayName()), netInterfaceCVec,...
    'UniformOutput', false);
hardwareCVec = cellfun(@(x)formatHardwareAddress(x.getHardwareAddress()),...
    netInterfaceCVec, 'UniformOutput', false);
[netStruct.interfaceName] = deal( nameCVec{:} );
[netStruct.interfaceDisplayName] = deal( displayNameCVec{:} );
[netStruct.hardwareAddress] = deal( hardwareCVec{:} );
%
%% Fill out IP address fields
%
ipFieldsCVec = {'hostName','ipVersion','ipAddress','networkPrefixLength',...
    'netMask','broadcastAddress','isLoopbackAddress'};
for iInt = 1:nInterfaces
    interfaceAddressCVec = inetAddressCArray{iInt};
    % IPv4 addresses are 32-bit, IPv6 addresses are 128-bit
    isIPv4Vec = cellfun(@(x)length(x.getAddress().getAddress())==4,...
        interfaceAddressCVec);
    isIPv6Vec = cellfun(@(x)length(x.getAddress().getAddress())==16,...
        interfaceAddressCVec);
    isLoopbackVec = cellfun(@(x)x.getAddress.isLoopbackAddress(),...
        interfaceAddressCVec);
    % Filter by IPv4Only and noLoopback flags
    isIncludedVec = (isIPv4Vec | ~isIPv4Only) & (~isLoopbackVec | ~isNoLoopback);
    interfaceAddressCVec(~isIncludedVec) = [];
    %
    % Init IP struct
    nAddresses = length(interfaceAddressCVec);
    ipStruct = cell2struct(cell(length(ipFieldsCVec), nAddresses), ipFieldsCVec, 1);
    %
    [ipStruct(isIPv4Vec(isIncludedVec)).ipVersion] = deal('IPv4');
    [ipStruct(isIPv6Vec(isIncludedVec)).ipVersion] = deal('IPv6');
    [ipStruct(isLoopbackVec(isIncludedVec)).isLoopbackAddress] = deal(true);
    [ipStruct(~isLoopbackVec(isIncludedVec)).isLoopbackAddress] = deal(false);
    %
    for iAddr = 1:nAddresses
        interfaceAddress = interfaceAddressCVec{iAddr};
        inetAddress = interfaceAddress.getAddress();
        %
        ipStruct(iAddr).hostName = char( inetAddress.getCanonicalHostName() );
        %
        ipStruct(iAddr).ipAddress = char( inetAddress.getHostAddress() );
        %
        % Broadcast addresses are only used for IPv4 addresses
        if strcmp(ipStruct(iAddr).ipVersion, 'IPv4')
            ipStruct(iAddr).broadcastAddress = char( interfaceAddress.getBroadcast.getHostAddress() );
        end
        %
        ipStruct(iAddr).networkPrefixLength = interfaceAddress.getNetworkPrefixLength();
        %
        % Subnet masks are only used for IPv4 addresses
        if strcmp(ipStruct(iAddr).ipVersion, 'IPv4')
            ipStruct(iAddr).netMask = formatNetMask(ipStruct(iAddr).networkPrefixLength);
        end
    end
    %
    netStruct(iInt).ipAddresses = ipStruct;
end
%
if isMustHaveAddress
    netStruct( arrayfun(@(x)isempty(x.ipAddresses),netStruct) ) = [];
end
%
    function cVec = listToCell(list)
        nElem = list.size();
        cVec = cellfun(@list.get, num2cell(0:nElem-1), 'UniformOutput', false);
    end
%
    function addrStr = formatHardwareAddress(bytesVec)
        % Convert int8 to uint8
        isNeg = bytesVec < 0;
        uintBytesVec = uint8(bytesVec);
        uintBytesVec(isNeg) = 256 - uint8(-bytesVec(isNeg));
        addrStr = sprintf('%02X-',uintBytesVec);
        addrStr = addrStr(1:end-1);
    end
%
    function netMask = formatNetMask(prefixLen)
        if prefixLen < 0
            maskVec = [0,0,0,0];
        else
            maskVec = [255,255,255,255];
            nMasked = fix(prefixLen/8);
            if nMasked < 4
                maskVec(nMasked+1) = bitshift(uint8(255),...
                    8-mod(prefixLen,8));
            end
            if nMasked < 3
                maskVec(nMasked+2:end) = 0;
            end
        end
        netMask = sprintf('%d.',maskVec);
        netMask = netMask(1:end-1);
    end
end