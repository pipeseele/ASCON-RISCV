

#define READ_HS(dir) (*(volatile unsigned *)dir)
#define WRITE_HS(dir, value) { (*(volatile unsigned *)dir) = (value); }

#define HS_BASE_ADDR 0x80003000
#define KEY_ADDR  HS_BASE_ADDR
#define NONCE_ADDR (HS_BASE_ADDR + 16)
#define DIN_ADDR (HS_BASE_ADDR + 32)
#define ENCR_ADDR (HS_BASE_ADDR + 48)
#define LAST_BLOCK_ADDR (HS_BASE_ADDR + 52)
#define SEL_DATA_ADDR (HS_BASE_ADDR + 56)
#define DOUT_ADDR (HS_BASE_ADDR + 60)
#define START_ADDR (HS_BASE_ADDR + 76)
#define BUSY_ADDR (HS_BASE_ADDR + 80)
#define FINISH_ADDR (HS_BASE_ADDR + 84)
#define DINREQ_ADDR (HS_BASE_ADDR + 88)





int main ( void )
{
    int En_Value=0x00010203;
    WRITE_HS((NONCE_ADDR+12), En_Value);
    En_Value=0x04050607;
    WRITE_HS((NONCE_ADDR+8), En_Value);
    En_Value=0x08090a0b;
    WRITE_HS((NONCE_ADDR+4), En_Value);
    En_Value=0x0c0d0e0f;
    WRITE_HS(NONCE_ADDR, En_Value);

    En_Value=0x00010203;
    WRITE_HS((KEY_ADDR+12), En_Value);
    En_Value=0x04050607;
    WRITE_HS((KEY_ADDR+8), En_Value);
    En_Value=0x08090a0b;
    WRITE_HS((KEY_ADDR+4), En_Value);
    En_Value=0x0c0d0e0f;
    WRITE_HS(KEY_ADDR, En_Value);

    En_Value=0x00010203;
    WRITE_HS((DIN_ADDR+12), En_Value);
    En_Value=0x04050607;
    WRITE_HS((DIN_ADDR+8), En_Value);
    En_Value=0x08090a0b;
    WRITE_HS((DIN_ADDR+4), En_Value);
    En_Value=0x0c0d0e0f;
    WRITE_HS(DIN_ADDR, En_Value);

    En_Value=0x00000000;
    WRITE_HS(LAST_BLOCK_ADDR, En_Value);

    En_Value=0x00000001;
    WRITE_HS(ENCR_ADDR, En_Value);

    En_Value=0x00000000;
    WRITE_HS((SEL_DATA_ADDR), En_Value);

    En_Value=0x00000001;
    WRITE_HS((START_ADDR), En_Value);

    En_Value=0x00000001;
    WRITE_HS((DINREQ_ADDR), En_Value);

    //第二个数据

    En_Value=0x80000000;
    WRITE_HS((DIN_ADDR+12), En_Value);
    En_Value=0x00000000;
    WRITE_HS((DIN_ADDR+8), En_Value);
    En_Value=0x00000000;
    WRITE_HS((DIN_ADDR+4), En_Value);
    En_Value=0x00000000;
    WRITE_HS(DIN_ADDR, En_Value);

    En_Value=0x00000001;
    WRITE_HS((LAST_BLOCK_ADDR), En_Value);

    En_Value=0x00000001;
    WRITE_HS((DINREQ_ADDR), En_Value);

    //第三个数据

    En_Value=0x00000001;
    WRITE_HS((SEL_DATA_ADDR), En_Value);

    En_Value=0x00000000;
    WRITE_HS((LAST_BLOCK_ADDR), En_Value);

    En_Value=0x00010203;
    WRITE_HS((DIN_ADDR+12), En_Value);
    En_Value=0x04050607;
    WRITE_HS((DIN_ADDR+8), En_Value);
    En_Value=0x08090a0b;
    WRITE_HS((DIN_ADDR+4), En_Value);
    En_Value=0x0c0d0e0f;
    WRITE_HS(DIN_ADDR, En_Value);

    En_Value=0x00000001;
    WRITE_HS((DINREQ_ADDR), En_Value);

    //第四个数据

    En_Value=0x00000001;
    WRITE_HS((LAST_BLOCK_ADDR), En_Value);

    En_Value=0x80000000;
    WRITE_HS((DIN_ADDR+12), En_Value);
    En_Value=0x00000000;
    WRITE_HS((DIN_ADDR+8), En_Value);
    En_Value=0x00000000;
    WRITE_HS((DIN_ADDR+4), En_Value);
    En_Value=0x00000000;
    WRITE_HS(DIN_ADDR, En_Value);

    En_Value=0x00000001;
    WRITE_HS((DINREQ_ADDR), En_Value);
    






    return(0);
}

