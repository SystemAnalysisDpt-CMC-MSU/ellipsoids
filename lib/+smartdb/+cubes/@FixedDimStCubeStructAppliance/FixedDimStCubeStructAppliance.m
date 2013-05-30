classdef FixedDimStCubeStructAppliance<smartdb.cubes.IDynamicCubeStructInternal
    % STATICCUBESTRUCTAPPLIANCE adds basic capabilities to CubeStruct
    methods
        function varargout=getUniqueDataAlongDim(self,varargin)
            % GETUNIQUEDATAALONGDIM - returns internal representation of CubeStruct
            %
            % Input:
            %   regular:
            %     self:
            %     catDim: double[1,1] - dimension number along which uniqueness is
            %        checked
            %
            %   properties
            %       fieldNameList: list of field names used for finding the unique
            %           elements; only the specified fields are returned in SData,
            %           SIsNull,SIsValueNull structures
            %       structNameList: list of internal structures to return (by default 
            %           it is {SData, SIsNull, SIsValueNull}
            %       replaceNull: logical[1,1] if true, null values are replaced with
            %           certain default values uniformly across all CubeStruct cells
            %               default value is false
            %       checkInputs: logical[1,1] - if true, the input parameters are
            %          checked for consistency
            %
            % Output:
            %   regular:
            %     SData: struct [1,1] - structure containing values of fields
            %
            %     SIsNull: struct [1,1] - structure containing info whether each value
            %         in selected cells is null or not, each field is either logical
            %         array or cell array containing logical arrays
            %
            %     SIsValueNull: struct [1,1] - structure containing a
            %        logical array [nSlices,1] for each of the fields (true
            %        means that a corresponding cell doesn't not contain
            %           any value
            %
            %     indForwardVec: double[nUniqueSlices,1] - indices of unique entries in
            %        the original CubeStruct data set
            %
            %     indBackwardVec: double[nSlices,1] - indices that map the unique data 
            %        set back to the original data setdata set unique along a specified 
            %        dimension
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
            % Input:
            %   regular:
            %     self: ARelation [1,1] - class object
            %     other: ARelation [1,1] - other class object
            %     dim: double[1,1] - dimension number for ismember operation
            %
            %   properties:
            %     keyFieldNameList/fieldNameList: char or char cell [1,nKeyFields] - 
            %         list  of fields to which ismember is applied; by default all  
            %         fields of first (self) object are used
            %
            %
            % Output:
            %   regular:
            %     isThere: logical [nSlices,1] - determines for each data slice of the
            %         first (self) object whether combination of values for key fields 
            %         is in the second (other) object or not
            %     indTheres: double [nSlices,1] - zero if the corresponding coordinate
            %         of isThere is false, otherwise the highest index of the
            %         corresponding data slice in the second (other) object
            if nargout==0
                self.isMemberAlongDimInternal(varargin{:});
            else
                varargout=cell(1,nargout);
                [varargout{:}]=self.isMemberAlongDimInternal(varargin{:});
            end
        end
        function sortByAlongDim(self,varargin)
            % SORTBYALONGDIM -  sorts data of given CubeStruct object along the 
            %                   specified dimension using the specified fields
            %
            % Usage: sortByInternal(self,sortFieldNameList,varargin)
            %
            % input:
            %   regular:
            %     self: CubeStruct [1,1] - class object
            %     sortFieldNameList: char or char cell [1,nFields] - list of field
            %         names with respect to which field content is sorted
            %     sortDim: numeric[1,1] - dimension number along which the sorting is
            %        to be performed
            %     properties:
            %     direction: char or char cell [1,nFields] - direction of sorting for
            %         all fields (if one value is given) or for each field separately;
            %         each value may be 'asc' or 'desc'
            %
            %
            self.sortByAlongDimInternal(varargin{:});
        end
        function reorderData(self,varargin)
            % REORDERDATA - reorders cells of CubeStruct object along the specified
            %               dimensions according to the specified index vectors
            %
            % Input:
            %   regular:
            %       self: CubeStruct [1,1] - the object
            %       subIndCVec: numeric[1,]/cell[1,nDims] of double [nSubElem_i,1] 
            %           for i=1,...,nDims array of indices of field value slices that  
            %           are selected to be returned; 
            %           if not given (default), no indexation is performed
            %       
            %   optional:
            %       dimVec: numeric[1,nDims] - vector of dimension numbers
            %           corresponding to subIndCVec
            %

            self.reorderDataInternal(varargin{:});
        end
        function addDataAlongDim(self,catDimension,varargin)
            % ADDDATAALONGDIM - adds a set of field values to existing data using
            %                   a concatenation along a specified dimension
            %
            % Input:
            %   regular:
            %       self: CubeStruct [1,1] - the object
            self.addDataAlongDimInternal(catDimension,varargin{:});
        end
        function clearData(self)
           % CLEARDATA - deletes all the data from the object
           %
           % Usage: self.clearData(self)
           %
           % Input:
           %   regular:
           %     self: CubeStruct [1,1] - class object
           %
           %
            self.clearDataInternal();
        end
        function unionWithAlongDim(self,varargin)
        % UNIONWITHALONGDIM - adds data from the input CubeStructs
        %
        % Usage: self.unionWithAlongDim(unionDim,inpCube)
        % 
        % Input:
        %   regular:
        %   self: 
        %       inpCube1: CubeStruct [1,1] - object to get the additional data from
        %           ...
        %       inpCubeN: CubeStruct [1,1] - object to get the additional data from
        %
        %   properties:
        %       checkType: logical[1,1] - if true, union is only performed when the
        %           types of relations is the same. Default value is false
        %
        %       checkStruct: logical[1,nStruct] - an array of indicators which when
        %          true force checking of structure content (including presence of 
        % all required fields). The first element correspod to SData, the
        %          second and the third (if specified) to SIsNull and SIsValueNull
        %          correspondingly
        %
        %       checkConsistency: logical [1,1]/[1,2] - the
        %           first element defines if a consistency between the value
        %           elements (data, isNull and isValueNull) is checked;
        %           the second element (if specified) defines if
        %           value's type is checked. If isConsistencyChecked
        %           is scalar, it is automatically replicated to form a
        %           two-element vector.
        %           Note: default value is true
            unionWithAlongDimInternal(self,varargin{:});
        end
    end
end
