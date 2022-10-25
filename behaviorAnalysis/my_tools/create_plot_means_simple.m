function graph = create_plot_means_simple (pattern, data1)


means = structfun(@nanmean,  data1);
sems = structfun(@(x) nanstd(x)/sqrt(length(x)), data1);


color.means.day1 = [0.8 0.8 0.8];
color.edge.day1 = [0.8 0.8 0.8];

color.means.day3 = [0.2 0.2 0.2];
color.edge.day3 = [0.2 0.2 0.2];


graph = figure;

y = means ((1:length(means)));
bars = sems (1:length(sems));

hold on

names = {'day1', 'day3'};

for i = 1:length(names)
    
    name = char(names(i));
    
    bar(i,y(i), 0.5, 'faceColor', color.means.(name), 'EdgeColor', color.edge.(name), 'LineWidth', 1);
end

errorbar(1:length(sems),y,bars,'.k', 'LineWidth', 1);
set(gca, 'XTickLabel', '')
ylabel(pattern,'FontSize',24)
ypos = min(ylim)-0.005;


labelx = {names{1},names{2}};
text([0.85  1.85],repmat(ypos,length(means),1), ...
    labelx,'verticalalignment','cap','FontSize',24)


set(gcf, 'Position', [50 100 300 600])
set(gcf, 'Color', 'w')
box off
