function [errorCount,failCount,messageStr]=countfailsinresults(results)
nRes=length(results);
errorCount=0;
failCount=0;
messageStr='';
for iRes=1:nRes
    errorCount=errorCount+results(iRes).get_errors();
    failCount=failCount+results(iRes).get_failures();
    messageStr=[messageStr,evalc('results(iRes).print_errors()')];
end