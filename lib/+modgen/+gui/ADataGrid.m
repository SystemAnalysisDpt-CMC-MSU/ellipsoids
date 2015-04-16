classdef ADataGrid<modgen.gui.ADataGridBase
    methods (Abstract)
        keyVec=getFilteredRowKeys(self)
        keyVec=getSelectedRowKeys(self)
        nRows=getRowCount(self);
        nCols=getColumnCount(self);
    end
    methods
        function self=ADataGrid(varargin)
            self=self@modgen.gui.ADataGridBase(varargin{:});
        end
    end
end
