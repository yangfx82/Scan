# 设备扫描管理系统

## 系统概述
本系统是一个在线服务，能够用手机浏览器访问，调用手机后置摄像头识别二维码，调用蓝牙打印机打印标签，向服务器发送JSON数据进行存储和管理。

## 主要功能

### 1. 识别当前用户
- 手机打开浏览器，访问该服务
- 获取当前手机号，如获取不到则弹出输入框输入手机号，作为当前用户名称
- 点击手机号可以切换用户或者填写新用户手机号
- 为连接用户提供唯一标识，记录用户的设备信息、配置信息（蓝牙打印设备默认连接）等

### 2. 扫码识别
- 调用手机后置摄像头识别二维码，使用Zxing.js本地库
- 二维码包含：计算机品牌、型号、序列号、CPU型号、内存大小、硬盘大小、显卡型号、网卡型号、主板型号、摄像头型号

二维码数据格式示例：
{"PC_Brand":"HP","PC_Model":"HP ProOne 600 G3 21.5-in Non-Touch AiO","SN":"JPH831NR40","CPU":"Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz","RAM":"16GB,16GB","HDD":"476.94GB","GPU":"OrayIddDriver Device,Intel(R) HD Graphics 530","NIC":"Intel(R) Ethernet Connection (5) I219-LM,Intel(R) Dual Band Wireless-AC 8265,Bluetooth Device (Personal Area Network),Hyper-V Virtual Ethernet Adapter","MB":"HP 82B5","CAM":"HP High Definition 1MP Webcam","CAM_Count":"1"}


- 数据处理规则：
  - 对于CPU、硬盘、显卡、网卡、摄像头等可能存在多个值的字段，识别到多条数据时，将所有值合并存入对应字段，用分号(;)隔开
  - 例如网卡字段值应为：`Intel(R) Ethernet Connection (5) I219-LM;Intel(R) Dual Band Wireless-AC 8265;Bluetooth Device (Personal Area Network);Hyper-V Virtual Ethernet Adapter`

- 识别成功后跳转到信息展示页面，该页面显示识别出的信息
- 页面包含按钮：
  - 附加信息：添加附加信息
    * 外观： 良好/轻微划痕/大划痕/外壳破损/屏轴损坏（良好/轻微划痕/大划痕/外壳破损为互斥项）
    * 键盘触控： US/JP/EU/掉键/键盘失灵/触控失灵（US/JP/EU为互斥项）
    * 电池：缺失/鼓包/不充电（缺失与其他项互斥）
    * 开机：掉电/光斑/黑点/老化/坏屏（光斑/黑点/老化 与 坏屏互斥）
  - 返回：返回扫码页面
  - 打印：调用蓝牙打印机打印标签
  - 确认：向服务器发送JSON数据


### 3. 蓝牙打印
- 扫描蓝牙打印设备、设置默认设备、当前默认设备
- 处理扫码识别的二维码内容，提取计算机型号、CPU型号、内存大小、硬盘大小、显卡型号、序列号
- 调用蓝牙打印机打印标签
- 标签格式：
  - 第一行：计算机型号
  - 第二行：CPU型号简写（如：i5-8）/内存大小（如：8G）/硬盘大小（如：256G）
  - 第三行：显卡型号
  - 第四行：序列号

### 4. 向服务器发送JSON数据
- 将JSON数据发送到服务器，包含当前用户名称、附加信息、识别出的信息、CPU简写
- 使用Node.js服务器技术，数据库采用SQlite
- 在接收数据时，根据CPU完整型号，生成CPU简写并存入数据库
- 数据库表名：computer_info
- 字段：
user_name
computer_brand
computer_model
serial_number
cpu_model
cpu_short
memory_size
disk_size
gpu_model
network_card_model
motherboard_model
camera_model
appearance  外观，数组
keyboard_touch  键盘触控，数组
battery  电池，数组
boot  开机，数组

CPU简写规则：
- AMD Ryzen处理器：使用R3-3作为简写，-后的数字为CPU数字型号的首位
- Intel的CPU：
  - i7-6700：-后面的数字，首位不为1，取首1位数作为CPU的代数
  - 首位为1，则取前两位为CPU代数
- 非Core i系列的CPU：
  - Celeron系列：统一简写Celeron
  - Pentium系列：统一简写Pentium
  - Atom系统：使用Atom
  - 其他：使用简写型号

### 5. 服务器返回响应
- 服务器接收到JSON数据后，返回响应：数据接收成功
- 手机端点击确认，提交数据获得服务器响应：
  - 成功：返回扫码页面
  - 超过3秒未响应：提示未成功提交数据，请重试
- 数据校验：
  - 计算机序列号为唯一标识
  - 检查数据库中是否已存在该序列号
  - 如存在，返回响应：数据已存在，弹出提示是否覆盖
  - 弹出页面包含两个按钮：确认、取消
  - 确认覆盖：等待服务器响应
  - 取消：返回扫码页面
  - 覆盖时，将旧数据迁移到info_old表中

### 6. 管理界面
- scanlist.html：查看所有数据(computer_info表)
  - 显示字段：序号、用户、品牌、型号、CPU、内存、硬盘、显卡、记录时间
  - 操作列：详情按钮
  - 详情弹窗：显示全部数据，自适应当前分辨率
  - 详情内容：用户、品牌、型号、CPU、内存、硬盘、显卡、网卡、序列号、主板、摄像头、附加信息、记录时间
  - 功能：刷新数据、导出数据（Excel格式，包含所有字段）
- history.html：查看历史数据（info_old表）
- 搜索功能：输入框内容+下拉选项复合搜索
  - 下拉选项：用户、品牌、型号、CPU、显卡、序列号、记录时间

## 技术要求
1. 前端：HTML5、JavaScript、CSS（使用Web API访问摄像头和蓝牙）
2. 后端：Node.js服务器技术，使用Https协议
3. 数据库：SQlite