classdef AxesLabelsTC < mlunitext.test_case
    %
    %$Author: Timofey Shalimov <ssstiss@gmail.com> $
    %$Date: 2017-14-12 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2017 $
    methods
        function self = tear_down(self)
            close all;
        end

        function self = AxesLabelsTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = testAxesNames(self)
            ell1 = ellipsoid(eye(2));
            plObj = plot(ell1);
            SProps = plObj.getPlotStructure();
            SFigure = SProps.figHMap.toStruct();
            hFigure = SFigure.figure_g1;
            children = hFigure.Children;
            mlunitext.assert_equals(children.XLabel.String, 'x_1');
            mlunitext.assert_equals(children.YLabel.String, 'x_2');
            mlunitext.assert_equals(children.ZLabel.String, 'x_3');
        end
        
        function self = testAxesNamesHold(self)
            hold on;
            ell1 = ellipsoid(eye(2));
            ell2 = hyperplane([1, 2; 3, 4]);
            plot(ell1);
            plObj = plot(ell2);
            SProps = plObj.getPlotStructure();
            SFigure = SProps.figHMap.toStruct();
            hFigure = SFigure.figure_g1;
            children = hFigure.Children;
            mlunitext.assert_equals(children.XLabel.String, 'x_1');
            mlunitext.assert_equals(children.YLabel.String, 'x_2');
            mlunitext.assert_equals(children.ZLabel.String, 'x_3');
        end
    end
end