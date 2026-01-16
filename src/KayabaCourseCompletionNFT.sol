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