# GlutAssistantN / 桂工助手N

桂林理工大学空港校区(分校)专属的教务工具APP  
颜值很正常 , 拥有课表查询 , 成绩查询 , 获取考试列表  
课表自动导入 , 自动获取当前周 , 一次登录即保存状态

项目创建于: 2021/11/02 01:21

#### 下载安装:

[酷安市场](https://www.coolapk.com/apk/289253)

[发布页面](https://github.com/nano71/GlutAssistantN/releases)

#### 应用图标:

<img src="https://github.com/nano71/Images/blob/master/gan/logo2-01-01-01-01-01-01-01-01.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G1.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G2.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G3.png" width="72" />

#### 应用截图: (特别感谢格格)

<img src="https://github.com/nano71/Images/blob/master/gan/a.jpg" style="border:1px solid" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-02-10-15-35-19-01_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/e.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-01-04-14-40-42-59_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-01-04-14-41-24-08_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-02-10-15-32-57-16_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-02-10-15-34-47-57_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-02-10-15-44-27-02_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/i.jpg" width="192" />

#### 更新日志:

[UPDATE LOG](https://github.com/nano71/GlutAssistantN/uploadLogs.md)

### 目录结构:

```text
.
|-- images 图片资源
|   |-- g.png
|   `-- g2.png
|   
|-- lib 主体
|   |-- main.dart 入口
|   |-- config.dart 常量
|   |-- data.dart 变量
|   |
|   |-- common 函数
|   |   |-- animation.dart
|   |   |-- cookie.dart
|   |   |-- get.dart
|   |   |-- init.dart
|   |   |-- io.dart
|   |   |-- login.dart
|   |   |-- noripple.dart
|   |   |-- parser.dart
|   |   `-- style.dart
|   |
|   |-- pages 页面
|   |   |-- career.dart
|   |   |-- home.dart
|   |   |-- info.dart
|   |   |-- init.dart
|   |   |-- login.dart
|   |   |-- mine.dart
|   |   |-- query.dart
|   |   |-- queryexam.dart
|   |   |-- queryroom.dart
|   |   |-- schedule.dart
|   |   |-- schedulemanage.dart
|   |   |-- setting.dart
|   |   |-- timemanage.dart
|   |   `-- update.dart
|   |
|   `-- widget 组件
|       |-- bars.dart
|       |-- cards.dart
|       |-- dialog.dart
|       |-- icons.dart
|       `-- lists.dart
|   
|-- README.md
|-- build.bat
|-- build.sh
|-- pubspec.lock
|-- pubspec.yaml
`-- updateLogs.md
```

#### 环境注意：

jdk_8  
dart_2.14.4  
flutter_2.5.3

#### 编译项目:

```
flutter build apk --obfuscate --split-debug-info=xxx_Struggle --target-platform android-arm,android-arm64,android-x64 --split-per-abi --no-sound-null-safety
```

或者

```
//Windows使用
./bulid.bat  

//Linux使用
./bulid.sh 
```

#### 附言:

分校教务提供的东西太少 , 只能取到这些了 , UI也确实一言难尽 , 有空我再改改  
