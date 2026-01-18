// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/KayabaCourseCompletionNFT.sol";

contract KayabaCourseCompletionNFTTest is Test {
    KayabaCourseCompletionNFT public nft;
    address public owner;
    address public student1;
    uint256 constant MINT_FEE = 0.0003 ether;
    
    receive() external payable {}
    function setUp() public {
        owner = address(this);
        student1 = address(0x1);
        
        nft = new KayabaCourseCompletionNFT(
            "https://gateway.lighthouse.storage/ipfs/metadata.json",
        );
        
        vm.deal(student1, 10 ether);
    }
    
    function testMintWithFee() public {
        vm.prank(student1);
        (uint256 tokenId, string memory studentId) = nft.mintCertificate{value: MINT_FEE}(
            student1,
            "Solidity Fundamentals",
            "January 16, 2024"
        );
        
        assertEq(nft.ownerOf(tokenId), student1);
        assertEq(tokenId, 0);
        // Student ID should be KL-SOL-0001
    }
    
    function testAutoStudentId() public {
        // Mint first certificate
        (uint256 tokenId1, ) = nft.mintCertificate{value: MINT_FEE}(
            student1,
            "Solidity Fundamentals",
            "Jan 16, 2024"
        );
        
        // Mint second certificate
        (uint256 tokenId2, ) = nft.mintCertificate{value: MINT_FEE}(
            student1,
            "Solidity Fundamentals",
            "Jan 16, 2024"
        );
        
        assertEq(tokenId1, 0);
        assertEq(tokenId2, 1);
        assertEq(nft.totalSupply(), 2);
    }
    
    function testWithdrawFees() public {
        vm.prank(student1);
        nft.mintCertificate{value: MINT_FEE}(
            student1,
            "Solidity Fundamentals",
            "Jan 16, 2024"
        );
        
        uint256 balanceBefore = owner.balance;
        nft.withdrawFees();
        uint256 balanceAfter = owner.balance;
        
        assertEq(balanceAfter - balanceBefore, MINT_FEE);
    }
}
