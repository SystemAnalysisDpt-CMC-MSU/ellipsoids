function urlStr=gitgeturl(WorkingCopy)
urlStrList=modgen.scm.git.gitcall('ls-remote --get-url',WorkingCopy);
urlStr=[urlStrList{:}];
urlStr=strtrim(urlStr);