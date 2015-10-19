function [taskName,SProp]=gettaskname()
% GETTASKNAME returns task name and some additional properties
%
% Usage: [taskName,SProp]=gettaskname()
%
% Input:
%
% Output:
%   taskName: char[1,] - name of the current task
%   SProp: struct[1,1] - properties structure with the following fields:
%       isMain: logical[1,1] - true if current process is main, false if child
%       taskId: numerical[1,1] - number of child task
%       taskName: char[1,] - same as above
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[isParTbxInstalled,isAltPartTbxInstalled]=...
    modgen.pcalc.isparttbxinst();
%
if isAltPartTbxInstalled
    %
    [taskName,SProp]=modgen.pcalcalt.gettaskname();
elseif isParTbxInstalled
    %
    [taskName,SProp]=modgen.pcalc.gettasknamepcomp();
else
    taskName='master';
    SProp.isMain=true;
    SProp.taskId='';
    SProp.taskName=taskName;
end
