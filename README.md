# Offline_Judge_for_cs101
 An offline judge system for python

非常欢迎Pull requests，欢迎Issue。

##### 2020.12.6 ver0.5 change log:

Add partial MacOS support(imperfect)

Automatically create Settings.xml on Windows

Fixed some bugs

##### 2020.11.27 ver0.4 change log:

Add arbitrary executables support,you can judge

You can extend this by adding scripts and modify the Settings.xml

Multithread support,the main form no loger stop when judging

Add Drag&Drop support

##### 2020.11.19 ver0.3 change log:

Add a simplified output checkbox.

Fix some bugs.

Add about dialog.

##### 2020.11.17 ver0.2 change log:

Command prompt window no longer shows.

You can save output log now.

Re-designed GUI.

macOs compability.

##### 使用方法：

###### GUI：

第一栏选择Python解释器位置（如果能正常使用则不要选）

第二栏选择Python源代码

第三栏选择测试数据所在目录（in和out后缀名的文件，只扫描一层目录，也就是说文件夹里面的文件夹的数据不会被考虑）

之后点击Offline Judge按钮即可

###### 命令行：

写死了，第一个参数是Python源代码，第二个参数是测试数据所在目录，不可调换顺序。

##### 注意事项：

无论你在哪个操作系统上使用，无论你使用哪种语言，必须安装python解释器并设置好路径，否则程序不能正常运行。将来版本路径设置会被添加到Settings.xml中。脚本能够在Windows平台上正确运行，其他平台请自行修改脚本（主要是斜杠问题和解释器路径问题）。

##### 测试过的平台：

Windows 10 2004专业版，64位，支持

Windows 7旗舰版，64位，虚拟机，上个版本支持，此版本未经测试，应该支持

ReactOS，32位，虚拟机，支持

WindowsXP专业版，32位，虚拟机，上个版本不支持，此版本应该支持，但未测试

MacOS Catalina，虚拟机，部分支持（需要自行调整配置，且不支持给出verdict，只能重定向脚本输出，但是这足够用了）