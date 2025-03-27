#!/bin/bash
# Create a new Bitcoin address, for receiving change.

# Create a new change address in regtest mode
CHANGE_ADDRESS=$(bitcoin-cli -regtest getrawchangeaddress)

# Output only the change address
echo "$CHANGE_ADDRESS"

