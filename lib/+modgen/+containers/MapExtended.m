classdef MapExtended<containers.Map
    methods
        function [isPos,reportStr]=isEqualProp(self,otherObj)
            isPos=isequal(self.KeyType,otherObj.KeyType);
            if ~isPos
                reportStr='incompatible key types';
            else
                isPos=self.Count==0||otherObj.Count==0||...
                    isequal(self.ValueType,otherObj.ValueType);
                if ~isPos
                    reportStr='incompatible value types';
                else
                    reportStr='';
                end
            end
        end
        %
        function checkIfEqualProp(self,otherObj)
            import modgen.common.throwerror;
            [isPos,reportStr]=isEqualProp(self,otherObj);
            if ~isPos
                throwerror('wrongInput',reportStr);
            end
        end
        % Override copyElement method:
        function self=MapExtended(varargin)
            self=self@containers.Map(varargin{:});
        end
        %
        function obj=getUnionWith(self,otherObj)
            import modgen.containers.MapExtended;
            import modgen.common.throwerror;
            if self.Count>0||otherObj.Count>0
                self.checkIfEqualProp(otherObj);
                keyList=[self.keys,otherObj.keys];
                if ~modgen.common.isunique(keyList)
                    throwerror('wrongInput:dupicateKeys',...
                        'key lists of both map objects cannot intersect');
                end
                %
                obj=MapExtended(keyList,...
                    [self.values,otherObj.values]);
            else
                obj=self.getCopy();
            end
        end
        %
        function SRes=toStruct(self)
            import modgen.containers.MapExtended;
            keyList=self.keys;
            fieldNameList=cellfun(@MapExtended.key2FieldName,keyList,...
                'UniformOutput',false);
            %
            valueList=self.values;
            isMapVec=cellfun('isclass',valueList,mfilename('class'));
            valueList(isMapVec)=cellfun(@(x)x.toStruct(),...
                valueList(isMapVec),'UniformOutput',false);
            keyValueMat=[fieldNameList;valueList];
            %
            SRes=struct(keyValueMat{:});
        end
        %
        function obj=getCopy(self)
            import modgen.containers.MapExtended;
            if self.Count>0
                isUniform=~strcmp(self.ValueType,'any');
                obj=MapExtended(self.keys,self.values,'UniformValues',...
                    isUniform);
            else
                obj=MapExtended('KeyType',self.KeyType,...
                    'ValueType',self.ValueType);
            end
        end
        function [isPos,reportStr]=isEqual(self,otherObj)
            import modgen.struct.structcompare;
            isPos=isequal(self,otherObj);
            if isPos
                reportStr='';
            else
                [isPos,reportStr]=self.isEqualProp(otherObj);
                if isPos
                    [isPos,reportStr]=structcompare(self.toStruct(),...
                        otherObj.toStruct());
                end
            end
        end
    end
    methods (Static)
        function fieldName=key2FieldName(keyName)
            import modgen.containers.MapExtended;
            N_MAX_NO_HASHED_CHARS=30;
            %
            nChars=length(keyName);
            nNoHachedChars=min(N_MAX_NO_HASHED_CHARS,nChars);
            fieldReadableNamePart=MapExtended.genVarName(...
                keyName(1:nNoHachedChars));
            nReadableChars=length(fieldReadableNamePart);
            nNotHashed=min(nNoHachedChars,nReadableChars);
            toHashStr=[fieldReadableNamePart(...
                nNotHashed+1:end),...
                keyName(nNoHachedChars+1:end)];
            %
            if ~isempty(toHashStr)
                if length(toHashStr)>32||~isvarname(toHashStr)
                    hashedStr=hash(toHashStr,'md2');
                else
                    hashedStr=toHashStr;
                end
                fieldName=[fieldReadableNamePart(1:nNotHashed),...
                    '_',hashedStr];
            else
                fieldName=fieldReadableNamePart(1:nNotHashed);
            end
        end
    end
    %
    methods (Static, Access=private)
        function varname=genVarName(varname)
            if ~isvarname(varname) % Short-circuit if varname already legal
                % Insert x if the first column is non-letter.
                varname = regexprep(varname,'^\s*+([^A-Za-z])','x$1', 'once');
                
                % Replace whitespace with camel casing.
                [~, afterSpace] = regexp(varname,'\S\s+\S');
                for j=afterSpace
                    varname(j) = upper(varname(j));
                end
                varname = regexprep(varname,'\s+','');
                if (isempty(varname))
                    varname = 'x';
                end
                % Replace non-word character with its HEXADECIMAL equivalent
                illegalChars = unique(varname(regexp(varname,'[^A-Za-z_0-9]')));
                for illegalChar=illegalChars
                    if illegalChar <= intmax('uint8')
                        width = 2;
                    else
                        width = 4;
                    end
                    replace = ['0x' dec2hex(illegalChar,width)];
                    varname = strrep(varname, illegalChar, replace);
                end
                % Prepend keyword with 'x' and camel case.
                if iskeyword(varname)
                    varname = ['x' upper(varname(1)) varname(2:end)];
                end
            end
        end
    end
end
