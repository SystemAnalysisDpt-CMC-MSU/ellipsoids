function jobObj = dfevalasync(dfcn, numArgOut, varargin)
% DFEVALASYNC is a copy of built-in DFEVALASYNC excepnt that it supports an
% additional property called 'clustersize' which specifies a maximum number
% of workers on the system
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
% Check arguments
error(nargoutchk(1,1,nargout, 'struct'))
error(nargchk(3,inf,nargin, 'struct'))

% Setup variables
stopOnError = false;
cr = sprintf('\n');

% Find out how many cell arrays have been passed in
isCellArray = cellfun('isclass', varargin, 'cell');
% The first non cell array is
firstNonCellIndex = find(~isCellArray, 1 );
% Check for only cell inputs
if isempty(firstNonCellIndex)
    firstNonCellIndex = length(isCellArray) + 1;
end
% Error out if we don't have any cell arguemnts
if isequal(firstNonCellIndex, 1)
    error('distcomp:dfevalasync:InvalidArgument', ...
        ['All input arguments (x1,...,xn) must be specified as cell arrays ' cr ...
         'and at least one input argument must be supplied. If the function' cr ...
         'being called takes no input arguments specify cell(numTasks, 0) as' cr ...
         'the input to dfeval or dfevalasync']);
end 
allInputArgs = varargin(1:firstNonCellIndex-1);
% Let's now check that the input sizes are all correct - they must be the
% same as each other in all dimensions
numDimsToCheck = max(cellfun('ndims', allInputArgs));
THROW_SIZE_ERROR = false;
for i = 1:numDimsToCheck
    allSizes = cellfun('size', allInputArgs, i);
    thisSize = allSizes(1);
    THROW_SIZE_ERROR = THROW_SIZE_ERROR || any(allSizes ~= thisSize);        
end
% Calculate how many tasks have been requested - ignore zero sized
% dimensions for this so that cell(4, 0, 4) represents 16 tasks
inputSize = size(allInputArgs{1});
inputSize(inputSize == 0) = 1;
numTasks = prod(inputSize);

if iscell(dfcn)
    THROW_SIZE_ERROR = THROW_SIZE_ERROR || numel(dfcn) ~= numTasks;
end
% Check to make sure input sizes are equal
if THROW_SIZE_ERROR 
    error('distcomp:dfevalasync:NonMatchingInputArgSize', ...
        ['The number of elements in all of the input argument cell ' cr ...
         'arrays (x1,...,xn) must be equal. If the function name input ' cr ...
         'argument, F, has also been specified as a cell array, then the ' cr ...
         'number of elements in F must also be equal to the number of ' cr ...
         'elements in the input argument cell arrays x1,...,xn.']);
end 
% Remove any empty inputs
allInputArgs(cellfun('isempty', allInputArgs)) = [];
% Now bundle this into a big cell array rather than several small ones
for i = 1:numel(allInputArgs)
    allInputArgs{i} = allInputArgs{i}(:);
end
allInputArgs = [allInputArgs{:}];
% Specifically deal with the empty input case
if isempty(allInputArgs)
    allInputArgs = cell(numTasks, 0);
end


numArgIn  = length(varargin);
numInputs = firstNonCellIndex-1;
pvLoc     = firstNonCellIndex;
%% Parse the PV inputs
findRArgs = {};
setSchedArgs = {};
jobArgs = {};
taskArgs = {};
while pvLoc<=numArgIn,
    switch class(varargin{pvLoc})
        case 'char'
            if (pvLoc + 1 > numArgIn) 
                error('distcomp:dfevalasync:InvalidPropVal', ...
                      'No value specified for the property ''%s''.', ...
                        varargin{pvLoc});
            end
            currPVPair = varargin(pvLoc:pvLoc + 1);
            switch lower(varargin{pvLoc}),
                case 'jobmanager'
                    % varargin{pvLoc+1} is the job manager name.  We forward 
                    % that to findResource as 'Name', varargin{pvLoc+1}.
                    findRArgs = [findRArgs, 'Name', varargin(pvLoc+1)]; %#ok<AGROW>
                case 'lookupurl'
                    findRArgs = [findRArgs, currPVPair]; %#ok<AGROW>
                case 'stoponerror'
                    stopOnError = varargin{pvLoc + 1};
                case 'clustersize',
                    setSchedArgs = [setSchedArgs, currPVPair]; %#ok<AGROW>
                case 'configuration'
                    findRArgs = [findRArgs, currPVPair]; %#ok<AGROW>
                    setSchedArgs = [setSchedArgs, currPVPair]; %#ok<AGROW>
                    jobArgs = [jobArgs currPVPair]; %#ok<AGROW>
                    taskArgs = [taskArgs currPVPair]; %#ok<AGROW>
                otherwise
                    jobArgs = [jobArgs currPVPair]; %#ok<AGROW>
            end % switch
            pvLoc = pvLoc+2;

%        case 'cell',
%             jobArgs=[jobArgs varargin(pvLoc:pvLoc+1)];
%             pvLoc=pvLoc+2;
        case 'struct'
            jobArgs = [jobArgs varargin(pvLoc)]; %#ok<AGROW>
            pvLoc = pvLoc+1;
        otherwise
            error('distcomp:dfevalasync:InvalidPropVal', ...
                ['Property/Value input argument ' ...
                int2str(pvLoc-numInputs) ...
                ' (DFEVALASYNC input argument ' int2str(pvLoc+1) ...
                ') is invalid.']);
    end % switch
end % while

%% Attach to the appropriate scheduler
% Put the configuration at the end so that it overrides the default, which is to
% find a job manager.
jobMgr = findResource('scheduler', 'type', 'jobmanager', findRArgs{:});

% Make sure a scheduler was found and insure that only 1 is utilized.  This
% check is guaranteed to succeed for LSF and generic.
if ~isempty(jobMgr),
    jobMgr = jobMgr(1);
else
    error('distcomp:dfevalasync:NoJobMgr', ...
        'No job managers matching specified criteria found.');
end % if ~isempty

% Finish the initialization of the scheduler object.  This is a no-op for 
% a job manager, but may set the DataLocation, etc. for 3rd party schedulers.
if ~isempty(setSchedArgs)
    set(jobMgr, setSchedArgs{:});
end

supportsCallbacks = isa(jobMgr, 'distcomp.jobmanager');

%% Create the tasks
jobObj=createJob(jobMgr,jobArgs{:});
try
    for taskLp = 1:numTasks,
        inputArgs = allInputArgs(taskLp, :);
        if iscell(dfcn),
            actdFcn = dfcn{taskLp};
        else
            actdFcn = dfcn;
        end % if
        taskObj = createTask(jobObj,actdFcn, numArgOut, inputArgs, ...
                             taskArgs{:});
        if supportsCallbacks
            % This will override the task finished function that may be defined
            % in the configuration.
            set(taskObj, 'FinishedFcn', {@taskFinish,stopOnError,taskLp});
        end
    end % for taskLp

    %% Submit the job
    submit(jobObj)

catch err
    %Clean up when an error occurs or Ctrl-C is pressed
    cancel(jobObj)
    destroy(jobObj)
    rethrow(err)
end % try/catch

function taskFinish(taskObj,eventData,stopOnError,taskNum) %#ok<INUSL>
% check for valid data coming back and that no errors occurred in the
% cluster.
cr = sprintf('\n');

taskError = get(taskObj,'ErrorMessage');
if ~isempty(taskError),
    if stopOnError,
        jobObj = taskObj.up;
        cancel(jobObj)
        destroy(jobObj)
        error('distcomp:dfevalasync:ErrorOnTaskError', ...
            ['Errors occurred during execution of task ' int2str(taskNum) ...
            '. Stopping job execution.\n%s'], taskError);
    else
        warning('distcomp:dfevalasync:WarningOnTaskError', ...
            ['Errors occurred during execution of task ' int2str(taskNum) ...
            '. Results may be incorrect.\n%s'], taskError);

    end %
end % if ~isempty