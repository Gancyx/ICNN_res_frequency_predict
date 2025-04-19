# ICNN_res_frequency_predict 文件夹结构说明

## 根文件夹(CNN_image_model)

**code文件夹**：里面存储了ICNN模型训练的代码train.py

**data文件夹**：里面存储了数据集(image)及其对应的标签(label.csv)，用于训练模型

**MATLAB_CST文件夹**：里面存储了MATLAB调用CST联合仿真的代码，以及将一维的天线参数转换为二维的图像的代码

**data_generation.py**：该文件用于生成微带天线的四个输入参数：贴片长度、贴片宽度、基板厚度、基板介电常数。

**验证集文件夹**：用于对训练完成的模型进行测试，里面存储了15张图片

**Inputs_Parameters.csv**：该文件是由data_generation.py代码跑出来的结果，这个文件存储的就是刚才说的四个输入参数。

**验证集.csv**：该文件存储了测试集以及ICNN模型运行之后的结果。第一列内容为15组测试集的索引，第二列为谐振频率的目标值（Ground truth），第三列为ICNN模型运行之后的谐振频率预测值。

**resonant_frequency_calculate.py**：该文件夹用于计算矩形微带天线的谐振频率

## 输入参数

L_mm, W_mm, h_mm, eps_r = 12.6, 16.14, 1.32, 2.9

在代码中修改这四个参数，可以在终端显示出对应的谐振频率

## MATLAB_CST文件夹

**Input_parameter.csv**：这个文件是从根文件夹下直接复制过去的。

**input_parameter.mat**：当运行MATLAB_CST_simulation.m文件时调用这个mat文件，即这个mat文件存储的是数据，数据内容和Input_parameter.csv一模一样，但是MATLAB运行调用mat文件更加的方便，所以我就把csv文件中的内容完全复制到这mat文件中了。

**PatchAntenna.m**和**PatchAntenna_addtohistorylist.m**：这两个文件均是MATLAB调用CST对矩形微带天线进行仿真的代码，具体的资料是从下面这段视频中拿到的。

[【CST进阶之路——MATLAB-CST联合仿真（建模与仿真）】](https://www.bilibili.com/video/BV1U7411w7wk?vd_source=e1052a4f3ce339726e58346edc9d3d3f)

## data_procress文件夹

这个文件夹用于将一维的天线参数转换为二维的图像，由于归一化选取的是m=10位的二进制数字，因此转换完成的图片像素也就是$4 \times 10$。
![image](https://github.com/user-attachments/assets/d4bafdb8-a4f2-4ccf-a62f-e8c94f243133)


图 1 一个 $4 \times 10$ 图模型转换的例子

如果需要将一维参数转换为二维图形，运行这个文件夹中的data_procress.m文件，然后生成一个"dataset"文件夹，这个文件夹中的内容就是全部的数据集（图片）。然后需要将这个文件夹复制到根文件夹下，再修改名称为"image"，就可以用作训练数据了。

## 如何训练模型

首先说明点，训练模型的各个参数全部是参照**"Microstrip antenna modelling based on image-based convolutional neural network"**这篇论文中的内容

如果想要训练该模型，在基于Pytorch框架下直接运行"./code/train.py"文件即可。如下图所示

![image](https://github.com/user-attachments/assets/7468eb1a-6500-4d6e-b410-5ecd85389b8d)

## 环境依赖包

这个表格列举了创建的虚拟环境中每个包的版本：

```
(base) C:\WINDOWS\system32>activate py39
(py39) C:\WINDOWS\system32>pip list

Package                      Version
---------------------------- --------------
aiohappyeyeballs            2.4.4
aiohttp                     3.11.11
aiosignal                   1.3.2
alabaster                   0.7.16
antlr4-python3-runtime      4.9.3
anyio                       4.8.0
argon2-cffi                 23.1.0
argon2-cffi-bindings        21.2.0
arrow                       1.3.0
astroid                     3.3.8
asttokens                   3.0.0
async-lru                   2.0.4
async-timeout               5.0.1
asyncssh                    2.19.0
atomicwrites                1.4.1
attrs                       24.3.0
audioread                   3.0.1
autopep8                    2.0.4
babel                       2.16.0
backports.tarfile           1.2.0
beautifulsoup4              4.12.3
binaryornot                 0.4.4
black                       24.10.0
bleach                      6.2.0
certifi                     2024.12.14
cffi                        1.17.1
chardet                     5.2.0
charset-normalizer          3.4.1
click                       8.1.8
cloudpickle                 3.1.0
colorama                    0.4.6
comm                        0.2.2
contourpy                   1.3.0
cookiecutter                2.6.0
cryptography                44.0.0
cycler                      0.12.1
debugpy                     1.8.11
decorator                   5.1.1
defusedxml                  0.7.1
Deprecated                  1.2.15
diff-match-patch            20241021
dill                        0.3.9
docstring-to-markdown       0.15
docutils                    0.21.2
exceptiongroup              1.2.2
executing                   2.1.0
fastjsonschema              2.21.1
filelock                    3.16.1
flake8                      7.1.1
fonttools                   4.55.3
fqdn                        1.5.1
frozenlist                  1.5.0
fsspec                      2024.12.0
gpytorch                    1.13
h11                         0.14.0
httpcore                    1.0.7
httpx                       0.28.1
idna                        3.10
imagesize                   1.4.1
importlib_metadata          8.5.0
importlib_resources         6.5.2
inflection                  0.5.1
intervaltree                3.1.0
ipykernel                   6.29.5
ipython                     8.18.1
ipywidgets                  8.1.5
isoduration                 20.11.0
isort                       5.13.2
jaraco.classes              3.4.0
jaraco.context              6.0.1
jaraco.functools            4.1.0
jaxtyping                   0.2.19
jedi                        0.19.2
jellyfish                   1.1.3
Jinja2                      3.1.5
joblib                      1.4.2
json5                       0.10.0
jsonpointer                 3.0.0
jsonschema                  4.23.0
jsonschema-specifications   2024.10.1
julius                      0.2.7
jupyter                     1.1.1
jupyter_client              8.6.3
jupyter-console             6.6.3
jupyter_core                5.7.2
jupyter-events              0.11.0
jupyter-lsp                 2.2.5
jupyter_server              2.15.0
jupyter_server_terminals    0.5.3
jupyterlab                  4.3.4
jupyterlab_pygments         0.3.0
jupyterlab_server           2.27.3
jupyterlab_widgets          3.0.13
keyring                     25.6.0
kiwisolver                  1.4.7
lazy_loader                 0.4
librosa                     0.11.0
linear-operator             0.5.3
llvmlite                    0.43.0
markdown-it-py              3.0.0
MarkupSafe                  3.0.2
matplotlib                  3.9.4
matplotlib-inline           0.1.7
mccabe                      0.7.0
mdurl                       0.1.2
mistune                     3.1.0
more-itertools              10.5.0
mpmath                      1.3.0
msgpack                     1.1.0
multidict                   6.1.0
mypy-extensions             1.0.0
nbclient                    0.10.2
nbconvert                   7.16.5
nbformat                    5.10.4
nest-asyncio                1.6.0
networkx                    3.2.1
notebook                    7.3.2
notebook_shim               0.2.4
numba                       0.60.0
numpy                       2.0.2
numpydoc                    1.8.0
omegaconf                   2.3.0
overrides                   7.7.0
packaging                   24.2
pandas                      2.2.3
pandocfilters               1.5.1
parso                       0.8.4
pathspec                    0.12.1
pexpect                     4.9.0
pickleshare                 0.7.5
pillow                      11.1.0
pip                         24.3.1
platformdirs                4.3.6
pluggy                      1.5.0
pooch                       1.8.2
prometheus_client           0.21.1
prompt_toolkit              3.0.48
propcache                   0.2.1
psutil                      6.1.1
ptyprocess                  0.7.0
pure_eval                   0.2.3
pycodestyle                 2.12.1
pycparser                   2.22
pydocstyle                  6.3.0
pyflakes                    3.2.0
PyGithub                    2.5.0
Pygments                    2.19.1
PyJWT                       2.10.1
pylint                      3.3.3
pylint-venv                 3.0.4
pyls-spyder                 0.4.0
PyNaCl                      1.5.0
pyparsing                   3.2.1
PyQt5                       5.15.11
PyQt5-Qt5                   5.15.2
PyQt5_sip                   12.16.1
PyQtWebEngine               5.15.7
PyQtWebEngine-Qt5           5.15.2
python-dateutil             2.9.0.post0
python-json-logger          3.2.1
python-lsp-black            2.0.0
python-lsp-jsonrpc          1.1.2
python-lsp-server           1.12.0
python-slugify              8.0.4
pytoolconfig                1.3.1
pytz                        2024.2
pyuca                       1.2
pywin32                     308
pywin32-ctypes              0.2.3
pywinpty                    2.0.14
PyYAML                      6.0.2
pyzmq                       26.2.0
QDarkStyle                  3.2.3
qstylizer                   0.2.4
QtAwesome                   1.3.1
qtconsole                   5.6.1
QtPy                        2.4.2
referencing                 0.35.1
requests                    2.32.3
rfc3339-validator           0.1.4
rfc3986-validator           0.1.1
rich                        13.9.4
rope                        1.13.0
rpds-py                     0.22.3
Rtree                       1.3.0
scikit-learn                1.6.0
scipy                       1.13.1
Send2Trash                  1.8.3
setuptools                  75.6.0
six                         1.17.0
sniffio                     1.3.1
snowballstemmer             2.2.0
sortedcontainers            2.4.0
soundfile                   0.13.1
soupsieve                   2.6
soxr                        0.5.0.post1
Sphinx                      7.4.7
sphinxcontrib-applehelp     2.0.0
sphinxcontrib-devhelp       2.0.0
sphinxcontrib-htmlhelp      2.1.0
sphinxcontrib-jsmath        1.0.1
sphinxcontrib-qthelp        2.0.0
sphinxcontrib-serializinghtml 2.0.0
spyder                      6.0.3
spyder-kernels              3.0.2
stack-data                  0.6.3
superqt                     0.7.1
sympy                       1.13.1
tabulate                    0.9.0
terminado                   0.18.1
text-unidecode              1.3
textdistance                4.6.3
threadpoolctl               3.5.0
three-merge                 0.1.1
tinycss2                    1.4.0
tomli                       2.2.1
tomlkit                     0.13.2
torch                       2.5.0
torchsummary                1.5.1
torchvision                 0.20.0
tornado                     6.4.2
tqdm                        4.67.1
traitlets                   5.14.3
typeguard                   4.4.2
types-python-dateutil       2.9.0.20241206
typing_extensions           4.12.2
tzdata                      2024.2
ujson                       5.10.0
uri-template                1.3.0
urllib3                     2.3.0
watchdog                    6.0.0
wcwidth                     0.2.13
webcolors                   24.11.1
webencodings                0.5.1
websocket-client            1.8.0
whatthepatch                1.0.7
wheel                       0.45.1
widgetsnbextension          4.0.13
wrapt                       1.17.0
yapf                        0.43.0
yarl                        1.18.3
zipp                        3.21.0
```
