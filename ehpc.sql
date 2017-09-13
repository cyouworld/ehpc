/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50628
Source Host           : localhost:3306
Source Database       : ehpc

Target Server Type    : MYSQL
Target Server Version : 50628
File Encoding         : 65001

Date: 2017-09-13 10:20:38
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `alembic_version`
-- ----------------------------
DROP TABLE IF EXISTS `alembic_version`;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of alembic_version
-- ----------------------------
INSERT INTO `alembic_version` VALUES ('7817e631ed63');

-- ----------------------------
-- Table structure for `apply`
-- ----------------------------
DROP TABLE IF EXISTS `apply`;
CREATE TABLE `apply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT '0',
  `course_id` int(11) DEFAULT '0',
  `status` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `apply_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `apply_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of apply
-- ----------------------------
INSERT INTO `apply` VALUES ('2', '3', '4', '0');
INSERT INTO `apply` VALUES ('3', '2', '4', '0');
INSERT INTO `apply` VALUES ('4', '3', '6', '0');
INSERT INTO `apply` VALUES ('5', '2', '1', '1');
INSERT INTO `apply` VALUES ('8', '3', '1', '1');
INSERT INTO `apply` VALUES ('13', '1', '1', '0');
INSERT INTO `apply` VALUES ('16', '15', '32', '1');
INSERT INTO `apply` VALUES ('18', '6', '32', '1');

-- ----------------------------
-- Table structure for `articles`
-- ----------------------------
DROP TABLE IF EXISTS `articles`;
CREATE TABLE `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `content` text NOT NULL,
  `visitNum` int(11) DEFAULT NULL,
  `updatedTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of articles
-- ----------------------------
INSERT INTO `articles` VALUES ('6', 'C++ 编译过程', '简单地说，一个编译器就是一个程序，它可以阅读以某一种语言（源语言）编写的程序，并把该程序翻译成一个等价的、用另一种语言（目标语言）编写的程序。\r\n\r\nC/C++编译系统将一个程序转化为可执行程序的过程包含：\r\n\r\n* 预处理(preprocessing)：根据已放置的文件中的预处理指令来修改源文件的内容。\r\n* 编译(compilation)：通过词法分析和语法分析，在确认所有指令都是符合语法规则之后，将其翻译成等价的中间代码表示或汇编代码。\r\n* 汇编(assembly)：把汇编语言代码翻译成目标机器指令的过程。\r\n* 链接(linking)：找到所有用到的函数所在的目标文件，并把它们链接在一起合成为可执行文件(executable file)。\r\n\r\n# 预处理\r\n\r\n预处理器是在程序源文件被编译之前根据预处理指令对程序源文件进行处理的程序。**预处理器指令以#号开头标识，末尾不包含分号**。预处理命令不是C/C++语言本身的组成部分，不能直接对它们进行编译和链接。C/C++语言的一个重要功能是可以使用预处理指令和具有预处理的功能。C/C++提供的预处理功能主要有文件包含、宏替换、条件编译等。\r\n\r\n## 文件包含\r\n\r\n预处理指令 #include 用于包含头文件，有两种形式：#include <xxx.h>，#include \"xxx.h\"。\r\n\r\n尖括号形式表示被包含的文件在系统目录中。如果被包含的文件不一定在系统目录中，应该用双引号形式。在双引号形式中可以指出文件路径和文件名。如果在双引号中没有给出绝对路径，则默认为用户当前目录中的文件，此时系统首先在用户当前目录中寻找要包含的文件，若找不到再在系统目录中查找。\r\n\r\n对于用户自己编写的头文件，宜用双引号形式。对于系统提供的头文件，既可以用尖括号形式，也可以用双引号形式，都能找到被包含的文件，但显然用尖括号形式更直截了当，效率更高。\r\n\r\n## 宏替换\r\n\r\n`宏定义`：一般用一个短的名字代表一个长的代码序列。宏定义包括无参数宏定义和带参数宏定义两类。宏名和宏参数所代表的代码序列可以是任何意义的内容，如类型、常量、变量、操作符、表达式、语句、函数、代码块等。\r\n\r\n宏定义在源文件中必须单独另起一行，换行符是宏定义的结束标志，因此宏定义以换行结束，不需要分号等符号作分隔符。如果一个宏定义中代码序列太长，一行不够时，可采用续行的方法。续行是在键入回车符之前先键入符号\\，注意回车要紧接在符号\\之后，中间不能插入其它符号，当然代码序列最后一行结束时不能有\\。\r\n\r\n预处理器在处理宏定义时，会对宏进行展开（即`宏替换`）。宏替换首先将源文件中在宏定义随后所有出现的宏名均用其所代表的代码序列替换之，如果是带参数宏则接着将代码序列中的宏形参名替换为宏实参名。宏替换只作代码字符序列的替换工作，不作任何语法的检查，也不作任何的中间计算，一切其它操作都要在替换完后才能进行。如果宏定义不当，错误要到预处理之后的编译阶段才能发现。\r\n\r\n## 条件编译\r\n\r\n一般情况下，在进行编译时对源程序中的每一行都要编译，但是有时希望程序中某一部分内容只在满足一定条件时才进行编译，如果不满足这个条件，就不编译这部分内容，这就是`条件编译`。\r\n\r\n条件编译主要是进行编译时进行有选择的挑选，注释掉一些指定的代码，以达到多个版本控制、防止对文件重复包含的功能。if, #ifndef, #ifdef, #else, #elif, #endif是比较常见条件编译预处理指令，可根据表达式的值或某个特定宏是否被定义来确定编译条件。\r\n\r\n此外，还有 #pragma 指令，它的作用是设定编译器的状态或指示编译器完成一些特定的动作。\r\n\r\n# 编译\r\n\r\n编译过程的第一个步骤称为词法分析（lexical analysis）或扫描（scanning），词法分析器读入组成源程序的字符流，并且将它们组织成有意义的词素的序列，对于每个词素，词法分析器产生一个词法单元（token），传给下一个步骤：语法分析。\r\n\r\n语法分析（syntax analysis）或解析（parsing）是编译的第二个步骤，使用词法单元来创建树形的中间表示，该中间表示给出了词法分析产生的词法单元流的语法结构。一个常用的表示方法是语法树（syntax tree），树中每个内部结点表示一个运算，而该结点的子结点表示该运算的分量。\r\n\r\n接下来是语义分析（semantic analyzer），使用语法树和符号表中的信息来检测源程序是否和语言定义的语义一致。\r\n\r\n在源程序的语法分析和语义分析之后，生成一个明确的低级的或者类机器语言的中间表示。接下来一般会有一个机器无关的代码优化步骤，试图改进中间代码，以便生成更好的目标代码。\r\n\r\n# 汇编\r\n\r\n对于被翻译系统处理的每一个C/C++语言源程序，都将最终经过这一处理而得到相应的目标文件。目标文件中所存放的也就是与源程序等效的目标机器语言代码。目标文件由段组成，通常一个目标文件中至少有两个段：代码段和数据段。\r\n\r\n* 代码段：该段中所包含的主要是程序的指令。该段一般是可读和可执行的，但一般却不可写。\r\n* 数据段：主要存放程序中要用到的各种全局变量或静态的数据。一般数据段都是可读，可写，可执行的。\r\n\r\n# 链接\r\n\r\n链接程序的主要工作就是将有关的目标文件彼此相连接，也即将在一个文件中引用的符号同该符号在另外一个文件中的定义连接起来，使得所有的这些目标文件成为一个能够按操作系统装入执行的统一整体。主要有静态链接和动态链接两种方式：\r\n\r\n* `静态链接`：在链接阶段，会将汇编生成的目标文件.o与引用到的库一起链接打包到可执行文件中，程序运行的时候不再需要静态库文件。\r\n* `动态链接`：把调用的函数所在文件模块（DLL）和调用函数在文件中的位置等信息链接进目标程序，程序运行的时候再从DLL中寻找相应函数代码，因此需要相应DLL文件的支持。  \r\n\r\n这里的库是写好的现有的，成熟的，可以复用的代码。现实中每个程序都要依赖很多基础的底层库，不可能每个人的代码都从零开始，因此库的存在意义非同寻常。本质上来说库是一种可执行代码的二进制形式，可以被操作系统载入内存执行。库有两种：静态库（.a、.lib）和动态库（.so、.dll），所谓静态、动态是指链接方式的不同。\r\n\r\n静态链接库与动态链接库都是**共享代码**的方式。如果采用静态链接库，程序在运行时与函数库再无瓜葛，移植方便。但是会浪费空间和资源，因为所有相关的目标文件与牵涉到的函数库被链接合成一个可执行文件。此外，静态库对程序的更新、部署和发布也会带来麻烦。如果静态库更新了，所有使用它的应用程序都需要重新编译、发布给用户。\r\n\r\n动态库在程序编译时并不会被连接到目标代码中，而是在程序运行是才被载入。不同的应用程序如果调用相同的库，那么在内存里只需要有一份该共享库的实例，规避了空间浪费问题。动态库在程序运行是才被载入，也解决了静态库对程序的更新、部署和发布页会带来麻烦。用户只需要更新动态库即可，增量更新。\r\n\r\n此外，还要注意静态链接库中不能再包含其他的动态链接库或者静态库，而在动态链接库中还可以再包含其他的动态或静态链接库。\r\n\r\n# 简单的例子\r\n\r\n下面是一个保存在文件 helloworld.cpp 中一个简单的 C++ 程序的代码：\r\n\r\n    /* helloworld.cpp */\r\n    #include <iostream>\r\n    int main(int argc,char *argv[])\r\n    {\r\n        std::cout << \"hello, world\" << std::endl;\r\n        return 0;\r\n    }\r\n\r\n用下面命令编译：\r\n\r\n    $ g++ helloworld.cpp\r\n\r\n编译器 g++ 通过检查命令行中指定的文件的后缀名可识别其为 C++ 源代码文件。编译器默认的动作：编译源代码文件生成对象文件(object file)，链接对象文件和 libstd c++ 库中的函数得到可执行程序，然后删除对象文件。由于命令行中未指定可执行程序的文件名，编译器采用默认的 a.out。\r\n\r\n## 预处理\r\n\r\n选项 -E 使 g++ 将源代码用编译预处理器处理后不再执行其他动作。下面的命令预处理源码文件 helloworld.cpp，并将结果保存在 .ii 文件中：\r\n\r\n    ➜  ~  g++ -E helloworld.cpp -o helloworld.ii\r\n    ➜  ~  ls | grep helloworld\r\n    helloworld.cpp\r\n    helloworld.ii\r\n    ➜  ~  wc -l helloworld.ii\r\n       38126 helloworld.ii\r\n\r\nhelloworld.cpp 的源代码，仅仅有六行，而且该程序除了显示一行文字外什么都不做，但是，预处理后的版本将超过3万行。这主要是因为头文件 iostream 被包含进来，而且它又包含了其他的头文件，除此之外，还有若干个处理输入和输出的类的定义。\r\n\r\n## 编译\r\n\r\n选项 -S 指示编译器将程序编译成汇编代码，输出汇编语言代码而后结束。下面的命令将由 C++ 源码文件生成汇编语言文件 helloworld.s，生成的汇编语言依赖于编译器的目标平台。\r\n\r\n    g++ -S helloworld.cpp\r\n\r\n## 汇编\r\n\r\n选项 -c 用来告诉编译器将汇编代码（.s文件，或者直接对源代码）转换为目标文件，但不要执行链接。输出结果为对象文件，文件默认名与源码文件名相同，只是将其后缀变为 .o。\r\n\r\n    ➜  ~  g++ -c helloworld.s\r\n    ➜  ~  ls |grep helloworld.o\r\n    helloworld.o\r\n\r\n\r\n## 链接\r\n\r\n加载相应的库，执行链接操作，将对象文件（.o，也可以直接将原文件）转化成可执行程序。\r\n\r\n    ➜  ~  g++ helloworld.o -o helloworld.o\r\n    ➜  ~  ./helloworld.o\r\n    hello, world\r\n\r\n\r\n# 更多阅读\r\n  \r\n[详解C/C++预处理器](http://blog.csdn.net/huang_xw/article/details/7648117)  \r\n[Compiling Cpp](http://wiki.ubuntu.org.cn/Compiling_Cpp)  \r\n[C++静态库与动态库](http://www.cnblogs.com/skynet/p/3372855.html)  \r\n[高级语言的编译：链接及装载过程介绍](http://tech.meituan.com/linker.html)    \r\n[编译原理 (预处理>编译>汇编>链接)](http://www.cnblogs.com/pipicfan/archive/2012/07/10/2583910.html)  \r\n\r\n', '59', '2016-10-21 00:00:00');
INSERT INTO `articles` VALUES ('13', '添加资讯测试', '\r\n# 轻松分享\r\n\r\n- 添加协作者，邀请小伙伴来一起协作\r\n- 你可以自行控制文档/表格的协作权限，只读/可写/私有，\r\n- 或协作或私密，由你一手掌控\r\n\r\n![石墨文档](https://assets-cdn.shimo.im/assets/images/home/personal/personal_qsfx-720ce6d09f.png)', '49', '2016-10-24 02:55:04');

-- ----------------------------
-- Table structure for `cases`
-- ----------------------------
DROP TABLE IF EXISTS `cases`;
CREATE TABLE `cases` (
  `id` int(64) NOT NULL AUTO_INCREMENT,
  `name` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `tag` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `icon` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Records of cases
-- ----------------------------
INSERT INTO `cases` VALUES ('1', '火灾模拟软件FDS的计算负载均衡优化', 'Fire dynamics simulator(FDS) 是一款用于处理火灾驱动的流体流动的开源计算流体力学CFD软件，广泛应用于建筑设计和消防安全等工程领域。FDS软件采用三维大涡模拟（Large Eddy Simulation），通过求解NS方程来分析燃烧过程中建筑内的温度场和流场的变化，但在此案例中，我们并不需要去关心具体求解过程。FDS软件支持MPI / OMP 的并行计算 , 但截止我们测试时，其公开版本（6.3.0）对MPI 并行计算有诸多限制:MPI 进程数必须少于其输入文件中的网格区域（MESH）数，并按照“前面的每个进程处理一个网格区域，最后一个进程处理剩余所有的网格区域”的方式来进行计算。这种模式使得FDS在HPC环境下直接使用难以发挥高性能计算集群的性能优势。\r\n\r\n![](/static/upload/md_images/20170108123846.png)\r\n\r\n![](/static/upload/md_images/20170108123900.png)\r\n\r\n为了能够在高性能计算环境下发挥FDS的并行计算能力，用户需要将模型切割成不同的MESH块。但一般情况下，用户建模是根据求解问题的几何特性来创建输入文件的MESH。这种建模方式导致了输入方式的各个MESH块中实际网格数量相差较大。\r\n\r\n为了能够使FDS的算例在超算上使用更大的节点规模，需要将大的MESH块拆分成小的MESH 块。通过拆分，可以提高MESH块的数量，从而提高算例的可用进程数，同时也降低了负载的不均衡性。此案例即要求用户尝试不同的切分方案来了解负载均衡对并行计算效率的影响。\r\n\r\n![](/static/upload/md_images/20170108123911.png)', '', '/static/upload/case/1.png');
INSERT INTO `cases` VALUES ('2', 'Jacobi迭代并行优化', 'Jacobi迭代是一种比较常见的迭代方法，具体来说，Jacobi迭代得到的新值是原来旧值点相邻数值点的平均。Jacobi迭代的局部性很好，可以取得很高的并行性，是并行计算中常见的一个例子。将参加迭代的数据按块分割后，各块之间除了相邻的元素需要通信外，在各块的内部可以完全独立地并行计算。随着计算规模的扩大，通信的开销相对于计算来说比例会降低，这将更有利于提高并行效果。Jacobi迭代的伪代码如下所示。\r\n\r\n```\r\nREAL A(N+1,N+1), B(N+1,N+1)\r\n\r\nDO K=1,STEP\r\n	DO J=1,N\r\n		DO I=1,N\r\n			B(I,J)=0.25*(A(I-1,J)+A(I+1,J)+A(I,J+1)+A(I,J-1))\r\n		END DO\r\n	END DO\r\n\r\n	DO J=1,N\r\n		DO I=1,N\r\n			A(I,J)=B(I,J)\r\n		END DO\r\n	END DO\r\nEND DO\r\n```\r\n\r\n为了并行求解Jacobi迭代，这里将参加迭代的数据按列进行分割，并假设一共有4个进程同时并行计算。数据的分割结果如下图所示。\r\n\r\n![](/static/upload/md_images/20170108122838.png)\r\n\r\n假设需要迭代的数据是M\\*M的二维数组A(M,M)，令M=4N，按下图所示进行数据划分，则分布在四个不同进程上的数据分别是： 进程0，A(M,1:N)、 进程1， A(M,N+1:2N)、进程2，A(M,2N+1:3N)、进程3，A(M,3N+1:M)。由于在迭代过程中，边界点新值的计算需要相邻边界其它块的数据，因此在每一个数据块的两侧又各增加1列的数据空间，用于存放从相邻数据块通信得到的数据 这样原来每个数据块的大小从MN扩大到M N+2，进程0和进程1的数据块只需扩大一块即可满足通信的要求，但这里为了编程的方便和形式的一致，在两边都增加了数据块。\r\n\r\n计算和通信过程是这样的，首先对数组赋初值，边界赋为8，内部赋为0，注意对不同的进程，赋值方式是不同的（两个内部块相同 但内部块和两个外部块两两互不相同）。然后，便开始进行Jacobi迭代，在迭代之前，每个进程都需要从相邻的进程得到数据块。同时，每一个进程也都需要向相邻的进程提供数据块（如下图所示）。由于每一个新迭代点的值是由相邻点的旧值得到，所以这里引入一个中间数组用来记录临时得到的新值，一次迭代完成后，再统一进行更新操作。\r\n\r\n![](/static/upload/md_images/20170106160515.png)', '', '/static/upload/case/2.png');
INSERT INTO `cases` VALUES ('3', '基于MPI的矩阵相乘Summa算法实现', '在科学与工程计算的许多问题中， 矩阵乘积是最基本的算法之一。经典的分布式矩阵乘积算法主要有1969年Cannon提出的二维mesh上的矩阵乘积算法和1987年Fox等提出的“广播-乘积-滚动”算法。1994年Choi等提出的PUMMA 算法将Fox 算法推广到二维块卷帘数据分布上。同年，Huss-Lederman等又将Fox算法推广到虚二维环绕数据分布。1995年van de Geijn 和Watts提出了一个简单而高效的矩阵乘积算法， 称为SUMMA 算法。\r\n\r\nSUMMA 算法首先将A, B和C划分为相同大小的矩阵，对应放在mesh_r × mesh_c的二维mesh上。但SUMMA 算法将矩阵乘法分解为一系列的秩nb 修正, 即各处理器中的A和B 分别被分解为nb 大小的列块和行块进行相乘，前面所说的分块尺寸就是指nb 的大小。算法中, 广播实现为逻辑处理器行环或列环上的流水线传送, 达到了计算与通信的重叠. 具体描述如下伪代码所示。\r\n\r\n```\r\nC= 0\r\nfor i= 0 t o k-1 step nb do\r\n　cur col = i×c/ n\r\n　cur row = i×r / m\r\n　if my col = cur rol 向本行广播A 从i mod (k/c) 列开始的nb 列, 存于A′\r\n　if my row = cur row 向本列广播B 从i mod (k/r) 行开始的nb 行, 存于B ′\r\n　C= A′×B ′\r\nend for\r\n```\r\n\r\nSUMMA算法的核心思想是：各处理器收集来自同一行处理器中A矩阵子块的所有列和同一列处理器中B矩阵子块的所有行，然后将行列相乘后累加，形成一个C矩阵的分块矩阵。最后由rank=0的处理器将其他处理器的数据收集起来，形成最终的矩阵C。SUMMA算法相较于cannon算法的优势只要体现在SUMMA算法能够计算m*l的A矩阵和l*n的B矩阵相乘（m、l、n可不相等），而cannon算法只能实现n*n的A矩阵和n*n的B矩阵相乘，具有很大的局限性。', '', '/static/upload/case/3.png');
INSERT INTO `cases` VALUES ('4', '图像连通区域标记并行算法', '图像连通域标记算法是从一幅栅格图像（通常为二值图像）中，将互相邻接（4邻接或8邻接）的具有非背景值的像素集合提取出来，为不同的连通域填入数字标记，并且统计连通域的数目。通过对栅格图像中进行连通域标记，可用于静态地分析各连通域斑块的分布，或动态地分析这些斑块随时间的集聚或离散，是图像处理非常基础的算法。目前常用的连通域标记算法有1）扫描法（二次扫描法、单向反复扫描法等）、2）线标记法、3）区域增长法。\r\n\r\n![](/static/upload/md_images/20170108122947.png)\r\n\r\n随着所要处理的数据量越来越大，使用传统的串行计算技术的连通域标记算法运行时间过长，难以满足实际应用的效率需求。随着并行计算技术的发展，利用不同的编程模型，许多数据密集型的计算任务可以被同时分配给单机多核或多机多处理器进行并行处理，从而有可能大幅度缩减计算时间，目前在集群计算领域广泛使用MPI来进行并行化。\r\n\r\n#### 一、二次扫描串行算法思想\r\n##### 1.1 第一次扫描\r\na）标记\r\n\r\nb）等价关系建立\r\n\r\n![](/static/upload/md_images/20170108122959.png)\r\n\r\n##### 1.2 第二次扫描\r\na）利用并查集链表进行标记更新。\r\n\r\n![](/static/upload/md_images/20170108123010.png)\r\n\r\n#### 二、并行化策略\r\n##### 2.1 数据划分\r\na）二次扫描的串行算法中，非直接相邻的各像元数据之间是无关的，将图像分割为数据块后，对于各个数据块之间的主体运算也是独立无关的，可并行性较高，因此可通过对图像进行分块来加快计算时间、提高计算效率。\r\n\r\n![](/static/upload/md_images/20170108123034.png)\r\n\r\n##### 2.2 并行算法步骤\r\na）各个进程分别使用串行算法计算\r\n\r\n![](/static/upload/md_images/20170108123047.png)\r\n\r\nb）各个进程将各块的标记值唯一化\r\n\r\n![](/static/upload/md_images/20170106163224.png)\r\n\r\nc）生成等价对数组\r\n\r\n![](/static/upload/md_images/20170106163347.png)\r\n\r\nd）主进程生成全局并查集链表\r\n将1到n-1进程中比较获得的等价对数组统一发送给0号进程，0号进程生成并查集链表。\r\n\r\n![](/static/upload/md_images/20170106164811.png)\r\n\r\ne）广播全局并查集链表，各进程更改标记值\r\n主进程广播全局并查集链表，各进程接收后更新标记值。\r\n\r\n![](/static/upload/md_images/20170106165304.png)', '', '/static/upload/case/4.png');
INSERT INTO `cases` VALUES ('5', '三维纵横波分离的弹性波方程模拟算法', '3D_EW（3D Elastic Wave Modeling）由中国石油东方地球物理公司自主研发，是用于石油勘探领域的真实应用。它是一种用波场延拓的方法来模拟弹性波在各向同性的弹性介质中传播的方法。在这个程序中，纵波（P 波）和横波（S 波）被分别模拟，这样可以更好地得知纵波和横波在弹性介质中的传递。该方法可以通过高阶有限差分方法来模拟弹性波的传递。其求解的方程为弹性波波动方程，如下：\r\n\r\n<img src=\"http://www.forkosh.com/mathtex.cgi? \\Large \\rho \\frac{\\partial^2 S}{\\partial t^2} = ( \\lambda  + \\mu  )\\triangledown \\theta  + \\mu \\triangledown^2 S\">\r\n\r\n#### 一、串行算法思想\r\n\r\n在输入数据并完成初始化工作后，程序进入 ishot 循环，也即计算不同震源的影响。对于不同的 ishot，计算任务完全独立，因而这里属于易并行问题。之后进入 l 循环，这里是时间推进方法，不同的 l 表示不同的时间步，前一次迭代的结果将会用于后一步的计算，因而不同的 l 之间存在极强的数据依赖。在 l 以内，则是不同网格的计算，对于显式格式的有限差分来说，不同网格的计算是完全独立的，因而这里也具备很强的并行性。\r\n\r\n算法基本流程如下：\r\n```\r\ninitialize the wave field in the 3D domain\r\nfor( ishot=0 ; ishot<nshot ; ishot+1)\r\n// different ishot means different source of ware\r\n{\r\n……\r\n	for(l=0 ;l<lt ; l++) // lt means time step\r\n	{\r\n	……\r\n	for i,j,k in x,y,z direction\r\n	{\r\n	compute P-wave and S-wave in each grid of the 3D domain\r\n……\r\n```\r\n\r\n#### 二、3D_EW 程序分析\r\n\r\n##### 2.1 热点分析\r\n\r\n由上述算法流程可以看出，3D_EW 程序结构相对简单，并没有复杂的函数调用，通过主要的计算都是在循环内，而 l 之间数据依赖，l 循环内部则是 kji 三层循环，在最内层的 i 循环中，仅有简单的加法和乘法运算，很显然，程序的热点即为 kji 循环内的计算。\r\n\r\n##### 2.2 代码分析\r\n\r\n对3D_EW 仔细阅读后，我们发现它由如下三个主要特点：\r\na) 程序并行性非常好\r\n最外层的 ishot 循环计算部分完全没有数据依赖，属于易并行问题；内层的 kji 循环在计算和写数据时也完全没有数据依赖，也属于易并行问题。因而整个程序具有非常良好的并行性，非常适合在超级计算机上并行实现。\r\n\r\nb) 内存访问存在大量的单元跨步访问（Unit Stride Access）\r\n在内层的 kji 循环中，在计算每个网格的物理量时，要读取周围5个点的数据以进行计算，x 方向上的数据读取时空间局部性较好，而在 y、z 方向上的跨步访问则地址跨度非常大。由于 KNC 的硬件无法隐藏 ache latency，因而这种数据读取方式对于 KNC 优化来说是非常不利的。\r\n\r\nc) 数据结构规则且负载均衡\r\n数据结构在高性能计算中的影响非常大。3D_EW 全部采用简单的数组结构，这对于并行编程来说是非常有利的。而且计算域是简单的3维立体拓扑结构，循环内几乎没有分支，虽然计算域是随着 l 的增加而增大，但是到 l 增大到一定层度使得计算域到达设定的边界时，每一次 l 迭代的计算量趋于稳定，而 kji 循环内的所有计算量几乎一致，因而整个程序的负载也非常均衡。\r\n\r\n#### 三、基于 CPU+MIC 集群平台的 3D_EW 并行算法设计与实现\r\n\r\n##### 3.1 基于 CPU+MIC 集群平台的 3D_EW 并行算法整体设计\r\n\r\n考虑到处理的数据及计算量庞大，我们使用 MPI+OpenMP 实现 3D_EW 程序在多节点异构平台的并行实现。其中，MPI 用于节点间并行，考虑到 ishot 循环计算完全独立，使用 MPI 并行将计算任务分配到不同的计算节点。而 OpenMP 用于节点内并行及处理器内向量化处理。对于 l 循环，由于数据依赖，无法并行，因而只能串行执行。而对于内层的 kji 循环，计算完全独立，我们使用 OpenMP 实现该计算的并行化。\r\n\r\n##### 3.2 基于CPU+MIC 集群平台的 3D_EW 并行算法实现\r\na) OpenMP 实现线程级并行\r\nOpenMP 是一种基于共享内存的并行编程标准。在使用 OpenMP 时，我们通过生成多个线程（thread）来使用现代处理器的多核系统，达到并行加速的效果。相对于多进程（process）的并行方法，OpenMP 的优势在于，线程级并行属于轻量级并行方法，所有线程共用一个存储空间，因而数据共享的开销比较小。因而对于节点内的并行非常适合用 OpenMP 。\r\n\r\n对于 3D_EW 程序，最外层的 ishot 循环不存在数据依赖，技术上也可以使用 OpenMP 并行，然而考虑到我们的并行还要基于多节点，而且对于不同的 ishot 要开辟独立的存储空间，这对于内存的压力非常大，因而我们使用 MPI 并行该循环，相关技术细节后续详细讲述。对于 l 循环，由我们前面所述，这个迭代过程前后数据依赖非常强，完全不适合并行，因而我们也不予考虑。对于 kji 循环，具有较好的并行性，且大部分计算量均在该循环，比较适合使用 OpenMP 。而最内层的 kk/kkk 循环则是 kji 循环内比较耗时的地方，虽然并行性也比较好，然而循环次数较少，每个循环只执行5次，不管对于多核的CPU还是众核的MIC，都不适合将其展开并行。综上，kji 循环是最适合使用 OpenMP 实现线程级并行的循环,我们最终决定在 kji 循环实现 OpenMP 并行。\r\n\r\n通过对 kji 循环内的代码仔细分析，发现里面计算是完全独立的，考虑到内层循环之后还要进行计算核心内的进一步优化（比如向量化计算），我们将 OpenMP 并行放在最外层的 k 循环外面。之前我们讲过 OpenMP 的一个优点在于它是轻量级并行方法，它的另一个优点是它的编程难度较低，程序员只需要在要并行的循环外面添加一些制导指令即可以实现并行。\r\n\r\nb) SIMD 实现数据级并行\r\nSIMD ( Single instruction, multiple data) 是一种数据级（data level）并行方式，是一种采用一个控制器来控制多个处理微元，同时对一组数据的每一个分别执行相同操作从而实现空间上的并行技术。现代许多基于高速缓存的处理器都支持 SIMD 操作的指令集。在我们使用的处理器中，Sandy Bridge 架构的 CPU 具有256bit宽度的向量处理器，而 MIC 的向量处理单元（VPU，vector processing unit）则支持512bit向量化处理。SIMD 技术的使用极大增加了程序的并行性能，以 MIC 为例，512bit 的VPU 能同时处理8个双精度数据/16个单精度数据。\r\n\r\n我们在实现 3D_EW 并行时对 CPU、MIC 部分的计算均使用了 SIMD 优化。由于这两个平台均基于x86架构，向量化的方法也比较类似，在要并行的代码前添加 “#pragma simd” 指令即可。\r\n\r\n由于SIMD 优化时处理单元基于相同的缓存系统，因而同一个 SIMD 处理器要处理的数据越密集、读取越规则，则越有利于获得更高的性能。在 3D_EW 程序中，处理的大部分数据是3维数组，而C程序是基于行存储的，源程序 kji 循环内数组的索引也是基于最内层 i 循环，因而对 i 循环进行了向量化处理。这样可以使得同一条 SIMD 指令处理的数据跨度更小，增加数据读写的空间局部性，更加高效地利用读写带宽。\r\n\r\n使用 SIMD 指令在 CPU 程序上能获得很好的加速效果，然而在基于 KNC 架构的 MIC 加速卡上性能却不理想。如我们前面所述，相对于 CPU，KNC 具有计算无法隐藏数据读取延迟的缺陷。对于 3D_EW 程序，其热点部分存在大量的单元跨步访问（Unit Stride Access），也即读取的数据存储非常分散，这导致在向量化后，VPU 读取数据时存在大量的 gather/scatter 操作，而这种操作对分散在各个 Cache Line 的数据采取逐个读入的方式，因而效率非常低。在实现中可以采用底层的编程指令集 C Intrinsic 来控制向量化的数据读取操作，从而有效减少了 gather/scatter 操作，使得 MIC 平台上程序性能获得了质的提升。除此以外，还可以在向量化时做数据对齐的优化。在 MIC 上开辟内存时使用 *mmmalloc* 语句可以保证数据对齐，这样可以将一个 Cache Line 的数据一次性读入向量寄存器。', '', '/static/upload/case/5.png');

-- ----------------------------
-- Table structure for `case_code_materials`
-- ----------------------------
DROP TABLE IF EXISTS `case_code_materials`;
CREATE TABLE `case_code_materials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version_id` int(11) NOT NULL,
  `name` varchar(1024) NOT NULL,
  `uri` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `version_id` (`version_id`),
  CONSTRAINT `case_code_materials_ibfk_1` FOREIGN KEY (`version_id`) REFERENCES `case_versions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of case_code_materials
-- ----------------------------
INSERT INTO `case_code_materials` VALUES ('1', '1', 'divBox.py', '');
INSERT INTO `case_code_materials` VALUES ('2', '1', 'FDSTool.py', '');
INSERT INTO `case_code_materials` VALUES ('3', '3', 'jacobiMain.f', '');
INSERT INTO `case_code_materials` VALUES ('4', '4', 'summa.c', '');

-- ----------------------------
-- Table structure for `case_versions`
-- ----------------------------
DROP TABLE IF EXISTS `case_versions`;
CREATE TABLE `case_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `case_id` int(11) NOT NULL,
  `version_id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `description` text NOT NULL,
  `dir_path` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `case_id` (`case_id`),
  CONSTRAINT `case_versions_ibfk_1` FOREIGN KEY (`case_id`) REFERENCES `cases` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of case_versions
-- ----------------------------
INSERT INTO `case_versions` VALUES ('1', '1', '1', '版本1', '数据采用一个实际用户的算例，由于需要计算的建筑较大较复杂，用户划分了34个MESH ，大小差异较大，总网格量40余万：\r\n\r\n测试过程只计算10s 的模拟时间（实际计算一般需要计算30min 的模拟时间）\r\n官网下载的二进制FDS程序，采用的是预编译的OpenMPI 通信库。 最多只能使用34个进程进行计算： 测试耗时450s\r\n使用系统MPI（MPICH3）编译的FDS程序\r\n34个进程耗时182s 。因使用系统的MPI编译才能发挥HPC计算环境的高速网络的性能，通过跨节点的并行计算来提高计算能力。\r\n通', '1/version_1');
INSERT INTO `case_versions` VALUES ('3', '2', '1', '版本1', '', '2/version_1');
INSERT INTO `case_versions` VALUES ('4', '3', '1', '版本1', '没有优化', '3/version_1');

-- ----------------------------
-- Table structure for `challenges`
-- ----------------------------
DROP TABLE IF EXISTS `challenges`;
CREATE TABLE `challenges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(1024) NOT NULL,
  `content` text NOT NULL,
  `knowledgeId` int(11) DEFAULT NULL,
  `knowledgeNum` int(11) DEFAULT NULL,
  `materialId` int(11) DEFAULT NULL,
  `source_code` text NOT NULL,
  `default_code` text,
  `task_number` int(11) DEFAULT '1',
  `cpu_number_per_task` int(11) DEFAULT '1',
  `node_number` int(11) DEFAULT '1',
  `language` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `knowledgeId` (`knowledgeId`),
  KEY `materialId` (`materialId`),
  CONSTRAINT `challenges_ibfk_1` FOREIGN KEY (`knowledgeId`) REFERENCES `knowledges` (`id`),
  CONSTRAINT `challenges_ibfk_2` FOREIGN KEY (`materialId`) REFERENCES `materials` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of challenges
-- ----------------------------
INSERT INTO `challenges` VALUES ('69', '第一个MPI程序', '这里以C语言为例开始你的第一个MPI程序！\n\n首先，我们应该先包含进一个头文件`<mpi.h>`，我们使用的函数都在其中。另外，在这之后，MPI程序和普通的C程序的区别在于有一个开始的函数和结束的函数来标识MPI部分，再在这个部分进行你想要进行的操作，现在就来尝试一下！\n\n虽然目前来说输出和普通程序没什么区别，但你已经走出了第一步！\n\n### 函数说明：\n\n```\nint MPI_Init(int *argc, char **argv)\n```\n\n通过MPI_Init函数进入MPI环境并完成所有的初始化工作，标志并行代码的开始。\n\n```\nint MPI_Finalize(void)\n```\n\n通过MPI_Finalize函数从MPI环境中退出，标志并行代码的结束，如果不是MPI程序最后一条可执行语句，则运行结果不可知。\n\n### 实验说明：\n\n使用MPI_Init函数和MPI_Finalize函数来标识出MPI部分，并简单地打印一句\"Hello World!\"，开始你的第一个MPI程序！', '5', '1', null, '#include <mpi.h>\n#include <stdio.h>\nint main(int argc, char **argv)\n{ \n    //your code here\n    MPI_Init(&argc, &argv); \n    //end of your code \n    \n    printf(\"Hello World!\"); \n    \n    //your code here \n    MPI_Finalize();\n    //end of your code \n    return 0;\n} ', '#include <mpi.h>\n#include <stdio.h>\nint main(int argc, char **argv)\n{ \n    //your code here\n    \n    //end of your code \n    \n    printf(\"Hello World!\"); \n    \n    //your code here \n    \n    //end of your code \n    return 0;\n} ', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('70', 'OpenMP介绍', '在C/C++中，OpenMP可以通过使用预处理指令来让程序并行化。OpenMP指令使用的格式为: \n\n```\n#pragma omp 指令 [子句[子句]…]\n```\n\n下面是一个最简单的OpenMP程序，可以运行后观察结果与普通程序有什么不同。\n\n请在适当的位置填上`#pragma omp parallel for` 使程序并行执行。\n*每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\ni = 2\ni = 0\ni = 6\ni = 1\ni = 8\ni = 5\ni = 4\ni = 7\ni = 9\ni = 3\n```', '6', '1', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for \r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 10; i++) {\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 10; i++) {\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('71', '获取进程数量', '在MPI编程中，我们常常需要获取指定通信域的进程个数，以确定程序的规模。\n\n一组可以相互发送消息的进程集合叫做通信子，通常由`MPI_Init()`在用户启动程序时，定义由用户启动的所有进程所组成的通信子，缺省值为 *MPI_COMM_WORLD* 。这个参数是MPI通信操作函数中必不可少的参数，用于限定参加通信的进程的范围。\n\n\n### 函数说明：\n\n```\nint MPI_Comm_size(MPI_Comm comm, int *rank)\n```\n\n获取指定通信域的进程个数。\n其中，第一个参数是通信子，第二个参数返回进程的个数。\n\n### 实验说明：\n使用函数MPI_Comm_size获取通信域中的进程个数并打印出来。', '5', '2', null, '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int numprocs;\r\n	MPI_Init(&argc, &argv);\r\n\r\n	//your code here\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	//end of your code\r\n\r\n	printf(\"Hello World! The number of processes is %d\\n\",numprocs);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int numprocs;\r\n	MPI_Init(&argc, &argv);\r\n\r\n	//your code here\r\n    \r\n	//end of your code\r\n\r\n	printf(\"Hello World! The number of processes is %d\\n\",numprocs);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('72', '获取进程id', '同样，我们也常常需要输出当前进程的id，以此来判断具体哪个进程完成了对应的任务。\n\n本章节同时也是对上一章节的强化复习。\n\n\n### 函数说明：\n\n```\nint MPI_Comm_rank(MPI_Comm comm, int *rank)\n```\n\n获得当前进程在指定通信域中的编号，将自身与其他程序区分。\n其中，第一个参数是通信子，第二个参数返回进程的编号。\n\n### 实验说明：\n\n在每个进程中，使用函数MPI_Comm_rank来获取当前进程的id并打印出来。\n\n### 输出结果：\n\n```\n0\n1\n3\n2\n```\n\n由于并行程序执行顺序的不确定性，你的结果的顺序可能和这个结果不一致。', '5', '3', null, '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Init(&argc, &argv);\r\n\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n	//your code here\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	//end of your code\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d\\n\", myid, numprocs);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Init(&argc, &argv);\r\n\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n\r\n	//your code here\r\n\r\n	//end of your code\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d\\n\", myid, numprocs);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('73', '消息传递', '在并行编程中，消息传递占了很大的比重。良好的消息传递是正常完成进程/节点之间操作的基本条件。在这里先介绍的最基本发送/接收函数。\n\n最基本的发送/接收函数都是以缓冲区作为端点，通过参数配置来完成指定操作。\n\n\n### 函数说明：\n\n```\nint MPI_Send(void* msg_buf_p, int msg_size, MPI_Datatype msg_type, int dest, int tag, MPI_Comm communicator)\n```\n\n发送缓冲区中的信息到目标进程。\n其中，\n```\nvoid* msg_buf_p ： 发送缓冲区的起始地址；\nint buf_size ： 缓冲区大小；\nMPI_Datatype msg_type ： 发送信息的数据类型；\nint dest ：目标进程的id值；\nint tag ： 消息标签；\nMPI_Comm communicator ： 通信子；\n```\n\n\n```\nint MPI_Recv(void* msg_buf_p, int buf_size, MPI_Datatype msg_type, int source, int tag, MPI_Comm communicator， MPI_Status *status_p)\n```\n\n发送缓冲区中的信息到目标进程。\n其中，\n```\nvoid* msg_buf_p ： 缓冲区的起始地址；\nint buf_size ： 缓冲区大小；\nMPI_Datatype msg_type ： 发送信息的数据类型；\nint dest ：目标进程的id值；\nint tag ： 消息标签；\nMPI_Comm communicator ： 通信子；\nMPI_Status *status_p ： status_p对象，包含实际接收到的消息的有关信息\n```\n\n### 实验说明：\n\n在这里我们把id为0的进程当作根进程，然后在除此之外的进程中使用函数MPI_Send发送一句\"hello world!\"到根进程中，然后在根进程中把这些信息打印出来。\n\n### 输出结果：\n\n一系列的\"hello world!\"。', '5', '6', null, '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs, source;\r\n	MPI_Status status;\r\n	char message[100];\r\n\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    if(myid != 0) {\r\n    	strcpy(message, \"hello world!\");\r\n    	\r\n    	//your code here\r\n    	MPI_Send(message, strlen(message)+1, MPI_CHAR, 0, 99, MPI_COMM_WORLD);\r\n    	//end of your code\r\n	}\r\n	else { //myid == 0\r\n		for(source=1; source<numprocs; source++) {\r\n			//your code here\r\n			MPI_Recv(message, 100, MPI_CHAR, source, 99, MPI_COMM_WORLD, &status);\r\n			//end of your code\r\n			\r\n			printf(\"%s\\n\", message);\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs, source;\r\n	MPI_Status status;\r\n	char message[100];\r\n\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    if(myid != 0) {\r\n    	strcpy(message, \"hello world!\");\r\n    	\r\n    	//your code here\r\n    	\r\n    	//end of your code\r\n	}\r\n	else { //myid == 0\r\n		for(source=1; source<numprocs; source++) {\r\n			//your code here\r\n			\r\n			//end of your code\r\n			\r\n			printf(\"%s\\n\", message);\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('74', '规约（reduce）', '在现实生活中，我们常常需要对于数据做同一种操作，并将结果返回到指定的进程中，这个过程称为集合通信。例如，将数据分散到各个进程中，先在各个进程内进行求和，再在全局完成求和-平均这个操作，这个过程是一个规约的过程。\n\n一般来说，集合通信包括通信、同步和计算三个功能。不过，目前我们暂时不需要关注整个过程，而是先使用一个规约函数去体验一下集合通信。\n\n\n### 函数说明：\n\n```\nint MPI_Reduce(void * input_data_p, void * output_data_p, int count, MPI_Datatype datatype, MPI_Op operator, int dest_process, MPI_Comm comm)\n```\n\n规约函数，所有进程将待处理数据通过输入的操作子operator计算为最终结果并将它存入目标进程中。 \n\n```\nvoid * input_data_p ： 每个进程的待处理数据存放在input_data_p中； \nvoid * output_data_p ： 存放最终结果的目标进程的地址；\nint count ： 缓冲区中的数据个数；\nMPI_Datatype datatype ： 数据项的类型；\nMPI_Op operator ： 操作子，例如加减；\nint dest_process ： 目标进程的编号；\n```\n\n### 实验说明：\n\n使用函数MPI_Reduce来完成加法规约到根进程的操作，并在根进程打印出总和和平均值。\n\n### 输出结果：\n由于这里是测试用例，所以每个进程的数值都是取3.0。所以，输出结果应该是总和等于进程数乘以3，平均值应该是3。', '5', '7', null, '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	double local_num = 3.0; \r\n\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    double global_num;\r\n    \r\n    //your code here\r\n    MPI_Reduce(&local_num, &global_num, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);\r\n    //end of your code\r\n    \r\n    if(myid == 0) {\r\n    	printf(\"Total sum = %f, avg = %f\\n\", global_num, global_num / numprocs);\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	double local_num = 3.0; \r\n\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    double global_num;\r\n    \r\n    //your code here\r\n    \r\n    //end of your code\r\n    \r\n    if(myid == 0) {\r\n    	printf(\"Total sum = %f, avg = %f\\n\", global_num, global_num / numprocs);\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('75', 'fork/join并行执行模式的概念', 'OpenMP是一套用于共享内存并行系统的多处理器程序设计的指导性的编译处理方案，从之前的介绍我们可以发现程序还是在循环结束之后才运行return 0语句，因此可以推断OpenMP并行执行的程序要全部结束后才会运行后面非并行部分的代码，这就是fork/join并行模式。以上结论可以从示例代码中体现。\n\n请在适当的位置填上`#pragma omp parallel for `使程序并行执行。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\nTime = 159\nTime = 161\nTotal time = 162\n```', '6', '2', null, '#include <stdio.h>\r\n#include <time.h>\r\n\r\nvoid foo()\r\n{\r\n	int cnt = 0;\r\n	clock_t t1 = clock();\r\n	int i;\r\n	for (i = 0; i < 1e8; i++) {\r\n		cnt++;\r\n	}\r\n	clock_t t2 = clock();\r\n	printf(\"Time = %d\\n\", t2 - t1);\r\n}\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	clock_t t1 = clock();\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for \r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 2; i++) {\r\n		foo();\r\n	}\r\n	clock_t t2 = clock();\r\n	printf(\"Total time = %d\\n\", t2 - t1);\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <time.h>\r\n\r\nvoid foo()\r\n{\r\n	int cnt = 0;\r\n	clock_t t1 = clock();\r\n	int i;\r\n	for (i = 0; i < 1e8; i++) {\r\n		cnt++;\r\n	}\r\n	clock_t t2 = clock();\r\n	printf(\"Time = %d\\n\", t2 - t1);\r\n}\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	clock_t t1 = clock();\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 2; i++) {\r\n		foo();\r\n	}\r\n	clock_t t2 = clock();\r\n	printf(\"Total time = %d\\n\", t2 - t1);\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('76', 'parallel 指令的用法', 'parallel 是构造并行块的一个指令，同时也可以配合其他指令如for, sections等指令一起使用。在这个指令后面需要使用一对大括号来指定需要并行计算的代码。\n```\n#pragma omp parallel [for | sections] [子句[子句]…] \n{ \n//并行部分 \n}\n```\n通过实例代码我们可以看出并行部分创建出了多个线程来完成。\n\n请在适当的位置填上`#pragma omp parallel num_threads(6)` 使程序并行执行。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\nThread: 0\nThread: 2\nThread: 1\nThread: 3\nThread: 4\nThread: 5\n```', '6', '3', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel num_threads(6) \r\n	// END OF YOUR CODE\r\n	{\r\n		printf(\"Thread: %d\\n\", omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	{\r\n		printf(\"Thread: %d\\n\", omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('77', 'for 指令的使用方法', 'for指令的作用是使一个for循环在多个线程中执行，一般for指令会与parallel指令同时使用，即parallel for指令。此外还可以在parallel指令的并行块中单独使用，在一个并行块中可以使用多个for指令。但是单独使用for指令是没有效果的。\n\n请在适当的位置使用for指令使程序并行执行。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n\n**运行结果**\n```\ni = 1\ni = 0\ni = 4\ni = 3\ni = 2\nj = 0\nj = 2\nj = 1\nj = 3\nj = 4\n```', '6', '4', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	#pragma omp parallel \r\n	{\r\n		// YOUR CODE HERE\r\n		#pragma omp for\r\n		// END OF YOUR CODE\r\n		for (int i = 0; i < 5; i++)\r\n			printf(\"i = %d\\n\", i);\r\n		// YOUR CODE HERE\r\n		#pragma omp for\r\n		// END OF YOUR CODE\r\n		for (int j = 0; j < 5; j++)\r\n			printf(\"j = %d\\n\", j);\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	#pragma omp parallel \r\n	{\r\n		// YOUR CODE HERE\r\n\r\n		// END OF YOUR CODE\r\n		for (int i = 0; i < 5; i++)\r\n			printf(\"i = %d\\n\", i);\r\n		// YOUR CODE HERE\r\n\r\n		// END OF YOUR CODE\r\n		for (int j = 0; j < 5; j++)\r\n			printf(\"j = %d\\n\", j);\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('78', 'sections和section指令的用法', 'sections语句可以将下面的代码分成不同的分块，通过section指令来指定分块。每一个分块都会并行执行，具体格式：\n#pragma omp [parallel] sections [子句] \n{\n#pragma omp section \n{\n	//代码\n}\n…\n}\n\n请在适当的位置填上使用sections指令使程序并行执行。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\nSection 2 ThreadId = 1\nSection 1 ThreadId = 0\nSection 4 ThreadId = 3\nSection 3 ThreadId = 2\n```', '6', '5', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel sections\r\n	// END OF YOUR CODE\r\n	{\r\n		#pragma omp section \r\n		printf(\"Section 1 ThreadId = %d\\n\", omp_get_thread_num());\r\n		#pragma omp section\r\n		printf(\"Section 2 ThreadId = %d\\n\", omp_get_thread_num());\r\n		#pragma omp section\r\n		printf(\"Section 3 ThreadId = %d\\n\", omp_get_thread_num());\r\n		#pragma omp section\r\n		printf(\"Section 4 ThreadId = %d\\n\", omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	{\r\n		#pragma omp section \r\n		printf(\"Section 1 ThreadId = %d\\n\", omp_get_thread_num());\r\n		#pragma omp section\r\n		printf(\"Section 2 ThreadId = %d\\n\", omp_get_thread_num());\r\n		#pragma omp section\r\n		printf(\"Section 3 ThreadId = %d\\n\", omp_get_thread_num());\r\n		#pragma omp section\r\n		printf(\"Section 4 ThreadId = %d\\n\", omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('79', '广播（broadcast）', '在一个集合通信中，如果属于一个进程的数据被发送到通信子中的所有进程，这样的集合通信叫做广播。\n\n这也是在现实中非常常用的功能。\n\n### 函数说明：\n\n```\nint MPI_Bcast(void* buffer, int count, MPI_Datatype datatype, int source, MPI_Comm comm)\n```\n\n广播函数，从一个id值为source的进程将一条消息广播发送到通信子内的所有进程,包括它本身在内。\n\n```\nvoid*　 buffer　　  缓冲区的起始地址； \nint　　　count　  　 缓冲区中的数据个数； \nMPI_Datatype datatype 　 缓冲区中的数据类型； \nint　　　source　  　　发送信息的进程id； \nMPI_Comm comm   　　 通信子； \n```\n\n### 实验说明：\n\n使用函数MPI_Bcast在根进程中发送一个数组到其他进程，并在其他进程中打印出来。\n\n### 输出结果：\n输出应该是这样的格式：\nIn process 1, arr[0]=1 arr[1]=2 arr[2]=3 arr[3]=4 arr[4]=5\nIn process 0, arr[0]=1 arr[1]=2 arr[2]=3 arr[3]=4 arr[4]=5\nIn process 3, arr[0]=1 arr[1]=2 arr[2]=3 arr[3]=4 arr[4]=5\n...\nIn process n, arr[0]=1 arr[1]=2 arr[2]=3 arr[3]=4 arr[4]=5\n...', '5', '8', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	int source = 0;\r\n	int array[5]={1,2,3,4,5};\r\n	int i;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    //your code here\r\n    MPI_Bcast(array, 5, MPI_INT, source, MPI_COMM_WORLD);\r\n    //end of your code\r\n    \r\n    if(myid != source) {\r\n    	printf(\"In process %d, \", myid);\r\n        for(i = 0; i < 5; i++)\r\n            printf(\"arr[%d]=%d\\t\", i, array[i]);\r\n        printf(\"\\n\");\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	int source = 0;\r\n	int array[5]={1,2,3,4,5};\r\n	int i;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    //your code here\r\n    \r\n    //end of your code\r\n    \r\n    if(myid != source) {\r\n    	printf(\"In process %d, \", myid);\r\n        for(i = 0; i < 5; i++)\r\n            printf(\"arr[%d]=%d\\t\", i, array[i]);\r\n        printf(\"\\n\");\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('80', '收集（gather）', '同样，有时候我们希望在一个进程中从所有进程获取信息，例如将所有进程中的一个数组都收集到根进程中作进一步的处理，这样的集合通信我们叫做收集。\n\n### 函数说明：\n\n```\nint MPI_Gather(void* sendbuf, int sendcount, MPI_Datatype sendtype, \n               void* recvbuf, int recvcount, MPI_Datatype recvtype, \n               int root, MPI_Comm comm)\n```\n\n收集函数，根进程（目标进程）从所有进程（包括它自己）收集发送缓冲区的数据，根进程根据发送这些数据的进程id将它们依次存放到自已的缓冲区中. \n\n```\nvoid* sendbuf    发送缓冲区的起始地址\nint sendcount    发送缓冲区的数据个数\nMPI_Datatype sendtype    发送缓冲区的数据类型\nvoid* recvbuf    接收缓冲区的起始地址\nint recvcount    待接收的元素个数\nMPI_Datatype recvtype    接收的数据类型\nint root    接收进程id \nMPI_Comm comm    通信子 \n```\n\n### 实验说明：\n\n使用函数MPI_Gather在根进程中从所有进程接收一个数组，并在根进程中打印出来。\n\n### 输出结果：\n输出应该是这样的格式：\nNow is process 1\'s data: arr[0]=1 arr[1]=2 arr[2]=3 arr[3]=4 arr[4]=5\nNow is process 4\'s data: arr[0]=1 arr[1]=2 arr[2]=3 arr[3]=4 arr[4]=5\nNow is process 2\'s data: arr[0]=1 arr[1]=2 arr[2]=3 arr[3]=4 arr[4]=5\n...\nNow is process n\'s data: arr[0]=1 arr[1]=2 arr[2]=3 arr[3]=4 arr[4]=5\n...', '5', '9', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	int dest = 0;\r\n	int array[5]={1,2,3,4,5};\r\n	int *rbuf; \r\n	int i,j;\r\n\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    if(myid == dest) {\r\n    	rbuf=(int *)malloc(numprocs*5*sizeof(int));\r\n	}\r\n\r\n	//your code here\r\n	MPI_Gather(array, 5, MPI_INT, rbuf, 5, MPI_INT, dest, MPI_WORLD_COMM);\r\n	//end of your code\r\n	\r\n	if(myid == dest) {\r\n		for(i=dest+1;i<numprocs;i++) {\r\n			printf(\"Now is process %d\'s data: \", i);\r\n			for(j=0;j<5;j++) {\r\n				printf(\"array[%d]=%d\\t\", j, rbuf[i*5+j]);\r\n			}\r\n			printf(\"\\n\");\r\n		}\r\n	}\r\n	\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	int dest = 0;\r\n	int array[5]={1,2,3,4,5};\r\n	int *rbuf; \r\n	int i,j;\r\n\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    if(myid == dest) {\r\n    	rbuf=(int *)malloc(numprocs*5*sizeof(int));\r\n	}\r\n\r\n	//your code here\r\n	\r\n	//end of your code\r\n	\r\n	if(myid == dest) {\r\n		for(i=dest+1;i<numprocs;i++) {\r\n			printf(\"Now is process %d\'s data: \", i);\r\n			for(j=0;j<5;j++) {\r\n				printf(\"array[%d]=%d\\t\", j, rbuf[i*5+j]);\r\n			}\r\n			printf(\"\\n\");\r\n		}\r\n	}\r\n	\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('81', '散发（scatter）', '在前面我们学习了收集（gather）操作，那么与之相对应也有一个相反的集合通信操作，即根进程向所有进程发送缓冲区的数据，称为散发。\n\n需要特别说明的是，散发操作和广播操作的区别在于发送到各个进程的信息可以是不同的。\n\n### 函数说明：\n\n```\nint MPI_Scatter(void* sendbuf, int sendcount, MPI_Datatype sendtype,\n                void* recvbuf, int recvcount, MPI_Datatype recvtype,\n                int root, MPI_Comm comm)\n```\n\nMPI_SCATTER是MPI_GATHER的逆操作，另外一种解释是根进程通过MPI_Send发送一条消息,这条消息被分成n等份,第i份发送给组中的第i个处理器, 然后每个处理器如上所述接收相应的消息。\n\n```\nvoid* sendbuf   发送缓冲区的起始地址\nint sendcount   发送的数据个数\nMPI_Datatype sendtype    发送缓冲区中的数据类型\nvoid* recvbuf     接收缓冲区的起始地址\nint recvcount  待接收的元素个数\nMPI_Datatype recvtype    接收的数据类型\nint root       发送进程id\nMPI_Comm comm       通信子 \n```\n\n### 实验说明：\n\n使用函数MPI_Scatter在根进程中向所有进程发送对应数组，并在对应进程中打印出来。\n\n### 输出结果：\n输出应该是这样的格式：\nNow is process 1: arr[0]=5 arr[1]=6 arr[2]=7 arr[3]=8 arr[4]=9\nNow is process 4: arr[0]=20 arr[1]=21 arr[2]=22 arr[3]=23 arr[4]=24\nNow is process 2: arr[0]=10 arr[1]=11 arr[2]=12 arr[3]=13 arr[4]=14\n...\nNow is process n: arr[0]=5*n arr[1]=5*n+1 arr[2]=5*n+2 arr[3]=5*n+3 arr[4]=5*n+4\n...', '5', '10', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	int source = 0;\r\n	int *sbuf;\r\n	int rbuf[5]; \r\n	int i;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    if(myid == source) {\r\n    	sbuf=(int *)malloc(numprocs*5*sizeof(int));\r\n    	\r\n    	for(int i=0;i<numprocs*5;i++) {\r\n    		sbuf[i]=i;\r\n		}\r\n	}\r\n\r\n    // your code here\r\n	MPI_Scatter(sbuf, 5, MPI_INT, rbuf, 5, MPI_INT, source, MPI_WORLD_COMM);\r\n	// end of your code\r\n	\r\n	printf(\"Now is process %d: \", myid);\r\n	for(i=0;i<5;i++) {\r\n		printf(\"array[%d]=%d\\t\", i, rbuf[i]);\r\n	}\r\n	printf(\"\\n\");\r\n	\r\n	\r\n	\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	int source = 0;\r\n	int *sbuf;\r\n	int rbuf[5]; \r\n	int i;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    if(myid == source) {\r\n    	sbuf=(int *)malloc(numprocs*5*sizeof(int));\r\n    	\r\n    	for(int i=0;i<numprocs*5;i++) {\r\n    		sbuf[i]=i;\r\n		}\r\n	}\r\n\r\n    // your code here\r\n	\r\n	// end of your code\r\n	\r\n	printf(\"Now is process %d: \", myid);\r\n	for(i=0;i<5;i++) {\r\n		printf(\"array[%d]=%d\\t\", i, rbuf[i]);\r\n	}\r\n	printf(\"\\n\");\r\n	\r\n	\r\n	\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('82', '运行时间', '在实际编程中，计时是一个很实用的功能。\n\n在MPI编程我们可以使用MPI_Wtime函数在并行代码中计算运行时间，用MPI_Wtick来查看精度。\n\n### 函数说明：\n\n```\ndouble MPI_Wtime(void)\n\ndouble MPI_Wtick(void)\n```\n\nMPI_WTIME返回一个用浮点数表示的秒数, 它表示从过去某一时刻到调用时刻所经历的时间。\n\nMPI_WTICK返回MPI_WTIME的精度，单位是秒，可以认为是一个时钟滴答所占用的时间。\n\n### 实验说明：\n\n使用函数MPI_Wtime计算并行代码的运行时间，并且在两次计算时间的函数之间用函数MPI_WTICK打印出精度。\n\n### 输出结果：\n\n输出结果格式应如下：\n\nThe precision is: 1e-06\nHello World!I\'m rank ... of ..., running ... seconds.\n\n', '5', '4', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	double start, finish;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n\r\n    MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n\r\n	//your code here\r\n	start = MPI_Wtime();\r\n	\r\n	printf(\"The precision is: %f\\n\", MPI_Wtick());\r\n	\r\n	finish = MPI_Wtime();\r\n	//your code here\r\n	\r\n	printf(\"Hello World!I\'m rank %d of %d, running %f seconds.\\n\", myid, numprocs, finish-start);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	double start, finish;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n\r\n    MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n\r\n	//your code here\r\n	\r\n	//your code here\r\n	\r\n	printf(\"Hello World!I\'m rank %d of %d, running %f seconds.\\n\", myid, numprocs, finish-start);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('83', '同步', '在实际工作中，我们常常会因为许多原因需要进行同步操作。\n\n例如，希望保证所有进程中并行代码在某个地方同时开始运行，或者在某个函数调用结束之前不能返回。\n\n这时候我们就需要使用到MPI_Barrier函数。\n\n### 函数说明：\n\n```\nint MPI_Barrier(MPI_Comm comm)\n\nMPI_Comm comm : 通信子；\n```\n\n阻止调用直到communicator中所有进程已经完成调用，就是说，任意一次进程的调用只能在所有communicator中的成员已经开始调用之后进行。\n\n### 实验说明：\n\n在计算运行时间的信息之前调用MPI_Barrier函数完成同步。\n\n### 输出结果：\n\n输出结果格式应如下：\n\nThe precision is: 1e-06\nHello World!I\'m rank ... of ..., running ... seconds.\n\n', '5', '5', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	double start, finish;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n\r\n    MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n\r\n	//your code here\r\n	MPI_Barrier(MPI_COMM_WORLD);\r\n	//end of your code\r\n	\r\n	start = MPI_Wtime();\r\n	\r\n	printf(\"The precision is: %f\\n\", MPI_Wtick());\r\n	\r\n	finish = MPI_Wtime();\r\n	\r\n	printf(\"Hello World!I\'m rank %d of %d, running %f seconds.\\n\", myid, numprocs, finish-start);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	double start, finish;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n\r\n    MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n\r\n	//your code here\r\n	\r\n	//end of your code \r\n	\r\n	start = MPI_Wtime();\r\n	\r\n	printf(\"The precision is: %f\\n\", MPI_Wtick());\r\n	\r\n	finish = MPI_Wtime();\r\n	\r\n	printf(\"Hello World!I\'m rank %d of %d, running %f seconds.\\n\", myid, numprocs, finish-start);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('84', 'private 子句的用法', 'private 子句可以将变量声明为线程私有，声明称线程私有变量以后，每个线程都有一个该变量的副本，线程之间不会互相影响，其他线程无法访问其他线程的副本。原变量在并行部分不起任何作用，也不会受到并行部分内部操作的影响。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\ni = 0\ni = 2\ni = 1\ni = 4\ni = 3\ni = 5\ni = 6\ni = 7\ni = 9\ni = 8\noutside i = 20\n```\n', '6', '6', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int i = 20;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for private(i)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	printf(\"outside i = %d\\n\", i);\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int i = 20;\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	printf(\"outside i = %d\\n\", i);\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('85', 'firstprivate子句的用法', 'private子句不能继承原变量的值，但是有时我们需要线程私有变量继承原来变量的值，这样我们就可以使用firstprivate子句来实现。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\nt = 20\nt = 21\nt = 23\nt = 24\nt = 22\noutside t = 20\n```\n', '6', '7', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int t = 20, i;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for firstprivate(t)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 5; i++)\r\n	{\r\n		t += i;\r\n		printf(\"t = %d\\n\", t);\r\n	}\r\n	printf(\"outside t = %d\\n\", t);\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int t = 20, i;\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 5; i++)\r\n	{\r\n		t += i;\r\n		printf(\"t = %d\\n\", t);\r\n	}\r\n	printf(\"outside t = %d\\n\", t);\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('86', 'lastprivate子句的用法', '除了在进入并行部分时需要继承原变量的值外，有时我们还需要再退出并行部分时将计算结果赋值回原变量，lastprivate子句就可以实现这个需求。\n需要注意的是，根据OpenMP规范，在循环迭代中，是最后一次迭代的值赋值给原变量；如果是section结构，那么是程序语法上的最后一个section语句赋值给原变量。\n如果是类(class)变量作为lastprivate的参数时，我们需要一个缺省构造函数，除非该变量也作为firstprivate子句的参数；此外还需要一个拷贝赋值操作符。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\nt = 20\nt = 22\nt = 24\nt = 21\nt = 23\noutside t = 24\n```\n', '6', '8', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int t = 20, i;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for firstprivate(t), lastprivate(t)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 5; i++)\r\n	{\r\n		t += i;\r\n		printf(\"t = %d\\n\", t);\r\n	}\r\n	printf(\"outside t = %d\\n\", t);\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int t = 20, i;\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 5; i++)\r\n	{\r\n		t += i;\r\n		printf(\"t = %d\\n\", t);\r\n	}\r\n	printf(\"outside t = %d\\n\", t);\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('87', 'threadprivate子句的用法', 'threadprivate子句可以将一个变量复制一个私有的拷贝给各个线程，即各个线程具有各自私有的全局对象。\n格式：\n#pragma omp threadprivate(list)\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\nthread id: 1 g: 1\nthread id: 5 g: 5\nthread id: 2 g: 2\nthread id: 3 g: 3\nthread id: 6 g: 6\nthread id: 4 g: 4\nthread id: 0 g: 0\nthread id: 7 g: 7\n```\n', '6', '9', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint g = 0;\r\n#pragma omp threadprivate(g)\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int t = 20, i;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel\r\n	// END OF YOUR CODE\r\n	{\r\n		g = omp_get_thread_num();\r\n	}\r\n	#pragma omp parallel\r\n	{\r\n		printf(\"thread id: %d g: %d\\n\", omp_get_thread_num(), g);\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint g = 0;\r\n#pragma omp threadprivate(g)\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int t = 20, i;\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	{\r\n		g = omp_get_thread_num();\r\n	}\r\n	#pragma omp parallel\r\n	{\r\n		printf(\"thread id: %d g: %d\\n\", omp_get_thread_num(), g);\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('88', 'shared子句的用法', 'Share子句可以将一个变量声明成共享变量，并且在多个线程内共享。需要注意的是，在并行部分进行写操作时，要求共享变量进行保护，否则不要随便使用共享变量，尽量将共享变量转换为私有变量使用。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\ni = 0, t = 21\ni = 2, t = 22\ni = 9, t = 23\ni = 4, t = 23\ni = 8, t = 25\ni = 5, t = 25\ni = 7, t = 24\ni = 1, t = 24\ni = 3, t = 24\ni = 6, t = 24\n```\n', '6', '10', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int t = 20, i;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for shared(t)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		if (i % 2 == 0)\r\n			t++;\r\n		printf(\"i = %d, t = %d\\n\", i, t);\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int t = 20, i;\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		if (i % 2 == 0)\r\n			t++;\r\n		printf(\"i = %d, t = %d\\n\", i, t);\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('89', '组的管理-创建（1）', '接下来我们将学习对组的管理。\n\n组是一个进程的有序集合，在实现中可以看作是进程标识符的一个有序集。组内的每个进程与一个整数rank相联系，序列号从0开始并且是连续的。我们可以在通信组中使用组来描述通信空间中的参与者并对这些参与者进行分级（这样在通信空间中为它们赋予了唯一的名字）。\n\n由此可见，组是我们对进程集合更高一级的抽象，我们可以在组的基础上对各个进程进行更进一步的操作，例如通过虚拟拓扑来辅助并行操作的实现。\n\n在这里我们先介绍两个特殊的预定义组，MPI_GROUP_EMPTY和MPI_GROUP_NULL。\n需要特别说明的是，前者是一个空组的有效句柄，可以在组操作中作为一个参数使用；而后者是一个无效句柄，在组释放时会被返回。\n\n现在我们可以开始学习第一个函数了。作为组管理的第一个小节，这个函数非常简单，是之后各个函数的基础。而本节重点是理解各个概念之间的关系。\n\n### 函数说明：\n\n```\nint MPI_Comm_group(MPI_Comm comm, MPI_Group *group)\n\nint MPI_Group_rank(MPI_Group group, int *rank)\n```\n\nMPI_Comm_group用来建立一个通信组对应的新进程组\n\nMPI_Group_rank查询调用进程在进程组里的rank\n\n### 实验说明：\n\n建立一个与初始通信子MPI_COMM_WORLD相联系的组，打印出当前进程在进程组的rank。\n\n### 输出结果：\n\n输出结果格式应如下：\nrank： 1\nrank： 0\n...\nrank： n\n\n顺序不唯一。', '5', '11', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Group group_world;\r\n	int rank_of_group;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	// your code here\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n	MPI_Group_rank(group_world, &rank_of_group);\r\n	// end of your code\r\n	\r\n	printf(\"rank: %d\\n\", rank_of_group);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Group group_world;\r\n	int rank_of_group;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	// your code here\r\n	\r\n	// end of your code\r\n	\r\n	printf(\"rank: %d\\n\", rank_of_group);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('90', '组的管理-创建（2）', '在上一节我们知道，可以用MPI_Comm_group函数来获得与通信组MPI_COMM_WORLD相关联的组句柄。\n那么我们可以用这个组句柄做什么呢？\n\n首先，我们可以通过这个最原始的组句柄来创建更多的、满足我们需要的组。\n\n在这里需要特别说明的是，MPI没提供凭空构造一个组的的机制，而只能从其它以前定义的组中构造。最基本的组是与初始通信子MPI_COMM_WORLD相联系的组（可通过函数MPI_COMM_GROUP获得〕，其它的组在该组基础上定义。\n\n### 函数说明：\n\n```\nint MPI_Group_incl(MPI_Group old_group, int count, int *members, MPI_Group *new_group)\n\nMPI_Group old_group ： 旧进程组；\nint count ： members数组中元素的个数；\nint *members ： 旧进程组中需要放入新进程组的进程的编号；\nMPI_Group *new_group ： 新进程组；\n```\n基于已经存在的进程组创建一个新的组，并指明被包含(included)其中的成员进程。\n\n### 实验说明：\n\n基于与初始通信子MPI_COMM_WORLD相联系的组创建一个新的组，这个新的组的成员是通信者MPI_COMM_WORLD的奇数编号的进程。\n\n### 输出结果：\n\n输出结果格式应如下：\nIn process n: odd rank is x\n...\n\n需要特别说明的是，如果在偶数编号的进程中，也就是不属于这个组的进程中输出这个值，MPI_Group_rank会返回MPI_UNDEFINED作为group_rank的值，表示它不是 worker_group的成员，在MPICH里是-32766。\n', '5', '12', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs, odd_rank;\r\n	MPI_Group group_world, odd_group;\r\n	int i;\r\n	int members[10];\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n\r\n	for(i=0; i<numprocs/2; i++) {\r\n		members[i] = 2*i+1 ;\r\n	}\r\n	\r\n	// your code here\r\n	MPI_Group_incl(group_world, numprocs/2, members, &odd_group);\r\n	// end of your code\r\n	\r\n	MPI_Group_rank(odd_group, &odd_rank);\r\n	\r\n	printf(\"In process %d: odd rank is %d\\n\", myid, odd_rank);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs, odd_rank;\r\n	MPI_Group group_world, odd_group;\r\n	int i;\r\n	int members[10];\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n\r\n	for(i=0; i<numprocs/2; i++) {\r\n		members[i] = 2*i+1 ;\r\n	}\r\n	\r\n	// your code here\r\n	\r\n	// end of your code\r\n	\r\n	MPI_Group_rank(odd_group, &odd_rank);\r\n	\r\n	printf(\"In process %d: odd rank is %d\\n\", myid, odd_rank);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('91', '组的管理-创建（3）', '同样，我们在基于旧进程组创建一个新的组的时候，可能希望排除一些成员进程。\n\n当然，我们可以通过选择出剩下的成员进程的方法来达成我们的目的，但是MPI提供了更好的办法去实现它。\n\n### 函数说明：\n\n```\nint MPI_Group_excl(MPI_Group old_group, int count, int *nonmembers, MPI_Group *new_group)\n\nMPI_Group old_group ： 旧进程组；\nint count ： nonmembers数组中元素的个数；\nint *nonmembers ： 旧进程组中不需要放入新进程组的进程的编号；\nMPI_Group *new_group ： 新进程组；\n```\n基于已经存在的进程组创建一个新的组，并指明不被包含(excluded)其中的成员进程。\n\n### 实验说明：\n\n基于与初始通信子MPI_COMM_WORLD相联系的组创建一个新的组，这个新的组的成员是通信者MPI_COMM_WORLD的偶数编号的进程。\n\n### 输出结果：\n\n输出结果格式应如下：\nIn process n: even rank is x\n...\n\n需要特别说明的是，如果在奇数编号的进程中，也就是不属于这个组的进程中输出这个值，MPI_Group_rank会返回MPI_UNDEFINED作为group_rank的值，表示它不是 worker_group的成员，在MPICH里这个值是-32766。\n', '5', '13', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs, even_rank;\r\n	MPI_Group group_world, even_group;\r\n	int i;\r\n	int nonmembers[10];\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n\r\n	for(i=0; i<numprocs/2; i++) {\r\n		members[i] = 2*i+1 ;\r\n	}\r\n	\r\n	// your code here\r\n	MPI_Group_excl(group_world, numprocs/2, nonmembers, &even_group);\r\n	// end of your code\r\n	\r\n	MPI_Group_rank(even_group, &even_rank);\r\n	\r\n	printf(\"In process %d: even rank is %d\\n\", myid, even_rank);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs, even_rank;\r\n	MPI_Group group_world, even_group;\r\n	int i;\r\n	int nonmembers[10];\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n\r\n	for(i=0; i<numprocs/2; i++) {\r\n		members[i] = 2*i+1 ;\r\n	}\r\n	\r\n	// your code here\r\n	\r\n	// end of your code\r\n	\r\n	MPI_Group_rank(even_group, &even_rank);\r\n	\r\n	printf(\"In process %d: even rank is %d\\n\", myid, even_rank);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('92', 'reduction子句的用法', 'reduction子句可以对一个或者多个参数指定一个操作符，然后每一个线程都会创建这个参数的私有拷贝，在并行区域结束后，迭代运行指定的运算符，并更新原参数的值。\n私有拷贝变量的初始值依赖于redtution的运算类型。\n具体用法如下\nreduction(operator:list)\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\n0\n2\n1\n5\n4\n5\n7\n6\n8\n9\nsum = 55\n```\n', '6', '11', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	\r\n	int i, sum = 10;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for reduction(+: sum)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		sum += i;\r\n		printf(\"%d\\n\", sum);\r\n	}\r\n	printf(\"sum = %ld\\n\", sum);\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	\r\n	int i, sum = 10;\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		sum += i;\r\n		printf(\"%d\\n\", sum);\r\n	}\r\n	printf(\"sum = %ld\\n\", sum);\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('93', 'copyin子句的用法', 'copyin子句可以将主线程中变量的值拷贝到各个线程的私有变量中，让各个线程可以访问主线程中的变量。\ncopyin的参数必须要被声明称threadprivate，对于类的话则并且带有明确的拷贝赋值操作符。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\nthread 0, g = 0\nthread 1, g = 1\nthread 2, g = 2\nthread 3, g = 3\nglobal g: 0\nthread 1, g = 0\nthread 2, g = 0\nthread 0, g = 0\nthread 3, g = 0\n```\n', '6', '12', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint g = 0;\r\n#pragma omp threadprivate(g) \r\nint main(int argc, char* argv[])\r\n{\r\n	int i;\r\n	#pragma omp parallel for   \r\n	for (i = 0; i < 4; i++)\r\n	{\r\n		g = omp_get_thread_num();\r\n		printf(\"thread %d, g = %d\\n\", omp_get_thread_num(), g);\r\n	}\r\n	printf(\"global g: %d\\n\", g);\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for copyin(g)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 4; i++)\r\n		printf(\"thread %d, g = %d\\n\", omp_get_thread_num(), g);\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint g = 0;\r\n#pragma omp threadprivate(g) \r\nint main(int argc, char* argv[])\r\n{\r\n	int i;\r\n	#pragma omp parallel for   \r\n	for (i = 0; i < 4; i++)\r\n	{\r\n		g = omp_get_thread_num();\r\n		printf(\"thread %d, g = %d\\n\", omp_get_thread_num(), g);\r\n	}\r\n	printf(\"global g: %d\\n\", g);\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 4; i++)\r\n		printf(\"thread %d, g = %d\\n\", omp_get_thread_num(), g);\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('94', 'static字句的用法', '当parallel for没有带schedule时，大部分情况下系统都会默认采用static调度方式。假设有n次循环迭代，t个线程，那么每个线程大约分到n/t次迭代。这种调度方式会将循环迭代均匀的分布给各个线程，各个线程迭代次数可能相差1次。用法为schedule(method)。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\ni = 0, thread 0\ni = 4, thread 2\ni = 1, thread 0\ni = 7, thread 5\ni = 8, thread 6\ni = 2, thread 1\ni = 9, thread 7\ni = 3, thread 1\ni = 5, thread 3\ni = 6, thread 4\n```\n', '6', '13', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int i;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for schedule(static)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		printf(\"i = %d, thread %d\\n\", i, omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int i;\r\n	// YOUR CODE HERE\r\n	\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		printf(\"i = %d, thread %d\\n\", i, omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('95', 'Size参数的用法', '在静态调度的时候，我们可以通过指定size参数来分配一个线程的最小迭代次数。指定size之后，每个线程最多可能相差size次迭代。可以推断出[0,size-1]的迭代是在第一个线程上运行，依次类推。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\ni = 6, thread 2\ni = 3, thread 1\ni = 4, thread 1\ni = 0, thread 0\ni = 5, thread 1\ni = 9, thread 3\ni = 1, thread 0\ni = 7, thread 2\ni = 2, thread 0\ni = 8, thread 2\n```\n', '6', '14', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int i;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for schedule(static, 3)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		printf(\"i = %d, thread %d\\n\", i, omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int i;\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		printf(\"i = %d, thread %d\\n\", i, omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('96', 'dynamic子句指令的用法', '动态分配是将迭代动态分配到各个线程，依赖于运行你状态来确定，所以我们无法像静态调度一样事先预计进程的分配。哪一个线程先启动，哪一个线程迭代多久，这些都取决于系统的资源和线程的调度。\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\ni = 0, thread 0\ni = 3, thread 3\ni = 8, thread 3\ni = 9, thread 7\ni = 2, thread 1\ni = 4, thread 4\ni = 5, thread 5\ni = 7, thread 0\ni = 1, thread 2\ni = 6, thread 6\n```\n', '6', '15', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int i;\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for schedule(dynamic)\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		printf(\"i = %d, thread %d\\n\", i, omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	int i;\r\n	// YOUR CODE HERE\r\n\r\n	// END OF YOUR CODE\r\n	for (i = 0; i < 10; i++)\r\n	{\r\n		printf(\"i = %d, thread %d\\n\", i, omp_get_thread_num());\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('97', '组的管理-相对编号', '在创建组之后，可能会有这个疑惑：如果知道了在组MPI_COMM_WORLD中某些进程的编号，如何根据这些编号来操作在不同组的同一进程来完成不同的任务呢？\n\nMPI提供了这样的函数以应付这种常见的情景。\n\n### 函数说明：\n\n```\nint MPI_Group_translate_ranks(MPI_Group group1, int count, int *ranks1, MPI_Group group2, int *ranks2)\n\nMPI_Group group1 ： 进程组1；\nMPI_Group group2 ： 进程组2；\nint count ： ranks1和ranks2数组中元素的个数；\nint *ranks1 ： 进程组1中有效编号组成的数组；\nint *ranks2 ： ranks1中的元素在进程组2中的对应编号\n```\n检测两个不同组中相同进程的相对编号。如果属于进程组1的某个进程可以在ranks1中找到，而这个进程不属于进程组2，则在ranks2中对应ranks1的位置返回值为MPI_UNDEFINED。\n\n### 实验说明：\n\n建立两个进程组，打印出进程组2中对应进程组1的进程的编号。\n\n### 输出结果：\n\n输出结果格式应如下：\nThe rank in group2 is: -32766\nThe rank in group2 is: 0\n...\n\n', '5', '15', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Group group_world, group1, group2;\r\n	int i;\r\n	int ranks1[10];\r\n	int ranks2[10];\r\n	int ranks_output[10];\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n\r\n	for(i=0; i<numprocs-1; i++) {\r\n		ranks1[i] = i ;\r\n		ranks2[i] = i+1 ;\r\n	}\r\n	\r\n	MPI_Group_incl(group_world, numprocs-1, ranks1, &group1);\r\n	MPI_Group_incl(group_world, numprocs-1, ranks2, &group2);\r\n	\r\n	// your code here\r\n	MPI_Group_translate_ranks(group1, numprocs-1, ranks1, group2, ranks_output);\r\n	// end of your code\r\n	\r\n	if (myid == 0) {\r\n		for (i=0; i<numprocs-1; i++) {\r\n			printf(\"The rank in group2 is: %d\\n\", ranks_output[i]);\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Group group_world, group1, group2;\r\n	int i;\r\n	int ranks1[10];\r\n	int ranks2[10];\r\n	int ranks_output[10];\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n\r\n	for(i=0; i<numprocs-1; i++) {\r\n		ranks1[i] = i ;\r\n		ranks2[i] = i+1 ;\r\n	}\r\n	\r\n	MPI_Group_incl(group_world, numprocs-1, ranks1, &group1);\r\n	MPI_Group_incl(group_world, numprocs-1, ranks2, &group2);\r\n	\r\n	// your code here\r\n	\r\n	// end of your code\r\n	\r\n	if (myid == 0) {\r\n		for (i=0; i<numprocs-1; i++) {\r\n			printf(\"The rank in group2 is: %d\\n\", ranks_output[i]);\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('98', '组的管理-释放', '既然有了组的构造，那么与之对应也存在组的析构。\n\n### 函数说明：\n\n```\nint MPI_Group_free(MPI_Group *group)\n\n```\n\n调用函数会标记一个被释放的组对象，组句柄被调用置为MPI_GROUP_NULL。\n任何正在使用此组的操作将正常完成。\n\n### 实验说明：\n\n建立一个进程组，打印出它的size，然后释放它。\n\n### 输出结果：\n\n输出结果格式应如下：\nNow the size is n\nNow the group is freed.\n\n', '5', '16', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Group group_world;\r\n	int size0;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n	\r\n	MPI_Group_size(group_world, &size0);\r\n	\r\n	if(myid == 0) {\r\n		printf(\"Now the size is %d\\n\", size0);\r\n	}\r\n	\r\n	// your code here\r\n	MPI_Group_free(&group_world);\r\n	// end of your code\r\n	\r\n	if(myid == 0) {\r\n		if (group_world == MPI_GROUP_NULL)\r\n			printf(\"Now the group is freed.\\n\");\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Group group_world;\r\n	int size0;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n	\r\n	MPI_Group_size(group_world, &size0);\r\n	\r\n	if(myid == 0) {\r\n		printf(\"Now the size is %d\\n\", size0);\r\n	}\r\n	\r\n	// your code here\r\n	\r\n	// end of your code\r\n	\r\n	if(myid == 0) {\r\n		if (group_world == MPI_GROUP_NULL)\r\n			printf(\"Now the group is freed.\\n\");\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('99', '组的管理-比较', '有时候我们想要对两个进程组做最基本的判断，例如成员是否相同，次序是否一致等等。\n\nMPI同样提供了这样的函数来完成这个功能。\n\n### 函数说明：\n\n```\nint MPI_Group_compare(MPI_Group group1, MPI_Group group2, int *result)\n\nMPI_Group group1 ： 要比较的组1；\nMPI_Group group2 ： 要比较的组2；\nint *result：结果；\n```\n如果在两个组中成员和次序完全相等，返回MPI_IDENT。例如在group1和group2是同一句柄时就会发生这种情况。如果组成员相同而次序不同则返回MPI_SIMILAR，否则返回MPI_UNEQUAL。\n\n### 实验说明：\n\n创建一个新的组，通过调整输出两个不同的结果。\n\n### 输出结果：\n\n输出结果格式应如下：\nNow the groups are identical.\nNow the groups are unequal.\n...', '5', '14', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Group group_world， new_group_world;\r\n	int members[5];\r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n	\r\n	members[0] = 0 ;\r\n	\r\n	MPI_Group_incl(group_world, 1, members, &new_group_world);\r\n	\r\n	if(myid == 0) {\r\n		// your code here\r\n		MPI_Group_compare(group_world, group_world, &result);\r\n		// end of your code\r\n		\r\n		if (result == MPI_IDENT) {\r\n			printf(\"Now the groups are identical.\\n\");\r\n		}\r\n		else if (result == MPI_SIMILAR) {\r\n			printf(\"Now the groups are similar.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Now the groups are unequal.\\n\");\r\n		}\r\n		\r\n		// your code here\r\n		MPI_Group_compare(group_world, new_group_world, &result);\r\n		// end of your code\r\n		\r\n		if (result == MPI_IDENT) {\r\n			printf(\"Now the groups are identical.\\n\");\r\n		}\r\n		else if (result == MPI_SIMILAR) {\r\n			printf(\"Now the groups are similar.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Now the groups are unequal.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Group group_world， new_group_world;\r\n	int members[5];\r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n	\r\n	members[0] = 0 ;\r\n	\r\n	MPI_Group_incl(group_world, 1, members, &new_group_world);\r\n	\r\n	if(myid == 0) {\r\n		// your code here\r\n		\r\n		// end of your code\r\n		\r\n		if (result == MPI_IDENT) {\r\n			printf(\"Now the groups are identical.\\n\");\r\n		}\r\n		else if (result == MPI_SIMILAR) {\r\n			printf(\"Now the groups are similar.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Now the groups are unequal.\\n\");\r\n		}\r\n		\r\n		// your code here\r\n		\r\n		// end of your code\r\n		\r\n		if (result == MPI_IDENT) {\r\n			printf(\"Now the groups are identical.\\n\");\r\n		}\r\n		else if (result == MPI_SIMILAR) {\r\n			printf(\"Now the groups are similar.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Now the groups are unequal.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('100', '通信子的管理-创建', '在实际开发中，我们往往需要很多不同的通信子来满足需求，这时候就需要创建新的通信子。\n\n### 函数说明：\n\n```\nint MPI_Comm_create(MPI_Comm comm, MPI_Group group, MPI_Comm *newcomm)\n\nMPI_Comm comm ： 旧的通信子；\nMPI_Group group ： 与comm相关联的组或其子集；\nMPI_Comm *newcomm ： 新的通信子；\n```\n用由group所定义的通信组及一个新的上下文创建了一个新的通信子newcomm。对于不在group中的进程，函数返回MPI_COMM_NULL。\n\n### 实验说明：\n\n复制一个新的通信子，并以此为基础创建一个新的通信子。由于示例是用奇数编号的进程来创建通信子的，所以只在奇数进程中输出结果。\n\n### 输出结果：\n\n输出结果格式应如下：\nThe new comm\'s size is 2.\nThe new comm\'s size is 2.\n...', '5', '18', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs, new_numprocs;\r\n	MPI_Group group_world, odd_group;\r\n	MPI_Comm new_comm;\r\n	int i;\r\n	int members[10];\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n\r\n	for(i=0; i<numprocs/2; i++) {\r\n		members[i] = 2*i+1 ;\r\n	}\r\n	\r\n	MPI_Group_incl(group_world, numprocs/2, members, &odd_group);\r\n	\r\n	// your code here\r\n	MPI_Comm_create(MPI_COMM_WORLD, odd_group, &new_comm);\r\n	// end of your code\r\n	\r\n	if (myid % 2 ！= 0 ) {\r\n	    MPI_Comm_size(new_comm, &new_numprocs);\r\n	    \r\n		printf(\"The new comm\'s size is %d.\\n\", new_numprocs);\r\n	} \r\n	\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs, new_numprocs;\r\n	MPI_Group group_world, odd_group;\r\n	MPI_Comm new_comm;\r\n	int i;\r\n	int members[10];\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_group(MPI_COMM_WORLD, &group_world);\r\n\r\n	for(i=0; i<numprocs/2; i++) {\r\n		members[i] = 2*i+1 ;\r\n	}\r\n	\r\n	MPI_Group_incl(group_world, numprocs/2, members, &odd_group);\r\n	\r\n	// your code here\r\n	\r\n	// end of your code\r\n	\r\n	if (myid % 2 ！= 0 ) {\r\n	    MPI_Comm_size(new_comm, &new_numprocs);\r\n	    \r\n		printf(\"The new comm\'s size is %d.\\n\", new_numprocs);\r\n	} \r\n	\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('101', '通信子的管理-复制', '在之前的学习中，我们经常使用系统帮助我们创建的初始组内通信子MPI_COMM_WORLD作为通信子的输入。\n\n其实，还有两个系统默认创建的通信子，一个是COMM_SELF，另一个是COMM_NULL。\nCOMM_SELF仅仅包含了当前进程，而COMM_NULL则什么进程都没有包含。\n\n在通信子的创建中，需要特别注意的是MPI中有一个\"鸡生蛋, 蛋生鸡\"的特点，即所有MPI通信子的创建都是由基础通信子，即MPI_COMM_WORLD（是在MPI的外部被定义的），创建的。而这些被创建的通信子又可以作为新的通信子创建的基础。\n\n这个模型是经过讨论后确定的，目的是为了提高用MPI写程序的安全性。\n\n### 函数说明：\n\n```\nint MPI_Comm_dup(MPI_Comm comm,MPI_Comm *newcomm)\n\nMPI_Comm comm ： 旧的通信子；\nMPI_Comm *newcomm ： 新的通信子；\n```\n复制已存在的通信子comm。\n\n### 实验说明：\n\n复制一个新的通信子，需要特别说明的是，结果显示MPI_IDENT表示上下文(context)和组(group)都相同，MPI_CONGRUENT表示上下文不同(different)但组完全相同(identical)，MPI_SIMILAR表示上下文不同，组的成员相同但次序不同(similar)，否则就是MPI_UNEQUAL。\n\n### 输出结果：\n\n输出结果格式应如下：\nThe comms are congruent.\n...', '5', '17', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm; \r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    // your code here\r\n	MPI_Comm_dup(MPI_COMM_WORLD, &new_comm);\r\n	// end of your code\r\n		\r\n	MPI_Comm_compare(MPI_COMM_WORLD, new_comm, &result);\r\n	\r\n	if(myid == 0) {\r\n		\r\n		if ( result == MPI_IDENT) {\r\n			printf(\"The comms are identical.\\n\");\r\n		}\r\n		else if ( result == MPI_CONGRUENT ) {\r\n			printf(\"The comms are congruent.\\n\");\r\n		}\r\n		else if ( result == MPI_SIMILAR ) {\r\n			printf(\"The comms are similar.\\n\");\r\n		}\r\n		else if ( result == MPI_UNEQUAL ) {\r\n			printf(\"The comms are unequal.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm; \r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n    \r\n    // your code here\r\n	\r\n	// end of your code\r\n		\r\n	MPI_Comm_compare(MPI_COMM_WORLD, new_comm, &result);\r\n	\r\n	if(myid == 0) {\r\n		\r\n		if ( result == MPI_IDENT) {\r\n			printf(\"The comms are identical.\\n\");\r\n		}\r\n		else if ( result == MPI_CONGRUENT ) {\r\n			printf(\"The comms are congruent.\\n\");\r\n		}\r\n		else if ( result == MPI_SIMILAR ) {\r\n			printf(\"The comms are similar.\\n\");\r\n		}\r\n		else if ( result == MPI_UNEQUAL ) {\r\n			printf(\"The comms are unequal.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('102', '通信子的管理-释放', '同样，通信子也存在析构的操作。\n\n### 函数说明：\n\n```\nint MPI_Comm_free(MPI_Comm *comm)\n\nMPI_Comm *comm ： 通信子；\n```\n用由group所定义的通信组及一个新的上下文创建了一个新的通信子newcomm。对于不在group中的进程，函数返回MPI_COMM_NULL。\n\n### 实验说明：\n\n这是一个标志通信对象撤消的集合操作。值得注意的是，这个函数操作只是将句柄置为MPI_COMM_NULL，任何使用此通信子的挂起操作都会正常完成；仅当没有对此对象的活动引用时，它才会被实际撤消。\n\n### 输出结果：\n\n输出结果格式应如下：\nThe comm is freed.\n...', '5', '20', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_dup(MPI_COMM_WORLD, &new_comm);\r\n	\r\n	// your code here\r\n	MPI_Comm_free(&new_comm);\r\n	// end of your code\r\n	\r\n	if(myid == 0) {\r\n		if (new_comm == MPI_COMM_NULL)\r\n			printf(\"Now the comm is freed.\\n\");\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	MPI_Comm_dup(MPI_COMM_WORLD, &new_comm);\r\n	\r\n	// your code here\r\n	\r\n	// end of your code\r\n	\r\n	if(myid == 0) {\r\n		if (new_comm == MPI_COMM_NULL)\r\n			printf(\"Now the comm is freed.\\n\");\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('103', '通信子的管理-划分', '有时候我们希望根据拓扑来创建不同的域，例如创建一个二维数组，显然一个个创建是很不方便的，这时候我们需要用到一个新的函数来进行划分。\n\n### 函数说明：\n\n```\nint MPI_Comm_split(MPI_Comm comm, int color, int key, MPI_Comm *newcomm)\n\nMPI_Comm comm ： 旧的通信子，也就是被划分的域；\nint color ： 子域的标识，也就是被划分出来的每个子域都对应一个color，每一个子域包含具有同样color的所有进程；\nint key ： 在每一个子域内, 进程按照key所定义的值的次序进行排列。\nMPI_Comm *newcomm ： 新的通信子；\n```\n函数将与comm相关的域划分为若干不相连的子域，根据color和key参数决定每个进程所处的位置。\n\n### 实验说明：\n\n创建一个二维数组，根据行与列进行求和，在每个进程中输出坐标和求出的和。\n\n### 输出结果：\n\n输出结果格式应如下：\nI\'m process n, my coordinates are (x, y), row sum is p, column sum is q.\n...', '5', '19', null, '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm row_comm, column_comm;\r\n	int myrow, mycolumn;\r\n	int color = 3 ;\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	myrow = myid / color ;\r\n	mycolumn = myid % color ;\r\n\r\n	// your code here\r\n	MPI_Comm_split(MPI_COMM_WORLD, myrow, mycolumn, &row_comm);  \r\n    MPI_Comm_split(MPI_COMM_WORLD, mycolumn, myrow, &column_comm);  \r\n    // end of your code\r\n	\r\n	int rowsum, columnsum;\r\n	\r\n	rowsum = myid;\r\n	columnsum = myid;\r\n	\r\n	MPI_Allreduce(MPI_IN_PLACE, &rowsum, 1, MPI_INT, MPI_SUM, row_comm);  \r\n    MPI_Allreduce(MPI_IN_PLACE, &columnsum, 1, MPI_INT, MPI_SUM, column_comm); \r\n    \r\n    printf(\"I\'m process %d, my coordinates are (%d, %d), row sum is %d, column sum is %d\\n\", myid, myrow, mycolumn,  \r\nrowsum, columnsum); \r\n    \r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm row_comm, column_comm;\r\n	int myrow, mycolumn;\r\n	int color = 3 ;\r\n		\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	myrow = myid / color ;\r\n	mycolumn = myid % color ;\r\n\r\n	// your code here\r\n	\r\n    // end of your code\r\n	\r\n	int rowsum, columnsum;\r\n	\r\n	rowsum = myid;\r\n	columnsum = myid;\r\n	\r\n	MPI_Allreduce(MPI_IN_PLACE, &rowsum, 1, MPI_INT, MPI_SUM, row_comm);  \r\n    MPI_Allreduce(MPI_IN_PLACE, &columnsum, 1, MPI_INT, MPI_SUM, column_comm); \r\n    \r\n    printf(\"I\'m process %d, my coordinates are (%d, %d), row sum is %d, column sum is %d\\n\", myid, myrow, mycolumn,  \r\nrowsum, columnsum); \r\n    \r\n	MPI_Finalize();\r\n	return 0;\r\n} ', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('104', 'omp_get_num_procs的用法', '返回调用函数时可用的处理器数目。\n函数原型 \nint omp_get_num_procs(void)\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\n8\n8\n8\n8\n8\n8\n8\n8\n8\n```\n', '6', '16', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	printf(\"%d\\n\", omp_get_num_procs());\r\n	#pragma omp parallel  \r\n	{\r\n	    // YOUR CODE HERE\r\n	    printf(\"%d\\n\", omp_get_num_procs());\r\n	    // END OF YOUR CODE\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	printf(\"%d\\n\", omp_get_num_procs());\r\n	#pragma omp parallel  \r\n	{\r\n	    // YOUR CODE HERE\r\n	    \r\n	    // END OF YOUR CODE\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('105', 'omp_get_num_threads的用法', '返回当前并行区域中的活动线程个数，如果在并行区域外部调用，返回1\n函数原型\nint omp_get_num_threads(void)\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\n1\n8\n8\n8\n8\n8\n8\n8\n8\n```\n', '6', '17', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n    printf(\"%d\\n\", omp_get_num_threads());\r\n	#pragma omp parallel  \r\n	{\r\n	    // YOUR CODE HERE\r\n	    printf(\"%d\\n\", omp_get_num_threads());\r\n	    // END OF YOUR CODE\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	printf(\"%d\\n\", omp_get_num_threads());\r\n	#pragma omp parallel  \r\n	{\r\n	    // YOUR CODE HERE\r\n	    \r\n	    // END OF YOUR CODE\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('106', 'omp_get_thread_num的用法', '返回当前的线程号，注意不要和之前的omp_get_num_threads混淆。\n函数原型\nint omp_get_thread_num(void)\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\n0\n0\n2\n1\n3\n4\n5\n6\n7\n```\n', '6', '18', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	printf(\"%d\\n\", omp_get_thread_num());\r\n	#pragma omp parallel  \r\n	{	    \r\n	    // YOUR CODE HERE\r\n	    printf(\"%d\\n\", omp_get_thread_num());\r\n	    // END OF YOUR CODE\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	printf(\"%d\\n\", omp_get_thread_num());\r\n	#pragma omp parallel  \r\n	{\r\n		// YOUR CODE HERE\r\n	    \r\n	    // END OF YOUR CODE\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('107', 'omp_set_num_threads的用法', '设置进入并行区域时，将要创建的线程个数\n函数原型\nint omp_set_num_threads(void)\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\n0 of 4 threads\n2 of 4 threads\n1 of 4 threads\n3 of 4 threads\n```\n', '6', '19', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n    // YOUR CODE HERE\r\n    omp_set_num_threads(4);\r\n    // END OF YOUR CODE\r\n	#pragma omp parallel  \r\n	{\r\n		printf(\"%d of %d threads\\n\", omp_get_thread_num(), omp_get_num_threads());\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n    // YOUR CODE HERE\r\n    \r\n    // END OF YOUR CODE\r\n	#pragma omp parallel  \r\n	{\r\n		printf(\"%d of %d threads\\n\", omp_get_thread_num(), omp_get_num_threads());\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');
INSERT INTO `challenges` VALUES ('108', 'omp_in_parallel的用法', '可以判断当前是否处于并行状态\n函数原型\nint omp_in_parallel();\n*注意：由于程序并行执行，每次输出的结果可能会有所区别。*\n\n**运行结果**\n```\n0\n1\n1\n1\n1\n```\n', '6', '20', null, '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	printf(\"%d\\n\", omp_in_parallel());\r\n	omp_set_num_threads(4);\r\n	#pragma omp parallel  \r\n	{\r\n	    // YOUR CODE HERE\r\n		printf(\"%d\\n\", omp_in_parallel());\r\n	    // END OF YOUR CODE\r\n	}\r\n	return 0;\r\n}\r\n', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	printf(\"%d\\n\", omp_in_parallel());\r\n	omp_set_num_threads(4);\r\n	#pragma omp parallel  \r\n	{\r\n	    // YOUR CODE HERE\r\n	    \r\n	    // END OF YOUR CODE\r\n	}\r\n	return 0;\r\n}\r\n', '1', '1', '1', 'mpi');

-- ----------------------------
-- Table structure for `classifies`
-- ----------------------------
DROP TABLE IF EXISTS `classifies`;
CREATE TABLE `classifies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `classifies_ibfk_1` (`user_id`),
  CONSTRAINT `classifies_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of classifies
-- ----------------------------
INSERT INTO `classifies` VALUES ('4', '并行计算理论', '3');
INSERT INTO `classifies` VALUES ('5', '并行算法', '3');
INSERT INTO `classifies` VALUES ('7', '北大并行计算试题', '3');
INSERT INTO `classifies` VALUES ('8', '并行计算机体系结构', '3');
INSERT INTO `classifies` VALUES ('9', 'MPI编程', '3');
INSERT INTO `classifies` VALUES ('10', 'OpenMP编程', '3');
INSERT INTO `classifies` VALUES ('11', 'Pthreads编程', '3');

-- ----------------------------
-- Table structure for `code_cache`
-- ----------------------------
DROP TABLE IF EXISTS `code_cache`;
CREATE TABLE `code_cache` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `program_id` int(11) NOT NULL,
  `code` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of code_cache
-- ----------------------------
INSERT INTO `code_cache` VALUES ('1', '1', '5', '#include <stdio.h>');
INSERT INTO `code_cache` VALUES ('2', '3', '1', '#include <stdio.h>\n\nmain()\n{\n   \n}');
INSERT INTO `code_cache` VALUES ('3', '3', '3', '#include <mpi.h>\n#include <stdlib.h>\n#include <stdio.h>\n\n\nint main(int argc, char**argv) { \n    \n    int rank, size;\n	int64_t i, num_steps;\n	double pi, x, sum, step, loc_sum = 0.0;\n	\n    num_steps = atoll(argv[1]);\n    num_steps = ((int64_t)1<<num_steps);\n    sum = 0.;\n    step = 1.0/(double) num_steps;\n    \n	MPI_Init(&argc, &argv);\n	MPI_Comm_size(MPI_COMM_WORLD, &size);\n	MPI_Comm_rank(MPI_COMM_WORLD, &rank);\n\n    for (i=rank+1; i<=num_steps ; i+=size) {\n         x = (i-0.5)*step;\n         loc_sum += 4.0/(1.0+x*x);\n    }\n    MPI_Allreduce(&loc_sum, &sum, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD); \n    pi = sum * step;     \n    \n    if (rank==0) {\n    	FILE *fout=fopen(\"data.out\",\"wb\");\n    	fwrite(&pi, sizeof(double), 1, fout);\n    	fclose(fout);\n    }\n     \n    MPI_Finalize();\n\n    return EXIT_SUCCESS;\n}\n');
INSERT INTO `code_cache` VALUES ('4', '3', '2', '#include <mpi.h>\n#include <stdio.h>\nint main(int argc, char **argv)\n{ \n    MPI_Init(&argc, &argv); \n    \n    int n = 100;\n    int m = 200;\n    printf(\"the min value is %d\",min(m,n));\n    \n    MPI_Finalize();\n    return 0;\n} \n\nint min(int m, int n){\n    if(m>n)return n;\n    else return m;\n}');

-- ----------------------------
-- Table structure for `comments`
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rank` int(11) DEFAULT NULL,
  `content` varchar(2048) DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  `courseId` int(11) DEFAULT NULL,
  `userId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courseId` (`courseId`),
  KEY `userId` (`userId`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`courseId`) REFERENCES `courses` (`id`),
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of comments
-- ----------------------------
INSERT INTO `comments` VALUES ('1', '4', '1212', '2016-11-21 14:02:21', '1', '1');
INSERT INTO `comments` VALUES ('2', '4', '评价2', '2016-11-18 00:00:00', '1', '2');
INSERT INTO `comments` VALUES ('3', '5', '这门课不错', '2017-03-13 15:44:38', '1', '3');
INSERT INTO `comments` VALUES ('4', '2', '评价4', '2016-11-18 00:00:00', '1', '4');
INSERT INTO `comments` VALUES ('5', '1', '评价5', '2016-11-18 00:00:00', '1', '5');
INSERT INTO `comments` VALUES ('6', '4', '12123', '2016-11-21 13:58:47', '2', '1');
INSERT INTO `comments` VALUES ('7', '3', '好好好', '2016-11-21 13:59:18', '3', '1');
INSERT INTO `comments` VALUES ('8', '1', '12345', '2016-11-22 16:19:11', '5', '1');
INSERT INTO `comments` VALUES ('9', '1', '122444', '2016-11-21 23:12:57', '5', '2');

-- ----------------------------
-- Table structure for `courses`
-- ----------------------------
DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL DEFAULT '',
  `subtitle` varchar(128) DEFAULT '',
  `about` text,
  `createdTime` datetime DEFAULT NULL,
  `lessonNum` int(11) NOT NULL,
  `studentNum` int(11) DEFAULT NULL,
  `smallPicture` varchar(128) DEFAULT NULL,
  `middlePicture` varchar(128) DEFAULT NULL,
  `largePicture` varchar(128) DEFAULT NULL,
  `rank` float(3,2) DEFAULT NULL,
  `public` tinyint(1) DEFAULT '1',
  `beginTime` datetime DEFAULT NULL,
  `endTime` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `nature_order` int(11) NOT NULL,
  `is_hidden` tinyint(1) unsigned zerofill DEFAULT '0',
  `is_invited` tinyint(1) DEFAULT NULL,
  `invite_code` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courses_ibfk_1` (`user_id`),
  KEY `courses_ibfk_2` (`group_id`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `courses_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of courses
-- ----------------------------
INSERT INTO `courses` VALUES ('1', '并行计算－结构•算法•编程', '中国科大《并行计算》国家精品课程，陈国良院士主讲。', '# 课程主讲：陈国良院士\n![](/static/upload/md_images/20170325225146.png)\n\n# 1. 课程内容体系结构\n\n“并行计算”是“并行算法类教学体系”中的核心内容之一，它是处于并行算法类教学体系中的算法应用基础层次，是面向计算机专业本科高年级学生或从事计算科学的研究生的，是为了适应高性能计算机迅速发展的形势，满足国家培养面向21世纪高科技人才之需求。为此本课程在内容体系上力求有所创新，而在遵循课程自身学科性、系统性和完整性的同时，应充分考虑不同应用领域在并行计算机上求解大型科学工程问题的需求，将并行机体系结构、并行数值计算、并行算法和并行编程等课程的内容有机的整合在一起，在国内形成一门新型的“并行计算”课程。\n \n# 2. 教学内容组织方式与目的\n\n* 教学内容组织方式: 全课程的教学内容组织成为四篇：第一篇为并行计算的硬件基础，包括并行计算机的系统结构模型、当代并行计算机系统介绍和并行计算性能评测；第二篇为并行算法的设计，包括并行算法通用设计策略、基本设计技术和一般设计过程；第三篇为并行数值算法，包括矩阵运算、线性方程组求解和快速傅氏变换；第四篇为并行程序设计，包括并行程序设计基础、共享存储系统并行编程、分布式存储系统并行编程和并行程序设计环境与工具。\n* 教学目的: 本课程以并行计算为主题、要求讲授并行计算的硬件平台（当代并行计算机系统及其结构模型）、软件支撑（并行程序设计）和理论基础（并行算法的设计和并行数值算法）。在内容组织上，强调融并行机结构、并行算法和并行编程为一体，着重讨论并行算法的设计及其实现，并力图反映本学科的最新成就和发展趋势，体现出并行机硬件和软件相结合以及并行算法和并行编程相结合。\n\n# 3.实践性教学的设计与效果\n\n“并行计算”是一门实践性很强的课程，除了系统的课堂理论学习外，还配有足够数量的实践内容，以巩固和加深学生对并行算法理论、设计技术、分析方法和具体实现等各个环节的整体理解。通过课程实践，强化学生“结构—算法—编程”一体化学习方法的意识，充分理解对于求解一个给定问题的任何并行算法，都必须采用某种并行编程语言，最终运行在一台具体的并行计算\n\n根据并行计算课程的要求，其实验教学的要求如下：\n\n- 熟悉三种以上的主流并行计算平台，包括共享存储的多处理机、分布存储的多计算机和目前流行的PC机群，要求学生能够使用上述几种并行计算平台所提供的硬／软件环境及工具来开展自己的实验工作。\n- 掌握至少两种并行程序设计语言标准：即分布存储的MPI和共享存储的OpenMP。对面向大型科学和工程计算的HPF（高性能Fortran）也应尽量了解和熟悉。\n- 选择某些典型的非数值并行算法和数值并行算法，使用上述的并行编程语言标准，至少在PC机群上编程调试、分析和运行它们。\n- 为了入门，选用课程中简单的计算π的样本程序为出发点，通过使用不同的并行程序设计模型和不同的并行编程语言，在不同的硬件编程环境上改造和重现，以便为进一步的实践打下基础。', '2016-10-20 00:00:00', '29', '4', 'upload/course/cover_1.png', null, null, '3.20', '1', null, null, '3', '16', '1', '0', '0', null);
INSERT INTO `courses` VALUES ('2', '并行计算介绍', '以下内容仅用于系统测试，知识产权归课件开发者所有', '# 1. Overview\nParallel computing has become the dominant technique for achieving high performance in computational science and engineering research. Parallel computing systems are now becoming mainstream in commercial sectors as well, due to the performance demands and requirements of today\'s engineering, database, and financial applications. Multiprocessor systems based on commodity processors (IA32, IA64, G4, Alpha, UltraSparc, Power3, Power4) are now common and offer excellent performance for the price. However, parallel computing is relatively new to college curricula; until recently, parallel computing was largely learned on the side (for research scientists) or on the job (in industry).\nThis class will discuss architectures of modern parallel computers (briefly) and will teach students how to write parallel programs for these parallel computers. This class will be very \'applied\' in nature: there will be more emphasis on parallel programming libraries than on abstract theoretical parallel programming concepts or computer engineering details.\n# 2.  Prerequisites\nStudents must have prior programming experience using either C or Fortran. Experience using Unix workstations and developing scientific codes is helpful but not required.\n# 3.  Topics\n* Overview of Parallel Computing(Majumdar): parallel computing concepts, parallel computer architectures, and standard programming models for parallel computers.\n* Shared Memory Parallel Programming with OpenMP (Majumdar): OpenMP features and syntax, examples of parallelizing serial codes with OpenMP, discussion of performance issues.\n* Distributed Memory Programming with Message Passing Interface (MPI) (Majumdar): MPI features and syntax, examples of parallelizing serial codes with MPI, discussion of performance issues.\n* Single Processor Optimization (Valafar): overview of microprocessor architectures, utilizing microprocessor features (registers, cashes, etc.) effectively, characteristics and potential bottlenecks that determine maximum deliverable performance for code segments, and measuring and improving code performance.', '2016-09-20 08:00:00', '3', '0', 'upload/course/cover_2.png', null, null, '4.00', '0', '2017-09-10 13:23:12', '2017-10-07 11:55:01', '3', '17', '2', '0', '1', '1234');
INSERT INTO `courses` VALUES ('3', '并行计算原理与实践', '华中科技大学金海教授主讲 （课程内容仅用于系统测试，知识产权归课件开发者所有）', '# 1. Course Description\nThe students will get the skills to use some of the best existing parallel programming tools, and be exposed to a number of open research questions. This course will:\n\n* provide an introduction to parallel computing including parallel computer architectures, analytical modeling of parallel programs, the principles of parallel algorithm design.\n* include material on TBB, OpenMP, CUDA, OpenCL, MPI, MapReduce.\n\n# 2. Prerequisite\nC language, discrete mathematics, data structure, principles of computer composition, operating system, C++, algorithms\n\n# 3. Syllabus\n* **Part 1: Principle (Lecture 1-5)**\n	\n	This section covers the very basics of parallel computing, and is intended for someone who is just becoming acquainted with the subject. It begins with a brief overview, including concepts and terminology associated with parallel computing. The topics of parallel memory architectures and programming models are then explored. These topics are followed by a discussion on a number of issues related to designing parallel programs.\n\n* **Part 2: Typical Issues Solved by Parallel Programming (Lecture 6-10)**\n	\n	This section concludes with several examples of how to parallelize simple serial programs. Including: threads and shared memory programming with TBB and OpenMP, SIMD programming model and Cuda & OpenCL, programming using the Message Passing Paradigm, parallel computing with MapReduce.\n\n* **Part 3: Parallel Programming Case Study and Assignment (Lecture 11 and Assignment)**\n	\n	Students in this course are required to complete several assignments, which accounts for 30% of their grade.', '2016-09-21 00:00:00', '12', '1', 'upload/course/cover_3.png', null, null, '3.00', '1', null, null, '3', '18', '3', '0', '0', null);
INSERT INTO `courses` VALUES ('4', '并行编程', '以下内容仅用于系统测试，知识产权归课件开发者所有', '# 1. Background and Description\nThis course is a comprehensive exploration of parallel programming paradigms, examining core concepts, focusing on a subset of widely used contemporary parallel programmingmodels, and providing context with a small set of parallel algorithms. In the last few years, this area has been the subject of significant interest due to a number of factors. Most significantly, the advent of multi-core microprocessors has made parallel computing available to the masses. At the high end, major vendors of large-scale parallel systems, including IBM, and Cray, have recently introduced new parallel programming languages designed for applications that exploit tens of thousands of processors. Embedded devices can also be thought of as small multiprocessors. The convergence of these distinct markets offers an opportunity to finally provide application programmers with a productive way to express parallel computation.\n\nThe course will be structured as lectures, homeworks, programming assignments and a final project. Students will perform four programming projects to express algorithms using selected parallel programming models and measure their performance. The final project will consist of teams of 2-3 students who will implement codes by combining multiple programming models.\n\n# 2. Prerequisites\nCS 4400, or concurrent\n', '2016-09-22 00:00:00', '24', '1', 'upload/course/cover_4.png', null, null, '0.00', '0', '2017-01-03 13:03:37', '2017-02-23 14:50:34', '3', '19', '4', '0', '0', null);
INSERT INTO `courses` VALUES ('5', '并行方法在数值分析中的应用', '以下内容仅用于系统测试，知识产权归课件开发者所有', '# 1. Course Description\nEmphasis is on techniques for obtaining maximum parallelism in numerical algorithms, especially those occurring when solving matrix problems, partial differential equations, and the subsequent mapping onto the computer. Implementation issues on parallel computers. Topics: parallel architecture, programming models (MPI, GPU Computing with CUDA ¿ quick review), matrix computations, FFT, fast multiple methods, domain decomposition, graph partitioning, discrete algorithms.\n\n# 2. Prerequisites\n302 or 200 ( ME 300A), 213 or equivalent, or consent of instructor. Recommended: differential equations and knowledge of a high-level programming language such as C or C++ (F90/95 also allowable).', '2016-09-23 01:00:00', '13', '2', 'upload/course/cover_5.png', null, null, '1.00', '1', null, null, '3', '20', '5', '0', '0', null);
INSERT INTO `courses` VALUES ('6', ' CUDA Programming on NVIDIA GPUs', '以下内容仅用于系统测试，知识产权归课件开发者所有', '# 1. Course Description\nThe course consists of approximately 3 hours of lectures and 4 hours of practicals each day. The aim is that by the end of the course you will be able to write relatively simple programs and will be confident and able to continue learning through studying the examples provided by NVIDIA as part of their SDK (software development kit). \n\n# 2. Preliminary Reading\n* Please read chapters 1 and 2 of the NVIDIA CUDA C Programming Guide. \n\n* CUDA is an extension of C/C++, so if you are a little rusty with C/C++ you should refresh your memory of it. ', '2016-09-29 01:00:00', '11', '0', 'upload/course/cover_6.png', null, null, '0.00', '0', '2017-01-03 13:04:21', '2017-01-28 15:35:17', '3', '21', '6', '0', '0', null);
INSERT INTO `courses` VALUES ('9', '并行编程初步', '上海超算中心张丹丹老师主讲（以下内容仅用于系统测试，知识产权归课件开发者所有）', '# Abstract\nThe Message Passing Interface Standard (MPI) is a message passing library standard based on the consensus of the MPI Forum, which has over 40 participating organizations, including vendors, researchers, software library developers, and users. The goal of the Message Passing Interface is to establish a portable, efficient, and flexible standard for message passing that will be widely used for writing message passing programs. As such, MPI is the first standardized, vendor independent, message passing library. The advantages of developing message passing software using MPI closely match the design goals of portability, efficiency, and flexibility. MPI is not an IEEE or ISO standard, but has in fact, become the \"industry standard\" for writing message passing programs on HPC platforms.\n\nThe goal of this tutorial is to teach those unfamiliar with MPI how to develop and run parallel programs according to the MPI standard. The primary topics that are presented focus on those which are the most useful for new MPI programmers. The tutorial begins with an introduction, background, and basic information for getting started with MPI. This is followed by a detailed look at the MPI routines that are most useful for new MPI programmers, including MPI Environment Management, Point-to-Point Communications, and Collective Communications routines. Numerous examples in both C and Fortran are provided, as well as a lab exercise.\n\nThe tutorial materials also include more advanced topics such as Derived Data Types, Group and Communicator Management Routines, and Virtual Topologies. However, these are not actually presented during the lecture, but are meant to serve as \"further reading\" for those who are interested.\n\n# Level/Prerequisites\nThis tutorial is ideal for those who are new to parallel programming with MPI. A basic understanding of parallel programming in C or Fortran is required. For those who are unfamiliar with Parallel Programming in general, the material covered in EC3500: Introduction To Parallel Computing would be helpful. ', '2016-10-23 08:58:17', '2', '0', 'upload/course/cover_9.png', null, null, '0.00', '1', null, null, '3', '22', '7', '0', '0', null);
INSERT INTO `courses` VALUES ('10', '并行计算机体系结构', '以下内容仅用于系统测试，知识产权归课件开发者所有', '# 并行计算机\n并行计算机就是由多个处理单元组成的计算机系统，这些处理单元相互通信和协作，能快速，高效地求解大型复杂问题。\n# 涉及问题\n* **资源分配**\n	1. 并行计算机系统有多大? \n    2. 处理单元的性能如何?\n	3. 购买价格如何?\n\n* **数据存取, 通信 以及 同步** \n	1. 各处理单元如何协作及通信?\n	2. 数据如何在各处理机间传送?\n	3. 什么是协作的概念?\n\n* **性能与规模**\n	1. 如何将之全部转化为高性能?\n	2. 如何对其进行评测?\n', '2016-12-12 12:48:28', '8', '0', 'upload/course/cover_10.png', null, null, '0.00', '1', null, null, '3', '23', '8', '0', '0', null);
INSERT INTO `courses` VALUES ('11', '并行算法的设计与分析', '以下内容仅用于系统测试，知识产权归课件开发者所有', '# 课程目标\n* 通过课程讲授、课程论文和课堂讨论的方式使同学们掌握各种并行计算模型上常用的、基本的、典型的并行算法设计和分析，以及在各自研究领域中的应用\n\n# 课程内容\n* 并行机结构模型、并行计算模型、并行算法基本知识\n* 非数值并行算法：排序、选择、组合搜索、串匹配、图论算法等\n* 数值并行算法：矩阵运算、线性方程组求解、FFT算法等\n* 并行计算理论初步和并行算法的应用举例\n', '2016-12-12 13:12:49', '13', '0', 'upload/course/cover_11.png', null, null, '0.00', '1', null, null, '3', '24', '9', '0', '0', null);
INSERT INTO `courses` VALUES ('12', '并行计算基础', '以下内容仅用于系统测试，知识产权归课件开发者所有', '# 1. 集群计算\n集群计算主要研究方向是并行计算所需的各种工具，如并行调试器、容错工具、性能调试、 并行化编译等等，另外还包括集群计算的实际应用程序的开发，如生物信息学、电力系统模 拟与仿真等。\n\n随着计算机体系结构的发展，并行处理重新成为了研究热点。原因是单内核处理器的发展已 经遇到了瓶颈，进一步提高 CPU 的性能必须从多内核入手， Intel 公司目前大部分的研究 工作都开始以多内核为基础。8 － 16 内核的处理器现在已经是桌面和服务器的主流， 如何有效地利用多内核处理器系统对于研究者来说仍然是一个新 的挑战。需要在并行处理的体系结构、并行算法、并行编程工具以及运行时系统等多个方面 进行更加深入的研究。可以预计，此方向的研究在今后 10 年之内仍然会持续成为研究的热 点。\n\n# 2. 开设本课程的动机\n* 并行系统已经逐渐成为主流\n\n	(1) 多核已经成为趋势\n\n	(2) 桌面系统已经成为并行系统，而且核数增加，软件需要从串行变为并行\n\n	(3) 集群已经大量普及，但当前的并行编程方法、工具还是专家们所掌握\n\n* 并行不再是少数人的专利，并行计算有可能成为通用计算技术\n* 并行计算的使用者来自各个领域，但对并行编程的熟悉程度还不高\n\n# 3. 课程目标\n* 不是单纯理论学习课，偏重实践的课程 \n* 实实在在体验并行软件开发过程\n\n# 4. 得到的收获\n* 在今后采用并行计算方法提升程序性能\n* 能编写一定规模的并行程序\n* 知道使用并行工具提高并行程序实现效率\n* 初步了解并行计算程序设计的过程\n* 了解最新的众核/异构并行技术', '2016-12-16 15:22:12', '12', '0', 'upload/course/cover_12.png', null, null, '0.00', '1', null, null, '3', '25', '10', '0', '0', null);
INSERT INTO `courses` VALUES ('14', '并行程序设计', '北京大学信息科学技术学院余华山老师主讲', '[课程网页](http://course.pku.edu.cn)', '2016-12-31 20:45:39', '14', '0', 'upload/course/cover_14.png', null, null, '0.00', '1', null, null, '3', '26', '11', '0', '0', null);
INSERT INTO `courses` VALUES ('32', '云计算概论', '中山大学数据科学与计算机学院，2017年春', '本课程讲授内容包括云计算基础概念、原理和应用。', '2017-03-21 21:20:01', '3', '23', 'upload/course/cover_32.png', null, null, '0.00', '0', '2017-02-23 21:35:42', '2017-06-30 23:55:42', '15', '27', '1', '0', '0', null);

-- ----------------------------
-- Table structure for `course_assistants`
-- ----------------------------
DROP TABLE IF EXISTS `course_assistants`;
CREATE TABLE `course_assistants` (
  `user_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  KEY `user_id` (`user_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `course_assistants_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `course_assistants_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of course_assistants
-- ----------------------------

-- ----------------------------
-- Table structure for `course_users`
-- ----------------------------
DROP TABLE IF EXISTS `course_users`;
CREATE TABLE `course_users` (
  `course_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  KEY `user_id` (`user_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `course_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `course_users_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of course_users
-- ----------------------------
INSERT INTO `course_users` VALUES ('3', '1');
INSERT INTO `course_users` VALUES ('4', '1');
INSERT INTO `course_users` VALUES ('5', '4');
INSERT INTO `course_users` VALUES ('1', '7');
INSERT INTO `course_users` VALUES ('5', '1');
INSERT INTO `course_users` VALUES ('1', '9');
INSERT INTO `course_users` VALUES ('1', '2');
INSERT INTO `course_users` VALUES ('1', '3');
INSERT INTO `course_users` VALUES ('32', '3');
INSERT INTO `course_users` VALUES ('32', '15');
INSERT INTO `course_users` VALUES ('32', '6');

-- ----------------------------
-- Table structure for `docker_holders`
-- ----------------------------
DROP TABLE IF EXISTS `docker_holders`;
CREATE TABLE `docker_holders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(256) NOT NULL,
  `ip` varchar(128) NOT NULL,
  `inner_ip` varchar(128) NOT NULL,
  `public_port` int(11) NOT NULL,
  `inner_port` int(11) NOT NULL,
  `status` int(11) DEFAULT '0',
  `running_container_count` int(11) DEFAULT '0',
  `images_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of docker_holders
-- ----------------------------
INSERT INTO `docker_holders` VALUES ('2', 'docker2', 'a002.nscc-gz.cn', '10.133.100.238', '10288', '8080', '1', '0', '0');
INSERT INTO `docker_holders` VALUES ('3', 'docker3', 'a002.nscc-gz.cn', '10.133.100.239', '10289', '8080', '1', '0', '0');
INSERT INTO `docker_holders` VALUES ('4', 'docker4', 'a002.nscc-gz.cn', '10.133.100.7', '10290', '8080', '1', '0', '0');
INSERT INTO `docker_holders` VALUES ('5', 'docker5', 'a002.nscc-gz.cn', '10.133.100.71', '10291', '8080', '1', '0', '0');

-- ----------------------------
-- Table structure for `docker_images`
-- ----------------------------
DROP TABLE IF EXISTS `docker_images`;
CREATE TABLE `docker_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `create_time` datetime NOT NULL,
  `last_connect_time` datetime DEFAULT NULL,
  `remaining_time_today` int(11) DEFAULT '14400',
  `port` int(11) DEFAULT '0',
  `tunnel_id` varchar(256) DEFAULT NULL,
  `vnc_password` varchar(128) NOT NULL,
  `ssh_password` varchar(128) NOT NULL,
  `status` int(11) DEFAULT '0',
  `is_running` tinyint(1) NOT NULL DEFAULT '0',
  `is_vnc_running` tinyint(1) NOT NULL DEFAULT '0',
  `is_ssh_running` tinyint(1) NOT NULL DEFAULT '0',
  `token` varchar(64) DEFAULT NULL,
  `name` varchar(64) NOT NULL,
  `user_id` int(11) NOT NULL,
  `docker_holder_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `docker_holder_id` (`docker_holder_id`),
  CONSTRAINT `docker_images_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `docker_images_ibfk_2` FOREIGN KEY (`docker_holder_id`) REFERENCES `docker_holders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of docker_images
-- ----------------------------

-- ----------------------------
-- Table structure for `groups`
-- ----------------------------
DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `about` text NOT NULL,
  `logo` varchar(128) DEFAULT NULL,
  `memberNum` int(11) DEFAULT NULL,
  `topicNum` int(11) DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of groups
-- ----------------------------
INSERT INTO `groups` VALUES ('1', 'C++讨论', '这里讨论 C++ 的基础知识，欢迎一起来讨论C++编程啊！', '/static/upload/group_logo/1.png?t=1481772698.14', '3', '6', '2016-09-20 00:00:00');
INSERT INTO `groups` VALUES ('2', '意见反馈', '反馈给站点的意见', '/static/upload/group_logo/2.jpg', '4', '1', '2016-08-20 00:00:00');
INSERT INTO `groups` VALUES ('3', '学习交流', '在这里交流学习的心得体会', '/static/upload/group_logo/3.jpg', '0', '1', '2016-10-20 00:00:00');
INSERT INTO `groups` VALUES ('4', '使用指南', '网站使用指南', '/static/upload/group_logo/4.jpg', '2', '3', '2016-09-20 00:00:00');
INSERT INTO `groups` VALUES ('6', '云计算概论', '本群组为云计算基础概念、原理和应用课程的讨论组，可以在该话题下面对课程进行讨论。', '/static/upload/group_logo/6.jpg', '0', '1', '2016-09-20 00:00:00');
INSERT INTO `groups` VALUES ('15', '测试群组', '这是一个测试群组', '/static/upload/group_logo/15.png?t=1477277568.0', '2', '1', '2016-10-24 10:52:49');
INSERT INTO `groups` VALUES ('16', '并行计算－结构•算法•编程', '', null, '4', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('17', '并行计算介绍', '', null, '0', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('18', '并行计算原理与实践', '', null, '1', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('19', '并行编程', '', null, '1', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('20', '并行方法在数值分析中的应用', '', null, '2', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('21', 'CUDA Programming on NVIDIA GPUs', '', null, '0', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('22', '并行编程初步', '', null, '0', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('23', '并行计算机体系结构', '', null, '0', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('24', '并行算法的设计与分析', '', null, '0', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('25', '并行计算基础', '', null, '0', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('26', '并行程序设计', '', null, '0', '0', '2017-01-01 11:11:11');
INSERT INTO `groups` VALUES ('27', '云计算概论', '', null, '3', '0', '2017-01-01 11:11:11');

-- ----------------------------
-- Table structure for `group_members`
-- ----------------------------
DROP TABLE IF EXISTS `group_members`;
CREATE TABLE `group_members` (
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`group_id`,`user_id`),
  KEY `user_id` (`user_id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `group_members_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `group_members_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of group_members
-- ----------------------------
INSERT INTO `group_members` VALUES ('1', '1');
INSERT INTO `group_members` VALUES ('2', '1');
INSERT INTO `group_members` VALUES ('3', '1');
INSERT INTO `group_members` VALUES ('4', '1');
INSERT INTO `group_members` VALUES ('15', '1');
INSERT INTO `group_members` VALUES ('18', '1');
INSERT INTO `group_members` VALUES ('19', '1');
INSERT INTO `group_members` VALUES ('20', '1');
INSERT INTO `group_members` VALUES ('27', '1');
INSERT INTO `group_members` VALUES ('2', '2');
INSERT INTO `group_members` VALUES ('16', '2');
INSERT INTO `group_members` VALUES ('2', '3');
INSERT INTO `group_members` VALUES ('16', '3');
INSERT INTO `group_members` VALUES ('27', '3');
INSERT INTO `group_members` VALUES ('1', '4');
INSERT INTO `group_members` VALUES ('20', '4');
INSERT INTO `group_members` VALUES ('1', '6');
INSERT INTO `group_members` VALUES ('2', '7');
INSERT INTO `group_members` VALUES ('15', '7');
INSERT INTO `group_members` VALUES ('16', '7');
INSERT INTO `group_members` VALUES ('16', '9');
INSERT INTO `group_members` VALUES ('4', '15');
INSERT INTO `group_members` VALUES ('27', '15');

-- ----------------------------
-- Table structure for `homework`
-- ----------------------------
DROP TABLE IF EXISTS `homework`;
CREATE TABLE `homework` (
  `id` int(64) NOT NULL AUTO_INCREMENT,
  `title` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `publish_time` datetime NOT NULL,
  `deadline` datetime DEFAULT NULL,
  `course_id` int(64) NOT NULL,
  `h_type` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `homework_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Records of homework
-- ----------------------------
INSERT INTO `homework` VALUES ('3', '作业1', '# Cost Function\r\n\r\nLet\'s first define a few variables that we will need to use:\r\n\r\n* L = total number of layers in the network\r\n* \\(s_l\\) = number of units (not counting bias unit) in layer l\r\n* K = number of output units/classes\r\n\r\nRecall that in neural networks, we may have many output nodes. We denote \\(h_{\\Theta}(x)_k\\) as being a hypothesis that results in the \\(k^{th}\\) output. Our cost function for neural networks is going to be a generalization of the one we used for logistic regression. Recall that the cost function for regularized logistic regression was:\r\n\r\n\\[J(\\theta) = - \\frac{1}{m} \\sum_{i=1}^m [ y^{(i)}\\ \\log (h_\\theta (x^{(i)})) + (1 - y^{(i)})\\ \\log (1 - h_\\theta(x^{(i)}))] + \\frac{\\lambda}{2m}\\sum_{j=1}^n \\theta_j^2\\]\r\n\r\nFor neural networks, it is going to be slightly more complicated:\r\n\r\n\\[\\begin{gather*} J(\\Theta) = - \\frac{1}{m} \\sum_{i=1}^m \\sum_{k=1}^K \\left[y^{(i)}_k \\log ((h_\\Theta (x^{(i)}))_k) + (1 - y^{(i)}_k)\\log (1 - (h_\\Theta(x^{(i)}))_k)\\right] + \\frac{\\lambda}{2m}\\sum_{l=1}^{L-1} \\sum_{i=1}^{s_l} \\sum_{j=1}^{s_{l+1}} ( \\Theta_{j,i}^{(l)})^2\\end{gather*}\\]\r\n\r\nWe have added a few nested summations to account for our multiple output nodes. In the first part of the equation, before the square brackets, we have an additional nested summation that loops through the number of output nodes.\r\n\r\nIn the regularization part, after the square brackets, we must account for multiple theta matrices. The number of columns in our current theta matrix is equal to the number of nodes in our current layer (including the bias unit). The number of rows in our current theta matrix is equal to the number of nodes in the next layer (excluding the bias unit). As before with logistic regression, we square every term.\r\n\r\nNote:\r\n\r\n* the double sum simply adds up the logistic regression costs calculated for each cell in the output layer\r\n* the triple sum simply adds up the squares of all the individual Θs in the entire network.\r\n* the i in the triple sum does **not** refer to training example i.\r\n\r\n', '2016-12-25 15:45:01', '2017-03-31 20:50:26', '1', '0');
INSERT INTO `homework` VALUES ('4', '作业2', '查阅资料，找出一个并行计算的典型应用，详细描述该应用在并行化方面成功和失败之处以及遇到的困难：（从下列方面考虑：该应用是针对什么科学或者工程上的具体问题设计的；对于要解决的问题，该应用实际效果怎样，模拟结果和物理结果进行比较的结果如何；该应用的运行在什么并行计算平台上；（比如分布式或共享内存，向量机）这个应用使用那种开发工具开发的；该应用的实际工作性能怎样，和运行平台最佳性能相比较；该应用的可扩展性如何？如果不好，你认为它的扩展性的瓶颈在何处？）', '2016-12-25 15:45:29', '2017-05-31 18:50:57', '1', '0');
INSERT INTO `homework` VALUES ('5', '作业3', '作业3', '2017-01-08 11:49:21', '2017-04-30 23:55:00', '1', '0');
INSERT INTO `homework` VALUES ('13', 'Homework 1', '**【论文阅读】：**\r\nTime, Clocks and the Ordering of Events in a Distributed System, Leslie Lamport, Communications of the ACM 21, 7 (July 1978), 558-565. [[PDF](http://a002.nscc-gz.cn:10165/static/homework/appendix/course_32/homework_13/appendix_59.pdf?q=1490103137)]\r\n\r\nInstructions: please use the following template to write a paper review and submit. [Review Template](http://a002.nscc-gz.cn:10165/static/homework/appendix/course_32/homework_13/appendix_61.zip?q=1490103137): [review_template.zip]\r\n[How to read a paper?](http://a002.nscc-gz.cn:10165/static/homework/appendix/course_32/homework_13/appendix_60.pdf?q=1490103137) [paper-reading.pdf]\r\n[How to write a review?](http://a002.nscc-gz.cn:10165/static/homework/appendix/course_32/homework_13/appendix_62.pdf?q=1490103137) [review-writing.pdf]\r\n\r\n**【提交物】：**论文的review report\r\n\r\n**【关于作业提交】：**\r\n\r\n作业命名方式：HW-X-学号姓名 （其中X为作业编号，阿拉伯数字，如HW-1-12345678张三。由于班级人数较多，请严格按照规范命名！）\r\n\r\n注册EasyHPC账号，申请加入云计算概论课程（请填写准确个人信息，需要审核后，才能加入）。审核通过后，可以在“课程作业”处提交作业。*', '2017-03-21 21:32:17', '2017-04-05 23:55:25', '32', '0');

-- ----------------------------
-- Table structure for `homework_appendix`
-- ----------------------------
DROP TABLE IF EXISTS `homework_appendix`;
CREATE TABLE `homework_appendix` (
  `id` int(64) NOT NULL AUTO_INCREMENT,
  `name` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `homework_id` int(64) DEFAULT NULL,
  `user_id` int(64) NOT NULL,
  `uri` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `upload_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `homework_id` (`homework_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `homework_appendix_ibfk_1` FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`),
  CONSTRAINT `homework_appendix_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Records of homework_appendix
-- ----------------------------
INSERT INTO `homework_appendix` VALUES ('45', 'KMP_Algorithm.pdf', '3', '3', 'course_1/homework_3/appendix_45.pdf', '2017-03-12 20:42:36');
INSERT INTO `homework_appendix` VALUES ('46', '部分练习题.docx.zip', '4', '3', 'course_1/homework_4/appendix_46.zip', '2017-03-12 20:43:21');
INSERT INTO `homework_appendix` VALUES ('59', '1978_ordering_events.pdf', '13', '15', 'course_32/homework_13/appendix_59.pdf', '2017-03-21 21:32:17');
INSERT INTO `homework_appendix` VALUES ('60', 'paper-reading.pdf', '13', '15', 'course_32/homework_13/appendix_60.pdf', '2017-03-21 21:32:17');
INSERT INTO `homework_appendix` VALUES ('61', 'review_template.zip', '13', '15', 'course_32/homework_13/appendix_61.zip', '2017-03-21 21:32:17');
INSERT INTO `homework_appendix` VALUES ('62', 'review-writing.pdf', '13', '15', 'course_32/homework_13/appendix_62.pdf', '2017-03-21 21:32:17');

-- ----------------------------
-- Table structure for `homework_program`
-- ----------------------------
DROP TABLE IF EXISTS `homework_program`;
CREATE TABLE `homework_program` (
  `homework_id` int(11) NOT NULL,
  `program_id` int(11) NOT NULL,
  PRIMARY KEY (`homework_id`,`program_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `homework_program_ibfk_1` FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`),
  CONSTRAINT `homework_program_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Records of homework_program
-- ----------------------------

-- ----------------------------
-- Table structure for `homework_score`
-- ----------------------------
DROP TABLE IF EXISTS `homework_score`;
CREATE TABLE `homework_score` (
  `user_id` int(11) NOT NULL,
  `homework_id` int(11) NOT NULL,
  `score` int(11) NOT NULL,
  `comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` tinyint(2) NOT NULL DEFAULT '2',
  PRIMARY KEY (`user_id`,`homework_id`),
  KEY `homework_id` (`homework_id`),
  CONSTRAINT `homework_score_ibfk_1` FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`),
  CONSTRAINT `homework_score_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Records of homework_score
-- ----------------------------
INSERT INTO `homework_score` VALUES ('3', '3', '88', '还有些错误！', '1');
INSERT INTO `homework_score` VALUES ('5', '3', '90', '下次早点交！', '1');

-- ----------------------------
-- Table structure for `homework_upload`
-- ----------------------------
DROP TABLE IF EXISTS `homework_upload`;
CREATE TABLE `homework_upload` (
  `id` int(64) NOT NULL AUTO_INCREMENT,
  `name` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `homework_id` int(64) NOT NULL,
  `user_id` int(64) NOT NULL,
  `uri` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `submit_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `homework_id` (`homework_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `homework_upload_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `homework_upload_ibfk_2` FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Records of homework_upload
-- ----------------------------
INSERT INTO `homework_upload` VALUES ('5', 'nahan.key.zip', '4', '3', 'course_1/homework_4/0_name_nahan.key.zip', '2017-03-12 20:47:56');
INSERT INTO `homework_upload` VALUES ('6', '2016_1【迟交】.pdf', '3', '3', 'course_1/homework_3/150101102_张三丰_2016_1【迟交】.pdf', '2017-04-10 19:00:10');
INSERT INTO `homework_upload` VALUES ('7', '2016_2【迟交】.pdf', '3', '3', 'course_1/homework_3/150101102_张三丰_2016_2【迟交】.pdf', '2017-04-10 19:00:10');
INSERT INTO `homework_upload` VALUES ('8', '课程介绍与安排【迟交】.pdf', '3', '5', 'course_1/homework_3/123222222_admin_课程介绍与安排【迟交】.pdf', '2017-04-17 13:29:44');

-- ----------------------------
-- Table structure for `knowledges`
-- ----------------------------
DROP TABLE IF EXISTS `knowledges`;
CREATE TABLE `knowledges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(1024) NOT NULL,
  `content` text,
  `cover_url` varchar(512) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `lab_id` int(11) DEFAULT NULL,
  `is_hidden` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `1` (`lab_id`),
  CONSTRAINT `1` FOREIGN KEY (`lab_id`) REFERENCES `lab` (`id`),
  CONSTRAINT `knowledges_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of knowledges
-- ----------------------------
INSERT INTO `knowledges` VALUES ('5', 'MPI 编程实训', 'MPI(Message Passing Interface)是一个跨语言的通讯协议,用于编写并行程序。与OpenMP并行程序不同，MPI是一种基于消息传递的并行编程技术。消息传递接口是一种编程接口标准，而不是一种具体的编程语言。\r\n简而言之，MPI标准定义了一组具有可移植性的编程接口。不同的厂商和组织遵循着这个标准推出各自的实现，而不同的实现也会有其不同的特点。\r\n由于MPI提供了统一的编程接口，程序员只需要设计好并行算法，使用相应的MPI库就可以实现基于消息传递的并行计算。MPI支持多种操作系统，包括大多数的类UNIX和Windows系统。', 'upload/lab/cover_5.png', '3', null, null);
INSERT INTO `knowledges` VALUES ('6', 'OpenMP 编程实训', 'OpenMP（Open Multi-Processing）是一套支持跨平台共享内存方式的多线程并发的编程API，使用C,C++和Fortran语言，可以在大多数的处理器体系和操作系统中运行，包括Solaris, AIX, HP-UX, GNU/Linux, Mac OS X, 和Microsoft Windows。包括一套编译器指令、库和一些能够影响运行行为的环境变量。\r\nOpenMP采用可移植的、可扩展的模型，为程序员提供了一个简单而灵活的开发平台，从标准桌面电脑到超级计算机的并行应用程序接口。', 'upload/lab/cover_6.png', '3', null, null);

-- ----------------------------
-- Table structure for `lab`
-- ----------------------------
DROP TABLE IF EXISTS `lab`;
CREATE TABLE `lab` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `knowledge_id` int(11) NOT NULL,
  `knowledge_type` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of lab
-- ----------------------------

-- ----------------------------
-- Table structure for `lab_programs`
-- ----------------------------
DROP TABLE IF EXISTS `lab_programs`;
CREATE TABLE `lab_programs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_code` text NOT NULL,
  `default_code` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of lab_programs
-- ----------------------------
INSERT INTO `lab_programs` VALUES ('1', '#include<iostream>\r\nusing namespace std;\r\nint main()\r\n{\r\n  cout<<\"hello world\"<<endl;\r\n}', '#include<iostream>\r\nusing namespace std;\r\nint main()\r\n{\r\n  \r\n}');

-- ----------------------------
-- Table structure for `lessons`
-- ----------------------------
DROP TABLE IF EXISTS `lessons`;
CREATE TABLE `lessons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` int(11) NOT NULL,
  `title` varchar(128) NOT NULL,
  `content` text,
  `courseId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courseId` (`courseId`),
  CONSTRAINT `lessons_ibfk_1` FOREIGN KEY (`courseId`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of lessons
-- ----------------------------
INSERT INTO `lessons` VALUES ('6', '2', '并行计算简介', '', '2');
INSERT INTO `lessons` VALUES ('9', '2', 'OpenMP', '', '2');
INSERT INTO `lessons` VALUES ('10', '2', 'MPI', '', '2');
INSERT INTO `lessons` VALUES ('11', '3', 'Why Parallel Programming?', '', '3');
INSERT INTO `lessons` VALUES ('12', '3', 'Parallel Architecture', '', '3');
INSERT INTO `lessons` VALUES ('13', '3', 'Parallel Programming Models', '', '3');
INSERT INTO `lessons` VALUES ('14', '3', 'Parallel Programming Methodology', '', '3');
INSERT INTO `lessons` VALUES ('15', '3', 'Parallel Programming Performance', '', '3');
INSERT INTO `lessons` VALUES ('16', '3', 'Shared memory programming and OpenMP', '', '3');
INSERT INTO `lessons` VALUES ('17', '3', 'Thread Programming with TBB', '', '3');
INSERT INTO `lessons` VALUES ('18', '3', 'Programming Using the Message Passing Paradigm', '', '3');
INSERT INTO `lessons` VALUES ('19', '3', 'Introduction to GPGPUs and Cuda Programming Model 2h', '', '3');
INSERT INTO `lessons` VALUES ('20', '3', 'Parallel Computing with MapReduce', '', '3');
INSERT INTO `lessons` VALUES ('21', '3', 'Experiment', '', '3');
INSERT INTO `lessons` VALUES ('22', '4', 'Introduction', '', '4');
INSERT INTO `lessons` VALUES ('23', '4', 'Introduction to parallel algorithms and correctness', '', '4');
INSERT INTO `lessons` VALUES ('24', '4', 'Parallel Computing Platforms, Memory Systems and Models of Execution', '', '4');
INSERT INTO `lessons` VALUES ('25', '4', 'Memory Systems and Introduction to Shared Memory Programming ', '', '4');
INSERT INTO `lessons` VALUES ('26', '4', 'Data Parallelism in OpenMP', '', '4');
INSERT INTO `lessons` VALUES ('27', '4', 'Data Dependences', '', '4');
INSERT INTO `lessons` VALUES ('28', '4', 'Data Locality', '', '4');
INSERT INTO `lessons` VALUES ('29', '4', 'Singular Value Decomposition', '', '4');
INSERT INTO `lessons` VALUES ('30', '4', 'More Locality and Data Parallelism', '', '4');
INSERT INTO `lessons` VALUES ('31', '4', 'Data Parallelism', '', '4');
INSERT INTO `lessons` VALUES ('32', '4', 'Breaking Dependences, and Introduction to Task Parallelism ', '', '4');
INSERT INTO `lessons` VALUES ('33', '4', 'OpenMP sections and tasks', '', '4');
INSERT INTO `lessons` VALUES ('34', '4', 'Midterm Review ', '', '4');
INSERT INTO `lessons` VALUES ('35', '4', 'Introduction to Message Passing', '', '4');
INSERT INTO `lessons` VALUES ('36', '4', 'MPI Communication', '', '4');
INSERT INTO `lessons` VALUES ('37', '4', 'Putting it Together: N-Body', '', '4');
INSERT INTO `lessons` VALUES ('38', '4', 'Introduction to GPUs and CUDA', '', '4');
INSERT INTO `lessons` VALUES ('39', '4', 'CUDA, cont.', '', '4');
INSERT INTO `lessons` VALUES ('40', '4', 'CUDA, cont.', '', '4');
INSERT INTO `lessons` VALUES ('41', '4', 'SIMD multimedia extensions', '', '4');
INSERT INTO `lessons` VALUES ('42', '4', 'Sparse Algorithms', '', '4');
INSERT INTO `lessons` VALUES ('43', '4', 'Parallel Graph Algorithms', '', '4');
INSERT INTO `lessons` VALUES ('44', '4', 'Course Retrospective and Future Directions for Parallel Computing', '', '4');
INSERT INTO `lessons` VALUES ('45', '5', 'Course Intro', '', '5');
INSERT INTO `lessons` VALUES ('46', '5', 'Parallel Architectures and Performance', '', '5');
INSERT INTO `lessons` VALUES ('47', '5', 'Details of MPI', '', '5');
INSERT INTO `lessons` VALUES ('48', '5', ' Parallel Performance', '', '5');
INSERT INTO `lessons` VALUES ('49', '5', 'Matrix Computations: Direct Methods', '', '5');
INSERT INTO `lessons` VALUES ('50', '5', 'Matrix Computations: Iterative methods', '', '5');
INSERT INTO `lessons` VALUES ('51', '5', ' OpenMP Programming I and II', '', '5');
INSERT INTO `lessons` VALUES ('52', '5', 'Fast Methods for N-body Problems', '', '5');
INSERT INTO `lessons` VALUES ('53', '5', ' Multigrid and Its Parallel Implementation in CFD Solvers', '', '5');
INSERT INTO `lessons` VALUES ('54', '5', 'Domain Decomposition I', '', '5');
INSERT INTO `lessons` VALUES ('55', '5', 'Domain Decomposition II', '', '5');
INSERT INTO `lessons` VALUES ('56', '5', 'Parallel FFT Algorithms', '', '5');
INSERT INTO `lessons` VALUES ('57', '6', 'An introduction to CUDA', '', '6');
INSERT INTO `lessons` VALUES ('58', '6', 'Different memory and variable types', '', '6');
INSERT INTO `lessons` VALUES ('59', '6', 'Control flow and synchronisation', '', '6');
INSERT INTO `lessons` VALUES ('60', '6', 'Warp shuffles, and reduction / scan operations', '', '6');
INSERT INTO `lessons` VALUES ('61', '6', 'Libraries and tools', '', '6');
INSERT INTO `lessons` VALUES ('62', '6', 'Multiple GPUs, and odds and ends', '', '6');
INSERT INTO `lessons` VALUES ('63', '6', 'Tackling a new CUDA application', '', '6');
INSERT INTO `lessons` VALUES ('64', '6', 'A case study', '', '6');
INSERT INTO `lessons` VALUES ('65', '6', 'Memory optimisations', '', '6');
INSERT INTO `lessons` VALUES ('66', '6', 'Profiling and tuning applications', '', '6');
INSERT INTO `lessons` VALUES ('67', '6', 'Pascal and CUDA 8.0', '', '6');
INSERT INTO `lessons` VALUES ('69', '1', 'Parallel Computing', '', '1');
INSERT INTO `lessons` VALUES ('70', '1', '并行计算——结构·算法·编程 第一章并行计算机系统及结构  第二章 当代并行机系统  第三章 并行计算性能评测', '', '1');
INSERT INTO `lessons` VALUES ('71', '1', '并行算法的设计基础', '', '1');
INSERT INTO `lessons` VALUES ('72', '1', '并行算法的一般设计方法', '', '1');
INSERT INTO `lessons` VALUES ('73', '1', '并行算法的基本设计技术', '', '1');
INSERT INTO `lessons` VALUES ('74', '1', '并行算法的一般设计过程', '', '1');
INSERT INTO `lessons` VALUES ('75', '1', '基本通讯操作', '', '1');
INSERT INTO `lessons` VALUES ('76', '1', '稠密矩阵运算', '', '1');
INSERT INTO `lessons` VALUES ('77', '1', '线性方程组的求解', '', '1');
INSERT INTO `lessons` VALUES ('78', '1', '快速傅里叶变换', '', '1');
INSERT INTO `lessons` VALUES ('79', '1', '并行程序设计基础', '', '1');
INSERT INTO `lessons` VALUES ('80', '1', '共享存储系统编程', '', '1');
INSERT INTO `lessons` VALUES ('81', '1', '分布存储系统并行编程', '', '1');
INSERT INTO `lessons` VALUES ('82', '1', '并行程序设计环境与工具', '', '1');
INSERT INTO `lessons` VALUES ('83', '1', 'Architectures Parallel Computing :Architectures· Algorithms Algorithms·Programming', '', '1');
INSERT INTO `lessons` VALUES ('84', '1', 'Parallel Computer System Part I : Parallel Computer System Architectures', '', '1');
INSERT INTO `lessons` VALUES ('85', '1', 'Parallel Computational Models Part II: Parallel Computational Models', '', '1');
INSERT INTO `lessons` VALUES ('86', '1', 'Parallel Programming Part III:Parallel Programming Models', '', '1');
INSERT INTO `lessons` VALUES ('87', '10', '绪论', '', '10');
INSERT INTO `lessons` VALUES ('88', '10', '性能测评', '', '10');
INSERT INTO `lessons` VALUES ('89', '10', '互联网络', '', '10');
INSERT INTO `lessons` VALUES ('90', '10', '对称多处理机系统', '', '10');
INSERT INTO `lessons` VALUES ('91', '10', '大规模并行处理机系统', '', '10');
INSERT INTO `lessons` VALUES ('92', '10', '机群系统', '', '10');
INSERT INTO `lessons` VALUES ('93', '10', '分布共享存储系统', '', '10');
INSERT INTO `lessons` VALUES ('94', '10', '并行机中的通信与延迟问题', '', '10');
INSERT INTO `lessons` VALUES ('95', '11', '并行算法基础', '', '11');
INSERT INTO `lessons` VALUES ('96', '11', '并行算大的基本设计技术', '', '11');
INSERT INTO `lessons` VALUES ('97', '11', '比较器网络上的排序和选择算法', '', '11');
INSERT INTO `lessons` VALUES ('98', '11', '排序和选择的同步算法', '', '11');
INSERT INTO `lessons` VALUES ('99', '11', '排序和选择的异步和分布式算法', '', '11');
INSERT INTO `lessons` VALUES ('100', '11', '并行搜索', '', '11');
INSERT INTO `lessons` VALUES ('101', '11', '数据传输与选路', '', '11');
INSERT INTO `lessons` VALUES ('102', '11', '矩阵运算', '', '11');
INSERT INTO `lessons` VALUES ('103', '11', '数值计算', '', '11');
INSERT INTO `lessons` VALUES ('104', '11', '快速傅里叶变换FFT', '', '11');
INSERT INTO `lessons` VALUES ('105', '11', '图论算法', '', '11');
INSERT INTO `lessons` VALUES ('106', '11', '组合搜索', '', '11');
INSERT INTO `lessons` VALUES ('107', '11', '随机算法', '', '11');
INSERT INTO `lessons` VALUES ('108', '9', '并行编程初步', '', '9');
INSERT INTO `lessons` VALUES ('109', '9', 'MPI并行程序设计---参考资料', '', '9');
INSERT INTO `lessons` VALUES ('110', '12', '高性能计算概述', '', '12');
INSERT INTO `lessons` VALUES ('111', '12', '并行程序模型', '', '12');
INSERT INTO `lessons` VALUES ('112', '12', 'In-core性能优化与工具', '', '12');
INSERT INTO `lessons` VALUES ('113', '12', '实验环境介绍', '', '12');
INSERT INTO `lessons` VALUES ('114', '12', 'OpenMP编程', '', '12');
INSERT INTO `lessons` VALUES ('115', '12', 'OpenMP习题课', '', '12');
INSERT INTO `lessons` VALUES ('116', '12', 'MPI编程', '', '12');
INSERT INTO `lessons` VALUES ('117', '12', '并行程序性能优化', '', '12');
INSERT INTO `lessons` VALUES ('118', '12', 'GPU与加速计算', '', '12');
INSERT INTO `lessons` VALUES ('119', '12', 'data-flow-computing', '', '12');
INSERT INTO `lessons` VALUES ('120', '12', '众核编程基础', '', '12');
INSERT INTO `lessons` VALUES ('121', '12', '并行和优化案例', '', '12');
INSERT INTO `lessons` VALUES ('122', '14', '概述（1）', '', '14');
INSERT INTO `lessons` VALUES ('124', '14', '概述（2）', '', '14');
INSERT INTO `lessons` VALUES ('125', '14', 'POSIX线程编程基础', '', '14');
INSERT INTO `lessons` VALUES ('126', '14', 'Pthreads线程的同步', '', '14');
INSERT INTO `lessons` VALUES ('127', '14', 'Pthreads的并行算法编码', '', '14');
INSERT INTO `lessons` VALUES ('128', '14', '并行计算区的计算划分', '', '14');
INSERT INTO `lessons` VALUES ('129', '14', '并行计算区的并发数据访问冲突', '', '14');
INSERT INTO `lessons` VALUES ('130', '14', 'MPI并行编程技术概述', '', '14');
INSERT INTO `lessons` VALUES ('131', '14', 'MPI程序的资源分配与管理', '', '14');
INSERT INTO `lessons` VALUES ('132', '14', '自定义数据类型和“点到点”的数据交换', '', '14');
INSERT INTO `lessons` VALUES ('133', '14', '进程之间的群通信、单边通信、共享文件访问', '', '14');
INSERT INTO `lessons` VALUES ('134', '14', '并行算法设计', '', '14');
INSERT INTO `lessons` VALUES ('135', '14', '专业化的并行编程模型（1）', '', '14');
INSERT INTO `lessons` VALUES ('136', '14', '专业化的并行编程模型（2）', '', '14');
INSERT INTO `lessons` VALUES ('147', '32', 'Overview', '', '32');
INSERT INTO `lessons` VALUES ('148', '32', 'Cloud Computing', '', '32');
INSERT INTO `lessons` VALUES ('149', '32', 'Time, Clocks and the Ordering of Events', '', '32');

-- ----------------------------
-- Table structure for `machine_account`
-- ----------------------------
DROP TABLE IF EXISTS `machine_account`;
CREATE TABLE `machine_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(64) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL,
  `key` varchar(256) DEFAULT NULL,
  `ip` varchar(64) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `token` varchar(64) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `sc_center` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `machine_account_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of machine_account
-- ----------------------------

-- ----------------------------
-- Table structure for `machine_apply`
-- ----------------------------
DROP TABLE IF EXISTS `machine_apply`;
CREATE TABLE `machine_apply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `applicant_name` varchar(64) DEFAULT NULL,
  `applicant_institution` varchar(64) DEFAULT NULL,
  `applicant_tel` varchar(64) DEFAULT NULL,
  `applicant_email` varchar(64) DEFAULT NULL,
  `applicant_address` varchar(128) DEFAULT NULL,
  `manager_name` varchar(64) DEFAULT NULL,
  `manager_institution` varchar(64) DEFAULT NULL,
  `manager_tel` varchar(64) DEFAULT NULL,
  `manager_email` varchar(64) DEFAULT NULL,
  `manager_address` varchar(128) DEFAULT NULL,
  `project_name` varchar(128) DEFAULT NULL,
  `sc_center` int(11) DEFAULT NULL,
  `cpu_hour` int(11) DEFAULT NULL,
  `usage` varchar(512) DEFAULT NULL,
  `applying_time` datetime NOT NULL,
  `submit_status` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `machine_apply_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of machine_apply
-- ----------------------------
INSERT INTO `machine_apply` VALUES ('1', '姓名1', '单位1', '123456', '123456@qq.com', '地址1', '', '', '', '', '', '高性能教育实践平台', '0', '10000', '用途', '2017-06-02 06:06:09', '1', '3');

-- ----------------------------
-- Table structure for `materials`
-- ----------------------------
DROP TABLE IF EXISTS `materials`;
CREATE TABLE `materials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(1024) NOT NULL,
  `uri` varchar(2048) DEFAULT NULL,
  `lessonId` int(11) DEFAULT NULL,
  `m_type` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `lessonId` (`lessonId`),
  CONSTRAINT `materials_ibfk_1` FOREIGN KEY (`lessonId`) REFERENCES `lessons` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=263 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of materials
-- ----------------------------
INSERT INTO `materials` VALUES ('84', 'lecture2.pdf', 'course_2/lesson6_material84.pdf', '6', 'pdf');
INSERT INTO `materials` VALUES ('85', 'lecture4.pdf', 'course_2/lesson6_material85.pdf', '6', 'pdf');
INSERT INTO `materials` VALUES ('86', 'lecture5.pdf', 'course_2/lesson6_material86.pdf', '6', 'pdf');
INSERT INTO `materials` VALUES ('87', 'lecture9.pdf', 'course_2/lesson10_material87.pdf', '10', 'pdf');
INSERT INTO `materials` VALUES ('88', 'lecture10.pdf', 'course_2/lesson10_material88.pdf', '10', 'pdf');
INSERT INTO `materials` VALUES ('89', 'lecture11.pdf', 'course_2/lesson10_material89.pdf', '10', 'pdf');
INSERT INTO `materials` VALUES ('90', 'lecture12.pdf', 'course_2/lesson10_material90.pdf', '10', 'pdf');
INSERT INTO `materials` VALUES ('91', 'lect5.pdf', 'course_3/lesson15_material91.pdf', '15', 'pdf');
INSERT INTO `materials` VALUES ('92', 'lect10.pdf', 'course_3/lesson20_material92.pdf', '20', 'pdf');
INSERT INTO `materials` VALUES ('93', 'lect11.pdf', 'course_3/lesson21_material93.pdf', '21', 'pdf');
INSERT INTO `materials` VALUES ('94', 'CS4230-L1.pdf', 'course_4/lesson22_material94.pdf', '22', 'pdf');
INSERT INTO `materials` VALUES ('95', 'CS4230-L2.pdf', 'course_4/lesson23_material95.pdf', '23', 'pdf');
INSERT INTO `materials` VALUES ('96', 'CS4230-L3.pdf', 'course_4/lesson24_material96.pdf', '24', 'pdf');
INSERT INTO `materials` VALUES ('97', 'CS4230-L4.pdf', 'course_4/lesson25_material97.pdf', '25', 'pdf');
INSERT INTO `materials` VALUES ('98', 'CS4230-L5.pdf', 'course_4/lesson26_material98.pdf', '26', 'pdf');
INSERT INTO `materials` VALUES ('99', 'CS4230-L6.pdf', 'course_4/lesson27_material99.pdf', '27', 'pdf');
INSERT INTO `materials` VALUES ('100', 'CS4230-L7.pdf', 'course_4/lesson28_material100.pdf', '28', 'pdf');
INSERT INTO `materials` VALUES ('101', 'SVD-L8.pdf', 'course_4/lesson29_material101.pdf', '29', 'pdf');
INSERT INTO `materials` VALUES ('102', 'CS4230-L9.pdf', 'course_4/lesson30_material102.pdf', '30', 'pdf');
INSERT INTO `materials` VALUES ('103', 'CS4230-L10.pdf', 'course_4/lesson31_material103.pdf', '31', 'pdf');
INSERT INTO `materials` VALUES ('104', 'CS4230-L11.pdf', 'course_4/lesson32_material104.pdf', '32', 'pdf');
INSERT INTO `materials` VALUES ('105', 'CS4230-L12.pdf', 'course_4/lesson33_material105.pdf', '33', 'pdf');
INSERT INTO `materials` VALUES ('106', '2011midterm.pdf', 'course_4/lesson34_material106.pdf', '34', 'pdf');
INSERT INTO `materials` VALUES ('107', 'CS4230-L13.pdf', 'course_4/lesson35_material107.pdf', '35', 'pdf');
INSERT INTO `materials` VALUES ('108', 'CS4230-L14.pdf', 'course_4/lesson36_material108.pdf', '36', 'pdf');
INSERT INTO `materials` VALUES ('110', 'CS4230-L16.pdf', 'course_4/lesson38_material110.pdf', '38', 'pdf');
INSERT INTO `materials` VALUES ('111', 'CS4230-L18.pdf', 'course_4/lesson40_material111.pdf', '40', 'pdf');
INSERT INTO `materials` VALUES ('112', 'CS4230-L19.pdf', 'course_4/lesson41_material112.pdf', '41', 'pdf');
INSERT INTO `materials` VALUES ('113', 'CS4230-L20.pdf', 'course_4/lesson42_material113.pdf', '42', 'pdf');
INSERT INTO `materials` VALUES ('114', 'lecture3-14.pdf', 'course_5/lesson47_material114.pdf', '47', 'pdf');
INSERT INTO `materials` VALUES ('115', 'lecture4-14.pdf', 'course_5/lesson47_material115.pdf', '47', 'pdf');
INSERT INTO `materials` VALUES ('116', 'lecture5-14.pdf', 'course_5/lesson47_material116.pdf', '47', 'pdf');
INSERT INTO `materials` VALUES ('117', 'lecture7-14_1.pdf', 'course_5/lesson48_material117.pdf', '48', 'pdf');
INSERT INTO `materials` VALUES ('118', 'lecture8-14.pdf', 'course_5/lesson49_material118.pdf', '49', 'pdf');
INSERT INTO `materials` VALUES ('119', 'lecture10-14.pdf', 'course_5/lesson50_material119.pdf', '50', 'pdf');
INSERT INTO `materials` VALUES ('120', 'lecture11-14.pdf', 'course_5/lesson50_material120.pdf', '50', 'pdf');
INSERT INTO `materials` VALUES ('121', 'lecture13-14.pdf', 'course_5/lesson51_material121.pdf', '51', 'pdf');
INSERT INTO `materials` VALUES ('122', 'lecture15-14.pdf', 'course_5/lesson54_material122.pdf', '54', 'pdf');
INSERT INTO `materials` VALUES ('123', 'lecture24-14.pdf', 'course_5/lesson56_material123.pdf', '56', 'pdf');
INSERT INTO `materials` VALUES ('124', 'lec1.pdf', 'course_6/lesson57_material124.pdf', '57', 'pdf');
INSERT INTO `materials` VALUES ('125', 'lec2.pdf', 'course_6/lesson58_material125.pdf', '58', 'pdf');
INSERT INTO `materials` VALUES ('126', 'lec3.pdf', 'course_6/lesson59_material126.pdf', '59', 'pdf');
INSERT INTO `materials` VALUES ('127', 'lec4.pdf', 'course_6/lesson60_material127.pdf', '60', 'pdf');
INSERT INTO `materials` VALUES ('128', 'lec5.pdf', 'course_6/lesson61_material128.pdf', '61', 'pdf');
INSERT INTO `materials` VALUES ('129', 'lec6.pdf', 'course_6/lesson62_material129.pdf', '62', 'pdf');
INSERT INTO `materials` VALUES ('130', 'lec7.pdf', 'course_6/lesson63_material130.pdf', '63', 'pdf');
INSERT INTO `materials` VALUES ('131', 'case_study.pdf', 'course_6/lesson64_material131.pdf', '64', 'pdf');
INSERT INTO `materials` VALUES ('133', 'lecture1.pdf', 'course_2/lesson6_material133.pdf', '6', 'pdf');
INSERT INTO `materials` VALUES ('134', 'lecture3.pdf', 'course_2/lesson6_material134.pdf', '6', 'pdf');
INSERT INTO `materials` VALUES ('135', 'lecture6.pdf', 'course_2/lesson9_material135.pdf', '9', 'pdf');
INSERT INTO `materials` VALUES ('136', 'lecture7.pdf', 'course_2/lesson9_material136.pdf', '9', 'pdf');
INSERT INTO `materials` VALUES ('137', 'lecture8.pdf', 'course_2/lesson9_material137.pdf', '9', 'pdf');
INSERT INTO `materials` VALUES ('138', 'lect1.pdf', 'course_3/lesson11_material138.pdf', '11', 'pdf');
INSERT INTO `materials` VALUES ('139', 'lect2.pdf', 'course_3/lesson12_material139.pdf', '12', 'pdf');
INSERT INTO `materials` VALUES ('140', 'lect3.pdf', 'course_3/lesson13_material140.pdf', '13', 'pdf');
INSERT INTO `materials` VALUES ('141', 'lect4.pdf', 'course_3/lesson14_material141.pdf', '14', 'pdf');
INSERT INTO `materials` VALUES ('142', 'lect6.pdf', 'course_3/lesson16_material142.pdf', '16', 'pdf');
INSERT INTO `materials` VALUES ('143', 'lect7.pdf', 'course_3/lesson17_material143.pdf', '17', 'pdf');
INSERT INTO `materials` VALUES ('147', 'CS4230-L17.pdf', 'course_4/lesson39_material147.pdf', '39', 'pdf');
INSERT INTO `materials` VALUES ('149', 'CS4230-L21.pdf', 'course_4/lesson44_material149.pdf', '44', 'pdf');
INSERT INTO `materials` VALUES ('150', 'CS4230-L20.pdf', 'course_4/lesson43_material150.pdf', '43', 'pdf');
INSERT INTO `materials` VALUES ('151', 'lecture1-14.pdf', 'course_5/lesson45_material151.pdf', '45', 'pdf');
INSERT INTO `materials` VALUES ('152', 'lecture2-14.pdf', 'course_5/lesson46_material152.pdf', '46', 'pdf');
INSERT INTO `materials` VALUES ('153', 'lecture6-14.pdf', 'course_5/lesson48_material153.pdf', '48', 'pdf');
INSERT INTO `materials` VALUES ('154', 'lecture9-14.pdf', 'course_5/lesson49_material154.pdf', '49', 'pdf');
INSERT INTO `materials` VALUES ('155', 'lecture13-14_1.pdf', 'course_5/lesson52_material155.pdf', '52', 'pdf');
INSERT INTO `materials` VALUES ('156', 'lecture14-14.pdf', 'course_5/lesson53_material156.pdf', '53', 'pdf');
INSERT INTO `materials` VALUES ('157', 'parallelMultigrid.pdf', 'course_5/lesson53_material157.pdf', '53', 'pdf');
INSERT INTO `materials` VALUES ('158', 'lecture14a-14.pdf', 'course_5/lesson53_material158.pdf', '53', 'pdf');
INSERT INTO `materials` VALUES ('159', 'memory2.pdf', 'course_6/lesson65_material159.pdf', '65', 'pdf');
INSERT INTO `materials` VALUES ('160', 'Pascal_and_CUDA_8.0.pdf', 'course_6/lesson67_material160.pdf', '67', 'pdf');
INSERT INTO `materials` VALUES ('161', 'profiling2.pdf', 'course_6/lesson66_material161.pdf', '66', 'pdf');
INSERT INTO `materials` VALUES ('162', 'PC0.pdf', 'course_1/lesson69_material162.pdf', '69', 'pdf');
INSERT INTO `materials` VALUES ('163', 'PC1-3.pdf', 'course_1/lesson70_material163.pdf', '70', 'pdf');
INSERT INTO `materials` VALUES ('164', 'PC4.pdf', 'course_1/lesson71_material164.pdf', '71', 'pdf');
INSERT INTO `materials` VALUES ('165', 'PC5.pdf', 'course_1/lesson72_material165.pdf', '72', 'pdf');
INSERT INTO `materials` VALUES ('166', 'PC6.pdf', 'course_1/lesson73_material166.pdf', '73', 'pdf');
INSERT INTO `materials` VALUES ('167', 'PC7.pdf', 'course_1/lesson74_material167.pdf', '74', 'pdf');
INSERT INTO `materials` VALUES ('168', 'PC8.pdf', 'course_1/lesson75_material168.pdf', '75', 'pdf');
INSERT INTO `materials` VALUES ('169', 'PC9.pdf', 'course_1/lesson76_material169.pdf', '76', 'pdf');
INSERT INTO `materials` VALUES ('170', 'PC10.pdf', 'course_1/lesson77_material170.pdf', '77', 'pdf');
INSERT INTO `materials` VALUES ('171', 'PC11.pdf', 'course_1/lesson78_material171.pdf', '78', 'pdf');
INSERT INTO `materials` VALUES ('172', 'PC13.pdf', 'course_1/lesson80_material172.pdf', '80', 'pdf');
INSERT INTO `materials` VALUES ('173', 'PC12.pdf', 'course_1/lesson79_material173.pdf', '79', 'pdf');
INSERT INTO `materials` VALUES ('174', 'PC14.pdf', 'course_1/lesson81_material174.pdf', '81', 'pdf');
INSERT INTO `materials` VALUES ('175', 'PC15.pdf', 'course_1/lesson82_material175.pdf', '82', 'pdf');
INSERT INTO `materials` VALUES ('176', 'outline.pdf', 'course_1/lesson83_material176.pdf', '83', 'pdf');
INSERT INTO `materials` VALUES ('177', 'partI.pdf', 'course_1/lesson84_material177.pdf', '84', 'pdf');
INSERT INTO `materials` VALUES ('178', 'partII.pdf', 'course_1/lesson85_material178.pdf', '85', 'pdf');
INSERT INTO `materials` VALUES ('179', 'partIII.pdf', 'course_1/lesson86_material179.pdf', '86', 'pdf');
INSERT INTO `materials` VALUES ('180', 'lec01-intro.pdf', 'course_10/lesson87_material180.pdf', '87', 'pdf');
INSERT INTO `materials` VALUES ('181', 'lec02-ParaarchTechissue.pdf', 'course_10/lesson88_material181.pdf', '88', 'pdf');
INSERT INTO `materials` VALUES ('182', 'lec03-evaluation.pdf', 'course_10/lesson88_material182.pdf', '88', 'pdf');
INSERT INTO `materials` VALUES ('183', 'lec05-interconnect.pdf', 'course_10/lesson89_material183.pdf', '89', 'pdf');
INSERT INTO `materials` VALUES ('184', 'lec06-interconnect2.pdf', 'course_10/lesson89_material184.pdf', '89', 'pdf');
INSERT INTO `materials` VALUES ('185', 'lec04-performance.pdf', 'course_10/lesson88_material185.pdf', '88', 'pdf');
INSERT INTO `materials` VALUES ('186', 'lec07-SMP.pdf', 'course_10/lesson90_material186.pdf', '90', 'pdf');
INSERT INTO `materials` VALUES ('187', 'lec08-SMP2.pdf', 'course_10/lesson90_material187.pdf', '90', 'pdf');
INSERT INTO `materials` VALUES ('188', 'lec09-SMP3.pdf', 'course_10/lesson90_material188.pdf', '90', 'pdf');
INSERT INTO `materials` VALUES ('189', 'lec10-SMP4.pdf', 'course_10/lesson90_material189.pdf', '90', 'pdf');
INSERT INTO `materials` VALUES ('190', 'lec11-MPP1.pdf', 'course_10/lesson91_material190.pdf', '91', 'pdf');
INSERT INTO `materials` VALUES ('191', 'lec12-CLUSTER.pdf', 'course_10/lesson92_material191.pdf', '92', 'pdf');
INSERT INTO `materials` VALUES ('192', 'lec13-CLUSTER2.pdf', 'course_10/lesson92_material192.pdf', '92', 'pdf');
INSERT INTO `materials` VALUES ('193', 'lec14-Cluster3-DSM1.pdf', 'course_10/lesson93_material193.pdf', '93', 'pdf');
INSERT INTO `materials` VALUES ('194', 'lec15-DSM2.pdf', 'course_10/lesson93_material194.pdf', '93', 'pdf');
INSERT INTO `materials` VALUES ('195', 'lec16-latency.pdf', 'course_10/lesson94_material195.pdf', '94', 'pdf');
INSERT INTO `materials` VALUES ('196', 'ch1.pdf', 'course_11/lesson95_material196.pdf', '95', 'pdf');
INSERT INTO `materials` VALUES ('197', 'ch2.pdf', 'course_11/lesson96_material197.pdf', '96', 'pdf');
INSERT INTO `materials` VALUES ('198', 'ch3.pdf', 'course_11/lesson97_material198.pdf', '97', 'pdf');
INSERT INTO `materials` VALUES ('199', 'ch4.pdf', 'course_11/lesson98_material199.pdf', '98', 'pdf');
INSERT INTO `materials` VALUES ('200', 'ch5.pdf', 'course_11/lesson99_material200.pdf', '99', 'pdf');
INSERT INTO `materials` VALUES ('201', 'ch6.pdf', 'course_11/lesson100_material201.pdf', '100', 'pdf');
INSERT INTO `materials` VALUES ('202', 'ch8.pdf', 'course_11/lesson101_material202.pdf', '101', 'pdf');
INSERT INTO `materials` VALUES ('203', 'ch12.pdf', 'course_11/lesson102_material203.pdf', '102', 'pdf');
INSERT INTO `materials` VALUES ('204', 'ch13.pdf', 'course_11/lesson103_material204.pdf', '103', 'pdf');
INSERT INTO `materials` VALUES ('205', 'ch14.pdf', 'course_11/lesson104_material205.pdf', '104', 'pdf');
INSERT INTO `materials` VALUES ('206', 'ch15.pdf', 'course_11/lesson105_material206.pdf', '105', 'pdf');
INSERT INTO `materials` VALUES ('207', 'ch17.pdf', 'course_11/lesson106_material207.pdf', '106', 'pdf');
INSERT INTO `materials` VALUES ('208', 'ch18.pdf', 'course_11/lesson107_material208.pdf', '107', 'pdf');
INSERT INTO `materials` VALUES ('209', 'MPI编程初步.pdf', 'course_9/lesson108_material209.pdf', '108', 'pdf');
INSERT INTO `materials` VALUES ('210', 'mpi.pdf', 'course_9/lesson109_material210.pdf', '109', 'pdf');
INSERT INTO `materials` VALUES ('214', '高性能计算概述.pdf', 'course_12/lesson110_material214.pdf', '110', 'pdf');
INSERT INTO `materials` VALUES ('215', '并行程序模型.pdf', 'course_12/lesson111_material215.pdf', '111', 'pdf');
INSERT INTO `materials` VALUES ('216', 'In-core性能优化与工具Part2.pdf', 'course_12/lesson112_material216.pdf', '112', 'pdf');
INSERT INTO `materials` VALUES ('217', 'In-core性能优化与工具part1.pdf', 'course_12/lesson112_material217.pdf', '112', 'pdf');
INSERT INTO `materials` VALUES ('218', '实验环境介绍.pdf', 'course_12/lesson113_material218.pdf', '113', 'pdf');
INSERT INTO `materials` VALUES ('219', 'OpenMP编程.pdf', 'course_12/lesson114_material219.pdf', '114', 'pdf');
INSERT INTO `materials` VALUES ('220', 'OpenMP习题课.pdf', 'course_12/lesson115_material220.pdf', '115', 'pdf');
INSERT INTO `materials` VALUES ('221', 'MPI编程1.pdf', 'course_12/lesson116_material221.pdf', '116', 'pdf');
INSERT INTO `materials` VALUES ('222', 'MPI编程2.pdf', 'course_12/lesson116_material222.pdf', '116', 'pdf');
INSERT INTO `materials` VALUES ('223', 'Part1-并行程序性能优化.pdf', 'course_12/lesson117_material223.pdf', '117', 'pdf');
INSERT INTO `materials` VALUES ('224', 'Part2-并行程序性能优化.pdf', 'course_12/lesson117_material224.pdf', '117', 'pdf');
INSERT INTO `materials` VALUES ('225', 'Part3-并行程序性能优化.pdf', 'course_12/lesson117_material225.pdf', '117', 'pdf');
INSERT INTO `materials` VALUES ('226', 'GPU与加速计算.pdf', 'course_12/lesson118_material226.pdf', '118', 'pdf');
INSERT INTO `materials` VALUES ('227', 'data-flow-computing.pdf', 'course_12/lesson119_material227.pdf', '119', 'pdf');
INSERT INTO `materials` VALUES ('228', '众核编程基础.pdf', 'course_12/lesson120_material228.pdf', '120', 'pdf');
INSERT INTO `materials` VALUES ('229', '并行和优化案例.pdf', 'course_12/lesson121_material229.pdf', '121', 'pdf');
INSERT INTO `materials` VALUES ('230', '2016_1.pdf', 'course_14/lesson122_material230.pdf', '122', 'pdf');
INSERT INTO `materials` VALUES ('231', '2016_2.pdf', 'course_14/lesson124_material231.pdf', '124', 'pdf');
INSERT INTO `materials` VALUES ('232', '2016_3.pdf', 'course_14/lesson125_material232.pdf', '125', 'pdf');
INSERT INTO `materials` VALUES ('233', '2016_4.pdf', 'course_14/lesson126_material233.pdf', '126', 'pdf');
INSERT INTO `materials` VALUES ('234', '2016_5.pdf', 'course_14/lesson127_material234.pdf', '127', 'pdf');
INSERT INTO `materials` VALUES ('235', '2016_6.pdf', 'course_14/lesson128_material235.pdf', '128', 'pdf');
INSERT INTO `materials` VALUES ('236', '2016_7.pdf', 'course_14/lesson129_material236.pdf', '129', 'pdf');
INSERT INTO `materials` VALUES ('237', '2016_8.pdf', 'course_14/lesson130_material237.pdf', '130', 'pdf');
INSERT INTO `materials` VALUES ('238', '2016_9.pdf', 'course_14/lesson131_material238.pdf', '131', 'pdf');
INSERT INTO `materials` VALUES ('239', '2016_10.pdf', 'course_14/lesson132_material239.pdf', '132', 'pdf');
INSERT INTO `materials` VALUES ('240', '2016_11.pdf', 'course_14/lesson133_material240.pdf', '133', 'pdf');
INSERT INTO `materials` VALUES ('241', '2016_12.pdf', 'course_14/lesson134_material241.pdf', '134', 'pdf');
INSERT INTO `materials` VALUES ('242', '2016_13.pdf', 'course_14/lesson135_material242.pdf', '135', 'pdf');
INSERT INTO `materials` VALUES ('243', '2016_14.pdf', 'course_14/lesson136_material243.pdf', '136', 'pdf');
INSERT INTO `materials` VALUES ('259', '1_Overview.pdf', 'course_32/lesson147_material259.pdf', '147', 'pdf');
INSERT INTO `materials` VALUES ('260', '2_Cloud.pdf', 'course_32/lesson148_material260.pdf', '148', 'pdf');
INSERT INTO `materials` VALUES ('261', '3_Time_Part2.pdf', 'course_32/lesson149_material261.pdf', '149', 'pdf');
INSERT INTO `materials` VALUES ('262', '3_Time_Part1.pdf', 'course_32/lesson149_material262.pdf', '149', 'pdf');

-- ----------------------------
-- Table structure for `notices`
-- ----------------------------
DROP TABLE IF EXISTS `notices`;
CREATE TABLE `notices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(32) NOT NULL,
  `content` text,
  `createdTime` datetime DEFAULT NULL,
  `courseId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courseId` (`courseId`),
  CONSTRAINT `notices_ibfk_1` FOREIGN KEY (`courseId`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of notices
-- ----------------------------
INSERT INTO `notices` VALUES ('12', '系统测试公告', '系统测试公告\r\n系统测试公告系统测试公告系统测试公告\r\n系统测试公告\r\n系统测试公告\r\n系统测试公告系统测试公告系统测试公告', '2017-06-03 19:55:27', '1');
INSERT INTO `notices` VALUES ('13', '第二次作业提交公告', '不交作业的要挂科哈哈', '2017-06-03 19:55:45', '1');

-- ----------------------------
-- Table structure for `notifications`
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `create_time` datetime NOT NULL,
  `event_name` varchar(512) NOT NULL,
  `event_content` text NOT NULL,
  `sender_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of notifications
-- ----------------------------

-- ----------------------------
-- Table structure for `notifications_receivers`
-- ----------------------------
DROP TABLE IF EXISTS `notifications_receivers`;
CREATE TABLE `notifications_receivers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `is_read` tinyint(1) DEFAULT NULL,
  `read_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notification_id` (`notification_id`),
  KEY `receiver_id` (`receiver_id`),
  CONSTRAINT `notifications_receivers_ibfk_1` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`),
  CONSTRAINT `notifications_receivers_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of notifications_receivers
-- ----------------------------

-- ----------------------------
-- Table structure for `papers`
-- ----------------------------
DROP TABLE IF EXISTS `papers`;
CREATE TABLE `papers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `about` varchar(128) NOT NULL,
  `courseId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courseId` (`courseId`),
  CONSTRAINT `papers_ibfk_1` FOREIGN KEY (`courseId`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of papers
-- ----------------------------
INSERT INTO `papers` VALUES ('1', '测验1', '这是测验1', '1');
INSERT INTO `papers` VALUES ('2', '测验2', '这是测验2', '1');
INSERT INTO `papers` VALUES ('3', '测验3', '这是测验3', '1');

-- ----------------------------
-- Table structure for `paper_question`
-- ----------------------------
DROP TABLE IF EXISTS `paper_question`;
CREATE TABLE `paper_question` (
  `question_id` int(11) NOT NULL DEFAULT '0',
  `paper_id` int(11) NOT NULL DEFAULT '0',
  `point` int(11) NOT NULL,
  PRIMARY KEY (`question_id`,`paper_id`),
  KEY `question_id` (`question_id`),
  KEY `paper_id` (`paper_id`),
  CONSTRAINT `paper_question_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`),
  CONSTRAINT `paper_question_ibfk_2` FOREIGN KEY (`paper_id`) REFERENCES `papers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of paper_question
-- ----------------------------
INSERT INTO `paper_question` VALUES ('8', '1', '20');

-- ----------------------------
-- Table structure for `post`
-- ----------------------------
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(1024) NOT NULL,
  `topicID` int(11) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `topicID` (`topicID`),
  KEY `userID` (`userID`),
  CONSTRAINT `post_ibfk_1` FOREIGN KEY (`topicID`) REFERENCES `topics` (`id`),
  CONSTRAINT `post_ibfk_2` FOREIGN KEY (`userID`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of post
-- ----------------------------
INSERT INTO `post` VALUES ('1', '内容不错', '1', '1', '2016-09-10 00:00:00');
INSERT INTO `post` VALUES ('2', '坐等下篇', '1', '1', '2016-10-10 00:00:00');
INSERT INTO `post` VALUES ('3', '1212', '1', '1', '2016-10-15 17:07:45');
INSERT INTO `post` VALUES ('4', '@<a href=\"/user/1/\" class=\"mention\">root</a>  测试一下评论', '1', '1', '2016-10-15 19:36:58');
INSERT INTO `post` VALUES ('5', '新的评论啊', '1', '1', '2016-10-15 19:38:39');
INSERT INTO `post` VALUES ('6', '新的话题啊', '1', '1', '2016-10-15 19:40:29');
INSERT INTO `post` VALUES ('7', '测试评论功能', '1', '1', '2016-10-15 19:41:35');
INSERT INTO `post` VALUES ('8', '8 评论啊', '1', '1', '2016-10-15 19:42:07');
INSERT INTO `post` VALUES ('9', '第 9 条 评论', '1', '1', '2016-10-15 19:42:46');
INSERT INTO `post` VALUES ('10', '第 10 评论', '1', '1', '2016-10-15 19:44:04');
INSERT INTO `post` VALUES ('19', '1', '2', '1', '2016-10-15 19:57:59');
INSERT INTO `post` VALUES ('20', '2', '2', '1', '2016-10-15 19:58:02');
INSERT INTO `post` VALUES ('21', '2', '2', '1', '2016-10-15 19:58:04');
INSERT INTO `post` VALUES ('22', '3', '2', '1', '2016-10-15 19:58:08');
INSERT INTO `post` VALUES ('23', '@<a href=\"/user/1/\" class=\"mention\">root</a> ', '2', '1', '2016-10-15 19:59:17');
INSERT INTO `post` VALUES ('24', '1212', '2', '1', '2016-10-15 20:00:38');
INSERT INTO `post` VALUES ('25', '433', '2', '1', '2016-10-15 20:00:49');
INSERT INTO `post` VALUES ('26', '12', '2', '1', '2016-10-15 20:01:03');
INSERT INTO `post` VALUES ('27', '新的评论测死', '2', '1', '2016-10-15 20:02:39');
INSERT INTO `post` VALUES ('42', '1', '3', '1', '2016-10-15 20:28:19');
INSERT INTO `post` VALUES ('43', '2', '3', '1', '2016-10-15 20:28:22');
INSERT INTO `post` VALUES ('44', '3', '3', '1', '2016-10-15 20:28:24');
INSERT INTO `post` VALUES ('45', '4', '3', '1', '2016-10-15 20:29:13');
INSERT INTO `post` VALUES ('46', '4', '3', '1', '2016-10-15 20:29:17');
INSERT INTO `post` VALUES ('47', '6', '3', '1', '2016-10-15 20:30:47');
INSERT INTO `post` VALUES ('48', '7', '3', '1', '2016-10-15 20:30:55');
INSERT INTO `post` VALUES ('49', '11', '1', '1', '2016-10-15 20:31:11');
INSERT INTO `post` VALUES ('50', '1', '4', '1', '2016-10-15 20:32:54');
INSERT INTO `post` VALUES ('51', '@<a href=\"/user/1/\" class=\"mention\">root</a> 2', '4', '1', '2016-10-15 20:35:37');
INSERT INTO `post` VALUES ('52', '@<a href=\"/user/1/\" class=\"mention\">root</a> 3', '4', '1', '2016-10-15 20:36:23');
INSERT INTO `post` VALUES ('53', '@<a href=\"/user/1/\" class=\"mention\">root</a> 4', '4', '1', '2016-10-15 20:36:35');
INSERT INTO `post` VALUES ('54', '5', '4', '1', '2016-10-15 20:44:03');
INSERT INTO `post` VALUES ('55', '212121  @<a href=\"/user/1/\" class=\"mention\">root</a> @<a href=\"/user/1/\" class=\"mention\">root</a> ', '4', '1', '2016-10-15 20:45:05');
INSERT INTO `post` VALUES ('56', '@<a href=\"/user/1/\" class=\"mention\">root</a> 22', '1', '1', '2016-10-15 22:56:07');
INSERT INTO `post` VALUES ('57', '1', '5', '1', '2016-10-16 16:24:45');
INSERT INTO `post` VALUES ('58', '2', '5', '1', '2016-10-16 17:16:02');
INSERT INTO `post` VALUES ('59', '12', '6', '1', '2016-10-16 22:50:36');
INSERT INTO `post` VALUES ('60', '2', '6', '1', '2016-10-16 22:50:39');
INSERT INTO `post` VALUES ('61', '新技能 GET', '6', '4', '2016-10-17 12:01:27');
INSERT INTO `post` VALUES ('62', '乱码了', '5', '4', '2016-10-17 14:13:22');
INSERT INTO `post` VALUES ('63', '评论测试', '6', '4', '2016-10-17 14:15:02');
INSERT INTO `post` VALUES ('64', '我来评价', '8', '1', '2016-10-19 15:19:00');
INSERT INTO `post` VALUES ('65', '@<a href=\"/user/1/\" class=\"mention\">root</a> 评价功能 bug 修复', '8', '3', '2016-10-22 11:12:51');
INSERT INTO `post` VALUES ('66', '\\[ x = y_1^i + 1 \\]', '12', '3', '2017-01-09 14:31:06');
INSERT INTO `post` VALUES ('67', '\\[` x = y_1^i + 1`\\]', '12', '3', '2017-01-09 14:31:32');
INSERT INTO `post` VALUES ('68', '12', '9', '3', '2017-03-16 21:01:00');

-- ----------------------------
-- Table structure for `programs`
-- ----------------------------
DROP TABLE IF EXISTS `programs`;
CREATE TABLE `programs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `detail` text NOT NULL,
  `difficulty` int(11) DEFAULT NULL,
  `acceptedNum` int(11) DEFAULT NULL,
  `submitNum` int(11) DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `default_code` text,
  `can_evaluate` tinyint(1) NOT NULL,
  `pi_code` text,
  `null_code` text,
  `serial_code` text,
  `ref_code` text,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `programs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of programs
-- ----------------------------
INSERT INTO `programs` VALUES ('1', '编写Pthreads程序', '编写Pthreads程序，求小于2n的素数。\r\n\r\na)	输入：整数n，10\\<n\\<48。\r\n\r\nb)	输出：二进制文件。每个素数用一个int64_t型的整数表示，找到的全部素数按照从小到大顺序存储在输出文件中。\r\n', '2', '0', '0', '2016-12-29 23:53:11', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"\\n\");\r\n}', '0', null, null, null, null);
INSERT INTO `programs` VALUES ('2', '编写MPI程序', '编写MPI程序，求小于2n的素数。\r\n\r\na)	输入：整数n，10\\<n\\<48。\r\n\r\nb)	输出：二进制文件。每个素数用一个int64_t型的整数表示，找到的全部素数按照从小到大顺序存储在输出文件中。\r\n', '0', '0', '0', '2016-12-29 23:53:40', '3', '', '0', null, null, null, null);
INSERT INTO `programs` VALUES ('3', '计算π的近似值', '公式![](/static/upload/md_images/20161229235552.png)可用于计算π的近似值。编写串行程序、Pthreads程序、和MPI程序实现该公式，分别计算π的近似值。\r\n\r\na)	输入：整数k和p，10\\<k\\<48。n=2k表示计算精度，p是并行执行时处理器的数量。\r\n\r\nb)	输出：每个版本分别以科学表示法输出所计算的π。\r\n', '0', '0', '0', '2016-12-29 23:56:26', '3', '#include <mpi.h>\n#include <stdio.h>\nint main(int argc, char **argv)\n{ \n    MPI_Init(&argc, &argv); \n    \n    float sum=0.0;\n    float i=1,d=1;\n    while(1/i>=1e-6)\n    {\n       sum=sum+d/i;\n       d=d*(-1);\n       i=i+2;\n    }           \n    sum=sum*4;\n    printf(\"value is %0.6f\",sum);\n    \n    MPI_Finalize();\n    return 0;\n} \n', '1', '#include <stdio.h>\r\n#include <stdlib.h>\r\n#include <string.h>\r\n#include <math.h>\r\n#include <time.h>\r\n#include <unistd.h>\r\n#include <sys/types.h>\r\n#include <sys/wait.h>\r\nusing namespace std;\r\n\r\n#define NANO           1000000000\r\n\r\nint main(int argc, char* argv[] ){\r\n    int8_t flag = 1;\r\n    struct timespec ts,te;\r\n    double scost, rcost, ycost;\r\n    char command[256];\r\n\r\n    sscanf(argv[1], \"%hhd\", &flag);\r\n    //printf(\"cmd:%s\\n\",\"test\");\r\n    //return 0 ; \r\n    int64_t num_steps = atoll(argv[3]);\r\n    if ( flag ) {\r\n        if (num_steps<30) {\r\n                        sprintf(command, \"./serial %s\", argv[3]);\r\n                        clock_gettime(CLOCK_REALTIME, &ts);\r\n                        //printf(\"cmd:%s\\n\",command);\r\n                        system(command);\r\n                        clock_gettime(CLOCK_REALTIME, &te);\r\n                        scost = te.tv_sec - ts.tv_sec + (double)(te.tv_nsec-ts.tv_nsec)/(double)NANO;\r\n        }\r\n\r\n        sprintf(command, \"mpirun -np %s ./hello\", argv[2]);\r\n        system(command);\r\n        sprintf(command, \"mpirun -np %s ./ref %s\", argv[2], argv[3]);\r\n                clock_gettime(CLOCK_REALTIME, &ts);\r\n                system(command);\r\n                clock_gettime(CLOCK_REALTIME, &te);\r\n                rcost = te.tv_sec - ts.tv_sec + (double)(te.tv_nsec-ts.tv_nsec)/(double)NANO;\r\n    }\r\n    sprintf(command, \"mpirun -np %s ./hello\", argv[2]);\r\n    //printf(\"cmd:%s\\n\",command);\r\n    system(command);\r\n    sprintf(command, \"mpirun -np %s ./program %s\", argv[2], argv[3]);\r\n    //printf(\"cmd:%s\\n\",command);\r\n    clock_gettime(CLOCK_REALTIME, &ts);\r\n    system(command);\r\n    clock_gettime(CLOCK_REALTIME, &te);\r\n    ycost = te.tv_sec - ts.tv_sec + (double)(te.tv_nsec-ts.tv_nsec)/(double)NANO;\r\n    FILE *fs, *fr, *fy;\r\n    double ds, dr, dy;\r\n    int    ss, sr, sy;\r\n    if ( flag ) {\r\n        if (num_steps<30) {\r\n    //printf(\"cmd:%s\\n\",\"test 1\");\r\n                fs=fopen(\"serial.out\",\"rb\");\r\n                fr=fopen(\"ref.out\",\"rb\");\r\n                fy=fopen(\"data.out\",\"rb\");\r\n                ss = fread(&ds, sizeof(double), 1, fs);\r\n                sr = fread(&dr, sizeof(double), 1, fr);\r\n                sy = fread(&dy, sizeof(double), 1, fy);\r\n                fclose(fs);\r\n                fclose(fr);\r\n                fclose(fy);\r\n                        printf(\"\\\"ser_cost\\\":\\\"%6.4e\\\", \\\"ser_val\\\":\\\"%15.13lf\\\",\", scost, ds);\r\n                        printf(\"\\\"ref_cost\\\":\\\"%6.4e\\\", \\\"ref_ratio\\\":\\\"%-5.3e\\\",\\\"ref_val\\\":\\\"%15.13lf\\\", \\\"ref_diff\\\":\\\"%10.8e\\\",\", rcost, scost/rcost, dr, fabs(ds - dr));\r\n                        printf(\"\\\"you_cost\\\":\\\"%6.4e\\\", \\\"you_ratio\\\":\\\"%-5.3e\\\",\\\"you_val\\\":\\\"%15.13lf\\\",\\\"you_diff\\\":\\\"%10.8e\\\"\", ycost, scost/ycost, dy, fabs(ds - dy));\r\n                        unlink(\"ref.out\");\r\n                        unlink(\"serial.out\");\r\n        } else {\r\n                //printf(\"cmd:%s\\n\",\"test 2\");\r\n                fr=fopen(\"ref.out\",\"rb\");\r\n                fy=fopen(\"data.out\",\"rb\");\r\n                sr = fread(&dr, sizeof(double), 1, fr);\r\n                sy = fread(&dy, sizeof(double), 1, fy);\r\n                fclose(fr);\r\n                fclose(fy);\r\n                        printf(\"reference parallel impl.: time_cost=%-6.4e pi=%15.13lf\\n\", rcost, dr);\r\n                        printf(\"your impl.              : time_cost=%-6.4e pi=%15.13lf diff=%10.8e\\n\", ycost, dy, fabs(dr - dy));\r\n                        unlink(\"ref.out\");\r\n        }\r\n    } else {\r\n    printf(\"cmd:%s\\n\",\"test 3\");\r\n        fy=fopen(\"data.out\",\"rb\");\r\n        sy = fread(&dy, sizeof(double), 1, fy);\r\n        fclose(fy);\r\n        printf(\"your impl. : time_cost=%-6.4e pi=%15.13lf\\n\", ycost, dy);\r\n    }\r\n    unlink(\"data.out\");\r\n    return EXIT_SUCCESS;\r\n}\r\n', '#include <mpi.h>\r\n#include <stdlib.h>\r\n\r\nint main(int argc,char ** argv) {   \r\n    int my_rank, np;\r\n    MPI_Init(&argc,&argv);\r\n    MPI_Comm_rank(MPI_COMM_WORLD,&my_rank);\r\n    MPI_Comm_size(MPI_COMM_WORLD,&np);\r\n    MPI_Finalize(); \r\n    return EXIT_SUCCESS;\r\n}\r\n\r\n\r\n', '#include <stdlib.h>\r\n#include <stdio.h>\r\n\r\nint main (int argc, char* argv[]) {\r\n	int64_t i, num_steps;\r\n	double pi, x, sum, step;\r\n     \r\n    num_steps = atoll(argv[1]);\r\n    num_steps = ((int64_t)1<<num_steps);\r\n    sum = 0.;\r\n    step = 1.0/(double) num_steps;\r\n     \r\n    for (i=1; i<=num_steps; i++) {\r\n    	x = (i-0.5)*step;\r\n        sum = sum + 4.0/(1.0+x*x);\r\n    }\r\n    pi = step * sum;\r\n    \r\n    FILE *fout=fopen(\"serial.out\",\"wb\");\r\n    fwrite(&pi, sizeof(double), 1, fout);\r\n    fclose(fout);\r\n     \r\n    return EXIT_SUCCESS;\r\n}\r\n\r\n', '#include <mpi.h>\r\n#include <stdlib.h>\r\n#include <stdio.h>\r\n\r\n\r\nint main(int argc, char**argv) { \r\n\r\n    int rank, size;\r\n	int64_t i, num_steps;\r\n	double pi, x, sum, step, loc_sum = 0.0;\r\n	\r\n    num_steps = atoll(argv[1]);//printf(\"%20.18f %ld\\n\", pi, num_steps);\r\n    num_steps = ((int64_t)1<<num_steps);\r\n    sum = 0.;\r\n    step = 1.0/(double) num_steps;\r\n    \r\n\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_size(MPI_COMM_WORLD, &size);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &rank);\r\n     \r\n    for (i=rank+1; i<=num_steps ; i+=size) {\r\n         x = (i-0.5)*step;\r\n         loc_sum += 4.0/(1.0+x*x);\r\n    }\r\n    MPI_Allreduce(&loc_sum, &sum, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD); \r\n    pi = sum * step;\r\n     \r\n    //evaluate(steps, ts, te, pi);\r\n    if (rank==0) {\r\n    	FILE *fout=fopen(\"ref.out\",\"wb\");\r\n    	fwrite(&pi, sizeof(double), 1, fout);\r\n    	fclose(fout);\r\n    }\r\n     \r\n    MPI_Finalize();\r\n\r\n    return EXIT_SUCCESS;\r\n}\r\n');
INSERT INTO `programs` VALUES ('4', '计算两个矩阵的乘积', '计算两个矩阵A和B的乘积A×B，其中A是m×n的单精度浮点数矩阵、B是n×k的单精度浮点数矩阵。\r\n\r\na)	输入：m、n、k、fa、fb、of。m、n、k是三个正整数，分别表示矩阵A和B的行数、列数。fa和fb是两个二进制输入文件，fa按行优先顺序存储A的元素值，fb按行优先顺序存储B的元素值；of是输出文件的名称。\r\n\r\nb)	输出：名为of的二进制文件，按行优先顺序存储结果矩阵的元素。\r\n\r\n', '0', '0', '0', '2016-12-29 23:58:14', '3', '', '0', null, null, null, null);
INSERT INTO `programs` VALUES ('5', '整型数组排序', '对长度为2n的整型数组排序。原始数组的每个元素类型为int32_t，以二进制存储在数据文件data.in中。\r\n\r\na)	输入：n。\r\n\r\nb)	输出：对data.in中前2n个元素从小到大排序，并将排序结果以二进制存储在文件data.out中。\r\n', '0', '0', '0', '2016-12-29 23:58:44', '3', '', '0', null, null, null, null);
INSERT INTO `programs` VALUES ('6', '求粒子状态', '在某个粒子系统中共有2n个粒子，粒子之间的互相吸引力导致其状态不断变化。为简化问题，我们将任意两个粒子b1和b2之间的吸引力用公式![](/static/upload/md_images/20161230000108.png)表示，其中m1、m2分别是b1和b2的质量，→┬r_12是b1和b2之间的矢量距离；粒子b的移动速度用矢量表示f ⃗/m表示，其中f ⃗、m分别是b的受力和质量。计算经过t个时间步后，该粒子系统的状态。粒子的原始状态存储在二进制文件data.in中，每个粒子的状态占用4个双精度浮点数，依次是质量、x轴坐标、y轴坐标、z轴坐标。\r\n\r\na)	输入：n，t。n表示粒子系统中共有2n个粒子，t是模拟计算的时间步数量。\r\n\r\nb)	输出：经过t步后各个粒子的状态，存储在二进制文件data.out中data.in。粒子在输出文件中的存储顺序与输入文件的一致，每个粒子的状态占用4个双精度浮点数，依次是质量、x轴坐标、y轴坐标、z轴坐标。\r\n', '0', '0', '0', '2016-12-30 00:02:31', '3', '', '0', null, null, null, null);
INSERT INTO `programs` VALUES ('7', '统计图顶点的度数', '给定图G=\\<V, E\\>的全部边，统计其中各顶点的度数。假设G是无向图，其顶点从0开始顺序编号。\r\n\r\na)	输入：graph.mtx。二进制文件名，其中每条记录表示G的一条边，由两个 int32_t型的整数组成，分别是端点的序号。\r\n\r\nb)	输出：graph.deg。与输入文件相同前缀的二进制文件名，存储G中各个顶点的度数。每个顶点的度数用一个int32_t型的整数表示，各顶点度数的存储顺序与其编号顺序一致。\r\n', '0', '0', '0', '2016-12-30 00:03:11', '3', '', '0', null, null, null, null);
INSERT INTO `programs` VALUES ('8', '浮点数数组排序', '对长度为2n的浮点数数组排序。原始数组的每个元素类型为双精度浮点数，以二进制存储在数据文件data.in中。\r\n\r\na)	输入：n。\r\n\r\nb)	输出：对data.in中前2n个元素从小到大排序，并将排序结果以二进制存储在文件data.out中。\r\n', '0', '0', '0', '2016-12-30 00:03:33', '3', '', '0', null, null, null, null);

-- ----------------------------
-- Table structure for `program_tag`
-- ----------------------------
DROP TABLE IF EXISTS `program_tag`;
CREATE TABLE `program_tag` (
  `program_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`program_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `program_tag_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`),
  CONSTRAINT `program_tag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `prog_tags` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of program_tag
-- ----------------------------
INSERT INTO `program_tag` VALUES ('1', '1');

-- ----------------------------
-- Table structure for `progress`
-- ----------------------------
DROP TABLE IF EXISTS `progress`;
CREATE TABLE `progress` (
  `user_id` int(11) NOT NULL,
  `knowledge_id` int(11) NOT NULL,
  `cur_progress` int(11) DEFAULT NULL,
  `update_time` datetime NOT NULL,
  PRIMARY KEY (`user_id`,`knowledge_id`),
  KEY `knowledge_id` (`knowledge_id`),
  CONSTRAINT `progress_ibfk_1` FOREIGN KEY (`knowledge_id`) REFERENCES `knowledges` (`id`),
  CONSTRAINT `progress_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of progress
-- ----------------------------
INSERT INTO `progress` VALUES ('1', '5', '0', '2017-03-23 09:22:38');
INSERT INTO `progress` VALUES ('1', '6', '0', '2017-03-22 17:50:34');
INSERT INTO `progress` VALUES ('3', '5', '1', '2017-07-04 21:26:21');
INSERT INTO `progress` VALUES ('3', '6', '0', '2017-03-24 09:15:36');
INSERT INTO `progress` VALUES ('5', '5', '0', '2017-03-03 13:34:55');
INSERT INTO `progress` VALUES ('10', '5', '0', '2017-03-22 21:07:09');
INSERT INTO `progress` VALUES ('13', '5', '0', '2017-03-21 16:59:38');
INSERT INTO `progress` VALUES ('15', '5', '0', '2017-03-25 22:09:41');

-- ----------------------------
-- Table structure for `prog_tags`
-- ----------------------------
DROP TABLE IF EXISTS `prog_tags`;
CREATE TABLE `prog_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of prog_tags
-- ----------------------------
INSERT INTO `prog_tags` VALUES ('1', 'mpi');
INSERT INTO `prog_tags` VALUES ('2', 'openmp');

-- ----------------------------
-- Table structure for `qrcode`
-- ----------------------------
DROP TABLE IF EXISTS `qrcode`;
CREATE TABLE `qrcode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `end_time` datetime NOT NULL,
  `course_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `qrcode_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrcode
-- ----------------------------
INSERT INTO `qrcode` VALUES ('1', '2017-03-22 21:45:13', '1');
INSERT INTO `qrcode` VALUES ('2', '2017-03-17 23:25:23', '15');
INSERT INTO `qrcode` VALUES ('4', '2017-03-24 09:26:46', '32');

-- ----------------------------
-- Table structure for `questions`
-- ----------------------------
DROP TABLE IF EXISTS `questions`;
CREATE TABLE `questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` tinyint(4) NOT NULL,
  `content` varchar(2048) NOT NULL,
  `solution` varchar(512) NOT NULL,
  `analysis` varchar(1024) DEFAULT '',
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `course_id` (`user_id`),
  CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=772 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of questions
-- ----------------------------
INSERT INTO `questions` VALUES ('8', '1', '{\"0\":\"单指令流单数据流（Single Instruction stream Single Data stream, SISD\",\"1\":\"单指令流多数据流（Single Instruction stream Multiple Data stream, SIMD\",\"2\":\"多指令流单数据流（Multiple Instruction stream Single Data stream, MISD\",\"3\":\"多指令流多数据流（Multiple Instruction stream Multiple Data stream, MISD\",\"title\":\"Flynn根据指令流和数据流的不同组织方式，把计算机系统的结构分为以下四类：\\n\\n\",\"len\":4}', 'A;B;C;D', '对并行计算机的分类有多种方法，其中最著名的是1966年由M.J.Flynn提出的分类法，称为Flynn分类法。Flynn分类法是从计算机的运行机制进行分类的。首先作如下定义：\r\n\r\n* 指令流（instruction stream）：机器执行的指令序列；\r\n* 数据流（data stream）：由指令流调用的数据序列，包括输入数据和中间结果。\r\n\r\nFlynn根据指令流和数据流的不同组织方式，把计算机系统的结构分为以下四类：\r\n\r\n* 单指令流单数据流（Single Instruction stream Single Data stream, SISD）；\r\n* 单指令流多数据流（Single Instruction stream Multiple Data stream, SIMD）；\r\n* 多指令流单数据流（Multiple Instruction stream Single Data stream, MISD）；\r\n* 多指令流多数据流（Multiple Instruction stream Multiple Data stream, MISD）。\r\n', '3');
INSERT INTO `questions` VALUES ('13', '0', '{\"0\":\"(n/8+4) tc＋4tw, (n/8+4) tc＋4tw\",\"1\":\"(n/8+4) tc＋4tw, (n/8+4) tc＋3tw\",\"2\":\"(n/8+4) tc＋3tw, (n/8+4) tc＋4tw\",\"3\":\"(n/8+4) tc＋3tw, (n/8+4) tc＋3tw\",\"title\":\"将n个数相加，假设一个人相加两个数需要的时间为tc，那么一个人完成相加n个数需要(n-1)\\\\*tc。\\n\\n若由8个技能完全相同的人计算这n个数的和，且8|n，相邻的两个人传送一个数需时间tw，在下列两种情况下：\\n\\n1. 8个人坐成一圈。\\n2. 8个人坐成一行。\\n\\n完成n个数的相加各需多长时间？\",\"len\":4}', 'A', ' 一个人完成n个数的相加需要的时间为(n-1)*tc \r\n \r\n 1. 若8个人坐成一圈，每个人完成n/8个数需要的时间为(n/8-1)\\*tc，从相邻的两个人同时开始向两个方向传送数据并相加，三次传送与相加需时间3(tc+tw)，最后，两个人再进行一次传送及一次计算就得到了最终结果。总的开销为(n/8-1)\\*tc＋ 3(tc+tw)＋(tc+tw)＝(n/8+4) tc＋4tw \r\n2. 同理，若8个人坐成一行，每个人完成n/8个数需要的时间为(n/8-1)\\*tc，从最远的两个人同时开始向中间方向传送数据并相加，最后，两个人再进行一次传送及一次计算就得到了最终结果。总的开销也为(n/8+4) tc＋4tw ', '3');
INSERT INTO `questions` VALUES ('14', '4', '并行计算机的自动编程：设计一个并行化编译器，使用户的串行程序通过并行化编译器编译，直接可在并行机上运行。到目前为此，这种编译器**已经存在**，并广泛应用于许多学科中。\r\n', '0', '并行计算机的自动编程：可否设计一个并行化编译器，使用户的串行程序通过并行化编译器编译，直接可在并行机上运行。到目前为此，这种编译器还不存在，而仅有一些半自动并行化编译器。\r\n', '3');
INSERT INTO `questions` VALUES ('15', '1', '{\"0\":\"计算密集型（Compute-Intensive）\",\"1\":\"数据密集型 (Data-Intensive)\",\"2\":\"文本密集型 (Text-Intensive)\",\"3\":\"网络密集型 (Network-Intensive)\",\"title\":\"并行计算的应用可概括为以下哪些方面\",\"len\":4}', 'A;B;D', '科学与工程计算对并行计算的需求是十分广泛的，但所有的应用可概括为三个方面：\r\n\r\n* 计算密集型（Compute-Intensive）：这一类型的应用问题主要集中在大型科学工程计算与数值模拟（气象预报、地球物理勘探等）\r\n* 数据密集型 (Data-Intensive)：Internet的发展，为我们提供了大量的数据资源，但有效地利用这些资源，需要进行大量地处理，且对计算机的要求也相当高，这些应用包括数字图书馆、数据仓库、数据挖掘、计算可视化。\r\n* 网络密集型 (Network-Intensive)：通过网络进行远距离信息交互，来完成用传统方法不同的一些应用问题。如协同工作、遥控与远程医疗诊断等', '3');
INSERT INTO `questions` VALUES ('16', '4', 'SIMD中通常包含大量处理单元PE，而控制部件只有一个。控制部件广播一条指令，所有的处理单元同时执行这条指令，但不同的处理单元操作的数据可能不同。', '1', 'SIMD中通常包含大量处理单元PE，而控制部件只有一个。控制部件广播一条指令，所有的处理单元同时执行这条指令，但不同的处理单元操作的数据可能不同。', '3');
INSERT INTO `questions` VALUES ('17', '4', '并行向量处理机的最大特点是其中的各处理器完全平等，无主从之分。所有的处理器都可以访问任何存储单元和I/O设备。', '0', '对称多处理机 对称多处理机的最大特点是其中的各处理器完全平等，无主从之分。所有的处理器都可以访问任何存储单元和I/O设备。存储器一般使用共享存储器，只有一个地址空间。', '3');
INSERT INTO `questions` VALUES ('18', '4', '为了维持一定的并行效率（介于 0 与 1 之间），当处理器 P 增大时，需要相应地增大问题规模 W 的值，由此定 义函数 fE(p)为问题规模 W 随处理器 P 变化的函数，称此函数为等效率函数。', '1', '', '3');
INSERT INTO `questions` VALUES ('19', '4', '用户态线程和核心态线程都由操作系统直接调度。', '0', '', '3');
INSERT INTO `questions` VALUES ('20', '4', '在广播通信中，单个进程传递相同的数据给所有的进程。', '1', '', '3');
INSERT INTO `questions` VALUES ('21', '4', 'while 循环语句是忙等待的一个例子。', '1', '', '3');
INSERT INTO `questions` VALUES ('22', '4', '一个好的并行算法要既能很好地匹配并行计算机硬件体系结构的特点又能反映问题内在并行性。', '1', '', '3');
INSERT INTO `questions` VALUES ('23', '4', '如果一个线程在临界区中执行代码，其他线程需要被排序在临界区外。', '1', '', '3');
INSERT INTO `questions` VALUES ('24', '4', '计算机视觉不属于英特尔集成性能函数库(IPP)所涵盖的领域。', '0', '', '3');
INSERT INTO `questions` VALUES ('25', '4', '控制单元负责决定应该执行程序中的哪些指令，而 ALU 负责执行指令核已经成为中央处理器或者 CPU 的代名词。', '1', '', '3');
INSERT INTO `questions` VALUES ('26', '4', 'OpenMP 是用于共享内存并行系统的多线程程序设计的一套指导性的编译处理方案(Compiler Directive)，也可以将其扩展到用于分布式内存的集群系统。', '1', '', '3');
INSERT INTO `questions` VALUES ('27', '4', '在共享内存系统中，每个处理器有自己私有的内存空间，处理器-内存对之间通过互连网络相互通信。', '0', '', '3');
INSERT INTO `questions` VALUES ('28', '4', '在 Amdahl 定律中，以 f 表示串行分量的比例，随着处理器数目的无限增大，并行系统所能够达到的加速上限是S=1/f。', '1', '', '3');
INSERT INTO `questions` VALUES ('29', '4', '通过继续增快集成电路的速度来提高处理器性能是可行的。', '0', '', '3');
INSERT INTO `questions` VALUES ('30', '4', '阻塞通信的功能都可以用非阻塞通信的方式实现。', '1', '', '3');
INSERT INTO `questions` VALUES ('31', '4', 'ALU 负责决定应该执行程序中的哪些指令，而控制单元负责执行指令。', '0', '', '3');
INSERT INTO `questions` VALUES ('32', '4', 'OpenMP 对同一个临界区不应当混合使用不同的互斥机制。', '1', '', '3');
INSERT INTO `questions` VALUES ('33', '4', 'MPI 中发送语句用整型，接收语句用实型可以匹配。', '0', '', '3');
INSERT INTO `questions` VALUES ('34', '4', '在有效编程下，超线程性能要高于多核性能。', '0', '', '3');
INSERT INTO `questions` VALUES ('35', '4', 'MPI_COMM_RANK 是 MPI 的一个基本函数，它用于确定进程总数。', '0', '', '3');
INSERT INTO `questions` VALUES ('36', '4', '并行计算中的并行性指问题中具有可在同一时刻发生的两个或者多个运算或者操作的特性。', '0', '', '3');
INSERT INTO `questions` VALUES ('37', '4', '英特尔线程检查器能够找出线程间的工作不平衡。', '0', '', '3');
INSERT INTO `questions` VALUES ('38', '4', '如果 MPI 程序中的某条输出语句在每一个进程都执行，则从标准输出上看，不同进程对该语句的输出在 顺序上是随机的。', '1', '', '3');
INSERT INTO `questions` VALUES ('39', '4', '依赖于 MPI 提供的缓冲机制是安全的。', '0', '', '3');
INSERT INTO `questions` VALUES ('40', '4', '利用矩阵向量相乘的方式进行离散傅立叶变换，计算复杂度是 O(n3),而快速傅里叶变换的时间复杂度是 O(nlogn)。', '0', '', '3');
INSERT INTO `questions` VALUES ('41', '4', '对于一个给定的应用，并行算法相比于串行算法的性能提升是（1- T 并行执行时间/T 串行执行时间）', '0', '', '3');
INSERT INTO `questions` VALUES ('42', '4', '一般来说，对高速缓冲存储器的访问时间比其他存储区域的访问时间短', '1', '', '3');
INSERT INTO `questions` VALUES ('43', '4', '组通信需要该组内所有的进程都参加?。', '1', '', '3');
INSERT INTO `questions` VALUES ('44', '4', '在细粒度多线程中，处理器在每条指令执行完后切换线程，从而跳过被阻塞的线程。', '1', '', '3');
INSERT INTO `questions` VALUES ('45', '4', '英特尔 Parallel Inspector 采用动态技术，不需要特殊的检查工具或者编译', '1', '', '3');
INSERT INTO `questions` VALUES ('46', '4', '虚拟进程数要小于实际的处理器的个数。', '0', '', '3');
INSERT INTO `questions` VALUES ('47', '4', 'Vtune 性能分析器能够分析程序中的代码错误并指出错误代码的位置。', '0', '', '3');
INSERT INTO `questions` VALUES ('48', '4', 'Linpack 是国际上最流行的用于测试高性能计算机系统浮点性能的 benchmark。它采用高斯消元法求解一 元 N 次稠密线性代数方程组，也即采用正交三角分解法（LU 分解）。', '0', '', '3');
INSERT INTO `questions` VALUES ('49', '4', '在并行程序设计中，局部变量指的是单个函数的私有变量。', '0', '', '3');
INSERT INTO `questions` VALUES ('50', '4', '忙等待是保护临界区的唯一办法。', '0', '', '3');
INSERT INTO `questions` VALUES ('51', '4', '向量处理器与图形处理器单元一般划分在 SIMD 系统里。', '1', '', '3');
INSERT INTO `questions` VALUES ('53', '4', '单处理器性能大幅度提升的主要原因之一是日益增加的集成电路晶体管密度。', '1', '', '3');
INSERT INTO `questions` VALUES ('55', '4', 'OS timer service 是 Vtune 性能分析器的基于时间的采样。', '1', '', '3');
INSERT INTO `questions` VALUES ('56', '4', '利用虚拟存储器，使得主存可以作为辅存的缓存。', '1', '', '3');
INSERT INTO `questions` VALUES ('57', '4', '在分布式内存系统中，各个核能够共享访问计算机的内存，理论上每个核能够读、写内存的所有', '0', '', '3');
INSERT INTO `questions` VALUES ('58', '4', '在实现指令级并行中，流水线是指将功能单元分阶段安排。（', '0', '', '3');
INSERT INTO `questions` VALUES ('59', '4', 'Vtune 性能分析器不搜集执行代码在内存中的地址信息。', '0', '', '3');
INSERT INTO `questions` VALUES ('60', '4', '将串行程序并行化，并行化的代码区域越多，程序的整体性能越好。', '0', '', '3');
INSERT INTO `questions` VALUES ('61', '4', '多核 CPU 中也可以使用超线程技术。', '1', '', '3');
INSERT INTO `questions` VALUES ('62', '4', '在大多数系统中，进程间的切换比线程间的切换更快。', '0', '', '3');
INSERT INTO `questions` VALUES ('64', '4', '英特尔线程检查器能够找出线程间的工作不平衡。', '0', '', '3');
INSERT INTO `questions` VALUES ('65', '4', '内存系统由多个内存“体”组成，每个内存体能够独立访问。', '1', '', '3');
INSERT INTO `questions` VALUES ('66', '4', '阻塞通信的功能都可以用非阻塞通信的方式实现?。', '1', '', '3');
INSERT INTO `questions` VALUES ('67', '4', '一个好的并行算法要既能很好地匹配并行计算机硬件体系结构的特点又能反映问题内在并行性', '1', '', '3');
INSERT INTO `questions` VALUES ('68', '4', '组通信调用只能实现通信功能 。', '0', '', '3');
INSERT INTO `questions` VALUES ('69', '4', '中央处理单元分为控制单元和算术逻辑单元。', '1', '', '3');
INSERT INTO `questions` VALUES ('71', '4', '非阻塞通信的功能都可以用阻塞通信的方式实现?。', '0', '', '3');
INSERT INTO `questions` VALUES ('72', '4', 'Cache 3C 失效中的强制性失效不受 Cache 容量的影响。', '1', '', '3');
INSERT INTO `questions` VALUES ('73', '4', 'MPI 主从模式的并行程序可以为 SPMD 形式。', '1', '', '3');
INSERT INTO `questions` VALUES ('75', '4', '多线程程序中，一个线程可以与同进程中的其它线程共享数据，因此当一个线程对全局变量 X赋值 0（即执行 x=0）之后，其它线程立刻读取 X，其值必为 0。', '0', '', '3');
INSERT INTO `questions` VALUES ('76', '4', '在共享内存系统中，每个核拥有自己的私有内存，核之间的通信是显式的，必须使用类似于网络 中发送消息的机制。', '0', '', '3');
INSERT INTO `questions` VALUES ('77', '4', '不管 OpenMP 语句以何种形式实现，修改同一变量的不同语句都将视为属于同一个临界区。', '1', '', '3');
INSERT INTO `questions` VALUES ('78', '4', '在机群系统的并行应用中，一个进程先执行发送操作，另一个进程先执行相应的接收操作，是安 全的发送和接收序列。', '1', '', '3');
INSERT INTO `questions` VALUES ('81', '4', 'IPO 对于循环内包含调用的程序可以极大地提高其性能。', '1', '', '3');
INSERT INTO `questions` VALUES ('82', '4', '操作系统是一种用来管理计算机的软件和硬件资源的主要软件。', '1', '', '3');
INSERT INTO `questions` VALUES ('83', '4', '单处理器性能大幅度提升的主要原因之一是日益增加的集成电路晶体管密度。', '1', '', '3');
INSERT INTO `questions` VALUES ('86', '4', 'MPI 使用的是所谓的“推”（Push） 通信机制', '1', '', '3');
INSERT INTO `questions` VALUES ('87', '4', '一块内存空间，包括可执行代码，一个用来跟踪执行函数的调用栈、一个堆，以及一些其他内存', '1', '', '3');
INSERT INTO `questions` VALUES ('88', '4', '一个并行程序的并行效率越高，它的浮点性能就越高。', '0', '', '3');
INSERT INTO `questions` VALUES ('89', '4', 'MPI 中发送语句用整型，接收语句用实型可以匹配。', '0', '', '3');
INSERT INTO `questions` VALUES ('92', '4', '有依赖关系的语句中一定有语句会有序地写或更新变量。', '1', '', '3');
INSERT INTO `questions` VALUES ('94', '4', 'OpenMP 只能并行化 for 循环，不能并行化 while 和 do-while 循环。', '1', '', '3');
INSERT INTO `questions` VALUES ('96', '4', '用户态线程和核心态线程都由操作系统直接调度。', '0', '', '3');
INSERT INTO `questions` VALUES ('97', '4', '并行算法求解问题只要保证与相应的串行算法一致的数据依赖，则其求解的结果与串行算法相同。', '0', '', '3');
INSERT INTO `questions` VALUES ('100', '4', '向量处理器与图形处理器单元一般划分在 SIMD 系统里。', '1', '', '3');
INSERT INTO `questions` VALUES ('103', '4', '大多数系统中，默认状态下，一个进程的内存块是公有的。', '0', '', '3');
INSERT INTO `questions` VALUES ('104', '4', '在分布式内存和共享内存系统，所有进程/线程都能够访问 stdout 和 stder', '1', '', '3');
INSERT INTO `questions` VALUES ('106', '4', '所有的向量数据类型都可以定义为结构数据类型。', '1', '', '3');
INSERT INTO `questions` VALUES ('108', '4', '非阻塞发送语句可以用阻塞接收语句来接收。', '1', '', '3');
INSERT INTO `questions` VALUES ('109', '4', '在写回 Cache 中，数据不是立即更新到主存中，而是将发生数据更新的高速缓存行标记为脏。', '1', '', '3');
INSERT INTO `questions` VALUES ('110', '4', '当一个 for 循环存在循环依赖时不能被并行化。', '1', '', '3');
INSERT INTO `questions` VALUES ('111', '0', '{\"0\":\"master\",\"1\":\"single\",\"2\":\"critical\",\"3\":\"atomic\",\"title\":\"指定代码只能由线程组中的一个线程执行的 OpenMP 编译制导命令是\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('112', '0', '{\"0\":\"Load-link 和普通的 Load 指令没有差别，只是多核处理器上的特别叫法。\",\"1\":\"Store-conditional 指令和普通的 Store 指令没有差别，只是多核处理器上的特别叫法。\",\"2\":\"Load-link 和 Store-conditional 指令可以用于实现同步原语。\",\"3\":\"Load-link 指令有可能失败。\",\"title\":\"下面关于 Load-link 和 Store-conditional 指令的说法，正确的是\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('113', '0', '{\"0\":\"带宽\",\"1\":\"速率\",\"2\":\"延迟\",\"3\":\"延迟带宽积\",\"title\":\"链路的（ ）是指它传输数据的速度。\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('114', '0', '{\"0\":\"critical\",\"1\":\"barrier\",\"2\":\"atomic\",\"3\":\"master\",\"title\":\"在并行域当中，在一段代码临界区之前只有一个线程进入，是使用什么关键字\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('115', '0', '{\"0\":\"M/0.85\",\"1\":\"M/(0.85+0.015M)\",\"2\":\"M/(0.85085+0.165M)\",\"3\":\"M/(0.85085+0.015M)\",\"title\":\"假设有一个计算问题，其中串行计算量占 15%。为实现并行计算，需要增加 1.5%的计算量，这部分计算量是不能并行执行的，并且与所使用处理器/执行内核的数量无关。此外，每个处理器执行内核在执行并行计算任务的过程中，还需要执行为所承担的并行任务执行一定的额外操作。这些额外操作的计算量是所承担并行任务量 的 0.1%。请问，在一个有 M 颗处理器/执行内核的计算平台上，并行程序可取得的最大加速比是多少？\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('116', '0', '{\"0\":\"共享\",\"1\":\"伪共享\",\"title\":\"缓存一致性强迫多个线程看起来好像是共享同一个内存单元，这称为()\",\"len\":2}', 'B', '', '3');
INSERT INTO `questions` VALUES ('117', '0', '{\"0\":\"栈\",\"1\":\"堆\",\"2\":\"线程局部存储\",\"3\":\"DATA 段\",\"title\":\"在 OpenMP 中，用 threadprivate 作用域标记的变量会存储在内存中的什么位置：\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('118', '0', '{\"0\":\"线程任务量不均衡\",\"1\":\"并行过载和顺序过载\",\"2\":\"以上都是\",\"title\":\"Intel(R)线程档案器为 OpenMP  提供了哪些功能？( ) A  并行代码和顺序代码的时间花费\",\"len\":3}', 'C', '', '3');
INSERT INTO `questions` VALUES ('119', '0', '{\"0\":\"都没有\",\"1\":\"都有\",\"2\":\"可有可无\",\"title\":\"MPI 的名字( )  前缀 MPI_\",\"len\":3}', 'B', '', '3');
INSERT INTO `questions` VALUES ('120', '0', '{\"0\":\"点对点通信\",\"1\":\"集合通信\",\"2\":\"广播\",\"title\":\"在 MPI 里涉及通信子中所有进程的通信函数是函数 ( )\",\"len\":3}', 'B', '', '3');
INSERT INTO `questions` VALUES ('121', '0', '{\"0\":\"任务并行\",\"1\":\"任务串行\",\"2\":\"数据并行\",\"3\":\"数据串行\",\"title\":\"编写并行程序将待解决问题所需要处理的数据分配给各个核的方法是（）\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('122', '0', '{\"0\":\"4\",\"1\":\"16\",\"2\":\"32\",\"3\":\"64\",\"title\":\"AMD 的 Radeon7970 图形卡包括（ ）个向量处理器(计算单元)?\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('123', '0', '{\"0\":\"动态功率\",\"1\":\"静态功率\",\"2\":\"动态功率和静态功率中较小的功率\",\"3\":\"动态功率与静态功率之和\",\"title\":\"CMOS 的动态功耗等于\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('124', '0', '{\"0\":\"效率\",\"1\":\"加速比\",\"title\":\"串行时间与并行时间的比值叫做\",\"len\":2}', 'B', '', '3');
INSERT INTO `questions` VALUES ('125', '0', '{\"0\":\"284\",\"1\":\"142\",\"2\":\"71\",\"3\":\"36；\",\"title\":\"要配置双精度浮点峰值性能是 20TFlops 的 HPC 集群，目前采用双路 2.93GHz  Intel  westmere 六核处理器 X5670来构建，我们知道该处理器的每个核都有两套浮点向量计算单元，问该集群共需要多少个计算节点？\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('126', '0', '{\"0\":\"KNF\",\"1\":\"KNC\",\"2\":\"KNL\",\"3\":\"KNH\",\"title\":\"What\'s the code name of 2nd generation Xeon Phi product?\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('127', '0', '{\"0\":\"61\",\"1\":\"48\",\"2\":\"57\",\"3\":\"72\",\"title\":\"How many cores on the Intel Xeon Phi product at least?\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('128', '0', '{\"0\":\"1\",\"1\":\"2\",\"2\":\"3\",\"3\":\"4\",\"title\":\"How many VPU will be available on the 2nd generation Xeon Phi product?\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('129', '0', '{\"0\":\"Relace static task partition with dynamic task partition\",\"1\":\"Remove MPI barrier\",\"2\":\"atomic computation\",\"title\":\"Which one is not the frequently used skills to tune MPI application?\",\"len\":3}', 'C', '', '3');
INSERT INTO `questions` VALUES ('130', '0', '{\"0\":\"Replace arrays with temporary variable\",\"1\":\"Replace 2D structure with 1D\",\"2\":\"AoS-＞SoA\",\"3\":\"Loop fusion and Loop Split\",\"title\":\"Which skill is not used for data restructure?\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('131', '1', '{\"0\":\"C 语言\",\"1\":\"C++语言\",\"2\":\"Fortran  语言\",\"title\":\"下面是 MPI 可以绑定的语言的是( )\",\"len\":3}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('132', '1', '{\"0\":\"消息拆卸\",\"1\":\"消息装配\",\"2\":\"消息传递\",\"title\":\"MPI 的消息传递过程分为 ( )\",\"len\":3}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('133', '1', '{\"0\":\"派生\",\"1\":\"合并\",\"2\":\"分离\",\"3\":\"消亡\",\"title\":\"如果进程是执行的“主线程”，其他线程由主线程启动和停止，那么我们可以设想进程和它的子线程如下进行， 当一个线程开始时，它从进程中（ ）出来；当一个线程结束，它（ ）到进程中。\",\"len\":4}', 'A;B', '', '3');
INSERT INTO `questions` VALUES ('134', '1', '{\"len\": 6, \"1\": \"执行终止\", \"title\": \"作为多遍优化算法 PGO 的三步过程由以下哪三步构成？( )\", \"5\": \"代码执行与评估\", \"3\": \"执行被插入信息采集代码的程序(Instrumented execution)\", \"4\": \"插入信息采集代码后编译(Instrumented compilation)\", \"0\": \"代码编译\", \"2\": \"反馈编译（feedback compilation）\"}', 'C;D', '', '3');
INSERT INTO `questions` VALUES ('135', '1', '{\"0\":\"少用锁，甚至采用无锁编程。\",\"1\":\"使用原子操作来替代锁。\",\"2\":\"从设计和算法层面来缩小串行化所占的比例。\",\"3\":\"设计并行指令\",\"title\":\"对于如何解决串行化方面的难题，以下表述正确的是：()\",\"len\":4}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('136', '1', '{\"0\":\"在 pthread 并行程序中，不允许 worker 线程执行函数调用\",\"1\":\"在 MPI 并行程序中，同一个串行函数，可以同时被多个进程分别执行\",\"2\":\"在 MPI 并行程序中，如果一个某个函数的数据运算划分到多个处理器上并行执行，则在参与计算的处理器 上都要执行该函数的调用\",\"3\":\"在 pthread 并行程序中，不允许 worker 线程执行线程创建操作\",\"title\":\"关于函数调用，下列哪些说法是正确的？\",\"len\":4}', 'B;C;D', '', '3');
INSERT INTO `questions` VALUES ('138', '1', '{\"0\":\"Computation Granularity *B Load Balance\",\"1\":\"Communication and I/O\",\"2\":\"Synchronization Overhead\",\"title\":\"To achieve the good load balance, which items may be needs to considered?\",\"len\":3}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('139', '1', '{\"0\":\"pragma ivdep\",\"1\":\"pragma simd\",\"2\":\"pragma vector align\",\"3\":\"pragma loop count(n)\",\"title\":\"Frenquently used pragma for vectorization includes\",\"len\":4}', 'A;B;C;D', '', '3');
INSERT INTO `questions` VALUES ('140', '0', '{\"0\":\"栈\",\"1\":\"堆\",\"2\":\"线程局部存储\",\"3\":\"DATA 段\",\"title\":\"在 OpenMP 中，用 threadprivate 作用域标记的变量会存储在内存中的什么位置：\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('141', '0', '{\"0\":\"集群\",\"1\":\"网格\",\"2\":\"分布式内存系统\",\"3\":\"共享内存系统\",\"title\":\"（）提供一种基础架构，使地理上分布的计算机大型网络转换成一个分布式内存系统，通常这样的系统是异构 的。\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('143', '0', '{\"0\":\"在传统的操作系统中，CPU  调度和分派的基本单位是进程\",\"1\":\"在引入线程的操作系统中，则把线程作为 CPU  调度和分派的基本单位\",\"2\":\"同一进程中线程的切换不会引起进程切换，从而避免了昂贵的系统调用\",\"3\":\"由一个进程中的线程切换到另一进程中的线程时，也不会引起进程切换\",\"title\":\"以下表述不正确的是：( )\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('144', '0', '{\"0\":\"信号量\",\"1\":\"互斥量\",\"title\":\"一个条件变量总是与一个 ( )相关联\",\"len\":2}', 'B', '', '3');
INSERT INTO `questions` VALUES ('145', '0', '{\"0\":\"任务,数据\",\"1\":\"任务,线程\",\"2\":\"数据,线程\",\"3\":\"进程,数据\",\"title\":\"OpenCL 提供了基于()和基于()的两种并行计算方式.\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('146', '0', '{\"0\":\"写回法\",\"1\":\"重复写\",\"2\":\"备份\",\"title\":\"当 CPU 向 Cache 中写数据时，Cache 中的值就会不同或者不一致，有两种方法：写直达和（ ）来解决这个不一 致性问题。\",\"len\":3}', 'A', '', '3');
INSERT INTO `questions` VALUES ('147', '0', '{\"0\":\"在 MIM*D 并行计算机上，并行程序的加速比不能随处理器执行核的数量按比例增长\",\"1\":\"并行程序的运行时间越短，加速比越高\",\"2\":\"确定了运行计算平台、及所使用的处理器数量，就可以确定并行程序的加速比\",\"3\":\"根据 Amdahl 定理，并行程序的加速比小于参与计算的处理器执行核数量\",\"title\":\"关于加速比，正确的说法是：\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('148', '0', '{\"0\":\"消息传递\",\"1\":\"负载平衡\",\"2\":\"同步\",\"3\":\"异步\",\"title\":\"在（）中，一个进程必须调用一个发送函数，并且发送函数必须与另一个进程调用的接受函数相匹配。\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('149', '0', '{\"0\":\"任务并行\",\"1\":\"任务串行\",\"2\":\"数据并行\",\"3\":\"数据串行\",\"title\":\"编写并行程序将待解决问题所需要处理的数据分配给各个核的方法是（）\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('150', '0', '{\"0\":\"合并最里面两层循环\",\"1\":\"最里层 for 循环用两个线程处理\",\"2\":\"合并最外两层循环\",\"title\":\"#pragma omp for collapse(2)的作用是什么？\",\"len\":3}', 'C', '', '3');
INSERT INTO `questions` VALUES ('151', '0', '{\"0\":\"分辨率\",\"1\":\"电压\",\"2\":\"电流\",\"title\":\"（ ）是指计时器的时间测量单位，是计时器在计时的过程中最短的非零时间跨度。\",\"len\":3}', 'A', '', '3');
INSERT INTO `questions` VALUES ('152', '0', '{\"0\":\"死锁\",\"1\":\"挂起\",\"title\":\"条件变量是一个数据对象，允许线程在某个特定条件或事件发生前都处于 ( )状态\",\"len\":2}', 'B', '', '3');
INSERT INTO `questions` VALUES ('153', '0', '{\"0\":\"NUMA 模型是高速缓存一致的、非均匀存储访问模型的简称。\",\"1\":\"并行计算机访存模型只有 NUMA、COMA 和 NORMA 这三种类型\",\"2\":\"多台 P*C 机通过网线连接形成的机群属于 NORM*A 非远程存储访问模型。\",\"3\":\"COMA 模型是 Coherent-Only Memory Access 的缩写。\",\"title\":\"下面哪个关于并行计算机的访存模型描述是对的？\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('156', '0', '{\"0\":\"随机的\",\"1\":\"特定的\",\"title\":\"不同进程对同一个内容的输出，其顺序是( )\",\"len\":2}', 'A', '', '3');
INSERT INTO `questions` VALUES ('157', '0', '{\"0\":\"共享存储并行计算模型包括 PRAM 模型和 BSP 模型\",\"1\":\"共享存储并行计算模型包括 LogP 模型和 PRAM 模型\",\"2\":\"分布式存储并行计算模型包括 PRAM 模型和 BSP 模型\",\"3\":\"分布式存储并行计算模型包括 LogP 模型和 BSP 模型；\",\"title\":\"下面关于并行计算模型，哪个描述是正确的？\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('158', '0', '{\"0\":\"MPI\",\"1\":\"CUDA\",\"2\":\"MapReduce\",\"3\":\"Pthreads\",\"title\":\"（ ）和 OpenMP 是为共享内存系统的编程而设计的，它们提供访问共享内存的机制。\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('159', '0', '{\"0\":\"3X\",\"1\":\"2X\",\"2\":\"1.5X\",\"3\":\"4X\",\"title\":\"How much improvement of Single-Thread Performance on 2nd generation compared to the 1st generation Intel Xeon Phi coprocessor?\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('160', '0', '{\"0\":\"128bits\",\"1\":\"512bits\",\"2\":\"256bits\",\"3\":\"64bits\",\"title\":\"How long is vector length on Xeon Phi?\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('161', '0', '{\"0\":\"4GB\",\"1\":\"8GB\",\"2\":\"16GB\",\"3\":\"32GB\",\"title\":\"What \'s the maxmum size of on-package memory (MCDRAM) will be available on 2nd generation Xeon Phi?\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('162', '0', '{\"0\":\"6\",\"1\":\"4\",\"2\":\"8\",\"3\":\"10\",\"title\":\"How many channels of DDR4 will be available on 2nd generation Xeon Phi?\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('163', '0', '{\"0\":\"KNF\",\"1\":\"KNC\",\"2\":\"KNL\",\"3\":\"KNH\",\"title\":\"What\'s the code name of 2nd generation Xeon Phi product?\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('165', '1', '{\"0\":\"MKL  是线程安全的， 可以在多线程中被使用\",\"1\":\"MKL  使用 OpenMP*  实现多线程\",\"2\":\"MKL  函数内部实现了多线程\",\"3\":\"MKL  函数内部实现了多线程，但 MKL 库不是线程安全的\",\"title\":\"下面关于英特 MKL 多线程的特性，哪些是正确的？( )\",\"len\":4}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('166', '1', '{\"0\":\"Microsoft\",\"1\":\"GNU\",\"2\":\"Intel\",\"title\":\"TBB 支持的 C++编译器包括：( )\",\"len\":3}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('167', '1', '{\"0\":\"concurrent_set\",\"1\":\"concurrent_queue\",\"2\":\"concurrent_hash_map\",\"3\":\"concurrent_vector\",\"title\":\"以下属于 TBB 中的并行容器的是：( )\",\"len\":4}', 'B;C;D', '', '3');
INSERT INTO `questions` VALUES ('169', '1', '{\"0\":\"进程 0 先执行 MPI_Send 发送 M0、然后执行 MPI_Recv 接收 M1，进程 1 先执行 MPI_Send 发送 M1、然后执行 MPI_Recv 接收 M0\",\"1\":\"进程 0 先执行 MPI_Recv 接收 M1、然后执行 MPI_Send 发送 M0，进程 1 执行 MPI_Recv 接收 M0、然后先执行 MPI_Send 发送 M1\",\"2\":\"进程 0 先执行 MPI_ISend 发送 M0、然后执行 MPI_Recv 接收 M1，进程 1 先执行 MPI_Send 发送 M1、然后执行 MPI_Recv 接收 M0\",\"3\":\"进程 0 先执行 MPI_IRecv 接收 M1、然后执行 MPI_Send 发送 M0，进程 1 执行 MPI_Recv 接收 M0、然后先执行 MPI_Send 发送 M1\",\"title\":\"进程 0 要将消息 M0 发送给进程 1，进程 1 要将消息 M1 发送给进程 0。下列哪几种情况下，可能出现“死锁”？\",\"len\":4}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('170', '1', '{\"0\":\"消息拆卸\",\"1\":\"消息装配\",\"2\":\"消息传递\",\"title\":\"MPI 的消息传递过程分为 ( )\",\"len\":3}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('171', '1', '{\"0\":\"编译器的编译优化\",\"1\":\"处理器的乱序执行\",\"2\":\"使用原子操作\",\"3\":\"使用单核 CPU\",\"title\":\"以下哪些选项有可能使得程序不会按照程序本身的顺序执行的\",\"len\":4}', 'A;B', '', '3');
INSERT INTO `questions` VALUES ('172', '1', '{\"0\":\"Use nontemporal pragma\",\"1\":\"pragma prefetch\",\"2\":\"the option of \\\"-qopt-streaming-stores=always\\\"\",\"3\":\"AoS-＞SoA\",\"title\":\"In order to improve memory bandwidth, comman used skills inlclude:\",\"len\":4}', 'A;C', '', '3');
INSERT INTO `questions` VALUES ('173', '1', '{\"0\":\"__attribute    ((aligned(n)))\",\"1\":\"mm_aligned_malloc(size, alignment_bytes)/);    mm_aligned_free()\",\"2\":\"scalable_aligned_malloc()/scalable_aligned_free()\",\"title\":\"Data alignment about dynamic memory can be achieved by __.\",\"len\":3}', 'B;C', '', '3');
INSERT INTO `questions` VALUES ('174', '0', '{\"0\":\"60%\",\"1\":\"70%\",\"2\":\"80%\",\"3\":\"90%\",\"title\":\"某并行任务中，通信部分占总时间 50%，计算占%40，而并行带来的额外开销占%10。经过优化，使得 通信与计算得到部分重叠，有 40%的通信时间被计算重叠。此时，总时间为原本的\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('175', '0', '{\"0\":\"进程\",\"1\":\"线程\",\"2\":\"接口\",\"title\":\"（ ）为程序员提供了一种机制，将程序划分为多个大致独立的任务，当某个任务阻塞时能执行其他任 务。\",\"len\":3}', 'B', '', '3');
INSERT INTO `questions` VALUES ('176', '0', '{\"0\":\"0\",\"1\":\"1\",\"2\":\"2\",\"3\":\"以上都有可能\",\"title\":\"在 Concurrent read concurrent write (CRCW) PRAM 模型中，两个处理器同时对初值为 0 的内存空间进行 加一操作（*p = *p + 1）。当其中一个处理器完成其操作时，该内存空间不可能的值是：\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('178', '0', '{\"0\":\"NUMA 模型是高速缓存一致的、非均匀存储访问模型的简称。\",\"1\":\"并行计算机访存模型只有 NUMA、COMA 和 NORMA 这三种类型\",\"2\":\"多台 PC 机通过网线连接形成的机群属于 NORMA 非远程存储访问模型。\",\"3\":\"COMA 模型是 Coherent-Only Memory Access 的缩写。\",\"title\":\"下面哪个关于并行计算机的访存模型描述是对的？\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('180', '0', '{\"0\":\"atomic\",\"1\":\"barrier\",\"2\":\"single\",\"3\":\"master\",\"title\":\"在并行域当中，指定一个数据操作原子性操作完成，是使用什么关键字\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('181', '0', '{\"0\":\"设计阶段\",\"1\":\"测试阶段\",\"2\":\"需求收集阶段\",\"3\":\"以上全部?\",\"title\":\"我们应该在产品生命周期中的哪个阶段考虑产品的性能？( )?\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('182', '0', '{\"len\": 4, \"1\": \"1\", \"title\": \"在 Exclusive read exclusive write (EREW) PRAM 模型中，三个处理器同时对初值为 0 的内存空间进行加一 操作（*p = *p + 1）。当所有处理器完成其操作时，该内存空间不可能的值是：\", \"3\": \"以上均不可能\", \"0\": \"0\", \"2\": \"2\"}', 'D', '', '3');
INSERT INTO `questions` VALUES ('183', '0', '{\"0\":\"进程\",\"1\":\"线程\",\"2\":\"接口\",\"3\":\"多发射\",\"title\":\"有两种主要方法来实现指令级并行：流水线和（ ）。\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('184', '0', '{\"0\":\"1\",\"1\":\"2\",\"2\":\"4\",\"3\":\"8\",\"title\":\"Intel Xeon Phi 处理器中，每个核有几个硬件线程。\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('185', '0', '{\"0\":\"barrier\",\"1\":\"single\",\"2\":\"atomic\",\"3\":\"master\",\"title\":\"在并行域当中，使代码线程同步，是使用什么关键字\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('186', '0', '{\"0\":\"忙等待\",\"1\":\"运行\",\"2\":\"就绪\",\"3\":\"休眠\",\"title\":\"在（ ）时，一个线程进入一个循环，这个循环的目的只是测试一个条件。\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('191', '0', '{\"0\":\"Data alignment\",\"1\":\"Cache blocking\",\"2\":\"Prefetch\",\"3\":\"data restructure\",\"title\":\"Which one is the freqently used skill to improve data locality?\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('192', '0', '{\"0\":\"O1\",\"1\":\"O2\",\"2\":\"O3\",\"3\":\"O0\",\"title\":\"What\'s the default vectorization option for Intel Compiler?\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('195', '1', '{\"len\": 4, \"1\": \"在引入线程的操作系统中，一个进程中的多个线程之间不可以并发执行\", \"title\": \"以下表述正确的是：( )\", \"3\": \"线程是拥有系统资源的一个独立单位，它可以拥有自己的资源\", \"0\": \"在引入线程的操作系统中，进程之间可以并发执行\", \"2\": \"进程是拥有系统资源的一个独立单位，它可以拥有自己的资源\"}', 'A;C', '', '3');
INSERT INTO `questions` VALUES ('196', '1', '{\"title\": \"Intel  调优助手能够给我们自动推荐代码改进办法，主要有以下哪些方面？ ( ) A  算法自动改进\", \"len\": 3, \"1\": \"取样向导增强\", \"0\": \"处理器瓶颈以及改进\", \"2\": \"超线程\"}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('197', '1', '{\"title\": \"避免对临界区竞争访问的基本方法有 ()\", \"len\": 3, \"1\": \"互斥量\", \"0\": \"忙等待\", \"2\": \"信号量\"}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('198', '1', '{\"title\": \"请说出目前 MPI 的主要免费实现的种类 ()\", \"len\": 3, \"1\": \"LAM\", \"0\": \"MPICH\", \"2\": \"CHIMP\"}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('200', '1', '{\"len\": 4, \"1\": \"Offload\", \"title\": \"The features supported on the 1st generation Xeon Phi include__\", \"3\": \"Symmetric\", \"0\": \"Native\", \"2\": \"Self-boot\"}', 'A;B;D', '', '3');
INSERT INTO `questions` VALUES ('201', '1', '{\"len\": 4, \"1\": \"pragma prefetch\", \"title\": \"In order to improve memory bandwidth, comman used skills inlclude:\", \"3\": \"AoS-＞SoA\", \"0\": \"Use nontemporal pragma\", \"2\": \"the option of \\\"-qopt-streaming-stores=always\\\"\"}', 'A;C', '', '3');
INSERT INTO `questions` VALUES ('202', '0', '{\"title\": \"以下哪个事例是 Vtune 性能分析器的基于事件的采样？ ( )\", \"len\": 3, \"1\": \"Every n processor ticks\", \"0\": \"Branch misprediction\", \"2\": \"Bugs encountered\"}', 'A', '', '3');
INSERT INTO `questions` VALUES ('203', '0', '{\"len\": 4, \"1\": \"1MB\", \"title\": \"Mmap()函数可以申请大页表空间，请问它申请的空间，每个页表的大小是多少?\", \"3\": \"4MB\", \"0\": \"512KB\", \"2\": \"2MB\"}', 'C', '', '3');
INSERT INTO `questions` VALUES ('204', '0', '{\"0\":\"stack\",\"1\":\"data section\",\"2\":\"register set\",\"3\":\"thread ID\",\"title\":\"同一进程下的线程可以共享以下\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('205', '0', '{\"0\":\"通信子\",\"1\":\"标签\",\"title\":\"在 MPI 中 ( )  指的是一组可以互相发送消息的进程集合\",\"len\":2}', 'A', '', '3');
INSERT INTO `questions` VALUES ('206', '0', '{\"0\":\"弱\",\"1\":\"强\",\"title\":\"如果程序可以在不增加问题规模的前提下维持恒定效率，那么程序拥有( )  扩展性\",\"len\":2}', 'B', '', '3');
INSERT INTO `questions` VALUES ('207', '0', '{\"0\":\"强确定性\",\"1\":\"弱确定性\",\"2\":\"非确定性\",\"title\":\"在任何一个 MIMD 系统中，如果处理器异步执行，那么很可能会引发（ ）。\",\"len\":3}', 'C', '', '3');
INSERT INTO `questions` VALUES ('208', '0', '{\"0\":\"进程悬挂\",\"1\":\"进程阻\",\"2\":\"进程死锁\",\"title\":\"如果一个进程试图接收消息，但没有相匹配的消息，那么该进程将会被永远阻塞在那里,这种情况叫做( )\",\"len\":3}', 'A', '', '3');
INSERT INTO `questions` VALUES ('209', '0', '{\"0\":\"条件变量\",\"1\":\"互斥量\",\"title\":\"在 Pthreads 中实现路障的更好方法是采用 ( )\",\"len\":2}', 'A', '', '3');
INSERT INTO `questions` VALUES ('210', '0', '{\"0\":\"各个线程共享同一个存储空间\",\"1\":\"一个条件信号可以唤醒多个线程\",\"2\":\"允许两个线程同时处于相同的临界区\",\"3\":\"采用互斥锁机制，可以解决线程之间的“读-写”冲突\",\"title\":\"关于 pthread 线程并行模型，正确的说法是：\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('212', '0', '{\"0\":\"采用超级流水线技术\",\"1\":\"采用超标量技术\",\"2\":\"以上都是\",\"3\":\"以上都不是\",\"title\":\"提高微处理器内部执行的并行性有哪些措施。( )\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('213', '0', '{\"0\":\"写回法\",\"1\":\"重复写\",\"2\":\"备份\",\"3\":\"写直达\",\"title\":\"在（ ）Cache 中，当 CPU 向 Cache 写数据时，高速缓存行会立即写入主存中。\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('214', '0', '{\"0\":\"Flynn 分类法\",\"1\":\"PCAM 方法\",\"2\":\"KMP 算法\",\"title\":\"通常（ ）用对并行硬件进行分类，通过系统可以处理的指令流数目和数据流数目来区别各个分类。\",\"len\":3}', 'A', '', '3');
INSERT INTO `questions` VALUES ('216', '0', '{\"0\":\"进程\",\"1\":\"线程\",\"2\":\"接口\",\"title\":\"当用户运行一个程序时，操作系统创建一个（ ）。\",\"len\":3}', 'A', '', '3');
INSERT INTO `questions` VALUES ('217', '0', '{\"0\":\"进程和线程都可以独立执行\",\"1\":\"线程是 CPU 调度和分派的基本单位\",\"2\":\"进程是系统进行资源分配和调度的一个独立单位\",\"3\":\"线程必须依存在进程中，由进程提供多个线程执行的控制\",\"title\":\"关于进程和线程的描述中不正确的是\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('218', '0', '{\"0\":\"MPI_Reduce\",\"1\":\"MPI_Allreduce\",\"2\":\"MPI_Reduce_scatter\",\"3\":\"MPI_Scan\",\"title\":\"在 MPI 集合通信中，下列哪一个函数可以完成多个进程间的前缀和（prefix sum）计算：\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('219', '0', '{\"0\":\"不可超越的\",\"1\":\"可超越的\",\"title\":\"MPI 要求消息是 ( )\",\"len\":2}', 'A', '', '3');
INSERT INTO `questions` VALUES ('220', '0', '{\"0\":\"互斥条件：一个资源每次只能被一个进程使用\",\"1\":\"请求与保持条件：一个进程因请求资源而阻塞时，对已获得的资源保持不放\",\"2\":\"资源分配不当:资源分配的顺序不合理\",\"3\":\"循环等待条件:若干进程之间形成一种头尾相接的循环等待资源关系\",\"title\":\"产生死锁的必要条件不包括\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('221', '0', '{\"0\":\"进程悬挂\",\"1\":\"进程阻碍\",\"2\":\"进程死锁\",\"title\":\"标签不匹配和目标进程的进程号与源进程的进程号不相同都会导致 （）\",\"len\":3}', 'A', '', '3');
INSERT INTO `questions` VALUES ('222', '0', '{\"0\":\"SSE\",\"1\":\"IMCI\",\"2\":\"AVX2\",\"3\":\"AVX-512\",\"title\":\"What\'s the instruction set on 2nd generation xeon phi?\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('223', '0', '{\"0\":\"Add compiler option\",\"1\":\"pragma prefetch\",\"2\":\"prefetch intrinsic\",\"3\":\"Cache blocking\",\"title\":\"Which skill is not used for prefetch?\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('224', '1', '{\"0\":\"MPICH\",\"1\":\"LAM\",\"2\":\"CHIMP\",\"title\":\"请说出目前 MPI 的主要免费实现的种类 ()\",\"len\":3}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('225', '1', '{\"0\":\"编写适用于特定 CPU  的优化代码\",\"1\":\"避免冗余的函数调用\",\"2\":\"避免不必要的边界检查\",\"3\":\"利 用局部变量保存中间计算结果\",\"title\":\"独立于体系结构性能优化方法主要有：( )\",\"len\":4}', 'B;C;D', '', '3');
INSERT INTO `questions` VALUES ('227', '1', '{\"len\": 4, \"1\": \"扩展指令集\", \"title\": \"对于现代微处理器体系结构而言，对性能优化影响比较大的主要是：( )\", \"3\": \"指令流水线的深度\", \"0\": \"超标量\", \"2\": \"乱序执行\"}', 'A;C;D', '', '3');
INSERT INTO `questions` VALUES ('228', '1', '{\"0\":\"Intel C/C++编译器\",\"1\":\"IPP 性能库\",\"2\":\"MKL 函数库\",\"3\":\"TBB 多线程开发库\",\"title\":\"英特尔 Parallel Composer 主要包含：( )\",\"len\":4}', 'A;B;D', '', '3');
INSERT INTO `questions` VALUES ('229', '1', '{\"0\":\"基于时间取样\",\"1\":\"随机取样\",\"2\":\"基于事件取样\",\"3\":\"线性取样\",\"title\":\"VTune  性能分析器中的取样功能有哪几种方式？()\",\"len\":4}', 'A;C', '', '3');
INSERT INTO `questions` VALUES ('232', '1', '{\"0\":\"OpenMP\",\"1\":\"Intel Cilk Plus,\",\"2\":\"Intel Threading Building Blocks\",\"title\":\"Which are the frenquently used multi-thread parallelization methods? A MPI\",\"len\":3}', 'A;B;C', '', '3');
INSERT INTO `questions` VALUES ('233', '0', '{\"0\":\"没有区别所以没有代价\",\"1\":\"和-O1(/O1)相比可能会大幅增加代码大小\",\"2\":\"性能优势将只能发挥在某些特定硬件平台上\",\"title\":\"使用 Intel 编译器时，开关-O2 对代码进行和开关-O1 或/O1 相类似的优化，但是会以什么为“代价”？( )\",\"len\":3}', 'C', '', '3');
INSERT INTO `questions` VALUES ('235', '0', '{\"0\":\"程序计数器\",\"1\":\"寄存器集合\",\"2\":\"堆栈\",\"3\":\"堆\",\"title\":\"一个标准的线程不一定需要哪一项资源？\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('236', '0', '{\"0\":\"flush\",\"1\":\"critical\",\"2\":\"atomic\",\"3\":\"master\",\"title\":\"在并行域当中，保证各个 openmp 线程数据影像的一致性，是使用什么关键字\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('237', '0', '{\"0\":\"稳定\",\"1\":\"速率\",\"2\":\"延迟\",\"3\":\"抖动\",\"title\":\"两个常用来衡量互连网络性能的指标：（ ）和带宽。\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('238', '0', '{\"0\":\"OpenMP  可以根据目标系统尽量使用最优数量的线程个数。\",\"1\":\"使用线程池可以避免为每个线程创建新进程的开销\",\"2\":\"线程池通常具有最大线程数限制，如果所有线程都繁忙，而额外的任务将放入队列中，直到有线程可用时 才能够得到处理\",\"3\":\"对于有优先级的线程，也可以使用线程池\",\"title\":\"以下表述错误的是：()\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('239', '0', '{\"0\":\"单指令多数据\",\"1\":\"多指令多数据\",\"2\":\"分布式内存\",\"3\":\"共享内存\",\"title\":\"（ ）系统支持同时多个指令流在多个数据流上操作。\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('241', '0', '{\"0\":\"进程级\",\"1\":\"线程级\",\"2\":\"程序级\",\"3\":\"任务级\",\"title\":\"（ ）并行是尝试通过同时执行不同线程来提供并行性。\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('242', '0', '{\"0\":\"可以，会\",\"1\":\"可以，不会\",\"2\":\"不可以，会\",\"3\":\"不可以，不会\",\"title\":\"具有不同局部性的存储单元，__放置在同一 cache 行中，这样__引发伪共享问题。( )\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('243', '0', '{\"0\":\"MKL_solver.lib\",\"1\":\"MKL_lapack.lib\",\"2\":\"MKL_c.lib\",\"3\":\"MKL_c_dll.lib\",\"title\":\"在 Windows*中静态链接 MKL  的 DFT 函数，应该选择下面哪一个 MKL 库\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('244', '0', '{\"0\":\"主存\",\"1\":\"寄存器\",\"2\":\"互联结构\",\"3\":\"程序计数器\",\"title\":\"控制单元有一个特殊的存储器，用来存放下一条指令的地址，叫做（ ）\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('245', '0', '{\"0\":\"4\",\"1\":\"16\",\"2\":\"32\",\"3\":\"64\",\"title\":\"AMD 的 Radeon7970 图形卡包括（ ）个向量处理器(计算单元)?\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('247', '0', '{\"0\":\"Loop Interchange\",\"1\":\"Data restructure\",\"2\":\"vectorization\",\"3\":\"Cache Blocking\",\"title\":\"Which optimization methods is not used in the case of \\\"small matrix multiplication\\\"?\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('248', '0', '{\"title\": \"Which optimization may not apply for below code?\", \"len\": 3, \"1\": \"Parallelization and Use \\\"pragma omp atomic\\\" to make sure the right result\", \"0\": \"Vectorize the loop\", \"2\": \"Pre-caculate rand() and store into an array\"}', 'A', '', '3');
INSERT INTO `questions` VALUES ('249', '0', '{\"0\":\"Reduce IO latentcy\",\"1\":\"Improve cache hit rate\",\"2\":\"Vectorization\",\"3\":\"Parallelization\",\"title\":\"What is the key reason for performance improvement after replacing Glibc rand() with Intel Math Kernel Library random generator in the case of \\\"Deep Learning\\\"?\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('250', '0', '{\"title\": \"Which one is not the potential issue of the code?\", \"len\": 3, \"1\": \"In the most inner loop, bad vectorization effect,even can\'t be vectorized\", \"0\": \"Can\'t be parallelized in the outer loop\", \"2\": \"non-contiguous memory access\"}', 'A', '', '3');
INSERT INTO `questions` VALUES ('251', '0', '{\"title\": \"Which option is commanly used for detailed vectorization information? D-no-vec\", \"len\": 3, \"1\": \"-fno-alias\", \"0\": \"-ansi-alias\", \"2\": \"-qopt-report\"}', 'C', '', '3');
INSERT INTO `questions` VALUES ('259', '1', '{\"len\": 4, \"1\": \"Intel? Cilk? Plus Array Notations\", \"title\": \"The common used vectorization methods include\", \"3\": \"Intrinsics\", \"0\": \"Auto-Vectorized using \\\"pragma\\\"\", \"2\": \"Elemental Functions\"}', 'A;B;C;D', '', '3');
INSERT INTO `questions` VALUES ('260', '0', '{\"0\":\"弱\",\"1\":\"强\",\"title\":\"如果当问题规模增加，需要通过增大进程数来维持程序效率的，那么程序拥有（）可扩展性\",\"len\":2}', 'A', '', '3');
INSERT INTO `questions` VALUES ('261', '0', '{\"0\":\"master\",\"1\":\"barrier C atomic D Single\",\"title\":\"在并行域当中，指定一段代码由主线程执行，是使用什么关键字\",\"len\":2}', 'A', '', '3');
INSERT INTO `questions` VALUES ('264', '0', '{\"0\":\"当两个或多个进程试图在同一时刻访问共享内存，或读写某些共享数据，就会产生竞争条件\",\"1\":\"每个临界区都有相应的进入区（entry section）和退出区（exit section）\",\"2\":\"可能有两个线程同时进入临界区。\",\"3\":\"临界区的存在就是为了保证当有一个线程在临界区内执行的时候，不能有其他任何进程被允许在临界区执 行\",\"title\":\"以下表述不正确的是：( )\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('265', '0', '{\"0\":\"线程\",\"1\":\"进程\",\"title\":\"在共享内存编程中，运行在一个处理器上的一个程序实例称为( )\",\"len\":2}', 'A', '', '3');
INSERT INTO `questions` VALUES ('266', '0', '{\"0\":\"进程\",\"1\":\"线程\",\"2\":\"接口\",\"title\":\"（ ）为程序员提供了一种机制，将程序划分为多个大致独立的任务，当某个任务阻塞时能执行其他任 务。\",\"len\":3}', 'B', '', '3');
INSERT INTO `questions` VALUES ('268', '0', '{\"0\":\"主存\",\"1\":\"寄存器\",\"2\":\"互联结构\",\"3\":\"程序计数器\",\"title\":\"CPU 中的数据和程序执行时的状态信息存储在特殊的快速存储介质中，即（ ）。\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('269', '0', '{\"0\":\"计算强度低\",\"1\":\"计算强度相当\",\"2\":\"较难实现负载均衡\",\"3\":\"时间开销较小\",\"title\":\"在并行计算中,粗粒度的并行相对细粒度的并行来说\",\"len\":4}', 'C', '', '3');
INSERT INTO `questions` VALUES ('272', '0', '{\"0\":\"通信\",\"1\":\"负载平衡\",\"2\":\"同步\",\"3\":\"异步\",\"title\":\"一个或多个核将自己的部分和结果发送给其他的核这一过程称之为：（）\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('275', '0', '{\"title\": \"在一个集合通信中，如果属于一个进程的数据被发送到通信子中的所有进程，则这样的集合通信叫做 ( )\", \"len\": 3, \"1\": \"集合通信\", \"0\": \"点对点通信\", \"2\": \"广播\"}', 'C', '', '3');
INSERT INTO `questions` VALUES ('277', '0', '{\"0\":\"single\",\"1\":\"barrier\",\"2\":\"atomic\",\"3\":\"master\",\"title\":\"在并行域当中，有一段代码想用单线程执行，是使用什么关键字\",\"len\":4}', 'A', '', '3');
INSERT INTO `questions` VALUES ('279', '0', '{\"0\":\"锁类似于信号量，不同之处在于在同一时刻只能使用一个锁。\",\"1\":\"锁有两个操作，分别是获取锁和释放锁\",\"2\":\"互斥量是一种锁，线程对共享资源进行访问之前必须先获得锁；否则线程将保持等待状态，直到该锁可用。\",\"3\":\"若线程不主动放弃锁，其他线程可以抢占它\",\"title\":\"对于锁，以下表述不正确的是：( )\",\"len\":4}', 'D', '', '3');
INSERT INTO `questions` VALUES ('281', '0', '{\"len\": 4, \"1\": \"除非你已经有了一个相当清晰可靠的非优化版本的实现，否则你不要试图对程序进行优化\", \"title\": \"Jackson  优化定律是指：( )\", \"3\": \"以上两条都不是\", \"0\": \"不要进行优化\", \"2\": \"以上两条都是\"}', 'C', '', '3');
INSERT INTO `questions` VALUES ('282', '0', '{\"len\": 4, \"1\": \"线程是 CPU 调度和分派的基本单位\", \"title\": \"关于进程和线程的描述中不正确的是\", \"3\": \"线程必须依存在进程中，由进程提供多个线程执行的控制\", \"0\": \"进程和线程都可以独立执行\", \"2\": \"进程是系统进行资源分配和调度的一个独立单位\"}', 'A', '', '3');
INSERT INTO `questions` VALUES ('283', '0', '{\"0\":\"2\",\"1\":\"4\",\"2\":\"6\",\"3\":\"8\",\"title\":\"How many threads per core on Xeon Phi?\",\"len\":4}', 'B', '', '3');
INSERT INTO `questions` VALUES ('284', '0', '{\"0\":\"Improve TLB hit ratio.\",\"1\":\"Improve memory bandwidth\",\"2\":\"Improve data locality\",\"title\":\"What\'s the purpose of huge page setting on Xeon Phi?\",\"len\":3}', 'A', '', '3');
INSERT INTO `questions` VALUES ('294', '1', '{\"0\":\"笛卡儿拓扑\",\"1\":\"图拓扑\",\"title\":\"下面是 MPI 提供的拓扑是 ( )\",\"len\":2}', 'A;B', '', '3');
INSERT INTO `questions` VALUES ('756', '3', '下列函数将一个数组A变换成另一个数组B，A和B的元素数量相同、且![](/static/upload/mdimages/20161228163737.png)。数组A和数组B已预先划分成若干个等长片段，每个片段的大小为size，第k个片段存储在通信子\\*comm的第k号进程上。在每个处理器上，数组A的本地片段的存储空间起始地址为函数参数”A”、 数组B的本地片段的存储空间起始地址为函数参数”B”。请补充缺少的代码。\r\n\r\n```\r\nvoid mysum(MPIComm *comm, int *A, int *B, int size) {\r\n  int i, rank, np, *sum;\r\n  MPICommsize(*comm, &np);\r\n  MPICommrank(*comm, &rank);  \r\n  B[0] = A[0];\r\n  for(i=1; i<size; i++) B[i] = B[i-1] + A[i];\r\n sum = new int[np];\r\n  MPIAllgather(&B[size-1], 1, MPIINT, sum, 1, MPIINT, *comm);\r\n *sum[rank] = 0;for(i=0; i<rank; i++) sum[rank] += sum[i];for(i=0; i<size; i++) B[i] += sum[rank]; *\r\n delete[] sum; \r\n}\r\n```\r\n', '{\"0\":\"comm的第k号进程上。在每个处理器上，数组A的本地片段的存储空间起始地址为函数参数”A”、 数组B的本地片段的存储空间起始地址为函数参数”B”。请补充缺少的代码。\\n\\n```\\nvoid mysum(MPIComm \",\"1\":\"A, int \",\"2\":\"sum;\\n\\tMPICommsize(\",\"3\":\"comm, &rank);\\t\\n\\tB[0] = A[0];\\n\\tfor(i=1; i<size; i++) B[i] = B[i-1] + A[i];\\n\\tsum = new int[np];\\n\\tMPIAllgather(&B[size-1], 1, MPIINT, sum, 1, MPIINT, \",\"4\":\"sum[rank] = 0;for(i=0; i<rank; i++) sum[rank] += sum[i];for(i=0; i<size; i++) B[i] += sum[rank]; \",\"len\":5}', '', '3');
INSERT INTO `questions` VALUES ('757', '3', '下列程序的输出结果为：0 1 2 3 4 5 6 7 7 6 5 4 3 2 1 0。请补充缺少的代码。提示：对线程从0开始编号，先顺序输出线程编号，再逆序输出线程编号。\r\n\r\n```\r\n#include <pthread.h>\r\n#include <unistd.h>  \r\n#include <stdlib.h>  \r\n#include <stdio.h>  \r\n#define THREAD_NUM 8      \r\nint threadid = 0;\r\npthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;\r\npthread_cond_t  cond  = PTHREAD_COND_INITIALIZER;\r\nvoid *fun(void *arg) {\r\n    *缺少的代码*\r\n pthread_exit(NULL);\r\n} \r\nint main(int argc, char* argv[])  {  \r\n    int i;\r\n  pthread_t *threads;  \r\n threads = new pthread_t[THREAD_NUM];      \r\n    for(i=0; i<THREAD_NUM; i++)  pthread_create(&threads[i], NULL, fun, NULL); \r\n    for(i=0; i<THREAD_NUM; i++)  pthread_join(threads[i], NULL);\r\n    delete[] threads;\r\n    printf(\"\\n\");\r\n    return EXIT_SUCCESS;  \r\n}\r\n```\r\n', '{\"0\":\"fun(void \",\"1\":\"缺少的代码\",\"2\":\" argv[])  {  \\n    int i;\\n\\tpthread_t \",\"len\":3}', '', '3');
INSERT INTO `questions` VALUES ('758', '3', '下列程序输出结果：sum=4950。请补充缺少的代码。提示：线程函数\\*fun(void \\*arg)的功能是对一个数组片段的各元素求和，并通过原子操作将计算结果规约到\\*arg中的sum分量上。\r\n\r\n```\r\n#include <pthread.h>\r\n#include <unistd.h>  \r\n#include <stdlib.h>  \r\n#include <stdio.h>        \r\nstruct Task {\r\n int *data, *sum, first, last;\r\n};\r\nvoid *fun(void *arg) {\r\n Task& task=*(Task*)arg;\r\n int sum=0, i; \r\n  for(i=task.first; i<task.last; i++) sum+=task.data[i];\r\n  __sync_fetch_and_add (task.sum, sum);\r\n pthread_exit(NULL);\r\n} \r\nint main(int argc, char* argv[])  {  \r\n    int       i, data[100], sum=0, thread_num=sysconf(_SC_NPROCESSORS_ONLN);\r\n  pthread_t *threads;  \r\n Task      *tasks; \r\n  for(i=0; i<100; i++) data[i] = i;\r\n tasks   = new Task[thread_num];\r\n threads = new pthread_t[thread_num];\r\n  *缺少的代码*\r\n    for(i=0; i<thread_num; i++)  pthread_create(&threads[i], NULL, fun, &tasks[i]); \r\n    for(i=0; i<thread_num; i++)  pthread_join(threads[i], NULL);\r\n    delete[] tasks;\r\n    delete[] threads;\r\n    printf(\"sum=%d\\n\", sum);    \r\n    return EXIT_SUCCESS;  \r\n}\r\n```\r\n', '{\"0\":\"fun(void \\\\\",\"1\":\"arg中的sum分量上。\\n\\n```\\n#include <pthread.h>\\n#include <unistd.h>  \\n#include <stdlib.h>  \\n#include <stdio.h>        \\nstruct Task {\\n\\tint \",\"2\":\"sum, first, last;\\n};\\nvoid \",\"3\":\"arg) {\\n\\tTask& task=\",\"4\":\")arg;\\n\\tint sum=0, i;\\t\\n\\tfor(i=task.first; i<task.last; i++) sum+=task.data[i];\\n\\t__sync_fetch_and_add (task.sum, sum);\\n\\tpthread_exit(NULL);\\n} \\nint main(int argc, char\",\"5\":\"threads;  \\n\\tTask      \",\"6\":\"缺少的代码\",\"len\":7}', '', '3');
INSERT INTO `questions` VALUES ('759', '3', '下列函数实现数组元素求和：数组的大小为array_size，其元素全部存储在通信子\\*comm的第root号进程上，array是数组的起始地址，计算结果也返回给第root号进程。请补充缺少的代码。\r\n\r\n```\r\n#define SIZE       20 \r\n#define NOTASK     1\r\n#define NEWTASK    2  \r\nint my_sum(MPI_Comm* comm, int *array, int array_size, int root) {\r\n  MPI_Status  status;\r\n int rank, i, size, data[SIZE], val=0;\r\n MPI_Comm_rank(*comm, &rank);  \r\n  if ( rank==root ) {\r\n   *缺少的代码*\r\n }\r\n else while(1) {\r\n   MPI_Send(&val, 1, MPI_INT, root, 0, *comm);\r\n   MPI_Recv(data, SIZE, MPI_INT, root, MPI_ANY_TAG, *comm, &status);\r\n   if (status.MPI_TAG==NOTASK) break;\r\n    val = 0;\r\n    MPI_Get_count(&status, MPI_INT, &size);\r\n   for(i=0; i<size; i++) val += data[i];\r\n } \r\n}\r\n```', '{\"0\":\"comm的第root号进程上，array是数组的起始地址，计算结果也返回给第root号进程。请补充缺少的代码。\\n\\n```\\n#define SIZE       20 \\n#define NOTASK     1\\n#define NEWTASK    2  \\nint my_sum(MPI_Comm\",\"1\":\"array, int array_size, int root) {\\n\\tMPI_Status  status;\\n\\tint rank, i, size, data[SIZE], val=0;\\n\\tMPI_Comm_rank(\",\"2\":\"缺少的代码\",\"3\":\"comm);\\n\\t\\tMPI_Recv(data, SIZE, MPI_INT, root, MPI_ANY_TAG, \",\"len\":4}', '', '3');
INSERT INTO `questions` VALUES ('760', '5', '在有24颗执行核的SMP/多核处理器系统上，对二维矩阵A进行2D5P模板计算，假设A的规模为2m2n，m>n>5。请设计一个并行求解算法并给出该算法的加速比上限。\r\n\r\n', '', '', '3');
INSERT INTO `questions` VALUES ('761', '5', 'A和B是两个单精度浮点数的矩阵，A的规模为n×m、B的规模为m×k。请问，在CUDA上实现矩阵乘法A×B时，GPU与设备内存之间的最少数据交换量为多少？假设执行配置中，线程块的笛卡尔结构为r×c。', '', '', '3');
INSERT INTO `questions` VALUES ('762', '5', '矩阵A的规模是2^m×2^n、矩阵B的规模是2^n×2^k。在一个由2^2p颗处理器构成的BSP上，采用流水并行执行A×B。假设m、n、k均大于p。\r\n\r\na)  每颗处理上消耗的存储空间规模是多少？\r\n\r\nb)  要执行多少个超级计算步？\r\n\r\nc)  在计算过程中，每颗处理器总共要发送多少个数据元素？ ', '', '', '3');
INSERT INTO `questions` VALUES ('763', '5', '一个无权图G的顶点数量为n、半径为α、直径为β。在一个APRAM-CRCW并行计算机上以最快速度执行BFS，请问并行计算效率的上限和下限分别是多少？假设在该APRAM-CRCW并行计算机上，一个操作内可以完成两项计算：某个顶点的状态更新计算；比较当前顶点被更新前后的状态值并将比较结果写入并行计算机的存储空间。', '', '', '3');
INSERT INTO `questions` VALUES ('764', '5', '在一个由p颗处理器构成的BSP上将数组A变换成数组B，A和B都有n个元素，B的每个元素 Bi 的值是![](/static/upload/md_images/20161229234518.png)。假设p远小于n，设计一个并行求解算法并给出该算法的加速比上限。', '', '', '3');
INSERT INTO `questions` VALUES ('765', '5', '在一台BSP并行计算机上，共有p颗处理器。请问：为尽可能快的完成两个长度为N的向量的点积运算，共需要执行多少个超级计算步、并简述计算超级计算步数量的依据。假设N远大于p。', '', '', '3');
INSERT INTO `questions` VALUES ('766', '5', '在p颗处理器的PRAM并行计算机上对N个元素求和。请问加速比和并行计算效率分别是多少？', '', '', '3');
INSERT INTO `questions` VALUES ('767', '5', '一个N-body问题中包括2^n个粒子。在一个由2^p颗处理器构成的BSP上采用分治并行计算粒子的受力，在一个时间步上要经过多少个超级计算步才能计算出一个粒子的受力？假设n大于p。', '', '', '3');
INSERT INTO `questions` VALUES ('768', '5', '一个N-body问题中包括2^n个粒子。在一个由2^p颗处理器构成的SMP系统上采用流水并行计算粒子的受力。假设SMP系统上每个存储单位可以存储一个粒子的全部信息；n大于p。\r\n\r\na) 使用Pthreads编程实现，应用程序的内存开销是多少？ \r\n\r\nb) 使用MPI编程实现，应用程序的内存开销是多少？\r\n', '', '', '3');
INSERT INTO `questions` VALUES ('769', '5', '假设有一个计算问题，其中串行计算量占15%。为实现并行计算，需要增加1.5%的计算量，这部分计算量是不能并行执行的，并且与所使用处理器/执行内核的数量无关。此外，每个处理器/执行内核在执行并行计算任务的过程中，还需要执行为所承担的并行任务执行一定的额外操作。这些额外操作的计算量是所承担并行任务量的0.1%。请问：\r\n\r\na) 在一个有M颗处理器/执行内核的计算平台上,并行程序可取得的最大加速比是多少？\r\n\r\nb)   为了使得并行计算效率至少为70%，M最大可为多少？\r\n', '', '', '3');
INSERT INTO `questions` VALUES ('770', '5', '假设A和B是两个向量，各存储N个复数。请问执行A和B的向量乘(A的第I个元素与B的第I个元素相乘)，至少需要多少次乘法运算?', '', '', '3');

-- ----------------------------
-- Table structure for `question_classifies`
-- ----------------------------
DROP TABLE IF EXISTS `question_classifies`;
CREATE TABLE `question_classifies` (
  `question_id` int(11) NOT NULL DEFAULT '0',
  `classify_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`question_id`,`classify_id`),
  KEY `question_id` (`question_id`),
  KEY `classify_id` (`classify_id`),
  CONSTRAINT `question_classifies_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`),
  CONSTRAINT `question_classifies_ibfk_2` FOREIGN KEY (`classify_id`) REFERENCES `classifies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of question_classifies
-- ----------------------------
INSERT INTO `question_classifies` VALUES ('8', '8');
INSERT INTO `question_classifies` VALUES ('13', '4');
INSERT INTO `question_classifies` VALUES ('14', '8');
INSERT INTO `question_classifies` VALUES ('15', '4');
INSERT INTO `question_classifies` VALUES ('16', '8');
INSERT INTO `question_classifies` VALUES ('17', '8');
INSERT INTO `question_classifies` VALUES ('18', '5');
INSERT INTO `question_classifies` VALUES ('19', '8');
INSERT INTO `question_classifies` VALUES ('20', '8');
INSERT INTO `question_classifies` VALUES ('21', '5');
INSERT INTO `question_classifies` VALUES ('22', '8');
INSERT INTO `question_classifies` VALUES ('23', '5');
INSERT INTO `question_classifies` VALUES ('24', '8');
INSERT INTO `question_classifies` VALUES ('25', '8');
INSERT INTO `question_classifies` VALUES ('26', '10');
INSERT INTO `question_classifies` VALUES ('27', '8');
INSERT INTO `question_classifies` VALUES ('28', '8');
INSERT INTO `question_classifies` VALUES ('29', '8');
INSERT INTO `question_classifies` VALUES ('30', '4');
INSERT INTO `question_classifies` VALUES ('31', '8');
INSERT INTO `question_classifies` VALUES ('32', '10');
INSERT INTO `question_classifies` VALUES ('33', '9');
INSERT INTO `question_classifies` VALUES ('34', '8');
INSERT INTO `question_classifies` VALUES ('35', '9');
INSERT INTO `question_classifies` VALUES ('36', '4');
INSERT INTO `question_classifies` VALUES ('37', '8');
INSERT INTO `question_classifies` VALUES ('38', '9');
INSERT INTO `question_classifies` VALUES ('39', '9');
INSERT INTO `question_classifies` VALUES ('40', '4');
INSERT INTO `question_classifies` VALUES ('41', '5');
INSERT INTO `question_classifies` VALUES ('42', '4');
INSERT INTO `question_classifies` VALUES ('43', '4');
INSERT INTO `question_classifies` VALUES ('44', '8');
INSERT INTO `question_classifies` VALUES ('45', '8');
INSERT INTO `question_classifies` VALUES ('46', '8');
INSERT INTO `question_classifies` VALUES ('47', '5');
INSERT INTO `question_classifies` VALUES ('48', '4');
INSERT INTO `question_classifies` VALUES ('49', '4');
INSERT INTO `question_classifies` VALUES ('50', '4');
INSERT INTO `question_classifies` VALUES ('51', '5');
INSERT INTO `question_classifies` VALUES ('53', '5');
INSERT INTO `question_classifies` VALUES ('55', '5');
INSERT INTO `question_classifies` VALUES ('56', '8');
INSERT INTO `question_classifies` VALUES ('57', '8');
INSERT INTO `question_classifies` VALUES ('58', '4');
INSERT INTO `question_classifies` VALUES ('59', '5');
INSERT INTO `question_classifies` VALUES ('60', '5');
INSERT INTO `question_classifies` VALUES ('61', '8');
INSERT INTO `question_classifies` VALUES ('62', '4');
INSERT INTO `question_classifies` VALUES ('64', '8');
INSERT INTO `question_classifies` VALUES ('65', '8');
INSERT INTO `question_classifies` VALUES ('66', '4');
INSERT INTO `question_classifies` VALUES ('67', '5');
INSERT INTO `question_classifies` VALUES ('68', '4');
INSERT INTO `question_classifies` VALUES ('69', '8');
INSERT INTO `question_classifies` VALUES ('71', '4');
INSERT INTO `question_classifies` VALUES ('72', '8');
INSERT INTO `question_classifies` VALUES ('73', '9');
INSERT INTO `question_classifies` VALUES ('75', '5');
INSERT INTO `question_classifies` VALUES ('76', '5');
INSERT INTO `question_classifies` VALUES ('77', '10');
INSERT INTO `question_classifies` VALUES ('78', '8');
INSERT INTO `question_classifies` VALUES ('81', '5');
INSERT INTO `question_classifies` VALUES ('82', '8');
INSERT INTO `question_classifies` VALUES ('83', '8');
INSERT INTO `question_classifies` VALUES ('86', '9');
INSERT INTO `question_classifies` VALUES ('87', '4');
INSERT INTO `question_classifies` VALUES ('88', '5');
INSERT INTO `question_classifies` VALUES ('89', '9');
INSERT INTO `question_classifies` VALUES ('92', '4');
INSERT INTO `question_classifies` VALUES ('94', '10');
INSERT INTO `question_classifies` VALUES ('96', '4');
INSERT INTO `question_classifies` VALUES ('97', '5');
INSERT INTO `question_classifies` VALUES ('100', '5');
INSERT INTO `question_classifies` VALUES ('103', '8');
INSERT INTO `question_classifies` VALUES ('104', '4');
INSERT INTO `question_classifies` VALUES ('106', '4');
INSERT INTO `question_classifies` VALUES ('108', '4');
INSERT INTO `question_classifies` VALUES ('109', '4');
INSERT INTO `question_classifies` VALUES ('110', '4');
INSERT INTO `question_classifies` VALUES ('111', '10');
INSERT INTO `question_classifies` VALUES ('112', '8');
INSERT INTO `question_classifies` VALUES ('113', '4');
INSERT INTO `question_classifies` VALUES ('114', '4');
INSERT INTO `question_classifies` VALUES ('115', '4');
INSERT INTO `question_classifies` VALUES ('116', '4');
INSERT INTO `question_classifies` VALUES ('117', '10');
INSERT INTO `question_classifies` VALUES ('118', '10');
INSERT INTO `question_classifies` VALUES ('119', '9');
INSERT INTO `question_classifies` VALUES ('120', '9');
INSERT INTO `question_classifies` VALUES ('121', '4');
INSERT INTO `question_classifies` VALUES ('122', '8');
INSERT INTO `question_classifies` VALUES ('123', '8');
INSERT INTO `question_classifies` VALUES ('124', '4');
INSERT INTO `question_classifies` VALUES ('125', '8');
INSERT INTO `question_classifies` VALUES ('126', '8');
INSERT INTO `question_classifies` VALUES ('127', '8');
INSERT INTO `question_classifies` VALUES ('128', '8');
INSERT INTO `question_classifies` VALUES ('129', '9');
INSERT INTO `question_classifies` VALUES ('130', '4');
INSERT INTO `question_classifies` VALUES ('131', '9');
INSERT INTO `question_classifies` VALUES ('132', '9');
INSERT INTO `question_classifies` VALUES ('133', '4');
INSERT INTO `question_classifies` VALUES ('134', '5');
INSERT INTO `question_classifies` VALUES ('135', '4');
INSERT INTO `question_classifies` VALUES ('136', '4');
INSERT INTO `question_classifies` VALUES ('138', '8');
INSERT INTO `question_classifies` VALUES ('139', '4');
INSERT INTO `question_classifies` VALUES ('140', '10');
INSERT INTO `question_classifies` VALUES ('141', '8');
INSERT INTO `question_classifies` VALUES ('143', '4');
INSERT INTO `question_classifies` VALUES ('144', '4');
INSERT INTO `question_classifies` VALUES ('145', '4');
INSERT INTO `question_classifies` VALUES ('146', '4');
INSERT INTO `question_classifies` VALUES ('147', '4');
INSERT INTO `question_classifies` VALUES ('148', '4');
INSERT INTO `question_classifies` VALUES ('149', '4');
INSERT INTO `question_classifies` VALUES ('150', '4');
INSERT INTO `question_classifies` VALUES ('151', '4');
INSERT INTO `question_classifies` VALUES ('152', '4');
INSERT INTO `question_classifies` VALUES ('153', '8');
INSERT INTO `question_classifies` VALUES ('156', '4');
INSERT INTO `question_classifies` VALUES ('157', '8');
INSERT INTO `question_classifies` VALUES ('158', '11');
INSERT INTO `question_classifies` VALUES ('159', '4');
INSERT INTO `question_classifies` VALUES ('160', '4');
INSERT INTO `question_classifies` VALUES ('161', '4');
INSERT INTO `question_classifies` VALUES ('162', '4');
INSERT INTO `question_classifies` VALUES ('163', '4');
INSERT INTO `question_classifies` VALUES ('165', '4');
INSERT INTO `question_classifies` VALUES ('166', '4');
INSERT INTO `question_classifies` VALUES ('167', '4');
INSERT INTO `question_classifies` VALUES ('169', '4');
INSERT INTO `question_classifies` VALUES ('170', '9');
INSERT INTO `question_classifies` VALUES ('171', '4');
INSERT INTO `question_classifies` VALUES ('172', '4');
INSERT INTO `question_classifies` VALUES ('173', '4');
INSERT INTO `question_classifies` VALUES ('174', '4');
INSERT INTO `question_classifies` VALUES ('175', '4');
INSERT INTO `question_classifies` VALUES ('176', '4');
INSERT INTO `question_classifies` VALUES ('178', '8');
INSERT INTO `question_classifies` VALUES ('180', '4');
INSERT INTO `question_classifies` VALUES ('181', '4');
INSERT INTO `question_classifies` VALUES ('182', '5');
INSERT INTO `question_classifies` VALUES ('183', '4');
INSERT INTO `question_classifies` VALUES ('184', '8');
INSERT INTO `question_classifies` VALUES ('185', '4');
INSERT INTO `question_classifies` VALUES ('186', '4');
INSERT INTO `question_classifies` VALUES ('191', '4');
INSERT INTO `question_classifies` VALUES ('192', '8');
INSERT INTO `question_classifies` VALUES ('195', '5');
INSERT INTO `question_classifies` VALUES ('196', '5');
INSERT INTO `question_classifies` VALUES ('197', '5');
INSERT INTO `question_classifies` VALUES ('198', '5');
INSERT INTO `question_classifies` VALUES ('200', '5');
INSERT INTO `question_classifies` VALUES ('201', '5');
INSERT INTO `question_classifies` VALUES ('202', '5');
INSERT INTO `question_classifies` VALUES ('203', '5');
INSERT INTO `question_classifies` VALUES ('204', '4');
INSERT INTO `question_classifies` VALUES ('205', '9');
INSERT INTO `question_classifies` VALUES ('206', '4');
INSERT INTO `question_classifies` VALUES ('207', '8');
INSERT INTO `question_classifies` VALUES ('208', '4');
INSERT INTO `question_classifies` VALUES ('209', '11');
INSERT INTO `question_classifies` VALUES ('210', '11');
INSERT INTO `question_classifies` VALUES ('212', '8');
INSERT INTO `question_classifies` VALUES ('213', '8');
INSERT INTO `question_classifies` VALUES ('214', '4');
INSERT INTO `question_classifies` VALUES ('216', '4');
INSERT INTO `question_classifies` VALUES ('217', '4');
INSERT INTO `question_classifies` VALUES ('218', '9');
INSERT INTO `question_classifies` VALUES ('219', '9');
INSERT INTO `question_classifies` VALUES ('220', '4');
INSERT INTO `question_classifies` VALUES ('221', '4');
INSERT INTO `question_classifies` VALUES ('222', '8');
INSERT INTO `question_classifies` VALUES ('223', '4');
INSERT INTO `question_classifies` VALUES ('224', '9');
INSERT INTO `question_classifies` VALUES ('225', '8');
INSERT INTO `question_classifies` VALUES ('227', '5');
INSERT INTO `question_classifies` VALUES ('228', '8');
INSERT INTO `question_classifies` VALUES ('229', '8');
INSERT INTO `question_classifies` VALUES ('232', '10');
INSERT INTO `question_classifies` VALUES ('233', '8');
INSERT INTO `question_classifies` VALUES ('235', '8');
INSERT INTO `question_classifies` VALUES ('236', '10');
INSERT INTO `question_classifies` VALUES ('237', '4');
INSERT INTO `question_classifies` VALUES ('238', '10');
INSERT INTO `question_classifies` VALUES ('239', '8');
INSERT INTO `question_classifies` VALUES ('241', '4');
INSERT INTO `question_classifies` VALUES ('242', '8');
INSERT INTO `question_classifies` VALUES ('243', '5');
INSERT INTO `question_classifies` VALUES ('244', '8');
INSERT INTO `question_classifies` VALUES ('245', '8');
INSERT INTO `question_classifies` VALUES ('247', '8');
INSERT INTO `question_classifies` VALUES ('248', '5');
INSERT INTO `question_classifies` VALUES ('249', '8');
INSERT INTO `question_classifies` VALUES ('250', '5');
INSERT INTO `question_classifies` VALUES ('251', '5');
INSERT INTO `question_classifies` VALUES ('259', '5');
INSERT INTO `question_classifies` VALUES ('260', '4');
INSERT INTO `question_classifies` VALUES ('261', '4');
INSERT INTO `question_classifies` VALUES ('264', '4');
INSERT INTO `question_classifies` VALUES ('265', '4');
INSERT INTO `question_classifies` VALUES ('266', '4');
INSERT INTO `question_classifies` VALUES ('268', '8');
INSERT INTO `question_classifies` VALUES ('269', '4');
INSERT INTO `question_classifies` VALUES ('272', '8');
INSERT INTO `question_classifies` VALUES ('275', '5');
INSERT INTO `question_classifies` VALUES ('277', '4');
INSERT INTO `question_classifies` VALUES ('279', '4');
INSERT INTO `question_classifies` VALUES ('281', '5');
INSERT INTO `question_classifies` VALUES ('282', '5');
INSERT INTO `question_classifies` VALUES ('283', '8');
INSERT INTO `question_classifies` VALUES ('284', '8');
INSERT INTO `question_classifies` VALUES ('294', '9');
INSERT INTO `question_classifies` VALUES ('756', '7');
INSERT INTO `question_classifies` VALUES ('757', '7');
INSERT INTO `question_classifies` VALUES ('758', '7');
INSERT INTO `question_classifies` VALUES ('759', '7');
INSERT INTO `question_classifies` VALUES ('760', '7');
INSERT INTO `question_classifies` VALUES ('761', '7');
INSERT INTO `question_classifies` VALUES ('762', '7');
INSERT INTO `question_classifies` VALUES ('763', '7');
INSERT INTO `question_classifies` VALUES ('764', '7');
INSERT INTO `question_classifies` VALUES ('765', '7');
INSERT INTO `question_classifies` VALUES ('766', '7');
INSERT INTO `question_classifies` VALUES ('767', '7');
INSERT INTO `question_classifies` VALUES ('768', '7');
INSERT INTO `question_classifies` VALUES ('769', '7');
INSERT INTO `question_classifies` VALUES ('770', '7');

-- ----------------------------
-- Table structure for `statistics`
-- ----------------------------
DROP TABLE IF EXISTS `statistics`;
CREATE TABLE `statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `action` int(11) NOT NULL,
  `data` text,
  `timestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `statistics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of statistics
-- ----------------------------
INSERT INTO `statistics` VALUES ('64', '3', '10001', null, '2017-09-10 13:19:56');
INSERT INTO `statistics` VALUES ('65', '3', '10001', null, '2017-09-10 13:19:58');
INSERT INTO `statistics` VALUES ('66', '3', '10001', null, '2017-09-13 10:14:52');

-- ----------------------------
-- Table structure for `submit_programs`
-- ----------------------------
DROP TABLE IF EXISTS `submit_programs`;
CREATE TABLE `submit_programs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(11) NOT NULL,
  `uid` int(11) NOT NULL,
  `code` text NOT NULL,
  `language` varchar(128) NOT NULL,
  `submit_time` datetime DEFAULT NULL,
  `status` varchar(128) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `pid` (`pid`),
  CONSTRAINT `submit_programs_ibfk_1` FOREIGN KEY (`pid`) REFERENCES `programs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=169 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of submit_programs
-- ----------------------------
INSERT INTO `submit_programs` VALUES ('1', '2', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"Success!\");\r\n}', 'C', '2016-11-06 20:36:14', null);
INSERT INTO `submit_programs` VALUES ('2', '2', '5', '#include <stdio.h>\r\nint main(){\r\n    printf(\"AAA\");\r\n}', 'C', '2016-12-05 11:29:36', null);
INSERT INTO `submit_programs` VALUES ('3', '2', '5', '#include <stdio.h>\r\nint main(){\r\n    printf(\"AAA\");\r\n}', 'C', '2016-12-05 11:33:42', null);
INSERT INTO `submit_programs` VALUES ('4', '2', '5', '#include <stdio.h>\r\nint main(){\r\n    printf(\"AAA\");\r\n}', 'C', '2016-12-05 11:35:07', null);
INSERT INTO `submit_programs` VALUES ('5', '2', '5', '#include <stdio.h>\r\nint main(){\r\n    printf(\"AAA\");\r\n}', 'C', '2016-12-05 11:35:50', null);
INSERT INTO `submit_programs` VALUES ('6', '2', '5', '#include <stdio.h>\r\nint main(){\r\n    printf(\"AAA\");\r\n}', 'C', '2016-12-05 11:38:42', null);
INSERT INTO `submit_programs` VALUES ('7', '2', '5', '#include <stdio.h>\r\nint main(){\r\n    printf(\"AAA\");\r\n}', 'C', '2016-12-05 11:45:08', null);
INSERT INTO `submit_programs` VALUES ('8', '2', '5', '#include <stdio.h>\r\nint main(){\r\n    printf(\"AAA\");\r\n}', 'C', '2016-12-05 11:46:57', null);
INSERT INTO `submit_programs` VALUES ('9', '2', '9', '#include \"stdio.h\"\r\n\r\nint main()\r\n{\r\n    printf(\"hello world!\\n\");\r\n}', 'C', '2016-12-05 14:05:39', null);
INSERT INTO `submit_programs` VALUES ('10', '2', '5', '#include <>', 'C', '2016-12-06 16:01:43', null);
INSERT INTO `submit_programs` VALUES ('11', '2', '5', '#include <stdio.h>\r\nint main(){\r\n    printf(\"%d\", 1+2);\r\n    return 0;\r\n}', 'C', '2016-12-06 16:02:35', null);
INSERT INTO `submit_programs` VALUES ('12', '2', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"AAA\");\r\n}', 'C', '2016-12-15 19:04:58', null);
INSERT INTO `submit_programs` VALUES ('13', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 10:12:37', null);
INSERT INTO `submit_programs` VALUES ('14', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 10:13:10', null);
INSERT INTO `submit_programs` VALUES ('15', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 10:13:25', null);
INSERT INTO `submit_programs` VALUES ('16', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 13:50:47', null);
INSERT INTO `submit_programs` VALUES ('18', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 14:05:56', null);
INSERT INTO `submit_programs` VALUES ('19', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 14:06:30', null);
INSERT INTO `submit_programs` VALUES ('20', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 14:10:58', null);
INSERT INTO `submit_programs` VALUES ('21', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:02:09', null);
INSERT INTO `submit_programs` VALUES ('22', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:02:22', null);
INSERT INTO `submit_programs` VALUES ('23', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:06:44', null);
INSERT INTO `submit_programs` VALUES ('24', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:07:09', null);
INSERT INTO `submit_programs` VALUES ('25', '4', '1', 'data[status]==\'success', 'C', '2016-12-24 15:10:59', null);
INSERT INTO `submit_programs` VALUES ('26', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:11:21', null);
INSERT INTO `submit_programs` VALUES ('27', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:11:41', null);
INSERT INTO `submit_programs` VALUES ('28', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:11:51', null);
INSERT INTO `submit_programs` VALUES ('29', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!   I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:12:57', null);
INSERT INTO `submit_programs` VALUES ('30', '4', '1', '', 'C', '2016-12-24 15:13:10', null);
INSERT INTO `submit_programs` VALUES ('31', '4', '1', 'eHPC/templates/problem/program_detail.html', 'C', '2016-12-24 15:15:15', null);
INSERT INTO `submit_programs` VALUES ('32', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-24 15:16:07', null);
INSERT INTO `submit_programs` VALUES ('33', '4', '1', '#include <>', 'C', '2016-12-25 13:49:29', null);
INSERT INTO `submit_programs` VALUES ('34', '4', '1', '@@@', 'C', '2016-12-26 21:47:03', null);
INSERT INTO `submit_programs` VALUES ('35', '4', '1', '', 'C', '2016-12-26 21:50:37', null);
INSERT INTO `submit_programs` VALUES ('36', '4', '1', '', 'C', '2016-12-26 21:57:30', null);
INSERT INTO `submit_programs` VALUES ('37', '4', '1', '', 'C', '2016-12-26 21:57:36', null);
INSERT INTO `submit_programs` VALUES ('38', '4', '1', '', 'C', '2016-12-26 21:57:45', null);
INSERT INTO `submit_programs` VALUES ('39', '4', '1', '', 'C', '2016-12-26 21:58:26', null);
INSERT INTO `submit_programs` VALUES ('40', '4', '1', '', 'C', '2016-12-26 21:58:50', null);
INSERT INTO `submit_programs` VALUES ('41', '4', '1', '', 'C', '2016-12-26 21:59:49', null);
INSERT INTO `submit_programs` VALUES ('42', '4', '1', '', 'C', '2016-12-26 22:00:02', null);
INSERT INTO `submit_programs` VALUES ('43', '4', '1', '', 'C', '2016-12-26 22:01:04', null);
INSERT INTO `submit_programs` VALUES ('44', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-26 22:01:34', null);
INSERT INTO `submit_programs` VALUES ('45', '4', '1', '', 'C', '2016-12-26 22:07:54', null);
INSERT INTO `submit_programs` VALUES ('46', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-26 22:08:22', null);
INSERT INTO `submit_programs` VALUES ('47', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-26 22:08:34', null);
INSERT INTO `submit_programs` VALUES ('48', '4', '1', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2016-12-30 13:48:54', null);
INSERT INTO `submit_programs` VALUES ('49', '2', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"Success!\");\r\n}\r\n', 'C', '2017-01-03 13:12:14', null);
INSERT INTO `submit_programs` VALUES ('50', '2', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"Success!\");\r\n}\r\n', 'C', '2017-01-03 13:12:20', null);
INSERT INTO `submit_programs` VALUES ('51', '2', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"Success!\");\r\n}', 'C', '2017-01-03 13:13:08', null);
INSERT INTO `submit_programs` VALUES ('52', '4', '3', '#3', 'C', '2017-01-03 13:14:57', null);
INSERT INTO `submit_programs` VALUES ('53', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:24:15', null);
INSERT INTO `submit_programs` VALUES ('54', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:24:42', null);
INSERT INTO `submit_programs` VALUES ('55', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:29:37', null);
INSERT INTO `submit_programs` VALUES ('56', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:30:32', null);
INSERT INTO `submit_programs` VALUES ('57', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:32:45', null);
INSERT INTO `submit_programs` VALUES ('58', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:33:26', null);
INSERT INTO `submit_programs` VALUES ('59', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:34:12', null);
INSERT INTO `submit_programs` VALUES ('60', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:37:45', null);
INSERT INTO `submit_programs` VALUES ('61', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:41:40', null);
INSERT INTO `submit_programs` VALUES ('62', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 15:41:56', null);
INSERT INTO `submit_programs` VALUES ('63', '6', '12', '#include<stdio.h>\r\nint main(){\r\n    printf(\"hello!\\n\");\r\n}', 'C', '2017-01-03 16:06:12', null);
INSERT INTO `submit_programs` VALUES ('64', '2', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"Success!\");\r\n}', 'C', '2017-01-06 10:05:02', null);
INSERT INTO `submit_programs` VALUES ('65', '2', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"Success!\");\r\n}', 'C', '2017-01-06 10:05:10', null);
INSERT INTO `submit_programs` VALUES ('66', '5', '3', 'teasta', 'C', '2017-01-09 15:12:23', null);
INSERT INTO `submit_programs` VALUES ('67', '6', '12', 'print (\"Hello\")', 'Python', '2017-01-09 15:37:01', null);
INSERT INTO `submit_programs` VALUES ('68', '6', '12', '#include <stdio.h>\r\nint main(){\r\n    printf(\"Hello!\\n\");\r\n}', 'C', '2017-01-09 15:37:49', null);
INSERT INTO `submit_programs` VALUES ('69', '6', '12', '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc , char *argv[]){\r\n    int myid , numprocs , namelen ;\r\n    char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n    MPI_Init(&argc , &argv);\r\n    MPI_Comm_rank(MPI_COMM_WORLD,&myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);\r\n    MPI_Get_processor_name(processor_name , &namelen);\r\n    if(myid ==0) \r\n        printf(\"number of processes: %d\\n\" , numprocs);\r\n    printf(\"%s: Hello world from process %d \\n\" ,processor_name ,myid );\r\n    printf(\"Hello!\\n\");\r\n    \r\n}', 'C', '2017-01-09 15:52:54', null);
INSERT INTO `submit_programs` VALUES ('70', '6', '12', '#include <stdio.h>\r\n#include <mpi.h>\r\n\r\nint main(int argc , char *argv[]){\r\n    int myid , numprocs , namelen ;\r\n    char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n    MPI_Init(&argc , &argv);\r\n    MPI_Comm_rank(MPI_COMM_WORLD,&myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);\r\n    MPI_Get_processor_name(processor_name , &namelen);\r\n    if(myid ==0) \r\n        printf(\"number of processes: %d\\n\" , numprocs);\r\n    printf(\"%s: Hello world from process %d \\n\" ,processor_name ,myid );\r\n    printf(\"Hello!\\n\");\r\n    \r\n}', 'C', '2017-01-09 15:58:17', null);
INSERT INTO `submit_programs` VALUES ('71', '5', '3', 'testa', 'C', '2017-01-09 16:03:01', null);
INSERT INTO `submit_programs` VALUES ('72', '5', '13', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'C', '2017-01-09 18:52:33', null);
INSERT INTO `submit_programs` VALUES ('73', '5', '3', '#include <stdio.h>\r\n\r\nmain()\r\n{\r\n    \r\n    \r\n}\r\n\r\n', 'C', '2017-01-12 15:58:00', null);
INSERT INTO `submit_programs` VALUES ('74', '5', '3', '', 'ace/mode/c_cpp', '2017-02-22 20:49:03', null);
INSERT INTO `submit_programs` VALUES ('75', '1', '3', '', 'ace/mode/c_cpp', '2017-02-23 15:55:42', null);
INSERT INTO `submit_programs` VALUES ('76', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 11:20:46', null);
INSERT INTO `submit_programs` VALUES ('77', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 11:20:48', null);
INSERT INTO `submit_programs` VALUES ('78', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 11:20:51', null);
INSERT INTO `submit_programs` VALUES ('79', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 11:25:33', null);
INSERT INTO `submit_programs` VALUES ('80', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 14:53:14', null);
INSERT INTO `submit_programs` VALUES ('81', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 14:58:13', null);
INSERT INTO `submit_programs` VALUES ('82', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', 'ace/mode/c_cpp', '2017-02-25 18:09:57', null);
INSERT INTO `submit_programs` VALUES ('83', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', 'ace/mode/c_cpp', '2017-02-25 18:10:51', null);
INSERT INTO `submit_programs` VALUES ('84', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 21:02:26', null);
INSERT INTO `submit_programs` VALUES ('85', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 21:05:27', null);
INSERT INTO `submit_programs` VALUES ('86', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 21:05:34', null);
INSERT INTO `submit_programs` VALUES ('87', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 21:05:49', null);
INSERT INTO `submit_programs` VALUES ('88', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 21:06:01', null);
INSERT INTO `submit_programs` VALUES ('89', '1', '1', '###3', 'ace/mode/c_cpp', '2017-02-25 21:06:20', null);
INSERT INTO `submit_programs` VALUES ('90', '1', '1', '#include <stdio.h>\r\n\r\nint main(){\r\n    printf(\"AAAA\");\r\n}', 'ace/mode/c_cpp', '2017-02-25 21:06:49', null);
INSERT INTO `submit_programs` VALUES ('91', '1', '1', '#include <stdio.h>\r\n\r\nint main(){\r\n    for(int i=0; i<10; i++){\r\n        printf(\"AAAA\");\r\n    }\r\n\r\n}', 'ace/mode/c_cpp', '2017-02-25 21:08:54', null);
INSERT INTO `submit_programs` VALUES ('92', '1', '1', '#include <stdio.h>\r\n\r\nint main(){\r\n    \r\n    for(int i=0; i<10; i++){\r\n        printf(\"AAAA\");\r\n    }\r\n    return 0;\r\n}', 'ace/mode/c_cpp', '2017-02-25 21:09:39', null);
INSERT INTO `submit_programs` VALUES ('93', '1', '1', '#include <stdio.h>\r\n\r\nint main(){\r\n    \r\n    for(std::int i=0; i<10; i++){\r\n        printf(\"AAAA\");\r\n    }\r\n    return 0;\r\n}', 'ace/mode/c_cpp', '2017-02-25 21:09:49', null);
INSERT INTO `submit_programs` VALUES ('94', '1', '1', '#include <stdio.h>\r\n\r\nint main(){\r\n    \r\n    for(std::int i=0; i<10; i++){\r\n        printf(\"AAAA\");\r\n    }\r\n    return 0;\r\n}', 'ace/mode/c_cpp', '2017-02-25 21:12:43', null);
INSERT INTO `submit_programs` VALUES ('95', '1', '1', '', 'ace/mode/c_cpp', '2017-02-25 21:29:49', null);
INSERT INTO `submit_programs` VALUES ('96', '2', '10', '', 'ace/mode/c_cpp', '2017-02-26 20:09:14', null);
INSERT INTO `submit_programs` VALUES ('97', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', 'ace/mode/c_cpp', '2017-02-26 20:34:57', null);
INSERT INTO `submit_programs` VALUES ('98', '1', '3', '#include <stdio.h>\r\n\r\nmain()\r\n{\r\n    printf(\"hello.h\")\r\n    \r\n}', 'ace/mode/c_cpp', '2017-02-27 10:24:54', null);
INSERT INTO `submit_programs` VALUES ('99', '1', '3', '#include stdio.h\r\n\r\nmain()\r\n{\r\n    printf(\"hello.h\");\r\n    \r\n}', 'ace/mode/c_cpp', '2017-02-27 10:25:13', null);
INSERT INTO `submit_programs` VALUES ('100', '1', '3', '#include stdio.h\r\n\r\nmain(void){\r\n    \r\n    printf(\"hello.h\");\r\n    \r\n}', 'ace/mode/c_cpp', '2017-02-27 10:25:28', null);
INSERT INTO `submit_programs` VALUES ('101', '1', '3', '#include \"stdio.h\"\r\n\r\nmain(void){\r\n    \r\n    printf(\"hello.h\");\r\n    \r\n}', 'ace/mode/c_cpp', '2017-02-27 10:25:48', null);
INSERT INTO `submit_programs` VALUES ('102', '1', '3', '#include \"stdio.h\"\r\n\r\nmain(void){\r\n    \r\n    printf(\"hello.h\");\r\n    \r\n}', 'ace/mode/c_cpp', '2017-02-27 10:26:55', null);
INSERT INTO `submit_programs` VALUES ('103', '1', '13', '#include <mpi.h>\r\n#include <stdio.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	printf(\"Hello World!\");\r\n	\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'ace/mode/c_cpp', '2017-03-02 21:22:16', null);
INSERT INTO `submit_programs` VALUES ('104', '1', '13', '#include <mpi.h>\r\n#include <stdio.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	printf(\"Hello World!\");\r\n	\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'ace/mode/c_cpp', '2017-03-02 21:28:14', null);
INSERT INTO `submit_programs` VALUES ('105', '1', '1', '', 'ace/mode/c_cpp', '2017-03-02 21:31:47', null);
INSERT INTO `submit_programs` VALUES ('106', '1', '1', '#include <mpi.h>\r\n#include <stdio.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n MPI_Init(&argc, &argv);\r\n \r\n printf(\"Hello World!\");\r\n \r\n MPI_Finalize();\r\n return 0;\r\n}', 'ace/mode/c_cpp', '2017-03-02 21:38:02', null);
INSERT INTO `submit_programs` VALUES ('107', '1', '1', '#include <mpi.h>\r\n#include <stdio.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n MPI_Init(&argc, &argv);\r\n \r\n printf(\"Hello World!\");\r\n \r\n MPI_Finalize();\r\n return 0;\r\n}', 'ace/mode/c_cpp', '2017-03-02 21:39:09', null);
INSERT INTO `submit_programs` VALUES ('108', '1', '13', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Init(&argc, &argv);\r\n\r\n	//your code here\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	//your code here\r\n	printf(\"Hello World!I\'m rank %d of %d\\n\", myid, numprocs);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'ace/mode/c_cpp', '2017-03-06 16:27:46', null);
INSERT INTO `submit_programs` VALUES ('109', '1', '13', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Init(&argc, &argv);\r\n\r\n	//your code here\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	//your code here\r\n	printf(\"Hello World!I\'m rank %d of %d\\n\", myid, numprocs);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'ace/mode/c_cpp', '2017-03-06 16:27:53', null);
INSERT INTO `submit_programs` VALUES ('110', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', 'mpi', '2017-03-09 09:37:04', null);
INSERT INTO `submit_programs` VALUES ('111', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myrank, nproc, namelen;\r\n	char processor_name[MPI_MAX_PROCESSOR_NAME];\r\n	MPI_Init(&argc, &argv);\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);\r\n	MPI_Get_processor_name(processor_name, &namelen);\r\n\r\n	printf(\"Hello World!I\'m rank %d of %d on %s\\n\", myrank, nproc, processor_name);\r\n	MPI_Finalize();\r\n	return 0;\r\n}\r\n', 'mpi', '2017-03-09 09:37:05', null);
INSERT INTO `submit_programs` VALUES ('112', '1', '3', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	double start, finish;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n\r\n    MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n\r\n	//your code here\r\n	start = MPI_Wtime();\r\n	\r\n	printf(\"The precision is: %f\\n\", MPI_Wtick());\r\n	\r\n	finish = MPI_Wtime();\r\n	//your code here\r\n	\r\n	printf(\"Hello World!I\'m rank %d of %d, running %f seconds.\\n\", myid, numprocs, finish-start);\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'mpi', '2017-03-09 21:37:08', null);
INSERT INTO `submit_programs` VALUES ('113', '1', '3', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    //your code here\r\n    MPI_Init(&argc, &argv); \r\n    //end of your code \r\n    \r\n    printf(\"Hello World!\"); \r\n    \r\n    //your code here \r\n    MPI_Finalize();\r\n    //end of your code \r\n    return 0;\r\n} ', 'mpi', '2017-03-10 19:18:36', null);
INSERT INTO `submit_programs` VALUES ('114', '2', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"Success!\");\r\n}', 'mpi', '2017-03-13 15:59:59', null);
INSERT INTO `submit_programs` VALUES ('115', '1', '3', '#', 'mpi', '2017-03-15 23:40:29', null);
INSERT INTO `submit_programs` VALUES ('116', '1', '3', '#', 'mpi', '2017-03-15 23:40:31', null);
INSERT INTO `submit_programs` VALUES ('117', '1', '3', '', 'mpi', '2017-03-15 23:44:03', null);
INSERT INTO `submit_programs` VALUES ('118', '1', '3', '#include <stdio.h>\r\n\r\nmain()\r\n{\r\n    printf(\"hello\");\r\n}', 'mpi', '2017-03-19 19:47:12', null);
INSERT INTO `submit_programs` VALUES ('119', '1', '13', '', 'mpi', '2017-03-19 22:41:28', null);
INSERT INTO `submit_programs` VALUES ('120', '1', '3', '#include <stdio.h>\r\n\r\nmain()\r\n{\r\n   \r\n}', 'mpi', '2017-03-20 15:40:46', null);
INSERT INTO `submit_programs` VALUES ('121', '1', '3', '#include <stdio.h>\r\n\r\nmain()\r\n{\r\n   \r\n}', 'mpi', '2017-03-20 15:40:49', null);
INSERT INTO `submit_programs` VALUES ('122', '1', '1', 'include <stdio.h>\r\n\r\nint main(){\r\n    printf(\"AAAA\");\r\n}', 'mpi', '2017-03-21 15:41:20', null);
INSERT INTO `submit_programs` VALUES ('123', '1', '1', 'include <stdio.h>\r\n\r\nint main(){\r\n    printf(\"AAAA\");\r\n}', 'mpi', '2017-03-21 15:41:21', null);
INSERT INTO `submit_programs` VALUES ('124', '1', '1', 'include <stdio.h>\r\n\r\nint main(){\r\n    printf(\"AAAA\");\r\n}', 'mpi', '2017-03-21 15:41:23', null);
INSERT INTO `submit_programs` VALUES ('125', '1', '1', 'include <stdio.h>\r\n\r\nint main(){\r\n    printf(\"AAAA\");\r\n}', 'mpi', '2017-03-21 15:41:25', null);
INSERT INTO `submit_programs` VALUES ('126', '1', '1', 'include <stdio.h>\r\n\r\nint main(){\r\n    printf(\"AAAA\");\r\n}', 'mpi', '2017-03-21 15:41:36', null);
INSERT INTO `submit_programs` VALUES ('127', '1', '1', 'include <stdio.h>\r\n\r\nint main(){\r\n    printf(\"AAAA\");\r\n}', 'mpi', '2017-03-21 15:41:38', null);
INSERT INTO `submit_programs` VALUES ('128', '1', '13', '1', 'mpi', '2017-03-21 16:43:45', null);
INSERT INTO `submit_programs` VALUES ('129', '1', '13', '1', 'openmp', '2017-03-21 16:47:37', null);
INSERT INTO `submit_programs` VALUES ('130', '1', '13', '1', 'openmp', '2017-03-21 16:47:38', null);
INSERT INTO `submit_programs` VALUES ('131', '1', '13', '1', 'openmp', '2017-03-21 16:47:39', null);
INSERT INTO `submit_programs` VALUES ('132', '1', '13', '1', 'openmp', '2017-03-21 16:47:40', null);
INSERT INTO `submit_programs` VALUES ('133', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm; \r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	if(myid == 0) {\r\n		// your code here\r\n		MPI_Comm_dup(MPI_COMM_WORLD, &new_comm);\r\n		// end of your code\r\n		\r\n		MPI_Comm_compare(MPI_COMM_WORLD, new_comm, &result);\r\n		\r\n		if ( result == MPI_IDENT) {\r\n			printf(\"Now the comm is copied.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Error.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'mpi', '2017-03-21 17:02:27', null);
INSERT INTO `submit_programs` VALUES ('134', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm; \r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	if(myid == 0) {\r\n		// your code here\r\n		MPI_Comm_dup(MPI_COMM_WORLD, &new_comm);\r\n		// end of your code\r\n		\r\n		MPI_Comm_compare(MPI_COMM_WORLD, new_comm, &result);\r\n		\r\n		if ( result == MPI_IDENT) {\r\n			printf(\"Now the comm is copied.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Error.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'mpi', '2017-03-21 17:02:28', null);
INSERT INTO `submit_programs` VALUES ('135', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm; \r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	if(myid == 0) {\r\n		// your code here\r\n		MPI_Comm_dup(MPI_COMM_WORLD, &new_comm);\r\n		// end of your code\r\n		\r\n		MPI_Comm_compare(MPI_COMM_WORLD, new_comm, &result);\r\n		\r\n		if ( result == MPI_IDENT) {\r\n			printf(\"Now the comm is copied.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Error.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'mpi', '2017-03-21 17:02:32', null);
INSERT INTO `submit_programs` VALUES ('136', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm; \r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	if(myid == 0) {\r\n		// your code here\r\n		MPI_Comm_dup(MPI_COMM_WORLD, &new_comm);\r\n		// end of your code\r\n		\r\n		MPI_Comm_compare(MPI_COMM_WORLD, new_comm, &result);\r\n		\r\n		if ( result == MPI_IDENT) {\r\n			printf(\"Now the comm is copied.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Error.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'mpi', '2017-03-21 17:02:42', null);
INSERT INTO `submit_programs` VALUES ('137', '1', '10', '#include<stdio.h>\r\n#include<mpi.h>\r\n\r\nint main(int argc, char **argv)\r\n{\r\n	int myid, numprocs;\r\n	MPI_Comm new_comm; \r\n	int result;\r\n	\r\n	MPI_Init(&argc, &argv);\r\n	\r\n	MPI_Comm_rank(MPI_COMM_WORLD, &myid);\r\n    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);\r\n	\r\n	if(myid == 0) {\r\n		// your code here\r\n		MPI_Comm_dup(MPI_COMM_WORLD, &new_comm);\r\n		// end of your code\r\n		\r\n		MPI_Comm_compare(MPI_COMM_WORLD, new_comm, &result);\r\n		\r\n		if ( result == MPI_IDENT) {\r\n			printf(\"Now the comm is copied.\\n\");\r\n		}\r\n		else {\r\n			printf(\"Error.\\n\");\r\n		}\r\n	}\r\n\r\n	MPI_Finalize();\r\n	return 0;\r\n}', 'mpi', '2017-03-21 17:02:46', null);
INSERT INTO `submit_programs` VALUES ('138', '1', '1', '', 'mpi', '2017-03-22 09:23:32', null);
INSERT INTO `submit_programs` VALUES ('139', '1', '1', '', 'mpi', '2017-03-22 09:25:57', null);
INSERT INTO `submit_programs` VALUES ('140', '1', '1', '', 'mpi', '2017-03-22 09:26:15', null);
INSERT INTO `submit_programs` VALUES ('141', '1', '1', '', 'mpi', '2017-03-22 09:45:35', null);
INSERT INTO `submit_programs` VALUES ('142', '1', '1', '', 'mpi', '2017-03-22 09:50:00', null);
INSERT INTO `submit_programs` VALUES ('143', '1', '1', '', 'mpi', '2017-03-22 09:50:01', null);
INSERT INTO `submit_programs` VALUES ('144', '1', '1', '', 'mpi', '2017-03-22 09:50:07', null);
INSERT INTO `submit_programs` VALUES ('145', '1', '1', '', 'mpi', '2017-03-22 09:50:29', null);
INSERT INTO `submit_programs` VALUES ('146', '1', '1', '', 'mpi', '2017-03-22 09:50:41', null);
INSERT INTO `submit_programs` VALUES ('147', '1', '1', '', 'mpi', '2017-03-22 16:01:43', null);
INSERT INTO `submit_programs` VALUES ('148', '1', '1', '', 'mpi', '2017-03-22 16:04:36', null);
INSERT INTO `submit_programs` VALUES ('149', '4', '1', '', 'mpi', '2017-03-22 17:46:44', null);
INSERT INTO `submit_programs` VALUES ('150', '4', '1', '', 'mpi', '2017-03-22 17:48:59', null);
INSERT INTO `submit_programs` VALUES ('151', '2', '10', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    //your code here\r\n    MPI_Init(&argc, &argv); \r\n    //end of your code \r\n    \r\n    printf(\"Hello World!\"); \r\n    \r\n    //your code here \r\n    MPI_Finalize();\r\n    //end of your code \r\n    return 0;\r\n} ', 'mpi', '2017-03-22 21:06:17', null);
INSERT INTO `submit_programs` VALUES ('152', '2', '10', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    //your code here\r\n    MPI_Init(&argc, &argv); \r\n    //end of your code \r\n    \r\n    printf(\"Hello World!\"); \r\n    \r\n    //your code here \r\n    MPI_Finalize();\r\n    //end of your code \r\n    return 0;\r\n} ', 'mpi', '2017-03-22 21:06:41', null);
INSERT INTO `submit_programs` VALUES ('153', '2', '10', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    //your code here\r\n    MPI_Init(&argc, &argv); \r\n    //end of your code \r\n    \r\n    printf(\"Hello World!\"); \r\n    \r\n    //your code here \r\n    MPI_Finalize();\r\n    //end of your code \r\n    return 0;\r\n} ', 'mpi', '2017-03-22 21:06:49', null);
INSERT INTO `submit_programs` VALUES ('154', '2', '10', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    //your code here\r\n    MPI_Init(&argc, &argv); \r\n    //end of your code \r\n    \r\n    printf(\"Hello World!\"); \r\n    \r\n    //your code here \r\n    MPI_Finalize();\r\n    //end of your code \r\n    return 0;\r\n} ', 'mpi', '2017-03-22 21:09:18', null);
INSERT INTO `submit_programs` VALUES ('155', '2', '3', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for \r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 10; i++) {\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	return 0;\r\n}\r\n', 'mpi', '2017-03-23 16:52:04', null);
INSERT INTO `submit_programs` VALUES ('156', '2', '3', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for \r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 10; i++) {\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	return 0;\r\n}\r\n', 'mpi', '2017-03-23 16:52:50', null);
INSERT INTO `submit_programs` VALUES ('157', '2', '3', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for \r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 10; i++) {\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	return 0;\r\n}\r\n', 'mpi', '2017-03-23 16:52:57', null);
INSERT INTO `submit_programs` VALUES ('158', '2', '3', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for \r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 10; i++) {\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	return 0;\r\n}\r\n', 'mpi', '2017-03-23 16:53:16', null);
INSERT INTO `submit_programs` VALUES ('159', '2', '3', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for \r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 10; i++) {\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	return 0;\r\n}\r\n', 'mpi', '2017-03-23 16:54:58', null);
INSERT INTO `submit_programs` VALUES ('160', '2', '3', '#include <stdio.h>\r\n#include <omp.h>\r\n\r\nint main(int argc, char* argv[])\r\n{\r\n	// YOUR CODE HERE\r\n	#pragma omp parallel for \r\n	// END OF YOUR CODE\r\n	int i;\r\n	for (i = 0; i < 10; i++) {\r\n		printf(\"i = %d\\n\", i);\r\n	}\r\n	return 0;\r\n}\r\n', 'mpi', '2017-03-23 16:56:08', null);
INSERT INTO `submit_programs` VALUES ('161', '1', '3', '#include <stdio.h>\r\nint main(){\r\n    printf(\"\\n\");\r\n}', 'mpi', '2017-04-14 16:32:07', null);
INSERT INTO `submit_programs` VALUES ('162', '1', '3', '#include <stdio.h>\r\n\r\nmain()\r\n{\r\n   \r\n}', 'mpi', '2017-07-04 21:44:57', null);
INSERT INTO `submit_programs` VALUES ('163', '2', '3', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    MPI_Init(&argc, &argv); \r\n    \r\n    int n = 100;\r\n    int m = 200;\r\n    printf(\"the min value is %d\",min(m,n));\r\n    \r\n    MPI_Finalize();\r\n    return 0;\r\n} \r\n\r\nint min(int m, int n){\r\n    if(m>n)return n;\r\n    else return m;\r\n}', 'mpi', '2017-07-20 15:05:20', null);
INSERT INTO `submit_programs` VALUES ('164', '2', '3', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    MPI_Init(&argc, &argv); \r\n    \r\n    int n = 100;\r\n    int m = 200;\r\n    printf(\"the min value is %d\",min(m,n));\r\n    \r\n    MPI_Finalize();\r\n    return 0;\r\n} \r\n\r\nint min(int m, int n){\r\n    if(m>n)return n;\r\n    else return m;\r\n}', 'mpi', '2017-07-20 15:05:44', null);
INSERT INTO `submit_programs` VALUES ('165', '2', '3', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    MPI_Init(&argc, &argv); \r\n    \r\n    int n = 100;\r\n    int m = 200;\r\n    printf(\"the min value is %d\",min(m,n));\r\n    \r\n    MPI_Finalize();\r\n    return 0;\r\n} \r\n\r\nint min(int m, int n){\r\n    if(m>n)return n;\r\n    else return m;\r\n}', 'mpi', '2017-07-20 15:06:05', null);
INSERT INTO `submit_programs` VALUES ('166', '2', '3', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    MPI_Init(&argc, &argv); \r\n    \r\n    int n = 100;\r\n    int m = 200;\r\n    printf(\"the min value is %d\",min(m,n));\r\n    \r\n    MPI_Finalize();\r\n    return 0;\r\n} \r\n\r\nint min(int m, int n){\r\n    if(m>n)return n;\r\n    else return m;\r\n}', 'mpi', '2017-07-20 15:35:16', null);
INSERT INTO `submit_programs` VALUES ('167', '2', '3', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    MPI_Init(&argc, &argv); \r\n    \r\n    int n = 100;\r\n    int m = 200;\r\n    printf(\"the min value is %d\",min(m,n));\r\n    \r\n    MPI_Finalize();\r\n    return 0;\r\n} \r\n\r\nint min(int m, int n){\r\n    if(m>n)return n;\r\n    else return m;\r\n}', 'mpi', '2017-07-20 16:36:00', null);
INSERT INTO `submit_programs` VALUES ('168', '2', '3', '#include <mpi.h>\r\n#include <stdio.h>\r\nint main(int argc, char **argv)\r\n{ \r\n    MPI_Init(&argc, &argv); \r\n    \r\n    int n = 100;\r\n    int m = 200;\r\n    printf(\"the min value is %d\",min(m,n));\r\n    \r\n    MPI_Finalize();\r\n    return 0;\r\n} \r\n\r\nint min(int m, int n){\r\n    if(m>n)return n;\r\n    else return m;\r\n}', 'mpi', '2017-07-20 16:36:51', null);

-- ----------------------------
-- Table structure for `topics`
-- ----------------------------
DROP TABLE IF EXISTS `topics`;
CREATE TABLE `topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `content` text NOT NULL,
  `visitNum` int(11) DEFAULT NULL,
  `postNum` int(11) DEFAULT NULL,
  `groupID` int(11) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  `updatedTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `groupID` (`groupID`),
  KEY `userID` (`userID`),
  CONSTRAINT `topics_ibfk_1` FOREIGN KEY (`groupID`) REFERENCES `groups` (`id`),
  CONSTRAINT `topics_ibfk_2` FOREIGN KEY (`userID`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of topics
-- ----------------------------
INSERT INTO `topics` VALUES ('1', 'C++ 编译流程', '简单地说，一个编译器就是一个程序，它可以阅读以某一种语言（源语言）编写的程序，并把该程序翻译成一个等价的、用另一种语言（目标语言）编写的程序。\r\n\r\nC/C++编译系统将一个程序转化为可执行程序的过程包含：\r\n\r\n* 预处理(preprocessing)：根据已放置的文件中的预处理指令来修改源文件的内容。\r\n* 编译(compilation)：通过词法分析和语法分析，在确认所有指令都是符合语法规则之后，将其翻译成等价的中间代码表示或汇编代码。\r\n* 汇编(assembly)：把汇编语言代码翻译成目标机器指令的过程。\r\n* 链接(linking)：找到所有用到的函数所在的目标文件，并把它们链接在一起合成为可执行文件(executable file)。\r\n\r\n# 预处理\r\n\r\n预处理器是在程序源文件被编译之前根据预处理指令对程序源文件进行处理的程序。**预处理器指令以#号开头标识，末尾不包含分号**。预处理命令不是C/C++语言本身的组成部分，不能直接对它们进行编译和链接。C/C++语言的一个重要功能是可以使用预处理指令和具有预处理的功能。C/C++提供的预处理功能主要有文件包含、宏替换、条件编译等。\r\n\r\n## 文件包含\r\n\r\n预处理指令 #include 用于包含头文件，有两种形式：#include <xxx.h>，#include \"xxx.h\"。\r\n\r\n尖括号形式表示被包含的文件在系统目录中。如果被包含的文件不一定在系统目录中，应该用双引号形式。在双引号形式中可以指出文件路径和文件名。如果在双引号中没有给出绝对路径，则默认为用户当前目录中的文件，此时系统首先在用户当前目录中寻找要包含的文件，若找不到再在系统目录中查找。\r\n\r\n对于用户自己编写的头文件，宜用双引号形式。对于系统提供的头文件，既可以用尖括号形式，也可以用双引号形式，都能找到被包含的文件，但显然用尖括号形式更直截了当，效率更高。\r\n\r\n## 宏替换\r\n\r\n`宏定义`：一般用一个短的名字代表一个长的代码序列。宏定义包括无参数宏定义和带参数宏定义两类。宏名和宏参数所代表的代码序列可以是任何意义的内容，如类型、常量、变量、操作符、表达式、语句、函数、代码块等。\r\n\r\n宏定义在源文件中必须单独另起一行，换行符是宏定义的结束标志，因此宏定义以换行结束，不需要分号等符号作分隔符。如果一个宏定义中代码序列太长，一行不够时，可采用续行的方法。续行是在键入回车符之前先键入符号\\，注意回车要紧接在符号\\之后，中间不能插入其它符号，当然代码序列最后一行结束时不能有\\。\r\n\r\n预处理器在处理宏定义时，会对宏进行展开（即`宏替换`）。宏替换首先将源文件中在宏定义随后所有出现的宏名均用其所代表的代码序列替换之，如果是带参数宏则接着将代码序列中的宏形参名替换为宏实参名。宏替换只作代码字符序列的替换工作，不作任何语法的检查，也不作任何的中间计算，一切其它操作都要在替换完后才能进行。如果宏定义不当，错误要到预处理之后的编译阶段才能发现。\r\n\r\n## 条件编译\r\n\r\n一般情况下，在进行编译时对源程序中的每一行都要编译，但是有时希望程序中某一部分内容只在满足一定条件时才进行编译，如果不满足这个条件，就不编译这部分内容，这就是`条件编译`。\r\n\r\n条件编译主要是进行编译时进行有选择的挑选，注释掉一些指定的代码，以达到多个版本控制、防止对文件重复包含的功能。if, #ifndef, #ifdef, #else, #elif, #endif是比较常见条件编译预处理指令，可根据表达式的值或某个特定宏是否被定义来确定编译条件。\r\n\r\n此外，还有 #pragma 指令，它的作用是设定编译器的状态或指示编译器完成一些特定的动作。\r\n\r\n# 编译\r\n\r\n编译过程的第一个步骤称为词法分析（lexical analysis）或扫描（scanning），词法分析器读入组成源程序的字符流，并且将它们组织成有意义的词素的序列，对于每个词素，词法分析器产生一个词法单元（token），传给下一个步骤：语法分析。\r\n\r\n语法分析（syntax analysis）或解析（parsing）是编译的第二个步骤，使用词法单元来创建树形的中间表示，该中间表示给出了词法分析产生的词法单元流的语法结构。一个常用的表示方法是语法树（syntax tree），树中每个内部结点表示一个运算，而该结点的子结点表示该运算的分量。\r\n\r\n接下来是语义分析（semantic analyzer），使用语法树和符号表中的信息来检测源程序是否和语言定义的语义一致。\r\n\r\n在源程序的语法分析和语义分析之后，生成一个明确的低级的或者类机器语言的中间表示。接下来一般会有一个机器无关的代码优化步骤，试图改进中间代码，以便生成更好的目标代码。\r\n\r\n# 汇编\r\n\r\n对于被翻译系统处理的每一个C/C++语言源程序，都将最终经过这一处理而得到相应的目标文件。目标文件中所存放的也就是与源程序等效的目标机器语言代码。目标文件由段组成，通常一个目标文件中至少有两个段：代码段和数据段。\r\n\r\n* 代码段：该段中所包含的主要是程序的指令。该段一般是可读和可执行的，但一般却不可写。\r\n* 数据段：主要存放程序中要用到的各种全局变量或静态的数据。一般数据段都是可读，可写，可执行的。\r\n\r\n# 链接\r\n\r\n链接程序的主要工作就是将有关的目标文件彼此相连接，也即将在一个文件中引用的符号同该符号在另外一个文件中的定义连接起来，使得所有的这些目标文件成为一个能够按操作系统装入执行的统一整体。主要有静态链接和动态链接两种方式：\r\n\r\n* `静态链接`：在链接阶段，会将汇编生成的目标文件.o与引用到的库一起链接打包到可执行文件中，程序运行的时候不再需要静态库文件。\r\n* `动态链接`：把调用的函数所在文件模块（DLL）和调用函数在文件中的位置等信息链接进目标程序，程序运行的时候再从DLL中寻找相应函数代码，因此需要相应DLL文件的支持。  \r\n\r\n这里的库是写好的现有的，成熟的，可以复用的代码。现实中每个程序都要依赖很多基础的底层库，不可能每个人的代码都从零开始，因此库的存在意义非同寻常。本质上来说库是一种可执行代码的二进制形式，可以被操作系统载入内存执行。库有两种：静态库（.a、.lib）和动态库（.so、.dll），所谓静态、动态是指链接方式的不同。\r\n\r\n静态链接库与动态链接库都是**共享代码**的方式。如果采用静态链接库，程序在运行时与函数库再无瓜葛，移植方便。但是会浪费空间和资源，因为所有相关的目标文件与牵涉到的函数库被链接合成一个可执行文件。此外，静态库对程序的更新、部署和发布也会带来麻烦。如果静态库更新了，所有使用它的应用程序都需要重新编译、发布给用户。\r\n\r\n动态库在程序编译时并不会被连接到目标代码中，而是在程序运行是才被载入。不同的应用程序如果调用相同的库，那么在内存里只需要有一份该共享库的实例，规避了空间浪费问题。动态库在程序运行是才被载入，也解决了静态库对程序的更新、部署和发布页会带来麻烦。用户只需要更新动态库即可，增量更新。\r\n\r\n此外，还要注意静态链接库中不能再包含其他的动态链接库或者静态库，而在动态链接库中还可以再包含其他的动态或静态链接库。\r\n\r\n# 简单的例子\r\n\r\n下面是一个保存在文件 helloworld.cpp 中一个简单的 C++ 程序的代码：\r\n\r\n    /* helloworld.cpp */\r\n    #include <iostream>\r\n    int main(int argc,char *argv[])\r\n    {\r\n        std::cout << \"hello, world\" << std::endl;\r\n        return 0;\r\n    }\r\n\r\n用下面命令编译：\r\n\r\n    $ g++ helloworld.cpp\r\n\r\n编译器 g++ 通过检查命令行中指定的文件的后缀名可识别其为 C++ 源代码文件。编译器默认的动作：编译源代码文件生成对象文件(object file)，链接对象文件和 libstd c++ 库中的函数得到可执行程序，然后删除对象文件。由于命令行中未指定可执行程序的文件名，编译器采用默认的 a.out。\r\n\r\n## 预处理\r\n\r\n选项 -E 使 g++ 将源代码用编译预处理器处理后不再执行其他动作。下面的命令预处理源码文件 helloworld.cpp，并将结果保存在 .ii 文件中：\r\n\r\n    ➜  ~  g++ -E helloworld.cpp -o helloworld.ii\r\n    ➜  ~  ls | grep helloworld\r\n    helloworld.cpp\r\n    helloworld.ii\r\n    ➜  ~  wc -l helloworld.ii\r\n       38126 helloworld.ii\r\n\r\nhelloworld.cpp 的源代码，仅仅有六行，而且该程序除了显示一行文字外什么都不做，但是，预处理后的版本将超过3万行。这主要是因为头文件 iostream 被包含进来，而且它又包含了其他的头文件，除此之外，还有若干个处理输入和输出的类的定义。\r\n\r\n## 编译\r\n\r\n选项 -S 指示编译器将程序编译成汇编代码，输出汇编语言代码而后结束。下面的命令将由 C++ 源码文件生成汇编语言文件 helloworld.s，生成的汇编语言依赖于编译器的目标平台。\r\n\r\n    g++ -S helloworld.cpp\r\n\r\n## 汇编\r\n\r\n选项 -c 用来告诉编译器将汇编代码（.s文件，或者直接对源代码）转换为目标文件，但不要执行链接。输出结果为对象文件，文件默认名与源码文件名相同，只是将其后缀变为 .o。\r\n\r\n    ➜  ~  g++ -c helloworld.s\r\n    ➜  ~  ls |grep helloworld.o\r\n    helloworld.o\r\n\r\n\r\n## 链接\r\n\r\n加载相应的库，执行链接操作，将对象文件（.o，也可以直接将原文件）转化成可执行程序。\r\n\r\n    ➜  ~  g++ helloworld.o -o helloworld.o\r\n    ➜  ~  ./helloworld.o\r\n    hello, world\r\n\r\n\r\n# 更多阅读\r\n  \r\n[详解C/C++预处理器](http://blog.csdn.net/huang_xw/article/details/7648117)  \r\n[Compiling Cpp](http://wiki.ubuntu.org.cn/Compiling_Cpp)  \r\n[C++静态库与动态库](http://www.cnblogs.com/skynet/p/3372855.html)  \r\n[高级语言的编译：链接及装载过程介绍](http://tech.meituan.com/linker.html)    \r\n[编译原理 (预处理>编译>汇编>链接)](http://www.cnblogs.com/pipicfan/archive/2012/07/10/2583910.html)  \r\n\r\n', '564', '12', '1', '1', '2016-09-20 00:00:00', '2016-10-16 00:07:07');
INSERT INTO `topics` VALUES ('2', 'C++ 声明还是定义?', '简单来说：\r\n\r\n> Declaration is for the compiler to accept a name(to tell the compiler that the name is legal, the name is introduced with intention not a typo).   \r\n>\r\n> A variable is declared when the compiler is informed that a variable exists (and this is its type); it does not allocate the storage for the variable at that point.\r\n>   \r\n> Definition is where a name and its content is associated. The definition is used by the linker to link a name reference to the content of the name.  \r\n> \r\n>A variable is defined when the compiler allocates the storage for the variable.\r\n\r\n变量声明（declaration）用来引入标识符，并对它的类型（对象，函数等）进行说明，有了声明语句，`编译器`就可以理解对该标识符的引用。下面的这些都是声明语句：\r\n\r\n    extern int bar;\r\n    extern int g(int, int);\r\n    double f(int, double); // extern can be omitted for function declarations\r\n    class foo; // no extern allowed for type declarations\r\n\r\n可以重复声明一个变量，所以下面语句是合法的：\r\n\r\n    double f(int, double);\r\n    double f(int, double);\r\n    extern double f(int, double); // the same as the two above\r\n    extern double f(int, double);\r\n\r\n变量定义（definition）**用于为变量分配存储空间，还可为变量指定初始值**。可以将定义看作是对声明的变量进行实例化，`链接器`需要根据定义来找到变量具体对应的值。下面是前面声明语句对应的定义部分：\r\n\r\n    int bar;\r\n    int g(int lhs, int rhs) {return lhs*rhs;}\r\n    double f(int i, double d) {return i+d;}\r\n    class foo {};\r\n\r\n程序中，变量必须有且仅有一个定义。\r\n\r\n> No translation unit shall contain more than one definition of any variable, function, class type, enumeration type, or template.\r\n\r\n重复定义会导致链接器不知道哪一个是需要的，编译器会报错：`redefinition of`。变量缺少定义链接器会因为 `symbol(s) not found` 链接失败。下面代码片段中 b 没有定义，c重复定义：\r\n\r\n    extern int a;\r\n    extern int b;\r\n    \r\n    int main(){\r\n        int a;\r\n        cout << a << b;\r\n        int c;\r\n        int c;\r\n    }\r\n\r\n有时候区别声明和定义还真不是那么简单的，看下面的例子：\r\n\r\n```c++\r\nstruct Test\r\n{\r\n    Test(int) {}\r\n    Test() {}\r\n    void fun() {}\r\n};\r\nvoid main( void )\r\n{\r\n    Test a(1);  // 定义了一个对象\r\n    a.fun();    // 调用对象的函数 \r\n    Test b();   // 声明了一个函数\r\n    // b.fun();    // Error！！！\r\n}\r\n```', '538', '9', '1', '1', '2016-09-20 00:00:00', '2016-10-19 14:32:14');
INSERT INTO `topics` VALUES ('3', 'C++左值还是右值', '左值与右值这两概念是从 c 中传承而来的，在 c 中，左值指的是既能够出现在等号左边也能出现在等号右边的变量(或表达式)，右值指的则是只能出现在等号右边的变量(或表达式)。\n\n\n	int a;\n	int b;\n    	\n	a = 3;\n	b = 4;\n	a = b;\n	b = a;\n 	   \n	// 以下写法不合法。\n	3 = a;\n	a+b = 4;\n\n\n在 C 语言中，通常来说有名字的变量就是左值(如上面例子中的 a, b)，而由运算操作(加减乘除，函数调用返回值等)所产生的中间结果(没有名字)就是右值，如上的 3 + 4， a + b 等。可以认为**左值就是在程序中能够寻址的东西，右值就是没法取到它的地址的东西**。\n\n如上概念到了 c++ 中，就变得稍有不同。具体来说，在 c++ 中，`每一个表达式或者是一个左值，或者是一个右值`，相应的，该表达式也就被称作“左值表达式\"，\"右值表达式\"。对于内置的基本数据类型来说(primitive types)，左值右值的概念和 c 没有太多不同，不同的地方在于自定义的类型:\n\n* 对于内置的类型，右值是不可被修改的(non-modifiable)，也不可被 const, volatile 所修饰；\n* 对于自定义的类型(user-defined types)，右值却允许通过它的成员函数进行修改。\n\nC++ 中自定义类型允许有成员函数，而通过右值调用成员函数是被允许的，但成员函数有可能不是 const 类型，因此通过调用右值的成员函数，也就可能会修改了该右值。此外，**右值只能被 const 类型的 reference 所指向**，当一个右值被 const reference 指向时，它的生命周期就被延长了。\n\n具体示例在 [C++_LR_Value](../Coding/C++_LR_Value.cpp)。\n', '500', '7', '1', '1', '2016-10-12 00:00:00', '2016-10-10 00:00:00');
INSERT INTO `topics` VALUES ('4', '引用', '\n引用（reference）是c++对c语言的重要扩充，引用就是某一变量（目标）的一个别名，对引用的操作与对变量直接操作完全一样。引用是除指针外另一个可以产生多态效果的手段。这意味着，一个基类的引用可以指向它的派生类实例。引用的定义方法：\n\n    类型标识符 &引用名=目标变量名；\n\n类型标识符是指目标变量的类型，这里的 & 不是求地址运算，而是起标识作用。**在定义引用时，必须同时对其进行初始化**，引用定义完毕后，相当于目标变量名有两个名称，即该目标原名称和引用名，且不能再将该引用指向其它变量。\n\n    int a=2,\n    int &ra=a;\n\na为原变量名称，ra为引用名。给ra赋值：ra=1; 等价于 a=1。对引用求地址，就是对目标变量求地址，因此&ra与&a相等。注意我们**不能建立引用的数组**，因为数组是一个由若干个元素所组成的集合，所以无法建立一个由引用组成的集合。\n\n    int& ref[3]= {2,3,5}; //int& ref[3]= {2,3,5}; //不能声明引用的数组\n    const int (&ref)[3] ={2,3,5};                 // 可以\n\n编译器一般将引用实现为`const指针`，即指向位置不可变的指针，也就是说引用实际上与一般指针同样占用内存，不过我们没有办法获得这个指针的地址。\n', '556', '6', '1', '1', '2016-10-10 00:00:00', '2016-01-20 00:00:00');
INSERT INTO `topics` VALUES ('5', '失败的多态？', '下面多态函数调用的输出？\r\n\r\n```\r\nclass B\r\n{\r\npublic:\r\n    virtual void vfun(int i = 10){\r\n        cout << \"B:vfun \" << i << endl;\r\n    }\r\n};\r\n\r\nclass D : public B\r\n{\r\npublic:\r\n    virtual void vfun(int i = 20){\r\n        cout << \"D:vfun \" << i << endl;\r\n    }\r\n};\r\n\r\nint main()\r\n{\r\n    D* pD = new D();\r\n    B* pB = pD;\r\n    pD->vfun();     // D:vfun 20\r\n    pB->vfun();     // D:vfun 10\r\n}\r\n```\r\n\r\n为了解释清楚，先来看四个概念：\r\n\r\n* 对象的静态类型：对象在声明时采用的类型，是在编译期确定的。\r\n* 对象的动态类型：目前所指对象的类型，是在运行期决定的。对象的动态类型可以更改，但是静态类型无法更改。\r\n* 静态绑定：绑定的是对象的静态类型，某些特性依赖于对象的静态类型，发生在编译期。\r\n* 动态绑定：绑定的是对象的动态类型，某些特性（比如多态）依赖于对象的动态类型，发生在运行期。\r\n\r\n假设类B是一个基类，类C继承B，类D继承B，那么：\r\n\r\n    D* pD = new D();//pD的静态类型是它声明的类型D*，动态类型也是D*\r\n    B* pB = pD;     //pB的静态类型是它声明的类型B*，动态类型是pB所指向的对象pD的类型D*\r\n    C* pC = new C();  \r\n    pB = pC;        //pB的动态类型是可以更改的，现在它的动态类型是C*\r\n\r\n只有虚函数才使用的是动态绑定，其他的全部是静态绑定。当缺省参数和虚函数一起出现的时候情况有点复杂，极易出错。虚函数是动态绑定的，但是为了执行效率，**缺省参数是静态绑定的**。\r\n\r\n所以对于上面的例子，pD->vfun()和pB->vfun()调用都是函数D::vfun()，但是缺省参数是静态绑定的，所以 pD->vfun() 时，pD的静态类型是D*，所以它的缺省参数应该是20；同理，pB->vfun()的缺省参数应该是10。\r\n\r\n不是很容易接受是吧，所以`Effective C++ 条款37：绝不要重新定义继承而来的缺省参数`。', '512', '3', '1', '1', '2016-10-16 08:24:18', '2016-10-16 16:31:19');
INSERT INTO `topics` VALUES ('6', 'Markdown 语法说明 (简体中文版)', '\r\n*   [概述](#overview)\r\n    *   [宗旨](#philosophy)\r\n    *   [兼容 HTML](#html)\r\n    *   [特殊字符自动转换](#autoescape)\r\n*   [区块元素](#block)\r\n    *   [段落和换行](#p)\r\n    *   [标题](#header)\r\n    *   [区块引用](#blockquote)\r\n    *   [列表](#list)\r\n    *   [代码区块](#precode)\r\n    *   [分隔线](#hr)\r\n*   [区段元素](#span)\r\n    *   [链接](#link)\r\n    *   [强调](#em)\r\n    *   [代码](#code)\r\n    *   [图片](#img)\r\n*   [其它](#misc)\r\n    *   [反斜杠](#backslash)\r\n    *   [自动链接](#autolink)\r\n*   [感谢](#acknowledgement)\r\n*	[Markdown 免费编辑器](#editor)\r\n\r\n* * *\r\n\r\n<h2 id=\"overview\">概述</h2>\r\n\r\n<h3 id=\"philosophy\">宗旨</h3>\r\n\r\nMarkdown 的目标是实现「易读易写」。\r\n\r\n可读性，无论如何，都是最重要的。一份使用 Markdown 格式撰写的文件应该可以直接以纯文本发布，并且看起来不会像是由许多标签或是格式指令所构成。Markdown 语法受到一些既有 text-to-HTML 格式的影响，包括 [Setext] [1]、[atx] [2]、[Textile] [3]、[reStructuredText] [4]、[Grutatext] [5] 和 [EtText] [6]，而最大灵感来源其实是纯文本电子邮件的格式。\r\n\r\n  [1]: http://docutils.sourceforge.net/mirror/setext.html\r\n  [2]: http://www.aaronsw.com/2002/atx/\r\n  [3]: http://textism.com/tools/textile/\r\n  [4]: http://docutils.sourceforge.net/rst.html\r\n  [5]: http://www.triptico.com/software/grutatxt.html\r\n  [6]: http://ettext.taint.org/doc/\r\n\r\n总之， Markdown 的语法全由一些符号所组成，这些符号经过精挑细选，其作用一目了然。比如：在文字两旁加上星号，看起来就像\\*强调\\*。Markdown 的列表看起来，嗯，就是列表。Markdown 的区块引用看起来就真的像是引用一段文字，就像你曾在电子邮件中见过的那样。\r\n\r\n<h3 id=\"html\">兼容 HTML</h3>\r\n\r\nMarkdown 语法的目标是：成为一种适用于网络的*书写*语言。\r\n\r\nMarkdown 不是想要取代 HTML，甚至也没有要和它相近，它的语法种类很少，只对应 HTML 标记的一小部分。Markdown 的构想*不是*要使得 HTML 文档更容易书写。在我看来， HTML 已经很容易写了。Markdown 的理念是，能让文档更容易读、写和随意改。HTML 是一种*发布*的格式，Markdown 是一种*书写*的格式。就这样，Markdown 的格式语法只涵盖纯文本可以涵盖的范围。\r\n\r\n不在 Markdown 涵盖范围之内的标签，都可以直接在文档里面用 HTML 撰写。不需要额外标注这是 HTML 或是 Markdown；只要直接加标签就可以了。\r\n\r\n要制约的只有一些 HTML 区块元素――比如 `<div>`、`<table>`、`<pre>`、`<p>` 等标签，必须在前后加上空行与其它内容区隔开，还要求它们的开始标签与结尾标签不能用制表符或空格来缩进。Markdown 的生成器有足够智能，不会在 HTML 区块标签外加上不必要的 `<p>` 标签。\r\n\r\n例子如下，在 Markdown 文件里加上一段 HTML 表格：\r\n\r\n    这是一个普通段落。\r\n\r\n    <table>\r\n        <tr>\r\n            <td>Foo</td>\r\n        </tr>\r\n    </table>\r\n\r\n    这是另一个普通段落。\r\n\r\n请注意，在 HTML 区块标签间的 Markdown 格式语法将不会被处理。比如，你在 HTML 区块内使用 Markdown 样式的`*强调*`会没有效果。\r\n\r\nHTML 的区段（行内）标签如 `<span>`、`<cite>`、`<del>` 可以在 Markdown 的段落、列表或是标题里随意使用。依照个人习惯，甚至可以不用 Markdown 格式，而直接采用 HTML 标签来格式化。举例说明：如果比较喜欢 HTML 的 `<a>` 或 `<img>` 标签，可以直接使用这些标签，而不用 Markdown 提供的链接或是图像标签语法。\r\n\r\n和处在 HTML 区块标签间不同，Markdown 语法在 HTML 区段标签间是有效的。\r\n\r\n<h3 id=\"autoescape\">特殊字符自动转换</h3>\r\n\r\n在 HTML 文件中，有两个字符需要特殊处理： `<` 和 `&` 。 `<` 符号用于起始标签，`&` 符号则用于标记 HTML 实体，如果你只是想要显示这些字符的原型，你必须要使用实体的形式，像是 `&lt;` 和 `&amp;`。\r\n\r\n`&` 字符尤其让网络文档编写者受折磨，如果你要打「`AT&T`」 ，你必须要写成「`AT&amp;T`」。而网址中的 `&` 字符也要转换。比如你要链接到：\r\n\r\n    http://images.google.com/images?num=30&q=larry+bird\r\n\r\n你必须要把网址转换写为：\r\n\r\n    http://images.google.com/images?num=30&amp;q=larry+bird\r\n\r\n才能放到链接标签的 `href` 属性里。不用说也知道这很容易忽略，这也可能是 HTML 标准检验所检查到的错误中，数量最多的。\r\n\r\nMarkdown 让你可以自然地书写字符，需要转换的由它来处理好了。如果你使用的 `&` 字符是 HTML 字符实体的一部分，它会保留原状，否则它会被转换成 `&amp`;。\r\n\r\n所以你如果要在文档中插入一个版权符号 `©`，你可以这样写：\r\n\r\n    &copy;\r\n\r\nMarkdown 会保留它不动。而若你写：\r\n\r\n    AT&T\r\n\r\nMarkdown 就会将它转为：\r\n\r\n    AT&amp;T\r\n\r\n类似的状况也会发生在 `<` 符号上，因为 Markdown 允许 [兼容 HTML](#html) ，如果你是把 `<` 符号作为 HTML 标签的定界符使用，那 Markdown 也不会对它做任何转换，但是如果你写：\r\n\r\n    4 < 5\r\n\r\nMarkdown 将会把它转换为：\r\n\r\n    4 &lt; 5\r\n\r\n不过需要注意的是，code 范围内，不论是行内还是区块， `<` 和 `&` 两个符号都*一定*会被转换成 HTML 实体，这项特性让你可以很容易地用 Markdown 写 HTML code （和 HTML 相对而言， HTML 语法中，你要把所有的 `<` 和 `&` 都转换为 HTML 实体，才能在 HTML 文件里面写出 HTML code。）\r\n\r\n* * *\r\n\r\n<h2 id=\"block\">区块元素</h2>\r\n\r\n\r\n<h3 id=\"p\">段落和换行</h3>\r\n\r\n一个 Markdown 段落是由一个或多个连续的文本行组成，它的前后要有一个以上的空行（空行的定义是显示上看起来像是空的，便会被视为空行。比方说，若某一行只包含空格和制表符，则该行也会被视为空行）。普通段落不该用空格或制表符来缩进。\r\n\r\n「由一个或多个连续的文本行组成」这句话其实暗示了 Markdown 允许段落内的强迫换行（插入换行符），这个特性和其他大部分的 text-to-HTML 格式不一样（包括 Movable Type 的「Convert Line Breaks」选项），其它的格式会把每个换行符都转成 `<br />` 标签。\r\n\r\n如果你*确实*想要依赖 Markdown 来插入 `<br />` 标签的话，在插入处先按入两个以上的空格然后回车。\r\n\r\n的确，需要多费点事（多加空格）来产生 `<br />` ，但是简单地「每个换行都转换为 `<br />`」的方法在 Markdown 中并不适合， Markdown 中 email 式的 [区块引用][bq] 和多段落的 [列表][l] 在使用换行来排版的时候，不但更好用，还更方便阅读。\r\n\r\n  [bq]: #blockquote\r\n  [l]:  #list\r\n\r\n<h3 id=\"header\">标题</h3>\r\n\r\nMarkdown 支持两种标题的语法，类 [Setext] [1] 和类 [atx] [2] 形式。\r\n\r\n类 Setext 形式是用底线的形式，利用 `=` （最高阶标题）和 `-` （第二阶标题），例如：\r\n\r\n    This is an H1\r\n    =============\r\n\r\n    This is an H2\r\n    -------------\r\n\r\n任何数量的 `=` 和 `-` 都可以有效果。\r\n\r\n类 Atx 形式则是在行首插入 1 到 6 个 `#` ，对应到标题 1 到 6 阶，例如：\r\n\r\n    # 这是 H1\r\n\r\n    ## 这是 H2\r\n\r\n    ###### 这是 H6\r\n\r\n你可以选择性地「闭合」类 atx 样式的标题，这纯粹只是美观用的，若是觉得这样看起来比较舒适，你就可以在行尾加上 `#`，而行尾的 `#` 数量也不用和开头一样（行首的井字符数量决定标题的阶数）：\r\n\r\n    # 这是 H1 #\r\n\r\n    ## 这是 H2 ##\r\n\r\n    ### 这是 H3 ######\r\n\r\n\r\n<h3 id=\"blockquote\">区块引用 Blockquotes</h3>\r\n\r\nMarkdown 标记区块引用是使用类似 email 中用 `>` 的引用方式。如果你还熟悉在 email 信件中的引言部分，你就知道怎么在 Markdown 文件中建立一个区块引用，那会看起来像是你自己先断好行，然后在每行的最前面加上 `>` ：\r\n\r\n    > This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,\r\n    > consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.\r\n    > Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.\r\n    > \r\n    > Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse\r\n    > id sem consectetuer libero luctus adipiscing.\r\n效果就像：\r\n> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,\r\n> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.\r\n> Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.\r\n> \r\n> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse\r\n> id sem consectetuer libero luctus adipiscing.\r\n\r\nMarkdown 也允许你偷懒只在整个段落的第一行最前面加上 `>` ：\r\n\r\n    > This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,\r\n    consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.\r\n    Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.\r\n\r\n    > Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse\r\n    id sem consectetuer libero luctus adipiscing.\r\n\r\n区块引用可以嵌套（例如：引用内的引用），只要根据层次加上不同数量的 `>` ：\r\n\r\n    > This is the first level of quoting.\r\n    >\r\n    > > This is nested blockquote.\r\n    >\r\n    > Back to the first level.\r\n\r\n引用的区块内也可以使用其他的 Markdown 语法，包括标题、列表、代码区块等：\r\n\r\n	> ## 这是一个标题。\r\n	> \r\n	> 1.   这是第一行列表项。\r\n	> 2.   这是第二行列表项。\r\n	> \r\n	> 给出一些例子代码：\r\n	> \r\n	>     return shell_exec(\"echo $input | $markdown_script\");\r\n\r\n任何像样的文本编辑器都能轻松地建立 email 型的引用。例如在 BBEdit 中，你可以选取文字后然后从选单中选择*增加引用阶层*。\r\n\r\n<h3 id=\"list\">列表</h3>\r\n\r\nMarkdown 支持有序列表和无序列表。\r\n\r\n无序列表使用星号、加号或是减号作为列表标记：\r\n\r\n    *   Red\r\n    *   Green\r\n    *   Blue\r\n\r\n等同于：\r\n\r\n    +   Red\r\n    +   Green\r\n    +   Blue\r\n\r\n也等同于：\r\n\r\n    -   Red\r\n    -   Green\r\n    -   Blue\r\n\r\n有序列表则使用数字接着一个英文句点：\r\n\r\n    1.  Bird\r\n    2.  McHale\r\n    3.  Parish\r\n\r\n很重要的一点是，你在列表标记上使用的数字并不会影响输出的 HTML 结果，上面的列表所产生的 HTML 标记为：\r\n\r\n    <ol>\r\n    <li>Bird</li>\r\n    <li>McHale</li>\r\n    <li>Parish</li>\r\n    </ol>\r\n\r\n如果你的列表标记写成：\r\n\r\n    1.  Bird\r\n    1.  McHale\r\n    1.  Parish\r\n\r\n或甚至是：\r\n\r\n    3. Bird\r\n    1. McHale\r\n    8. Parish\r\n\r\n你都会得到完全相同的 HTML 输出。重点在于，你可以让 Markdown 文件的列表数字和输出的结果相同，或是你懒一点，你可以完全不用在意数字的正确性。\r\n\r\n如果你使用懒惰的写法，建议第一个项目最好还是从 1. 开始，因为 Markdown 未来可能会支持有序列表的 start 属性。\r\n\r\n列表项目标记通常是放在最左边，但是其实也可以缩进，最多 3 个空格，项目标记后面则一定要接着至少一个空格或制表符。\r\n\r\n要让列表看起来更漂亮，你可以把内容用固定的缩进整理好：\r\n\r\n    *   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\r\n        Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,\r\n        viverra nec, fringilla in, laoreet vitae, risus.\r\n    *   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.\r\n        Suspendisse id sem consectetuer libero luctus adipiscing.\r\n\r\n但是如果你懒，那也行：\r\n\r\n    *   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\r\n    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,\r\n    viverra nec, fringilla in, laoreet vitae, risus.\r\n    *   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.\r\n    Suspendisse id sem consectetuer libero luctus adipiscing.\r\n\r\n如果列表项目间用空行分开，在输出 HTML 时 Markdown 就会将项目内容用 `<p>` \r\n标签包起来，举例来说：\r\n\r\n    *   Bird\r\n    *   Magic\r\n\r\n会被转换为：\r\n\r\n    <ul>\r\n    <li>Bird</li>\r\n    <li>Magic</li>\r\n    </ul>\r\n\r\n但是这个：\r\n\r\n    *   Bird\r\n\r\n    *   Magic\r\n\r\n会被转换为：\r\n\r\n    <ul>\r\n    <li><p>Bird</p></li>\r\n    <li><p>Magic</p></li>\r\n    </ul>\r\n\r\n列表项目可以包含多个段落，每个项目下的段落都必须缩进 4 个空格或是 1 个制表符：\r\n\r\n    1.  This is a list item with two paragraphs. Lorem ipsum dolor\r\n        sit amet, consectetuer adipiscing elit. Aliquam hendrerit\r\n        mi posuere lectus.\r\n\r\n        Vestibulum enim wisi, viverra nec, fringilla in, laoreet\r\n        vitae, risus. Donec sit amet nisl. Aliquam semper ipsum\r\n        sit amet velit.\r\n\r\n    2.  Suspendisse id sem consectetuer libero luctus adipiscing.\r\n\r\n如果你每行都有缩进，看起来会看好很多，当然，再次地，如果你很懒惰，Markdown 也允许：\r\n\r\n    *   This is a list item with two paragraphs.\r\n\r\n        This is the second paragraph in the list item. You\'re\r\n    only required to indent the first line. Lorem ipsum dolor\r\n    sit amet, consectetuer adipiscing elit.\r\n\r\n    *   Another item in the same list.\r\n\r\n如果要在列表项目内放进引用，那 `>` 就需要缩进：\r\n\r\n    *   A list item with a blockquote:\r\n\r\n        > This is a blockquote\r\n        > inside a list item.\r\n\r\n如果要放代码区块的话，该区块就需要缩进*两次*，也就是 8 个空格或是 2 个制表符：\r\n\r\n    *   一列表项包含一个列表区块：\r\n\r\n            <代码写在这>\r\n\r\n\r\n当然，项目列表很可能会不小心产生，像是下面这样的写法：\r\n\r\n    1986. What a great season.\r\n\r\n换句话说，也就是在行首出现*数字-句点-空白*，要避免这样的状况，你可以在句点前面加上反斜杠。\r\n\r\n    1986\\. What a great season.\r\n\r\n<h3 id=\"precode\">代码区块</h3>\r\n\r\n和程序相关的写作或是标签语言原始码通常会有已经排版好的代码区块，通常这些区块我们并不希望它以一般段落文件的方式去排版，而是照原来的样子显示，Markdown 会用 `<pre>` 和 `<code>` 标签来把代码区块包起来。\r\n\r\n要在 Markdown 中建立代码区块很简单，只要简单地缩进 4 个空格或是 1 个制表符就可以，例如，下面的输入：\r\n\r\n    这是一个普通段落：\r\n\r\n        这是一个代码区块。\r\n\r\nMarkdown 会转换成：\r\n\r\n    <p>这是一个普通段落：</p>\r\n\r\n    <pre><code>这是一个代码区块。\r\n    </code></pre>\r\n\r\n这个每行一阶的缩进（4 个空格或是 1 个制表符），都会被移除，例如：\r\n\r\n    Here is an example of AppleScript:\r\n\r\n        tell application \"Foo\"\r\n            beep\r\n        end tell\r\n\r\n会被转换为：\r\n\r\n    <p>Here is an example of AppleScript:</p>\r\n\r\n    <pre><code>tell application \"Foo\"\r\n        beep\r\n    end tell\r\n    </code></pre>\r\n\r\n一个代码区块会一直持续到没有缩进的那一行（或是文件结尾）。\r\n\r\n在代码区块里面， `&` 、 `<` 和 `>` 会自动转成 HTML 实体，这样的方式让你非常容易使用 Markdown 插入范例用的 HTML 原始码，只需要复制贴上，再加上缩进就可以了，剩下的 Markdown 都会帮你处理，例如：\r\n\r\n        <div class=\"footer\">\r\n            &copy; 2004 Foo Corporation\r\n        </div>\r\n\r\n会被转换为：\r\n\r\n    <pre><code>&lt;div class=\"footer\"&gt;\r\n        &amp;copy; 2004 Foo Corporation\r\n    &lt;/div&gt;\r\n    </code></pre>\r\n\r\n代码区块中，一般的 Markdown 语法不会被转换，像是星号便只是星号，这表示你可以很容易地以 Markdown 语法撰写 Markdown 语法相关的文件。\r\n\r\n<h3 id=\"hr\">分隔线</h3>\r\n\r\n你可以在一行中用三个以上的星号、减号、底线来建立一个分隔线，行内不能有其他东西。你也可以在星号或是减号中间插入空格。下面每种写法都可以建立分隔线：\r\n\r\n    * * *\r\n\r\n    ***\r\n\r\n    *****\r\n\r\n    - - -\r\n\r\n    ---------------------------------------\r\n\r\n\r\n* * *\r\n\r\n<h2 id=\"span\">区段元素</h2>\r\n\r\n<h3 id=\"link\">链接</h3>\r\n\r\nMarkdown 支持两种形式的链接语法： *行内式*和*参考式*两种形式。\r\n\r\n不管是哪一种，链接文字都是用 [方括号] 来标记。\r\n\r\n要建立一个*行内式*的链接，只要在方块括号后面紧接着圆括号并插入网址链接即可，如果你还想要加上链接的 title 文字，只要在网址后面，用双引号把 title 文字包起来即可，例如：\r\n\r\n    This is [an example](http://example.com/ \"Title\") inline link.\r\n\r\n    [This link](http://example.net/) has no title attribute.\r\n\r\n会产生：\r\n\r\n    <p>This is <a href=\"http://example.com/\" title=\"Title\">\r\n    an example</a> inline link.</p>\r\n\r\n    <p><a href=\"http://example.net/\">This link</a> has no\r\n    title attribute.</p>\r\n\r\n如果你是要链接到同样主机的资源，你可以使用相对路径：\r\n\r\n    See my [About](/about/) page for details.   \r\n\r\n*参考式*的链接是在链接文字的括号后面再接上另一个方括号，而在第二个方括号里面要填入用以辨识链接的标记：\r\n\r\n    This is [an example][id] reference-style link.\r\n\r\n你也可以选择性地在两个方括号中间加上一个空格：\r\n\r\n    This is [an example] [id] reference-style link.\r\n\r\n接着，在文件的任意处，你可以把这个标记的链接内容定义出来：\r\n\r\n    [id]: http://example.com/  \"Optional Title Here\"\r\n\r\n链接内容定义的形式为：\r\n\r\n*   方括号（前面可以选择性地加上至多三个空格来缩进），里面输入链接文字\r\n*   接着一个冒号\r\n*   接着一个以上的空格或制表符\r\n*   接着链接的网址\r\n*   选择性地接着 title 内容，可以用单引号、双引号或是括弧包着\r\n\r\n下面这三种链接的定义都是相同：\r\n\r\n	[foo]: http://example.com/  \"Optional Title Here\"\r\n	[foo]: http://example.com/  \'Optional Title Here\'\r\n	[foo]: http://example.com/  (Optional Title Here)\r\n\r\n**请注意：**有一个已知的问题是 Markdown.pl 1.0.1 会忽略单引号包起来的链接 title。\r\n\r\n链接网址也可以用方括号包起来：\r\n\r\n    [id]: <http://example.com/>  \"Optional Title Here\"\r\n\r\n你也可以把 title 属性放到下一行，也可以加一些缩进，若网址太长的话，这样会比较好看：\r\n\r\n    [id]: http://example.com/longish/path/to/resource/here\r\n        \"Optional Title Here\"\r\n\r\n网址定义只有在产生链接的时候用到，并不会直接出现在文件之中。\r\n\r\n链接辨别标签可以有字母、数字、空白和标点符号，但是并*不*区分大小写，因此下面两个链接是一样的：\r\n\r\n	[link text][a]\r\n	[link text][A]\r\n\r\n*隐式链接标记*功能让你可以省略指定链接标记，这种情形下，链接标记会视为等同于链接文字，要用隐式链接标记只要在链接文字后面加上一个空的方括号，如果你要让 \"Google\" 链接到 google.com，你可以简化成：\r\n\r\n	[Google][]\r\n\r\n然后定义链接内容：\r\n\r\n	[Google]: http://google.com/\r\n\r\n由于链接文字可能包含空白，所以这种简化型的标记内也许包含多个单词：\r\n\r\n	Visit [Daring Fireball][] for more information.\r\n\r\n然后接着定义链接：\r\n\r\n	[Daring Fireball]: http://daringfireball.net/\r\n\r\n链接的定义可以放在文件中的任何一个地方，我比较偏好直接放在链接出现段落的后面，你也可以把它放在文件最后面，就像是注解一样。\r\n\r\n下面是一个参考式链接的范例：\r\n\r\n    I get 10 times more traffic from [Google] [1] than from\r\n    [Yahoo] [2] or [MSN] [3].\r\n\r\n      [1]: http://google.com/        \"Google\"\r\n      [2]: http://search.yahoo.com/  \"Yahoo Search\"\r\n      [3]: http://search.msn.com/    \"MSN Search\"\r\n\r\n如果改成用链接名称的方式写：\r\n\r\n    I get 10 times more traffic from [Google][] than from\r\n    [Yahoo][] or [MSN][].\r\n\r\n      [google]: http://google.com/        \"Google\"\r\n      [yahoo]:  http://search.yahoo.com/  \"Yahoo Search\"\r\n      [msn]:    http://search.msn.com/    \"MSN Search\"\r\n\r\n上面两种写法都会产生下面的 HTML。\r\n\r\n    <p>I get 10 times more traffic from <a href=\"http://google.com/\"\r\n    title=\"Google\">Google</a> than from\r\n    <a href=\"http://search.yahoo.com/\" title=\"Yahoo Search\">Yahoo</a>\r\n    or <a href=\"http://search.msn.com/\" title=\"MSN Search\">MSN</a>.</p>\r\n\r\n下面是用行内式写的同样一段内容的 Markdown 文件，提供作为比较之用：\r\n\r\n    I get 10 times more traffic from [Google](http://google.com/ \"Google\")\r\n    than from [Yahoo](http://search.yahoo.com/ \"Yahoo Search\") or\r\n    [MSN](http://search.msn.com/ \"MSN Search\").\r\n\r\n参考式的链接其实重点不在于它比较好写，而是它比较好读，比较一下上面的范例，使用参考式的文章本身只有 81 个字符，但是用行内形式的却会增加到 176 个字元，如果是用纯 HTML 格式来写，会有 234 个字元，在 HTML 格式中，标签比文本还要多。\r\n\r\n使用 Markdown 的参考式链接，可以让文件更像是浏览器最后产生的结果，让你可以把一些标记相关的元数据移到段落文字之外，你就可以增加链接而不让文章的阅读感觉被打断。\r\n\r\n<h3 id=\"em\">强调</h3>\r\n\r\nMarkdown 使用星号（`*`）和底线（`_`）作为标记强调字词的符号，被 `*` 或 `_` 包围的字词会被转成用 `<em>` 标签包围，用两个 `*` 或 `_` 包起来的话，则会被转成 `<strong>`，例如：\r\n\r\n    *single asterisks*\r\n\r\n    _single underscores_\r\n\r\n    **double asterisks**\r\n\r\n    __double underscores__\r\n\r\n会转成：\r\n\r\n    <em>single asterisks</em>\r\n\r\n    <em>single underscores</em>\r\n\r\n    <strong>double asterisks</strong>\r\n\r\n    <strong>double underscores</strong>\r\n\r\n你可以随便用你喜欢的样式，唯一的限制是，你用什么符号开启标签，就要用什么符号结束。\r\n\r\n强调也可以直接插在文字中间：\r\n\r\n    un*frigging*believable\r\n\r\n但是**如果你的 `*` 和 `_` 两边都有空白的话，它们就只会被当成普通的符号**。\r\n\r\n如果要在文字前后直接插入普通的星号或底线，你可以用反斜线：\r\n\r\n    \\*this text is surrounded by literal asterisks\\*\r\n\r\n<h3 id=\"code\">代码</h3>\r\n\r\n如果要标记一小段行内代码，你可以用反引号把它包起来（`` ` ``），例如：\r\n\r\n    Use the `printf()` function.\r\n\r\n会产生：\r\n\r\n    <p>Use the <code>printf()</code> function.</p>\r\n\r\n如果要在代码区段内插入反引号，你可以用多个反引号来开启和结束代码区段：\r\n\r\n    ``There is a literal backtick (`) here.``\r\n\r\n这段语法会产生：\r\n\r\n    <p><code>There is a literal backtick (`) here.</code></p>\r\n\r\n代码区段的起始和结束端都可以放入一个空白，起始端后面一个，结束端前面一个，这样你就可以在区段的一开始就插入反引号：\r\n\r\n	A single backtick in a code span: `` ` ``\r\n	\r\n	A backtick-delimited string in a code span: `` `foo` ``\r\n\r\n会产生：\r\n\r\n	<p>A single backtick in a code span: <code>`</code></p>\r\n	\r\n	<p>A backtick-delimited string in a code span: <code>`foo`</code></p>\r\n\r\n在代码区段内，`&` 和方括号**都**会被自动地转成 HTML 实体，这使得插入 HTML 原始码变得很容易，Markdown 会把下面这段：\r\n\r\n    Please don\'t use any `<blink>` tags.\r\n\r\n转为：\r\n\r\n    <p>Please don\'t use any <code>&lt;blink&gt;</code> tags.</p>\r\n\r\n你也可以这样写：\r\n\r\n    `&#8212;` is the decimal-encoded equivalent of `&mdash;`.\r\n\r\n以产生：\r\n\r\n    <p><code>&amp;#8212;</code> is the decimal-encoded\r\n    equivalent of <code>&amp;mdash;</code>.</p>\r\n\r\n\r\n\r\n<h3 id=\"img\">图片</h3>\r\n\r\n很明显地，要在纯文字应用中设计一个「自然」的语法来插入图片是有一定难度的。\r\n\r\nMarkdown 使用一种和链接很相似的语法来标记图片，同样也允许两种样式： *行内式*和*参考式*。\r\n\r\n行内式的图片语法看起来像是：\r\n\r\n    ![Alt text](/path/to/img.jpg)\r\n\r\n    ![Alt text](/path/to/img.jpg \"Optional title\")\r\n\r\n详细叙述如下：\r\n\r\n*   一个惊叹号 `!`\r\n*   接着一个方括号，里面放上图片的替代文字\r\n*   接着一个普通括号，里面放上图片的网址，最后还可以用引号包住并加上\r\n    选择性的 \'title\' 文字。\r\n\r\n参考式的图片语法则长得像这样：\r\n\r\n    ![Alt text][id]\r\n\r\n「id」是图片参考的名称，图片参考的定义方式则和连结参考一样：\r\n\r\n    [id]: url/to/image  \"Optional title attribute\"\r\n\r\n到目前为止， Markdown 还没有办法指定图片的宽高，如果你需要的话，你可以使用普通的 `<img>` 标签。\r\n\r\n* * *\r\n\r\n<h2 id=\"misc\">其它</h2>\r\n\r\n<h3 id=\"autolink\">自动链接</h3>\r\n\r\nMarkdown 支持以比较简短的自动链接形式来处理网址和电子邮件信箱，只要是用方括号包起来， Markdown 就会自动把它转成链接。一般网址的链接文字就和链接地址一样，例如：\r\n\r\n    <http://example.com/>\r\n\r\nMarkdown 会转为：\r\n\r\n    <a href=\"http://example.com/\">http://example.com/</a>\r\n\r\n邮址的自动链接也很类似，只是 Markdown 会先做一个编码转换的过程，把文字字符转成 16 进位码的 HTML 实体，这样的格式可以糊弄一些不好的邮址收集机器人，例如：\r\n\r\n    <address@example.com>\r\n\r\nMarkdown 会转成：\r\n\r\n    <a href=\"&#x6D;&#x61;i&#x6C;&#x74;&#x6F;:&#x61;&#x64;&#x64;&#x72;&#x65;\r\n    &#115;&#115;&#64;&#101;&#120;&#x61;&#109;&#x70;&#x6C;e&#x2E;&#99;&#111;\r\n    &#109;\">&#x61;&#x64;&#x64;&#x72;&#x65;&#115;&#115;&#64;&#101;&#120;&#x61;\r\n    &#109;&#x70;&#x6C;e&#x2E;&#99;&#111;&#109;</a>\r\n\r\n在浏览器里面，这段字串（其实是 `<a href=\"mailto:address@example.com\">address@example.com</a>`）会变成一个可以点击的「address@example.com」链接。\r\n\r\n（这种作法虽然可以糊弄不少的机器人，但并不能全部挡下来，不过总比什么都不做好些。不管怎样，公开你的信箱终究会引来广告信件的。）\r\n\r\n<h3 id=\"backslash\">反斜杠</h3>\r\n\r\nMarkdown 可以利用反斜杠来插入一些在语法中有其它意义的符号，例如：如果你想要用星号加在文字旁边的方式来做出强调效果（但不用 `<em>` 标签），你可以在星号的前面加上反斜杠：\r\n\r\n    \\*literal asterisks\\*\r\n\r\nMarkdown 支持以下这些符号前面加上反斜杠来帮助插入普通的符号：\r\n\r\n    \\   反斜线\r\n    `   反引号\r\n    *   星号\r\n    _   底线\r\n    {}  花括号\r\n    []  方括号\r\n    ()  括弧\r\n    #   井字号\r\n    +   加号\r\n    -   减号\r\n    .   英文句点\r\n    !   惊叹号\r\n\r\n<h2 id=\"acknowledgement\">感谢</h2>\r\n\r\n感谢 [leafy7382][] 协助翻译，[hlb][]、[Randylien][] 帮忙润稿，[ethantw][] 的[汉字标准格式・CSS Reset][]， [WM][] 回报文字错误。\r\n\r\n[leafy7382]:https://twitter.com/#!/leafy7382\r\n[hlb]:http://iamhlb.com/\r\n[Randylien]:http://twitter.com/randylien\r\n[ethantw]:https://twitter.com/#!/ethantw\r\n[汉字标准格式・CSS Reset]:http://ethantw.net/projects/han/\r\n[WM]:http://kidwm.net/\r\n\r\n感谢 [fenprace][]，[addv][]。\r\n\r\n[fenprace]:https://github.com/fenprace\r\n[addv]:https://github.com/addv\r\n\r\n----------\r\n<h2 id=\"editor\">Markdown 免费编辑器</h2>\r\n\r\nWindows 平台\r\n\r\n* [MarkdownPad](http://markdownpad.com/)\r\n* [MarkPad](http://code52.org/DownmarkerWPF/)\r\n\r\nLinux 平台\r\n\r\n* [ReText](http://sourceforge.net/p/retext/home/ReText/)\r\n\r\nMac 平台\r\n\r\n* [Mou](http://mouapp.com/)\r\n\r\n在线编辑器\r\n\r\n* [Markable.in](http://markable.in/)\r\n* [Dillinger.io](http://dillinger.io/)\r\n\r\n浏览器插件\r\n\r\n* [MaDe](https://chrome.google.com/webstore/detail/oknndfeeopgpibecfjljjfanledpbkog) (Chrome)\r\n\r\n高级应用\r\n\r\n* [Sublime Text 2](http://www.sublimetext.com/2) + [MarkdownEditing](http://ttscoff.github.com/MarkdownEditing/) / [教程](http://lucifr.com/2012/07/12/markdownediting-for-sublime-text-2/)', '501', '4', '4', '1', '2016-10-16 14:50:22', '2016-10-16 22:51:30');
INSERT INTO `topics` VALUES ('7', '使用 GDB 调试程序', 'GDB是UNIX下面的程序调试工具, 可以调试多种类型程序, 主要可以完成以下四个功能:\r\n\r\n1. 启动你的程序，可以按照你的自定义的要求随心所欲的运行程序。 \r\n2. 可让被调试的程序在指定的调置的断点处停住。（断点可以是条件表达式）\r\n3. 当程序被停住时，可以检查此时程序中所发生的事。\r\n4. 动态的改变程序的执行环境。\r\n\r\n# 简单的调试例子\r\n\r\n测试程序如下：\r\n\r\n    #include <stdio.h>\r\n    int func(int n)\r\n    {\r\n        int sum=0,i;\r\n        for(i=0; i<n; i++)\r\n        {\r\n            sum+=i;\r\n        }\r\n        return sum;\r\n    }\r\n    void main()\r\n    {\r\n        int i; long result = 0;\r\n        for(i=1; i<=100; i++)\r\n        {\r\n            result += i;\r\n        }\r\n        printf(“result[1-100] = %d \\n”, result );\r\n        printf(“result[1-250] = %d \\n”, func(250) );\r\n    }\r\n\r\n编译生成执行文件（要调试C/C++的程序，在编译时必须要把调试信息加到可执行文件中：-g 选项）：\r\n\r\n    gcc -g C++_GDB_test.cpp -o C++_GDB_test.o\r\n\r\n一个简单的调试过程如下：\r\n\r\n    $ gdb C++_GDB_test.o\r\n    GNU gdb (GDB) 7.10.1\r\n    ......\r\n    done.\r\n    (gdb) l                    ----> l(list), 列出源码\r\n    6	*/\r\n    7\r\n    8	#include <stdio.h>\r\n    9	int func(int n)\r\n    10	{\r\n    11	    int sum=0,i;\r\n    12	    for(i=0; i<n; i++)\r\n    13	    {\r\n    14	        sum+=i;\r\n    15	    }\r\n    (gdb)                      ----> 直接回车表示重复上一次命令\r\n    16	    return sum;\r\n    17	}\r\n    18	int main()\r\n    19	{\r\n    20	    int i; long result = 0;\r\n    21	    for(i=1; i<=100; i++)\r\n    22	    {\r\n    23	        result += i;\r\n    24	    }\r\n    25	    printf(\"result[1-100] = %ld\\n\", result );\r\n    (gdb)\r\n    26	    printf(\"result[1-250] = %d\\n\", func(250));\r\n    27	}\r\n    (gdb) br 20                 ----> 设置断点，在源程序 20 行处\r\n    Breakpoint 1 at 0x100000edf: file C++_GDB_test.cpp, line 20.\r\n    (gdb) br func               ----> 设置断点，在函数func()入口处\r\n    Breakpoint 2 at 0x100000e97: file C++_GDB_test.cpp, line 11.\r\n    (gdb) info br               ----> 查看断点信息\r\n    Num     Type           Disp Enb Address            What\r\n    1       breakpoint     keep y   0x0000000100000edf in main() at C++_GDB_test.cpp:20\r\n    2       breakpoint     keep y   0x0000000100000e97 in func(int) at C++_GDB_test.cpp:11\r\n    (gdb) r                     ----> r(run) 运行程序\r\n    Starting program: .../C++_Code/C++_GDB_test.o\r\n    Breakpoint 1, main () at C++_GDB_test.cpp:20  ----> 在断点处停住\r\n    20	    int i; long result = 0;\r\n    (gdb) n                     ----> n(next)单条语句执行\r\n    21	    for(i=1; i<=100; i++)\r\n    (gdb) n\r\n    23	        result += i;\r\n    (gdb) n\r\n    21	    for(i=1; i<=100; i++)\r\n    (gdb) c                     ----> c(continue)继续运行程序到下一个断点\r\n    Continuing.\r\n    result[1-100] = 5050        ----> 程序输出\r\n    \r\n    Breakpoint 2, func (n=250) at C++_GDB_test.cpp:11\r\n    11	    int sum=0,i;\r\n    (gdb) n\r\n    12	    for(i=0; i<n; i++)\r\n    (gdb) br 14 if i==50        ----> 设置条件断点\r\n    Breakpoint 3 at 0x100000eb1: file C++_GDB_test.cpp, line 14.\r\n    (gdb) c\r\n    Continuing.\r\n    \r\n    Breakpoint 3, func (n=250) at C++_GDB_test.cpp:14\r\n    14	        sum+=i;\r\n    (gdb) p i                   ----> p(print): 打印变量i的值\r\n    $1 = 50\r\n    (gdb) p sum                 ----> p: 打印变量sum的值\r\n    $2 = 1225\r\n    (gdb) bt                    ----> 查看函数堆栈\r\n    #0  func (n=250) at C++_GDB_test.cpp:14\r\n    #1  0x0000000100000f36 in main () at C++_GDB_test.cpp:26\r\n    (gdb) finish                ----> 退出函数\r\n    Run till exit from #0  func (n=250) at C++_GDB_test.cpp:14\r\n    0x0000000100000f36 in main () at C++_GDB_test.cpp:26\r\n    26	    printf(\"result[1-250] = %d\\n\", func(250));\r\n    Value returned is $6 = 31125\r\n    (gdb) c\r\n    Continuing.\r\n    result[1-250] = 31125\r\n    [Inferior 1 (process 8845) exited normally]   ----> 程序退出，调试结束 \r\n    (gdb) q \r\n\r\n# core dump 调试\r\n\r\n当程序异常退出时，操作系统把程序当前的内存状况存储在一个core文件中，该文件包含了程序运行时的内存，寄存器状态，堆栈指针，内存管理信息还有各种函数调用堆栈信息等。通过分析这个文件，我们可以定位到程序异常退出的时候对应的堆栈调用等信息，找出问题所在并进行及时解决。\r\n\r\n首先要确定当前会话的 ulimit –c，若为0，则不会产生对应的coredump，需要进行修改和设置，`ulimit –c [size]`（注意，这里的size如果太小，则可能不会产生对应的core文件）。\r\n\r\n```\r\nulimit  -c unlimited  (可以产生core dump 且不受大小限制)\r\n```\r\n\r\ncore文件默认的存储位置为当前进程的工作目录（一般就是可执行文件所在的目录）。当程序出现段错误（试图访问或者修改不属于自己的内存地址时）时，就会产生 core dump，方便我们进行调试。下面是一些常见的段错误：\r\n\r\n* 内存访问越界：由于使用错误的下标，导致数组访问越界。\r\n* 非法指针访问：比如写 nullptr\r\n* 栈溢出：使用了大的局部变量\r\n\r\n下面是个简单的例子：\r\n\r\n```c++\r\n#include <iostream>\r\nusing namespace std;\r\n\r\nvoid test(){\r\n    int *p = nullptr;\r\n    *p = 1;             // Segment Fault\r\n}\r\nint main() {\r\n    test();\r\n    return 0;\r\n}\r\n```\r\n\r\n然后编译运行程序，用 GDB 查看其产生的 Core Dump 文件：\r\n\r\n```bash\r\n$ g++ -g demo.cpp -o demo.o -std=c++11\r\n$ ulimit -c\r\n0\r\n$ ulimit -c unlimited\r\n$ ./demo.o\r\n[1]    15193 segmentation fault (core dumped)  ./demo.o\r\n$ ~ ls\r\ncore  demo.cpp  demo.o\r\n➜  ~ gdb demo.o core\r\nGNU gdb (Ubuntu 7.7.1-0ubuntu5~14.04.2) 7.7.1\r\nCopyright (C) 2014 Free Software Foundation, Inc.\r\n......\r\nCore was generated by \'./demo.o\'.\r\nProgram terminated with signal SIGSEGV, Segmentation fault.\r\n#0  0x00000000004006dd in test () at demo.cpp:6\r\n6	    *p = 1;\r\n(gdb) bt\r\n#0  0x00000000004006dd in test () at demo.cpp:6\r\n#1  0x00000000004006ee in main () at demo.cpp:9\r\n```\r\n\r\n# 调试参数\r\n\r\ngdb调试中需要用到的命令\r\n\r\n* file [filename]：装入想要调试的可执行文件\r\n* kill [filename]：终止正在调试的程序\r\n* break [file:]function：在(file文件的)function函数中设置一个断点\r\n* clear：删除一个断点，这个命令需要指定代码行或者函数名作为参数\r\n* run [arglist]：运行您的程序 (如果指定了arglist,则将arglist作为参数运行程序)\r\n* bt Backtrace：显示程序堆栈信息\r\n* `x`：查看内存\r\n* print expr：打印表达式的值\r\n* continue：继续运行您的程序 (在停止之后，比如在一个断点之后)\r\n* list：列出产生执行文件的源代码的一部分\r\n* next：单步执行 (在停止之后); 跳过函数调用（与step相对应，step会进入函数内部）\r\n* set：设置变量的值。例如：set nval=54 将把54保存到nval变量中；设置输入参数也可以通过这个命令(例如当三个入参分别为a、b、c的话，set args a b c)\r\n* watch：使你能监视一个变量的值而不管它何时被改变\r\n* finish：继续执行，直到当前函数返回\r\n* ignore：忽略某个断点制定的次数。例：ignore 4 23 忽略断点4的23次运行，在第24次的时候中断\r\n* info [name]：查看name信息\r\n* xbreak：在当前函数的退出的点上设置一个断点\r\n* whatis：显示变量的值和类型\r\n* ptype：显示变量的类型\r\n* shell：使你能不离开 gdb 就执行 UNIX shell 命令\r\n* help [name]：显示GDB命令的信息，或者显示如何使用GDB的总体信息\r\n* quit：退出gdb.\r\n  \r\n`命令行参数`\r\n\r\n有时候，我们需要调试的程序需要有命令行参数，可以通过下面两种方式设置调试的程序的命令行参数：\r\n\r\n* gdb命令行的 –args 参数\r\n* gdb环境中 set args命令。\r\n\r\n# 高级的用法\r\n\r\n比如为了搞清楚柔性数组的内存分布特征，我们可以用下面的程序来验证：\r\n\r\n    #include <stdlib.h>\r\n    #include <string.h>\r\n    \r\n    struct line {\r\n       int length;\r\n       char contents[0]; // C99：char contents[]; 没有指定数组长度\r\n    };\r\n    \r\n    int main(){\r\n        int this_length=10;\r\n        struct line *thisline = (struct line *)\r\n                         malloc (sizeof (struct line) + this_length);\r\n        thisline->length = this_length;\r\n        memset(thisline->contents, \'a\', this_length);\r\n        return 0;\r\n    }\r\n\r\n然后用下面的调试过程来理解柔性数组的内存分布：\r\n\r\n![][1]\r\n\r\n# 参考\r\n\r\n[使用gdb调试程序详解](http://www.vimer.cn/2009/11/使用gdb调试程序详解.html)  \r\n[GDB中应该知道的几个调试方法](http://coolshell.cn/articles/3643.html)  \r\n[Codesign gdb on Mac OS X Yosemite](http://andresabino.com/2015/04/14/codesign-gdb-on-mac-os-x-yosemite-10-10-2/)  \r\n[详解 coredump](http://blog.csdn.net/tenfyguo/article/details/8159176)  \r\n[C++编译器无法捕捉到的8种错误](http://blog.jobbole.com/15837/)  \r\n[What is a segmentation fault?](http://stackoverflow.com/questions/2346806/what-is-a-segmentation-fault)  \r\n\r\n[1]: http://7xrlu9.com1.z0.glb.clouddn.com/C++_GDB_Debug_1.png\r\n\r\n\r\n', '517', '0', '1', '1', '2016-10-16 15:12:15', '2016-10-16 23:12:15');
INSERT INTO `topics` VALUES ('8', '并行运算课程', '并行计算是相对于串行计算而言，比如一个矩阵相乘的例子，下面给出串行程序的代码\r\n\r\n    void matrixMultiplication(int a[][SIZE], int b[][SIZE])\r\n    {\r\n        int i,j,k;\r\n        for(i = 0; i < c_row; i++) \r\n        {\r\n            for(j = 0; j < c_col; j++) \r\n            {\r\n                for(k = 0; k < a_col; k++) \r\n                {\r\n                    c[i][j] += a[i][k] * b[k][j];\r\n                }\r\n            }\r\n        }\r\n    }\r\n\r\n在上面的程序中，程序编译运行之后以一个进程（注意区分进程和线程这两个概念）的方式是按照for循环迭代顺序执行。那怎么并行矩阵相乘的代码呢？这里需要使用高级语言级别的并行库，常见的并行库有opemp，pthread，MPI，CUDA等，这些并行库一般都支持C/C++，程序员可以直接调用并行库的函数而不需要实现底层的CPU多核调用。下面给出opemmp版本的矩阵相乘程序。\r\n\r\n    void matrixMultiplication(int a[][SIZE], int b[][SIZE])\r\n    {\r\n        int i,j,k;\r\n        #pragma omp parallel shared(a,b,c) private(i,j,k)  \r\n        {  \r\n             #pragma omp for schedule(dynamic)  \r\n             for(i = 0; i < c_row; i++) \r\n             {\r\n                for(j = 0; j < c_col; j++) \r\n                {\r\n                    for(k = 0; k < a_col; k++) \r\n                    {\r\n                        c[i][j] += a[i][k] * b[k][j];\r\n                    }\r\n                }\r\n            }\r\n        }\r\n    }\r\n\r\nopemmp在没有改动原本代码的基础上实现了矩阵相乘的并行化，实现的办法仅仅是添加了两条openmp编译制导语句，在程序运行到并行代码时，程序的主线程会启动多线程把任务分成n份（n=CPU核心数)，然后在多核心上同时计算，最后主线程得到结果。当然除了多线程，程序也可以启动多进程进行并行计算，关于多进程，Linux下的fork()想必很多人都有了解，而mpich是目前很流行的多进程消息传递库。并行化看起来很简单不是么，但是，要设计高效能解决复杂问题的并行程序可不那么容易。\r\n', '560', '2', '6', '4', '2016-10-17 06:18:55', '2016-10-18 16:19:45');
INSERT INTO `topics` VALUES ('9', 'test', '测试', '201', '1', '2', '7', '2016-11-07 10:43:47', '2016-11-07 18:43:47');
INSERT INTO `topics` VALUES ('10', '新的话题', '新的话题测试', '504', '0', '15', '1', '2016-11-08 02:39:50', '2016-11-08 10:39:50');
INSERT INTO `topics` VALUES ('12', '支持 Latex 公式的插入', '现在支持 Latex 公式。\r\n\r\n行内公式用 `\\(` 和 `\\)` 包裹，行间公式用 `\\[` 和 `\\]` 包裹。\r\n\r\n# 具体例子\r\n\r\nLet\'s first define a few variables that we will need to use:\r\n\r\n* L = total number of layers in the network\r\n* \\(s_l\\) = number of units (not counting bias unit) in layer l\r\n* K = number of output units/classes\r\n\r\nRecall that in neural networks, we may have many output nodes. We denote \\(h_{\\Theta}(x)_k\\) as being a hypothesis that results in the \\(k^{th}\\) output. Our cost function for neural networks is going to be a generalization of the one we used for logistic regression. Recall that the cost function for regularized logistic regression was\r\n\r\n\\[J(\\theta) = - \\frac{1}{m} \\sum_{i=1}^m [ y^{(i)}\\ \\log (h_\\theta (x^{(i)})) + (1 - y^{(i)})\\ \\log (1 - h_\\theta(x^{(i)}))] + \\frac{\\lambda}{2m}\\sum_{j=1}^n \\theta_j^2\\]\r\n\r\nFor neural networks, it is going to be slightly more complicated:\r\n\r\n\\[\\begin{gather*} J(\\Theta) = - \\frac{1}{m} \\sum_{i=1}^m \\sum_{k=1}^K \\left[y^{(i)}_k \\log ((h_\\Theta (x^{(i)}))_k) + (1 - y^{(i)}_k)\\log (1 - (h_\\Theta(x^{(i)}))_k)\\right] + \\frac{\\lambda}{2m}\\sum_{l=1}^{L-1} \\sum_{i=1}^{s_l} \\sum_{j=1}^{s_{l+1}} ( \\Theta_{j,i}^{(l)})^2\\end{gather*}\\]\r\n', '411', '2', '4', '1', '2017-01-09 14:20:51', '2017-01-09 14:20:51');

-- ----------------------------
-- Table structure for `users`
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(128) NOT NULL,
  `password_hash` varchar(128) NOT NULL,
  `email` varchar(128) NOT NULL,
  `name` varchar(128) NOT NULL,
  `gender` tinyint(1) NOT NULL,
  `phone` varchar(128) NOT NULL,
  `university` varchar(128) NOT NULL,
  `student_id` varchar(64) DEFAULT '0',
  `student_type` int(11) DEFAULT '-1',
  `is_password_reset_link_valid` tinyint(1) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `date_joined` datetime DEFAULT NULL,
  `website` varchar(128) DEFAULT NULL,
  `avatar_url` varchar(128) DEFAULT NULL,
  `permissions` int(11) NOT NULL,
  `personal_profile` text,
  `topicNum` int(11) NOT NULL,
  `postNum` int(11) NOT NULL,
  `commentNum` int(11) NOT NULL,
  `open_id` varchar(64) DEFAULT NULL,
  `experience` int(11) DEFAULT '0',
  `is_verify_email` tinyint(1) DEFAULT NULL,
  `verify_email_time` datetime DEFAULT NULL,
  `last_longitude` float DEFAULT NULL,
  `last_latitude` float DEFAULT NULL,
  `city_name` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_users_email` (`email`),
  UNIQUE KEY `ix_users_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('1', 'root', 'pbkdf2:sha1:1000$xBnOyGu0$2265b81c262f0438d80348748b24db1f66a65425', '1291023320@qq.com', 'name', '1', '13800138000', 'university', '0', '-1', '1', '2017-03-24 09:24:17', '2016-09-29 03:14:30', '', '1.png?t=1475844478.0', '1', '知其然，知其所以然。知识广度是深度的副产品！', '6', '1', '3', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('2', 'test', 'pbkdf2:sha1:1000$JZE0rscV$a7b07ad8602a608e76dc583142b1aaf2c378c55b', '1@qq.com', 'name', '1', '13800138000', 'university', '0', '-1', '0', '2017-01-04 14:13:35', '2016-09-29 03:35:29', null, 'none.jpg', '1', '好好学习，天天向上', '0', '0', '1', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('3', 'teacher', 'pbkdf2:sha1:1000$ZRqJzJuR$ec4e50db6eb3eaae92e7cb8bd9468fd2743c3505', 'teacher@qq.com', '张三丰', '0', '13800138000', '中山大学', '150101102', '-1', '0', '2017-07-20 10:20:36', '2016-09-29 03:36:08', 'http://sdcs.sysu.edu.cn', '3.png?t=1489327909.05', '2', '混吃等死不舒服', '0', '4', '6', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('4', 'abc', 'pbkdf2:sha1:1000$Z0hb47ZO$8cc84309e6a696c6deb28d6ebb910fa828d16e3d', '3@qq.com', 'name', '1', '13800138000', 'university', '0', '-1', '0', '2016-10-23 10:40:03', '2016-10-17 03:00:38', null, 'none.jpg', '1', null, '1', '2', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('5', 'admin', 'pbkdf2:sha1:1000$h9IWWCJh$78e5c725ab15124732c7b19dbe43775df4e823e1', 'admin@qq.com', 'name', '1', '13800138000', 'university', '0', '-1', '0', '2017-03-23 15:23:28', '2016-10-22 11:41:15', null, 'none.jpg', '0', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('6', 'wudi', 'pbkdf2:sha1:1000$6eg5KT1A$36731eb6b025347439f6f333050fa727f7d74d94', 'wudi27@mail.sysu.edu.cn', '吴迪测试2', '0', '13800138000', '中山大学', '14312412', '-1', '0', '2017-03-22 23:09:29', '2016-10-18 02:57:55', 'netlab.sysu.edu.cn', '6.png?t=1490195402.92', '2', null, '1', '1', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('7', 'yongyi_yang', 'pbkdf2:sha1:1000$qeUp02pL$088fe9b296a054b622d5b3826045d9c7dbd28e9c', '18826073128@163.com', 'name', '1', '13800138000', 'university', '0', '-1', '0', '2016-12-15 12:03:44', '2016-10-18 15:03:29', null, 'none.jpg', '1', null, '2', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('8', 'alexhanbing', 'pbkdf2:sha1:1000$MsiV0RcE$b9d0794fd92ce0f1d6c3432f4a68614ec60294ca', '565613352@qq.com', 'name', '1', '13800138000', 'university', '0', '-1', '0', '2016-10-21 14:18:52', '2016-10-21 14:18:52', null, null, '1', null, '0', '3', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('9', 'forest80', 'pbkdf2:sha1:1000$34jYf26A$3f6f628bd4e48ed8492219171920e9d498d5023b', 'forest80@163.com', 'name', '1', '13800138000', 'university', '0', '-1', '1', '2016-12-05 14:04:15', '2016-12-05 14:04:15', null, 'none.jpg', '1', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('10', 'Zouzhp', 'pbkdf2:sha1:1000$fzjFGAmb$30667cca608819c147c04d5a49671989dd66cefd', '503951764@qq.com', 'name', '1', '13800138000', 'university', '0', '-1', '1', '2017-03-16 10:29:13', '2016-12-12 10:22:07', null, '10.png?t=1481509362.88', '1', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('11', 'test1', 'pbkdf2:sha1:1000$3fdjJ0du$b93a90b23e1365bd53962cf7339ff69d7c6e0423', 'test@163.com', 'name', '1', '13800138000', 'university', '0', '-1', '1', '2016-12-15 12:15:14', '2016-12-15 12:15:14', null, 'none.jpg', '1', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('12', 'test_nscc', 'pbkdf2:sha1:1000$ANtf20qe$a3f467c203a80abde2b126307f04af5affb50164', 'lijianggs@126.com', 'name', '1', '13800138000', 'university', '0', '-1', '1', '2017-03-12 21:06:06', '2017-01-03 15:14:08', null, 'none.jpg', '1', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('13', '111', 'pbkdf2:sha1:1000$DaD5XWyO$c00d0caab874bac4e3ef1328bdcfc0408a5974b9', '1970025901@qq.com', 'name', '1', '13800138000', 'university', '0', '-1', '1', '2017-03-21 16:32:50', '2017-01-09 18:47:36', null, 'none.jpg', '1', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('14', '233', 'pbkdf2:sha1:1000$OdRDanMv$0def1b35ce8cb669df1034d4a2c2bb1d057bbae6', '50395@qq.com', 'name', '1', '13800138000', 'university', '0', '-1', '1', '2017-01-14 21:42:28', '2017-01-14 21:42:28', null, 'none.jpg', '1', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('15', 'dwu', 'pbkdf2:sha1:1000$99UY1dEj$fe3e2848ca6be8d45783b7d2047ad83a1d38d9c8', 'wudi.cuhk@foxmail.com', 'name', '1', '13800138000', 'university', '0', '-1', '0', '2017-03-25 22:07:05', '2017-03-05 12:22:41', null, '15.png?t=1490194462.8', '2', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');
INSERT INTO `users` VALUES ('16', 'hpc', 'pbkdf2:sha1:1000$AsXJJ16h$52545c65a85e4b4b1e2010ca0223bd7ebbe4d87d', 'hpc@qq.com', 'hpc', '1', '0', '0', '0', '-1', '1', '2017-05-31 05:12:37', '2017-05-16 07:14:30', null, 'none.jpg', '3', null, '0', '0', '0', null, '0', '1', null, '113.28', '23.12', '广州');

-- ----------------------------
-- Table structure for `vnc_knowledge`
-- ----------------------------
DROP TABLE IF EXISTS `vnc_knowledge`;
CREATE TABLE `vnc_knowledge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(1024) NOT NULL,
  `about` text NOT NULL,
  `cover_url` varchar(512) DEFAULT NULL,
  `teacher_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `vnc_knowledge_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of vnc_knowledge
-- ----------------------------
INSERT INTO `vnc_knowledge` VALUES ('1', '配置实验1', '此乃配置实验1', 'upload/vnc_lab/default.png', '3');
INSERT INTO `vnc_knowledge` VALUES ('2', '配置实验2', '此乃配置实验2', 'upload/vnc_lab/default.png', '3');
INSERT INTO `vnc_knowledge` VALUES ('3', '配置实验3', '此乃配置实验3', 'upload/vnc_lab/default.png', '3');
INSERT INTO `vnc_knowledge` VALUES ('4', '配置实验4', '此乃配置实验4', 'upload/vnc_lab/default.png', '3');

-- ----------------------------
-- Table structure for `vnc_progresses`
-- ----------------------------
DROP TABLE IF EXISTS `vnc_progresses`;
CREATE TABLE `vnc_progresses` (
  `user_id` int(11) NOT NULL,
  `vnc_knowledge_id` int(11) NOT NULL,
  `have_done` int(11) DEFAULT '0',
  `update_time` datetime NOT NULL,
  PRIMARY KEY (`user_id`,`vnc_knowledge_id`),
  KEY `vnc_knowledge_id` (`vnc_knowledge_id`),
  CONSTRAINT `vnc_progresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `vnc_progresses_ibfk_2` FOREIGN KEY (`vnc_knowledge_id`) REFERENCES `vnc_knowledge` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of vnc_progresses
-- ----------------------------
INSERT INTO `vnc_progresses` VALUES ('3', '1', '1', '2017-03-23 09:22:38');

-- ----------------------------
-- Table structure for `vnc_tasks`
-- ----------------------------
DROP TABLE IF EXISTS `vnc_tasks`;
CREATE TABLE `vnc_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(1024) NOT NULL,
  `content` text NOT NULL,
  `vnc_knowledge_id` int(11) DEFAULT NULL,
  `vnc_task_num` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `vnc_knowledge_id` (`vnc_knowledge_id`),
  CONSTRAINT `vnc_tasks_ibfk_1` FOREIGN KEY (`vnc_knowledge_id`) REFERENCES `vnc_knowledge` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of vnc_tasks
-- ----------------------------
INSERT INTO `vnc_tasks` VALUES ('1', '第一个小任务', '# markdown内容1', '1', '1');
INSERT INTO `vnc_tasks` VALUES ('2', '第二个小任务', '# markdown内容2', '1', '2');
INSERT INTO `vnc_tasks` VALUES ('3', '第三个小任务', '# markdown内容3', '1', '3');
INSERT INTO `vnc_tasks` VALUES ('4', '第四个小任务', '# markdown内容4', '1', '4');
DROP TRIGGER IF EXISTS `create_new_image`;
DELIMITER ;;
CREATE TRIGGER `create_new_image` BEFORE INSERT ON `docker_images` FOR EACH ROW BEGIN
    DECLARE dhid INT(11);
    DECLARE new_port INT(11);

    SET @dhid = (SELECT t1.id FROM (SELECT * from docker_holders) AS t1 WHERE t1.images_count = (SELECT MAX(t2.images_count) FROM (SELECT * from docker_holders) AS t2 WHERE t2.images_count < 10) LIMIT 1);
    UPDATE docker_holders set images_count = images_count + 1 where id = @dhid;

    SET @new_port = (SELECT MAX(port) FROM docker_images WHERE docker_holder_id = @dhid);

    SET NEW.port = IF(ISNULL(@dhid), 0, 1 + IF(ISNULL(@new_port), 5900, @new_port));
    SET NEW.docker_holder_id = IF(ISNULL(@dhid), NULL, @dhid);
  END
;;
DELIMITER ;
