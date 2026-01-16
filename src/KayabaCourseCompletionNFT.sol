// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title KayabaCourseCompletionNFT
 * @dev NFT for Kayaba Labs Course Completion Certificates
 * - Soulbound (non-transferable)
 * - $0.50 minting fee
 * - Stores only student ID, course name, and completion date
 * - Batch minting available for owner
 */

contract KayabaCourseCompletionNFT is ERC721, ERC721URIStorage, Ownable {
    using Strings for uint256;

    // Student information struct
    struct StudentInfo {
        string studentId;      // Student ID (e.g., KL-SOL-0001)
        string courseName;     // Course completed
        string completionDate; // Date of completion
    }

    
    uint256 private _nextTokenId;
    uint256 public constant MINT_FEE = 0.0003 ether; // ~$0.50 on L2s
    
    // Mapping from token ID to student information
    mapping(uint256 => StudentInfo) public studentInfo;
    
    // Base URI for metadata (will be Pinata IPFS gateway)
    string private _baseTokenURI;
    
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
        string memory baseURI
    ) ERC721("Kayaba Labs Course Completion", "KAYABA-COURSE") Ownable(msg.sender) {
        _baseTokenURI = baseURI;
    }


    
    /**
     * @dev Mint course completion certificate
     * @param to Student's wallet address
     * @param studentId Student ID (e.g., KL-SOL-0001)
     * @param course Name of the completed course
     * @param date Completion date (e.g., "January 15, 2024")
     * @param metadataURI Specific metadata URI (e.g., "0.json")
     */


    function mintCertificate(
        address to,
        string memory studentId,
        string memory course,
        string memory date,
        string memory metadataURI
    ) public payable returns (uint256) {
        require(msg.value >= MINT_FEE, "Insufficient minting fee");
        require(bytes(course).length > 0, "Course name required");
        require(bytes(studentId).length > 0, "Student ID required");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, metadataURI);
        
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
        
        return tokenId;
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
     * @param studentIds Array of student IDs
     * @param course Name of the course (same for all)
     * @param dates Array of completion dates
     * @param baseMetadataURI Base URI for metadata (e.g., "ipfs://QmHash")
     */

    function batchMintCertificates(
        address[] memory recipients,
        string[] memory studentIds,
        string memory course,
        string[] memory dates,
        string memory baseMetadataURI
    ) public onlyOwner {
        require(recipients.length == studentIds.length, "Recipients and IDs length mismatch");
        require(recipients.length == dates.length, "Recipients and dates length mismatch");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(recipients[i], tokenId);

            // Create unique metadata URI for each token
            string memory metadataURI = string(
                abi.encodePacked(baseMetadataURI, "/", tokenId.toString(), ".json")
            );
            _setTokenURI(tokenId, metadataURI);
            
            // Store student information
            studentInfo[tokenId] = StudentInfo({
                studentId: studentIds[i],
                courseName: course,
                completionDate: dates[i]
            });
            
            emit CertificateMinted(recipients[i], tokenId, studentIds[i], course, dates[i]);
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
    {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        StudentInfo memory info = studentInfo[tokenId];
        return (
            info.studentId,
            info.courseName,
            info.completionDate,
            ownerOf(tokenId)
        );
    }


      /**
     * @dev Get all certificates issued to a specific wallet address
     */
    function getStudentCertificates(address student) 
        public 
        view 
        returns (uint256[] memory) 
    {
        uint256 total = totalSupply();
        uint256 count = 0;
        
        // First pass: count certificates
        for (uint256 i = 0; i < total; i++) {
            if (_ownerOf(i) == student) {
                count++;
            }
        }

        // Second pass: collect token IDs
        uint256[] memory certificates = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < total; i++) {
            if (_ownerOf(i) == student) {
                certificates[index] = i;
                index++;
            }
        }
        
        return certificates;
    }

    
    /**
     * @dev Get total minted certificates
     */
    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }

// Override functions
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }


    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}