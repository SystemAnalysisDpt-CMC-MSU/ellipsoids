classdef PlotPropProcessor
    
    properties (Access = private)
        fullArgNameList;
        colorFieldList;
        lineWidthFieldList;
        isFillFieldList;
        transparencyFieldList;
        fColor;
        fLineWidth;
        fTransparency;
        fIsFill;
    end
    
    methods (Access = private)
        
        function propValue = getProp(self, argList, fGetProp,...
            propFieldList)
        
            indPropFieldVec = self.getIndexOfField(propFieldList);
            propValue = getPropByInd(self, argList, fGetProp,...
                indPropFieldVec);
            
        end
        
        function indFieldVec = getIndexOfField(self, propFieldList)
            [isThereVec, indFieldVec] =...
                ismember(propFieldList, self.fullArgNameList);

            if ~all(isThereVec)
                throwerror('wrongInput',...
                    'colorFieldList is expected to contain fields only from the following list %s',...
                modgen.cell.cellstr2expression(self.fullArgNameList));
            end
            indFieldVec = indFieldVec(find(indFieldVec));
        end
        
        function propValue = getPropByInd(self, inputNameList, fGetProp,...
            indPropFieldVec)
            
            argPropCVec = arrayfun(@(x)...
                (inputNameList{indPropFieldVec(x)}),...
                1 : numel(indPropFieldVec), 'UniformOutput', false);
            
            propValue = fGetProp(argPropCVec{:});
        end
    end
    
    methods
        function self =...
            PlotPropProcessor(fullArgNameList, fColor, colorFieldList,...
                fLineWidth, lineWidthFieldList, fIsFill, isFillFieldList,...
                fTransparency, transparencyFieldList) 
            % PlotPropProcessor - set value all properties
            %
            % Input:
            %   regular:
            %       fullArgNameList: cell[nArg, ] - full list of
            %           possible arguments
            %       fColor: function_handle[1, 1] - function 
            %           for property 'color'
            %       colorFieldList: cell[nField, ] - list of   
            %           arguments for property 'color'
            %       fLineWidth: function_handle[1, 1] - function 
            %           for property 'lineWidth'
            %       lineWidthFieldList: cell[nField, ] - list of   
            %           arguments for property 'lineWidth'
            %       fIsFill: function_handle[1, 1] - function 
            %           for property 'isFill'
            %       isFillFieldList: cell[nField, ] - list of   
            %           arguments for property 'isFill'
            %       fTransparency: function_handle[1, 1] - function 
            %           for property 'transparency'
            %       transparencyFieldList: cell[nField, ] - list of   
            %           arguments for property 'transparency'
            % Ouptput:
            %   self.
            %
            % Artem Grachev <grachev.art@gmail.com> %
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science, 
            %             System Analysis Department 2013$
            
            self.fullArgNameList = fullArgNameList;
            
            self.colorFieldList = colorFieldList;
            self.lineWidthFieldList = lineWidthFieldList;
            self.isFillFieldList = isFillFieldList;
            self.transparencyFieldList = transparencyFieldList;
            
            self.fColor = fColor;
            self.fLineWidth = fLineWidth;
            self.fTransparency = fTransparency;
            self.fIsFill = fIsFill;            
        end
        
        
        function colorVec = getColor(self, argList)
            % GETCOLOR return colorVec specified by
            %   function_handle self.fColor and argList
            %
            % Input:
            %   regular:
            %       self.
            %       argList: cell[nArg, ] - list of value
            %           arguments for function_hanlde
            %           self.fColor
            %
            % Ouptput:
            %   colorVec: double[1, 3] - color vector
            %
            % Artem Grachev <grachev.art@gmail.com> %
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science, 
            %             System Analysis Department 2013$
            colorVec = self.getProp(argList, self.fColor,...
                self.colorFieldList);
        end
        
        function lineWidth = getLineWidth(self, argList)
        %
            lineWidth = self.getProp(argList, self.fLineWidth,...
                self.lineWidthFieldList);        
        end
        
        function isFill = getIsFilled(self, argList)
            isFill = self.getProp(argList, self.fIsFill,...
                self.isFillFieldList);
        end
        
        function transparency = getTransparency(self, argList)
            transparency = self.getProp(argList, self.fTransparency,...
                self.transparencyFieldList);
        end
    end
    
end

