# ======================================================
#               CUSTOM GPU HOST INTERFACE TEST
# ======================================================
# 
# RESET COMMAND DATA             : PASS | Expected=00000000 Got=00000000
# RESET COMMAND VALID            : PASS | Expected=0 Got=0
# HOST READY                     : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 2 : HOST COMMAND WRITE
# ----------------------------------------------
# COMMAND REGISTER               : PASS | Expected=12345678 Got=12345678
# COMMAND VALID                  : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 3 : COMMAND VALID PULSE
# ----------------------------------------------
# COMMAND VALID CLEAR            : PASS | Expected=0 Got=0
# COMMAND DATA RETAIN            : PASS | Expected=12345678 Got=12345678
# 
# ----------------------------------------------
# TEST 4 : HOST READ
# ----------------------------------------------
# HOST READ DATA                 : PASS | Expected=12345678 Got=12345678
# 
# ----------------------------------------------
# TEST 5 : SECOND COMMAND
# ----------------------------------------------
# SECOND COMMAND DATA            : PASS | Expected=a5a5a5a5 Got=a5a5a5a5
# SECOND COMMAND VALID           : PASS | Expected=1 Got=1
# 
# ----------------------------------------------
# TEST 6 : INVALID ADDRESS
# ----------------------------------------------
# INVALID ADDRESS PROTECTION     : PASS | Expected=a5a5a5a5 Got=a5a5a5a5
# INVALID ADDRESS VALID          : PASS | Expected=0 Got=0
# INVALID READ DATA              : PASS | Expected=00000000 Got=00000000
# 
# ======================================================
#                     FINAL RESULT
# ======================================================
# PASSED : 13
# FAILED : 0
# ======================================================
# 
# ALL HOST INTERFACE TESTS PASSED
# 
# ======================================================