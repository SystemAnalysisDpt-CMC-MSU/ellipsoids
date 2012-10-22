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
curTaskObj=getCurrentTask();
isMain=isempty(curTaskObj);
taskId=get(curTaskObj,'ID');
if isMain
    taskName='master';
else
    %on windows the task name has a form Job#/Task#, while on
    %Linux - Task#. We need a unification so we remove the Job#
    %part
    curTaskName=['task',num2str(taskId)];
    %
    taskName=['child','.',curTaskName];
end
%
SProp.isMain=isMain;
SProp.taskId=taskId;
SProp.taskName=taskName;
