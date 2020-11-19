# Offline_Judge_for_cs101
 An offline judge system for python

非常欢迎Pull requests，欢迎Issue。

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