# <Limitation>-------------------------------------------------------------------------------------------------------
# Do not use following
# - space characters
# - comment out keyword `<<`
# - return escaping `\`, like as follow
#   ```
#   -D'QQQ(IN)=(IN? \
#               TRUE: \
#               FALSE \
#              )'
#   ```
# ------------------------------------------------------------------------------------------------------</Limitation>

# < Do not change here (This option is necessary for enabling only preprocess)>--------------------------------------
-E
-C
-P
# -------------------------------------</ Do not change here (This option is necessary for enabling only preprocess)>

# < User Defintions >------------------------------------------------------------------------------------------------
-D'XXX'
-D'IN=1'
-D'QQQ(IN)=(IN?1:0)'
# -----------------------------------------------------------------------------------------------</ User Defintions >
