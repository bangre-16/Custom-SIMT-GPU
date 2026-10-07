# ======================================================
#            FINAL CUSTOM GPU REGRESSION TEST
# ======================================================
# 
# 
# ----------------------------------------------
# TEST 1 : COMPLETE SYSTEM RESET
# ----------------------------------------------
# HOST READY AFTER RESET                 : PASS | Expected=1 Got=1
# COMMAND RESET                          : PASS | Expected=00000000 Got=00000000
# COMMAND VALID RESET                    : PASS | Expected=0 Got=0
# DISPATCH BUSY RESET                    : PASS | Expected=0 Got=0
# MEMORY READY RESET                     : PASS | Expected=1 Got=1
# MEMORY BUSY RESET                      : PASS | Expected=0 Got=0
# SM PC RESET                            : PASS | Expected=00000000 Got=00000000
# SM INSTRUCTION VALID RESET             : PASS | Expected=0 Got=0
# SM PC RESET                            : PASS | Expected=00000000 Got=00000000
# SM INSTRUCTION VALID RESET             : PASS | Expected=0 Got=0
# SM PC RESET                            : PASS | Expected=00000000 Got=00000000
# SM INSTRUCTION VALID RESET             : PASS | Expected=0 Got=0
# SM PC RESET                            : PASS | Expected=00000000 Got=00000000
# SM INSTRUCTION VALID RESET             : PASS | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 2 : HOST TO MULTI-SM DISPATCH
# ----------------------------------------------
# HOST COMMAND REGISTER                  : PASS | Expected=00221800 Got=00221800
# COMMAND VALID AFTER WRITE              : PASS | Expected=1 Got=1
# DISPATCH BUSY                          : PASS | Expected=1 Got=1
# INSTRUCTION BROADCAST                  : PASS | Expected=00221800 Got=00221800
# INSTRUCTION BROADCAST                  : PASS | Expected=00221800 Got=00221800
# INSTRUCTION BROADCAST                  : PASS | Expected=00221800 Got=00221800
# INSTRUCTION BROADCAST                  : PASS | Expected=00221800 Got=00221800
# 
# ----------------------------------------------
# TEST 3 : ALL-SM ADD
# ----------------------------------------------
# SM ADD ALU RESULT                      : PASS | Expected=0000000f Got=0000000f
# SM ADD WRITEBACK                       : PASS | Expected=0000000f Got=0000000f
# SM ADD WRITE ENABLE                    : PASS | Expected=1 Got=1
# SM ADD ZERO                            : PASS | Expected=0 Got=0
# SM ADD ALU RESULT                      : PASS | Expected=0000000f Got=0000000f
# SM ADD WRITEBACK                       : PASS | Expected=0000000f Got=0000000f
# SM ADD WRITE ENABLE                    : PASS | Expected=1 Got=1
# SM ADD ZERO                            : PASS | Expected=0 Got=0
# SM ADD ALU RESULT                      : PASS | Expected=0000000f Got=0000000f
# SM ADD WRITEBACK                       : PASS | Expected=0000000f Got=0000000f
# SM ADD WRITE ENABLE                    : PASS | Expected=1 Got=1
# SM ADD ZERO                            : PASS | Expected=0 Got=0
# SM ADD ALU RESULT                      : PASS | Expected=0000000f Got=0000000f
# SM ADD WRITEBACK                       : PASS | Expected=0000000f Got=0000000f
# SM ADD WRITE ENABLE                    : PASS | Expected=1 Got=1
# SM ADD ZERO                            : PASS | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 4 : PC SYNCHRONIZATION
# ----------------------------------------------
# SM PC SYNCHRONIZATION                  : PASS | Expected=00000010 Got=00000010
# SM PC SYNCHRONIZATION                  : PASS | Expected=00000010 Got=00000010
# SM PC SYNCHRONIZATION                  : PASS | Expected=00000010 Got=00000010
# SM PC SYNCHRONIZATION                  : PASS | Expected=00000010 Got=00000010
# 
# ----------------------------------------------
# TEST 5 : ALL-SM SUB
# ----------------------------------------------
# SM SUB RESULT                          : PASS | Expected=00000005 Got=00000005
# SM SUB WRITEBACK                       : PASS | Expected=00000005 Got=00000005
# SM SUB WRITE ENABLE                    : PASS | Expected=1 Got=1
# SM SUB RESULT                          : PASS | Expected=00000005 Got=00000005
# SM SUB WRITEBACK                       : PASS | Expected=00000005 Got=00000005
# SM SUB WRITE ENABLE                    : PASS | Expected=1 Got=1
# SM SUB RESULT                          : PASS | Expected=00000005 Got=00000005
# SM SUB WRITEBACK                       : PASS | Expected=00000005 Got=00000005
# SM SUB WRITE ENABLE                    : PASS | Expected=1 Got=1
# SM SUB RESULT                          : PASS | Expected=00000005 Got=00000005
# SM SUB WRITEBACK                       : PASS | Expected=00000005 Got=00000005
# SM SUB WRITE ENABLE                    : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 6 : ALL-SM MUL
# ----------------------------------------------
# SM MUL RESULT                          : PASS | Expected=00000032 Got=00000032
# SM MUL WRITEBACK                       : PASS | Expected=00000032 Got=00000032
# SM MUL RESULT                          : PASS | Expected=00000032 Got=00000032
# SM MUL WRITEBACK                       : PASS | Expected=00000032 Got=00000032
# SM MUL RESULT                          : PASS | Expected=00000032 Got=00000032
# SM MUL WRITEBACK                       : PASS | Expected=00000032 Got=00000032
# SM MUL RESULT                          : PASS | Expected=00000032 Got=00000032
# SM MUL WRITEBACK                       : PASS | Expected=00000032 Got=00000032
# 
# ----------------------------------------------
# TEST 7 : ALL-SM AND
# ----------------------------------------------
# SM AND RESULT                          : PASS | Expected=00000000 Got=00000000
# SM AND ZERO FLAG                       : PASS | Expected=1 Got=1
# SM AND RESULT                          : PASS | Expected=00000000 Got=00000000
# SM AND ZERO FLAG                       : PASS | Expected=1 Got=1
# SM AND RESULT                          : PASS | Expected=00000000 Got=00000000
# SM AND ZERO FLAG                       : PASS | Expected=1 Got=1
# SM AND RESULT                          : PASS | Expected=00000000 Got=00000000
# SM AND ZERO FLAG                       : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 8 : ALL-SM OR
# ----------------------------------------------
# SM OR RESULT                           : PASS | Expected=0000000f Got=0000000f
# SM OR RESULT                           : PASS | Expected=0000000f Got=0000000f
# SM OR RESULT                           : PASS | Expected=0000000f Got=0000000f
# SM OR RESULT                           : PASS | Expected=0000000f Got=0000000f
# 
# ----------------------------------------------
# TEST 9 : ALL-SM XOR
# ----------------------------------------------
# SM XOR RESULT                          : PASS | Expected=0000000f Got=0000000f
# SM XOR RESULT                          : PASS | Expected=0000000f Got=0000000f
# SM XOR RESULT                          : PASS | Expected=0000000f Got=0000000f
# SM XOR RESULT                          : PASS | Expected=0000000f Got=0000000f
# 
# ----------------------------------------------
# TEST 10 : ALL-SM ADDI
# ----------------------------------------------
# SM ADDI RESULT                         : PASS | Expected=0000001e Got=0000001e
# SM ADDI RESULT                         : PASS | Expected=0000001e Got=0000001e
# SM ADDI RESULT                         : PASS | Expected=0000001e Got=0000001e
# SM ADDI RESULT                         : PASS | Expected=0000001e Got=0000001e
# 
# ----------------------------------------------
# TEST 11 : MEMORY STORE
# ----------------------------------------------
# LSU STORE READY                        : PASS | Expected=1 Got=1
# L2 STORE READY                         : PASS | Expected=1 Got=1
# L2 STORE MISS                          : PASS | Expected=1 Got=1
# MEMORY CONTROLLER STORE BUSY           : PASS | Expected=1 Got=1
# MEMORY READY AFTER STORE               : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 12 : MEMORY LOAD MISS
# ----------------------------------------------
# LSU LOAD READY                         : PASS | Expected=1 Got=1
# L2 LOAD MISS                           : PASS | Expected=1 Got=1
# MEMORY LOAD DATA                       : PASS | Expected=a5a5a5a5 Got=a5a5a5a5
# MEMORY CONTROLLER LOAD BUSY            : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 13 : L2 CACHE HIT
# ----------------------------------------------
# L2 HIT AFTER FILL                      : PASS | Expected=1 Got=1
# L2 MISS AFTER FILL                     : PASS | Expected=0 Got=0
# L2 HIT DATA                            : PASS | Expected=a5a5a5a5 Got=a5a5a5a5
# 
# ----------------------------------------------
# TEST 14 : L2 WRITE HIT
# ----------------------------------------------
# L2 STORE HIT                           : PASS | Expected=1 Got=1
# L2 STORE MISS ON HIT                   : PASS | Expected=0 Got=0
# L2 WRITE HIT READY                     : PASS | Expected=1 Got=1
# MEMORY BUSY WRITE HIT                  : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 15 : READ UPDATED CACHE DATA
# ----------------------------------------------
# UPDATED DATA CACHE HIT                 : PASS | Expected=1 Got=1
# UPDATED CACHE DATA                     : PASS | Expected=5a5a5a5a Got=5a5a5a5a
# 
# ----------------------------------------------
# TEST 16 : UNALIGNED MEMORY ACCESS
# ----------------------------------------------
# UNALIGNED ADDRESS DETECTION            : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 17 : INVALID LOAD + STORE
# ----------------------------------------------
# SIMULTANEOUS ACCESS NOT READY          : PASS | Expected=0 Got=0
# L2 REJECTS SIMULTANEOUS ACCESS         : PASS | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 18 : NoC PACKET ROUTING 1
# ----------------------------------------------
# NoC DEST 2 VALID                       : PASS | Expected=1 Got=1
# NoC PACKET 1 DATA                      : PASS | Expected=12345678 Got=12345678
# NoC INPUT 0 READY                      : PASS | Expected=1 Got=1
# NoC PACKET COUNT 1                     : PASS | Expected=00000001 Got=00000001
# 
# ----------------------------------------------
# TEST 19 : NoC PACKET ROUTING 2
# ----------------------------------------------
# NoC DEST 3 VALID                       : PASS | Expected=1 Got=1
# NoC PACKET 2 DATA                      : PASS | Expected=cafebabe Got=cafebabe
# NoC INPUT 1 READY                      : PASS | Expected=1 Got=1
# NoC PACKET COUNT 2                     : PASS | Expected=00000002 Got=00000002
# 
# ----------------------------------------------
# TEST 20 : NoC DESTINATION COLLISION
# ----------------------------------------------
# NoC COLLISION OUTPUT VALID             : PASS | Expected=1 Got=1
# NoC FIRST PACKET WINS                  : PASS | Expected=11111111 Got=11111111
# NoC FIRST INPUT ACCEPTED               : PASS | Expected=1 Got=1
# NoC SECOND INPUT BLOCKED               : PASS | Expected=0 Got=0
# NoC PACKET COUNT COLLISION             : PASS | Expected=00000003 Got=00000003
# 
# ----------------------------------------------
# TEST 21 : HOST READBACK
# ----------------------------------------------
# HOST COMMAND READBACK                  : PASS | Expected=18200014 Got=18200014
# 
# ----------------------------------------------
# TEST 22 : INVALID HOST ACCESS
# ----------------------------------------------
# INVALID HOST READ                      : PASS | Expected=00000000 Got=00000000
# 
# ======================================================
#                    FINAL RESULT
# ======================================================
# PASSED : 117
# FAILED : 0
# ======================================================
# 
# ALL FINAL GPU SYSTEM REGRESSION TESTS PASSED
# 
# ======================================================