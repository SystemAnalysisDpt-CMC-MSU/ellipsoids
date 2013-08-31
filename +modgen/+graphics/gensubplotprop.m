function theAxis = gensubplotprop(nRows, nCols, plotId, varargin)
% gensubplotprop- does the same as the subplot but doesn't create axis
            %
            %
            % Input:
            %   regular:
            %       nRows: doble - number of axes in a row. 
            %       nCols: doble - number of axes in a column. 
            %       plotId: double - plotId-th axes.
            %               %
            % Output:
            %   regular:
            %       theAxis:  cell array -  axes handle (pairs of the 
            %                           form: property - the property value )
            %   
            %
            % $Author: Ilya Lyubich <lubi4ig@gmail.com>$
            %   $Date: 4-august-2013$
            % 
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013 $
            %
inset = [.2, .18, .04, .1];
%
parent = get(0, 'CurrentFigure');
%
[~,~,parent]=modgen.common.parseparext(varargin,{'Parent';parent});
%
ancestorFigure = parent;
if ~isempty(parent) && ~isempty(get(parent, 'CurrentAxes'))
    parent = get(get(parent, 'CurrentAxes'), 'Parent');
    ancestorFigure = parent;
    if ~strcmp(get(ancestorFigure, 'Type'), 'figure')
        ancestorFigure = ancestor(parent, 'figure');
    end
end



if min(plotId) < 1
    error(message('MATLAB:subplot:SubplotIndexTooSmall'))
elseif max(plotId) > nCols * nRows
    error(message('MATLAB:subplot:SubplotIndexTooLarge'));
else
    
    row = (nRows - 1) - fix((plotId - 1) / nCols);
    col = rem(plotId - 1, nCols);
    
    % get default axes position in normalized units
    % If we have checked this quanitity once, cache it.
    if ~isappdata(ancestorFigure, 'SubplotDefaultAxesLocation')
        if ~strcmp(get(ancestorFigure, 'DefaultAxesUnits'), 'normalized')
            tmp = axes;
            set(tmp, 'Units', 'normalized')
            def_pos = get(tmp, 'Position');
            delete(tmp)
        else
            def_pos = get(ancestorFigure, 'DefaultAxesPosition');
        end
        setappdata(ancestorFigure, 'SubplotDefaultAxesLocation', def_pos);
    else
        def_pos = getappdata(ancestorFigure, 'SubplotDefaultAxesLocation');
    end
    
    % compute outerposition and insets relative to figure bounds
    rw = max(row) - min(row) + 1;
    cw = max(col) - min(col) + 1;
    width = def_pos(3) / (nCols - inset(1) - inset(3));
    height = def_pos(4) / (nRows - inset(2) - inset(4));
    inset = inset .* [width, height, width, height];
    outerpos = [def_pos(1) + min(col) * width - inset(1), ...
        def_pos(2) + min(row) * height - inset(2), ...
        width * cw, height * rw];
    
    % adjust outerpos and insets for axes around the outside edges
    if min(col) == 0
        inset(1) = def_pos(1);
        outerpos(3) = outerpos(1) + outerpos(3);
        outerpos(1) = 0;
    end
    if min(row) == 0
        inset(2) = def_pos(2);
        outerpos(4) = outerpos(2) + outerpos(4);
        outerpos(2) = 0;
    end
    if max(col) == nCols - 1
        inset(3) = max(0, 1 - def_pos(1) - def_pos(3));
        outerpos(3) = 1 - outerpos(1);
    end
    if max(row) == nRows - 1
        inset(4) = max(0, 1 - def_pos(2) - def_pos(4));
        outerpos(4) = 1 - outerpos(2);
    end
    
    % compute inner position
    position = [outerpos(1 : 2) + inset(1 : 2), ...
        outerpos(3 : 4) - inset(1 : 2) - inset(3 : 4)];
    
end

theAxis ={'Units', 'normalized', 'Position', position, ...
    'LooseInset', inset, 'Parent', parent};

end