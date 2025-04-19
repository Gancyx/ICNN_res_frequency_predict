clc;
clear;
%% 数据归一化并映射到整数范围，但第五列保持原样
% 读取MAT文件
dataStruct = load('data.mat');

% 获取数据
data = dataStruct.data;

% 定义二进制表示的位数为m
m = 10;

% 对每列进行归一化并映射到 [0, 2^m - 1]，并取整数，但第五列保持原样
mappedData = zeros(size(data));
for col = 1:size(data, 2)
    if col == 5
        % 第五列直接复制原始数据，不做任何处理
        mappedData(:, col) = data(:, col);
    else
        % 其他列进行归一化处理
        minVal = min(data(:, col));
        maxVal = max(data(:, col));
        % 归一化并映射到 [0, 2^m - 1]，然后四舍五入取整
        mappedData(:, col) = round(((data(:, col) - minVal) / (maxVal - minVal)) * (2^m - 1));
    end
end

% 打印映射后的整数数据
disp('映射后的数据(第五列保持原样):');
disp(mappedData);

% 保存映射数据到新的 MAT 文件
save('mapped_data.mat', 'mappedData');

%% 将输入数据转换为二进制矩阵的形式

% 读取归一化后的数据
file_content = load('mapped_data.mat');
data_matrix = file_content.mappedData; % 假设数据的变量名为 mappedData
data_matrix = data_matrix(:, 1:4); % 提取前四列数据

% 将数据转换为二进制矩阵
binary_matrices = cell(size(data_matrix, 1), 1); % 用于存储每行结果

for i = 1:size(data_matrix, 1)
    % 初始化存储每一行的二进制矩阵
    binary_row = zeros(4, m); % 4 表示前四列数据，每列转换为 m 位
    for j = 1:4
        % 将每个值转换为二进制字符数组，并转为数值数组
        binary_str = dec2bin(data_matrix(i, j), m); % 转换为二进制字符串
        binary_row(j, :) = binary_str - '0'; % 将字符数组转换为数值数组
    end
    binary_matrices{i} = binary_row; % 存储每一行结果
end

% 保存结果
save('binary_matrices.mat', 'binary_matrices');

disp('转换完成，结果已保存为 binary_matrices.mat');

%% 二进制矩阵转换为图片
% 创建用于保存图片的文件夹
output_folder = 'dataset';  % 修改为统一文件夹名
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 加载映射后的数据以获取标签
load('mapped_data.mat', 'mappedData');  % 确保mappedData包含第五列
labels = mappedData(:,5);              % 第五列为标签

% 初始化存储文件名和标签的数组
filenames = cell(length(binary_matrices),1);
label_values = zeros(length(binary_matrices),1);

% 遍历每个二进制矩阵，转换为灰度图片并保存
for idx = 1:length(binary_matrices)
    binary_matrix = binary_matrices{idx}; % 获取当前矩阵
    
    % 将 0 和 1 转换为灰度值 (0 和 255)
    grayscale_image = uint8(binary_matrix * 255); % MATLAB 图像使用 uint8 格式
    
    % 生成文件名
    filename = sprintf('image_%03d.png', idx+194);
    output_path = fullfile(output_folder, filename);
    imwrite(grayscale_image, output_path);
    
    % 记录文件名和标签
    filenames{idx} = filename;
    label_values(idx) = labels(idx);
end

% 保存标签到CSV文件
label_table = table(filenames, label_values, 'VariableNames', {'filename', 'label'});
writetable(label_table, 'label.csv');

disp('所有二进制矩阵已成功转换为灰度图片，标签已保存至label.csv！');