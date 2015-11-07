classdef ASingleTubeControl<handle
    %
    properties (Access=protected)
        properEllTube
        controlVectorFunct
    end
    methods 
        function controlFunc = getControlFunction(self)
            % GETCONTROLFUNCTION returns controlVectorFunct class's
            % property
            %
            % Output:
            %   controlFunc: elltool.control.ControlVectorFunct[1,1]
            %       - an object providing evaluation of control
            %       synthesis for predetermined position (t,x)
            %
            controlFunc = self.controlVectorFunct.clone();
        end
        %
        function properEllTube = getProperEllTube(self)
            % GETPROPERELLTUBE returns copy of properEllTube class's
            % property
            %
            % Output:
            %       properEllTube: gras.ellapx.smartdb.rels.EllTube[1,1]
            %           - an object containing ellipsoidal tube that is
            %           used for contol synthesis constructing
            %
            %
            properEllTube = self.properEllTube.clone();
        end
    end
end