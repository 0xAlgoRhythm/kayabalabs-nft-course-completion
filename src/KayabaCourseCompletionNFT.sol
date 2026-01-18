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


// Auto-generate student ID: KL-SOL-0001, KL-SOL-0002, etc.
        string memory studentId = string(
            abi.encodePacked(
                coursePrefix,
                "-",
                _padNumber(tokenId + 1, 4)
            )
        );

         _safeMint(to, tokenId);
        _setTokenURI(tokenId, _metadataURI);
        

        // Store student information
        studentInfo[tokenId] = StudentInfo({
            studentId: studentId,
            courseName: course,
            completionDate: date
        });


        emit CertificateMinted(to, tokenId, studentId, course, date);
         
        // Refund excess payment
        if (msg.value > MINT_FEE) {
            payable(msg.sender).transfer(msg.value - MINT_FEE);
        }
        
        return (tokenId, studentId);
    }


    /**
     * @dev Soulbound: Prevent transfers (certificates are non-transferable)
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);

         // Allow minting (from address(0)) but block transfers
        if (from != address(0) && to != address(0)) {
            revert("Certificate is soulbound and cannot be transferred");
        }
        
        return super._update(to, tokenId, auth);
    }

/**
     * @dev Batch mint certificates (only owner, no fees)
     * @param recipients Array of student wallet addresses
     * @param course Name of the course (same for all)
     * @param dates Array of completion dates
     */

function batchMintCertificates(
        address[] memory recipients,
        string memory course,
        string[] memory dates
    ) public onlyOwner returns (string[] memory) {
        require(recipients.length == dates.length, "Recipients and dates length mismatch");
         string[] memory studentIds = new string[](recipients.length);
        
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 tokenId = _nextTokenId++;

            // Auto-generate student ID
            string memory studentId = string(
                abi.encodePacked(
                    coursePrefix,
                    "-",
                    _padNumber(tokenId + 1, 4)
                )
            );

            _safeMint(recipients[i], tokenId);
            _setTokenURI(tokenId, _metadataURI);
            
            // Store student information
            studentInfo[tokenId] = StudentInfo({
                studentId: studentId,
                courseName: course,
                completionDate: dates[i]
            });

            studentIds[i] = studentId;
            emit CertificateMinted(recipients[i], tokenId, studentId, course, dates[i]);
        }
        
        return studentIds;
    }

    /**
     * @dev Withdraw accumulated or collected funds (only owner)
     */

    function withdrawFees() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

         payable(owner()).transfer(balance);
        emit FundsWithdrawn(owner(), balance);
    }

    /**
     * @dev Update metadata URI (only owner)
     */
    function setMetadataURI(string memory newURI) public onlyOwner {
        _metadataURI = newURI;
    }

    /**
     * @dev Update course prefix (only owner)
     */
    function setCoursePrefix(string memory newPrefix) public onlyOwner {
        coursePrefix = newPrefix;
    }

    /**
     * @dev Get complete certificate information for a token
     */

    function getCertificateInfo(uint256 tokenId) 
        public 
        view 
        returns (
            string memory studentId,
            string memory course,
            string memory date,
            address wallet
        ) 