function chapter06_section08_forward2
close all
elltool.doc.snip.s_chapter06_section08_snippet03;
elltool.doc.snip.s_chapter06_section08_snippet02;
hFigHandle = findobj('Type','figure');
figRegExpList = {'[a-zA-Z_0-9:;,\]\[\s]*_forward_reach_set_proj\w*'};

elltool.doc.picgen.PicGenController.savePicFileNameByCaller(...
    hFigHandle, 1, 1, 1, 1, 'figRegExpList', figRegExpList);
end
