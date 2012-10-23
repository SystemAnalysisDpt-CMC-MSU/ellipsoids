function resStr=obj2plainstr(meObj)
%OBJ2PLAINSTR does the same as OBJ2STR but without using the
%hyper-references and via a legacy function errst2str
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
resCStr=cellfun(@(x)sprintf('%s\n',x),...
    errst2str(meObj),'UniformOutput',false);
resStr=[resCStr{:}];