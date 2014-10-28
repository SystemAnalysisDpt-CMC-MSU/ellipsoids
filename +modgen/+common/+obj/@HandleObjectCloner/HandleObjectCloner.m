classdef HandleObjectCloner<handle
    % HANDLEOBJECTCLONER provides some simples functionality for clonable
    % objects
    % 
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-07 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    methods (Access=private,Static)
        function isPositive=isMe(inpObj)
            curClassName=mfilename('class');
            isPositive=isa(inpObj,curClassName);
        end
    end
    %
    methods
        function [isEq,reportStr]=isequal(varargin)
            % ISEQUAL compares objects and returns true if they are found
            % equal
            %
            % Usage: isEq=isequal(objMat1,...,objMatN,varargin) or
            %        [isEq,reportStr]=isequal(objMat1,...,objMatN,varargin)
            %
            % input:
            %   regular:
            %     objMat1: HandleObjectCloner of any size - first object
            %         array
            %     objMat2: HandleObjectCloner of any size - second object
            %         array
            %     ...
            %     objMatN: HandleObject Cloner of any size - N-th object
            %         array
            %   properties:
            %     isFullCheck: logical [1,1] - if true, then all input
            %         objects are compared, otherwise (default) check is
            %         performed up to the first difference
            % output:
            %   regular:
            %     isEq: logical [1,1] - true if all objects are equal,
            %         false otherwise
            %   optional:
            %     reportStr: char - report about the found differences
            %
            %
            % $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-10-14 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2014 $
            %
            %
            
            reportStr='';
            [reg,prop]=parseparams(varargin);
            nObj=length(reg);
            if nObj==1,
                modgen.common.throwerror('wrongInput',...
                    'Not enough input arguments');
            end
            isFullCheck=false;
            if ~isempty(prop),
                indProp=find(strcmpi('isfullcheck',prop(1:2:end-1)),1,'first');
                if ~isempty(indProp),
                    indProp=indProp*2;
                    isFullCheck=prop{indProp};
                    prop(indProp+[-1 0])=[];
                end
            end
            reportStrList=cell(1,nObj-1);
            isEq=true;
            for iObj=1:nObj-1,
                obj1=varargin{iObj};
                obj2=varargin{iObj+1};
                if isequal(size(obj1),size(obj2)),
                    if isequal(class(obj1),class(obj2)),
                        if nargout>1,
                            [isEqCur,reportStrCur]=eq(obj1,obj2,prop{:});
                            isEqCur=all(isEqCur);
                            if ~isempty(reportStrCur),
                                reportStrList{iObj}=sprintf(...
                                    '(%d-th and %d-th objects):%s',...
                                    iObj,iObj+1,reportStrCur);
                            end
                        else
                            isEqCur=all(eq(obj1,obj2));
                        end
                    else
                        isEqCur=false;
                        if nargout>1,
                            reportStrList{iObj}=sprintf(...
                                '(%d-th and %d-th objects):%s',...
                                iObj,iObj+1,'classes are not equal');
                        end
                    end
                else
                    isEqCur=false;
                    if nargout>1,
                        reportStrList{iObj}=sprintf(...
                            '(%d-th and %d-th objects):%s',...
                            iObj,iObj+1,'sizes are not equal');
                    end
                end
                isEq=isEq&&isEqCur;
                if ~(isEq||isFullCheck),
                    break;
                end
            end
            if nargout>1,
                reportStrList(cellfun('isempty',reportStrList))=[];
                if length(reportStrList)>1,
                    reportStr=modgen.string.catwithsep(reportStrList,...
                        sprintf('\n'));
                elseif ~isempty(reportStrList),
                    reportStr=reportStrList{:};
                end
            end
        end
        
        function [isEqMat,reportStr]=eq(varargin)
            isEqMat=eq@handle(varargin{:});
            reportStr='';
        end
            
        function obj=clone(self,varargin)
            % CLONE - creates a copy of a specified object via calling
            %         a copy constructor for the object class
            %
            % Input:
            %   regular:
            %     self: any [] - current object
            %   optional
            %     any parameters applicable for relation constructor
            %
            % Ouput:
            %   self: any [] - constructed object
            obj=self.createInstance(self,varargin{:});
        end
        function resObj=createInstance(self,varargin)
            % CREATEINSTANCE - returns an object of the same class by calling a default
            %                  constructor (with no parameters)
            %
            % Usage: resObj=getInstance(self)
            %
            % input:
            %   regular:
            %     self: any [] - current object
            %   optional
            %     any parameters applicable for relation constructor
            %
            % Ouput:
            %   self: any [] - constructed object
            p=metaclass(self);
            resObj=feval(p.Name,varargin{:});
        end
    end
    
end