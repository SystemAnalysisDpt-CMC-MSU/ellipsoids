function urlStr=gitgeturl(WorkingCopy)
urlStr=modgen.git.gitcall('ls-remote --get-url',WorkingCopy);
urlStr=urlStr{:};