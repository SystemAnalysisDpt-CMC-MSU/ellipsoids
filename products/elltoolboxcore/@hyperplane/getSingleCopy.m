function copyHpObj = getSingleCopy(hpObj)
% GETCOPY - returns the copy of single hyperplane.
%
% Input:
%	regular:
%		ellObj: hyperplane[1,1] - hyperplane
%
% Output:
%	copyEllObj: hyperplane[1,1] - copy of given hyperplane
% 
% Example:
%	ellObj = hyperplane(1);
%	copyEllObj = getCopy(ellObj)
%	-------hyperplane object-------
%	Properties:
%		|    
%		|-- actualClass : 'hyperplane'
%		|--------- size : [1 1]
%
%	Fields (name, type, description):
%		'normal'    'double'    'Hyperplane normal'
%		'shift'     'double'    'Hyperplane shift'
%
%	Data: 
%		|    
%		|-- normal : 1
%		|--- shift : 0
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
hyperplane.checkIsMe(hpObj);
copyHpObj=feval(class(hpObj));
copyHpObj.normal=hpObj.normal;
copyHpObj.shift=hpObj.shift;
copyHpObj.absTol=hpObj.absTol;
end