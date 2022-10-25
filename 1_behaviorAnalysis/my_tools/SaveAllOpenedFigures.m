function SaveAllOpenedFigures(FolderName)
%function SaveAllOpenedFigures(FolderName)
% save all open figures into jpg files in FolderName
% adapted from https://www.mathworks.com/matlabcentral/answers/182574-save-all-the-plots

% get handles for all open figures:
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
FigList = FigList(end:-1:1);
%create an html file:
fid = fopen(fullfile(FolderName, 'all_figures.html'), 'w');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    %FigName   = get(FigHandle, 'Name');
    %FigName   = get(get(findobj(FigHandle,'type','axe'),'ylabel'),'string'); % by ylabel
    FigName = ['HIS-fig-' sprintf('%02d',iFig)];
    saveas(FigHandle,fullfile(FolderName, [FigName, '.jpg']))
    %write to the html file
    fprintf(fid, '<img src="%s.jpg" height="800">\n', fullfile(FolderName, FigName));
end
fclose(fid);

end
