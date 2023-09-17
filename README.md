# GlutAssistantN / 桂工助手N

桂林理工大学空港校区(分校)专属的教务工具APP  
颜值很正常 , 拥有课表查询 , 成绩查询 , 获取考试列表  
课表自动导入 , 自动获取当前周 , 一次登录即保存状态

项目创建于: 2021/11/02 01:21

#### 下载安装:

[项目官网](https://nano71.com/gan)

[发布页面](https://github.com/nano71/GlutAssistantN/releases)

#### 应用图标:

<img src="https://github.com/nano71/GlutAssistantN/blob/master/images/ic_launcher-playstore.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/ic_launcher-playstore.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/logo2-01-01-01-01-01-01-01-01.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G1.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G2.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G3.png" width="72" />

#### (过时的, 待更新)应用截图: (特别感谢莫格格)

<img src="https://github.com/nano71/Images/blob/master/gan/1FDB13A58E9C603B96581C589DAA2C4C.jpg" style="border:1px solid" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-02-10-15-35-19-01_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/248B069E4374DF049F28D97D510ADD6C.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/77DAB8345CA162F77C647CCE07A80E48.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/CE19BA7D42040C371385476E9D030581.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/E3A2AF93264ACD695475568DBBC6F86A.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/7E00784C2347C0982113E2BEAFF2ABF6.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/FF853B6193109699A0ABC6DD893F10BB.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-02-10-15-44-27-02_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/51E157CEB422FD5398716ECFA3C4D71A.jpg" width="192" />

#### 更新日志:

[UPDATE LOG](https://github.com/nano71/GlutAssistantN/uploadLogs.md)

#### (过时的, 待更新)目录结构:

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
|   |   |-- queryscore.dart
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
|-- pubspec.yaml
`-- updateLogs.md
```

#### 环境注意：
Android SDK 26-33
Gradle 8.0
OpenJDK 17.0.8.1 2023-08-24
Flutter 3.13.4
Dart 3.1.2

#### 编译项目:

```
flutter build apk --obfuscate --split-debug-info=xxx_Struggle --target-platform android-arm,android-arm64,android-x64 --split-per-abi
```

或者

```
//Windows使用
./bulid.bat  

//Linux使用
./bulid.sh 
```

#### 附言:

分校教务提供的东西太少 , 目前只能拿到这些 , UI也确实一言难尽 , 有空我再改改  
