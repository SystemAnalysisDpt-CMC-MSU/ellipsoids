function chapter06_section02_reachmech_gen
%     REACHMECH_GEN - creates picture "chapter05_section03_reachmech.eps" in
%     doc/pic   
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <9 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter06_section02_snippet01;
    elltool.doc.snip.s_chapter06_section02_snippet02;
    figHandle = findobj('Type','figure');
    combinedFig = figure;
    
    leftupAxes = subplot(2,2,1);
    axis([0 4 -3 2 -2 3]);
    grid on
    set(leftupAxes, 'XLimMode', 'auto', 'YLimMode', 'auto',...
        'ZLimMode', 'auto');
    xlabel('t');
    ylabel('x1');
    zlabel('x2');
    title('(a)');
    movedContent = get(findobj(figHandle(4),'Type','axes'), 'Children');
    copyobj(movedContent, leftupAxes);
    
    movedContent = findobj(figHandle(3),'Type','axes');
    rightupAxes = copyobj(movedContent, combinedFig);
    title(rightupAxes, '(b)');
    set(rightupAxes,  'Position', [ 0.5703    0.5838    0.3347    0.3412]);
     
    leftdownAxes = subplot(2,2,3);
    axis([0 4 -3 2 -3 3]);
    grid on
    set(leftdownAxes, 'XLimMode', 'auto', 'YLimMode', 'auto',...
        'ZLimMode', 'auto');
    xlabel('t');
    ylabel('x1');
    zlabel('x2');
    title('(c)');
    movedContent = get(findobj(figHandle(2),'Type','axes'), 'Children');
    copyobj(movedContent, leftdownAxes);
    
    movedContent = findobj(figHandle(1),'Type','axes');
    rightdownAxes = copyobj(movedContent, combinedFig);
    title(rightdownAxes, '(d)');
    set(rightdownAxes,  'Position', [0.5703    0.1100    0.3347    0.3412]);
    
    
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(combinedFig, 0.6, 0.6);

end