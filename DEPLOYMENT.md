# Kayaba Labs NFT Certificate - Mainnet Deployment Guide

## 📋 Prerequisites Checklist

Before deploying to mainnet, ensure you have:

- [ ] Contract tested on Sepolia testnet
- [ ] At least 2-3 test certificates minted successfully
- [ ] Metadata uploaded to Pinata/Lighthouse
- [ ] Metadata URL tested and accessible
- [ ] Image displays correctly on test mints
- [ ] ~$5-10 worth of ETH on your chosen network
- [ ] Private key backed up securely
- [ ] Contract code reviewed and finalized

---

## 🎯 Recommended Networks & Costs

| Network | Deploy Cost | Mint Cost | OpenSea Support | Best For |
|---------|-------------|-----------|-----------------|----------|
| **Scroll** | $2-5 | $0.01-0.05 | ✅ Yes | Low fees, zkEVM |
| **Base** | $2-5 | $0.01-0.05 | ✅ Yes | Coinbase backing |
| **Arbitrum** | $2-5 | $0.01-0.05 | ✅ Yes | Established ecosystem |
| **Optimism** | $2-5 | $0.01-0.05 | ✅ Yes | Retroactive funding |
| **Polygon** | $1-3 | $0.005-0.02 | ✅ Yes | Cheapest option |

**Recommendation:** Start with **Scroll** or **Base** for best balance of cost and features.

---

## 🚀 Step-by-Step Deployment

### Step 1: Prepare Environment

```bash
# Navigate to project directory
cd /mnt/c/Users/user/desktop/kayabalabs-nft

# Ensure .env file exists
ls -la .env
```

### Step 2: Update Environment Variables

Edit `.env` file:

```bash
nano .env
```

Add mainnet configuration:

```bash
# Your wallet private key (NEVER share this!)
PRIVATE_KEY=your_private_key_here

# Network RPC URLs
SCROLL_MAINNET_RPC_URL=https://rpc.scroll.io
BASE_MAINNET_RPC_URL=https://mainnet.base.org
ARBITRUM_MAINNET_RPC_URL=https://arb1.arbitrum.io/rpc
OPTIMISM_MAINNET_RPC_URL=https://mainnet.optimism.io
POLYGON_MAINNET_RPC_URL=https://polygon-rpc.com

# Block Explorer API Keys (for verification)
SCROLLSCAN_API_KEY=your_api_key_here
BASESCAN_API_KEY=your_api_key_here
ARBISCAN_API_KEY=your_api_key_here
OPTIMISM_API_KEY=your_api_key_here
POLYGONSCAN_API_KEY=your_api_key_here

# Metadata URL (from Pinata/Lighthouse)
METADATA_URI=https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreigwxq3idiphzvosbd55ytwcgbdeatr26aaqw4osvk7yw4jydvjolu

# Course prefix for student IDs
COURSE_PREFIX=KL-SOL
```

Save and exit (Ctrl+X, Y, Enter)

```bash
# Load environment variables
source .env
```

### Step 3: Get Mainnet ETH

#### For Scroll:
1. **Bridge from Ethereum:**
   - Go to: https://scroll.io/bridge
   - Connect wallet
   - Bridge 0.01 ETH (enough for deployment + several mints)
   - Wait ~15 minutes

2. **Or Buy Direct:**
   - Binance/OKX: Withdraw to Scroll network
   - Use DEX: Swap on Scroll

#### For Base:
1. **Bridge from Ethereum:**
   - Go to: https://bridge.base.org
   - Bridge 0.01 ETH
   
2. **Or Coinbase:**
   - Withdraw directly to Base network

#### For Other Networks:
- Use official bridges or CEX withdrawals

### Step 4: Verify Your Balance

```bash
# Check balance on Scroll
cast balance YOUR_WALLET_ADDRESS --rpc-url $SCROLL_MAINNET_RPC_URL

# Check balance on Base
cast balance YOUR_WALLET_ADDRESS --rpc-url $BASE_MAINNET_RPC_URL
```

Should show at least `10000000000000000` (0.01 ETH)

### Step 5: Review Deployment Script

```bash
cat script/DeployCourseNFT.s.sol
```

Verify:
- ✅ Correct metadata URI
- ✅ Correct course prefix (KL-SOL)
- ✅ Network RPC URL matches your target

### Step 6: Final Contract Check

```bash
# Clean build
forge clean

# Build contract
forge build

# Should compile successfully with no errors
```

### Step 7: Deploy to Mainnet

**For Scroll:**

```bash
forge script script/DeployCourseNFT.s.sol:DeployCourseNFT \
    --rpc-url $SCROLL_MAINNET_RPC_URL \
    --broadcast \
    --verify \
    -vvvv
```

**For Base:**

```bash
forge script script/DeployCourseNFT.s.sol:DeployCourseNFT \
    --rpc-url $BASE_MAINNET_RPC_URL \
    --broadcast \
    --verify \
    -vvvv
```

**For Arbitrum:**

```bash
forge script script/DeployCourseNFT.s.sol:DeployCourseNFT \
    --rpc-url $ARBITRUM_MAINNET_RPC_URL \
    --broadcast \
    --verify \
    -vvvv
```

### Step 8: Save Contract Address

After deployment, you'll see:

```
Contract Address: 0x1234567890abcdef1234567890abcdef12345678
```

**CRITICAL: Save this address immediately!**

```bash
# Save to .env
echo "CONTRACT_ADDRESS=0x1234567890abcdef1234567890abcdef12345678" >> .env
source .env

# Also save to a file
echo "CONTRACT_ADDRESS=0x1234567890abcdef1234567890abcdef12345678" > contract-address.txt
echo "NETWORK=scroll" >> contract-address.txt
echo "DEPLOYED_AT=$(date)" >> contract-address.txt
```

### Step 9: Verify Contract (if auto-verify failed)

**For Scroll:**

```bash
forge verify-contract \
    $CONTRACT_ADDRESS \
    src/KayabaCourseCompletionNFT.sol:KayabaCourseCompletionNFT \
    --chain-id 534352 \
    --constructor-args $(cast abi-encode "constructor(string,string)" "$METADATA_URI" "$COURSE_PREFIX") \
    --etherscan-api-key $SCROLLSCAN_API_KEY
```

**For Base:**

```bash
forge verify-contract \
    $CONTRACT_ADDRESS \
    src/KayabaCourseCompletionNFT.sol:KayabaCourseCompletionNFT \
    --chain-id 8453 \
    --constructor-args $(cast abi-encode "constructor(string,string)" "$METADATA_URI" "$COURSE_PREFIX") \
    --etherscan-api-key $BASESCAN_API_KEY
```

### Step 10: Test Mint First Certificate

```bash
# Mint your first mainnet certificate
cast send $CONTRACT_ADDRESS \
    "mintCertificate(address,string,string)" \
    YOUR_WALLET_ADDRESS \
    "Solidity Fundamentals" \
    "January 18, 2026" \
    --value 0.0003ether \
    --rpc-url $SCROLL_MAINNET_RPC_URL \
    --private-key $PRIVATE_KEY
```

### Step 11: Verify Everything Works

**Check contract on block explorer:**

Scroll: `https://scrollscan.com/address/$CONTRACT_ADDRESS`
Base: `https://basescan.org/address/$CONTRACT_ADDRESS`

**Verify certificate info:**

```bash
cast call $CONTRACT_ADDRESS "getStudentId(uint256)" 0 --rpc-url $SCROLL_MAINNET_RPC_URL
```

Should return: `KL-SOL-0001`

**Check OpenSea (wait 15-30 minutes):**

```
https://opensea.io/assets/scroll/$CONTRACT_ADDRESS/0
```

### Step 12: Document Deployment

Create `DEPLOYMENT_INFO.md`:

```markdown
# Deployment Information

**Network:** Scroll Mainnet
**Contract Address:** 0x1234567890abcdef1234567890abcdef12345678
**Deployed By:** 0xYourWalletAddress
**Deployment Date:** January 18, 2026
**Deployment TX:** 0xTransactionHash
**Gas Used:** XXX
**Deployment Cost:** 0.XXX ETH

## Links
- Contract: https://scrollscan.com/address/0x...
- OpenSea: https://opensea.io/collection/...
- Metadata: https://coral-genuine-koi-966.mypinata.cloud/ipfs/...

## Configuration
- Course Prefix: KL-SOL
- Mint Fee: 0.0003 ETH (~$0.50)
- Total Supply: Unlimited
- Soulbound: Yes
```

---

## ⚠️ Important Security Notes

### 🔒 Protect Your Private Key

**NEVER:**
- ❌ Share your private key
- ❌ Commit .env to git
- ❌ Post it in Discord/Telegram
- ❌ Store in plain text online

**DO:**
- ✅ Keep .env in .gitignore
- ✅ Use hardware wallet for large amounts
- ✅ Backup private key offline (paper/encrypted USB)
- ✅ Use different wallet for deployment vs personal funds

### 🔐 .gitignore Setup

Ensure `.gitignore` contains:

```
.env
*.env
contract-address.txt
broadcast/
cache/
out/
```

---

## ✅ Post-Deployment Checklist

After successful deployment:

- [ ] Contract address saved in multiple locations
- [ ] Contract verified on block explorer
- [ ] Test certificate minted successfully
- [ ] Certificate visible on OpenSea (after 30 mins)
- [ ] Metadata loads correctly
- [ ] Image displays properly
- [ ] Student ID auto-generation works (KL-SOL-0001)
- [ ] Soulbound transfer prevention works
- [ ] Owner can batch mint
- [ ] Fees can be withdrawn
- [ ] Deployment documented in DEPLOYMENT_INFO.md
- [ ] Private key secured
- [ ] .env file not committed to git

---

## 🆘 Troubleshooting

### Issue: "Insufficient funds for gas"

**Solution:**
```bash
# Check your balance
cast balance YOUR_WALLET_ADDRESS --rpc-url $SCROLL_MAINNET_RPC_URL

# Get more ETH from bridge or CEX
```

### Issue: Contract verification failed

**Solution:**
```bash
# Wait 2-3 minutes, then manually verify
forge verify-contract $CONTRACT_ADDRESS \
    src/KayabaCourseCompletionNFT.sol:KayabaCourseCompletionNFT \
    --chain-id 534352 \
    --constructor-args $(cast abi-encode "constructor(string,string)" "$METADATA_URI" "$COURSE_PREFIX")
```

### Issue: NFT not showing on OpenSea

**Solution:**
1. Wait 30 minutes minimum
2. Click "Refresh metadata" on OpenSea
3. Verify metadata URL works in browser
4. Check image URL is accessible

### Issue: Transaction pending forever

**Solution:**
```bash
# Check transaction status
cast tx TRANSACTION_HASH --rpc-url $SCROLL_MAINNET_RPC_URL

# If stuck, try increasing gas price on next transaction
```

---

## 📊 Cost Tracking

Keep track of your deployment costs:

| Item | Cost (ETH) | Cost (USD) |
|------|------------|------------|
| Deployment | 0.00XX | $X.XX |
| Test Mint | 0.0003 | $0.XX |
| Verification | 0.00XX | $0.XX |
| **Total** | **0.00XX** | **$X.XX** |

---

## 🎯 Next Steps

After successful deployment:

1. ✅ Update website with contract address
2. ✅ Create minting interface for students
3. ✅ Set up bulk minting workflow
4. ✅ Configure payment processing (Stripe)
5. ✅ Test end-to-end student flow
6. ✅ Prepare marketing materials
7. ✅ Launch to first cohort

See `OPERATIONS.md` for ongoing management instructions.

---

## 📞 Support

If you encounter issues:

1. Check transaction on block explorer
2. Verify RPC endpoint is working
3. Ensure sufficient ETH for gas
4. Review Foundry documentation: https://book.getfoundry.sh/
5. Check network status pages

---

**Congratulations on deploying to mainnet! 🎉**