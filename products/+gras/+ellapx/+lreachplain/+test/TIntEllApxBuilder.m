classdef TIntEllApxBuilder < gras.ellapx.lreachplain.IntEllApxBuilder & ...
    gras.ellapx.lreachplain.test.TATightIntEllApxBuilder
    %TINTELLAPXBUILDER Subclass to check Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods
        function self = TIntEllApxBuilder(varargin)
            self=self@gras.ellapx.lreachplain.test.TATightIntEllApxBuilder(...
                varargin{:});
            bigX0SqrtMat=gras.la.sqrtmpos(self.getProblemDef().getX0Mat);
            self.bigS0X0SqrtMat=bigX0SqrtMat;
            pDefObj=self.getProblemDef();
            sysDim=pDefObj.getDimensionality();
            pTimeLimsVec=pDefObj.getTimeLimsVec();
            startTime=pTimeLimsVec(1);
            s0Mat=eye(sysDim);
            goodDirCurveSpline=self.getGoodDirSet().getGoodDirCurveSpline();
            self.l0Mat=s0Mat*bigX0SqrtMat*goodDirCurveSpline.evaluate(...
                startTime);
        end
    end
end

