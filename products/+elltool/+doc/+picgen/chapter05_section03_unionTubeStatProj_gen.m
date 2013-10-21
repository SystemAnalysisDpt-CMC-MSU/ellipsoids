function chapter05_section03_unionTubeStatProj_gen
%     UNIONTUBESTATPROJ_GEN - creates picture "chapter05_section03_unionTubeStatProj.eps" in
%     doc/pic   
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <2 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter05_section03_snippet05;
    hfigHandle = findobj('Type','figure', '-regexp','Name',...
        '[a-zA-Z,\s]*union[a-zA-Z_0-9;,\]\[\s]*=[1;0\],\w*=\w*');
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(hfigHandle, 0.5, 0.6);

end