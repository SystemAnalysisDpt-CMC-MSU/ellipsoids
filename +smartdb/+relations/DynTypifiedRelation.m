classdef DynTypifiedRelation<smartdb.relations.DynamicRelation
    methods 
        function self=DynTypifiedRelation(varargin)
            [reg,prop]=modgen.common.parseparams(varargin);
            nReg=length(reg);
            %
            isRelObjectOnInput=nReg>=1&&...
                smartdb.relations.ARelation.isMe(reg{1});
            %
            if ~isRelObjectOnInput && nReg>3
                error([upper(mfilename),':wrongInput'],...
                    'incorrect number of regular arguments');
            end
            %
            %
            if isRelObjectOnInput
                inpArgList=prop;
                isFieldNameListSpec=any(strcmpi(inpArgList(1:2:end-1),'fieldNameList'));
                isFieldTypeSpecListSpec=any(strcmpi(inpArgList(1:2:end-1),'fieldTypeSpecList'));
                if numel(reg{1})>=1
                    if ~isFieldNameListSpec
                        inpArgList=[inpArgList,{'fieldNameList',...
                            reg{1}(1).getFieldNameList()}];
                    end
                    if ~isFieldTypeSpecListSpec
                        inpArgList=[inpArgList,{'fieldTypeSpecList',...
                            reg{1}(1).getFieldTypeSpecList()}];
                    end
                end
            else
                inpArgList=varargin;
            end
            self=self@smartdb.relations.DynamicRelation(inpArgList{:});
            if isRelObjectOnInput
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
                            'transactionSafe',false);
                    end
                end
            end
        end
    end
end
