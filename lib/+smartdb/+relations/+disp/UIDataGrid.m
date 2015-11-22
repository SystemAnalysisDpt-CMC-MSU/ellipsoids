classdef UIDataGrid<modgen.gui.ADataGrid
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
        function putData(self,varargin)
            self.gridObj.putData(varargin{:});
        end
        function keyVec=getFilteredRowKeys(self)
            keyVec=self.gridObj.getFilteredRowKeys();
        end
        function keyVec=getSelectedRowKeys(self)
            keyVec=self.gridObj.getSelectedRowKeys();
        end
        function nRows=getRowCount(self)
            nRows=self.gridObj.getRowCount();
        end
        function nCols=getColumnCount(self)
            nCols=self.gridObj.getColumnCount();
        end
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
            [reg,~,tableType,nullTopReplacement,panelHandle,...
                isTableTypeSpec,isNullTopRepSpec]=...
                modgen.common.parseparext(varargin,...
                {'tableType','nullTopReplacement','panelHandle';...
                [],'N/A',[];...
                @(x)ischar(x)&&isrow(x)&&...
                ismember(lower(x),{'scijavatable','uitable'}),...
                @(x)ischar(x)&&isrow(x),...
                @(x)ishghandle(x)&&any(strcmp(get(x,'Type'),...
                {'uipanel','uibuttongroup'}))},[],...
                'isObligatoryPropVec',[false,false,true]);
            %
            if ~isTableTypeSpec
                if ~isempty(meta.class.fromName('modgen.gui.JDataGrid'))
                    if ~usejava('swing')
                        throwerror('wrongState:noSwing',...
                            ['Java-based table UI requires Swing ',...
                            'which is not available']);
                    end
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
                        panelHandle,reg{:});
                case 'uitable',
                    self.gridObj=modgen.gui.MDataGrid('panelHandle',...
                        panelHandle,reg{:});
            end
            %
            if isNullTopRepSpec
                self.relToMatProp.nullTopReplacement=nullTopReplacement;
            end
            %
        end
    end
end
