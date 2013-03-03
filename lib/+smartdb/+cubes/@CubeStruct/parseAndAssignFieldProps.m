function parseAndAssignFieldProps(self,varargin)
% PARSEANDASSIGNFIELDPROPS parses field properties for CubeStruct object
% and assignes them to the object
%
% Usage: initialize(self,varargin)
%
% Input:
%   regular:
%     self: CubeStruct [1,1]
%
%   properties:
%     fieldNameList: char cell [1,nFields] - list of names for
%         fields of given object
%     fieldDescrList: char cell [1,nFields] - list of
%         descriptions for fields of given object
%     fieldTypeSpecList: cell[1,nFields] of cell of char - field type
%        specification
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[~,prop]=modgen.common.parseparams(varargin,[],0);
nProp=length(prop);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'fieldnamelist',
            smartdb.cubes.CubeStructFieldInfoBuilder.setNameList(...
                prop{k+1});
        case 'fielddescrlist'
            smartdb.cubes.CubeStructFieldInfoBuilder.setDescrList(...
                prop{k+1});
        case 'fieldtypespeclist',
            smartdb.cubes.CubeStructFieldInfoBuilder.setTypeSpecList(...
                prop{k+1});
        case 'fieldmetadata',
            smartdb.cubes.CubeStructFieldInfoBuilder.setMetaDataVec(...
                prop{k+1});
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'unidentified property name: %s ',prop{k});
    end
end