function graph = create_plot_means (pattern, data1, xtags)



means = structfun(@nanmean,  data1);
sems = structfun(@(x) nanstd(x)/sqrt(length(x)), data1);


color.means.(xtags{1}) = [0.5 0.8 0.1];
color.edge.(xtags{1}) = [0.5 0.8 0.1];

color.means.(xtags{2}) = [0.2 0.2 0.2];
color.edge.(xtags{2}) = [0.2 0.2 0.2];

color.means.(xtags{3}) = [0.8 0.1 0.1];
color.edge.(xtags{3})  = [.9 .9 .9];


graph = figure;

y = means ((1:length(means)));
bars = sems (1:length(sems));

hold on

for i = 1:length(xtags)
    
    name = char(xtags(i));
    
    bar(i,y(i), 0.5, 'faceColor', color.means.(name), 'EdgeColor', color.edge.(name), 'LineWidth', 1);
end

errorbar(1:length(sems),y,bars,'.k', 'LineWidth', 1);
set(gca, 'XTickLabel', '')
ylabel(pattern,'FontSize',24)
ypos = min(ylim)-0.005;



labelx = {xtags{1},xtags{2},xtags{3}};
text([0.85  1.85  2.9],repmat(ypos,length(means),1), ...
    labelx,'verticalalignment','cap','FontSize',24)


set(gcf, 'Position', [50 100 300 600])
set(gcf, 'Color', 'w')
box off
