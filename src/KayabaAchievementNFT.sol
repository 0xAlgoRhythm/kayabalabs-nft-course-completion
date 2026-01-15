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

    /**
     * @dev Mint achievement NFT to a student
     * @param to Address of the recipient
     * @param achievementType Type of achievement
     * @param details Additional details (course name, hackathon name, etc.)
     * @param metadataURI Specific metadata URI for this token
     */
    function mintAchievement(
        address to,
        AchievementType achievementType,
        string memory details,
        string memory metadataURI
    ) public payable returns (uint256) {
        require(msg.value >= MINT_FEE, "Insufficient minting fee");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, metadataURI);
        
        tokenAchievements[tokenId] = achievementType;
        achievementDetails[tokenId] = details;
        
        emit AchievementMinted(to, tokenId, achievementType, details);
         
        // Refund excess payment
        if (msg.value > MINT_FEE) {
            payable(msg.sender).transfer(msg.value - MINT_FEE);
        }
        
        return tokenId;
    }
    

    **
     * @dev Batch mint achievements (only owner)
     * Useful for awarding multiple students at once
     */
    function batchMintAchievements(
        address[] memory recipients,
        AchievementType achievementType,
        string memory details,
        string memory baseMetadataURI
    ) public onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(recipients[i], tokenId);


            / Create unique metadata URI for each token
            string memory metadataURI = string(
                abi.encodePacked(baseMetadataURI, "/", tokenId.toString(), ".json")
            );
            _setTokenURI(tokenId, metadataURI);
            
            tokenAchievements[tokenId] = achievementType;
            achievementDetails[tokenId] = details;
            
            emit AchievementMinted(recipients[i], tokenId, achievementType, details);
        }
    }


     /**
     * @dev Withdraw collected fees (only owner)
     */
    function withdrawFees() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        payable(owner()).transfer(balance);
        emit FundsWithdrawn(owner(), balance);
    }
    
    /**
     * @dev Update base URI (only owner)
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }
    
    **
     * @dev Get achievement info for a token
     */
    function getAchievementInfo(uint256 tokenId) 
        public 
        view 
        returns (
            AchievementType achievementType,
            string memory details,
            address owner
        ) 


         {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return (
            tokenAchievements[tokenId],
            achievementDetails[tokenId],
            ownerOf(tokenId)
        );
    }

    /**
     * @dev Get total minted tokens
     */
    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }
    

     // Override functions
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    