classdef ARelation<smartdb.cubes.CubeStruct
    %ARELATION Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant,Hidden)
        MAX_TUPLES_TO_DISPLAY=15
    end
    %
    methods
        function [isEq,reportStr]=isEqual(self,otherObj,varargin)
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
            %     checkFieldOrder/isFieldOrderCheck: logical [1,1] - if true, then fields 
            %         in compared relations must be in the same order, otherwise the 
            %         order is not  important (false by default)        
            %     checkTupleOrder: logical[1,1] -  if true, then the tuples in the 
            %         compared relations are expected to be in the same order,
            %         otherwise the order is not important (false by default)
            %         
            %     maxTolerance: double [1,1] - maximum allowed tolerance            
            %
            %     compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            %         referenced from the meta data objects are also compared
            %
            %     maxRelativeTolerance: double [1,1] - maximum allowed
            %     relative tolerance
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
            isCompareCubeStructBackwardRef=true;
            if nargin<2,
                error([upper(mfilename),':wrongInput'],...
                    'both object to be compared must be given');
            end
            if numel(self)~=1||numel(otherObj)~=1,
                error([upper(mfilename),':wrongInput'],...
                    'both object to be compared must be scalar');
            end
            [~,prop]=modgen.common.parseparams(varargin,[],0);
            nProp=length(prop);
            isFieldOrderCheck=false;
            isSortedBeforeCompare=true;
            sortDim=1;
            inpArgList={};
            for k=1:2:nProp-1
                switch lower(prop{k})
                    case {'isfieldordercheck','checkfieldorder'},
                        isFieldOrderCheck=prop{k+1};
                    case 'checktupleorder',
                        if prop{k+1}
                            isSortedBeforeCompare=false;
                        end
                    case 'comparemetadatabackwardref',
                        isCompareCubeStructBackwardRef=prop{k+1};
                    case {'maxtolerance','maxrelativetolerance'},
                        inpArgList=[inpArgList, prop([k,k+1])];
                    otherwise,
                        error([upper(mfilename),':wrongInput'],...
                            'unidentified property name: %s ',prop{k});
                end
            end
            inpArgList=[inpArgList,...
                {'compareMetaDataBackwardRef',isCompareCubeStructBackwardRef}];
            if isSortedBeforeCompare
                inpArgList=[inpArgList,{'sortDim',sortDim}];
            end
            [isEq,reportStr]=isEqual@smartdb.cubes.CubeStruct(self,otherObj,...
                'checkFieldOrder',isFieldOrderCheck,inpArgList{:});
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
            % Output:
            %   regular:
            %     self: ARelation [1,1] - constructed class object
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