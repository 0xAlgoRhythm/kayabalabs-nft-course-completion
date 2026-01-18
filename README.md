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

---

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