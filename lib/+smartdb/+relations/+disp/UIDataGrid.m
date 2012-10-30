classdef UIDataGrid<handle
    properties (Access=private)
        relToMatProp=struct();
        dataRel
        gridObj
    end
    methods (Access=protected)
        function propList=getRelToMatProps(self)
            propList=[fieldnames(self.relToMatProp);...
                struct2cell(self.relToMatProp)];
            propList=transpose(propList(:));
        end
    end    
    methods
        function putRel(self,dataObj,varargin)
            self.dataRel=dataObj.getCopy();            
            inpArgList=self.getRelToMatProps();
            dataCell=dataObj.toDispCell(inpArgList{:});
            %
            dataCell=cellfun(@catIfScalar,dataCell,'UniformOutput',false);
            colNameList=dataObj.getFieldNameList;
            self.gridObj.putData(colNameList,dataCell);
            %
            function outStr=catIfScalar(inpStr)
                if numel(inpStr)==1
                    outStr=[inpStr,' '];
                else
                    outStr=inpStr;
                end
            end
        end
        function self=UIDataGrid(varargin)
            import modgen.common.throwerror;
            [~,~,tableType,nullTopReplacement,panelHandle,...
                isTableTypeSpec,isNullTopRepSpec]=...
                modgen.common.parseparext(varargin,...
                {'tableType','nullTopReplacement','panelHandle';...
                [],'N/A',[];...
                @(x)ischar(x)&&isrow(x)&&...
                ismember(lower(x),{'scijavatable','uitable'}),...
                @(x)ischar(x)&&isrow(x),...
                @(x)ishandle(x)&&strcmp(get(x,'Type'),'uipanel')},0,...
                'isObligatoryPropVec',[false,false,true]);
            %
            if ~isTableTypeSpec
                if ~isempty(meta.class.fromName('modgen.gui.JDataGrid'))
                    tableType='sciJavaTable';
                elseif ~isempty(meta.class.fromName('modgen.gui.MDataGrid'))
                    tableType='uitable';
                else
                    throwerror('classMissing',...
                        ['cannot find any ADataGridBase class for',...
                        'displaying the data']);
                end
            end
            %    
            switch lower(tableType)
                case 'scijavatable',
                    self.gridObj=modgen.gui.JDataGrid('panelHandle',...
                        panelHandle);
                case 'uitable',
                    self.gridObj=modgen.gui.MDataGrid('panelHandle',...
                        panelHandle);
            end
            %
            if isNullTopRepSpec
                self.relToMatProp.nullTopReplacement=nullTopReplacement;
            end
            %
        end
    end
end
