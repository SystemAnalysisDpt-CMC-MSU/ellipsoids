ellUnionObj = gras.ellapx.smartdb.test.examples.getUnion();
%
% get a copy of the object
%
ellCopy = ellUnionObj.getCopy();
%
% delete all the data from the object
%
ellUnionObj.clearData();
ellUnionObj = gras.ellapx.smartdb.test.examples.getUnion();
%
% create a copy of a specified object via calling a copy constructor for 
% the object class
%
cloneObj = ellUnionObj.clone();
%
% remove all duplicate tuples from the relation
%
noDuplicate = cloneObj.removeDuplicateTuples();
%
% write a content of relation into Excel spreadsheet file
%
ellUnionObj.writeToCSV('path');
%
% write a content of relation into Excel spreadsheet file
%
fileName = ellUnionObj.writeToXLS('path');
%
% display a content of the given relation as a data grid UI component
%
ellUnionObj.dispOnUI();
%
% put some textual information about object in screen
%
ellUnionObj.display();
