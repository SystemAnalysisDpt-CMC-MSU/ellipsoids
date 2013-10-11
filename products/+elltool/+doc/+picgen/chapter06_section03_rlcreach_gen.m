function chapter06_section03_rlcreach_gen
%     RLCREACH_GEN - creates picture "chapter06_section03_rlcreach.eps" in
%     doc/pic   
% $Author: <Elena Shcherbakova>  <shcherbakova415@gmail.com> $    $Date: <9 October 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
    close all
    elltool.doc.snip.s_chapter06_section03_snippet01;
    elltool.doc.snip.s_chapter06_section03_snippet02;
    figHandle = findobj('Type','figure');
    combinedFig = figure;
    
    leftupAxes = subplot(2,2,1);
    axis([0 3 -1 1 -0.2 0.2]);
    grid on
    set(leftupAxes, 'XLimMode', 'auto', 'YLimMode', 'auto',...
        'ZLimMode', 'auto');
    xlabel('t');
    ylabel('x1');
    zlabel('x2');
    title('(a)');
    for iElem = 9:12
    movedContent = get(findobj(figHandle(iElem),'Type','axes'), 'Children');
    copyobj(movedContent, leftupAxes);
    end
    
    rightupAxes = subplot(2,2,2);
    axis([-1 1 -0.2 0.2 -0.4 0.4]);
    grid on
    set(rightupAxes, 'XLimMode', 'auto', 'YLimMode', 'auto',...
        'ZLimMode', 'auto');
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('(b)');
    for iElem = 7:8
    movedContent = get(findobj(figHandle(iElem),'Type','axes'), 'Children');
    copyobj(movedContent, rightupAxes);
    end
    
    leftdownAxes = subplot(2,2,3);
    axis([-2 3 -2 2 -0.4 0.4]);
    grid on
    set(leftdownAxes, 'XLimMode', 'auto', 'YLimMode', 'auto',...
        'ZLimMode', 'auto');
    xlabel('t');
    ylabel('x1');
    zlabel('x2');
    title('(c)');
    for iElem = 3:6
    movedContent = get(findobj(figHandle(iElem),'Type','axes'), 'Children');
    copyobj(movedContent, leftdownAxes);
    end
    
    rightdownAxes = subplot(2,2,4);
    axis([-1.5 1.5 -0.4 0.4 -1.5 1.5]);
    grid on
    set(rightdownAxes, 'XLimMode', 'auto', 'YLimMode', 'auto',...
        'ZLimMode', 'auto');
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('(d)');
    for iElem = 1:2
    movedContent = get(findobj(figHandle(iElem),'Type','axes'), 'Children');
    copyobj(movedContent, rightdownAxes);
    end
    
    elltool.doc.picgen.PicGenController.savePicFileNameByCaller(combinedFig, 0.6, 0.6);

end