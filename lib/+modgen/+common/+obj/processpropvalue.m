function valueList=processpropvalue(objSizeVec,value,fTypeCheckFunc)
% PROCESSPROPVALUE is a helper function for assigning property values
% especially when a set of values should be assigned to an
% array of objects in a vectorial manner
%
% Input: 
%   regular:
%       sizeVec: numeric[1,k]= [n1,n2,...,n_k] - size of the target object
%          array to which the value should be assigned
%       value: any[]/cell[n1,n2,...,n_k] - a value to be assigned to self
%          array (please note that it is acceptable for value and self to
%          be of a different size, but in the latter case value should
%          either contain the same number of elements or be a property
%          value that is to be propogated to all the elements of self array
%
%       fTypeCheckFunc: function_handle[1,1] - a function that checks if
%          the value type corresponds to the object field type
%
% Output:
%   valueArray: cell[n1,n2,...,n_k] - an array of property values
% 
% Example1: 
%   valueArray=processpropvalue([10 20 30],{'cell','char'},@iscellstr)
%       in this example {'cell','char'} is a single property value because it
%       passes @iscellstr check; thus the function replicates this value
%       for for all elements of valueArray where size(valueArray)=[10 20 30]
%   
% Example2:
%   valueArray=processpropvalue([10 20 30],{{'cell','char'}},@iscellstr)
%       in this example the function automatically figures out that it is
%       {'cell','char'}, not {{'cell','char'}} that is a property value.
%       Thus {'cell','char'} is replicated to form valueArray
%
% Example3: (using the function to implement assignValue method of some handle class: 
%
%         function valueList=assignValue(self,value,fTypeCheckFunc,fieldName)
%             % ASSIGN value is a thin wrapper for processvalue which allows
%             % a vectorial property assignment
%             %
%             valueList=modgen.common.obj.processvalue(size(self),value,fTypeCheckFunc);
%             [self.(fieldName)]=deal(valueList{:});
%             %
%         end
%   In this example self is an object array
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-02-16 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
nExpected=prod(objSizeVec);
if ~isa(fTypeCheckFunc,'function_handle')
    error([upper(mfilename),':wrongInput'],...
        'expectedType is expected to be a function_handle');
end
if ~(isnumeric(nExpected)&&(fix(nExpected)==nExpected))
    %&&(nExpected>0))
    error([upper(mfilename),':wrongInput'],...
        'nExpected is expected to be an integer positive number');
end
%
valueLength=numel(value);
%
if fTypeCheckFunc(value)
    if valueLength==nExpected
        valueList=num2cell(value);
    elseif valueLength<=1
        if valueLength==1&&iscell(value)&&fTypeCheckFunc(value{1})
                error([upper(mfilename),':wrongInput'],...
                    ['an ambiguous attempt to assign the value: ',...
                      'the value''s type is correct but it is a cell and its content',...
                      'also has a correct type']);
        end
        valueList=repmat({value},objSizeVec);
    else
        error([upper(mfilename),':wrongInput'],...
            ['the passed value''s length (%d) doesn''t equal the expected ',...
            'lenght (%d)'],...
            valueLength,nExpected);
    end
elseif iscell(value)
    if (valueLength==nExpected)
        if all(cellfun(fTypeCheckFunc,value))
            valueList=value;
        else
            error([upper(mfilename),':wrongInput'],...
                ['all elements of passed cell ',...
                'array are expected to have the type specified by ',...
                'function %s '],func2str(fTypeCheckFunc));
        end
    elseif valueLength==1
        valueList=repmat(value,objSizeVec);
    else
        error([upper(mfilename),':wrongInput'],...
            ['the passed value''s length (%d) doesn''t equal the expected ',...
            'lenght (%d)'],...
            valueLength,nExpected);
    end
else
    error([upper(mfilename),':wrongInput'],...
        'the passed value''s type (%s) is not expected',...
        class(value));
end