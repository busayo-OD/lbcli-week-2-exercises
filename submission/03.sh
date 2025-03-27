#!/bin/bash
# Created a SegWit address.
# Add funds to the address.
# Return only the Address

# Create a new native SegWit address (bech32) in regtest mode
ADDRESS=$(bitcoin-cli -regtest -named getnewaddress label="" address_type="bech32")

# Mine 101 blocks to send funds to the address (only works in regtest)
bitcoin-cli -regtest generatetoaddress 101 "$ADDRESS" > /dev/null 2>&1

# Return only the address
echo "$ADDRESS"

