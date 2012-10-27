function ret = camlight(hAxes,varargin)
%CAMLIGHT works in the same way as built-in camlight function with one
%exception - it accepts an obligatory hAxes argument that defines a parent
%axes 


defaultAz = 30;
defaultEl = 30;
defaultStyle = 'local';
createLight = 0;

if nargin>4
  error('MATLAB:camlight:TooManyInputs', 'Too many input arguments')
else  
  args = varargin;
  if ~isempty(args) && isnumeric(args{1}) && length(args{1}) > 1
    error('MATLAB:camlight:NeedHandle', 'First numeric argument must be a handle to a single light object');
  end

  if ~isempty(args) && any(ishghandle(args{1},'light'))
    h = args{1};
    args(1) = [];
  else
    createLight = 1;
  end
  
  if ~isempty(args) && validString(args{end})==2
    style = args{end};
    args(end) = [];
  else
    style = defaultStyle;
  end
  
  len = length(args);
  if len > 2
    error('MATLAB:camlight:InvalidArgument', 'Invalid arguments');
  elseif len==1
    [c az el] = validString(args{1});
    if c~=1
      error('MATLAB:camlight:InvalidArgument', '%s is an invalid argument',num2str(args{1}) );
    end
  elseif len==2
    az = args{1};
    el = args{2};
    if ~(isnumeric(az) && isreal(az) && isnumeric(el) && isreal(el))
      error('MATLAB:camlight:NotValidArguments', [num2str(az) ' and ' num2str(el) ' are not valid arguments']);
    end
  else
    az = defaultAz; el = defaultEl;
  end
end

if createLight == 1;
  h = light('Parent',hAxes);
end

ax = ancestor(h, 'axes');
pos  = get(ax, 'cameraposition' );
targ = get(ax, 'cameratarget'   );
dar  = get(ax, 'dataaspectratio');
up   = get(ax, 'cameraupvector' );

if ~righthanded(ax), az = -az; end

[newPos newUp] = camrotate(pos,targ,dar,up,az,el,'camera',[]);

if style(1)=='i'
  newPos = newPos-targ;
  newPos = newPos/norm(newPos);
end
set(h, 'position', newPos, 'style', style);

if nargout>0
  ret = h;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, az, el]= validString(str)

defaultAz = 30;
defaultEl = 30;
az = 0; el = 0;

if ischar(str)
  c1 = lower(str(1));
  
  if length(str)>1
    c2 = lower(str(2));
  else
    c2 = [];
  end
  
  if c1=='r'        %right
    ret = 1;
    az = defaultAz; el = defaultEl;
  elseif c1=='h'    %headlight
    ret = 1;
    az = 0; el = 0;
  elseif c1=='i'    %infinite
    ret = 2;
  elseif c1=='l' && ~isempty(c2)
    if c2=='o'      %local
      ret = 2;
    elseif c2=='e'  %left
      ret = 1;
      az = -defaultAz; el = defaultEl;
    else
      ret = 0;
    end
  else
    ret = 0;
  end
else
  ret = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=righthanded(ax)

dirs=get(ax, {'xdir' 'ydir' 'zdir'}); 
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);
