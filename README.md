(https://github.com/user-attachments/assets/4dfcd742-aeb0-4f5f-8df9-1d85a694040f)# ASCON-RISCV
基于RISC-V-FPGA的ASCON加密核心 ASCON Encryption Core Based on RISC-V-FPGA
# ASCON加密算法的RISC-V硬件实现

1. ASCON加密协议的介绍可从以下链接详细了解:
   https://zhuanlan.zhihu.com/p/576265874
   https://lmzyoyo.top/archives/asconencryption
   https://ascon.isec.tugraz.at/files/asconv12-nist.pdf

2. Verilog实现(由'ascon_core.v'与'SubstBlock.v'实现)
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
   
3. Vivado Testbench仿真
   3.1 时钟生成：
       时钟（clk）信号每5个时间单位翻转一次，生成一个周期为10个时间单位的时钟。
   3.2 复位序列：
       复位（rstn）信号在仿真开始时被置位（低电平持续100个时间单位），然后被取消置位以开始正常操作。
   3.3 测试用状态机：
       测试平台使用一个简单的状态机来模拟Ascon核心的不同输入和输出阶段。该状态机控制数据流向Ascon_core模块：
       状态 0：置位开始信号（start），使核心进入初始化状态（IVS）。
       状态 1：请求输入数据（dinReq被置位），并将Din设置为随机数（nonce）值。
       状态 2：等待dinAck信号，表示输入数据已被接受。
       状态 3：将Din设置为最后一块数据（LastData），并置位last_block信号。
       状态 4：再次发出数据请求，将Din设置为最后一块数据（LastData），并置位last_block信号。
       状态 5-8：根据控制信号提供加密或解密的明文/密文。
       状态 9：等待finished信号，表示核心已完成处理，并返回到初始状态。    
   3.4 数据读取：
       测试平台持续监控doReq信号，当该信号被置位时，将输出数据（Dout）捕获到read_data寄存器中。
   3.5 数据读取：
       测试平台持续监控doReq信号，当该信号被置位时，将输出数据（Dout）捕获到read_data寄存器中。
   3.6 资源占用报告：
       切片查找表 切片寄存器 F7多路复用器 F8多路复用器 绑定IOB 全局缓冲控制器
         1096       483          36           18        524         1
   
4. RISC_V FPGA的集成(由'ascon_core_top.v'与'main.c'实现)
   4.1 架构
       RVFPGA中的SoC（System on Chip）名为SweRVolfX，构建在SweRV EH1 Core Comple上，SweRV EH1核心使用AXI总线，而外设则使用Wishbone总线，通过AXI-Wishbone桥接进行互连。
   4.2 设计过程
       a) 创建ascon模块（ascon_core.v），并且独立仿真通过。
       b) 创建一个wrapper模块（ascon_core_top.v），该模块有wishbone 从机接口,并且例化上述独立仿真通过的ascon_core.v模块。
       c) 在swervolf_core.v模块中，实例化上述wrapper，并且修改wb_intercon.vh添加ascon模块的wishbone总线接口。
       d) 给wishbone总线模块添加一些输入输出端口，来适配新增加的ascon外设。
       e) 修改wb_mux的num_slaves、MATCH_ADDR和MATCH_MASK，num_slaves增加1，由7变为8，MATCH_ADDR和MATCH_MASK为ascon外设分配地址，ascon的基地址分配为0x80003000，前面的地址被GPIO等7个外设所占据。
       f) 创建src/SweRVolfSoC/Peripherals/ascon文件夹，并且将ascon相关的文件都放在该文件夹下。
       g) 编写测试的c文件，驱动ascon外设模块，通过读写ascon的寄存器的方式实现。
   4.3 ascon_core_top实现的逻辑：
       hs_top的端口信号定义如下，是标准的wishbone接口。
       module ascon_core_top(
       wb_clk_i, wb_rst_i, wb_cyc_i, wb_adr_i, wb_dat_i, wb_sel_i, wb_we_i, wb_stb_i, wb_dat_o, wb_ack_o, wb_err_o, wb_inta_o）；
       该模块根据ascon.v模块设计了如下寄存器，并且对寄存器分配了偏移地址（此处的寄存器定义和之后c代码读写寄存器的地址相关），寄存器的偏移地址如下表所示：
       /////////////////////////////////////////////////////////////////////////
       寄存器     位宽 地址  读写  含义                                        //
       key        128  0x0   W     key值                                      //
       nonce      128  0x10  W     nonce值                                    //
       Din        128  0x20  W     Din值                                      //
       encrypt    32   0x30  W     1=encrypt, 0=decrypt                       //
       last_block 32   0x34  W     最低位为1表示开始，之后会自动清零           //
       sel_data   32   0x38  W     busy标志位                                 //
       Dout       128  0x3c  R     Dout值                                     //
       start      32   0x4c  W     最低位为1表示开始，之后会自动清零           //
       busy       32   0x50  R     计算完成后置1，读取该寄存器后自动清零       //
       finished   32   0x54  R     往该寄存器卸入任意值均表示Din有效           //
       dinReq     32   0x58  W     之后当dinReq和dinAck握手成功后才会释放wb总线//
       /////////////////////////////////////////////////////////////////////////
       在该wrapper模块中读写寄存器的逻辑如下面的代码所示，通过判断wishbone总线发送的地址和控制信号，来实现相关寄存器的写入。
       always@(posedge clk or  posedge rst)begin
           if(rst == 1'b1)
               key<='b0;
           else if(wb_adr_i == key_addr && we)
               key[31:0]<=wb_dat_i;
           else if(wb_adr_i == (key_addr + 4) && we)
               key[63:32]<=wb_dat_i;
           else if(wb_adr_i == (key_addr + 8) && we)
               key[95:64]<=wb_dat_i;
           else if(wb_adr_i == (key_addr + 12) && we)
               key[127:96]<=wb_dat_i;
       end
       这些寄存器作为ascon模块的输入信号。
       Ascon模块的输出信号也可以暂存在寄存器中，由c代码驱动wishbone总线进行读取。
   4.4 调试
       C代码通过wishbone总线对ascon外设的寄存器进行读写，逻辑与对ascon模块单独进行操作的testbench的逻辑实现一致。通过宏定义定义两个读取寄存器的函数，READ_HS读取地址为dir的寄存器，WRITE_HS将value写入地址为dir的寄存器中。
       #define READ_HS(dir) (*(volatile unsigned *)dir)
       #define WRITE_HS(dir, value) { (*(volatile unsigned *)dir) = (value); }
       下面通过宏定义定义寄存器的地址。HS_BASE_ADDR定义为0x80003000，不同的寄存器由HS_BASE_ADDR+偏移地址实现，偏移地址在hs_top.v模块内进行了定义。下面代码展示了KEY_ADDR  HS和NONCE_ADDR的计算过程。
       #define HS_BASE_ADDR 0x80003000
       #define KEY_ADDR  HS_BASE_ADDR
       #define NONCE_ADDR (HS_BASE_ADDR + 16)。
       C代码总体执行逻辑如下图所示：
       首先写入key，nonce，din值，之后写入控制信号last_block，sel_data，encrypt，最后写入start信号，并且往0x80003058写入任意值，拉高dinReq信号，注意只有握手成功才会释放总线。之后更新Din值，控制信号，拉高dinReq，这样的步骤重复进行3次。（参考testbench）
       最后读取finished寄存器，直至读取到的finished信号的值为1，表示Dout的值以及计算完成，然后C代码读取Dout的值。


















   
