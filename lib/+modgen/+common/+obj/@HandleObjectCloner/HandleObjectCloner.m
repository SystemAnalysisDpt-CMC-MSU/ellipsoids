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
        function isEq=isequal(varargin)
            % ISEQUAL compares objects and returns true if they are found
            % equal
            %
            isnWrong=nargin>1;
            if isnWrong,
                isnWrong=~ischar(varargin{2});
            end
            if ~isnWrong,
                isEq=true;
            else
                [reg,prop]=parseparams(varargin);
                nObj=length(reg);
                for iObj=1:nObj-1,
                    obj1=varargin{iObj};
                    obj2=varargin{iObj+1};
                    isEq=eq(obj1,obj2,prop{:});
                    if ~isEq,
                        return;
                    end
                end
                isEq=true;
            end
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