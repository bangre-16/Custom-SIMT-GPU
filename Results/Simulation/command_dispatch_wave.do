# ======================================================
#           CUSTOM GPU COMMAND DISPATCH TEST
# ======================================================
# 
# 
# ----------------------------------------------
# TEST 1 : RESET
# ----------------------------------------------
# RESET INSTRUCTION              : PASS | SM0 | Expected=00000000 Got=00000000
# RESET VALID                    : PASS | SM0 | Expected=0 Got=0
# RESET INSTRUCTION              : PASS | SM1 | Expected=00000000 Got=00000000
# RESET VALID                    : PASS | SM1 | Expected=0 Got=0
# RESET INSTRUCTION              : PASS | SM2 | Expected=00000000 Got=00000000
# RESET VALID                    : PASS | SM2 | Expected=0 Got=0
# RESET INSTRUCTION              : PASS | SM3 | Expected=00000000 Got=00000000
# RESET VALID                    : PASS | SM3 | Expected=0 Got=0
# RESET BUSY                     : PASS | SM0 | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 2 : FIRST COMMAND DISPATCH
# ----------------------------------------------
# COMMAND BROADCAST              : PASS | SM0 | Expected=12345678 Got=12345678
# COMMAND VALID                  : PASS | SM0 | Expected=1 Got=1
# COMMAND BROADCAST              : PASS | SM1 | Expected=12345678 Got=12345678
# COMMAND VALID                  : PASS | SM1 | Expected=1 Got=1
# COMMAND BROADCAST              : PASS | SM2 | Expected=12345678 Got=12345678
# COMMAND VALID                  : PASS | SM2 | Expected=1 Got=1
# COMMAND BROADCAST              : PASS | SM3 | Expected=12345678 Got=12345678
# COMMAND VALID                  : PASS | SM3 | Expected=1 Got=1
# DISPATCH BUSY                  : PASS | SM0 | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 3 : VALID PULSE CLEAR
# ----------------------------------------------
# VALID CLEAR                    : PASS | SM0 | Expected=0 Got=0
# INSTRUCTION RETAIN             : PASS | SM0 | Expected=12345678 Got=12345678
# VALID CLEAR                    : PASS | SM1 | Expected=0 Got=0
# INSTRUCTION RETAIN             : PASS | SM1 | Expected=12345678 Got=12345678
# VALID CLEAR                    : PASS | SM2 | Expected=0 Got=0
# INSTRUCTION RETAIN             : PASS | SM2 | Expected=12345678 Got=12345678
# VALID CLEAR                    : PASS | SM3 | Expected=0 Got=0
# INSTRUCTION RETAIN             : PASS | SM3 | Expected=12345678 Got=12345678
# BUSY CLEAR                     : PASS | SM0 | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 4 : SECOND COMMAND
# ----------------------------------------------
# SECOND BROADCAST               : PASS | SM0 | Expected=a5a5a5a5 Got=a5a5a5a5
# SECOND VALID                   : PASS | SM0 | Expected=1 Got=1
# SECOND BROADCAST               : PASS | SM1 | Expected=a5a5a5a5 Got=a5a5a5a5
# SECOND VALID                   : PASS | SM1 | Expected=1 Got=1
# SECOND BROADCAST               : PASS | SM2 | Expected=a5a5a5a5 Got=a5a5a5a5
# SECOND VALID                   : PASS | SM2 | Expected=1 Got=1
# SECOND BROADCAST               : PASS | SM3 | Expected=a5a5a5a5 Got=a5a5a5a5
# SECOND VALID                   : PASS | SM3 | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 5 : THIRD COMMAND
# ----------------------------------------------
# THIRD BROADCAST                : PASS | SM0 | Expected=0000000f Got=0000000f
# THIRD VALID                    : PASS | SM0 | Expected=1 Got=1
# THIRD BROADCAST                : PASS | SM1 | Expected=0000000f Got=0000000f
# THIRD VALID                    : PASS | SM1 | Expected=1 Got=1
# THIRD BROADCAST                : PASS | SM2 | Expected=0000000f Got=0000000f
# THIRD VALID                    : PASS | SM2 | Expected=1 Got=1
# THIRD BROADCAST                : PASS | SM3 | Expected=0000000f Got=0000000f
# THIRD VALID                    : PASS | SM3 | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 6 : NO COMMAND
# ----------------------------------------------
# NO COMMAND VALID               : PASS | SM0 | Expected=0 Got=0
# LAST INSTRUCTION RETAIN        : PASS | SM0 | Expected=0000000f Got=0000000f
# NO COMMAND VALID               : PASS | SM1 | Expected=0 Got=0
# LAST INSTRUCTION RETAIN        : PASS | SM1 | Expected=0000000f Got=0000000f
# NO COMMAND VALID               : PASS | SM2 | Expected=0 Got=0
# LAST INSTRUCTION RETAIN        : PASS | SM2 | Expected=0000000f Got=0000000f
# NO COMMAND VALID               : PASS | SM3 | Expected=0 Got=0
# LAST INSTRUCTION RETAIN        : PASS | SM3 | Expected=0000000f Got=0000000f
# NO COMMAND BUSY                : PASS | SM0 | Expected=0 Got=0
# 
# ----------------------------------------------
# TEST 7 : SM BROADCAST CONSISTENCY
# ----------------------------------------------
# SM BROADCAST CONSISTENCY       : PASS | SM0 | Expected=cafebabe Got=cafebabe
# SM BROADCAST VALID             : PASS | SM0 | Expected=1 Got=1
# SM BROADCAST CONSISTENCY       : PASS | SM1 | Expected=cafebabe Got=cafebabe
# SM BROADCAST VALID             : PASS | SM1 | Expected=1 Got=1
# SM BROADCAST CONSISTENCY       : PASS | SM2 | Expected=cafebabe Got=cafebabe
# SM BROADCAST VALID             : PASS | SM2 | Expected=1 Got=1
# SM BROADCAST CONSISTENCY       : PASS | SM3 | Expected=cafebabe Got=cafebabe
# SM BROADCAST VALID             : PASS | SM3 | Expected=1 Got=1
# 
# ======================================================
#                     FINAL RESULT
# ======================================================
# PASSED : 60
# FAILED : 0
# ======================================================
# 
# ALL COMMAND DISPATCH TESTS PASSED
# 
# ======================================================