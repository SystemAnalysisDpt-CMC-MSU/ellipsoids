classdef AFieldDefs    
	methods 
        function [isThereVec,outDescrList,outTypeSpecList,...
                outCodeList]=getDefsByNames(self,nameList)
            mc=metaclass(self);
            propVec=findobj(mc.PropertyList,'-regexp','Name','.*',...
                'Constant',true,'GetAccess','public');
            %
            fullCodeList={propVec.Name};
            isFoundCVec=regexp(fullCodeList,'.*(_D|_T)$');
            isFoundVec=cellfun(@(x)~isempty(x),isFoundCVec);
            fullCodeList=fullCodeList(~isFoundVec);
            %
            fullNameList=self.getNameList(fullCodeList);
            [isThereVec,indThereVec]=ismember(nameList,fullNameList);
            codeList=fullCodeList(indThereVec(isThereVec));
            [~,descrList,typeSpecList]=self.getDefs(codeList);
            %
            nNames=length(nameList);
            outDescrList=cell(1,nNames);
            outTypeSpecList=cell(1,nNames);
            outCodeList=cell(1,nNames);
            outDescrList(isThereVec)=descrList;
            outTypeSpecList(isThereVec)=typeSpecList;
            outCodeList(isThereVec)=codeList;
        end
        function nameList=getNameList(self,idList)
            nameList=cell(size(idList));
            for iDescr=1:length(idList)
                nameList{iDescr}=self.(idList{iDescr});
            end
        end
        function descrList=getDescrList(self,idList)
            descrList=cell(size(idList));
            for iDescr=1:length(descrList)
                descrList{iDescr}=self.([idList{iDescr},'_D']);
            end
        end
        function typeSpecList=getTypeSpecList(self,idList)
            typeSpecList=cell(size(idList));
            for iType=1:length(typeSpecList)
                typeSpecList{iType}=self.([idList{iType},'_T']);
            end
        end
        function [nameList,descrList,typeSpecList]=addFieldsByDef(self,...
                relObj,varargin)
            [nameList,descrList,typeSpecList]=self.getDefs(varargin{:});
            relObj.addFields(nameList,descrList,'typeSpecList',...
                typeSpecList);
        end
        function [nameList,descrList,typeSpecList]=getDefs(self,idList,...
                addNameCMat,isAddedToEnd)
            import modgen.common.type.simple.lib.*;
            import modgen.common.type.simple.checkgen;
            %
            if nargin<4
                isAddedToEnd=true;
                if nargin<3
                    addNameCMat=cell(3,0);
                end
            end
            nameList=self.getNameList(idList);
            descrList=self.getDescrList(idList);
            typeSpecList=self.getTypeSpecList(idList);
            %
            checkgen(addNameCMat,@(x)size(x,1)==3);            
            checkgen(addNameCMat(1:2,:),@(x)iscellofstring(x));
            checkgen(addNameCMat(3,:),@(x)all(cellfun(@iscellofstring,x)));
            if isAddedToEnd
                nameList=[nameList,addNameCMat(1,:)];
                descrList=[descrList,addNameCMat(2,:)];
                typeSpecList=[typeSpecList,addNameCMat(3,:)];
            else
                nameList=[addNameCMat(1,:),nameList];
                descrList=[addNameCMat(2,:),descrList];
                typeSpecList=[addNameCMat(3,:),typeSpecList];
            end
        end
    end
end	