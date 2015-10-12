classdef CubeStructEqualAppliance<modgen.common.obj.HandleObjectCloner
    methods
        function [isEq,varargout]=isEqual(varargin)
        % ISEQUAL compares the specified CubeStructEqualAppliance object 
        % with other CubeStructEqualAppliance
        % object and returns true if they are equal, otherwise it
        % returns false
        %
        % Usage: isEq=obj1Arr.isEqual(,...,objNArr,varargin) or
        %        [isEq,reportStr]=isequal(obj1Arr,...,objNArr,varargin)
        %
        % Input:
        % 	regular:
        %       obj1Arr: CubeStructEqualAppliance of any size - first object
        %           array
        %       obj2Arr: CubeStructEqualAppliance of any size - second object
        %           array
        %           ...
        %       objNArr: CubeStructEqualAppliance of any size - N-th object
        %           array
        %
        %   properties:
        %       asHandle: logical[1,1] - if true, elements are compared
        %           as handles ignoring content of the objects   
        %       propEqScalarList: cell[1,] - list of properties passed
        %           to isEqualScalarInternal method         
        %       checkFieldOrder: logical [1,1] -
        %           if true, then fields in compared objects must
        %           be in the same order, otherwise the order is not
        %           important (false by default)
        %
        %       sortDim: numeric[1,1] - dimension along which the CubeStructEqualAppliance slices
        %           order is considered irrelevant with regard to equality
        %
        %       compareMetaDataBackwardRef: logical[1,1] if true, the CubeStructEqualAppliance's
        %           referenced from the meta data objects are also compared
        %
        %       compareMetaDataParamList: cell[1,nParam] - list of additional
        %           parameters passed to isEqual method of CubeStructEqualAppliance from isEqual method
        %           of CubeStructFieldInfo. This list is used particularly to
        %           elimitate an infinite loop when comparing the reverse
        %           references from CubeStructFieldInfo to CubeStructEqualAppliance
        %
        %       maxTolerance: double [1,1] - maximum allowed tolerance
        %
        %       maxRelativeTolerance: double [1,1] - maximum allowed relative
        %           tolerance
        %
        %       leftIndCVec: cell[1,nLeftIndDims] - list of indices to be applied to
        %           the dimensions of left-hand side CubeStructEqualAppliance object
        %
        %       leftDimVec: numeric[1,nLeftIndDims] - vector of index dimensions for
        %           which leftIndCVec is specified
        %
        %       rightIndCVec: cell[1,nRightIndDims] - same as leftIndCVec but for the
        %           right-hand side CubeStructEqualAppliance object
        %
        %       rightDimVec: numeric[1,nRightIndDims] - same as leftDimVec but for
        %           the right-hand side CubeStructEqualAppliance object
        %
        %           Note: sortDim property cannot be specified along with
        %           any of leftIndCVec, leftDimVec, rightIndCVec, rightDimVec
        %           properties
        %
        %       compareFuncHandle: function_handle[1,1] - function handle used to
        %           compare data structures
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
            indObj=find(cellfun(@(x)isa(x,mfilename('class')),varargin),...
                1,'first');   
            %
            [regArgList,propEqScalarList]=...
                varargin{indObj}.parseEqScalarProps(...
                varargin{indObj}.getIsEqualPropCheckCMat(),...
                varargin);        
            %
            varargout=cell(1,max(nargout-1,0));            
            [isEq,varargout{:}]=...
                isEqual@modgen.common.obj.HandleObjectCloner(...
                regArgList{:},'propEqScalarList',propEqScalarList);
        end
        function [isEqArr,varargout]=isEqualElem(varargin)
        % ISEQUALELEM compares the specified CubeStructEqualAppliance object with other CubeStructEqualAppliance
        % object and returns true if they are equal, otherwise it
        % returns false
        %
        % Usage: isEqArr=isEqualElem(selfArr,otherArr,varargin)
        %
        % Input:
        %   regular:
        %       selfArr: CubeStructEqualAppliance [n_1,n_2,...,n_k] - calling
        %           object
        %       otherArr: CubeStructEqualAppliance [n_1,n_2,...,n_k] - other
        %           object to compare with
        %
        %   properties:
        %     asHandle: logical[1,1] - if true, elements are compared
        %           as handles ignoring content of the objects   
        %     propEqScalarList: cell[1,] - list of properties passed
        %           to isEqualScalarInternal method           
        %     checkFieldOrder: logical [1,1] -
        %         if true, then fields in compared objects must
        %         be in the same order, otherwise the order is not
        %         important (false by default)
        %
        %     sortDim: numeric[1,1] - dimension along which the CubeStructEqualAppliance slices
        %        order is considered irrelevant with regard to equality
        %
        %     compareMetaDataBackwardRef: logical[1,1] if true, the CubeStructEqualAppliance's
        %         referenced from the meta data objects are also compared
        %
        %     compareMetaDataParamList: cell[1,nParam] - list of additional
        %        parameters passed to isEqual method of CubeStructEqualAppliance from isEqual method
        %        of CubeStructFieldInfo. This list is used particularly to
        %        elimitate an infinite loop when comparing the reverse
        %        references from CubeStructFieldInfo to CubeStructEqualAppliance
        %
        %     maxTolerance: double [1,1] - maximum allowed tolerance
        %
        %     maxRelativeTolerance: double [1,1] - maximum allowed relative
        %        tolerance
        %
        %     leftIndCVec: cell[1,nLeftIndDims] - list of indices to be applied to
        %       the dimensions of left-hand side CubeStructEqualAppliance object
        %
        %     leftDimVec: numeric[1,nLeftIndDims] - vector of index dimensions for
        %        which leftIndCVec is specified
        %
        %     rightIndCVec: cell[1,nRightIndDims] - same as leftIndCVec but for the
        %        right-hand side CubeStructEqualAppliance object
        %
        %     rightDimVec: numeric[1,nRightIndDims] - same as leftDimVec but for
        %       the right-hand side CubeStructEqualAppliance object
        %
        %       Note: sortDim property cannot be specified along with
        %           any of leftIndCVec, leftDimVec, rightIndCVec, rightDimVec
        %           properties
        %
        %     compareFuncHandle: function_handle[1,1] - function handle used to
        %        compare data structures
        %
        % Output:
        %   isEqArr: logical[1,1] - result of comparison
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
            indObj=find(cellfun(@(x)isa(x,mfilename('class')),varargin),...
                1,'first');
            %
            [regArgList,propEqScalarList]=...
                varargin{indObj}.parseEqScalarProps(...
                varargin{indObj}.getIsEqualPropCheckCMat(),...
                varargin);        
            %
            varargout=cell(1,max(nargout-1,0));
            [isEqArr,varargout{:}]=...
                isEqualElem@modgen.common.obj.HandleObjectCloner(...
                regArgList{:},'propEqScalarList',propEqScalarList);
        end        
    end
    methods (Access=protected,Sealed)
        function propCheckCMat=getIsEqualPropCheckCMat(~,propNameList)
            import modgen.common.throwerror;
            fIsIndVec=@(y)isnumeric(y)&&...
                modgen.common.type.simple.lib.isvec(y)&&...
                all((y>=0)&(fix(y)==y));
            fIsIndCVec=@(x)(iscell(x)&&...
                modgen.common.type.simple.lib.isvec(x)&&...
                all(cellfun(fIsIndVec,x)));
            %
            propCheckCMat=...
                {'comparefunchandle','checkfieldorder','sortdim',...
                'comparemetadatabackwardref','maxtolerance','maxrelativetolerance',...
                'leftindcvec','rightindcvec','leftdimvec','rightdimvec';...
                @modgen.struct.structcompare,false,[],...
                false,0,0,...
                [],[],[],[];
                'isfunction(x)','isscalar(x)&&islogical(x)','isscalar(x)&&isnumeric(x)&&(x>=1)&&(fix(x)==x)',...
                'islogical(x)&&isscalar(x)','isnumeric(x)&&isscalar(x)&&(x>=0)','isnumeric(x)&&isscalar(x)&&(x>=0)',...
                fIsIndCVec,fIsIndCVec,fIsIndVec,fIsIndVec};
            if nargin>1
                [isThereVec,indThereVec]=ismember(lower(propNameList),...
                    lower(propCheckCMat(1,:)));
                if ~all(isThereVec)
                    throwerror('wrongInput','not all properties are know');
                end
                propCheckCMat=propCheckCMat(:,indThereVec);
            end
        end
    end    
end