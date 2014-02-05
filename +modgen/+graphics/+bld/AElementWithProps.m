classdef AElementWithProps<handle
    properties (GetAccess=private,Constant)
        PUBLIC_PROP_WITH_SETTER_LIST={'hFigure'};
    end
    
    methods
        function self=AElementWithProps(varargin)
            self.setPropList(varargin{:});
        end
    end
    
    methods (Sealed)
        function propNameList=getPropNameList(self)
            metaClassObj=metaclass(self);
            SPropsVec=metaClassObj.PropertyList;
            propNameList={SPropsVec.Name};
            isPropVec=strcmp({SPropsVec.SetAccess},'public');
            if any(isPropVec),
                isnSetterVec=~ismember(propNameList(isPropVec),...
                    self.PUBLIC_PROP_WITH_SETTER_LIST);
                if any(isnSetterVec),
                    isPropVec(isnSetterVec)=...
                        cellfun('isempty',...
                        {SPropsVec(isnSetterVec).SetMethod});
                end
            end
            propNameList(~isPropVec)=[];
        end
        
        function setPropList(self,varargin)
            if ~isempty(varargin),
                if mod(numel(varargin),2),
                    modgen.common.throwerror('wrongInput',...
                        'Incorrect propList');
                end
                propNameList=varargin(1:2:end-1);
                propValList=varargin(2:2:end);
                nProps=numel(propNameList);
                allPropNameList=self.getPropNameList();
                [isPropVec,indPropVec]=ismember(lower(propNameList),...
                    lower(allPropNameList));
                if ~all(isPropVec),
                    modgen.common.throwerror('wrongInput',...
                        'These properties can not be set: %s',...
                        cell2sepstr([],propNameList(~isPropVec),', '));
                end
                propNameList=allPropNameList(indPropVec);
                for iProp=1:nProps,
                    self.(propNameList{iProp})=propValList{iProp};
                end
            end
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
end