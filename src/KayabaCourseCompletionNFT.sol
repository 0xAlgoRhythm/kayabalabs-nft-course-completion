// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


/**
 * @title KayabaCourseCompletionNFT
 * @dev NFT for Kayaba Labs Course Completion Certificates
 * - Auto-generates Student IDs (KL-SOL-0001, KL-SOL-0002, etc.)
 * - Single metadata JSON for all certificates
 * - Soulbound (non-transferable)
 * - $0.50 minting fee
 */



contract KayabaCourseCompletionNFT is ERC721, ERC721URIStorage, Ownable {
    using Strings for uint256;

    struct StudentInfo {
        string studentId;      // Auto-generated: KL-SOL-0001, KL-SOL-0002, etc.
        string courseName;     // Course completed
        string completionDate; // Date of completion
    }

    uint256 private _nextTokenId;
    uint256 public constant MINT_FEE = 0.0003 ether; // ~$0.50 on L2s
    
    // Mapping from token ID to student information
    mapping(uint256 => StudentInfo) public studentInfo;
    
// Single metadata URI (same for all tokens)
    string private _metadataURI;

    // Course prefix for student IDs (e.g., "KL-SOL" for Solidity course)
    string public coursePrefix;

    // Events
    event CertificateMinted(
        address indexed studentWallet,
        uint256 indexed tokenId,
        string studentId,
        string courseName,
        string completionDate
    );

    event FundsWithdrawn(address indexed owner, uint256 amount);
    
    constructor(
        string memory metadataURI,
        string memory _coursePrefix
    ) ERC721("Kayaba Labs Course Completion", "KAYABA-COURSE") Ownable(msg.sender) {
        _metadataURI = metadataURI;
        coursePrefix = _coursePrefix; // e.g., "KL-SOL"
    }

    /**
     * @dev Mint course completion certificate (auto-generates student ID)
     * @param to Student's wallet address
     * @param course Name of the completed course
     * @param date Completion date (e.g., "January 16, 2024")
     */

    function mintCertificate(
        address to,
        string memory course,
        string memory date
    ) public payable returns (uint256, string memory) {
        require(msg.value >= MINT_FEE, "Insufficient minting fee");
        require(bytes(course).length > 0, "Course name required");

uint256 tokenId = _nextTokenId++;


