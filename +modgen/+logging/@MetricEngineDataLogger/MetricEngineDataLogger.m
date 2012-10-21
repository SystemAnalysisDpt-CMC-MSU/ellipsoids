classdef MetricEngineDataLogger<modgen.logging.DataLogger
    % METRICENGINEDATALOGGER allows to log performance of functions within
    % metrics of metric engine and also save contents of their local
    % variables into MAT-files

    methods (Static)
        function setCurMetricName(metricName)
            % SETCURMETRICNAME sets current metric to be calculated within
            % metric engine
            %
            % Usage: setCurMetricName(metricName)
            %
            % input:
            %   regular:
            %     metricName: char [1,] - name of current metric
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %
            
            %% initial actions
            className=mfilename('class');
            if ~feval([className '.getIsEnabled']),
                return;
            end
            if ~(ischar(metricName)&&size(metricName,2)==numel(metricName)),
                error([upper(mfilename),':wrongInput'],...
                    'metricName must be string');
            end
            %% set current metric name
            feval([className '.setPropInternal'],'curMetricName',metricName,className);
        end
        %
        function setCurProfileNameList(profileNameList)
            % SETCURPROFILENAMELIST sets current list with names of
            % profiles to be processed within calculation of current metric
            % in metric engine
            %
            % Usage: setCurProfileNameList(profileNameList)
            %
            % input:
            %   regular:
            %     profileNameList: char [1,] or char cell [1,nProfiles] -
            %         names of current profiles
            %
            %
            
            %% initial actions
            className=mfilename('class');
            if ~feval([className '.getIsEnabled']),
                return;
            end
            if ischar(profileNameList),
                if isempty(profileNameList)||size(profileNameList,2)~=...
                        numel(profileNameList),
                    error([upper(mfilename),':wrongInput'],...
                        'profileNameList must be nonempty string');
                end
                profileNameList={profileNameList};
            else
                isnWrong=iscell(profileNameList);
                if isnWrong,
                    profileNameList=reshape(profileNameList,1,[]);
                    isnWrong=all(...
                        cellfun('isclass',profileNameList,'char')&...
                        cellfun('size',profileNameList,2)==...
                        cellfun('prodofsize',profileNameList)&...
                        ~cellfun('isempty',profileNameList));
                end
                if ~isnWrong,
                    error([upper(mfilename),':wrongInput'],...
                        'profileNameList must be cell array with nonempty strings');
                end
            end
            %% set current metric name
            feval([className '.setPropInternal'],'curProfileNameList',profileNameList,className);
        end
        %
        function log()
            % LOG logs info on function only as text into special log-file
            %
            % Usage: log()
            %
            %
            
            className=mfilename('class');
            if ~feval([className '.getIsEnabled']),
                return;
            end
            [~,fullFuncName,isLogged]=feval([className '.getFunctionProps'],2);
            if ~isLogged,
                return;
            end
            getMethodName=[className '.getPropInternal'];
            loggerObj=feval(getMethodName,'loggerObj');
            [curProfileNameList,isCurProfileNameList]=feval(getMethodName,...
                'curProfileNameList',true,className);
            messageStr=[fullFuncName ' is performed'];
            if isCurProfileNameList,
                 messageStr=[messageStr ' for profiles '...
                    cell2sepstr([],curProfileNameList,',')];
            end
            loggerObj.info(messageStr);
        end
        %
        function logData()
            % LOG logs both info on function executed and data of local
            % variables
            %
            % Usage: logData()
            %
            %
            
            className=mfilename('class');
            if ~feval([className '.getIsEnabled']),
                return;
            end
            [shortFuncName,fullFuncName,isLogged]=feval([className '.getFunctionProps'],2);
            if ~isLogged,
                return;
            end
            getMethodName=[className '.getPropInternal'];
            loggerObj=feval(getMethodName,'loggerObj');
            [curProfileNameList,isCurProfileNameList]=feval(getMethodName,...
                'curProfileNameList',true,className);
            messageStr=[fullFuncName ' is performed'];
            if isCurProfileNameList,
                profileStr=cell2sepstr([],curProfileNameList,',');
                messageStr=[messageStr ' for profiles '...
                    profileStr];
                fullFuncName=[fullFuncName '(' profileStr ')'];
            end
            fileName=feval([className '.getDataFileName'],shortFuncName,fullFuncName);
            [~,shortFileName]=fileparts(fileName);
            loggerObj.info([messageStr ', data with local variables are in ' shortFileName]);
            evalin('caller',['save(''' fileName ''')']);
        end
        %
        function flush()
            % FLUSH clears info set by configure within storage
            %
            % Usage: flush()
            %
            %
            
            className=mfilename('class');
            feval([className '.flushInternal'],className);
            flush@modgen.logging.DataLogger();
        end         
    end
    
    methods (Access=protected,Static)
        function [shortFuncName,fullFuncName,isLogged]=getFunctionProps(indStack)
            % GETFUNCTIONPROPS returns short name of function as well
            % as its full name including all necessary prefixes and
            % information whether it is to be logged or not
            %
            % Usage: [shortFuncName,fullFuncName,isLogged]=...
            %            getFunctionProps()
            %
            % input:
            %   optional:
            %     indStack: double [1,1] - index of function in stack
            %         (relative to this method, 1 corresponds to the
            %         immediate caller of this method); if not given,
            %         we take the first function in the stack that is not
            %         method (or subfunction of method) of some descendant
            %         of this class
            % output:
            %   regular:
            %     shortFuncName: char [1,] - short name of function to be
            %         logged (i.e. without name of class, prefixes, etc.)
            %     fullFuncName: char [1,] - full name of function with all
            %         necessary prefixes
            %     isLogged: logical [1,1] - if true, then given function is
            %         to be logged, otherwise false
            %
            %
            
            %% initial actions
            if nargin==0,
                inputCell={};
            else
                inputCell={indStack+1};
            end
            nOuts=min(nargout,2);
            if nOuts==0,
                return;
            end
            outCell=cell(1,nOuts);
            [outCell{:}]=getFunctionProps@modgen.logging.DataLogger(inputCell{:});
            shortFuncName=outCell{1};
            %% process fullFuncName and isLogged
            if nargout>1,
                curClassName=mfilename('class');
                getMethodName=[curClassName '.getPropInternal'];
                [curMetricName,isCurMetric]=feval(getMethodName,'curMetricName',true,curClassName);
                if isCurMetric&&~isempty(curMetricName),
                    fullFuncName=['#' curMetricName '.' outCell{2}];
                else
                    fullFuncName=outCell{2};
                end
                if nargout>2,
                    isLogged=any(strcmp(fullFuncName,...
                        feval(getMethodName,'functionNameList')));
                end
            end
        end
    end
end