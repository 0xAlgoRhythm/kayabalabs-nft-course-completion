
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