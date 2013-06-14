classdef mlunit_test_xmlloadsave < mlunitext.test_case
    
    properties
        locDir
        fileName
        simpleData
        simpleMetaData
        xmlsaveParams
        resTmpDir
    end
    %
    methods
        function self = tear_down(self)
            rmdir(self.resTmpDir,'s');
        end
        function self = mlunit_test_xmlloadsave(varargin)
            self = self@mlunitext.test_case(varargin{:});
            metaClass=metaclass(self);
            self.locDir=fileparts(which(metaClass.Name));            
        end
        function self=set_up_param(self,varargin)
            self.resTmpDir=modgen.test.TmpDataManager.getDirByCallerKey();
            self.fileName=[self.resTmpDir,filesep,'tmp.xml'];
            Data.a=[1 2 3];
            Data.b=[1 2 3].';
            Data.c='sdfasdfa';
            Data.d='sdfasdfa'.';
            self.simpleData=Data;
            self.simpleMetaData=struct('version','0.1','someparam',...
                'abra-kadabra');
            self.xmlsaveParams=varargin;
        end
        function testTrickySize(self)
            Data.alpha={'alpha'.'};
            check();
            Data.theta.gamma={'alpha'.'};
            Data.beta=repmat('c',20,30);
            Data.vega=zeros(2,3,4);
            check();
            function check()
                reg=modgen.common.parseparams(self.xmlsaveParams);
                ResData=xmlparse(xmlformat(Data,reg{:}));
                mlunitext.assert_equals(true,isequal(Data,ResData));
            end
        end
        
        function testEmpty(~)
            expVar=struct('alpha',zeros(1,0));
            check();
            expVar=zeros(1,0);
            check();
            function check()
                resVar=xmlparse(xmlformat(expVar));
                mlunitext.assert_equals(true,isequal(resVar,expVar));
            end
        end
        function self=testMultidimStructField(self)
            SData.alpha(2,3).a=1;
            SRes=xmlparse(xmlformat(SData,'on'));
            mlunitext.assert_equals(isequalwithequalnans(SRes,SData),true);
        end
        function self = testInteger(self)
            SData.a=int32([1,2,3]);
            SData.b=int64([1,2,3]);
            SData.c=uint64([1,2,3;2 3 3]);
            SData.d=uint32([1,2,3;4 2 4]);
            SData.a1=uint32([]);
            SData.b1=uint64([]);
            SData.c1=int64([]);
            SData.d1=int32([]);
            SData.test=SData;
            %
            self.xmlsave(self.fileName,SData);
            SRes=xmlload(self.fileName);
            mlunitext.assert_equals(isequalwithequalnans(SRes,SData),true);
        end
        function testNegative(self)
            checkN(handle([1,2]));
            checkN(complex([1,2],[1,2]));
            checkN(complex(int32([1,2]),int32([1,2])));
            checkN(sparse([1,2]));
            %
            function checkN(inpArray)
                SData.alpha=inpArray;
                self.runAndCheckError('self.xmlsave(self.fileName,SData);',...
                    ':wrongInput');
            end
        end
        function xmlsave(self,filePath,data,varargin)
            [reg1,prop1]=modgen.common.parseparams(varargin,{'insertTimestamp'});
            [reg2,prop2]=modgen.common.parseparams(self.xmlsaveParams);
            nReg1=numel(reg1);
            nReg2=numel(reg2);
            if nReg1<nReg2
                reg=[reg1,reg2(nReg1+1:end)];
            else
                reg=reg1;
            end
            xmlsave(filePath,data,reg{:},prop1{:},prop2{:});
        end
        function self = test_complexstructure(self)
            Data(1)=modgen.common.genteststruct(1);
            Data(2)=modgen.common.genteststruct(2);
            self.xmlsave(self.fileName,Data);
            SRes=xmlload(self.fileName);
            mlunitext.assert_equals(isequalwithequalnans(SRes,Data),true);
            delete(self.fileName);
            %
            Data=modgen.common.genteststruct(1);
            self.xmlsave(self.fileName,Data);
            SRes=xmlload(self.fileName);
            mlunitext.assert_equals(isequalwithequalnans(SRes,Data),true);
            delete(self.fileName);
        end
        function self = test_complexstructure_backwardcompatibility(self)
            file1ElemName=[self.locDir,filesep,'test_complexstructure_1elem.xml'];
            file1ElemTmpName=[self.locDir,filesep,'test_complexstructure_1elem_tmp.xml'];
            fileArrayName=[self.locDir,filesep,'test_complexstructure_array.xml'];
            fileArrayTmpName=[self.locDir,filesep,'test_complexstructure_array_tmp.xml'];
            %
            SRes=xmlload(file1ElemName);
            self.xmlsave(file1ElemTmpName,SRes);
            SResTmp=xmlload(file1ElemTmpName);
            mlunitext.assert_equals(isequalwithequalnans(SRes,SResTmp),true);
            delete(file1ElemTmpName);
            %
            SRes=xmlload(fileArrayName);
            self.xmlsave(fileArrayTmpName,SRes);
            SResTmp=xmlload(fileArrayTmpName);
            mlunitext.assert_equals(isequalwithequalnans(SRes,SResTmp),true);
            delete(fileArrayTmpName);
        end
        function self = test_simple(self)
            self.xmlsave(self.fileName,self.simpleData);
            SRes=xmlload(self.fileName);
            mlunitext.assert_equals(isequalwithequalnans(SRes,...
                self.simpleData),true)
            delete(self.fileName);
        end
        function self=test_simple_metadata(self)
            self.xmlsave(self.fileName,self.simpleData,'on',self.simpleMetaData);
            [SRes,SMetaData]=xmlload(self.fileName);
            mlunitext.assert_equals(isequalwithequalnans(SRes,...
                self.simpleData),true)
            mlunitext.assert_equals(SMetaData,...
                self.simpleMetaData,true)
        end
        function self=test_simple_metadata_negative(self)
            try
                metaData=self.simpleMetaData;
                metaData.badParam=zeros(1,3);
                self.xmlsave(self.fileName,self.simpleData,'on',metaData);
                mlunitext.assert_equals(true,false);
            catch meObj
                mlunitext.assert_equals(~isempty(strfind(meObj.identifier,...
                    ':wrongInput')),true);
            end
        end
        function self = test_parseFormatEmptyStruct(self)
            mlunitext.assert_equals(true,isequal(....
                struct(),...
                xmlparse(xmlformat(struct()),'on')));
            mlunitext.assert_equals(true,isequal(....
                struct([]),...
                xmlparse(xmlformat(struct([])),'on')));
        end
    end
end