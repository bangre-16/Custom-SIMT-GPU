# ======================================================
#               CUSTOM GPU TOP TEST
# ======================================================
# 
# 
# ----------------------------------------------
# TEST 1 : GPU TOP RESET
# ----------------------------------------------
# TOP RESET PC              : PASS | SM0 | Expected=00000000 Got=00000000
# TOP RESET PC              : PASS | SM1 | Expected=00000000 Got=00000000
# TOP RESET PC              : PASS | SM2 | Expected=00000000 Got=00000000
# TOP RESET PC              : PASS | SM3 | Expected=00000000 Got=00000000
# 
# ----------------------------------------------
# TEST 2 : ADD THROUGH TOP
# ----------------------------------------------
# TOP ADD RESULT            : PASS | SM0 | Expected=0000000f Got=0000000f
# TOP ADD WRITEBACK         : PASS | SM0 | Expected=0000000f Got=0000000f
# TOP ADD WRITE ENABLE      : PASS | SM0 | Expected=1 Got=1
# TOP ADD ZERO              : PASS | SM0 | Expected=0 Got=0
# TOP ADD RESULT            : PASS | SM1 | Expected=0000000f Got=0000000f
# TOP ADD WRITEBACK         : PASS | SM1 | Expected=0000000f Got=0000000f
# TOP ADD WRITE ENABLE      : PASS | SM1 | Expected=1 Got=1
# TOP ADD ZERO              : PASS | SM1 | Expected=0 Got=0
# TOP ADD RESULT            : PASS | SM2 | Expected=0000000f Got=0000000f
# TOP ADD WRITEBACK         : PASS | SM2 | Expected=0000000f Got=0000000f
# TOP ADD WRITE ENABLE      : PASS | SM2 | Expected=1 Got=1
# TOP ADD ZERO              : PASS | SM2 | Expected=0 Got=0
# TOP ADD RESULT            : PASS | SM3 | Expected=0000000f Got=0000000f
# TOP ADD WRITEBACK         : PASS | SM3 | Expected=0000000f Got=0000000f
# TOP ADD WRITE ENABLE      : PASS | SM3 | Expected=1 Got=1
# TOP ADD ZERO              : PASS | SM3 | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 3 : TOP PC UPDATE
# ----------------------------------------------
# TOP PC UPDATE             : PASS | SM0 | Expected=00000008 Got=00000008
# TOP PC UPDATE             : PASS | SM1 | Expected=00000008 Got=00000008
# TOP PC UPDATE             : PASS | SM2 | Expected=00000008 Got=00000008
# TOP PC UPDATE             : PASS | SM3 | Expected=00000008 Got=00000008
# 
# ----------------------------------------------
# TEST 4 : SUB THROUGH TOP
# ----------------------------------------------
# TOP SUB RESULT            : PASS | SM0 | Expected=00000005 Got=00000005
# TOP SUB WRITEBACK         : PASS | SM0 | Expected=00000005 Got=00000005
# TOP SUB RESULT            : PASS | SM1 | Expected=00000005 Got=00000005
# TOP SUB WRITEBACK         : PASS | SM1 | Expected=00000005 Got=00000005
# TOP SUB RESULT            : PASS | SM2 | Expected=00000005 Got=00000005
# TOP SUB WRITEBACK         : PASS | SM2 | Expected=00000005 Got=00000005
# TOP SUB RESULT            : PASS | SM3 | Expected=00000005 Got=00000005
# TOP SUB WRITEBACK         : PASS | SM3 | Expected=00000005 Got=00000005
# 
# ----------------------------------------------
# TEST 5 : MUL THROUGH TOP
# ----------------------------------------------
# TOP MUL RESULT            : PASS | SM0 | Expected=00000032 Got=00000032
# TOP MUL RESULT            : PASS | SM1 | Expected=00000032 Got=00000032
# TOP MUL RESULT            : PASS | SM2 | Expected=00000032 Got=00000032
# TOP MUL RESULT            : PASS | SM3 | Expected=00000032 Got=00000032
# 
# ----------------------------------------------
# TEST 6 : AND THROUGH TOP
# ----------------------------------------------
# TOP AND RESULT            : PASS | SM0 | Expected=00000000 Got=00000000
# TOP AND ZERO              : PASS | SM0 | Expected=1 Got=1
# TOP AND RESULT            : PASS | SM1 | Expected=00000000 Got=00000000
# TOP AND ZERO              : PASS | SM1 | Expected=1 Got=1
# TOP AND RESULT            : PASS | SM2 | Expected=00000000 Got=00000000
# TOP AND ZERO              : PASS | SM2 | Expected=1 Got=1
# TOP AND RESULT            : PASS | SM3 | Expected=00000000 Got=00000000
# TOP AND ZERO              : PASS | SM3 | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 7 : OR THROUGH TOP
# ----------------------------------------------
# TOP OR RESULT             : PASS | SM0 | Expected=0000000f Got=0000000f
# TOP OR RESULT             : PASS | SM1 | Expected=0000000f Got=0000000f
# TOP OR RESULT             : PASS | SM2 | Expected=0000000f Got=0000000f
# TOP OR RESULT             : PASS | SM3 | Expected=0000000f Got=0000000f
# 
# ----------------------------------------------
# TEST 8 : XOR THROUGH TOP
# ----------------------------------------------
# TOP XOR RESULT            : PASS | SM0 | Expected=0000000f Got=0000000f
# TOP XOR RESULT            : PASS | SM1 | Expected=0000000f Got=0000000f
# TOP XOR RESULT            : PASS | SM2 | Expected=0000000f Got=0000000f
# TOP XOR RESULT            : PASS | SM3 | Expected=0000000f Got=0000000f
# 
# ----------------------------------------------
# TEST 9 : ADDI THROUGH TOP
# ----------------------------------------------
# TOP ADDI RESULT           : PASS | SM0 | Expected=0000001e Got=0000001e
# TOP ADDI WRITEBACK        : PASS | SM0 | Expected=0000001e Got=0000001e
# TOP ADDI WRITE ENABLE     : PASS | SM0 | Expected=1 Got=1
# TOP ADDI RESULT           : PASS | SM1 | Expected=0000001e Got=0000001e
# TOP ADDI WRITEBACK        : PASS | SM1 | Expected=0000001e Got=0000001e
# TOP ADDI WRITE ENABLE     : PASS | SM1 | Expected=1 Got=1
# TOP ADDI RESULT           : PASS | SM2 | Expected=0000001e Got=0000001e
# TOP ADDI WRITEBACK        : PASS | SM2 | Expected=0000001e Got=0000001e
# TOP ADDI WRITE ENABLE     : PASS | SM2 | Expected=1 Got=1
# TOP ADDI RESULT           : PASS | SM3 | Expected=0000001e Got=0000001e
# TOP ADDI WRITEBACK        : PASS | SM3 | Expected=0000001e Got=0000001e
# TOP ADDI WRITE ENABLE     : PASS | SM3 | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 10 : MULTI-SM TOP INTEGRATION
# ----------------------------------------------
# TOP SM INTEGRATION        : PASS | SM0 | Expected=0000001e Got=0000001e
# TOP SM INTEGRATION        : PASS | SM1 | Expected=0000001e Got=0000001e
# TOP SM INTEGRATION        : PASS | SM2 | Expected=0000001e Got=0000001e
# TOP SM INTEGRATION        : PASS | SM3 | Expected=0000001e Got=0000001e
# 
# ======================================================
#                     FINAL RESULT
# ======================================================
# PASSED : 68
# FAILED : 0
# ======================================================
# 
# ALL GPU TOP TESTS PASSED