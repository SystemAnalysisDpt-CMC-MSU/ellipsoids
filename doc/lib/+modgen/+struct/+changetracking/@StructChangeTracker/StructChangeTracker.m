classdef StructChangeTracker<modgen.struct.changetracking.AStructChangeTracker
    % STRUCTCHANGETRACKER keeps a list of structure patches and provide
    % tools for applying them to any arbitrary structure. Patches can be
    % defined either as static or plain class methods 
    % A method must 
    %   1) have 'patch_' prefix and '_#' suffix 
    %   2) be public
    % to be recognized as patch
    %
    % A typical usage scenario is inheriting from the given class and define
    % patch methods
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-11 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    %
    methods
        function self=StructChangeTracker()
            % STRUCTCHANGETRACKER - constructor accepts no parameters
        end
        function [SInput,lastVersion]=applyAllLaterPatches(self,SInput,startRev)
            lastVersion=self.getLastRevision();
            if isnan(startRev)
                startRev=-Inf;
            end
            %
            if lastVersion>startRev
                SInput=self.applyPatches(SInput,startRev,...
                    lastVersion,[false true]);
            elseif lastVersion<startRev
                error([upper(mfilename),':badRepoState'],['inconsistent '...
                    'state of structure repository: latest patch version',...
                    ' is %d, version of current structure is %d'],...
                    lastVersion,startRev);
            end         
        end
        function lastRevNum=getLastRevision(self)
            % GETLASTREVISION - see the parent class for documentation on
            %                   this mehtod
            [~,revNumVec]=self.findPatchFuncList(-Inf,+Inf,[true true]);
            if isempty(revNumVec)
                lastRevNum=nan;
            else
                lastRevNum=max(revNumVec);
            end
                
        end  
        function SInput=applyPatches(self,SInput,startRev,endRev,isInclusiveVec)
            % APPLYPATCHES - see the parent class for documentation on this
            %                method
            if nargin<5
                isInclusiveVec=[true true];
            end
            %
            funcHandleList=self.findPatchFuncList(startRev,endRev,isInclusiveVec);
            nFunc=length(funcHandleList);
            for iFunc=1:nFunc
                SInput=feval(funcHandleList{iFunc},SInput);
            end
        end        
    end
    methods(Access=private)
        function [funcHandleList,revNumVec]=findPatchFuncList(self,startRev,endRev,isInclusiveVec)
            % FINDPATCHFUNCLIST - returns a list of transformation functions
            %                     patch functions) corresponding to the 
            %                     iven revision number range
            % 
            %
            % Input:
            %   regular: 
            %       self: the object itself
            %       startRev: numeric[1,1] - see applyPatches method 
            %           description
            %       endRev: numeric[1,1] - see applyPatches method 
            %           description
            %       isInclusiveVec: logical[1,2] see applyPatches method 
            %           description
            %   
            % Output:
            %   funcHandleList: cell[1,nPatches] - a list of patch functions
            %   revNumVec: double[1,nPatches] - a vector of revision numbers
            %      corresponding to the patch functions
            %      

           
            if ~islogical(isInclusiveVec)
                error([upper(mfilename),':wrongInput'],...
                    'isInlcusiveVec is expected to have logical type');
            end
            if length(isInclusiveVec)~=2
                error([upper(mfilename),':wrongInput'],...
                    'isInlcusiveVec is expected to be a vector with 2 elements');
            end
            metaClass=metaclass(self);
            methodList=metaClass.Methods();
            %isPatchVec=cellfun(@(x,y)(x.Static),methodList);
            isPatchVec=true(size(methodList));
            if any(isPatchVec)
                %
                methodList=methodList(isPatchVec);
                funcNameList=cellfun(@(x)x.Name,methodList,'UniformOutput',false);
                %
                [SResList]=regexp(funcNameList,'^patch_(?<patchver>\d*)','names');
                nMatchesVec=cellfun('length',SResList);
                if any(nMatchesVec>1)
                    error([upper(mfilename),':badState'],...
                        'Oops, we shouldn''t be here, regular expression is incorrect');
                end
                %
                isNumOkVec=~cellfun('isempty',SResList);
                okRevNumVec=cellfun(@(x)str2double(x.patchver),SResList(isNumOkVec));
                %
                if isInclusiveVec(1)
                    isNumOkSubLeftVec=(okRevNumVec>=startRev);
                else
                    isNumOkSubLeftVec=(okRevNumVec>startRev);
                end
                %
                if isInclusiveVec(2)
                    isNumOkSubRightVec=(okRevNumVec<=endRev);
                else
                    isNumOkSubRightVec=(okRevNumVec<endRev);
                end
                %
                isNumOkSubVec=isNumOkSubLeftVec&isNumOkSubRightVec;
                isNumOkVec(isNumOkVec)=isNumOkSubVec;
                %
                okRevNumVec=okRevNumVec(isNumOkSubVec);
                %
                funcHandleList=cellfun(@(x)eval(['@(y)self.',x,'(y)']),funcNameList(isNumOkVec),'UniformOutput',false);
                %sort the patch names by the patch number
                [revNumVec,ind]=sort(okRevNumVec);
                funcHandleList=funcHandleList(ind);
                %
            else
                funcHandleList={};
            end
        end
    end
    
end