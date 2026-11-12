# MintMate Pass — deploy from the vault wallet

**Status: NOT deployed yet.** This pack makes the deploy one command (forge)
or a few taps (Remix). You sign it yourself — Muse does not hold the vault key.

Repo (public): https://github.com/georgeonweb3/mintmate-pass

## The facts

- **Deployer:** vault wallet `0xB3Aa20A71326D1d627e3097427514A30894D0FA8`
- **Owner + royalty receiver (constructor argument):** main wallet `0xfFDd2f83555c64d1CaA17f5646C08b80013ED38b`
- **Chain:** Base mainnet (8453), RPC `https://mainnet.base.org`
- **Deploy gas:** ~1,908,960 gas (~$0.02 at current Base fees)
- **Vault balance on Base (checked 2026-11-12 15:38 WAT):** 0.0003016 ETH (~$0.61) — about 26x the gas needed. No top-up required.

Ownership and the 5% royalty land on the main wallet no matter which wallet
deploys, because the owner is set in the constructor.

## Route 1 — Foundry (Termux or desktop)

Needs forge installed and the vault key available in your own shell.
Never send the key to Muse or paste it in chat.

```bash
cd ~/workspace/mintmate-pass   # or wherever you keep the project
export PATH="$HOME/.foundry/bin:$PATH"

forge create src/MintMatePass.sol:MintMatePass \
  --rpc-url https://mainnet.base.org \
  --private-key <VAULT_WALLET_KEY> \
  --constructor-args 0xfFDd2f83555c64d1CaA17f5646C08b80013ED38b
```

It prints the deployed contract address when it lands. Keep that address.

## Route 2 — Remix (phone, with your Bitget wallet)

No big paste needed. The contract is on GitHub, Remix fetches it with one line.

1. Open https://remix.ethereum.org in your phone browser.
2. Create a new file, paste this ONE line:

   ```solidity
   import "https://github.com/georgeonweb3/mintmate-pass/blob/main/MintMatePass.flattened.sol";
   ```

   (Single file, no dependencies to resolve. If that import ever fails, the
   same file is attached to the chat as `MintMatePass.flattened.sol` — paste
   its whole contents instead.)
3. Compile it (Solidity 0.8.26).
4. In Deploy & Run: environment = **Injected Provider** (connect your
   Bitget wallet, vault account, Base network).
5. Deploy with constructor argument:
   `0xfFDd2f83555c64d1CaA17f5646C08b80013ED38b`
6. Confirm the transaction in Bitget. Gas is ~$0.02, and the vault already
   holds ~$0.61 on Base.

## After the deploy

Send Muse the deployed contract address. Then Muse will:

1. Verify the source on Basescan (`forge verify-contract`).
2. Set the address in MintMate's gate config (still warn-only until you say
   otherwise).
3. Set the base URI and the Founding Merkle root only when you give the go
   (base URI locks at the first mint, so it must be set before claims open).
