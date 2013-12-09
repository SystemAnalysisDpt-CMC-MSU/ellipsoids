classdef ATypifiedByFieldCodeRel<smartdb.relations.ATypifiedStaticRelation
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    methods 
        function self=ATypifiedByFieldCodeRel(varargin)
            self=self@smartdb.relations.ATypifiedStaticRelation(varargin{:});
        end
    end
    methods (Access=protected,Static,Hidden)
        function outObj=loadobj(inpObj)
            import modgen.common.throwerror;
            outObj=loadobj@smartdb.relations.ATypifiedStaticRelation(inpObj);
            [expFieldNameList,expFieldDescrList,...
                expFieldTypeSpecList]=outObj.getFieldDefs();
            nExpFields=length(expFieldNameList);
            nFields=outObj.getNFields();
            fieldNameList=outObj.getFieldNameList();
            if nExpFields~=nFields
                throwerror('badMatFile:wrongState',['relation loaded from mat file ',...
                    'contains incorrect number of fields']);
            end
            isThereVec=ismember(expFieldNameList,fieldNameList);
            if ~all(isThereVec)
                throwerror('badMatFile:wrongState',...
                    ['relation loaded from mat file ',...
                    'has incorrect field names']);
            end
            fieldDescrList=outObj.getFieldDescrList(expFieldNameList);
            if ~isequal(fieldDescrList,expFieldDescrList)
                throwerror('badMatFile:wrongState',...
                    ['relation loaded from mat file ',...
                    'has incorrect field descriptions']);
            end
            fieldTypeSpecList=outObj.getFieldTypeSpecList(expFieldNameList);
            if ~isequal(fieldTypeSpecList,expFieldTypeSpecList)
                throwerror('badMatFile:wrongState',...
                    ['relation loaded from mat file ',...
                    'has incorrect field types']);
            end                
        end
    end
	methods (Access=protected,Abstract)
        fObj=getFieldDefObject(~)
	end
    methods (Access=protected)
        function [fieldNameList fieldDescrList fieldTypeSpecList]=...
                getFieldDefs(self)
            fieldDefObj=self.getFieldDefObject();
            propDefCMat=self.getFieldDefCMat();
            fieldCodeList=self.getFieldCodeList();            
            [fieldNameList,fieldDescrList,fieldTypeSpecList]=...
                fieldDefObj.getDefs(fieldCodeList);
            fieldNameList=[fieldNameList;propDefCMat(:,1)].';
            fieldDescrList=[fieldDescrList;propDefCMat(:,2)].';
            fieldTypeSpecList=[fieldTypeSpecList;propDefCMat(:,3)].';
        end
        function propDefCMat=getFieldDefCMat(self)
            [~,propDefCVec]=self.getFieldDefsByRegExp('^FDEF_');
            if isempty(propDefCVec)
                propDefCMat=cell.empty(0,3);
            else
                propDefCMat=vertcat(propDefCVec{:});
            end
        end
        function codeList=getFieldCodeList(self)
            CODE_PREFIX='FCODE_';
            propNameCVec=self.getFieldDefsByRegExp(['^',CODE_PREFIX]);
            firstCodeValueInd=length(CODE_PREFIX)+1;
            codeList=cellfun(@(x)x(firstCodeValueInd:end),propNameCVec,...
                'UniformOutput',false);            
        end
        function initialize(self,varargin)
            [self.fieldNameList,self.fieldDescrList,...
                self.fieldTypeSpecList]=getFieldDefs(self);
        end
    end
    
end