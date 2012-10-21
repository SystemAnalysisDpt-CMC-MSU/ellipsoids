function [uuidStr, leastSignificantBits, mostSignificantBits] = getuuid()
% GETUUID returns a random UUID (Universally Unique IDentifier)
%
% Output:
%   uuidStr: char[1,] - a string representation of the UUID (see
%     http://java.sun.com/j2se/1.5.0/docs/api/java/util/UUID.html#toString()
%     for details). Example: '6e8349f6-df71-41bd-8230-1fe32cd3e058'
%   leastSignificantBits: int64[1,1] - least significant 64 bits of this
%     UUID's 128 bit value
%   mostSignificantBits: int64[1,1] - most significant 64 bits of this
%     UUID's 128 bit value
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

uuid = java.util.UUID.randomUUID();
uuidStr = char( uuid.toString() );
leastSignificantBits = int64( uuid.getLeastSignificantBits() );
mostSignificantBits = int64( uuid.getMostSignificantBits() );