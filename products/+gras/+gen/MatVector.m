classdef MatVector
    %MATVECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        function dataArray=triu(dataArray)
            for iElem=1:size(dataArray,3)
                dataArray(:,:,iElem)=triu(dataArray(:,:,iElem));
            end
        end
        function resDataArray=makeSymmetric(dataArray)
            import gras.gen.MatVector;
            resDataArray=0.5*(dataArray+MatVector.transpose(dataArray));
        end
        %
        function invDataArray=pinv(dataArray)
            Xsize=size(dataArray);
            if length(Xsize)==2
                Xsize(3)=1;
            end
            invDataArray=zeros(Xsize([2 1 3]));
            for t=1:1:Xsize(3)
                invDataArray(:,:,t)=pinv(dataArray(:,:,t));
            end
        end
        %
        function outTransArray=transpose(inpArray)
            Asize=size(inpArray);
            if length(Asize)==2
                Asize(3)=1;
            end
            outTransArray=zeros([Asize(2) Asize(1) Asize(3)]);
            for t=1:1:Asize(3)
                outTransArray(:,:,t)=inpArray(:,:,t).';
            end
        end
        function Y=fromFormulaMat(X,t)
            import gras.gen.MatVector;
            expStr=modgen.cell.cellstr2expression(X);
            Y=MatVector.fromExpression(expStr,t);
        end
        %
        function Y=fromFunc(fHandle,t)
            if numel(t)==1
                Y=fHandle(t);
            else
                t=shiftdim(t,-1);
                Y=fHandle(t);
                nTimePoints=numel(t);
                if size(Y,3)==1&&nTimePoints>1
                    Y=repmat(Y,[1,1,nTimePoints]);
                end
            end
        end         
        %
        function Y=fromExpression(expStr,t)
            if numel(t)==1
                Y=eval(expStr);
            else
                t=shiftdim(t,-1);
                Y=eval(expStr);
                nTimePoints=numel(t);
                if size(Y,3)==1&&nTimePoints>1
                    Y=repmat(Y,[1,1,nTimePoints]);
                end
            end
        end        
        %
        function Bpt_data=rMultiplyByVec(Bt_data,pt_data)
            import modgen.common.throwerror;
            if ndims(pt_data)~=2
                throwerror('wrongInput',...
                    'pt_data is expected to be 2-dimensional array');
            end
            psize=size(pt_data);
            bsize=size(Bt_data);
            Bpt_data=zeros([bsize(1) psize(2) ]);
            for t=1:1:psize(2)
                Bpt_data(:,t)=Bt_data(:,:,t)*pt_data(:,t);
            end;
        end
        %
        function Bpt_data=rMultiply(Bt_data,pt_data,qt_data)
            import modgen.common.throwerror;
            psize=[size(pt_data),1];
            bsize=size(Bt_data);
            nElems=size(Bt_data,3);
            nRightElems=size(pt_data,3);
            if (nRightElems>1)&&(nElems~=nRightElems)
                throwerror('wrongInput',...
                    ['number of elements in both matrix vectors ',...
                    'should be the same']);
            end
            switch nargin
                case 2,
                    Bpt_data=zeros([bsize(1) psize(2) nElems]);
                    if nRightElems>1
                        for t=1:1:nElems
                            Bpt_data(:,:,t)=Bt_data(:,:,t)*pt_data(:,:,t);
                        end
                    else
                        for t=1:1:nElems
                            Bpt_data(:,:,t)=Bt_data(:,:,t)*pt_data;
                        end
                    end                        
                case 3,
                    qsize=size(qt_data);
                    Bpt_data=zeros([bsize(1) qsize(2) psize(3)]);
                    for t=1:1:psize(3)
                        Bpt_data(:,:,t)=Bt_data(:,:,t)*...
                            pt_data(:,:,t)*qt_data(:,:,t);
                    end
            end
        end
    end
end
