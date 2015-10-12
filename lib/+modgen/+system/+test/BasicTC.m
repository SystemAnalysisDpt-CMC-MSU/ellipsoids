classdef BasicTC < mlunitext.test_case
    methods
        function self = BasicTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function testHostName(~)
            nArgoutVec=[1,2];
            for nArgout=nArgoutVec
                outList=cell(1,nArgout);
                lastwarn('');
                [outList{:}]=modgen.system.getuserhost(); %#ok<NASGU>
                lastWarn=lastwarn();
                mlunitext.assert(isempty(lastWarn),lastWarn);
            end
        end
        function testPidHost(~)
            nArgoutVec=[1,2,3];
            for nArgout=nArgoutVec
                outList=cell(1,nArgout);
                lastwarn('');
                [outList{:}]=modgen.system.getpidhost(); %#ok<NASGU>
                lastWarn=lastwarn();
                mlunitext.assert(isempty(lastWarn),lastWarn);
            end
        end        
    end
end