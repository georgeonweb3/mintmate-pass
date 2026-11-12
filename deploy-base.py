#!/usr/bin/env python3
"""Deploy MintMatePass to Base mainnet (8453) from the launch wallet.
Reads the key from the launch wallet secret.json only; never prints it.
Init code (creation bytecode + constructor arg for the main wallet) is read
from /tmp/mintmate_init.txt, which was verified by cast estimate against the
live Base RPC (1,889,030 gas) before this script was written.
Usage: deploy-base.py   (no args; one deploy per run)
"""
import json, sys, time, urllib.request
from eth_account import Account

RPC = "https://mainnet.base.org"
CHAIN_ID = 8453
SECRET = "/home/hatch/workspace/scratch/elysium-launch/secret.json"
INIT_FILE = "/tmp/mintmate_init.txt"
EXPECTED_FROM = "0x4aA5dE33AD398Bc9F9a51207cB3a05Bb22cD8265"

def rpc(method, params):
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": method, "params": params}).encode()
    last_err = None
    for attempt in range(4):
        try:
            req = urllib.request.Request(RPC, data=body, headers={
                "Content-Type": "application/json",
                "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
                "Connection": "close",
            })
            with urllib.request.urlopen(req, timeout=30) as r:
                resp = json.load(r)
                if "result" not in resp:
                    print("RPC ERROR RESPONSE:", json.dumps(resp), file=sys.stderr)
                    raise SystemExit(1)
                return resp["result"]
        except Exception as e:
            last_err = e
            print(f"RPC {method} attempt {attempt + 1} failed: {e}; retrying...", file=sys.stderr)
            time.sleep(2 * (attempt + 1))
    print(f"RPC {method} failed after 4 attempts: {last_err}", file=sys.stderr)
    raise SystemExit(1)

def main():
    init_code = open(INIT_FILE).read().strip()
    assert init_code.startswith("0x6080604052"), "init code head mismatch"
    assert init_code.endswith("ffdd2f83555c64d1caa17f5646c08b80013ed38b"), "constructor arg tail mismatch"
    key = json.load(open(SECRET))["private_key"]
    acct = Account.from_key(key)
    assert acct.address.lower() == EXPECTED_FROM.lower(), f"unexpected signer {acct.address}"
    balance = int(rpc("eth_getBalance", [acct.address, "latest"]), 16)
    nonce = int(rpc("eth_getTransactionCount", [acct.address, "latest"]), 16)
    # No markup on gas price: the $0.03 funding only just covers the deploy,
    # and a 1.1x markup plus gas drift pushed the first attempt over balance.
    gas_price = int(rpc("eth_gasPrice", []), 16)
    est_gas = int(rpc("eth_estimateGas", [{"from": acct.address, "data": init_code}]), 16)
    gas_limit = int(est_gas * 1.1)
    # Base (OP Stack) also charges an L1 data fee for the init code; read it
    # from the GasPriceOracle predeploy so the fits check uses the true total.
    code_bytes = bytes.fromhex(init_code[2:])
    call_data = ("0x49948e0e"
                 + (32).to_bytes(32, "big").hex()
                 + len(code_bytes).to_bytes(32, "big").hex()
                 + code_bytes.hex()
                 + "00" * ((32 - len(code_bytes) % 32) % 32))
    l1_fee = int(rpc("eth_call", [{"to": "0x420000000000000000000000000000000000000F",
                                   "data": call_data}, "latest"]), 16)
    max_cost = gas_limit * gas_price + l1_fee
    print(json.dumps({
        "from": acct.address, "balance_wei": balance, "nonce": nonce,
        "gas_price_wei": gas_price, "est_gas": est_gas, "gas_limit": gas_limit,
        "max_cost_wei": max_cost, "fits_balance": max_cost <= balance,
    }))
    if max_cost > balance:
        print("ABORT: worst-case cost exceeds balance", file=sys.stderr)
        raise SystemExit(2)
    tx = {"data": init_code, "value": 0, "gas": gas_limit,
          "gasPrice": gas_price, "nonce": nonce, "chainId": CHAIN_ID}
    signed = acct.sign_transaction(tx)
    tx_hash = rpc("eth_sendRawTransaction", ["0x" + signed.raw_transaction.hex()])
    print(json.dumps({"tx_hash": tx_hash, "status": "sent"}))
    receipt = None
    for _ in range(60):
        time.sleep(2)
        receipt = rpc("eth_getTransactionReceipt", [tx_hash])
        if receipt is not None:
            break
    if receipt is None:
        print(json.dumps({"tx_hash": tx_hash, "status": "sent_but_no_receipt_yet"}))
        raise SystemExit(0)
    print(json.dumps({
        "tx_hash": tx_hash,
        "status": "mined" if int(receipt["status"], 16) == 1 else "FAILED",
        "contract_address": receipt.get("contractAddress"),
        "gas_used": int(receipt["gasUsed"], 16),
        "block": int(receipt["blockNumber"], 16),
    }))

main()
