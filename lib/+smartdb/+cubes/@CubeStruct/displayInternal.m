function displayInternal(self,typeStr,varargin)
% DISPLAYINTERNAL is used by display method to do the job
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[~,prop]=modgen.common.parseparams(varargin,[],0);
isMetaDataStrSpec=false;
isPropertiesDisplayed=true;
isHeaderDisplayed=true;
for k=1:2:length(prop)
    switch lower(prop{k})
        case 'metadataextrastr',
            isMetaDataStrSpec=true;
            metaDataExtraStr=prop{k+1};
        case 'displayproperties',
            isPropertiesDisplayed=prop{k+1};
        case 'displayheader',
            isHeaderDisplayed=prop{k+1};
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'property %s is not supported',prop{k});
    end
            
end
nElem=numel(self);
%
if isHeaderDisplayed
    sizeVec=size(self);
    disp(['-------',typeStr,' object-------']);
end
if isPropertiesDisplayed    
    SDisp.size=sizeVec;
    SDisp.actualClass=class(self);
    disp('Properties:')
    strucdisp(SDisp);
    fprintf('\n');
    %
    if isMetaDataStrSpec
        disp(metaDataExtraStr);
    end
end
%
if nElem==1
    if isPropertiesDisplayed
        fprintf('Dimensionality: %s \n',...
            mat2str(self.getMinDimensionSizeInternal()));
    end
    %
    disp('Fields (name, type, size, description):');
    fieldTypeSpecs=cellfun(@(x)cell2sepstr([],x,'->'),...
        self.getFieldTypeSpecList,'UniformOutput',false);
    fieldNames=self.getFieldNameList;
    sizeMat=self.getFieldValueSizeMat('skipMinDimensions',true);
    nFields=length(fieldNames);
    sizeList=cellfun(@mat2str,...
        mat2cell(sizeMat,ones(1,nFields),size(sizeMat,2)),...
        'UniformOutput',false).';
    fieldDescrList=self.getFieldDescrList;
    showcell([fieldNames;fieldTypeSpecs;sizeList;fieldDescrList].');
end