#!/bin/bash
# This script dynamically creates a raw transaction that spends the UTXOs
# from the provided raw transaction to send 20,000,000 satoshis (0.2 BTC)
# to the address 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP.
#
# No change output is added; the fee equals the difference between total input
# and the amount being sent.

# Set Bitcoin CLI command (adjust if necessary)
BITCOIN_CLI="bitcoin-cli -regtest"

# Provided raw transaction (the only info given)
raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Step 1: Decode the provided raw transaction.
DECODED=$( $BITCOIN_CLI decoderawtransaction "$raw_tx" )
# (For debugging, you can echo "$DECODED")

# The new transaction will spend BOTH outputs from the decoded transaction.
# Extract the parent's txid (this is the txid of the provided transaction).
PARENT_TXID=$( echo "$DECODED" | jq -r '.txid' )
# And we assume that both outputs are spendable, so we use vout 0 and 1.
INPUTS=$( jq -n --arg txid "$PARENT_TXID" '[
  {"txid": $txid, "vout": 0},
  {"txid": $txid, "vout": 1}
]' )

# Step 2: Calculate total input amount.
# Extract the two output values (in BTC) from the decoded transaction.
VALUE0=$( echo "$DECODED" | jq -r '.vout[0].value' )
VALUE1=$( echo "$DECODED" | jq -r '.vout[1].value' )
TOTAL_INPUT=$( echo "$VALUE0 + $VALUE1" | bc -l )
# For example, if VALUE0=0.16430198 and VALUE1=0.07248910, then:
#   TOTAL_INPUT = 0.23679108 BTC

# Step 3: Define the amount to send and calculate fee.
SEND_AMOUNT=0.20000000   # 20,000,000 satoshis = 0.2 BTC
# Since we are not creating a change output, the fee is the leftover:
FEE=$( echo "scale=8; $TOTAL_INPUT - $SEND_AMOUNT" | bc )
# In our example: FEE = 0.23679108 - 0.20000000 = 0.03679108 BTC

# Step 4: Construct the output JSON.
# We want a single output sending 0.2 BTC to the recipient.
OUTPUTS=$( jq -n --arg addr "2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP" --argjson amt "$SEND_AMOUNT" '{($addr): $amt}' )

# Step 5: Create the new raw transaction.
NEW_RAW_TX=$( $BITCOIN_CLI createrawtransaction "$INPUTS" "$OUTPUTS" )
# The new raw transaction will include both inputs (vout 0 and vout 1) from the parent transaction
# and one output sending 0.2 BTC to the recipient.
# The fee is implicitly the difference: FEE = TOTAL_INPUT - SEND_AMOUNT.

# Output the new raw transaction hex.
echo "$NEW_RAW_TX"


