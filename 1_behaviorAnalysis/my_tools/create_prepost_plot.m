function graph = create_prepost_plot (pattern, data1, data2)
% quick and dirty function to plot interaction

% PRE
mean_pre = structfun(@nanmean,  data1);
mean_pre = mean_pre(1:2);
std_pre  = structfun(@(x) nanstd(x)/sqrt(length(x)), data1);
std_pre  = std_pre(1:2);

color.means.val  = [0.5 0.8 0.1];

%  [0.3 0.7 0.9]; %this is blue

% [0.8 0.5 0.1] %this is orange

% POST
mean_post = structfun(@nanmean,  data2);
mean_post = mean_post (1:2);
std_post = structfun(@(x) nanstd(x)/sqrt(length(x)), data2);
std_post = std_post (1:2);


color.means.deval =  [0.2 0.2 0.2];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot bars

graph = figure;
hold on;

b = bar([mean_pre(1), mean_pre(2); mean_post(1), mean_post(2)],0.95);
b(1).FaceColor = color.means.val;
b(2).FaceColor = color.means.deval;


% plot errorbars
model_series = [mean_pre(1), mean_pre(2); mean_post(1), mean_post(2)];
model_error =  [std_pre(1), std_pre(2); std_post(1), std_post(2)];

numgroups = 2; 
numbars = 2; 

groupwidth = min(0.8, numbars/(numbars+1.5));

for i = 1:numbars

      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, model_series(:,i), model_error(:,i), 'k', 'linestyle', 'none','LineWidth', 1);

end


LEG = legend('Valued','Devalued');
set(LEG,'FontSize',12); %
set(LEG,'Box', 'off');
set(LEG, 'Position', [0.850 0.500 0.150 0.100])

% y label
ylabel(pattern, 'FontSize',18,'FontWeight','bold');
y = get(gca,'YLabel');
set(y, 'Units', 'Normalized', 'Position', [-0.08, 0.5, 0])

set(gcf, 'Position', [300 500 600 600])
set(gcf, 'Color', 'w')

% x label
set(gca, 'XTickLabel', '')
ypos = min(ylim)-0.005;
labelx = {'PRE','POST'};
text([0.85  1.85],repmat(ypos,length(mean_pre),1), ...
    labelx,'verticalalignment','cap','FontSize',24)

end