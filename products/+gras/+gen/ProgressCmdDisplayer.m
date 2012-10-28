classdef ProgressCmdDisplayer<handle
    properties (Access=private)
        tStart
        tEnd
        nDotsShown
        nDots
        nInvDots
        invLengthPerDot
        tCur
        prefixStr
    end
    methods
        function self=ProgressCmdDisplayer(tStart,tEnd,nDots,prefixStr)
            import modgen.common.throwerror;
            self.tStart=tStart;
            self.tEnd=tEnd;
            self.nDots=nDots;
            self.nDotsShown=0;
            if tEnd<tStart
                throwerror('wrongInput','it is expected that tEnd > tStart');
            end
            spanLength=(tEnd-tStart);
            self.invLengthPerDot=nDots/spanLength;
            self.tCur=tStart;
            if nargin<4
                prefixStr='';
            else
                prefixStr=[prefixStr,':'];
            end
            self.prefixStr=prefixStr;
        end
        function start(self)
            fprintf([self.prefixStr,'[',repmat(' ',1,self.nDots),']']);
        end
        function progress(self,t)
            import modgen.common.throwerror;
            if t<self.tCur
                throwerror('wrongInput','t is expected to be increasing');  
            end
            iCurDot=fix((t-self.tStart)*self.invLengthPerDot);
            if iCurDot>self.nDotsShown
                nToRemove=1+(self.nDots-self.nDotsShown);
                strToPrint=[repmat(sprintf('\b'),1,nToRemove),...
                repmat('.',1,iCurDot-self.nDotsShown),...
                repmat(' ',1,self.nDots-iCurDot),']'];
                fprintf(strToPrint);
                self.nDotsShown=iCurDot;
                self.tCur=t;
            end
        end
        function finish(self)
            nToRemove=1+(self.nDots-self.nDotsShown);
            strToPrint=[repmat(sprintf('\b'),1,nToRemove),...
                repmat('.',1,self.nDots-self.nDotsShown),']\n'];
            fprintf(strToPrint);
        end
    end
end