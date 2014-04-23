classdef AElementWithProps<handle
    properties (GetAccess=protected,Constant,Abstract)
        REGULAR_PROP_NAME_LIST
    end
    
    methods (Access=protected,Abstract)
        setRegularProps(self,varargin)
    end
    
    methods (Sealed)
        function propNameList=getPropNameList(self)
            metaClassObj=metaclass(self);
            SPropsVec=metaClassObj.PropertyList;
            propNameList={SPropsVec.Name};
            isPropVec=strcmp({SPropsVec.GetAccess},'public');
            if any(isPropVec),
                isPropVec(isPropVec)=~ismember(propNameList(isPropVec),...
                    self.REGULAR_PROP_NAME_LIST);
            end
            propNameList(~isPropVec)=[];
        end

        function propList=getPropList(self)
            propNameList=self.getPropNameList();
            nProps=numel(propNameList);
            propValList=cell(1,nProps);
            for iProp=1:nProps,
                propValList{iProp}=self.(propNameList{iProp});
            end
            propList=reshape([propNameList;propValList],1,[]);
        end
    end
    
    methods (Access=protected,Sealed)
        function [reg,prop]=parseRegAndPropList(self,varargin)
            nReg=numel(self.REGULAR_PROP_NAME_LIST);
            [reg,~,prop]=modgen.common.parseparext(...
                varargin,self.getPropNameList(),[nReg nReg+1],...
                'propRetMode','list');
            if numel(reg)>nReg,
                obj=reg{end};
                reg(end)=[];
                if ~isa(obj,class(self)),
                    modgen.common.throwerror('wrongInput',...
                        'Incorrect class of object containing properties: %s',...
                        class(obj));
                end
                allPropList=obj.getPropList();
                if numel(prop)>0,
                    [isPropVec,indPropVec]=ismember(...
                        lower(prop(1:2:end-1)),lower(allPropList(1:2:end-1)));
                    if any(isPropVec),
                        indPropVec=indPropVec(isPropVec);
                        allPropList(2*indPropVec)=...
                            prop(2*find(isPropVec));
                    end
                end
                prop=allPropList;
            else
                allPropNameList=self.getPropNameList();
                propNameList=prop(1:2:end-1);
                propValList=prop(2:2:end);
                [~,indPropVec]=ismember(lower(propNameList),...
                    lower(allPropNameList));
                propNameList=allPropNameList(indPropVec);
                prop=reshape([propNameList;propValList],1,[]);
            end
        end
    end
end