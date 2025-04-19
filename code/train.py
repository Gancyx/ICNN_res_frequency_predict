import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, random_split
from torchvision import transforms
from PIL import Image
import pandas as pd
import os

# 超参数设置
batch_size = 3
learning_rate = 0.001
num_epochs = 200
train_val_split = 0.8  # 训练集占80%
dropout_rate = 0.1
normalization_mean = [0.5]
normalization_std = [0.5]

class ImageRegressionDataset(Dataset):
    def __init__(self, csv_path, img_dir, transform=None):
        self.labels_df = pd.read_csv(csv_path)  # 直接读取CSV
        self.img_dir = img_dir                  # 图片路径
        self.transform = transform

    def __getitem__(self, idx):
        img_name = os.path.join(self.img_dir, self.labels_df.iloc[idx, 0])
        image = Image.open(img_name)
        label = torch.tensor(self.labels_df.iloc[idx, 1], dtype=torch.float32)
        if self.transform:
            image = self.transform(image)
        return image, label

    def __len__(self):
        return len(self.labels_df)

# 定义数据预处理 - 移除Resize操作
transform = transforms.Compose([
    transforms.ToTensor(),                    # 转为Tensor
    transforms.Normalize(mean=normalization_mean, std=normalization_std)  # 使用超参数
])

# 创建数据集并划分训练集/验证集
full_dataset = ImageRegressionDataset(
    csv_path="./data/label.csv",   # CSV路径
    img_dir="./data/image/",       # 图片文件夹路径
    transform=transform
)

# 按比例划分
train_size = int(train_val_split * len(full_dataset))  # 使用超参数
val_size = len(full_dataset) - train_size
train_dataset, val_dataset = random_split(full_dataset, [train_size, val_size])

# 创建DataLoader
train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)

# 定义新的CNN架构 - 基于表格的网络结构
class CNNRegressor(nn.Module):
    def __init__(self):
        super(CNNRegressor, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=1, out_channels=2, kernel_size=(1, 3), stride=1) # 卷积层1: 输入 4×10×1, 输出 4×8×2
        self.conv2 = nn.Conv2d(in_channels=2, out_channels=4, kernel_size=(1, 3), stride=1) # 卷积层2: 输入 4×8×2, 输出 4×6×4
        self.conv3 = nn.Conv2d(in_channels=4, out_channels=8, kernel_size=(2, 2), stride=1) # 卷积层3: 输入 4×6×4, 输出 3×5×8
        
        # 全连接层
        self.fc1 = nn.Linear(3 * 5 * 8, 100)  # 120 -> 100
        self.fc2 = nn.Linear(100, 20)         # 100 -> 20
        self.fc3 = nn.Linear(20, 1)           # 20 -> 1
        
        # 激活函数
        self.relu = nn.ReLU()
        self.dropout = nn.Dropout(dropout_rate)
        
    def forward(self, x):
        # 卷积层
        x = self.relu(self.conv1(x))
        x = self.relu(self.conv2(x))
        x = self.relu(self.conv3(x))
        
        # 展平
        x = x.view(-1, 3 * 5 * 8)
        
        # 全连接层
        x = self.relu(self.fc1(x))
        x = self.dropout(x)
        x = self.relu(self.fc2(x))
        x = self.fc3(x)
        
        return x

# 初始化模型、损失函数和优化器
model = CNNRegressor()

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = model.to(device)
print(f"Using device: {device}")

criterion = nn.MSELoss(reduction='mean')  # 均方误差损失
optimizer = optim.SGD(model.parameters(), lr=learning_rate)  # 使用超参数

def train_model(model, train_loader, val_loader, criterion, optimizer, num_epochs):
    best_val_loss = float('inf')
    
    for epoch in range(num_epochs):
        # 训练阶段
        model.train()
        running_loss = 0.0
        for images, labels in train_loader:
            # 将数据移到GPU
            images = images.to(device)
            labels = labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs.view(-1), labels)  # 修改：使用view(-1)替代squeeze()
            loss.backward()
            optimizer.step()
            running_loss += loss.item() * images.size(0)
        epoch_loss = running_loss / len(train_loader.dataset)
        
        # 验证阶段
        model.eval()
        val_loss = 0.0
        with torch.no_grad():
            for images, labels in val_loader:
                # 将数据移到GPU
                images = images.to(device)
                labels = labels.to(device)
                
                outputs = model(images)
                loss = criterion(outputs.view(-1), labels)
                val_loss += loss.item() * images.size(0)
        val_loss = val_loss / len(val_loader.dataset)
        
        print(f"Epoch {epoch+1}/{num_epochs} | "
              f"Train Loss: {epoch_loss:.4f} | Val Loss: {val_loss:.4f}")
        
        # 保存最佳模型
        if val_loss < best_val_loss:
            best_val_loss = val_loss
            torch.save(model.state_dict(), "best_model.pth")
    
    print("Training complete. Best Val Loss: {:.4f}".format(best_val_loss))

# 开始训练
train_model(model, train_loader, val_loader, criterion, optimizer, num_epochs)

def predict(image_path, model, transform):
    model.eval()
    image = Image.open(image_path)
    image = transform(image).unsqueeze(0).to(device)  # 添加batch维度并移到GPU
    with torch.no_grad():
        prediction = model(image)
    return prediction.item()

# 加载最佳模型
model.load_state_dict(torch.load("best_model.pth", weights_only=True))

# Generate consecutive image IDs
image_ids = [f"{i:03d}" for i in range(1, 16)]
for img_id in image_ids:
    image_path = f"./验证集/validation_{img_id}.png"
    predicted_value = predict(image_path, model, transform)
    print(f"Predicted value for image_{img_id}.png: {predicted_value:.4f}")