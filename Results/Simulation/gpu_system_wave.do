# ======================================================
#         CUSTOM GPU SYSTEM INTEGRATION TEST
# ======================================================
# 
# 
# ----------------------------------------------
# TEST 1 : SYSTEM RESET
# ----------------------------------------------
# HOST READY AFTER RESET           : PASS | Expected=1 Got=1
# COMMAND DATA RESET               : PASS | Expected=00000000 Got=00000000
# COMMAND VALID RESET              : PASS | Expected=0 Got=0
# DISPATCH BUSY RESET              : PASS | Expected=0 Got=0
# RESET PC                         : PASS | Expected=00000000 Got=00000000
# RESET INSTRUCTION VALID          : PASS | Expected=0 Got=0
# RESET PC                         : PASS | Expected=00000000 Got=00000000
# RESET INSTRUCTION VALID          : PASS | Expected=0 Got=0
# RESET PC                         : PASS | Expected=00000000 Got=00000000
# RESET INSTRUCTION VALID          : PASS | Expected=0 Got=0
# RESET PC                         : PASS | Expected=00000000 Got=00000000
# RESET INSTRUCTION VALID          : PASS | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 2 : HOST COMMAND WRITE
# ----------------------------------------------
# HOST COMMAND REGISTER            : PASS | Expected=00221800 Got=00221800
# COMMAND VALID AFTER WRITE        : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 3 : COMMAND DISPATCH
# ----------------------------------------------
# DISPATCH BUSY AFTER DISPATCH     : PASS | Expected=1 Got=1
# DISPATCHED INSTRUCTION           : PASS | Expected=00221800 Got=00221800
# DISPATCHED INSTRUCTION           : PASS | Expected=00221800 Got=00221800
# DISPATCHED INSTRUCTION           : PASS | Expected=00221800 Got=00221800
# DISPATCHED INSTRUCTION           : PASS | Expected=00221800 Got=00221800
# 
# ----------------------------------------------
# TEST 4 : ADD THROUGH COMPLETE CONTROL PATH
# ----------------------------------------------
# ADD ALU RESULT                   : PASS | Expected=0000000f Got=0000000f
# ADD WRITEBACK                    : PASS | Expected=0000000f Got=0000000f
# ADD WRITE ENABLE                 : PASS | Expected=1 Got=1
# ADD ZERO FLAG                    : PASS | Expected=0 Got=0
# ADD ALU RESULT                   : PASS | Expected=0000000f Got=0000000f
# ADD WRITEBACK                    : PASS | Expected=0000000f Got=0000000f
# ADD WRITE ENABLE                 : PASS | Expected=1 Got=1
# ADD ZERO FLAG                    : PASS | Expected=0 Got=0
# ADD ALU RESULT                   : PASS | Expected=0000000f Got=0000000f
# ADD WRITEBACK                    : PASS | Expected=0000000f Got=0000000f
# ADD WRITE ENABLE                 : PASS | Expected=1 Got=1
# ADD ZERO FLAG                    : PASS | Expected=0 Got=0
# ADD ALU RESULT                   : PASS | Expected=0000000f Got=0000000f
# ADD WRITEBACK                    : PASS | Expected=0000000f Got=0000000f
# ADD WRITE ENABLE                 : PASS | Expected=1 Got=1
# ADD ZERO FLAG                    : PASS | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 5 : MULTI-SM PC SYNCHRONIZATION
# ----------------------------------------------
# SM PC SYNCHRONIZATION            : PASS | Expected=00000010 Got=00000010
# SM PC SYNCHRONIZATION            : PASS | Expected=00000010 Got=00000010
# SM PC SYNCHRONIZATION            : PASS | Expected=00000010 Got=00000010
# SM PC SYNCHRONIZATION            : PASS | Expected=00000010 Got=00000010
# 
# ----------------------------------------------
# TEST 6 : SUB COMMAND
# ----------------------------------------------
# SUB ALU RESULT                   : PASS | Expected=00000005 Got=00000005
# SUB WRITEBACK                    : PASS | Expected=00000005 Got=00000005
# SUB WRITE ENABLE                 : PASS | Expected=1 Got=1
# SUB ALU RESULT                   : PASS | Expected=00000005 Got=00000005
# SUB WRITEBACK                    : PASS | Expected=00000005 Got=00000005
# SUB WRITE ENABLE                 : PASS | Expected=1 Got=1
# SUB ALU RESULT                   : PASS | Expected=00000005 Got=00000005
# SUB WRITEBACK                    : PASS | Expected=00000005 Got=00000005
# SUB WRITE ENABLE                 : PASS | Expected=1 Got=1
# SUB ALU RESULT                   : PASS | Expected=00000005 Got=00000005
# SUB WRITEBACK                    : PASS | Expected=00000005 Got=00000005
# SUB WRITE ENABLE                 : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 7 : MUL COMMAND
# ----------------------------------------------
# MUL ALU RESULT                   : PASS | Expected=00000032 Got=00000032
# MUL WRITEBACK                    : PASS | Expected=00000032 Got=00000032
# MUL ALU RESULT                   : PASS | Expected=00000032 Got=00000032
# MUL WRITEBACK                    : PASS | Expected=00000032 Got=00000032
# MUL ALU RESULT                   : PASS | Expected=00000032 Got=00000032
# MUL WRITEBACK                    : PASS | Expected=00000032 Got=00000032
# MUL ALU RESULT                   : PASS | Expected=00000032 Got=00000032
# MUL WRITEBACK                    : PASS | Expected=00000032 Got=00000032
# 
# ----------------------------------------------
# TEST 8 : AND COMMAND
# ----------------------------------------------
# AND ALU RESULT                   : PASS | Expected=00000000 Got=00000000
# AND ZERO FLAG                    : PASS | Expected=1 Got=1
# AND ALU RESULT                   : PASS | Expected=00000000 Got=00000000
# AND ZERO FLAG                    : PASS | Expected=1 Got=1
# AND ALU RESULT                   : PASS | Expected=00000000 Got=00000000
# AND ZERO FLAG                    : PASS | Expected=1 Got=1
# AND ALU RESULT                   : PASS | Expected=00000000 Got=00000000
# AND ZERO FLAG                    : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 9 : OR COMMAND
# ----------------------------------------------
# OR ALU RESULT                    : PASS | Expected=0000000f Got=0000000f
# OR ALU RESULT                    : PASS | Expected=0000000f Got=0000000f
# OR ALU RESULT                    : PASS | Expected=0000000f Got=0000000f
# OR ALU RESULT                    : PASS | Expected=0000000f Got=0000000f
# 
# ----------------------------------------------
# TEST 10 : HOST COMMAND READBACK
# ----------------------------------------------
# HOST COMMAND READBACK            : PASS | Expected=10223800 Got=10223800
# 
# ----------------------------------------------
# TEST 11 : INVALID HOST ADDRESS
# ----------------------------------------------
# INVALID HOST READ                : PASS | Expected=00000000 Got=00000000
# 
# ======================================================
#                     FINAL RESULT
# ======================================================
# PASSED : 73
# FAILED : 0
# ======================================================