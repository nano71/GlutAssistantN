# GlutAssistantN / 桂工助手N
<img src="https://github.com/nano71/Images/blob/main/ic_launcher-playstore%20-%20副本.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/ic_launcher-playstore.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/ic_launcher-playstore2.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/logo2-01-01-01-01-01-01-01-01.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G1.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G2.png" width="72" /><img src="https://github.com/nano71/Images/blob/master/gan/G3.png" width="72" />

桂林理工大学空港校区(分校)专属的教务工具APP  
颜值很正常 , 拥有课表查询 , 成绩查询 , 获取考试列表  
课表自动导入 , 自动获取当前周 , 一次登录即保存状态

项目创建于: 2021/11/02 01:21

#### 下载安装:

[项目官网](https://nano71.com/gan)

[发布页面](https://github.com/nano71/GlutAssistantN/releases)

#### (过时的, 待更新)应用截图: (特别感谢莫格格)

<img src="https://github.com/nano71/Images/blob/master/gan/1FDB13A58E9C603B96581C589DAA2C4C.jpg" style="border:1px solid" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-02-10-15-35-19-01_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/248B069E4374DF049F28D97D510ADD6C.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/77DAB8345CA162F77C647CCE07A80E48.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/CE19BA7D42040C371385476E9D030581.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/E3A2AF93264ACD695475568DBBC6F86A.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/7E00784C2347C0982113E2BEAFF2ABF6.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/FF853B6193109699A0ABC6DD893F10BB.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/Screenshot_2022-02-10-15-44-27-02_581d685b5f7bb8d.jpg" width="192" /><img src="https://github.com/nano71/Images/blob/master/gan/51E157CEB422FD5398716ECFA3C4D71A.jpg" width="192" />

#### 目录结构:

```text
.
|-- images 图片资源
|   
|-- lib 主体
|   |-- main.dart 入口
|   |-- config.dart 配置项
|   |-- data.dart 必要的数据
|   |-- test.dart
|   |
|   |-- common 函数
|   |   |-- animation.dart 动画
|   |   |-- cookie.dart cookie
|   |   |-- day.dart 日期处理
|   |   |-- encode.dart 密码编码
|   |   |-- get.dart http请求
|   |   |-- homeWidget.dart 桌面微件
|   |   |-- init.dart 初始化
|   |   |-- io.dart 文件操作
|   |   |-- login.dart 登录
|   |   |-- noripple.dart 取消涟漪动画
|   |   |-- parser.dart html解析
|   |   |-- service.dart 后台服务
|   |   `-- style.dart 样式
|   |
|   |-- custom 自定义组件
|   |   `-- expansiontile.dart 折叠面板
|   |
|   |-- pages 页面
|   |   |-- about.dart 关于
|   |   |-- career.dart 生涯
|   |   |-- home.dart 主页
|   |   |-- layout.dart 主体
|   |   |-- login.dart 登录
|   |   |-- person.dart 个人
|   |   |-- queryClassRoom.dart 查询教室
|   |   |-- queryScore.dart 查询成绩
|   |   |-- queryExam.dart 查询考试
|   |   |-- schedule.dart 课表
|   |   |-- scheduleManager.dart 课表管理
|   |   |-- setting.dart 设置
|   |   |-- timeManager.dart 课时管理
|   |   `-- update.dart 更新
|   |
|   `-- widget 组件
|       |-- bars.dart 条
|       |-- cards.dart 卡片
|       |-- dialog.dart 弹出消息
|       |-- icons.dart 图标
|       `-- lists.dart 列表
|   
|-- README.md
|-- build.bat
|-- build.sh
|-- pubspec.yaml
```

#### 推荐环境：
Android SDK 26-35  
Gradle 8.11.1  
OpenJDK 17.0.8.1 2023-08-24  
Kotlin 2.3.0
Flutter 3.89.9  
Dart 3.10.8  

#### 编译项目:

```
flutter build apk --obfuscate --split-debug-info=xxx_Struggle --target-platform android-arm,android-arm64,android-x64 --split-per-abi
```

或者

```
// Windows使用
./bulid.bat  

// Linux使用
./bulid.sh 
```

#### 附言:

分校教务提供的东西太少 , 目前只能拿到这些 , UI也确实一言难尽 , 有空我再改改  
