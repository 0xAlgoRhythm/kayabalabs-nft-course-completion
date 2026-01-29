// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/KayabaCourseCompletionNFT.sol";

contract DeployCourseNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // REPLACE WITH YOUR METADATA.JSON CID FROM LIGHTHOUSE
        string memory metadataURI = "https://coral-genuine-koi-966.mypinata.cloud/ipfs/bafkreia6rxkezois2eymzxbikacx5egnrfvteqsky6gcswscjzmlummccu";
        
        // Course prefix for student IDs (e.g., KL-SOL will create KL-SOL-0001, KL-SOL-0002, etc.)
        string memory coursePrefix = "KL-SOL";
        
        vm.startBroadcast(deployerPrivateKey);
        
        KayabaCourseCompletionNFT nft = new KayabaCourseCompletionNFT(
            metadataURI,
            coursePrefix
        );
        
        console.log("====================================");
        console.log("Kayaba Course Completion NFT Deployed!");
        console.log("====================================");
        console.log("Contract Address:", address(nft));
        console.log("Metadata URI:", metadataURI);
        console.log("Course Prefix:", coursePrefix);
        console.log("Network: Base Sepolia Testnet");
        console.log("====================================");
        console.log("");
        console.log("Student IDs will be auto-generated:");
        console.log("  Token #0 = KL-SOL-0001");
        console.log("  Token #1 = KL-SOL-0002");
        console.log("  Token #2 = KL-SOL-0003");
        console.log("  ... and so on");
        console.log("====================================");
        
        vm.stopBroadcast();
    }
}
