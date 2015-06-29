classdef ARelation<smartdb.cubes.CubeStruct
    %ARELATION Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant,Hidden)
        MAX_TUPLES_TO_DISPLAY=15
    end
    %
    methods (Static,Access=protected,Sealed)
        %
        function propCheckCMat=getRelOnlyIsEqualPropCheckCMat()
            propCheckCMat={'checktupleorder';...
                false;...
                'isscalar(x)&&islogical(x)'};            
        end
        %
        function propCheckCMat=getRelIsEqualPropCheckCMat(propNameList)
            import modgen.common.throwerror;
            propCheckCMat=[...
                smartdb.relations.ARelation.getRelOnlyIsEqualPropCheckCMat(),...
                smartdb.cubes.CubeStruct.getIsEqualPropCheckCMat()];
            if nargin>0
                [isThereVec,indThereVec]=ismember(lower(propNameList),...
                    lower(propCheckCMat(1,:)));
                if ~all(isThereVec)
                    throwerror('wrongInput','not all properties are know');
                end
                propCheckCMat=propCheckCMat(:,indThereVec);
            end            
        end
    end
    methods
        function [isEq,reportStr]=isEqual(varargin)
        % ISEQUAL compares the specified CubeStruct object with other CubeStruct
        % object and returns true if they are equal, otherwise it
        % returns false
        %
        % Usage: isEq=obj1Arr.isEqual(,...,objNArr,varargin) or
        %        [isEq,reportStr]=isequal(obj1Arr,...,objNArr,varargin)
        %
        % Input:
        % 	regular:
        %       obj1Arr: CubeStruct of any size - first object
        %           array
        %       obj2Arr: CubeStruct of any size - second object
        %           array
        %           ...
        %       objNArr: CubeStruct of any size - N-th object
        %           array
        %
        %   properties:
        %       asHandle: logical[1,1] - if true, elements are compared
        %           as handles ignoring content of the objects   
        %       propEqScalarList: cell[1,] - list of properties passed
        %           to isEqualScalarInternal method  
        %
        %       checkTupleOrder: logical[1,1] -  if true, then the tuples in the 
        %           compared relations are expected to be in the same order,
        %           otherwise the order is not important (false by default)        
        %       checkFieldOrder: logical [1,1] -
        %           if true, then fields in compared objects must
        %           be in the same order, otherwise the order is not
        %           important (false by default)
        %
        %       compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
        %           referenced from the meta data objects are also compared
        %
        %       maxTolerance: double [1,1] - maximum allowed tolerance
        %
        %       maxRelativeTolerance: double [1,1] - maximum allowed relative
        %           tolerance
        %
        % Output:
        %   isEq: logical[1,1] - result of comparison
        %   reportStr: char[1,] - contains an additional information about the
        %      differences (if any)
        %
        %
        % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 10-June-2015 $ 
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2015 $
        %                
            import modgen.common.parseparams;
            %
            [regArgList,propEqScalarList]=...
                smartdb.relations.ARelation.parseEqScalarProps(...
                smartdb.relations.ARelation.getRelOnlyIsEqualPropCheckCMat(),...
                varargin);
            %
            [isEq,reportStr]=...
                isEqual@smartdb.cubes.CubeStruct(...
                regArgList{:},'propEqScalarList',propEqScalarList);
        end
        function [isEqArr,reportStr]=isEqualElem(varargin)
        % ISEQUALELEM compares the specified CubeStruct object with other CubeStruct
        % object and returns true if they are equal, otherwise it
        % returns false
        %
        % Usage: isEqArr=isEqualElem(selfArr,otherArr,varargin)
        %
        % Input:
        %   regular:
        %       selfArr: ARelation [n_1,n_2,...,n_k] - calling
        %           object
        %       otherArr: ARelation [n_1,n_2,...,n_k] - other
        %           object to compare with
        %
        %   properties:
        %       asHandle: logical[1,1] - if true, elements are compared
        %           as handles ignoring content of the objects   
        %       propEqScalarList: cell[1,] - list of properties passed
        %           to isEqualScalarInternal method  
        %
        %       checkTupleOrder: logical[1,1] -  if true, then the tuples in the 
        %           compared relations are expected to be in the same order,
        %           otherwise the order is not important (false by default)        
        %       checkFieldOrder: logical [1,1] -
        %           if true, then fields in compared objects must
        %           be in the same order, otherwise the order is not
        %           important (false by default)
        %
        %       compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
        %           referenced from the meta data objects are also compared
        %
        %       maxTolerance: double [1,1] - maximum allowed tolerance
        %
        %       maxRelativeTolerance: double [1,1] - maximum allowed relative
        %           tolerance
        %
        % Output:
        %   isEqArr: logical[n_1,n_2,...,n_k] - result of comparison
        %   reportStr: char[1,] - contains an additional information about the
        %      differences (if any)
        %
        %
        % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 11-June-2015 $ 
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2015 $
        %                        
            import modgen.common.parseparams;
            %
            [regArgList,propEqScalarList]=...
                smartdb.relations.ARelation.parseEqScalarProps(...
                smartdb.relations.ARelation.getRelOnlyIsEqualPropCheckCMat(),...
                varargin);
            %
            [isEqArr,reportStr]=...
                isEqualElem@smartdb.cubes.CubeStruct(...
                regArgList{:},'propEqScalarList',propEqScalarList);
        end        
    end
    methods (Access=protected)
        function [isEq,reportStr]=isEqualScalarInternal(self,otherObj,...
                varargin)
            % ISEQUAL - compares current relation object with other relation object and 
            %           returns true if they are equal, otherwise it returns false
            % 
            %
            % Usage: isEq=isEqual(self,otherObj)
            %
            % Input:
            %   regular:
            %     self: ARelation [1,1] - current relation object
            %     otherObj: ARelation [1,1] - other relation object
            %
            %   properties:
            %     checkFieldOrder: logical [1,1] - if true, then fields 
            %         in compared relations must be in the same order, otherwise the 
            %         order is not  important (false by default)  
            %
            %     checkTupleOrder: logical[1,1] -  if true, then the tuples in the 
            %         compared relations are expected to be in the same order,
            %         otherwise the order is not important (false by default)
            %         
            %     maxTolerance: double [1,1] - maximum allowed tolerance            
            %
            %     compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            %     	referenced from the meta data objects are also compared
            %
            %     maxRelativeTolerance: double [1,1] - maximum allowed
            %       relative tolerance
            %
            % Output:
            %   isEq: logical[1,1] - result of comparison
            %   reportStr: char[1,] - report of comparsion
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-31 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            %
            import modgen.common.throwerror;
            PROP_NAME_LIST={'checkfieldorder','checktupleorder',...
                'comparemetadatabackwardref','maxtolerance',...
                'maxrelativetolerance'};
            SORT_DIM=1;
            %
            if numel(self)~=1||numel(otherObj)~=1,
                throwerror('wrongInput',...
                    'both object to be compared must be scalar');
            end
            propCheckMat=...
                smartdb.relations.ARelation.getRelIsEqualPropCheckCMat(...
                PROP_NAME_LIST);
            [~,~,isFieldOrderCheck,isCheckTupleOrder,...
                isCompareCubeStructBackwardRef,maxTolerance,...
                maxRelTolerance]=modgen.common.parseparext(varargin,...
                propCheckMat,0);
            %
            inpArgList={'compareMetaDataBackwardRef',...
                isCompareCubeStructBackwardRef,...
                'maxTolerance',maxTolerance,'maxRelativeTolerance',...
                maxRelTolerance};
            %
            if ~isCheckTupleOrder
                inpArgList=[inpArgList,{'sortDim',SORT_DIM}];
            end
            isEq=isequal(self.getMinDimensionSizeInternal(),...
                otherObj.getMinDimensionSizeInternal());
            if isEq,
                [isEq,reportStr]=...
                    isEqualScalarInternal@smartdb.cubes.CubeStruct(...
                    self,otherObj,...
                    'checkFieldOrder',isFieldOrderCheck,inpArgList{:});
            else
                reportStr='Number of tuples is different';
            end
        end
        %
    end
    %
    methods
        function self=ARelation(varargin)
            % ARELATION is a constructor of relation class object
            %
            % Usage: self=ARelation(varargin)
            %
            % Input:
            %   optional:
            %     inpObj: ARelation[1,1]/SData: struct[1,1]
            %         structure with values of all fields
            %         for all tuples
            %
            %     SIsNull: struct [1,1] - structure of fields with is-null
            %        information for the field content, it can be logical for
            %        plain real numbers of cell of logicals for cell strs or
            %        cell of cell of str for more complex types
            %
            %     SIsValueNull: struct [1,1] - structure with logicals
            %         determining whether value corresponding to each field
            %         and each tuple is null or not
            %
            %   OR
            %
            %   regular:
            %     sizeVec: double [1,nDims] - size of array that is
            %         necessary to generate as result of constructor
            % Output:
            %   regular:
            %     self: ARelation [1,1] (or any size) - constructed class
            %         object(s)
            %
            %   Subclasses probably do have an overriden version of this
            %   method which defines either dynamic or static set of fields
            %
            % (tweaked to use CubeStuct as a base class)
            %
            self=self@smartdb.cubes.CubeStruct(varargin{:},'minDimensionality',1);
            
        end
    end
    %
    methods (Access=protected,Hidden)
        displayInternal(self,typeStr)
        resRel=getJoinWithInternal(self,otherRel,keyFieldNameList,varargin)
        % GETJOINWITHINTERNAL returns a result of INNER join of given relation 
        % with another relation by the specified key fields 
        [SData,SIsNull,SIsValueNull]=getTuplesInternal(self,varargin)
        % GETTUPLESINTERNAL returns internal representation of tuples for
        % given relation
        addTuplesInternal(self,varargin)
        % ADDTUPLESINTERNAL adds a set of new tuples to the relation
        resCVec=toFieldListInternal(self,fieldNameList,structNameList,isGroupByStruct)
        % TOFIELDLISTINTERNAL transforms a content of a relation into a
        % cell array of column values
        [resRel,resOtherRel]=getTuplesJoinedWithInternal(self,otherRel,...
            keyFieldNameList,varargin)
        % GETTUPLESJOINEDWITHINTERNAL returns the tuples of the given relation INNER-joined
        % with other relation by the specified key fields         
    end
    methods (Static)
        relDataObj=fromStructList(className,structList)
            % FROMSTRUCTLIST creates a dynamic relation from a list of
            % structures interpreting each structure as the data for
            % several tuples.
            %        
    end
    methods (Static,Hidden,Access=protected)
        function isPositive=isMe(inpObj)
            curClassName=mfilename('class');
            isPositive=isa(inpObj,curClassName);
        end
        
    end
end