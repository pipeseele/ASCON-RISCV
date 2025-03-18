(https://github.com/user-attachments/assets/4dfcd742-aeb0-4f5f-8df9-1d85a694040f)# ASCON-RISCV
基于RISC-V-FPGA的ASCON加密核心 ASCON Encryption Core Based on RISC-V-FPGA
# ASCON加密算法的RISC-V硬件实现

1. ASCON加密协议的介绍可从以下两篇帖子内详细了解:
   https://zhuanlan.zhihu.com/p/576265874
   https://lmzyoyo.top/archives/asconencryption

2. Verilog实现(由'ascon_core.v'与'ascon_core.v'实现)
   2.1 核心设计总览
       Ascon核心设计主要包括以下组件:
       a) 输入密钥随机数和数据处理:
          该模块接收一个128位的密钥和一个128位的nonce作为输入，这些通过状态机进行处理，以执行逐块加密/解密操作。
       b) 状态寄存器：
          该设计包括五个64位状态寄存器(So到S4)，用于存储算法的内部状态。
       c) 状态机:
          状态机控制整个加密/解密过程的顺序操作，包括数据加载、置换、异或操作等。它通过一系列状态和子状态进行转换，以管理这些操作。
       d) 置换操作:
          该设计实现了Ascon算法的置换步骤，包括S-Box置换和扩散操作。
       e) 控制信号:
          多个控制信号用于协调模块内的数据输入/输出、状态转换和操作的完成。
   2.2 状态机设计
       状态机定义了正在处理的步骤，在置换中使用了子状态(以及两个计数器:perms”用于计数置换，“count”用于计数替换中的步骤)。还有"next-state"来决定置换后的去向.
       a) IDLE (Idle):
          在IDLE状态中，会发生以下操作:
            .清除状态寄存器:寄存器S0到S4被重置为0。
            .重置busy信号:将busy信号设置为0。
            .等待启动信号:一旦启动信号变高，状态机将从空闲状态转换为初始化向量设置状态。
            .启动操作:在切换到IVS状态时，busy信号设置为1。
       b) IVS (Initialization):
          在IVS状态中，会发生以下操作:
            .预定义常量:状态寄存器S0初始化为一个特定的常量(80800c0800000000)
            .加载密钥和nonce:S1加载了密钥的上64位,S2加载了密钥的低64位,S3加载了随机数的上64位,S4加载了随机数的低64位。
       c) PERM (Permutation):
          在IVS状态中，会发生以下操作:
            .子状态控制:在PERM状态中，控制逻辑通过多个子状态(如ARK,SUBST,DIFF)来执行置换过程的各个步骤。
            .轮数控制:置换操作重复进行多轮(在设计中最多为12轮)。每轮执行上述步骤，逐步打乱内部状态。一旦完成所有要求的轮次，状态机将切换到下一个状态，可能是AKL或另一个相关状态。
       d) ARK (Add round constant):
          在IVS状态中，会发生以下操作:
          将S2的最低位于轮常量异或。
       e) SUBST (Substitution):
          该部分使用wire型变量进行代还操作，伪代码如下：
          // Input: inp (5-bit)
          // Output: opt (5-bit)
          // Step 1: XOR the input with a custom pattern
             x1 = inp ⊕ [inp[3], 0, inp[1], 0, inp[4]]
          // Step 2: Negate x1 and AND with a rotated version of x1
             x2 = !(x1) & [x1[0], x1[4], x1[3], x1[2], x1[1]]
          // Step 3: XOR x1 with a rotated version of x2
             x3 = x1 ⊕ [x2[0], x2[4], x2[3], x2[2], x2[1]]
          // Step 4: XOR x3 with another custom pattern to get the final output
             opt = x3 ⊕ [0, x3[2], 1, x3[0], x3[4]]
          // Return opt as the final output
       f) DIFF (Diffusion):
          该部分为S0到S4五个寄存器的位移异或操作。
       g) AKL (Add key lower):
          该部分S3,S4寄存器与密钥的异或。
       h) WAIT (Wait):
          WAIT状态决定了整个加密解密流程中输入输出数据的去向。
       i) AKU (Add key upper):
          S4,S3和秘钥异或。
       j) XOR1 (XOR with 1):
          S4寄存器和1异或。
       k) TAG (Generate tag):
          生成tag的操作。
       l) WAITF (Waiting finish):
          此状态操作了数据输入和数据输出的控制信号。
   
3. RISC_V FPGA 的集成
