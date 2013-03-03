function displayInternal(self,typeStr)
% DISPLAYINTERNAL displays a content of relation object and prints its type
% using the specified type string
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-18 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
displayInternal@smartdb.cubes.CubeStruct(self,typeStr);
if numel(self)==1
    fprintf('Data (first row contain field names):\n');
    nTuples=self.getNTuples;
    if self.getNFields()>0
        if nTuples<=self.MAX_TUPLES_TO_DISPLAY
            showcell([self.getFieldNameList;self.toDispCell()],...
                'printVarName',false);
        else
            indVec=1:self.MAX_TUPLES_TO_DISPLAY;
            showcell([self.getFieldNameList;...
                self.getTuples(indVec).toDispCell()],...
                'printVarName',false);
            %
            fprintf('... <<%d tuples more>> ...\n',...
                nTuples-self.MAX_TUPLES_TO_DISPLAY);
        end
    end
end