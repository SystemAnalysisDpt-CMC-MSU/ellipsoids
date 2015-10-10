classdef EntityFactory
    methods (Static)
        function resArr=create(valMat,varargin)
            import modgen.common.parseparext;
            [reg,~,isUniqueIsMemberChecked]=parseparext(varargin,...
                {'checkUniqueIsMember';true},[0 1],'regDefList',{true});
            %
            isSortable=reg{1};
            %
            if isUniqueIsMemberChecked
                if isSortable
                    fCreate=@modgen.common.test.aux.SortableEntityRedirected;
                else
                    fCreate=@modgen.common.test.aux.CompEntityRedirected;
                end                
            else
                if isSortable
                    fCreate=@modgen.common.test.aux.SortableEntity;
                else
                    fCreate=@modgen.common.test.aux.CompEntity;
                end
            end
            %
            nElems=numel(valMat);
            sizeVec=size(valMat);
            resCArr=cell(sizeVec);
            for iElem=nElems:-1:1
                resCArr{iElem}=fCreate(valMat(iElem));
            end
            resArr=reshape([resCArr{:}],sizeVec);
        end
    end
end