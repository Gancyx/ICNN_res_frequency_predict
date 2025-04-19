clc;
clear;
close all;

%% CST�ļ���ʼ��
cst = actxserver('CSTStudio.application');%��������CSTӦ�ÿؼ�
mws = invoke(cst, 'NewMWS');%�½�һ��MWS��Ŀ
app = invoke(mws, 'GetApplicationName');%��ȡ��ǰӦ������
ver = invoke(mws, 'GetApplicationVersion');%��ȡ��ǰӦ�ð汾��
invoke(mws, 'FileNew');%�½�һ��CST�ļ�
path=pwd;%��ȡ��ǰm�ļ���·��
filename='\Patch_Antenna_9.8GHz.cst';%�½���CST�ļ�����
fullname=[path filename];
invoke(mws, 'SaveAs', fullname, 'True');%True��ʾ���浽ĿǰΪֹ�Ľ��
invoke(mws, 'DeleteResults');%ɾ��֮ǰ�Ľ����ע�����н����������޸�ģ�ͻ���ֵ�����ʾ�Ƿ�ɾ��������������еĳ����ֹͣ����ȴ��ֶ��������ʹ֮��ʧ
%%CST�ļ���ʼ������

%% ��Ƭ���߽�ģ��������
%��������������Ҫ�޸ĵĲ���
a= 9.06; %��Ƭ��
b= 11.86; %��Ƭ��
ts= 1.59; %�����
er1 = 2.2; %����Ľ�糣��

w=1.46; %���߿�100ŷķ������
l=40; %���߳�
lx=100; %���峤
ly=100; %�����
tm=0.035; %�������
Frq=[6 14]; %����Ƶ�ʣ���λ��GHz
%��CST�м���ṹ��������������ֶ���CST�ļ��н��в���
invoke(mws, 'StoreParameter','a',a);
invoke(mws, 'StoreParameter','b',b);
invoke(mws, 'StoreParameter','w',w);
invoke(mws, 'StoreParameter','l',l);
invoke(mws, 'StoreParameter','lx',lx);
invoke(mws, 'StoreParameter','ly',ly);
invoke(mws, 'StoreParameter','ts',ts);
invoke(mws, 'StoreParameter','tm',tm);
%%��ģ�����������ý���

%%ȫ�ֵ�λ��ʼ��
sCommand = '';
sCommand = [sCommand 'With Units' ];
sCommand = [sCommand 10 '.Geometry "mm"'];%10�������ǻ��е�����
sCommand = [sCommand 10 '.Frequency "ghz"' ];
sCommand = [sCommand 10 '.Time "ns"'];
sCommand = [sCommand 10 'End With'] ;
invoke(mws, 'AddToHistory','define units', sCommand);
%%ȫ�ֵ�λ��ʼ������

%%����Ƶ������
sCommand = '';
sCommand = [sCommand 'Solver.FrequencyRange '  num2str(Frq(1)) ',' num2str(Frq(2)) ];
invoke(mws, 'AddToHistory','define frequency range', sCommand);
%%����Ƶ�����ý���

%%������������
sCommand = '';
sCommand = [sCommand 'With Background' ];
sCommand = [sCommand 10 '.ResetBackground'];
sCommand = [sCommand 10 '.Type "Normal"' ];
sCommand = [sCommand 10 'End With'] ;
invoke(mws, 'AddToHistory','define background', sCommand);
%%�����������ý���

%%�߽��������á�
sCommand = '';
sCommand = [sCommand 'With Boundary' ];
sCommand = [sCommand 10 '.Xmin "expanded open"'];
sCommand = [sCommand 10 '.Xmax "expanded open"'];
sCommand = [sCommand 10 '.Ymin "expanded open"'];
sCommand = [sCommand 10 '.Ymax "expanded open"'];
sCommand = [sCommand 10 '.Zmin "expanded open"'];
sCommand = [sCommand 10 '.Zmax "expanded open"'];
sCommand = [sCommand 10 '.Xsymmetry "none"' ];
sCommand = [sCommand 10 '.Xsymmetry "none"' ];
sCommand = [sCommand 10 '.Xsymmetry "none"' ];
sCommand = [sCommand 10 'End With'] ;
invoke(mws, 'AddToHistory','define boundary', sCommand);
%%�߽��������ý���

%%�½�������ʲ���
sCommand = '';
sCommand = [sCommand 'With Material' ];
sCommand = [sCommand 10 '.Reset'];
sCommand = [sCommand 10 '.Name "material1"' ];
sCommand = [sCommand 10 '.FrqType "all"' ];
sCommand = [sCommand 10 '.Type "Normal"' ];
sCommand = [sCommand 10 '.Epsilon ' num2str(er1) ];
sCommand = [sCommand 10 '.Create'];
sCommand = [sCommand 10 'End With'] ;
invoke(mws, 'AddToHistory','define material: material265', sCommand);
%%�½�������ʲ��Ͻ���

%%ʹBounding Box��ʾ,��δ��벻�ñ������ʷ��
plot = invoke(mws, 'Plot');
invoke(plot, 'DrawBox', 'True');
%%ʹBounding Box��ʾ����

%%��ģ��ʼ
%%����Brick����ʼ
Str_Name='patch';
Str_Component='Patch';
Str_Material='PEC';
%������һ������д�ɺ���
sCommand = '';
sCommand = [sCommand 'With Brick'];
sCommand = [sCommand 10 '.Reset'];
sCommand = [sCommand 10 '.Name "',Str_Name, '"'];
sCommand = [sCommand 10 '.Component "', Str_Component, '"'];
sCommand = [sCommand 10 '.Material "', Str_Material, '"'];
sCommand = [sCommand 10 '.Xrange ', '"-a/2", "a/2"'];%����ı�������Ϊ�ַ�����ӦCST��������б�ı�����,����ı��������粻��˫���ţ���ô��CST�����ֶ��޸Ĳ����б�������ݺ󲻻������ʾ���㰴F7���£�������Ҫ�Լ�����ʷ�б�������
sCommand = [sCommand 10 '.Yrange ', '"-b/2","b/2"'];
sCommand = [sCommand 10 '.Zrange ', '"0","tm"'];
sCommand = [sCommand 10 '.Create'];
sCommand = [sCommand 10 'End With'] ;
invoke(mws, 'AddToHistory',['define brick:',Str_Component,':',Str_Name], sCommand);
%������һ������д�ɺ���

invoke(plot, 'ZoomToStructure');%���ŵ��ʺϴ�С���ͺ���CST���水�ո���һ��Ч����û�°����ո�������ṹ����Ҫ

Str_Name='line1';
Str_Component='Feed';
Str_Material='PEC';
sCommand = '';
sCommand = [sCommand 'With Brick'];
sCommand = [sCommand 10 '.Reset'];
sCommand = [sCommand 10 '.Name "',Str_Name, '"'];
sCommand = [sCommand 10 '.Component "', Str_Component, '"'];
sCommand = [sCommand 10 '.Material "', Str_Material, '"'];
sCommand = [sCommand 10 '.Xrange ', '"-lx/2","-a/2"'];%����ı�������Ϊ�ַ�����ӦCST��������б�ı�����
sCommand = [sCommand 10 '.Yrange ', '"-w/2","w/2"'];
sCommand = [sCommand 10 '.Zrange ', '"0","tm"'];
sCommand = [sCommand 10 '.Create'];
sCommand = [sCommand 10 'End With'] ;
invoke(mws, 'AddToHistory',['define brick:',Str_Component,':',Str_Name], sCommand);

Str_Name='bottom';
Str_Component='Bottom';
Str_Material='PEC';
sCommand = '';
sCommand = [sCommand 'With Brick'];
sCommand = [sCommand 10 '.Reset'];
sCommand = [sCommand 10 '.Name "',Str_Name, '"'];
sCommand = [sCommand 10 '.Component "', Str_Component, '"'];
sCommand = [sCommand 10 '.Material "', Str_Material, '"'];
sCommand = [sCommand 10 '.Xrange ', '"-lx/2","lx/2"'];%����ı�������Ϊ�ַ�����ӦCST��������б�ı�����
sCommand = [sCommand 10 '.Yrange ', '"-ly/2","ly/2"'];
sCommand = [sCommand 10 '.Zrange ', '"-ts-tm","-ts"'];
sCommand = [sCommand 10 '.Create'];
sCommand = [sCommand 10 'End With'] ;
invoke(mws, 'AddToHistory',['define brick:',Str_Component,':',Str_Name], sCommand);

invoke(plot, 'ZoomToStructure');

Str_Name='sub';
Str_Component='Sub';
Str_Material='material1';
sCommand = '';
sCommand = [sCommand 'With Brick'];
sCommand = [sCommand 10 '.Reset'];
sCommand = [sCommand 10 '.Name "',Str_Name, '"'];
sCommand = [sCommand 10 '.Component "', Str_Component, '"'];
sCommand = [sCommand 10 '.Material "', Str_Material, '"'];
sCommand = [sCommand 10 '.Xrange ', '"-lx/2","lx/2"'];%����ı�������Ϊ�ַ�����ӦCST��������б�ı�����
sCommand = [sCommand 10 '.Yrange ', '"-ly/2","ly/2"'];
sCommand = [sCommand 10 '.Zrange ', '"-ts","0"'];
sCommand = [sCommand 10 '.Create'];
sCommand = [sCommand 10 'End With'] ;
invoke(mws, 'AddToHistory',['define brick:',Str_Component,':',Str_Name], sCommand);

%%��ģ����

invoke(plot, 'ZoomToStructure');

%%�˿����ã����õķ�������CST����ѡ��һ����Ȼ�����ö˿���һ���Ĳ�����������ȫ����
%�˿�1
sCommand = '';
sCommand = [sCommand 'Pick.PickFaceFromId "','Feed:line1"',',4'];
invoke(mws, 'AddToHistory','pick face', sCommand);
sCommand = '';
sCommand = [sCommand 10 'With Port'];
sCommand = [sCommand 10 '.Reset'];
sCommand = [sCommand 10 '.PortNumber ', '1'];
sCommand = [sCommand 10 '.Label ', '""'];
sCommand = [sCommand 10 '.NumberOfModes ', '1'];
sCommand = [sCommand 10 '.AdjustPolarization ', '"False"'];
sCommand = [sCommand 10 '.PolarizationAngle ', '0.0'];
sCommand = [sCommand 10 '.ReferencePlaneDistance ', '0'];
sCommand = [sCommand 10 '.TextSize ', '50'];
sCommand = [sCommand 10 '.TextMaxLimit ', '0'];
sCommand = [sCommand 10 '.Coordinates ', '"Picks"'];
sCommand = [sCommand 10 '.Orientation ', '"positive"'];
sCommand = [sCommand 10 '.PortOnBound ', '"False"'];
sCommand = [sCommand 10 '.ClipPickedPortToBound ', '"False"'];
sCommand = [sCommand 10 '.Xrange ', '"-lx/2","-lx/2"'];
sCommand = [sCommand 10 '.Yrange ', '"-w/2","w/2"'];
sCommand = [sCommand 10 '.Zrange ', '"0","tm"'];
sCommand = [sCommand 10 '.XrangeAdd ', '"0.0","0.0"'];
sCommand = [sCommand 10 '.YrangeAdd ', '"3*ts","3*ts"'];
sCommand = [sCommand 10 '.ZrangeAdd ', '"ts","3*ts"'];
sCommand = [sCommand 10 '.SingleEnded ', '"False"'];
sCommand = [sCommand 10 '.Create'];
sCommand = [sCommand 10 'End With'];
invoke(mws, 'AddToHistory','define port1', sCommand);

%% ���濪ʼ
solver = invoke(mws, 'Solver');
invoke(solver, 'Start');
%%�������

invoke(mws, 'Save');%����
%invoke(mws, 'Quit');%�˳�
