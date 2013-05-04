classdef FixedDimStCubeStructAppliance<smartdb.cubes.IDynamicCubeStructInternal
    % STATICCUBESTRUCTAPPLIANCE adds basic capabilities to CubeStruct
    methods
        function varargout=getUniqueDataAlongDim(self,varargin)
            % GETUNIQUEDATAALONGDIM - returns internal representation of CubeStruct
            %                         data set unique along a specified dimension
            if nargout==0
                self.getUniqueDataAlongDimInternal(varargin{:});
            else
                varargout=cell(1,nargout);
                [varargout{:}]=self.getUniqueDataAlongDimInternal(varargin{:});
            end
        end
        function varargout=isMemberAlongDim(self,varargin)
            % ISMEMBERALONGDIM - performs ismember operation of CubeStruct data slices
            %                    along the specified dimension
            if nargout==0
                self.isMemberAlongDimInternal(varargin{:});
            else
                varargout=cell(1,nargout);
                [varargout{:}]=self.isMemberAlongDimInternal(varargin{:});
            end
        end
        function sortByAlongDim(self,varargin)
            self.sortByAlongDimInternal(varargin{:});
        end
        function reorderData(self,varargin)
            %The following methods being public are still used by CubeStruct
            %internal methods which makes it dangereous to leave them open
            %for redefinition. To protect them we use Sealed access modifier.
            self.reorderDataInternal(varargin{:});
        end
        function addDataAlongDim(self,catDimension,varargin)
            % ADDDATAALONGDIM - adds a set of field values to existing data using
            %                   a concatenation along a specified dimension
            %
            self.addDataAlongDimInternal(catDimension,varargin{:});
        end
        function clearData(self)
            self.clearDataInternal();
        end
        function unionWithAlongDim(self,varargin)
            unionWithAlongDimInternal(self,varargin{:});
        end
    end
end
