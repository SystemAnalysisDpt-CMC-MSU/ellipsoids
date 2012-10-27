classdef ATypifiedStaticRelation<smartdb.relations.AStaticRelation&...
        smartdb.cubes.CubeStructReflectionHelper
    methods (Access=protected)
        function [nameCVec,propDefCVec]=getFieldDefsByRegExp(self,regExpStr)
            mcObj=metaclass(self);
            propVec=findobj(mcObj.PropertyList,'-regexp','Name',...
                regExpStr,'Constant',true,'GetAccess','public');
            if isempty(propVec)
                nameCVec=cell(0,1);
                propDefCVec=cell(0,1);
            else
                nameCVec={propVec.Name}.';
                isThereDefault=vertcat(propVec.HasDefault);
                propDefCVec=cell(size(propVec));
                propDefCVec(isThereDefault)={propVec(...
                    isThereDefault).DefaultValue};
            end
        end
    end
    methods
        function self=ATypifiedStaticRelation(varargin)
            % ATYPIFIEDSTATICRELATION is a constructor of static relation class
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
            %     self: ATYPIFIEDSTATICRELATION [1,1] - constructed class object
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
            [reg,prop]=modgen.common.parseparams(varargin);
            nReg=length(reg);
            %
            curClassNameObj=modgen.containers.ValueBox();
            self=self@smartdb.cubes.CubeStructReflectionHelper(curClassNameObj);
            %
            isForeignRelObjectOnInput=nReg>=1&&...
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
                %if relation on input, we pass the data via constructor
                %to enforce field type checking data from the input relation
                inpArgList={};
                setDataArgList=prop;
            else
                inpArgList=varargin;
            end
            self=self@smartdb.relations.AStaticRelation(inpArgList{:});
            if isForeignRelObjectOnInput
                sizeVec=size(reg{1});
                %
                if isempty(reg{1})
                    self=self.empty(sizeVec);
                else
                    self=repmatAuxInternal(self,sizeVec);
                    nElem=numel(reg{1});
                    %
                    dataCell=cell(1,3);
                    for iElem=1:nElem
                        [dataCell{:}]=reg{1}(iElem).getDataInternal(reg{2:end});
                        self(iElem).setData(dataCell{:},...
                            'transactionSafe',false,setDataArgList{:});
                    end
                end
            end
        end
        function display(self)
            self.displayInternal('TypifiedStaticRelation');
        end
    end
end