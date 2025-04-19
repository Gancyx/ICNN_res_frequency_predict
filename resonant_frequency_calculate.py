import numpy as np

c = 3e8  # 光速（米/秒）

# 输入参数
L_mm, W_mm, h_mm, eps_r = 12.6, 16.14, 1.32, 2.9

# 转换为米
h_m = h_mm * 1e-3
W_m = W_mm * 1e-3
L_m = L_mm * 1e-3

# 计算有效介电常数
eps_eff = (eps_r + 1)/2 + (eps_r - 1)/2 * (1 + 12*h_m/W_m)**(-0.5)

# 计算边缘场修正
delta_L_m = 0.412 * h_m * ((eps_eff + 0.3) * (W_m/h_m + 0.264))/ ((eps_eff - 0.258) * (W_m/h_m + 0.8))

# 考虑边缘效应的实际长度
L_eff_m = L_m + 2 * delta_L_m

# 反向计算谐振频率
# 公式：f_r = c/(2*L_eff*√ε_eff)
f_r_Hz = c / (2 * L_eff_m * np.sqrt(eps_eff))
f_r_GHz = f_r_Hz * 1e-9

print(f"谐振频率 f_r_GHz = {f_r_GHz:.4f} GHz")
print(f"有效介电常数 eps_eff = {eps_eff:.4f}")
print(f"边缘场修正 delta_L_mm = {delta_L_m*1e3:.4f} mm")
print(f"有效贴片长度 L_eff_mm = {L_eff_m*1e3:.4f} mm")

# 验证：用计算出的频率反向计算贴片尺寸
# W_m_verify = c / (2 * f_r_Hz) * np.sqrt(2 / (eps_r + 1))
# L_nom_m_verify = c / (2 * f_r_Hz * np.sqrt(eps_eff))
# L_m_verify = L_nom_m_verify - 2 * delta_L_m

# print(f"\n验证计算:")
# print(f"计算得到的宽度 W_mm = {W_m_verify*1e3:.4f} mm (原始输入: {W_mm} mm)")
# print(f"计算得到的长度 L_mm = {L_m_verify*1e3:.4f} mm (原始输入: {L_mm} mm)")