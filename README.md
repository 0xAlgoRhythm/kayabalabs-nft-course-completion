## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

- ✅ Batch minting (owner only)
- ✅ Fee withdrawal
- ✅ Auto student ID generation
- ✅ Soulbound transfer prevention
- ✅ Certificate info retrieval

### Manual Testing on Sepolia

```bash
# Mint test certificate
cast send 0x5f303F0F87a0A64292C784A3De47CB59edF4035C \
    "mintCertificate(address,string,string)" \
    YOUR_WALLET \
    "Solidity Fundamentals" \
    "January 18, 2026" \
    --value 0.0003ether \
    --rpc-url https://sepolia.drpc.org \
    --private-key $PRIVATE_KEY
```

---

## 📋 What's Left to Build

### Phase 1: Immediate (Pre-Launch)
- [ ] Deploy to mainnet (Scroll/Base recommended)
- [ ] Test mainnet deployment with 1-2 certificates
- [ ] Verify OpenSea integration works
- [ ] Create basic minting website for students

### Phase 2: Launch Ready
- [ ] Build student self-mint interface (HTML/React)
- [ ] Integrate Stripe for bulk mint payments
- [ ] Create email templates for notifications
- [ ] Setup automated weekly bulk mint script
- [ ] Create student wallet collection form

### Phase 3: Enhancement
- [ ] Build admin dashboard for monitoring
- [ ] Add analytics tracking (total mints, revenue, etc.)
- [ ] Create certificate verification page (check by student ID)
- [ ] Integrate with course platform (auto-mint on completion)
- [ ] Add certificate gallery for students

### Phase 4: Expansion
- [ ] Deploy separate contracts for different courses
- [ ] Create hackathon achievement NFT contract
- [ ] Add project completion NFT contract
- [ ] Build community contributor NFT system
- [ ] Partner integrations (LinkedIn, Gitcoin Passport)

### Phase 5: Advanced Features
- [ ] Multi-signature wallet for fee withdrawals
- [ ] Dynamic metadata (update course info post-mint)
- [ ] Rarity/achievement levels
- [ ] Certificate renewal/expiration system
- [ ] Cross-chain certificate bridge

---

## 🎯 Immediate Next Steps

### Step 1: Deploy to Mainnet (1 hour)
Follow `DEPLOYMENT.md` to deploy to Scroll or Base

### Step 2: Mint Test Certificates (15 minutes)
Mint 2-3 test certificates to verify everything works

### Step 3: Verify OpenSea Integration (30 minutes)
Wait 30 minutes, check if certificates appear on OpenSea

### Step 4: Build Minting Page (2-4 hours)
Create simple HTML page for student self-minting

### Step 5: Setup Payment Processing (2-3 hours)
Integrate Stripe for bulk mint option

**Estimated Time to Launch:** 1-2 days

---

## 📊 Success Metrics (30-Day Goals)

- [ ] Contract deployed to mainnet
- [ ] 50+ certificates minted
- [ ] $25+ in fees collected
- [ ] 90%+ student satisfaction
- [ ] <5 support tickets
- [ ] Certificates visible on OpenSea
- [ ] Zero security incidents

---

## 🔐 Security Considerations

### Implemented ✅
- ✅ Ownable pattern (only owner can batch mint)
- ✅ Fee validation (requires exact payment)
- ✅ Soulbound transfers (prevents selling)
- ✅ Input validation (non-empty course names)
- ✅ Excess payment refunds

### Future Enhancements
- [ ] Multi-signature wallet for withdrawals
- [ ] Rate limiting on minting
- [ ] Emergency pause functionality
- [ ] Upgradeable proxy pattern (if needed)

---

## 📚 Documentation

- **README.md** (this file) - Project overview and status
- **DEPLOYMENT.md** - Step-by-step mainnet deployment guide
- **OPERATIONS.md** - Day-to-day operations and student management
- **Contract Comments** - Inline documentation in Solidity code

---

## 🤝 Contributing

This is a private project for Kayaba Labs. For questions or suggestions:
- Review documentation files
- Check smart contract comments
- Test on Sepolia before mainnet changes

---

## 📜 License

MIT License - See contract header for details

---

## 🔗 Links

**Test Deployment:**
- Contract: https://sepolia.etherscan.io/address/0x5f303F0F87a0A64292C784A3De47CB59edF4035C
- Metadata: https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreia6rxkezois2eymzxbikacx5egnrfvteqsky6gcswscjzmlummccu

**Documentation:**
- Foundry: https://book.getfoundry.sh/
- OpenZeppelin: https://docs.openzeppelin.com/
- Scroll: https://docs.scroll.io/
- Base: https://docs.base.org/

**Tools:**
- Pinata (IPFS): https://pinata.cloud
- Lighthouse: https://lighthouse.storage
- OpenSea: https://opensea.io
- Etherscan: https://etherscan.io

---

## 📞 Support

For technical issues:
1. Check DEPLOYMENT.md troubleshooting section
2. Check OPERATIONS.md for common questions
3. Review contract code and comments
4. Test on Sepolia before mainnet

---

## 🎉 Project Status Summary

**Stage:** Production Ready ✅
**Test Status:** Passed ✅
**Mainnet Status:** Ready to Deploy 🚀
**Documentation:** Complete ✅
**Next Action:** Deploy to mainnet (Scroll/Base recommended)

**Estimated Launch Timeline:** 1-2 days

---

**Built with ❤️ for Kayaba Labs students**

Last Updated: January 18, 2026
Version: 1.0.0