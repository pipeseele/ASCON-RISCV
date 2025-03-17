(https://github.com/user-attachments/assets/4dfcd742-aeb0-4f5f-8df9-1d85a694040f)# ASCON-RISCV
基于RISC-V-FPGA的ASCON加密核心 ASCON Encryption Core Based on RISC-V-FPGA
# ASCON加密算法的RISC-V硬件实现

1. ASCON加密协议的介绍可从以下两篇帖子内详细了解:
   https://zhuanlan.zhihu.com/p/576265874
   https://lmzyoyo.top/archives/asconencryption

2. Verilog实现
   2.1 核心设计总览
       Ascon核心设计主要包括以下组件:
       a) 输入密钥非作废和数据处理:
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
          sdf
       b) IVS (Initialization):
          sdf
       c) PERM (Permutation):
          sdf
       d) ARK (Add round constant):
          sdf
       e) SUBST (Substitution):
          sdf
       f) DIFF (Diffusion):
          sdf
       g) AKL (Add key lower):
          sdf
       h) WAIT (Wait):
          sdf
       i) AKU (Add key upper):
          sdf
       j) XOR1 (XOR with 1):
          sdf
       k) TAG (Generate tag):
          sdf
       l) WAITF (Waiting finish):
          sdf
