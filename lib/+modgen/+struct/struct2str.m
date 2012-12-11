function resStr=struct2str(SInp,varargin)
% STRUCDISP  display structure outline
%
% Usage: STRUCT2STR(STRUC,fileName,'depth',DEPTH,'printValues',PRINTVALUES,...
%           'maxArrayLength',MAXARRAYLENGTH) stores
%        the hierarchical outline of a structure and its substructures into
%        the specified file
%
% Input:
%   regular:
%       SInp: struct[1,1] - is a structure datatype with unknown field
%           content. It can be  either a scalar or a vector, but not a
%           matrix. STRUC is the only mandatory argument in this function.
%           All other arguments are optional.
%
%   optional
%       fileName: char[1,] is the name of the file to which the output
%           should be printed. if this argument is not defined, the output
%           is printed to the command window.
%
%   properties
%       depth: numeric[1,1] - the number of hierarchical levels of
%           the structure that are printed. If DEPTH is smaller than zero,
%           all levels are printed. Default value for DEPTH is -1
%           (print all levels).
%
%       printValues: logical[1,1] -  flag that states if the field values
%           should be printed  as well. The default value is 1 (print values)
%
%       maxArrayLength: numeric[1,1] - a positive integer,
%           which determines up to which length or size the values of
%           a vector or matrix are printed. For a  vector holds that
%           if the length of the vector is smaller or equal to
%           MAXARRAYLENGTH, the values are printed. If the vector is
%           longer than MAXARRAYLENGTH, then only the size of the
%           vector is printed. The values of a 2-dimensional (m,n)
%           array are printed if the number of elements (m x n) is
%           smaller or equal to MAXARRAYLENGTH. For vectors and arrays,
%           this constraint overrides the PRINTVALUES flag.
%       numberFormat: char[1,] - format specification used for displaying
%           numberic values, passed directly to sprintf, by default '%g' is
%           used
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08-18 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
resStr=strucdisp(SInp,varargin{:});