classdef DynamicRelation<smartdb.relations.ARelation&...
        smartdb.cubes.FixedDimDynCubeStructAppliance
    %DYNAMICRELATION class is designed as an extension of ARelation class
    %to provide a functionality for modifying relations in run-time
    %
    %TODO add getcolumns method which returns DynamicRelation class with
    %only specified columns
    %TODO add support for multiple-argument function into applySetFunc
    %method
    methods (Access=protected,Static,Hidden)
        outObj=loadobj(inpObj)
    end
    methods
        function display(self)
            self.displayInternal('DynamicRelation');
        end        
        function self=DynamicRelation(varargin)
            % DYNAMICRELATION is a constructor of dynamic relation class
            % object
            %
            % Usage: self=DynamicRelation(obj) or
            %        self=DynamicRelation(varargin)
            %
            % Input:
            %   optional:
            %     inpObj: ARelation[1,1]/SData: struct[1,1]
            %         structure with values of all fields
            %         for all tuples
            %
            %     SIsNull: struct [1,1] - structure of fields with is-null
            %        information for the field content, it can be logical for
            %        plain real numbers of cell of logicals for cell strs or
            %        cell of cell of str for more complex types
            %
            %     SIsValueNull: struct [1,1] - structure with logicals
            %         determining whether value corresponding to each field
            %         and each tuple is null or not
            %
            %   properties:
            %     fieldNameList: char cell [1,nFields] - list of names for
            %         fields of given dynamic relation
            %
            %     fieldDescrList: char cell [1,nFields] - list of
            %         descriptions for fields of given dynamic relation
            %
            %     fieldTypeSpecList: cell[1,nFields] of cell[1,] - field type
            %        specification list ({{'cell','double'},{'double'}}
            %        for instance)
            %
            % Output:
            %   regular:
            %     self: DynamicRelation [1,1] - constructed class object
            %
            % Note: In the case the first interface is used, SData and
            %       SIsNull are taken from class object obj
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-18 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            %
            varargin=smartdb.cubes.CubeStruct.inferFieldNamesFromSData(varargin);
            self=self@smartdb.relations.ARelation(varargin{:});
        end
        %
    end
    methods (Access=protected,Hidden)
        function initialize(self,varargin)
            self.parseAndAssignFieldProps(varargin{:});
        end
    end
    methods (Static)
        relDataObj=fromStructList(structList)
            % FROMSTRUCTLIST creates a dynamic relation from a list of
            % structures interpreting each structure as the data for
            % several tuples.
            %

    end
end