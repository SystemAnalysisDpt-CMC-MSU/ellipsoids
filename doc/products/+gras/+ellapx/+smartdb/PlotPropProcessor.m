classdef PlotPropProcessor
    % PlotPropProcessor - class that processes different
    %   functions which specified properties for plot.
    %   This class has series methods for getting necessary
    %   properties.
    %   
    % $Authors: 
    % Artem Grachev <grachev.art@gmail.com> 
    % $Date: May-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science, 
    %             System Analysis Department 2013$
    
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
        end
        
        function propValue = getPropByInd(~, inputNameList, fGetProp,...
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
            %       fullArgNameList: cell[nArgs, ] of char[1, ] - full 
            %           list of possible arguments
            %       fColor: function_handle[1, 1] - function 
            %           for property 'color'
            %       colorFieldList: cell[nColorFields, ] of char[1, ] - 
            %           list of arguments for property 'color'
            %       fLineWidth: function_handle[1, 1] - function 
            %           for property 'lineWidth'
            %       lineWidthFieldList: cell[nLineWidthFields, ] 
            %           of char[1, ] - list of arguments for property 
            %           'lineWidth'
            %       fIsFill: function_handle[1, 1] - function 
            %           for property 'isFill'
            %       isFillFieldList: cell[nIsFillFields, ] of char[1, ] - 
            %           list of arguments for property 'isFill'
            %       fTransparency: function_handle[1, 1] - function 
            %           for property 'transparency'
            %       transparencyFieldList: cell[nTransparencyFields, ] of 
            %           char[1, ] - list of arguments for property 
            %           'transparency'
            % Ouptput:
            %   self.
            %
            % Artem Grachev <grachev.art@gmail.com> 
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science, 
            %             System Analysis Department 2013$
            
            checkInput(); 
            self.fullArgNameList = fullArgNameList;
                      
            self.colorFieldList = colorFieldList;
            self.lineWidthFieldList = lineWidthFieldList;
            self.isFillFieldList = isFillFieldList;
            self.transparencyFieldList = transparencyFieldList;
            
            self.fColor = fColor;
            self.fLineWidth = fLineWidth;
            self.fTransparency = fTransparency;
            self.fIsFill = fIsFill;
            function checkInput()
                checkFunctionAndArgList(fColor, colorFieldList);
                checkFunctionAndArgList(fLineWidth, lineWidthFieldList);
                checkFunctionAndArgList(fIsFill, isFillFieldList);
                checkFunctionAndArgList(fTransparency, transparencyFieldList);
            end
            function checkFunctionAndArgList(fProp, propArgList)
                import modgen.common.checkvar
                modgen.common.checkvar(propArgList,...
                    'iscellofstring(x)&&isrow(x)', 'errorTag',...
                    'wrongInput:badType','errorMessage',...
                    'Excpect cell of string');
                modgen.common.checkvar(fProp,...
                    'isfunction(x)', 'errorTag',...
                    'wrongInput:badType','errorMessage',...
                    'Excpect function_handle');
            end
        end
        
        
        function colorVec = getColor(self, argList)
            % GETCOLOR return colorVec specified by
            %   function_handle self.fColor and argList
            %
            % Input:
            %   regular:
            %       self.
            %       argList: cell[nArgs, ] of char[1, ] - list of value
            %           arguments for function_hanlde self.fColor
            %
            % Ouptput:
            %   colorVec: double[1, 3] - color vector
            %
            % Artem Grachev <grachev.art@gmail.com> 
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science, 
            %             System Analysis Department 2013$
            colorVec = self.getProp(argList, self.fColor,...
                self.colorFieldList);
        end
        
        function lineWidth = getLineWidth(self, argList)
            % GETCOLOR return lineWidth value specified by
            %   function_handle self.fLineWidth and argList
            %
            % Input:
            %   regular:
            %       self.
            %       argList: cell[nLineWidthArgs, ] of char[1, ] - list of 
            %           value arguments for function_hanlde
            %           self.fLineWidth
            %
            % Ouptput:
            %   lineWidth: double[1, 1] - value line width
            %
            % Artem Grachev <grachev.art@gmail.com> 
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science, 
            %             System Analysis Department 2013$
            lineWidth = self.getProp(argList, self.fLineWidth,...
                self.lineWidthFieldList);        
        end
        
        function isFill = getIsFilled(self, argList)
            % GETCOLOR return isFill value
            %
            % Input:
            %   regular:
            %       self.
            %       argList: cell[nIsFillArgs, ] of char[1, ] - list of 
            %           value arguments for function_hanlde self.fIsFill
            %
            % Ouptput:
            %   isFill: logical[1, 1] - true if need to
            %       fill, false if not need to fill
            %
            % Artem Grachev <grachev.art@gmail.com> 
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science, 
            %             System Analysis Department 2013$
            isFill = self.getProp(argList, self.fIsFill,...
                self.isFillFieldList);
        end
        
        function transparency = getTransparency(self, argList)
            % GETCOLOR return transparency value specified by
            %   function_handle self.fTransparency and argList
            %
            % Input:
            %   regular:
            %       self.
            %       argList: cell[nTransparencyArgs, ] of char[1, ] - list 
            %           of value arguments for function_hanlde 
            %           self.fTransparency
            %
            % Ouptput:
            %   transparency: double[1, 1] - value of
            %       transparency
            %
            % Artem Grachev <grachev.art@gmail.com> 
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science, 
            %             System Analysis Department 2013$
            transparency = self.getProp(argList, self.fTransparency,...
                self.transparencyFieldList);
        end
    end
    
end

