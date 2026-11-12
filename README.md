# MintMate Pass — contract

ERC-721 access pass for **MintMate** (the Mint Terminal), built to the approved
spec in `~/workspace/your_files/mintmate-pass-gate-spec.md` (section 3).

**Status: code + tests only. NOT deployed. Nothing has been signed or sent to
any network.** Deployment is a separate, later step — see "Deploying later".

## The contract

`src/MintMatePass.sol` — a plain contract. No proxy, no upgrade path, no admin
mint. Built on OpenZeppelin Contracts v5.1.0 (`ERC721`, `ERC2981`, `Ownable`,
`MerkleProof`, `ReentrancyGuard`).

| Rule | Value |
|---|---|
| Name / symbol | MintMate Pass / `MMPASS` |
| Chain (intended) | Base mainnet, 8453 |
| Hard supply cap | 1,000 (token ids start at 1) |
| Founding phase | First 200 tokens, free, 1 per wallet, Merkle-allowlist claim |
| Public phase | Remaining supply, **0.005 ETH** each, max **3 per wallet** |
| Royalty | EIP-2981 default **5%** to the owner wallet |
| Owner | Passed as a **constructor argument** — the deployer is irrelevant |

Behaviour worth knowing:

- **Phases are strictly ordered.** Founding runs first. The owner opens the
  public phase with `openPublicSale()`, which only works once Founding has
  ended — either sold out (200 claimed) or closed early by the owner with
  `closeFounding()`.
- **`isFounding(tokenId)`** is recorded at mint time. If Founding closes early,
  public tokens minted into the first 200 ids are *not* Founding tokens.
- **Founding and public allowances are separate.** A Founding claimer can still
  buy up to 3 public passes (4 total). Nobody — including the owner — can mint
  outside these rules; the owner has no mint function at all.
- **Public payment must be exact** (`0.005 ETH × quantity`). Under- and
  over-payments revert; there is no refund path to attack.
- **Founding claim is non-payable** — sending ETH with a claim reverts.
- **`setBaseURI` locks at the first mint.** Set it and verify the metadata
  before any claim opens (the spec pins the IPFS hash in the contract).
- **`withdraw()`** is owner-only and sweeps the full balance (public-sale
  proceeds) to the owner.
- **Allowlist leaf format:** for address `a`, the leaf is
  `keccak256(bytes.concat(keccak256(abi.encode(a))))` (OpenZeppelin's
  double-hash convention). The root is set with `setFoundingMerkleRoot` by the
  owner.

## Tests

Toolchain: Foundry `forge` 1.9.0, solc 0.8.26, OpenZeppelin Contracts v5.1.0,
forge-std v1.9.4 (both vendored under `lib/` as pinned git clones).

```bash
export PATH="$HOME/.foundry/bin:$PATH"
cd ~/workspace/mintmate-pass
forge build
forge test
```

**Result (2026-11-11): 23 passed, 0 failed, 0 skipped.**

Coverage, mapped to the requirements:

- Cap enforcement: `test_CapEnforcement_1000` mints the full 1,000 (200
  founding + 800 public) and shows the 1,001st mint reverting.
- Founding happy path, double-claim rejection, non-allowlisted rejection,
  wrong-proof rejection, owner-can't-claim-without-a-spot, claim-with-payment
  rejection.
- Founding boundary: token 200 is the last Founding token; token 201 mints
  through the public phase and `isFounding(201)` is false.
- Phase gating: public mint reverts while closed; `openPublicSale` reverts
  while Founding is still running; phase controls are owner-only; early close
  then open works; claims revert after early close.
- Public price exactness: ±1 wei and wrong-quantity totals revert with the
  expected/received amounts; exact payment succeeds.
- 3-per-wallet limit across multiple transactions and in a single transaction;
  zero quantity reverts; Founding claim does not consume public allowance.
- Royalty: `royaltyInfo` returns the owner wallet and exactly 5%; ERC-2981 and
  ERC-721 interface ids detected.
- Withdraw: non-owner reverts; owner sweeps the full sale balance.
- Base URI: settable pre-launch, `tokenURI` resolves, locked after first mint,
  owner-only.

One build lint warning (forge's reentrancy-events heuristic on the `Withdrawn`
event emitted after the external call in `withdraw`) is a false positive:
`withdraw` is `nonReentrant` and the amount is read before the call.

## Deploying later (NOT done here)

Constructor argument — one address, used for ownership **and** royalties:

```
initialOwner = 0xfFDd2f83555c64d1CaA17f5646C08b80013ED38b   (George's main wallet)
```

Example with Foundry (fill in the deployer key at deploy time — any funded
Base account can deploy; ownership lands on the address above):

```bash
forge create src/MintMatePass.sol:MintMatePass \
  --rpc-url https://mainnet.base.org \
  --private-key <DEPLOYER_KEY> \
  --constructor-args 0xfFDd2f83555c64d1CaA17f5646C08b80013ED38b
```

**Gas needed:** deployment measured locally at **1,908,960 gas** (in-test
measurement; deployed bytecode is 7,827 bytes, which cross-checks: 7,827 × 200
gas code deposit + 21,000 base + constructor execution ≈ 1.9M). At typical Base
gas prices (~0.005–0.05 gwei) that is roughly **0.00001–0.0001 ETH** — the
deployer needs only dust on Base, but confirm the live gas price at the time.

Pre-launch checklist, in order:

1. Deploy with the constructor argument above.
2. `setBaseURI("ipfs://…/")` — before any mint, it locks at the first one.
   Verify `tokenURI` rendering against the hosted metadata.
3. Build the Founding allowlist (200 wallets), compute the Merkle root using
   the leaf format above, then `setFoundingMerkleRoot(root)`.
4. Add the pass as a drop in MintMate and run Founding claims through
   MintMate's own mint flow (per the spec's dogfooded launch).
5. When Founding ends (sold out or `closeFounding()`), call
   `openPublicSale()`.
6. Verify the contract on Basescan (`forge verify-contract`) so the pass
   itself passes the same source-verified check MintMate sells.

## Layout

```
src/MintMatePass.sol        the contract
test/MintMatePass.t.sol     the test suite (incl. a Merkle-tree helper)
lib/openzeppelin-contracts  OpenZeppelin v5.1.0 (pinned clone)
lib/forge-std               forge-std v1.9.4 (pinned clone)
foundry.toml / remappings.txt
```
