ellProjObj = gras.ellapx.smartdb.test.examples.getProj();
%
% get a copy of the object
%
ellCopy = ellProjObj.getCopy();
%
% delete all the data from the object
%
ellProjObj.clearData();
ellProjObj = gras.ellapx.smartdb.test.examples.getProj();
%
% create a copy of a specified object via calling a copy constructor for 
% the object class
%
cloneObj = ellProjObj.clone();
%
% remove all duplicate tuples from the relation
%
noDuplicate = cloneObj.removeDuplicateTuples();
%
% write a content of relation into Excel spreadsheet file
%
ellProjObj.writeToCSV('path');
%
% write a content of relation into Excel spreadsheet file
%
fileName = ellProjObj.writeToXLS('path');
%
% display a content of the given relation as a data grid UI component
%
ellProjObj.dispOnUI();
%
% put some textual information about object in screen
%
ellProjObj.display();
