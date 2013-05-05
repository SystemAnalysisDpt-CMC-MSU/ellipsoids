function [hFigure,gridObj]=dispOnUI(self,varargin)
% DISPONUI - displays a content of the given relation as a data grid UI
%            component.
%
% Input:
%   regular:
%       self:
%   properties:
%       tableType: char[1,] - type of table used for displaying the data,
%           the following types are supported:
%           'sciJavaGrid' - proprietary Java-based data grid component 
%               is used
%           'uitable'  - Matlab built-in uitable component is used. 
%               if not specified, the method tries to use sciJavaGrid 
%               if it is available, if not - uitable is used.
%
% Output:
%   hFigure: double[1,1] - figure handle containing the component
%   gridObj: smartdb.relations.disp.UIDataGrid[1,1] - data grid component 
%       instance used for displaying a content of the relation object
%  
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-21 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
hFigure=figure();
hPanel = uipanel('Parent',hFigure,'Position',[0 0 1 1]);
gridObj= smartdb.relations.disp.UIDataGrid(...
    'panelHandle',hPanel,'nullTopReplacement','N/A',varargin{:});
gridObj.putRel(self);