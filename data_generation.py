import numpy as np
import pandas as pd

def generate_microstrip_data(num_samples):
    c = 3e8  # 光速（m/s）
    data = []
    
    for _ in range(num_samples):
        # --- 第1步：生成目标频率和基板参数 ---
        f_r_GHz = np.random.uniform(10, 30)
        f_r_Hz = f_r_GHz * 1e9
        
        # 基板参数：介电常数和厚度
        eps_r = np.random.uniform(2.2, 6.15)  # 介电常数（无量纲）
        h_mm = np.clip(np.random.lognormal(mean=np.log(1.0), sigma=0.5), 0.5, 2.0)  # 对数分布
        
        # --- 第2步：计算贴片宽度W ---
        # 公式：W = c/(2f_r) * sqrt(2/(eps_r+1)) （单位：米）
        W_m = c / (2 * f_r_Hz) * np.sqrt(2 / (eps_r + 1))
        W_mm = W_m * 1e3  # 转换为毫米
        
        # --- 第3步：计算有效介电常数ε_eff ---
        h_m = h_mm * 1e-3  # 基板厚度（米）
        eps_eff = (eps_r + 1)/2 + (eps_r - 1)/2 * (1 + 12*h_m/W_m)**(-0.5)
        
        # --- 第4步：计算贴片长度L ---
        # 公式：L = c/(2f_r√ε_eff) - 2ΔL （单位：米）
        L_nom_m = c / (2 * f_r_Hz * np.sqrt(eps_eff))
        
        # 边缘场修正ΔL（单位：米）
        delta_L_m = 0.412 * h_m * ((eps_eff + 0.3) * (W_m/h_m + 0.264))/ ((eps_eff - 0.258) * (W_m/h_m + 0.8))
        L_m = L_nom_m - 2 * delta_L_m
        
        # 转换为毫米并验证物理可行性
        L_mm = L_m * 1e3
        lambda0_mm = c / f_r_Hz * 1e3  # 自由空间波长（毫米）
        feasible = (L_mm > 0.1 * lambda0_mm) and (L_mm > 0)
        
        # --- 第5步：保存有效数据 ---
        if feasible:
            data.append([L_mm, W_mm, h_mm, eps_r, f_r_GHz])
    
    return data

# 生成数据并保存
sample_size = 200
data = generate_microstrip_data(sample_size)

df = pd.DataFrame(data, columns=["L (mm)", "W (mm)", "h (mm)", "eps_r", "f_r (GHz)"])
# 将前四列四舍五入到小数点后两位，第五列四舍五入到小数点后四位
df.iloc[:, :4] = df.iloc[:, :4].round(2)
df.iloc[:, 4] = df.iloc[:, 4].round(4)
df.to_csv("./MATLAB_CST/Input_Parameters.csv", index=False)
print(f"数据已保存至csv文件中")