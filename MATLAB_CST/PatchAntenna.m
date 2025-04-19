%ccly_Patch_Antenna
%%MATLAB控制CST的思想基础：CST的建模仿真的命令都是VB命令，而要想使用MATLAB来控制CST就需要将应用之间的通信接口作为一个桥梁架接在MATLAB与CST之间，COM组件就是做这样的事情。
%%由于CST程序中的帮助文件关于VB语言的使用非常详细，所以我们需要做的就是将这座桥梁搭好。注：理论上所有手动操作CST的VB命令能在帮助文件里面找到对应代码
%%将VB命令转化为在MATLAB中能够运行的代码是MATLAB自动控制CST进行建模仿真的关键
%%典型的VB命令转化为CST代码如下所示[1]:
% With Brick                                    brick = invoke(mws, 'Brick')
%     .Reset                                    invoke(brick, 'Reset');
%     .Name ("brick1")                          invoke(brick, 'Name', "brick1");
%     .Component ("component1")                 invoke(brick, 'Component', "component1");
%     .Material ("PEC")               ==》      invoke(brick, 'Material', "PEC");
%     .Xrange (0, 2)                            invoke(brick, 'Xrange', 0, 2);
%     .Yrange (0, 3)                            invoke(brick, 'Yrange', 0, 3);
%     .Zrange (0, "a+3")                        invoke(brick, 'Zrange', '0', num2str(a+3));
%     .Create                                   invoke(brick, 'Create');
% End With                                      release(brick);
%基本思路就是找出mws中需要操作的对象，然后对其所有参数进行赋值或者执行命令，然后释放对象

%%参考文献：
%%[1]CST. "Application Note - Calling CST Studio from Matlab"

clc;
clear;
close all;

%%贴片天线建模基本参数
a=38.6;%贴片长
b=38;%贴片宽
w=1.46;%馈线宽，100欧姆传输线
l=40;%馈线长
lx=100;%基板长
ly=100;%基板宽
ts=2;%基板厚
tm=0.035;%金属层厚
Frq=[2,2.7];%工作频率，单位：GHz
%%建模基本参数设置结束

%%CST文件初始化
cst = actxserver('CSTStudio.application');%首先载入CST应用控件
mws = invoke(cst, 'NewMWS');%新建一个MWS项目
app = invoke(mws, 'GetApplicationName');%获取当前应用名称
ver = invoke(mws, 'GetApplicationVersion');%获取当前应用版本号
invoke(mws, 'FileNew');%新建一个CST文件
path=pwd;%获取当前m文件夹路径
filename='\Patch_Antenna.cst';%新建的CST文件名字
fullname=[path filename];
invoke(mws, 'SaveAs', fullname, 'True');%True表示保存到目前为止的结果
invoke(mws, 'DeleteResults');%删除之前的结果。注：在有结果的情况下修改模型会出现弹窗提示是否删除结果，这样运行的程序会停止，需等待手动点击弹窗使之消失
%%CST文件初始化结束

%%全局单位初始化
units = invoke(mws, 'Units');
invoke(units, 'Geometry', 'mm');
invoke(units, 'Frequency', 'ghz');
invoke(units, 'Time', 'ns');
invoke(units, 'TemperatureUnit', 'kelvin');
release(units);
%%全局单位初始化结束

%%工作频率设置
solver = invoke(mws, 'Solver');
invoke(solver, 'FrequencyRange', Frq(1), Frq(2));
release(solver);
%%工作频率设置结束

%%背景材料设置
background = invoke(mws, 'Background');
invoke(background, 'ResetBackground');
invoke(background, 'Type', 'Normal');
release(background);
%%背景材料设置结束

%%边界条件设置。
boundary = invoke(mws, 'Boundary');
invoke(boundary, 'Xmin', 'expanded open');%常用的值：”electric””magnetic””open””expanded open””periodic”"conducting wall"等
invoke(boundary, 'Xmax', 'expanded open');
invoke(boundary, 'Ymin', 'expanded open');
invoke(boundary, 'Ymax', 'expanded open');
invoke(boundary, 'Zmin', 'expanded open');
invoke(boundary, 'Zmax', 'expanded open');
invoke(boundary, 'Xsymmetry', 'none');%可以是”electric””magnetic””none”
invoke(boundary, 'Ysymmetry', 'none');
invoke(boundary, 'Zsymmetry', 'none');
invoke(boundary, 'ApplyInAllDirections', 'True');
release(boundary);
%%边界条件设置结束

%%新建所需介质材料
material = invoke(mws, 'Material');
material1 = 'material265';
er1 = 2.65;
invoke(material, 'Reset');
invoke(material, 'Name', material1);
invoke(material, 'FrqType', 'all');
invoke(material, 'Type', 'Normal');
invoke(material, 'Epsilon', er1);
invoke(material, 'Create');
release(material);
%%新建所需介质材料结束

%%使Bounding Box显示
plot = invoke(mws, 'Plot');
invoke(plot, 'DrawBox', 'True');

%%使Bounding Box显示结束

%%建模开始
%%调用Brick对象开始
brick = invoke(mws, 'Brick');

Str_Name='patch';
Str_Component='Patch';
Str_Material='PEC';
x=[-a/2,a/2];
y=[-b/2,b/2];
z=[0,tm]; 
%以下这一串可以写成函数
invoke(brick, 'Reset');
invoke(brick, 'Name', Str_Name);
invoke(brick, 'Component', Str_Component);
invoke(brick, 'Material', Str_Material);
invoke(brick, 'Xrange', x(1), x(2));%这里的数值可以是数值类型，也可以是字符串
invoke(brick, 'Yrange', y(1), y(2));
invoke(brick, 'Zrange', z(1), z(2));
invoke(brick, 'Create');
%以上这一串可以写成函数

invoke(plot, 'ZoomToStructure');%缩放到适合大小，就和在CST里面按空格是一个效果，没事按按空格看下整体结构很重要

Str_Name='line1';
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

Str_Name='line2';
Str_Component='Feed';
Str_Material='PEC';
x=[a/2,lx/2];
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

invoke(plot, 'ZoomToStructure');

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
%%建模结束

invoke(plot, 'ZoomToStructure');

%%端口设置，采用的方法和在CST里面选中一个面然后设置端口是一样的操作，这里完全复现
%端口1
pick = invoke(mws, 'Pick');
invoke(pick, 'PickFaceFromId','Feed:line1', '4' );%
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
%端口2
pick = invoke(mws, 'Pick');
invoke(pick, 'PickFaceFromId','Feed:line2', '6' );
port = invoke(mws, 'Port');
invoke(port, 'Reset');
invoke(port, 'PortNumber', '2');
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
invoke(port, 'Xrange', lx/2, lx/2);
invoke(port, 'Yrange', -w/2, w/2);
invoke(port, 'Zrange', 0, tm);
invoke(port, 'XrangeAdd', '0.0', '0.0');
invoke(port, 'YrangeAdd', 3*ts, 3*ts);
invoke(port, 'ZrangeAdd', ts, 3*ts);
invoke(port, 'SingleEnded', 'False');
invoke(port, 'Create');
%%端口设置结束

%%设置远场方向图的Monitor
monitor = invoke(mws, 'Monitor');
farfield_monitor = 2.1:0.05:2.6;
for i = 1:length(farfield_monitor)
    Str_name = ['Farfield (f=',num2str(farfield_monitor(i)),')'];
    invoke(monitor, 'Reset');
    invoke(monitor, 'Name', Str_name);
    invoke(monitor, 'Dimension', 'Volume');
    invoke(monitor, 'Domain', 'Frequency');
    invoke(monitor, 'FieldType', 'Farfield');
    invoke(monitor, 'Frequency', farfield_monitor(i));
    invoke(monitor, 'Create');
end
%%设置远场方向图的Monitor结束

%%仿真开始
solver = invoke(mws, 'Solver');
invoke(solver, 'Start');
%%仿真结束全局

invoke(mws, 'Save');%保存
%invoke(mws, 'Quit');%退出

release(plot);
release(pick);
release(monitor);
release(port);
release(brick);
release(solver);
release(mws);
release(cst);