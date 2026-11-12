# MintMate Pass — Founding Allowlist DRAFT

**Status: DRAFT — do not finalize. No Merkle root computed.**
**Updated 2026-11-12 17:08 WAT — George's cuts applied: P2P wallet OUT, Davinci OUT, Tier C (40 rows) CUT.**
**Date:** 2026-11-12
**Contract:** MintMate Pass (MMPASS), ERC-721 on Base — `0xe02Eca3160260D3f19A74f304D4a82cDd6758e1c`
**Rules (per spec §3):** Founding = first 200 passes, free (gas only), 1 per wallet, allowlist via Merkle root. Sources: George's actual circles — Farcaster followers who engage with the launch cast, the Daxin X group, and Base/Elysium builders he has shipped with.

## Counts

| Block | Rows | Addresses known |
|---|---|---|
| 0 — George's own wallets | 3 | 3 |
| 2 — Tier A: shipped-with / two-way | 31 | 12 |
| 3 — Daxin X group members | 4 | 0 |
| 4 — Tier B: engaged / adopted their work | 40 | 0 |
| 6 — Launch-cast engagers (slots reserved) | 122 | 0 |
| **Total** | **200** | **15** |

**Tier legend.** A = shipped work together, merged PR, bounty paid, or two-way conversation (reply/follow/DM). B = George engaged with them (replied, liked, followed) or adopted their work. Tier C (one-way only) was CUT by George on 2026-11-12, along with the P2P wallet and Davinci.

**Hard rule applied:** no wallet address is invented or guessed anywhere in this file. Only 15 addresses appear, all from verified sources (George's 3 wallets + 12 Neynar verified addresses, resolved 2026-11-12). Every other row says `address to resolve` with the resolution method.

**How to resolve an address:**
- **Farcaster user:** Neynar user lookup → verified address for their FID (preferred; it is the address they attached to their Farcaster profile). For `.eth` names, also resolve the ENS name (BaseScan ENS lookup) and use the verified address when the two differ.
- **X-only creator:** ask the person directly (DM) for their Base wallet. No public mapping exists on record.
- **Daxin member:** ask in the X group chat for their Base wallet.
- **Telegraph builder:** ask via Discord DM (George already DMs them) or check their project repo for a deployer/funding address.
- **Partial identity (first name / entry name only):** identify the full handle first, then DM.

## Block 0 — George's own wallets

| # | Handle / name | Wallet address | Source circle | Why they fit |
|---|---|---|---|---|
| 1 | George Agbe — main wallet | `0xfFDd2f83555c64d1CaA17f5646C08b80013ED38b` | Owner | Contract owner and royalty receiver; gate allowlists this wallet permanently. |
| 2 | George Agbe — vault wallet (Farcaster) | `0xB3Aa20A71326D1d627e3097427514A30894D0FA8` | Owner | Gate allowlists this wallet permanently; funded the deploy and holds the Elysium Punk. |
| 3 | George Agbe — agentic wallet (baw) | `0xA79E2C85D5456Fa3d9115d86398896a390159D1c` | Owner | Gate allowlists this wallet permanently; the wallet Muse operates for him. |

## Block 2 — Tier A: shipped-with / two-way

| # | Handle / name | Wallet address | Source circle | Why they fit |
|---|---|---|---|---|
| 4 | Teknium | address to resolve — Farcaster/X DM for their Base wallet | Base builders (Hermes) | Maintainer of NousResearch/hermes-agent; merged George's Aegis spend-guard catalog PR #151917 on 2026-11-12 after three review rounds. |
| 5 | poet.base.eth | `0x02d961c577746ba35e65bff1016088016f49e21f` (Neynar primary verified address; 3 verified; ENS cross-check unavailable for Basename) | Farcaster / Field Atlas | Farcaster Base builder; their Field Atlas cast led to George's merged PR #27 (20M ATLAS). Replied to again Nov 11. |
| 6 | 0x94t3z | address to resolve — ask via Field Atlas (GitHub) or Farcaster DM | Field Atlas | Maintainer of Field Atlas; accepted George's proposal #24 and merged PR #27. |
| 7 | 0xSvinci | address to resolve — X/Farcaster DM for their Base wallet | MintDash / SuperDads | Founder of MintDash and SuperDads; George modelled MintMate's scope and this pass gate on MintDash. |
| 8 | Hoodie Jake (@0FJAKE) | address to resolve — X DM for their Base wallet | Robinhood Chain builders | Offered the $1,000 Hoodie Launcher bounty; George built and shipped it. |
| 9 | Sadiq | address to resolve — Discord DM (Telegraph) for their Base wallet | Telegraph Season II | Builder of Counterproof sanctions screening; his miner 731002 is wired into tgp-guard as a second opinion; warm Aegis DM delivered Nov 8. |
| 10 | jey | address to resolve — Discord DM (Telegraph) for their Base wallet | Telegraph Season II | Builder of Receipts Desk diligence packs; warm Aegis DM delivered Nov 8 with a $60 audit offer. |
| 11 | maahin | address to resolve — Discord DM (Telegraph) for their Base wallet | Telegraph Season II | Builder of Listings Desk miners; warm Aegis DM delivered Nov 8 with a $60 audit offer. |
| 12 | nice.bills | address to resolve — Discord DM (Telegraph) for their Base wallet | Telegraph Season II | Builder of por-attest reserve attestation; warm Aegis DM delivered Nov 8 with a $60 audit offer. |
| 13 | Sarah (Oracle Arena) | address to resolve — Discord DM (Telegraph) for their Base wallet | Telegraph Season II | Builder of Oracle Arena; warm Aegis DM delivered Nov 8 with a $60 audit offer. |
| 14 | TOLUweb3 | address to resolve — Discord DM (Telegraph) for their Base wallet | Telegraph Season II | Builder pitching a private counterparty-assessment agent; overlaps tgp-guard on sanctions screening; owns the privacy angle George's entry lacks. |
| 15 | onlyonenftking | address to resolve — Discord DM (Telegraph) for their Base wallet | Telegraph Season II | Builder of Gainsay, Pecos and Assize; tgp-guard was compared against his entry Nov 12 and stayed ahead. |
| 16 | escrix | `0xb903c132270a3ca9b8a2c9279d4243baf693aa1f` (Neynar primary verified address; 1 verified) | Farcaster / Base builders | Building AI-agent escrow on Base; George followed Nov 5 and replied on his Aegis casts, most recently Nov 11. |
| 17 | temhemc | `0x4604a0fd65843f8b6e7cd8e67c5e3dff7b0c9c12` (Neynar primary verified address; 2 verified) | Farcaster / Base builders | George replied Nov 5 on local-currency stablecoins on Base and again Nov 10 on his reliability article, which he also liked. |
| 18 | luciano | `0x6a0ba3707df9d13a4445cd7e04274b2725930cd7` (Neynar primary verified address; 3 verified) | Farcaster / Base builders | Base builder at Kismet and Base House Mumbai; George liked Nov 4 and Nov 7, followed Nov 6. |
| 19 | mikkodev.eth | `0x71dbf7a50efe49629768dc8a14fb0b2b7ce4ff2c` (Neynar primary verified address; 1 verified; ENS cross-check unavailable for Basename) | Farcaster / Base builders | Builder of Streema.gg (zero-fee direct-to-wallet USDC tips); George replied and liked Nov 3. |
| 20 | rakshasar.eth | `0xe9faa9702061163886f9f1f03d51d9d84bcd836b` (Neynar primary verified address; 3 verified; ENS cross-check unavailable for Basename) | Farcaster / Base builders | Creator on x402 trust gates on Base and the Aegis spend gate; George replied, liked and followed Nov 4. |
| 21 | 0xEddie (@0xeddiekim) | address to resolve — X DM for their Base wallet | Base builders (Preflight) | Replied to George's Preflight Solana post Nov 7 with a real transfer-fee bug; fix built, tested and pushed the same morning, crediting him. |
| 22 | Artist Xeature | address to resolve — Farcaster DM for their Base wallet | Farcaster / Hermes | Asked on George's Hermes post Nov 9 whether the guard catches spend inside a script; script-gate PR shipped the same day. |
| 23 | Devansh Mehta | address to resolve — X DM for their Base wallet | Deep Funding | Runs Deep Funding; George's v1 model ranked 2nd of 5 in Originality Round 3 (score 1.7718). |
| 24 | RyanB | address to resolve — X/email for their Base wallet | Cubed / Superteam | Editor at Cubed; invited George's swap.io article Nov 12, added him as a writer; George submitted the same day. |
| 25 | @smshakil | address to resolve — Farcaster DM for their Base wallet | Farcaster mini apps | Developer of Gig Bot 2.0 on Farcaster, which pays George for social tasks; the only route to swap the X account stored for George's Farcaster account. |
| 26 | kazani | `0xe97c29b17ed7d742e3843affa357449fa10a1855` (Neynar primary verified address; 4 verified) | Farcaster creators | Farcaster creator; George replied and liked Nov 3 on the Binance-hack post. |
| 27 | decent-artlu | `0xea51ddf4d06fdc5cd6564380fa8d05329edfdad6` (Neynar primary verified address; 1 verified) | Farcaster creators | Farcaster creator; George replied and liked Nov 4 on letting AI take the wheel and pre-flight checks. |
| 28 | hasnainshah | `0x16f0109b9d7db238e1f11c112b893ac44cb3744c` (Neynar primary verified address; 2 verified) | Farcaster creators | George replied Nov 7 and again Nov 10 on his Preflight Solana thread. |
| 29 | cashlessman.eth | `0x6100b29a235ebb272f4b10c1964ad9692ee67e13` (Neynar primary verified address; 3 verified; ENS cross-check unavailable for Basename) | Farcaster creators | Farcaster creator; George liked their 'Goodbye Mumbai' post Nov 7. |
| 30 | Walid (kzl27.eth) | `0x13dbc7d5ace21d1eeb5f884666e284138fbff620` (Neynar primary verified address; 2 verified; ENS cross-check unavailable for Basename) | Farcaster creators | Farcaster creator; George sent his Rug Club post Nov 8 for checking. |
| 31 | Ahmed Ali | address to resolve — identify full handle first (Telegraph Discord), then DM | Telegraph Season II | Telegraph builder; George closed his open ask for a third link-scan voter Nov 11, and he is the contact on Assize's pending comparator families. |
| 32 | Anthony (Countersign) | address to resolve — identify full handle first (Telegraph #showcase), then DM | Telegraph Season II | Builder of Countersign; live with 6 paid calls the same day it was read Nov 11. |
| 33 | vetted (builder handle unknown) | address to resolve — identify the builder behind the 'vetted' entry (Telegraph #showcase), then DM | Telegraph Season II | Builder of vetted, the #1-ranked Telegraph entry (Telegram bot + web app, x402 memo sales). |
| 34 | linza | `0x521d6c234c274f1b6d8850387c1c79f6cbff468e` (Neynar primary verified address; 3 verified) | Farcaster creators | Farcaster creator whose Pixel Fox mint cast George tracked down Nov 8; the cast led to the verified Mint Terminal mint check. |

## Block 3 — Daxin X group members (ai打新项目群)

| # | Handle / name | Wallet address | Source circle | Why they fit |
|---|---|---|---|---|
| 35 | 阿文 | address to resolve — ask in the X group chat for their Base wallet | Daxin X group | Group member; asked Nov 8 whether there was anything else to play. George built the Daxin Bot for this group. |
| 36 | Gavin.Jan | address to resolve — ask in the X group chat for their Base wallet | Daxin X group | Group member; noted Nov 8 that each Agent ID's first mint is free to grab attention. |
| 37 | Cc | address to resolve — ask in the X group chat for their Base wallet | Daxin X group | Group member; said Nov 8 to just take the free mint. |
| 38 | xi xi | address to resolve — ask in the X group chat for their Base wallet | Daxin X group | Group member; dropped the TeslAgent link in the group Nov 8. |

## Block 4 — Tier B: engaged / adopted their work

| # | Handle / name | Wallet address | Source circle | Why they fit |
|---|---|---|---|---|
| 39 | Alex Finn | address to resolve — X DM for their Base wallet | Agent use cases | Runs agentusecases.ai; George submitted three agent use cases Nov 4 (pending review). |
| 40 | CoderDaMing | address to resolve — X DM for their Base wallet | X creators | MoneyPrinterTurbo post led to a restricted render-only install Nov 4. |
| 41 | RitOnchain | address to resolve — X DM for their Base wallet | X creators | Quant-theory one-sheet sparked George's $10 trading experiment and 14-day paper test. |
| 42 | 0xrichboy | address to resolve — X DM for their Base wallet | X creators | Prabowo-NFT free-mint playbook reviewed Nov 4 and merged into the BNB hunter's standing rules. |
| 43 | awe0_io | address to resolve — X DM for their Base wallet | X creators | Horizon adopted Nov 6–7 from their posts. |
| 44 | dexterofweb3 | address to resolve — X DM for their Base wallet | X creators | Bread promo video became half of George's locked video standard. |
| 45 | LoneRogue8 | address to resolve — X DM for their Base wallet | X creators | Money Moves promo became the receipts-led proof half of his locked video standard. |
| 46 | Mikocrypto11 | address to resolve — X DM for their Base wallet | X creators | 24/7 AI trading desk post led to the Strategy P paper lane, built and live the same evening. |
| 47 | mr_mofun | address to resolve — X DM for their Base wallet | X creators | Grok Bot repos roundup led to Field Notes adoption and the HyperGrok trial. |
| 48 | DeRonin_ | address to resolve — X DM for their Base wallet | X creators | Uncensored-local-AI post led to the Ollama setup now live here and the Telegram bot running on it. |
| 49 | dopamine_crypto | address to resolve — X DM for their Base wallet | X creators | Posts led to the ScrapeCreators install and the youtube-agent-skill top-3 install for Alpha Toolkit. |
| 50 | Jakeschincariol | address to resolve — X DM for their Base wallet | YouTube skills | Author of the youtube-agent-skill repo George adopted Nov 7. |
| 51 | Tosi ola | address to resolve — X DM for their Base wallet | X creators / mints | NasalisFlow giveaway spot George won Nov 6 with his main wallet; on his mint watch list. |
| 52 | bolt_book | address to resolve — X DM for their Base wallet | X creators / Agent Wilds | Agent Wilds article led George to check the hero mint and join the game free Nov 5. |
| 53 | PoEFE (@poefe_app) | address to resolve — X DM for their Base wallet | Robinhood Chain mints | Behind the PoEFE Spectrum free mint on Robinhood Chain; George asked for its mint link and contract Nov 5. |
| 54 | CryptoBLACK0511 | address to resolve — X DM for their Base wallet | X creators / mints | Squeek testnet mint post led to a contract extraction and precheck Nov 5. |
| 55 | TheMaran | address to resolve — X DM for their Base wallet | X creators | Money-play posts sent Nov 4–5, including an Elysium guide and a Solana dust finder. |
| 56 | 0xWassie | address to resolve — X DM for their Base wallet | X creators / mints | Daily free-testnet curation post covering Squeek, Pocketpad, Primus x Kaito and Metric. |
| 57 | aifindr | address to resolve — X DM for their Base wallet | X creators | Claude Code skills roundup adopted Nov 11 as George's new video style (Bank 6 re-cut, swap.io v3/v4). |
| 58 | mdaman010 | address to resolve — X DM for their Base wallet | X creators | Starwire post led George to adopt Starwire-first tool discovery Nov 7. |
| 59 | Feljoy_ix | address to resolve — X DM for their Base wallet | X creators | Muse Video Creation Studio post led George to order his own Video Studio Space Nov 10. |
| 60 | ASED (@asedd72) | address to resolve — X DM for their Base wallet | X creators / testnets | Arc and Giwa testnet guides checked out and joined George's daily farm rotation Nov 10. |
| 61 | HoneyBiu | address to resolve — X DM for their Base wallet | X creators | Article on Muse freebie farming led to a standing rule on account-sensitive work Nov 10. |
| 62 | wangzan101 | address to resolve — X DM for their Base wallet | X creators | Developer behind Mika, the open-source Android phone agent audited Nov 11. |
| 63 | vibeman_0 | address to resolve — X DM for their Base wallet | X creators | FLOP devnet post led to the agent-connect lane; MCP verified read-only (34 tools). |
| 64 | 0xStephen_ | address to resolve — X DM for their Base wallet | X creators | Jack Butcher 'bars' mint guide checked live Nov 11. |
| 65 | bi_9527zx | address to resolve — X DM for their Base wallet | X creators | Meme Radar v2.2.0 post saved Nov 11 to forward to a friend who just installed Muse. |
| 66 | Keri Kramer | address to resolve — X/Devpost DM for their Base wallet | Hackathons (PayPal) | Devpost organizer who flagged George's PayPal entry Nov 11, prompting the same-night fix. |
| 67 | kane_120 | address to resolve — X DM for their Base wallet | X creators | Micro1 post prompted George's Generalist application (submitted Nov 8). |
| 68 | aiqiang888 | address to resolve — X DM for their Base wallet | X creators | HashDoge post led to a follow-up on the mining prompt and a full Hashcats check Nov 5. |
| 69 | Ylj158852 | address to resolve — X DM for their Base wallet | X creators | Posts on free pu.gy subdomains, free-for-dev directory and a reopened Cloady tier. |
| 70 | laobaishare | address to resolve — X DM for their Base wallet | X creators | 35-useful-websites list; Pixabay and Mixkit entries matter for MoneyPrinterTurbo stock footage. |
| 71 | suraj_sharma14 | address to resolve — X DM for their Base wallet | X creators | 2027 meta agent-engineering build list; half maps onto the tgp-guard and Aegis roadmap. |
| 72 | sankitdev | address to resolve — X DM for their Base wallet | X creators | '5 Claude skills' post audited Nov 6; three skills map onto George's real work. |
| 73 | trungkts29 | address to resolve — X DM for their Base wallet | X creators | Scrapling scraping-framework post led to an audit and live Cloudflare trial. |
| 74 | HeLi8866 | address to resolve — X DM for their Base wallet | X creators | SAPPER autonomous pentesting swarm post led to a full audit Nov 6. |
| 75 | taiyanghere | address to resolve — X DM for their Base wallet | X creators | Box by Simular post; Muse checked Simular's real terms and ruled Box out as the dsh-Go build machine. |
| 76 | zefirium | address to resolve — X DM for their Base wallet | X creators | Free frontier-model routes roundup; OrcaRouter free DeepSeek is now Horizon's wired fallback. |
| 77 | mfBRAT_eth | address to resolve — X DM for their Base wallet | X creators / mints | Behind the squeek.mfbrat.com Squeek fan site; Ping mechanism verified Nov 7. |
| 78 | ShuaiMaLong | address to resolve — X DM for their Base wallet | X creators | Nov 7 AI freebie roundup surfaced the Exa credit George claimed ($60). |

## Block 6 — Launch-cast engagers (slots reserved, identities unknown until the cast goes out)

Per the spec, Founding includes Farcaster followers who engage with the launch cast. Those people cannot be named until the cast is posted. This block reserves **122 slots (#79–#200)**. The first 10 are shown as placeholders; slots #89–#200 follow the same pattern.

Fill rule (to confirm with George): after the launch cast posts, take engagers in this order — (1) people who reply with substance, (2) reposters, (3) likers — resolve each to a Neynar verified address, dedupe against Blocks 0–5, and fill in order until the 200 cap is reached. Any named candidate whose address never resolves drops out and frees its slot to this block. Cutoff: when the Founding window closes (~7 days) or the 200 fills, whichever comes first.

| # | Handle / name | Wallet address | Source circle | Why they fit |
|---|---|---|---|---|
| 79 | Launch-cast engager #1 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 80 | Launch-cast engager #2 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 81 | Launch-cast engager #3 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 82 | Launch-cast engager #4 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 83 | Launch-cast engager #5 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 84 | Launch-cast engager #6 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 85 | Launch-cast engager #7 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 86 | Launch-cast engager #8 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 87 | Launch-cast engager #9 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |
| 88 | Launch-cast engager #10 | address to resolve — Neynar verified address for the engager's FID | Launch cast (Farcaster) | Engaged with the MintMate Pass launch cast; rank by reply > repost > like. |

*Slots #89–#200 (112 more) follow the same pattern — same fill rule, same resolution method.*

## What is still missing before this list can be finalized

1. **Unresolved addresses — the big one.** Only 3 of 200 rows have a wallet address (George's own 3). 75 named rows need their address resolved (Neynar for Farcaster users, DM for X creators, X group chat for Daxin, Discord DM for Telegraph builders) and 122 engager slots need the launch cast to happen first. No Merkle root can be computed until the final 200 addresses are in hand.
2. **George's decisions — DECIDED 2026-11-12 17:08 WAT:** P2P wallet OUT, Davinci OUT, Tier C CUT (all applied above). Still open:
   - Engager fill rule: confirm reply > repost > like ranking, the cutoff time, and how many of the 200 stay reserved for engagers (now 122 after the cuts).
   - George's own 3 wallets: claim a Founding pass each, or skip claiming since the gate bypasses them anyway?
3. **Identities to pin down first:** Ahmed Ali (#33, full handle unknown), Anthony / Countersign (#34, full handle unknown), the builder behind 'vetted' (#35, handle unknown). No address can be resolved until the person is identified.
4. **Circles with no names in the sources:** Elysium project teams (Punks, Gloom, slymz, Montra) are unnamed in the records — George to name contacts if he wants any of them in Founding. The /base-builds channel hosts are also unnamed. INA699 (Field Atlas rival claimant on issue #26, settled in George's favour) was deliberately excluded — confirm that stands.
5. **Separate track, not this list:** pass art/metadata and the base URI must be set before any claim opens (it locks at the first mint). The Merkle root is computed only after this list is final — it has not been computed here, per instructions.
