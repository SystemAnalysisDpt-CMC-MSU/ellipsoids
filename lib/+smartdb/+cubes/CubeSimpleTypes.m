classdef CubeSimpleTypes<smartdb.cubes.Cube
    methods
        function self=CubeSimpleTypes(varargin)
            % CUBESIMPLETYPE is a constructor of CubeSimpleType class
            % object
            %
            % For description see help for Cube constructor
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %
            
            isEmptyCube=false;
            inputCell=varargin;
            if nargin==1,
                if isempty(varargin{1}),
                    superClassNameList=superclasses(mfilename('class'));
                    if isa(varargin{1},superClassNameList{1}),
                        isEmptyCube=true;
                        inputCell=cell(1,0);
                    end
                end
            end
            self=self@smartdb.cubes.Cube(inputCell{:});
            if isEmptyCube,
                self=feval([mfilename('class') '.empty'],size(varargin{1}));
                return;
            end
            nObjs=numel(self);
            if nObjs==0||nargin==0,
                return;
            end
            if nargin==1&&isa(varargin{1},mfilename('class')),
                return;
            end
            %% check that data types are simple
            nFields=self(1).getNFields();
            if nObjs==1&&nFields==0,
                return;
            end
            fieldNameList=self(1).getFieldNameList();
            for iObj=1:nObjs,
                if iObj>1,
                    if ~isequal(self(iObj).getFieldNameList(),fieldNameList),
                        error([upper(mfilename),':wrongInput'],...
                            'fields must be the same for all objects');
                    end
                end
                for iField=1:nFields,
                    if isa(self(iObj).(fieldNameList{iField}),'handle'),
                        error([upper(mfilename),':wrongInput'],...
                            'Field %s has not simple type for %d-th object',fieldNameList{iField},iObj);
                    end
                end
            end
        end
    end
    
    methods (Access=protected,Static,Hidden)
        function outObj=loadobj(inpObj)
            isTransform=isstruct(inpObj);
            outObj=loadobj@smartdb.cubes.Cube(inpObj);
            if isTransform,
                outObj=feval(mfilename('class'),outObj);
            end
        end
    end
end