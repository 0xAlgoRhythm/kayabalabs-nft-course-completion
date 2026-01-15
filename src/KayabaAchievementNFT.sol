// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "..lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "..lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import "..lib/openzeppelin-contracts/contracts/utils/Strings.sol";

import "..lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract KayabaAchievementNFT is ERC721, ERC721URIStorage, Ownable {
    using Strings for uint256;

    uint256 private _nextTokenId;
    uint256 public constant MINT_FEE = 0.0003 ether; // ~$0.50 on L2s (adjust based on ETH price)
    
    // Achievement types
    enum AchievementType {
        COURSE_COMPLETION,
        HACKATHON_WINNER,
        HACKATHON_PARTICIPANT
    }

    // Mapping from token ID to achievement type
    mapping(uint256 => AchievementType) public tokenAchievements;
    
    // Mapping from token ID to achievement details
    mapping(uint256 => string) public achievementDetails;
    
    // Base URI for metadata
    string private _baseTokenURI;
    
    // Events
    event AchievementMinted(
        address indexed recipient,
        uint256 indexed tokenId,
        AchievementType achievementType,
        string details
    );

    event FundsWithdrawn(address indexed owner, uint256 amount);
    
    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) ERC721(name, symbol) Ownable(msg.sender) {
        _baseTokenURI = baseURI;
    }