
function f_plotmeanSD(ROI,xMeassure,yMeassure,condition1,condition2,data1,data2,x_axis,color, y_axis, dash_line)

% ROI is going to be the name of the channel or scout to include in the
% title (string)
% Meassure is the label for the y-axes (string)
% condition1 is the label for the first condition (string)
% condition2 is the label for the second condition (string)
% data1 is the data for condition 1
% data2 is the data for condition 2
% x_axis is the vector that contains the values for the x-axis
% y_axis = [-100 100];%[min(min([c1;c2]))-0.2, max(max([c1;c2]))+0.2];        % define y_axis limits
% view      % pvalue or fdr

%% Input params
display_fig = 'on';   % 'on' or 'off'
savefig = 0;           % binario 1 = guardar, 0 = no guardar
% t = 2;                 % COMPARE FREQS (1) OR TASKS (2)
error = 'SD';         % define error
x1 = 0; % events line plots in seconds

% view      % pvalue or fdr

%----------------------------------------------------------------------
Title_roi = ROI;

%% Load data
% grupo = [condition1 ' and ' condition2 ' - Mean ' freq ' Z-score - SEM - ROI ' roi ];
grupo = Title_roi;


c1 = data1; % Vector de Condicion 1
c2 = data2; %Vector de Condicion 2


%% Plot configuration

Xt = x_axis;%EjeX; % Time o EjeX

figure1 = grupo;
figure%('visible',display_fig,'position', [0, 0, 1000, 500]); hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = shadedErrorBar(Xt,c1,{@mean,@std}, 'lineprops',color);hold on;
p2 = shadedErrorBar(Xt,c2,{@mean,@std}, 'lineprops', '-k');hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel([xMeassure],'FontSize',12,'FontWeight','bold')
ylabel([yMeassure],'FontSize',12,'FontWeight','bold')
%%%%%%%%%%%%%%%%%%%%%%%%%% AXIS SCALE %%%%
ylim([y_axis(1) y_axis(2)])
xlim ([x_axis(1) x_axis(end)])

title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
h = title(figure1,'Fontsize',12,'FontWeight','bold','interpreter', 'none');
P = get(h,'Position');
%set(h,'Position',[P(1) P(2)+0.1 P(3)])

ax = gca; % current axes
ax.XTickMode = 'manual';
ax.TickDirMode = 'manual';
ax.TickDir = 'in';
ax.XColor = 'black';
ax.YColor = 'black';
set(gca,'LineWidth',1,'Fontsize',10,'clipping', 'on')

if dash_line ==1
    linea = ones(size(x_axis));
    hold on; line('XData',x_axis,'YData',linea, 'LineStyle','--', 'LineWidth', 1);
elseif dash_line == 0
    linea = zeros(size(x_axis));
    hold on; line('XData',x_axis,'YData',linea, 'LineStyle','--', 'LineWidth', 1);
end


hold on;
box on;

legend({condition1,condition2});
allChildren = get(gca, 'Children');                % list of all objects on axes
displayNames = get(allChildren, 'DisplayName');    % list of all legend display names
% Remove object associated with "data1" in legend
delete(allChildren(strcmp(displayNames, 'data1')))
%saveas(fig,char(strcat(ROIp,'.png')));