nTubes=5;
nPoints = 100;
timeBeg=0;
timeEnd=1;
type = 2;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
%
% get a copy of the object
%
ellCopy = ellTubeObj.getCopy();
%
% delete all the data from the object
%
ellTubeObj.clearData();
ellTubeObj =...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
%
% create a copy of a specified object via calling a copy constructor for 
% the object class
%
cloneObj = ellTubeObj.clone();
%
% remove all duplicate tuples from the relation
%
noDuplicate = cloneObj.removeDuplicateTuples();
%
% write a content of relation into Excel spreadsheet file
%
ellTubeObj.writeToCSV('path');
%
% write a content of relation into Excel spreadsheet file
%
fileName = ellTubeObj.writeToXLS('path');
%
% display a content of the given relation as a data grid UI component
%
ellTubeObj.dispOnUI();
%
% put some textual information about object in screen
%
ellTubeObj.display();
