classdef THyperplane < hyperplane & gras.test.mlunit.TolCounter
    %THYPERPLANE Subclass to count Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods (Access = protected)
        function beforeGetAbsTol(self)
            beforeGetAbsTol@hyperplane(self);
            self.incAbsTolCount();
        end
        function beforeGetRelTol(self)
            beforeGetRelTol@hyperplane(self);
            self.incRelTolCount();
        end
    end
    %
    methods (Static)
        function hpArr = fromRepMat(varargin)
            import modgen.common.checkvar;
            if nargin>3
                indVec=[1:2,4:nargin];
                sizeVec=varargin{3};
            else
                sizeVec=varargin{nargin};
                indVec=1:nargin-1;
            end
            hpArr = repMat(elltool.core.test.mlunit.THyperplane(...
                varargin{indVec}),sizeVec);
        end
        function hpArr = fromStruct(SHpArr)
            function hpObj = struct2Hp(SHp)
                if (isfield(SHp, 'absTol'))
                    SProp = rmfield(SHp, {'normal', 'shift'});
                    propNameValueCMat = [fieldnames(SProp), struct2cell(SProp)].';
                    hpObj = elltool.core.test.mlunit.THyperplane(...
                        SHp.normal, SHp.shift, propNameValueCMat{:});
                else
                    hpObj = elltool.core.test.mlunit.THyperplane(...
                        SHp.normal, SHp.shift);
                end
            end
            
            for iHp = numel(SHpArr) : -1 : 1
                hpArr(iHp) = struct2Hp(SHpArr(iHp));
            end
            hpArr = reshape(hpArr, size(SHpArr));
        end
    end
    %
    methods
        function varargout = toStruct(hpArr, varargin)
            varargout = cell(1, nargout);
            if nargin == 3
                %hpArr.startTolTest();
                [varargout{:}] = toStruct@hyperplane(hpArr, varargin{:});
                %hpArr.finishTolTest();
            else
                [varargout{:}] = toStruct@hyperplane(hpArr, varargin{:});
            end
        end
    end
    %
    methods
        function self = THyperplane(varargin)
            self = self@gras.test.mlunit.TolCounter();
            self = self@hyperplane(varargin{:});
        end
    end
end

