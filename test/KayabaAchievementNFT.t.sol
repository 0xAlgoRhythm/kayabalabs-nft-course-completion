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
    