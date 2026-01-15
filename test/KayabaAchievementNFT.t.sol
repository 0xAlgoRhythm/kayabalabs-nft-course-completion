// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/KayabaAchievementNFT.sol";

contract KayabaAchievementNFTTest is Test {
    KayabaAchievementNFT public nft;
    address public owner;
    address public student1;
    address public student2;
    
    uint256 constant MINT_FEE = 0.0003 ether;
    
    // Add receive function to accept ETH
    receive() external payable {}
    
    function setUp() public {
        owner = address(this);
        student1 = address(0x1);
        student2 = address(0x2);
        
        nft = new KayabaAchievementNFT(
            "Kayaba Achievement",
            "KAYABA",
            "https://metadata.kayabalabs.com/achievements"
        );
        
        // Fund test addresses
        vm.deal(student1, 10 ether);
        vm.deal(student2, 10 ether);
    }
    
    function testMintWithFee() public {
        vm.prank(student1);
        uint256 tokenId = nft.mintAchievement{value: MINT_FEE}(
            student1,
            KayabaAchievementNFT.AchievementType.COURSE_COMPLETION,
            "Solidity Fundamentals",
            "1.json"
        );
        
        assertEq(nft.ownerOf(tokenId), student1);
        assertEq(address(nft).balance, MINT_FEE);
    }
    
    function testMintFailsWithInsufficientFee() public {
        vm.prank(student1);
        vm.expectRevert("Insufficient minting fee");
        nft.mintAchievement{value: 0.0001 ether}(
            student1,
            KayabaAchievementNFT.AchievementType.COURSE_COMPLETION,
            "Solidity Fundamentals",
            "1.json"
        );
    }
    
    function testBatchMint() public {
        address[] memory recipients = new address[](3);
        recipients[0] = student1;
        recipients[1] = student2;
        recipients[2] = address(0x3);
        
        nft.batchMintAchievements(
            recipients,
            KayabaAchievementNFT.AchievementType.HACKATHON_WINNER,
            "ETHGlobal 2024",
            "https://metadata.kayabalabs.com/hackathon"
        );
        
        assertEq(nft.totalSupply(), 3);
        assertEq(nft.ownerOf(0), student1);
        assertEq(nft.ownerOf(1), student2);
    }
    
    function testWithdrawFees() public {
        vm.prank(student1);
        nft.mintAchievement{value: MINT_FEE}(
            student1,
            KayabaAchievementNFT.AchievementType.COURSE_COMPLETION,
            "Test",
            "1.json"
        );
        
        uint256 balanceBefore = owner.balance;
        nft.withdrawFees();
        uint256 balanceAfter = owner.balance;
        
        assertEq(balanceAfter - balanceBefore, MINT_FEE);
    }
}