classdef LegendDisplayTC < mlunitext.test_case
    methods
        function self = tear_down(self)
            close all;
        end

        function self = LegendDisplayTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end

        function self = test2dEllipsoid(self)
            ell1 = ellipsoid([1 0; 0 1]);
            plObj = plot(ell1);
            legend('show');
            SProps = plObj.getPlotStructure();
            SFigure = SProps.figHMap.toStruct();
            hFigure = SFigure.figure_g1;
            childVec = hFigure.Children;
            mlunitext.assert_equals(length(childVec), 2);
            hAxes = childVec(2);
            hLegend = childVec(1);
            graphicalObjectsVec = hAxes.Children;
            mlunitext.assert_equals(length(graphicalObjectsVec), 2);
            center = graphicalObjectsVec(1);
            ell = graphicalObjectsVec(2);
            mlunitext.assert_equals(ell.FaceColor, 'none');
            mlunitext.assert_equals(...
                center.Annotation.LegendInformation.IconDisplayStyle, 'off');
            mlunitext.assert_equals(...
                ell.Annotation.LegendInformation.IconDisplayStyle, 'on');
            str = hLegend.String{1};
            mlunitext.assert_equals(str, '1');
        end

        function self = test2dEllipsoidAndHyperplane(self)
            hyp1 = hyperplane([1; 1], 3);
            ell1 = ellipsoid([100 50; 50 200]);
            hold on;
            plObj = plot(ell1, 'r');
            plot(hyp1, 'b');
            legend('show');
            SProps = plObj.getPlotStructure();
            SFigure = SProps.figHMap.toStruct();
            hFigure = SFigure.figure_g1;
            childVec = hFigure.Children;
            mlunitext.assert_equals(length(childVec), 2);
            hAxes = childVec(2);
            hLegend = childVec(1);
            graphicalObjectsVec = hAxes.Children;
            mlunitext.assert_equals(length(graphicalObjectsVec), 3);
            center = graphicalObjectsVec(2);
            ell = graphicalObjectsVec(3);
            hyp = graphicalObjectsVec(1);
            mlunitext.assert_equals(ell.FaceColor, 'none');
            mlunitext.assert_equals(hyp.FaceColor, 'none');
            mlunitext.assert_equals(...
                center.Annotation.LegendInformation.IconDisplayStyle, 'off');
            mlunitext.assert_equals(...
                ell.Annotation.LegendInformation.IconDisplayStyle, 'on');
            mlunitext.assert_equals(...
                hyp.Annotation.LegendInformation.IconDisplayStyle, 'on');
            str1 = hLegend.String{1};
            str2 = hLegend.String{2};
            mlunitext.assert_equals(str1, '1');
            mlunitext.assert_equals(str2, '2');
        end
    end
end
