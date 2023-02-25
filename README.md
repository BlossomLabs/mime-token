# Mime Token [![test][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license] <a href="#"><img align="right" src=".github/assets/blossom-labs.svg" height="80px" /></a>

[gha]: https://github.com/BlossomLabs/mime-token/actions/workflows/test.yml
[gha-badge]: https://github.com/BlossomLabs/mime-token/actions/workflows/test.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

MimeToken is a non-transferable token that inherits from the [ERC20 standard](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/) and implements a modified version the [Uniswap MerkleDistributor](https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol) logic. It allows accounts to claim their balances from an existing token by providing a merkle proof. The token uses a merkle tree of claims to store the balances, which can be updated to a new snapshot using a round functionality.

## Motivation

The purpose of MimeToken is to improve the user adoption on a multi-chain ecosystem by reducing the friction of onboarding. The current onboarding process when trying to use a protocol on a new chain is to transfer tokens to that chain, which requires the user to pay for the gas fees. This is a major barrier to entry for new users, especially for those who are not familiar with the process. 

MimeToken allows users to claim their balances from an existing token by providing a merkle proof generated by the front-end, similar to an airdrop process. This allow for more experimentation with new chains and protocols without the need to transfer tokens across chain.

## License

[MIT](./LICENSE.md) © Blossom Labs