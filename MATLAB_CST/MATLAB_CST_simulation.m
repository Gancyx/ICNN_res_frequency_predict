clc;
clear;
close all;

%% 加载参数文件
load('input_parameters.mat');
% 前四列分别为贴片长、贴片宽、基板厚度和基板介电常数

%% 其余参数
w = 1.46; % 馈线宽
l = 40;   % 馈线长
lx = 100; % 基板长
ly = 100; % 基板宽
tm = 0.035; % 金属层厚
Frq = [1, 10.5]; % 工作频率

%% 单层循环，每次处理一组参数
for i = 1:size(input_parameters, 1)
    % 从当前行获取参数
    a = input_parameters(i, 1);    % 贴片长
    b = input_parameters(i, 2);    % 贴片宽
    ts = input_parameters(i, 3);   % 基板厚度
    er1 = input_parameters(i, 4);  % 基板介电常数
    
    % 初始化CST文件
    cst = actxserver('CSTStudio.application');
    mws = invoke(cst, 'NewMWS');
    invoke(mws, 'FileNew');
    path = pwd;
    filename = sprintf('\\Antenna_%d.cst', i);
    fullname = [path filename];
    invoke(mws, 'SaveAs', fullname, 'True');
    invoke(mws, 'DeleteResults');

    % 设置全局单位
    units = invoke(mws, 'Units');
    invoke(units, 'Geometry', 'mm');
    invoke(units, 'Frequency', 'ghz');
    invoke(units, 'Time', 'ns');
    invoke(units, 'TemperatureUnit', 'kelvin');
    release(units);

    % 设置工作频率
    solver = invoke(mws, 'Solver');
    invoke(solver, 'FrequencyRange', Frq(1), Frq(2));
    release(solver);

    % 设置背景材料
    background = invoke(mws, 'Background');
    invoke(background, 'ResetBackground');
    invoke(background, 'Type', 'Normal');
    release(background);

    % 设置边界条件
    boundary = invoke(mws, 'Boundary');
    invoke(boundary, 'Xmin', 'expanded open');
    invoke(boundary, 'Xmax', 'expanded open');
    invoke(boundary, 'Ymin', 'expanded open');
    invoke(boundary, 'Ymax', 'expanded open');
    invoke(boundary, 'Zmin', 'expanded open');
    invoke(boundary, 'Zmax', 'expanded open');
    invoke(boundary, 'Xsymmetry', 'none');
    invoke(boundary, 'Ysymmetry', 'none');
    invoke(boundary, 'Zsymmetry', 'none');
    release(boundary);

    % 创建介质材料
    material = invoke(mws, 'Material');
    material1 = 'material265';
    invoke(material, 'Reset');
    invoke(material, 'Name', material1);
    invoke(material, 'FrqType', 'all');
    invoke(material, 'Type', 'Normal');
    invoke(material, 'Epsilon', er1);
    invoke(material, 'Create');
    release(material);

    % 建模
    brick = invoke(mws, 'Brick');

    %定义底版
    Str_Name='bottom';
    Str_Component='Bottom';
    Str_Material='PEC';
    x=[-lx/2,lx/2];
    y=[-ly/2,ly/2];
    z=[-ts-tm,-ts]; 
    invoke(brick, 'Reset');
    invoke(brick, 'Name', Str_Name);
    invoke(brick, 'Component', Str_Component);
    invoke(brick, 'Material', Str_Material);
    invoke(brick, 'Xrange', x(1), x(2));
    invoke(brick, 'Yrange', y(1), y(2));
    invoke(brick, 'Zrange', z(1), z(2));
    invoke(brick, 'Create');

    %定义基板substrate
    Str_Name='sub';
    Str_Component='Sub';
    Str_Material=material1;
    x=[-lx/2,lx/2];
    y=[-ly/2,ly/2];
    z=[-ts,0]; 
    invoke(brick, 'Reset');
    invoke(brick, 'Name', Str_Name);
    invoke(brick, 'Component', Str_Component);
    invoke(brick, 'Material', Str_Material);
    invoke(brick, 'Xrange', x(1), x(2));
    invoke(brick, 'Yrange', y(1), y(2));
    invoke(brick, 'Zrange', z(1), z(2));
    invoke(brick, 'Create');

    %定义贴片
    Str_Name='patch';
    Str_Component='Patch';
    Str_Material='PEC';
    x=[-a/2,a/2];
    y=[-b/2,b/2];
    z=[0,tm]; 
    invoke(brick, 'Reset');
    invoke(brick, 'Name', Str_Name);
    invoke(brick, 'Component', Str_Component);
    invoke(brick, 'Material', Str_Material);
    invoke(brick, 'Xrange', x(1), x(2));%这里的数值可以是数值类型，也可以是字符串
    invoke(brick, 'Yrange', y(1), y(2));
    invoke(brick, 'Zrange', z(1), z(2));
    invoke(brick, 'Create');

    %定义馈线
    Str_Name='line';
    Str_Component='Feed';
    Str_Material='PEC';
    x=[-lx/2,-a/2];
    y=[-w/2,w/2];
    z=[0,tm]; 
    invoke(brick, 'Reset');
    invoke(brick, 'Name', Str_Name);
    invoke(brick, 'Component', Str_Component);
    invoke(brick, 'Material', Str_Material);
    invoke(brick, 'Xrange', x(1), x(2));
    invoke(brick, 'Yrange', y(1), y(2));
    invoke(brick, 'Zrange', z(1), z(2));
    invoke(brick, 'Create');

    % 设置端口
    pick = invoke(mws, 'Pick');
    invoke(pick, 'PickFaceFromId','Feed:line', '4' );%
    port = invoke(mws, 'Port');
    invoke(port, 'Reset');
    invoke(port, 'PortNumber', '1');
    invoke(port, 'Label', '');
    invoke(port, 'NumberOfModes', '1');
    invoke(port, 'AdjustPolarization', 'False');
    invoke(port, 'PolarizationAngle', '0.0');
    invoke(port, 'ReferencePlaneDistance', '0');
    invoke(port, 'TextSize', '50');
    invoke(port, 'TextMaxLimit', '0');
    invoke(port, 'Coordinates', 'Picks');
    invoke(port, 'Orientation', 'positive');
    invoke(port, 'PortOnBound', 'False');
    invoke(port, 'ClipPickedPortToBound', 'False');
    invoke(port, 'Xrange', -lx/2, -lx/2);
    invoke(port, 'Yrange', -w/2, w/2);
    invoke(port, 'Zrange', 0, tm);
    invoke(port, 'XrangeAdd', '0.0', '0.0');
    invoke(port, 'YrangeAdd', 3*ts, 3*ts);
    invoke(port, 'ZrangeAdd', ts, 3*ts);
    invoke(port, 'SingleEnded', 'False');
    invoke(port, 'Create');

    % 开始仿真
    solver = invoke(mws, 'Solver');
    invoke(solver, 'Start');

    invoke(mws, 'Save'); % 保存

    % 释放资源
    release(port);
    release(pick);
    release(brick);
    release(solver);
    release(mws);
    release(cst);
    
    % 显示进度
    disp(['已完成第 ', num2str(i), '/', num2str(size(input_parameters, 1)), ' 组参数的仿真']);
end
