# ======================================================
#               CUSTOM GPU MULTI-SM TEST
# ======================================================
# 
# RESET PC                  : PASS | SM0 | Expected=00000000 Got=00000000
# RESET PC                  : PASS | SM1 | Expected=00000000 Got=00000000
# RESET PC                  : PASS | SM2 | Expected=00000000 Got=00000000
# RESET PC                  : PASS | SM3 | Expected=00000000 Got=00000000
# ADD RESULT                : PASS | SM0 | Expected=0000000f Got=0000000f
# ADD WRITEBACK             : PASS | SM0 | Expected=0000000f Got=0000000f
# ADD WRITE ENABLE          : PASS | SM0 | Expected=1 Got=1
# ADD ZERO                  : PASS | SM0 | Expected=0 Got=0
# ADD RESULT                : PASS | SM1 | Expected=0000000f Got=0000000f
# ADD WRITEBACK             : PASS | SM1 | Expected=0000000f Got=0000000f
# ADD WRITE ENABLE          : PASS | SM1 | Expected=1 Got=1
# ADD ZERO                  : PASS | SM1 | Expected=0 Got=0
# ADD RESULT                : PASS | SM2 | Expected=0000000f Got=0000000f
# ADD WRITEBACK             : PASS | SM2 | Expected=0000000f Got=0000000f
# ADD WRITE ENABLE          : PASS | SM2 | Expected=1 Got=1
# ADD ZERO                  : PASS | SM2 | Expected=0 Got=0
# ADD RESULT                : PASS | SM3 | Expected=0000000f Got=0000000f
# ADD WRITEBACK             : PASS | SM3 | Expected=0000000f Got=0000000f
# ADD WRITE ENABLE          : PASS | SM3 | Expected=1 Got=1
# ADD ZERO                  : PASS | SM3 | Expected=0 Got=0
# PC AFTER ADD              : PASS | SM0 | Expected=00000008 Got=00000008
# PC AFTER ADD              : PASS | SM1 | Expected=00000008 Got=00000008
# PC AFTER ADD              : PASS | SM2 | Expected=00000008 Got=00000008
# PC AFTER ADD              : PASS | SM3 | Expected=00000008 Got=00000008
# SUB RESULT                : PASS | SM0 | Expected=00000005 Got=00000005
# SUB WRITEBACK             : PASS | SM0 | Expected=00000005 Got=00000005
# SUB WRITE ENABLE          : PASS | SM0 | Expected=1 Got=1
# SUB ZERO                  : PASS | SM0 | Expected=0 Got=0
# SUB RESULT                : PASS | SM1 | Expected=00000005 Got=00000005
# SUB WRITEBACK             : PASS | SM1 | Expected=00000005 Got=00000005
# SUB WRITE ENABLE          : PASS | SM1 | Expected=1 Got=1
# SUB ZERO                  : PASS | SM1 | Expected=0 Got=0
# SUB RESULT                : PASS | SM2 | Expected=00000005 Got=00000005
# SUB WRITEBACK             : PASS | SM2 | Expected=00000005 Got=00000005
# SUB WRITE ENABLE          : PASS | SM2 | Expected=1 Got=1
# SUB ZERO                  : PASS | SM2 | Expected=0 Got=0
# SUB RESULT                : PASS | SM3 | Expected=00000005 Got=00000005
# SUB WRITEBACK             : PASS | SM3 | Expected=00000005 Got=00000005
# SUB WRITE ENABLE          : PASS | SM3 | Expected=1 Got=1
# SUB ZERO                  : PASS | SM3 | Expected=0 Got=0
# MUL RESULT                : PASS | SM0 | Expected=00000032 Got=00000032
# MUL RESULT                : PASS | SM1 | Expected=00000032 Got=00000032
# MUL RESULT                : PASS | SM2 | Expected=00000032 Got=00000032
# MUL RESULT                : PASS | SM3 | Expected=00000032 Got=00000032
# AND RESULT                : PASS | SM0 | Expected=00000000 Got=00000000
# AND ZERO FLAG             : PASS | SM0 | Expected=1 Got=1
# AND RESULT                : PASS | SM1 | Expected=00000000 Got=00000000
# AND ZERO FLAG             : PASS | SM1 | Expected=1 Got=1
# AND RESULT                : PASS | SM2 | Expected=00000000 Got=00000000
# AND ZERO FLAG             : PASS | SM2 | Expected=1 Got=1
# AND RESULT                : PASS | SM3 | Expected=00000000 Got=00000000
# AND ZERO FLAG             : PASS | SM3 | Expected=1 Got=1
# OR RESULT                 : PASS | SM0 | Expected=0000000f Got=0000000f
# OR RESULT                 : PASS | SM1 | Expected=0000000f Got=0000000f
# OR RESULT                 : PASS | SM2 | Expected=0000000f Got=0000000f
# OR RESULT                 : PASS | SM3 | Expected=0000000f Got=0000000f
# XOR RESULT                : PASS | SM0 | Expected=0000000f Got=0000000f
# XOR RESULT                : PASS | SM1 | Expected=0000000f Got=0000000f
# XOR RESULT                : PASS | SM2 | Expected=0000000f Got=0000000f
# XOR RESULT                : PASS | SM3 | Expected=0000000f Got=0000000f
# 
# ADDI DEBUG : Opcode=000110 RS1=1 IMM=20 IMM_HEX=0014
# ADDI RESULT               : PASS | SM0 | Expected=0000001e Got=0000001e
# ADDI WRITEBACK            : PASS | SM0 | Expected=0000001e Got=0000001e
# ADDI WRITE ENABLE         : PASS | SM0 | Expected=1 Got=1
# ADDI ZERO                 : PASS | SM0 | Expected=0 Got=0
# ADDI RESULT               : PASS | SM1 | Expected=0000001e Got=0000001e
# ADDI WRITEBACK            : PASS | SM1 | Expected=0000001e Got=0000001e
# ADDI WRITE ENABLE         : PASS | SM1 | Expected=1 Got=1
# ADDI ZERO                 : PASS | SM1 | Expected=0 Got=0
# ADDI RESULT               : PASS | SM2 | Expected=0000001e Got=0000001e
# ADDI WRITEBACK            : PASS | SM2 | Expected=0000001e Got=0000001e
# ADDI WRITE ENABLE         : PASS | SM2 | Expected=1 Got=1
# ADDI ZERO                 : PASS | SM2 | Expected=0 Got=0
# ADDI RESULT               : PASS | SM3 | Expected=0000001e Got=0000001e
# ADDI WRITEBACK            : PASS | SM3 | Expected=0000001e Got=0000001e
# ADDI WRITE ENABLE         : PASS | SM3 | Expected=1 Got=1
# ADDI ZERO                 : PASS | SM3 | Expected=0 Got=0
# 
# ----------------------------------------------
# MULTI-SM INDEPENDENCE CHECK
# ----------------------------------------------
# SM INDEPENDENCE           : PASS | SM0 | Expected=0000001e Got=0000001e
# SM INDEPENDENCE           : PASS | SM1 | Expected=0000001e Got=0000001e
# SM INDEPENDENCE           : PASS | SM2 | Expected=0000001e Got=0000001e
# SM INDEPENDENCE           : PASS | SM3 | Expected=0000001e Got=0000001e
# 
# ======================================================
# PASSED : 80
# FAILED : 0
# ======================================================
# 
# ALL MULTI-SM GPU TESTS PASSED
# 
# ======================================================