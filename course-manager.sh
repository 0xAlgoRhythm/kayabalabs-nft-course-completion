#!/bin/bash

# course-manager.sh
# Complete management script for Kayaba Labs Course Completion NFT
# Handles certificate minting, student tracking, and course management

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Load environment
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi
source .env

# Contract address - Use from .env or set manually
if [ -z "$CONTRACT_ADDRESS" ]; then
    CONTRACT_ADDRESS=0xA64d57395a02cF0267F487ec4DBe43a43c11ef86
fi

# Helper function to pause
pause() {
    read -p "Press Enter to continue..."
}

# Show header
show_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║    Kayaba Labs Course Completion Certificate System   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Main menu
main_menu() {
    while true; do
        show_header
        echo -e "${YELLOW}═══ MAIN MENU ═══${NC}"
        echo ""
        echo -e "${GREEN}CERTIFICATE MINTING:${NC}"
        echo "  1) 📜 Mint Single Certificate"
        echo "  2) 📚 Batch Mint Certificates (Manual Entry)"
        echo "  3) 📁 Batch Mint from CSV File"
        echo ""
        echo -e "${GREEN}STUDENT RECORDS:${NC}"
        echo "  4) 🎓 View Student's Certificates"
        echo "  5) 🔍 Search Certificate by Token ID"
        echo "  6) 📊 View All Issued Certificates"
        echo "  7) 📈 View Course Statistics"
        echo ""
        echo -e "${GREEN}ADMINISTRATION:${NC}"
        echo "  8) 💰 Withdraw Collected Fees"
        echo "  9) 🔧 Update Metadata URI"
        echo "  10) 🏷️ Change Course Prefix"
        echo "  11) ⚙️ View Contract Configuration"
        echo ""
        echo -e "${GREEN}UTILITIES:${NC}"
        echo "  12) 📝 Generate Sample CSV Template"
        echo "  13) 🔗 View Important Links"
        echo "  14) 🧪 Run System Tests"
        echo "  15) 📤 Export Student Database (CSV)"
        echo ""
        echo -e "${RED}  0) Exit${NC}"
        echo ""
        read -p "Enter choice [0-15]: " choice
        
        case $choice in
            1) mint_single ;;
            2) batch_mint_interactive ;;
            3) batch_mint_csv ;;
            4) view_student_certificates ;;
            5) view_certificate ;;
            6) view_all_certificates ;;
            7) view_statistics ;;
            8) withdraw_fees ;;
            9) update_metadata ;;
            10) change_prefix ;;
            11) view_config ;;
            12) generate_csv ;;
            13) view_links ;;
            14) run_tests ;;
            15) export_database ;;
            0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice${NC}"; pause ;;
        esac
    done
}

# 1. Mint Single Certificate
mint_single() {
    show_header
    echo -e "${CYAN}═══ MINT SINGLE CERTIFICATE ═══${NC}"
    echo ""
    
    read -p "Student Wallet Address: " WALLET
    read -p "Course Name (e.g., 'Solidity Fundamentals'): " COURSE_NAME
    read -p "Completion Date (e.g., 'January 23, 2026'): " COMPLETION_DATE
    
    # Confirm
    echo ""
    echo -e "${YELLOW}═══ REVIEW ═══${NC}"
    echo "Student Wallet: $WALLET"
    echo "Course: $COURSE_NAME"
    echo "Date: $COMPLETION_DATE"
    echo "Minting Fee: 0.0003 ETH (~\$0.50)"
    echo ""
    read -p "Proceed with minting? (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${RED}Cancelled${NC}"
        pause
        return
    fi
    
    echo ""
    echo -e "${BLUE}Minting certificate...${NC}"
    echo ""
    
    TX_HASH=$(cast send $CONTRACT_ADDRESS \
        "mintCertificate(address,string,string)" \
        "$WALLET" \
        "$COURSE_NAME" \
        "$COMPLETION_DATE" \
        --value 0.0003ether \
        --rpc-url $BASE_SEPOLIA_RPC_URL \
        --private-key $PRIVATE_KEY 2>&1 | tee /dev/tty | grep -i "transactionHash" | awk '{print $2}')
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Certificate minted successfully!${NC}"
        echo ""
        
        # Get current total supply to estimate token ID
        TOTAL_SUPPLY=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
        LIKELY_TOKEN_ID=$((TOTAL_SUPPLY - 1))
        
        # Get student ID if possible
        if [ $LIKELY_TOKEN_ID -ge 0 ]; then
            STUDENT_ID=$(cast call $CONTRACT_ADDRESS "getStudentId(uint256)" $LIKELY_TOKEN_ID --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
            
            echo -e "${YELLOW}═══ CERTIFICATE DETAILS ═══${NC}"
            echo -e "${GREEN}Student ID:${NC} $STUDENT_ID"
            echo -e "${GREEN}Token ID:${NC} $LIKELY_TOKEN_ID"
            echo -e "${GREEN}Owner:${NC} $WALLET"
            echo -e "${GREEN}Course:${NC} $COURSE_NAME"
            echo -e "${GREEN}Date:${NC} $COMPLETION_DATE"
            echo ""
        fi
        
        if [ -n "$TX_HASH" ]; then
            echo -e "${CYAN}Transaction Hash:${NC} $TX_HASH"
            echo -e "${CYAN}View on Etherscan:${NC}"
            echo "https://sepolia.etherscan.io/tx/$TX_HASH"
            echo ""
        fi
        
        if [ $LIKELY_TOKEN_ID -ge 0 ]; then
            echo -e "${CYAN}View Certificate on OpenSea:${NC}"
            echo "https://testnets.opensea.io/assets/sepolia/$CONTRACT_ADDRESS/$LIKELY_TOKEN_ID"
        fi
    else
        echo -e "${RED}❌ Minting failed${NC}"
    fi
    
    echo ""
    pause
}

# 2. Batch Mint Interactive
batch_mint_interactive() {
    show_header
    echo -e "${CYAN}═══ BATCH MINT CERTIFICATES (INTERACTIVE) ═══${NC}"
    echo ""
    
    read -p "Course Name (same for all students): " COURSE_NAME
    
    echo ""
    echo -e "${YELLOW}Enter student details (empty wallet to finish):${NC}"
    echo ""
    
    WALLETS=()
    DATES=()
    
    while true; do
        echo -e "${CYAN}Student #$((${#WALLETS[@]} + 1))${NC}"
        read -p "  Wallet Address (or Enter to finish): " WALLET
        
        if [ -z "$WALLET" ]; then
            break
        fi
        
        read -p "  Completion Date: " DATE
        
        WALLETS+=("$WALLET")
        DATES+=("$DATE")
        
        echo -e "${GREEN}  ✓ Added${NC}"
        echo ""
    done
    
    if [ ${#WALLETS[@]} -eq 0 ]; then
        echo -e "${RED}No students added${NC}"
        pause
        return
    fi
    
    # Format arrays for Solidity
    WALLETS_STR=$(printf ',"%s"' "${WALLETS[@]}")
    WALLETS_STR="[${WALLETS_STR:1}]"
    
    DATES_STR=$(printf ',"%s"' "${DATES[@]}")
    DATES_STR="[${DATES_STR:1}]"
    
    # Review
    echo -e "${YELLOW}═══ REVIEW ═══${NC}"
    echo "Course: $COURSE_NAME"
    echo "Total Students: ${#WALLETS[@]}"
    echo ""
    for i in "${!WALLETS[@]}"; do
        echo "  $((i+1)). ${WALLETS[$i]:0:10}...${WALLETS[$i]: -6} - ${DATES[$i]}"
    done
    echo ""
    echo -e "${CYAN}Note: Batch minting is free for contract owner${NC}"
    echo ""
    read -p "Proceed with batch mint? (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${RED}Cancelled${NC}"
        pause
        return
    fi
    
    echo ""
    echo -e "${BLUE}Minting ${#WALLETS[@]} certificates...${NC}"
    echo ""
    
    # Get supply before minting
    SUPPLY_BEFORE=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    SUPPLY_BEFORE=$((SUPPLY_BEFORE))
    
    TX_HASH=$(cast send $CONTRACT_ADDRESS \
        "batchMintCertificates(address[],string,string[])" \
        "$WALLETS_STR" \
        "$COURSE_NAME" \
        "$DATES_STR" \
        --rpc-url $BASE_SEPOLIA_RPC_URL \
        --private-key $PRIVATE_KEY 2>&1 | tee /dev/tty | grep -i "transactionHash" | awk '{print $2}')
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Batch mint complete!${NC}"
        echo -e "${GREEN}${#WALLETS[@]} certificates issued${NC}"
        echo ""
        
        echo -e "${YELLOW}═══ CERTIFICATE DETAILS ═══${NC}"
        echo -e "${GREEN}Course:${NC} $COURSE_NAME"
        echo -e "${GREEN}Token IDs:${NC} $SUPPLY_BEFORE to $((SUPPLY_BEFORE + ${#WALLETS[@]} - 1))"
        echo -e "${GREEN}Total Students:${NC} ${#WALLETS[@]}"
        echo ""
        
        if [ -n "$TX_HASH" ]; then
            echo -e "${CYAN}Transaction Hash:${NC} $TX_HASH"
            echo -e "${CYAN}View on Etherscan:${NC}"
            echo "https://sepolia.etherscan.io/tx/$TX_HASH"
        fi
    else
        echo -e "${RED}❌ Batch mint failed${NC}"
    fi
    
    echo ""
    pause
}

# 3. Batch Mint from CSV
batch_mint_csv() {
    show_header
    echo -e "${CYAN}═══ BATCH MINT FROM CSV FILE ═══${NC}"
    echo ""
    
    read -p "CSV File Path: " CSV_FILE
    
    if [ ! -f "$CSV_FILE" ]; then
        echo -e "${RED}File not found: $CSV_FILE${NC}"
        pause
        return
    fi
    
    echo ""
    echo -e "${BLUE}Reading CSV file...${NC}"
    
    WALLETS=()
    DATES=()
    COURSE_NAME=""
    
    # Read CSV (skip header)
    LINE_NUM=0
    while IFS=',' read -r wallet date course || [ -n "$wallet" ]; do
        LINE_NUM=$((LINE_NUM + 1))
        
        # Skip header
        if [ $LINE_NUM -eq 1 ]; then
            continue
        fi
        
        # Skip empty lines
        if [ -z "$wallet" ]; then
            continue
        fi
        
        # Set course name from first row
        if [ -z "$COURSE_NAME" ]; then
            COURSE_NAME="$course"
        fi
        
        WALLETS+=("$wallet")
        DATES+=("$date")
    done < "$CSV_FILE"
    
    if [ ${#WALLETS[@]} -eq 0 ]; then
        echo -e "${RED}No data found in CSV${NC}"
        pause
        return
    fi
    
    echo -e "${GREEN}Found ${#WALLETS[@]} students${NC}"
    echo ""
    
    # Format arrays
    WALLETS_STR=$(printf ',"%s"' "${WALLETS[@]}")
    WALLETS_STR="[${WALLETS_STR:1}]"
    
    DATES_STR=$(printf ',"%s"' "${DATES[@]}")
    DATES_STR="[${DATES_STR:1}]"
    
    # Preview
    echo -e "${YELLOW}Preview (first 5):${NC}"
    for i in {0..4}; do
        if [ $i -lt ${#WALLETS[@]} ]; then
            echo "  $((i+1)). ${WALLETS[$i]:0:10}... - ${DATES[$i]}"
        fi
    done
    echo ""
    echo "Course: $COURSE_NAME"
    echo ""
    
    read -p "Proceed with batch mint? (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${RED}Cancelled${NC}"
        pause
        return
    fi
    
    echo ""
    echo -e "${BLUE}Minting ${#WALLETS[@]} certificates...${NC}"
    echo ""
    
    # Get supply before minting
    SUPPLY_BEFORE=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    SUPPLY_BEFORE=$((SUPPLY_BEFORE))
    
    TX_HASH=$(cast send $CONTRACT_ADDRESS \
        "batchMintCertificates(address[],string,string[])" \
        "$WALLETS_STR" \
        "$COURSE_NAME" \
        "$DATES_STR" \
        --rpc-url $BASE_SEPOLIA_RPC_URL \
        --private-key $PRIVATE_KEY 2>&1 | tee /dev/tty | grep -i "transactionHash" | awk '{print $2}')
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Batch mint from CSV complete!${NC}"
        echo -e "${GREEN}${#WALLETS[@]} certificates issued${NC}"
        echo ""
        
        echo -e "${YELLOW}═══ CERTIFICATE DETAILS ═══${NC}"
        echo -e "${GREEN}Course:${NC} $COURSE_NAME"
        echo -e "${GREEN}Token IDs:${NC} $SUPPLY_BEFORE to $((SUPPLY_BEFORE + ${#WALLETS[@]} - 1))"
        echo -e "${GREEN}Total Students:${NC} ${#WALLETS[@]}"
        echo ""
        
        if [ -n "$TX_HASH" ]; then
            echo -e "${CYAN}Transaction Hash:${NC} $TX_HASH"
            echo -e "${CYAN}View on Etherscan:${NC}"
            echo "https://sepolia.etherscan.io/tx/$TX_HASH"
        fi
    else
        echo -e "${RED}❌ Batch mint failed${NC}"
    fi
    
    echo ""
    pause
}

# 4. View Student's Certificates
view_student_certificates() {
    show_header
    echo -e "${CYAN}═══ VIEW STUDENT'S CERTIFICATES ═══${NC}"
    echo ""
    
    read -p "Student Wallet Address: " WALLET
    
    echo ""
    echo -e "${BLUE}Searching for certificates...${NC}"
    
    # Get total supply
    TOTAL_SUPPLY=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    TOTAL_SUPPLY=$((TOTAL_SUPPLY))
    
    if [ $TOTAL_SUPPLY -eq 0 ]; then
        echo ""
        echo -e "${YELLOW}No certificates have been issued yet${NC}"
        echo ""
        pause
        return
    fi
    
    echo -e "${BLUE}Checking $TOTAL_SUPPLY certificates...${NC}"
    echo ""
    
    FOUND=0
    
    # Normalize wallet address for comparison
    WALLET_LOWER=$(echo $WALLET | tr '[:upper:]' '[:lower:]' | sed 's/^0x//')
    
    for ((i=0; i<$TOTAL_SUPPLY; i++)); do
        OWNER=$(cast call $CONTRACT_ADDRESS "ownerOf(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
        OWNER_LOWER=$(echo $OWNER | tr '[:upper:]' '[:lower:]' | sed 's/^0x//')
        
        if [[ "$OWNER_LOWER" == "$WALLET_LOWER" ]]; then
            if [ $FOUND -eq 0 ]; then
                echo -e "${YELLOW}═══ CERTIFICATES FOUND ═══${NC}"
                echo ""
            fi
            
            # Get certificate info
            STUDENT_ID=$(cast call $CONTRACT_ADDRESS "getStudentId(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
            
            # Get course info from studentInfo mapping
            COURSE_INFO=$(cast call $CONTRACT_ADDRESS "studentInfo(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
            
            echo -e "${GREEN}📜 Certificate #$((FOUND + 1))${NC}"
            echo -e "${CYAN}  Student ID:${NC} $STUDENT_ID"
            echo -e "${CYAN}  Token ID:${NC} $i"
            echo -e "${CYAN}  Owner:${NC} 0x$OWNER_LOWER"
            echo ""
            echo -e "${YELLOW}  Links:${NC}"
            echo "  OpenSea: https://testnets.opensea.io/assets/sepolia/$CONTRACT_ADDRESS/$i"
            echo "  Etherscan: https://sepolia.etherscan.io/token/$CONTRACT_ADDRESS?a=$i"
            echo ""
            
            FOUND=$((FOUND + 1))
        fi
    done
    
    if [ $FOUND -eq 0 ]; then
        echo -e "${YELLOW}No certificates found for this wallet${NC}"
        echo ""
        echo -e "${CYAN}Checked wallet:${NC} 0x$WALLET_LOWER"
        echo -e "${CYAN}Total certificates in system:${NC} $TOTAL_SUPPLY"
    else
        echo -e "${GREEN}═══════════════════════════════${NC}"
        echo -e "${GREEN}Total certificates found: $FOUND${NC}"
    fi
    echo ""
    
    pause
}

# 5. View Certificate Details
view_certificate() {
    show_header
    echo -e "${CYAN}═══ CERTIFICATE DETAILS ═══${NC}"
    echo ""
    
    read -p "Token ID: " TOKEN_ID
    
    echo ""
    echo -e "${BLUE}Fetching certificate #$TOKEN_ID...${NC}"
    echo ""
    
    # Check if token exists
    OWNER=$(cast call $CONTRACT_ADDRESS "ownerOf(uint256)" $TOKEN_ID --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    
    if [ -z "$OWNER" ] || [ "$OWNER" == "0x0000000000000000000000000000000000000000" ]; then
        echo -e "${RED}Certificate not found or does not exist${NC}"
        pause
        return
    fi
    
    # Get student ID
    STUDENT_ID=$(cast call $CONTRACT_ADDRESS "getStudentId(uint256)" $TOKEN_ID --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
    
    # Get metadata URI
    URI=$(cast call $CONTRACT_ADDRESS "tokenURI(uint256)" $TOKEN_ID --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
    
    echo -e "${YELLOW}═══ Certificate #$TOKEN_ID ═══${NC}"
    echo ""
    echo -e "${GREEN}Student ID:${NC} $STUDENT_ID"
    echo -e "${GREEN}Owner:${NC} $OWNER"
    echo -e "${GREEN}Metadata URI:${NC} $URI"
    echo ""
    echo -e "${CYAN}View on OpenSea:${NC}"
    echo "https://testnets.opensea.io/assets/sepolia/$CONTRACT_ADDRESS/$TOKEN_ID"
    echo ""
    echo -e "${CYAN}View on Etherscan:${NC}"
    echo "https://sepolia.etherscan.io/token/$CONTRACT_ADDRESS?a=$TOKEN_ID"
    echo ""
    
    pause
}

# 6. View All Certificates
view_all_certificates() {
    show_header
    echo -e "${CYAN}═══ ALL ISSUED CERTIFICATES ═══${NC}"
    echo ""
    
    TOTAL_SUPPLY=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    TOTAL_SUPPLY=$((TOTAL_SUPPLY))
    
    if [ $TOTAL_SUPPLY -eq 0 ]; then
        echo -e "${YELLOW}No certificates issued yet${NC}"
        pause
        return
    fi
    
    echo -e "${BLUE}Loading $TOTAL_SUPPLY certificates...${NC}"
    echo ""
    
    for ((i=0; i<$TOTAL_SUPPLY; i++)); do
        STUDENT_ID=$(cast call $CONTRACT_ADDRESS "getStudentId(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
        OWNER=$(cast call $CONTRACT_ADDRESS "ownerOf(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
        
        echo -e "${GREEN}#$i:${NC} $STUDENT_ID - ${OWNER:0:10}...${OWNER: -6}"
        
        # Pause every 20 items
        if [ $((($i + 1) % 20)) -eq 0 ]; then
            echo ""
            read -p "Press Enter for more (or Ctrl+C to exit)..."
            echo ""
        fi
    done
    
    echo ""
    echo -e "${CYAN}Total certificates issued: $TOTAL_SUPPLY${NC}"
    echo ""
    
    pause
}

# 7. View Statistics
view_statistics() {
    show_header
    echo -e "${CYAN}═══ COURSE STATISTICS ═══${NC}"
    echo ""
    
    echo -e "${BLUE}Fetching data...${NC}"
    echo ""
    
    # Get total supply
    TOTAL_SUPPLY=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    TOTAL_SUPPLY=$((TOTAL_SUPPLY))
    
    # Get contract balance
    BALANCE=$(cast balance $CONTRACT_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    BALANCE_ETH=$(echo "scale=4; $BALANCE / 1000000000000000000" | bc)
    
    # Get course prefix
    PREFIX=$(cast call $CONTRACT_ADDRESS "coursePrefix()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
    
    # Calculate revenue
    REVENUE=$(echo "scale=2; $TOTAL_SUPPLY * 0.50" | bc)
    
    echo -e "${YELLOW}═══ OVERVIEW ═══${NC}"
    echo -e "${GREEN}Total Certificates Issued:${NC} $TOTAL_SUPPLY"
    echo -e "${GREEN}Student ID Range:${NC} $PREFIX-0001 to $PREFIX-$(printf "%04d" $TOTAL_SUPPLY)"
    echo -e "${GREEN}Contract Balance:${NC} $BALANCE_ETH ETH"
    echo -e "${GREEN}Estimated Revenue:${NC} \$$REVENUE USD"
    echo ""
    
    echo -e "${YELLOW}═══ CONTRACT INFO ═══${NC}"
    echo -e "${CYAN}Address:${NC} $CONTRACT_ADDRESS"
    echo -e "${CYAN}Network:${NC} Base Sepolia"
    echo -e "${CYAN}Course Prefix:${NC} $PREFIX"
    echo -e "${CYAN}Mint Fee:${NC} 0.0003 ETH (~\$0.50)"
    echo ""
    
    pause
}

# 8. Withdraw Fees
withdraw_fees() {
    show_header
    echo -e "${CYAN}═══ WITHDRAW COLLECTED FEES ═══${NC}"
    echo ""
    
    # Check balance
    BALANCE=$(cast balance $CONTRACT_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    BALANCE_ETH=$(echo "scale=4; $BALANCE / 1000000000000000000" | bc)
    
    echo -e "${YELLOW}Contract Balance:${NC} $BALANCE_ETH ETH"
    echo ""
    
    if (( $(echo "$BALANCE_ETH == 0" | bc -l) )); then
        echo -e "${RED}No funds to withdraw${NC}"
        pause
        return
    fi
    
    read -p "Withdraw all fees? (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${RED}Cancelled${NC}"
        pause
        return
    fi
    
    echo ""
    echo -e "${BLUE}Withdrawing fees...${NC}"
    
    cast send $CONTRACT_ADDRESS \
        "withdrawFees()" \
        --rpc-url $BASE_SEPOLIA_RPC_URL \
        --private-key $PRIVATE_KEY
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Withdrawal successful!${NC}"
        echo -e "${GREEN}$BALANCE_ETH ETH sent to your wallet${NC}"
    else
        echo -e "${RED}❌ Withdrawal failed${NC}"
    fi
    
    pause
}

# 9. Update Metadata URI
update_metadata() {
    show_header
    echo -e "${CYAN}═══ UPDATE METADATA URI ═══${NC}"
    echo ""
    
    # Get current URI
    CURRENT_URI=$(cast call $CONTRACT_ADDRESS "tokenURI(uint256)" 0 --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p 2>/dev/null)
    
    echo -e "${YELLOW}Current Metadata URI:${NC}"
    echo "$CURRENT_URI"
    echo ""
    
    read -p "New Metadata URI: " NEW_URI
    
    echo ""
    read -p "Update metadata URI? (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${RED}Cancelled${NC}"
        pause
        return
    fi
    
    echo ""
    echo -e "${BLUE}Updating metadata URI...${NC}"
    
    cast send $CONTRACT_ADDRESS \
        "setMetadataURI(string)" \
        "$NEW_URI" \
        --rpc-url $BASE_SEPOLIA_RPC_URL \
        --private-key $PRIVATE_KEY
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Metadata URI updated!${NC}"
    else
        echo -e "${RED}❌ Update failed${NC}"
    fi
    
    pause
}

# 10. Change Course Prefix
change_prefix() {
    show_header
    echo -e "${CYAN}═══ CHANGE COURSE PREFIX ═══${NC}"
    echo ""
    
    CURRENT_PREFIX=$(cast call $CONTRACT_ADDRESS "coursePrefix()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
    
    echo -e "${YELLOW}Current Prefix:${NC} $CURRENT_PREFIX"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  KL-SOL  (Solidity Course)"
    echo "  KL-WEB3 (Web3 Fundamentals)"
    echo "  KL-DEFI (DeFi Development)"
    echo ""
    read -p "New Course Prefix: " NEW_PREFIX
    
    echo ""
    echo -e "${YELLOW}This will change future student IDs from:${NC}"
    echo "  $CURRENT_PREFIX-0001 → $NEW_PREFIX-0001"
    echo ""
    read -p "Proceed? (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${RED}Cancelled${NC}"
        pause
        return
    fi
    
    echo ""
    echo -e "${BLUE}Updating prefix...${NC}"
    
    cast send $CONTRACT_ADDRESS \
        "setCoursePrefix(string)" \
        "$NEW_PREFIX" \
        --rpc-url $BASE_SEPOLIA_RPC_URL \
        --private-key $PRIVATE_KEY
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Prefix updated to: $NEW_PREFIX${NC}"
    else
        echo -e "${RED}❌ Update failed${NC}"
    fi
    
    pause
}

# 11. View Configuration
view_config() {
    show_header
    echo -e "${CYAN}═══ CONTRACT CONFIGURATION ═══${NC}"
    echo ""
    
    PREFIX=$(cast call $CONTRACT_ADDRESS "coursePrefix()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
    
    echo -e "${YELLOW}Contract Details:${NC}"
    echo "  Address: $CONTRACT_ADDRESS"
    echo "  Network: Base Sepolia"
    echo "  RPC: $BASE_SEPOLIA_RPC_URL"
    echo ""
    
    echo -e "${YELLOW}Course Settings:${NC}"
    echo "  Course Prefix: $PREFIX"
    echo "  Mint Fee: 0.0003 ETH (~\$0.50)"
    echo "  Soulbound: Yes (non-transferable)"
    echo "  Batch Minting: Enabled (owner only, free)"
    echo ""
    
    echo -e "${YELLOW}Student ID Format:${NC}"
    echo "  Pattern: $PREFIX-XXXX"
    echo "  Example: $PREFIX-0001, $PREFIX-0002, etc."
    echo "  Auto-increments with each mint"
    echo ""
    
    echo -e "${YELLOW}Contract Features:${NC}"
    echo "  ✓ ERC-721 Compliant"
    echo "  ✓ Auto-generated Student IDs"
    echo "  ✓ Single metadata for all certificates"
    echo "  ✓ Soulbound (cannot be transferred)"
    echo "  ✓ Batch minting support"
    echo "  ✓ Fee collection & withdrawal"
    echo ""
    
    pause
}

# 12. Generate Sample CSV
generate_csv() {
    show_header
    echo -e "${CYAN}═══ GENERATE SAMPLE CSV TEMPLATE ═══${NC}"
    echo ""
    
    CSV_FILE="sample_students.csv"
    
    cat > $CSV_FILE << 'EOF'
wallet,date,course
0xBe1382237f760d8A26c9d6559DBf4239f97BF2eF,January 23 2026,Solidity Fundamentals
0x76764f8DE65f6D2Cd00987d9791B8C6af00c1911,January 23 2026,Solidity Fundamentals
0x1234567890123456789012345678901234567890,January 22 2026,Solidity Fundamentals
0xabcdefabcdefabcdefabcdefabcdefabcdefabcd,January 21 2026,Solidity Fundamentals
EOF
    
    echo -e "${GREEN}✅ Sample CSV generated: $CSV_FILE${NC}"
    echo ""
    echo -e "${YELLOW}CSV Format:${NC}"
    echo "  wallet,date,course"
    echo ""
    echo -e "${YELLOW}Fields:${NC}"
    echo "  wallet  - Student's Ethereum wallet address"
    echo "  date    - Course completion date"
    echo "  course  - Course name (same for all in batch)"
    echo ""
    echo -e "${CYAN}Edit this file and use option 3 to batch mint!${NC}"
    echo ""
    
    pause
}

# 13. View Important Links
view_links() {
    show_header
    echo -e "${CYAN}═══ IMPORTANT LINKS ═══${NC}"
    echo ""
    
    echo -e "${YELLOW}Contract:${NC}"
    echo "  Address: $CONTRACT_ADDRESS"
    echo "  Etherscan: https://sepolia.etherscan.io/address/$CONTRACT_ADDRESS"
    echo ""
    
    echo -e "${YELLOW}OpenSea:${NC}"
    echo "  Collection: https://testnets.opensea.io/assets/sepolia/$CONTRACT_ADDRESS"
    echo ""
    
    echo -e "${YELLOW}Documentation:${NC}"
    echo "  Foundry: https://book.getfoundry.sh/"
    echo "  Cast Reference: https://book.getfoundry.sh/cast/"
    echo "  OpenZeppelin ERC721: https://docs.openzeppelin.com/contracts/erc721"
    echo ""
    
    echo -e "${YELLOW}Network:${NC}"
    echo "  Base Sepolia RPC: $BASE_SEPOLIA_RPC_URL"
    echo "  Chain ID: 84532"
    echo "  Block Explorer: https://sepolia.basescan.org/"
    echo ""
    
    echo -e "${YELLOW}Support:${NC}"
    echo "  GitHub: https://github.com/kayabalabs"
    echo "  Website: https://kayabalabs.com"
    echo ""
    
    pause
}

# 14. Run Tests
run_tests() {
    show_header
    echo -e "${CYAN}═══ SYSTEM TESTS ═══${NC}"
    echo ""
    
    echo -e "${BLUE}Running contract tests...${NC}"
    echo ""
    
    # Test 1: Contract exists
    echo -n "1. Contract deployment... "
    CODE=$(cast code $CONTRACT_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    if [ -n "$CODE" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ (Contract not found)${NC}"
    fi
    
    # Test 2: Total supply
    echo -n "2. Read total supply... "
    SUPPLY=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    if [ -n "$SUPPLY" ]; then
        echo -e "${GREEN}✓${NC} (Total: $((SUPPLY)) certificates)"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # Test 3: Course prefix
    echo -n "3. Read course prefix... "
    PREFIX=$(cast call $CONTRACT_ADDRESS "coursePrefix()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
    if [ -n "$PREFIX" ]; then
        echo -e "${GREEN}✓${NC} (Prefix: $PREFIX)"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # Test 4: Contract balance
    echo -n "4. Contract balance... "
    BALANCE=$(cast balance $CONTRACT_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    if [ -n "$BALANCE" ]; then
        BALANCE_ETH=$(echo "scale=4; $BALANCE / 1000000000000000000" | bc)
        echo -e "${GREEN}✓${NC} (Balance: $BALANCE_ETH ETH)"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    # Test 5: Wallet balance
    echo -n "5. Wallet has funds... "
    WALLET_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY 2>/dev/null)
    WALLET_BALANCE=$(cast balance $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    WALLET_ETH=$(echo "scale=4; $WALLET_BALANCE / 1000000000000000000" | bc)
    if (( $(echo "$WALLET_ETH > 0.001" | bc -l) )); then
        echo -e "${GREEN}✓${NC} (Balance: $WALLET_ETH ETH)"
    else
        echo -e "${YELLOW}⚠${NC} (Balance: $WALLET_ETH ETH - Low balance!)"
    fi
    
    # Test 6: Read metadata URI
    echo -n "6. Metadata URI accessible... "
    if [ $((SUPPLY)) -gt 0 ]; then
        URI=$(cast call $CONTRACT_ADDRESS "tokenURI(uint256)" 0 --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p)
        if [ -n "$URI" ]; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
    else
        echo -e "${YELLOW}⊘${NC} (No certificates minted yet)"
    fi
    
    echo ""
    echo -e "${GREEN}Tests complete!${NC}"
    echo ""
    
    pause
}

# 15. Export Student Database
export_database() {
    show_header
    echo -e "${CYAN}═══ EXPORT STUDENT DATABASE ═══${NC}"
    echo ""
    
    EXPORT_FILE="student_database_$(date +%Y%m%d_%H%M%S).csv"
    
    echo -e "${BLUE}Exporting student database...${NC}"
    echo ""
    
    # Get total supply
    TOTAL_SUPPLY=$(cast call $CONTRACT_ADDRESS "totalSupply()" --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
    TOTAL_SUPPLY=$((TOTAL_SUPPLY))
    
    if [ $TOTAL_SUPPLY -eq 0 ]; then
        echo -e "${YELLOW}No certificates issued yet${NC}"
        pause
        return
    fi
    
    # Create CSV header
    echo "token_id,student_id,wallet_address,course_name,completion_date" > $EXPORT_FILE
    
    # Export all certificates
    for ((i=0; i<$TOTAL_SUPPLY; i++)); do
        echo -ne "Exporting certificate $((i+1))/$TOTAL_SUPPLY..."
        
        # Get student ID
        STUDENT_ID=$(cast call $CONTRACT_ADDRESS "getStudentId(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | xxd -r -p 2>/dev/null | tr -d '\0')
        
        # Get wallet address
        WALLET=$(cast call $CONTRACT_ADDRESS "ownerOf(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | tr -d '\n\r' | xargs)
        
        # Get certificate info (returns tuple: studentId, courseName, completionDate, wallet)
        # We'll parse each field separately to avoid null byte issues
        COURSE=$(cast call $CONTRACT_ADDRESS "studentInfo(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null)
        
        # Extract course name and date from the struct
        # The studentInfo mapping returns: (string studentId, string courseName, string completionDate)
        # For now, we'll use cast to get individual fields
        
        # Get course name by calling the struct field
        COURSE_NAME=$(cast call $CONTRACT_ADDRESS "studentInfo(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | grep -o '"[^"]*"' | sed -n '2p' | tr -d '"' 2>/dev/null)
        if [ -z "$COURSE_NAME" ]; then
            COURSE_NAME="N/A"
        fi
        
        # Get completion date
        COMPLETION_DATE=$(cast call $CONTRACT_ADDRESS "studentInfo(uint256)" $i --rpc-url $BASE_SEPOLIA_RPC_URL 2>/dev/null | grep -o '"[^"]*"' | sed -n '3p' | tr -d '"' 2>/dev/null)
        if [ -z "$COMPLETION_DATE" ]; then
            COMPLETION_DATE="N/A"
        fi
        
        # Clean up values (remove any problematic characters)
        STUDENT_ID=$(echo "$STUDENT_ID" | tr -d '\0\n\r' | xargs)
        COURSE_NAME=$(echo "$COURSE_NAME" | tr -d '\0\n\r' | sed 's/,/;/g')
        COMPLETION_DATE=$(echo "$COMPLETION_DATE" | tr -d '\0\n\r' | sed 's/,/;/g')
        
        # Write to CSV
        echo "$i,\"$STUDENT_ID\",\"$WALLET\",\"$COURSE_NAME\",\"$COMPLETION_DATE\"" >> $EXPORT_FILE
        
        echo -e "\r${GREEN}✓${NC} Exported certificate $((i+1))/$TOTAL_SUPPLY   "
    done
    
    echo ""
    echo -e "${GREEN}✅ Database exported to: $EXPORT_FILE${NC}"
    echo -e "${CYAN}Total records: $TOTAL_SUPPLY${NC}"
    echo ""
    
    # Show preview of exported data
    echo -e "${YELLOW}Preview (first 3 rows):${NC}"
    head -n 4 "$EXPORT_FILE"
    echo ""
    
    pause
}

# Start the script
main_menu