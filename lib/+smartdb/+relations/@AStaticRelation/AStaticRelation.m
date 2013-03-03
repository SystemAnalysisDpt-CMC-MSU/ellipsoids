classdef AStaticRelation<smartdb.relations.ARelation&...
        smartdb.cubes.FixedDimStCubeStructAppliance&...
        smartdb.cubes.CubeStructReflectionHelper
    %ASTATICRELATION Summary of this class goes here
    %   Detailed explanation goes here
    methods (Access=protected, Static,Hidden)
        outObj=loadobj(inpObj)
    end
    methods
        function display(self)
            self.displayInternal('StaticRelation');
        end          
        function self=AStaticRelation(varargin)
            % ASTATICRELATION is a constructor of static relation class
            % object
            %
            % Usage: self=AStaticRelation(obj) or
            %        self=AStaticRelation(varargin)
            %
            % Input:
            %   optional
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
            %       fillMissingFieldsWithNulls: logical[1,1] - if true,
            %           the relation fields absent in the input data 
            %           structures are filled with null values
            %
            % Output:
            %   regular:
            %     self: AStaticRelation [1,1] - constructed class object
            %
            % Note: In the case the first interface is used, SData and
            %       SIsNull are taken from class object obj 
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-21 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            %
            curClassNameObj=modgen.containers.ValueBox();
            self=self@smartdb.cubes.CubeStructReflectionHelper(curClassNameObj);
            [reg,prop]=modgen.common.parseparams(varargin);
            nReg=length(reg);
            isForeignRelObjectOnInput= nReg>=1 &&...
                smartdb.relations.ARelation.isMe(reg{1})&&...
                ~isa(reg{1},curClassNameObj.getValue());
            %
            if ~isForeignRelObjectOnInput && nReg>3
                error([upper(mfilename),':wrongInput'],...
                    'incorrect number of regular arguments');
            end
            %
            %
            if isForeignRelObjectOnInput
                %if relation on input, we pass the data via copyFromInternal
                %to enforce a consistency between a static field list and a
                %data from the input relation
                inpArgList={};
                copyArgList=prop;
            else
                inpArgList=varargin;
            end
            self=self@smartdb.relations.ARelation(inpArgList{:});
            if isForeignRelObjectOnInput
                if isempty(reg{1})
                    self=self.empty(size(reg{1}));
                else
                    self=repmatAuxInternal(self,size(reg{1}));
                    self.copyFromInternal(reg{:},copyArgList{:},...
                        'fieldNameList',self(1).fieldNameList);
                end
            end
        end
    end
    
end