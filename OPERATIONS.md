
### Option 2: Bulk Mint (You Mint, They Pay via Stripe)

**When to use:** Most students (easier, better UX)

#### Process:

1. **Collect wallet addresses during enrollment**

Sample form fields:
```
Full Name: _________________
Email: _________________
Wallet Address: _________________
(Don't have one? Click here for guide)
```

2. **Students complete course**

3. **Collect payment via Stripe:**

```
Product: NFT Course Certificate
Price: $0.50
Description: Blockchain certificate minted to your wallet
```

4. **Export paid students from database**

Create `students.csv`:
```csv
wallet,completion_date
0x1234567890abcdef1234567890abcdef12345678,January 18 2026
0xabcdef1234567890abcdef1234567890abcdef12,January 18 2026
0x567890abcdef1234567890abcdef1234567890ab,January 19 2026
```

5. **Run weekly bulk mint script:**

```bash
#!/bin/bash
# bulk-mint.sh

# Load environment
source .env

# Student data
WALLETS='["0x1234567890abcdef1234567890abcdef12345678","0xabcdef1234567890abcdef1234567890abcdef12","0x567890abcdef1234567890abcdef1234567890ab"]'
DATES='["January 18 2026","January 18 2026","January 19 2026"]'
COURSE="Solidity Fundamentals"

# Bulk mint
cast send $CONTRACT_ADDRESS \
    "batchMintCertificates(address[],string,string[])" \
    "$WALLETS" \
    "$COURSE" \
    "$DATES" \
    --rpc-url $SCROLL_MAINNET_RPC_URL \
    --private-key $PRIVATE_KEY

echo "✅ Certificates minted for $(echo $WALLETS | grep -o '0x' | wc -l) students"
```

6. **Send confirmation emails:**

```
Subject: ✅ Your Certificate Has Been Minted!

Hi [Student Name],

Your NFT certificate has been minted to your wallet!

🆔 Student ID: KL-SOL-0042
📅 Completion Date: January 18, 2026
📚 Course: Solidity Fundamentals

VIEW YOUR CERTIFICATE:
- OpenSea: https://opensea.io/assets/scroll/CONTRACT_ADDRESS/41
- Explorer: https://scrollscan.com/token/CONTRACT_ADDRESS?a=41
- Your Wallet: Open MetaMask → NFTs tab

This certificate is soulbound and cannot be transferred.

Congratulations!
Kayaba Labs Team
```

---

## 💰 Fee Management

### Check Collected Fees

```bash
# Check contract balance
cast balance $CONTRACT_ADDRESS --rpc-url $SCROLL_MAINNET_RPC_URL
```

### Withdraw Fees (Monthly Recommended)

```bash
# Withdraw all collected fees to your wallet
cast send $CONTRACT_ADDRESS \
    "withdrawFees()" \
    --rpc-url $SCROLL_MAINNET_RPC_URL \
    --private-key $PRIVATE_KEY

# Verify withdrawal
cast balance YOUR_WALLET_ADDRESS --rpc-url $SCROLL_MAINNET_RPC_URL
```

**Best Practice:** Withdraw monthly or when balance reaches threshold (e.g., $50+)

---

## 📊 Monitoring & Analytics

### Daily Checks

```bash
# Total certificates minted
cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $SCROLL_MAINNET_RPC_URL

# Contract balance (fees collected)
cast balance $CONTRACT_ADDRESS --rpc-url $SCROLL_MAINNET_RPC_URL

# Last minted token info
LAST_TOKEN=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $SCROLL_MAINNET_RPC_URL)
LAST_TOKEN=$((LAST_TOKEN - 1))
cast call $CONTRACT_ADDRESS "getCertificateInfo(uint256)" $LAST_TOKEN --rpc-url $SCROLL_MAINNET_RPC_URL
```

### Weekly Reports

Create `weekly-report.sh`:

```bash
#!/bin/bash
source .env

echo "=== Kayaba Labs NFT Certificate Report ==="
echo "Week of: $(date)"
echo ""

TOTAL=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $SCROLL_MAINNET_RPC_URL)
BALANCE=$(cast balance $CONTRACT_ADDRESS --rpc-url $SCROLL_MAINNET_RPC_URL)

echo "Total Certificates Minted: $TOTAL"
echo "Fees Collected: $BALANCE wei"
echo "Revenue (USD): Approximately $$(echo "scale=2; $TOTAL * 0.50" | bc)"
echo ""
echo "View on OpenSea: https://opensea.io/collection/..."
echo "View on Explorer: https://scrollscan.com/address/$CONTRACT_ADDRESS"
```

---

## 🔧 Common Operations

### 1. Mint Single Certificate (Manual)

```bash
cast send $CONTRACT_ADDRESS \
    "mintCertificate(address,string,string)" \
    STUDENT_WALLET \
    "Solidity Fundamentals" \
    "January 18, 2026" \
    --value 0.0003ether \
    --rpc-url $SCROLL_MAINNET_RPC_URL \
    --private-key $PRIVATE_KEY
```

### 2. Check Student's Certificate

```bash
# Get student ID for token
cast call $CONTRACT_ADDRESS "getStudentId(uint256)" TOKEN_ID --rpc-url $SCROLL_MAINNET_RPC_URL

# Get full certificate info
cast call $CONTRACT_ADDRESS "getCertificateInfo(uint256)" TOKEN_ID --rpc-url $SCROLL_MAINNET_RPC_URL
```

### 3. Find All Certificates for a Wallet

```bash
# Get all token IDs owned by wallet
cast call $CONTRACT_ADDRESS "getStudentCertificates(address)" WALLET_ADDRESS --rpc-url $SCROLL_MAINNET_RPC_URL
```

### 4. Update Metadata URI (if needed)

```bash
# Only if you need to change metadata location
cast send $CONTRACT_ADDRESS \
    "setMetadataURI(string)" \
    "NEW_METADATA_URI" \
    --rpc-url $SCROLL_MAINNET_RPC_URL \
    --private-key $PRIVATE_KEY
```

### 5. Update Course Prefix (if needed)

```bash
# Change prefix from KL-SOL to something else
cast send $CONTRACT_ADDRESS \
    "setCoursePrefix(string)" \
    "NEW-PREFIX" \
    --rpc-url $SCROLL_MAINNET_RPC_URL \
    --private-key $PRIVATE_KEY
```

---

## 📧 Email Templates

### Course Completion (Self-Mint Option)

```
Subject: 🎉 Claim Your Certificate NFT

Hi {STUDENT_NAME},

Congratulations on completing {COURSE_NAME}!

Claim your blockchain certificate:
👉 {MINT_URL}

Cost: $0.50 (instant)
Requirements: MetaMask + Scroll ETH

Your certificate will be:
✅ Permanent blockchain record
✅ Visible on OpenSea
✅ Non-transferable (soulbound)

Questions? Reply to this email.

Best,
Kayaba Labs Team
```

### Certificate Minted (Bulk Mint)

```
Subject: ✅ Your Certificate is Ready!

Hi {STUDENT_NAME},

Your certificate has been minted!

🆔 Student ID: {STUDENT_ID}
📚 Course: {COURSE_NAME}
📅 Completed: {COMPLETION_DATE}

View Certificate:
- OpenSea: {OPENSEA_LINK}
- Explorer: {EXPLORER_LINK}

The certificate is in your wallet:
{WALLET_ADDRESS}

Open MetaMask → NFTs tab to see it!

Congratulations,
Kayaba Labs Team
```

### Reminder (Haven't Minted Yet)

```
Subject: ⏰ Don't forget your certificate!

Hi {STUDENT_NAME},

You haven't claimed your course certificate yet.

Claim now: {MINT_URL}

Your achievement deserves recognition!
Certificate expires: Never (claim anytime)

Need help? Reply to this email.

Best,
Kayaba Labs Team
```

---

## 🆘 Student Support FAQ

### "I don't have a wallet"

**Response:**
```
No problem! Here's how to get started:

1. Install MetaMask: https://metamask.io
2. Create new wallet (save your seed phrase!)
3. Get your wallet address (0x...)
4. Send it to us or use it to mint

Video guide: {YOUR_TUTORIAL_LINK}

Need help? We can mint for you if you provide your wallet address.
```

### "How do I get ETH on Scroll?"

**Response:**
```
You can get ETH on Scroll in two ways:

OPTION 1 - Bridge (if you have ETH on Ethereum):
1. Go to: https://scroll.io/bridge
2. Connect MetaMask
3. Bridge minimum 0.001 ETH
4. Wait 15 minutes

OPTION 2 - Buy from Exchange:
1. Buy ETH on Binance/Coinbase
2. Withdraw to Scroll network
3. Use your MetaMask address

OR: We can mint for you! Just pay $0.50 via Stripe and provide your wallet address.
```

### "Where is my NFT?"

**Response:**
```
Your NFT is in your wallet! View it:

METHOD 1 - MetaMask:
1. Open MetaMask
2. Switch to Scroll network
3. Click "NFTs" tab
4. You should see "Kayaba Labs Certificate"

METHOD 2 - OpenSea:
Go to: https://opensea.io/assets/scroll/{CONTRACT_ADDRESS}/{TOKEN_ID}

METHOD 3 - Check on Explorer:
Go to: https://scrollscan.com/token/{CONTRACT_ADDRESS}?a={TOKEN_ID}

Still don't see it? Reply with your wallet address and we'll check.
```

### "Can I transfer my certificate?"

**Response:**
```
No, certificates are "soulbound" - they cannot be transferred.

This ensures:
✅ Authentic verification (you earned it!)
✅ Cannot be sold or given away
✅ Permanent proof of YOUR achievement

The certificate stays with your wallet forever.
```

### "I lost access to my wallet"

**Response:**
```
Unfortunately, we cannot recover access to your wallet.

HOWEVER, we can mint a new certificate to a new wallet address:
1. Create a new MetaMask wallet
2. Send us the new address
3. We'll mint a duplicate certificate (one-time exception)

For future: ALWAYS backup your seed phrase!
```

---

## 📈 Growth & Scaling

### When to Create New Contracts

Create separate contracts for:
- ✅ Different courses (Solidity vs Rust vs Move)
- ✅ Different achievement types (Hackathons, Projects)
- ✅ Different organizations/partners
- ✅ Major curriculum updates

### Batch Mint Limits

Safe batch sizes:
- **10-50 students:** Single transaction
- **50-100 students:** Still fine, ~$1-2 gas
- **100-500 students:** Consider 2-3 batches
- **500+ students:** Split into 100-student batches

### Automation Opportunities

**Consider building:**
1. Automated minting on course completion
2. Payment webhook integration (Stripe → Auto-mint)
3. Student dashboard to view certificates
4. Analytics dashboard for your team
5. API for third-party integrations

---

## 🔐 Security Best Practices

### Daily Operations

- ✅ Never share private key
- ✅ Use hardware wallet for large operations
- ✅ Verify contract address before transactions
- ✅ Test on small batches first
- ✅ Keep backup of all student data
- ✅ Monitor contract for suspicious activity
- ✅ Withdraw fees regularly (don't let large balance accumulate)

### Access Control

- ✅ Only owner can batch mint (already enforced)
- ✅ Only owner can withdraw fees (already enforced)
- ✅ Keep deployment wallet separate from personal wallet
- ✅ Use multi-sig for high-value operations (future)

---

## 📊 Success Metrics

Track these monthly:

| Metric | Target | Actual |
|--------|--------|--------|
| Certificates Minted | 100+ | ___ |
| Self-Mint Rate | 70% | ___ |
| Bulk Mint Rate | 30% | ___ |
| Fees Collected | $50+ | ___ |
| Support Tickets | <5 | ___ |
| OpenSea Views | 500+ | ___ |
| Student Satisfaction | 4.5/5 | ___ |

---

## 🎯 Monthly Checklist

- [ ] Withdraw collected fees
- [ ] Review total certificates minted
- [ ] Check for failed transactions
- [ ] Update student records
- [ ] Send reminder emails to non-claimers
- [ ] Review OpenSea collection performance
- [ ] Update metadata if needed
- [ ] Backup student wallet list
- [ ] Generate monthly report
- [ ] Plan next cohort certificates

---

## 📞 Emergency Procedures

### Issue: Contract Compromised

1. Stop all operations immediately
2. Withdraw all fees if possible
3. Deploy new contract
4. Notify students
5. Migrate to new contract

### Issue: Wrong Certificate Minted

**Cannot delete NFTs**, but you can:
1. Mint correct certificate to student
2. Notify student to ignore wrong one
3. Update internal records
4. Learn from mistake

### Issue: Student Lost Wallet

1. Verify identity thoroughly
2. Mint new certificate to new wallet
3. Mark old certificate as "replaced" in records
4. One-time exception only

---

**For technical issues, see DEPLOYMENT.md troubleshooting section.**