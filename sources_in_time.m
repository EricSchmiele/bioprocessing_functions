%============================================================================
% Function name.: sources_in_time
% Date..........: August 29, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Shows the reconstructed brain sources along a time period.
%                 It can also show other plots at the same time for deeper
%                 analysis.
%
% Parameters....: 
%                 source......-> source type struct in the fieldtrip format.
%                 sourcespace.-> source model struct in the fieldtrip format.
%                 roi_color...-> triangulated mesh with brain regions of
%                                interest (ROIs), and their colors. It should
%                                have the following fields:
%                                pos...-> ROI positions;
%                                tri...-> ROI triangulation;
%                                color.-> respective ROI coloration.
%                 opt_plot1...-> optional value to be shown in a normal plot.
%                 opt_plot1x..-> optional value for the horizontal axis of
%                                opt_plot_1.
%                                Default: the same as from source.
%                 opt_plot2...-> optional value to be shown in a normal plot.
%                 eeg.........-> eeg type struct in the fieldtrip format.
%                 type1.......-> use the first type of source plot.
%                                Default: 0.
%                 plot_rad....-> uses the calculated rad instead of the power
%                                of the sources for the plot.
%============================================================================

function sources_in_time(source, sourcespace, roi_color, opt_plot1, opt_plot1x, opt_plot2, eeg, type1, plot_rad)

%============================================================================
%% Manage inputs
global use_roi use_opt_1 use_opt_2 use_eeg use_type_1 use_rad;
use_roi = 0;
use_window = 0;
use_opt_1 = 0;
use_opt_x = 0;
use_opt_2 = 0;
use_eeg = 0;
use_type_1 = 0;
use_rad = 0;
if nargin >= 3 && ~isempty(roi_color)
    use_roi = 1;
end
if nargin >= 4 && ~isempty(opt_plot1)
    use_opt_1 = 1;
end
if nargin >= 5 && ~isempty(opt_plot1x)
    use_opt_x = 1;
end
if nargin >= 6 && ~isempty(opt_plot2)
    if isempty(opt_plot1)
        opt_plot1 = opt_plot2;
        use_opt_1 = 1;
    else
        use_opt_2 = 1;
    end
end
if nargin >= 7 && ~isempty(eeg)
    use_eeg = 1;
end
if nargin >= 8 && ~isempty(type1)
    use_type_1 = type1;
end
if nargin >= 9 && ~isempty(plot_rad)
    use_rad = plot_rad;
end
%============================================================================
    %% Set Number of tabs and tab labels
    NumberOfTabs = 2;
    TabLabels = {'Source'; 'EEG'};
    if size(TabLabels, 1) ~= NumberOfTabs % Make sure the number of tab labels match the NumberOfTabs setting
        errordlg('Number of tabs and tab labels must be the same', 'Setup Error');
        return
    end
    %========================================================================
    %% Get user screen size
    SC = get(0, 'ScreenSize');
    MaxMonitorX = SC(3);
    MaxMonitorY = SC(4);
    %========================================================================
    %% Set the figure window size values
    MainFigScale = .9; % Change this value to adjust the figure size
    MaxWindowX = round(MaxMonitorX*MainFigScale);
    MaxWindowY = round(MaxMonitorY*MainFigScale);
    XBorder = (MaxMonitorX - MaxWindowX)/2;
    YBorder = (MaxMonitorY - MaxWindowY)/2; 
    TabOffset = 0; % This value offsets the tabs inside the figure
    ButtonHeight = 40;
    PanelWidth = MaxWindowX - 2*TabOffset + 4;
    PanelHeight = MaxWindowY - ButtonHeight - 2*TabOffset;
    ButtonWidth = round((PanelWidth - NumberOfTabs)/NumberOfTabs);
    %========================================================================
    %% Set the color varables
    White = [1  1  1];
    BGColor = .9*White;
    %========================================================================
    %% Create a figure for the tabs
    global hTabFig;
    hTabFig = figure(...
        'Units', 'pixels',...
        'Toolbar', 'none',...
        'Position',[ XBorder, YBorder, MaxWindowX, MaxWindowY ],...
        'NumberTitle', 'off',...
        'Name', 'Tab Demo',...
        'MenuBar', 'none',...
        'Resize', 'off',...
        'DockControls', 'off',...
        'Color', White);
    %========================================================================
    %% Define handler for the tabs
    % Define a cell array for panel and pushbutton handles, pushbuttons labels and other data
    % rows are for each tab + two additional rows for other data
    % columns are uipanel handles, selection pushbutton handles, and tab label strings - 3 columns.
    TabHandles = cell(NumberOfTabs,3);
    TabHandles(:,3) = TabLabels(:,1);
    % Add additional rows for other data
    TabHandles{NumberOfTabs+1,1} = hTabFig; % Main figure handle
    TabHandles{NumberOfTabs+1,2} = PanelWidth; % Width of tab panel
    TabHandles{NumberOfTabs+1,3} = PanelHeight; % Height of tab panel
    TabHandles{NumberOfTabs+2,1} = 0; % Handle to default tab 2 content(set later)
    TabHandles{NumberOfTabs+2,2} = White; % Selected tab Color
    TabHandles{NumberOfTabs+2,3} = BGColor; % Background color
    %========================================================================
    %% Build the Tabs
    for TabNumber = 1:NumberOfTabs
      % create a UIPanel   
        TabHandles{TabNumber,1} = uipanel('Units', 'pixels',...
            'Visible', 'off',...
            'Backgroundcolor', White,...
            'BorderWidth', 1,...
            'Position', [TabOffset TabOffset PanelWidth PanelHeight]);

      % create a selection pushbutton
        TabHandles{TabNumber,2} = uicontrol('Style', 'pushbutton',...
            'Units', 'pixels',...
            'BackgroundColor', BGColor,...
            'Position', [TabOffset+(TabNumber-1)*ButtonWidth PanelHeight+TabOffset ButtonWidth ButtonHeight],...
            'String', TabHandles{TabNumber,3},...
            'HorizontalAlignment', 'center',...
            'FontName', 'arial',...
            'FontWeight', 'bold',...
            'FontSize', 10);
    end
    %========================================================================
    %% Define the callbacks for the Tab Buttons
    % All callbacks go to the same function with the additional argument being the Tab number
    for CountTabs = 1:NumberOfTabs
        set(TabHandles{CountTabs,2}, 'callback',...
            {@TabSellectCallback, CountTabs});
    end
%============================================================================
%% Define all other global variables
global Source max_s min_s;
Source = source;
if use_rad
    pow_all_inside = [];
    for i = 1:length(source.inside)
        if source.inside(i)
            pow_all_inside = [pow_all_inside; source.avg.rad{i}];
        end
    end
else
    pow_all_inside = source.avg.pow(find(source.inside),:);
end
max_s = max(max(pow_all_inside));
min_s = min(min(pow_all_inside));

global Bnd;
Bnd.pnt = sourcespace.pos;
Bnd.tri = sourcespace.tri;

global Roi_color;
if use_roi
    Roi_color = roi_color;
end

global Opt_plot1 adapt_time gap;
if use_opt_1
    Opt_plot1 = opt_plot1;
    adapt_time = [];
    if use_opt_x
        for i = 1:length(Source.time)
            adapt_time(end+1) = find(opt_plot1x >= Source.time(i), 1);
        end
    else
        opt_plot1x = Source.time;
        adapt_time = 1:length(Opt_plot1);
    end
    gap = length(opt_plot1x) - length(adapt_time);
end

if use_opt_2
    for i = 1:size(opt_plot2, 1)
        opt_plot2(i,:) = opt_plot2(i,:)*(max(Opt_plot1)/max(opt_plot2(i,:)));
    end
end

global Eeg max_e min_e;
if use_eeg
    Eeg = eeg;
    max_e = max(max(Eeg.trial{1}));
    min_e = min(min(Eeg.trial{1}));
end

global SourceAxis OptAxis OptLine EEGAxis;
%============================================================================
%% Define needed window space values
MarginOffset = 40;
MarginOffset2 = 50;
LineOffset1 = 175;
LineOffset2 = 120;
HorizontalGraphSize = PanelWidth - 2*MarginOffset;
VerticalGraphSize = PanelHeight - 5*MarginOffset;
%============================================================================
%% Define Tab 1: Source
% GIF button
uicontrol('Style', 'pushbutton',...
    'Position', [MarginOffset 1.5*MarginOffset MarginOffset MarginOffset],...
    'Parent', TabHandles{1,1},...
    'string', 'GIF',...
    'BackgroundColor', BGColor,...
    'HorizontalAlignment', 'center',...
    'FontName', 'arial',...
    'FontSize', 12,...
    'callback', {@MakeGIF});

% Time scroll
sli = uicontrol('Style', 'slider',...
    'Position', [MarginOffset 0.5*MarginOffset HorizontalGraphSize MarginOffset],...
    'Parent', TabHandles{1,1},...
    'string', 'Time',...
    'BackgroundColor', BGColor,...
    'HorizontalAlignment', 'center',...
    'FontName', 'arial',...
    'FontSize', 12,...
    'Min', 0,...
    'Max', length(Source.time),...
    'SliderStep', [1/(length(Source.time)), 0.1],...
    'Value', 0,...
    'callback', {@RefreshCurrentPos});

% Optional axis
if use_opt_1
    OptAxis = axes('Parent', TabHandles{1,1},...
        'Units', 'pixels',...
        'Position', [MarginOffset+HorizontalGraphSize/2 4*MarginOffset HorizontalGraphSize/2 VerticalGraphSize]);
    cursor = ones(1,length(Opt_plot1))*min(min(Opt_plot1));
    cursor(1) = max(max(Opt_plot1));
    axes(OptAxis);
    axis([1 length(Opt_plot1) min(min(Opt_plot1-1)) max(max(Opt_plot1+1))]);
    OptLine = plot(opt_plot1x, cursor,'g');
    hold on;
    for i = 1:size(Opt_plot1, 1)
        plot(opt_plot1x, Opt_plot1(i,:));
    end
    if use_opt_2
        for i = 1:size(opt_plot2, 1)
            plot(opt_plot1x, opt_plot2(i,:));
        end
    end
    hold off;
end

% Source axis
SourceAxis = axes('Parent', TabHandles{1,1},...
    'Units', 'pixels',...
    'Position', [MarginOffset 4*MarginOffset HorizontalGraphSize/2 VerticalGraphSize]);
RefreshSourceAxis(0)%, []);
%============================================================================
%% Define Tab 2: EEG
% Time scroll
sli2 = uicontrol('Style', 'slider',...
    'Position', [MarginOffset 0.5*MarginOffset HorizontalGraphSize MarginOffset],...
    'Parent', TabHandles{2,1},...
    'string', 'Time',...
    'BackgroundColor', BGColor,...
    'HorizontalAlignment', 'center',...
    'FontName', 'arial',...
    'FontSize', 12,...
    'Min', 0,...
    'Max', length(Source.time),...
    'SliderStep', [1/(length(Source.time)), 0.1],...
    'Value', 0,...
    'callback', {@RefreshEEGAxis});

if use_eeg
    EEGAxis = axes('Parent', TabHandles{2,1},...
        'Units', 'pixels',...
        'Position', [MarginOffset 4*MarginOffset HorizontalGraphSize/2 VerticalGraphSize]);
    RefreshEEGAxis(sli2);
    %set(EEGAxis, 'Visible', 'off');
end
%============================================================================
%% Save the TabHandles in guidata
guidata(hTabFig,TabHandles);
%============================================================================
%% Make Tab 1 active
TabSellectCallback(0, 0, 1);
%============================================================================

end

%============================================================================
%%% Callback for Tab Selection
function TabSellectCallback(~, ~, SelectedTab)
    % All tab selection pushbuttons are greyed out and uipanels are set to
    % visible off, then the selected panel is made visible and it's selection
    % pushbutton is highlighted.

    %========================================================================
    %% Set up some varables
    TabHandles = guidata(gcf);
    NumberOfTabs = size(TabHandles, 1) - 2;
    White = TabHandles{NumberOfTabs+2,2}; % White
    BGColor = TabHandles{NumberOfTabs+2,3}; % Light Grey
    %========================================================================
    %% Turn all tabs off
    for TabCount = 1:NumberOfTabs
        set(TabHandles{TabCount,1}, 'Visible', 'off');
        set(TabHandles{TabCount,2}, 'BackgroundColor', BGColor);
    end
    %========================================================================
    %% Enable the selected tab
    set(TabHandles{SelectedTab,1}, 'Visible', 'on');        
    set(TabHandles{SelectedTab,2}, 'BackgroundColor', White);
    %========================================================================

end
%============================================================================
%%% Function to draw the field map
function RefreshCurrentPos(hObject, ~)

%============================================================================
%% Load global variables
global EEGAxis SourceAxis use_eeg;
%============================================================================
%% Prepare axis orientations
if use_eeg
    try
        ori.XLim = EEGAxis.XLim;
        ori.YLim = EEGAxis.YLim;
        ori.ZLim = EEGAxis.ZLim;
        ori.CameraPosition = EEGAxis.CameraPosition;
        ori.CameraTarget = EEGAxis.CameraTarget;
        ori.CameraUpVector = EEGAxis.CameraUpVector;
        ori.CameraViewAngle = EEGAxis.CameraViewAngle;
    catch
    end
else
    ori.XLim = SourceAxis.XLim;
    ori.YLim = SourceAxis.YLim;
    ori.ZLim = SourceAxis.ZLim;
    ori.CameraPosition = SourceAxis.CameraPosition;
    ori.CameraTarget = SourceAxis.CameraTarget;
    ori.CameraUpVector = SourceAxis.CameraUpVector;
    ori.CameraViewAngle = SourceAxis.CameraViewAngle;
end
%============================================================================
%% Determine current position in time
current_pos = round(get(hObject, 'value'))
%============================================================================
%% Refresh axis
RefreshSourceAxis(current_pos)%, ori);
if use_eeg
    %RefreshEEGAxis(current_pos);
end
%============================================================================

end
%============================================================================
%%% Function to draw the field map
function RefreshSourceAxis(current_pos)%, ori)

%============================================================================
%% Load global variables
global SourceAxis Source Bnd max_s min_s use_roi Roi_color OptLine use_opt_1 Opt_plot1 adapt_time use_type_1 use_rad gap;
%============================================================================
%% Optional plot
if use_opt_1 && current_pos ~= 0
    cursor = ones(1,length(Opt_plot1))*min(min(Opt_plot1));
    cursor(adapt_time(current_pos)) = max(max(Opt_plot1));
    cursor(adapt_time(current_pos) - adapt_time(1) + 1) = max(max(Opt_plot1));
    OptLine.YData = cursor;
end 
%============================================================================
%% Prepare values for main plot
chosen = find(Source.inside);
current_s = zeros(size(Bnd.pnt, 1), 1);
if current_pos == 0 % Use the sum of values over the whole time duration
    if use_rad
        for i = 1:length(Bnd.pnt)
            if Source.inside(i)
                current_s(i) = mean(Source.avg.rad{i});
            end
        end
    else
        current_s(chosen) = mean(Source.avg.pow(chosen,:), 2);
    end
else % Use values from a specific time point
    if use_rad
        for i = 1:length(Bnd.pnt)
            if Source.inside(i)
                current_s(i) = Source.avg.rad{i}(current_pos);
            end
        end
    else
        current_s(chosen) = Source.avg.pow(chosen,current_pos);
    end
end
current_mask = -1*ones(size(Bnd.pnt, 1), 1);
current_mask(chosen) = 2;
%============================================================================
%% Plot brain mesh
cla(SourceAxis);
axes(SourceAxis);
ft_plot_mesh(Bnd, 'facealpha', 0.2, 'edgealpha', 0, 'edgecolor', [0,0,0]);
if use_roi
    roi_surf.pnt = Roi_color.pos;
    roi_surf.tri = Roi_color.tri;
    ft_plot_mesh(roi_surf, 'facealpha', 0.2, 'edgealpha', 0, 'edgecolor', [0,0,0], 'facecolor', Roi_color.color);
end
%============================================================================
%% Main plot
hold on;
if use_type_1
    scatter3(Bnd.pnt(chosen, 1), Bnd.pnt(chosen, 2), Bnd.pnt(chosen, 3), [], current_s(chosen), 'filled');
else
    ft_plot_mesh(Bnd, 'edgecolor', [0,0,0], 'vertexcolor', current_s, 'edgealpha', 0, 'facealpha', current_mask, 'clim', [min_s max_s], 'alphalim', [0 1], 'alphamap', 'rampup', 'colormap', 'jet', 'maskstyle', 'opacity');
end
%============================================================================
%% Final ajustments
lighting gouraud
camlight
% colormap jet;
caxis([min_s max_s]);
rotate3d on;
% try
%     SourceAxis.XLim = ori.XLim;
%     SourceAxis.YLim = ori.YLim;
%     SourceAxis.ZLim = ori.ZLim;
%     SourceAxis.CameraPosition = ori.CameraPosition;
%     SourceAxis.CameraTarget = ori.CameraTarget;
%     SourceAxis.CameraUpVector = ori.CameraUpVector;
%     SourceAxis.CameraViewAngle = ori.CameraViewAngle;
% catch
% end
%============================================================================

end
%============================================================================
%%% Function to draw the EEG values at the same time that the sources are presented
function MakeGIF(hObject, ~)

%============================================================================
%% Load global variables
global hTabFig Source;
%============================================================================
%% Make gif
filename = 'SourceGIF.gif';
for n = 1:2:length(Source.time)
    RefreshSourceAxis(n);
    drawnow
    frame = getframe(hTabFig);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im,256);
    if n == 1
        imwrite(imind, cm, filename, 'gif', 'DelayTime', 0.00008, 'Loopcount', inf);
    else
        imwrite(imind, cm, filename, 'gif', 'DelayTime', 0.00008, 'WriteMode', 'append');
    end
end
%============================================================================

end
%============================================================================
%%% Function to draw the EEG values at the same time that the sources are presented
function RefreshEEGAxis(hObject, ~)

%============================================================================
%% Load global variables
global use_eeg EEGAxis Eeg Bnd max_e min_e adapt_time;
%============================================================================
%% Check the existence of an EEG input
if use_eeg
    %========================================================================
    %% Determine current position in time
    current_pos = round(get(hObject, 'value'))
    %========================================================================
    %% Prepare values for main plot
    if current_pos == 0
        current_e = sum(Eeg.trial{1}, 2);
    else
        current_pos = adapt_time(current_pos);
        current_e = Eeg.trial{1}(:,current_pos);
    end
    %========================================================================
    %% Plot brain mesh
    cla(EEGAxis);
    axes(EEGAxis);
    ft_plot_mesh(Bnd, 'facealpha', 0.2, 'edgealpha', 0, 'edgecolor', [0,0,0]);
    %========================================================================
    %% Main plot
    hold on;
    for channel = 1:length(Eeg.label)
        current_channel_name = Eeg.label{channel};
        channel_pos = Eeg.elec.chanpos(find(strcmp(Eeg.elec.label, current_channel_name)),:);
        scatter3(channel_pos(1), channel_pos(2), channel_pos(3), 20, current_e(channel), 'filled');
    end
    %========================================================================
    %% Final ajustments
    lighting gouraud
    camlight
    colormap jet;
    caxis([min_e max_e]);
    set(gca, 'Color', 'none');
    axis off;
    rotate3d on;
    %========================================================================
end
%============================================================================

end
%============================================================================