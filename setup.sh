#!/bin/bash

# Android ROM Setup Script for Xiaomi Mars (SM8350)
# This script clones all necessary repositories for building Android ROM

set -e  # Exit on any error
set -u  # Exit on undefined variables

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to display welcome screen
show_welcome_screen() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                              ║"
    echo "║     █████╗ ███╗   ██╗██████╗ ██████╗  ██████╗ ██╗██████╗                   ║"
    echo "║    ██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔═══██╗██║██╔══██╗                  ║"
    echo "║    ███████║██╔██╗ ██║██║  ██║██████╔╝██║   ██║██║██║  ██║                  ║"
    echo "║    ██╔══██║██║╚██╗██║██║  ██║██╔══██╗██║   ██║██║██║  ██║                  ║"
    echo "║    ██║  ██║██║ ╚████║██████╔╝██║  ██║╚██████╔╝██║██████╔╝                  ║"
    echo "║    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═════╝                   ║"
    echo "║                                                                              ║"
    echo "║    ██████╗  ██████╗ ███╗   ███╗    ███████╗███████╗████████╗██╗   ██╗██████╗ ║"
    echo "║    ██╔══██╗██╔═══██╗████╗ ████║    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗║"
    echo "║    ██████╔╝██║   ██║██╔████╔██║    ███████╗█████╗     ██║   ██║   ██║██████╔╝║"
    echo "║    ██╔══██╗██║   ██║██║╚██╔╝██║    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ ║"
    echo "║    ██║  ██║╚██████╔╝██║ ╚═╝ ██║    ███████║███████╗   ██║   ╚██████╔╝██║     ║"
    echo "║    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ║"
    echo "║                                                                              ║"
    echo "╠══════════════════════════════════════════════════════════════════════════════╣"
    echo -e "║${YELLOW}                    🚀 Xiaomi Mars (SM8350) Setup Tool 🚀                    ${CYAN}║"
    echo -e "║${WHITE}                                                                              ${CYAN}║"
    echo -e "║${GREEN}  📱 Device Trees    📦 Vendor Files    🔧 Hardware HAL    🐧 Kernel         ${CYAN}║"
    echo -e "║${PURPLE}  🔄 Auto-Update    💾 Path Memory                                     ${CYAN}║"
    echo -e "║${WHITE}                                                                              ${CYAN}║"
    echo -e "║${YELLOW}  Welcome, ${WHITE}$(whoami)${YELLOW}! 👋                                     $(date '+%Y-%m-%d %H:%M')${CYAN} ║"
    echo -e "║${WHITE}                                                                              ${CYAN}║"
    echo -e "║${BLUE}  by darkinzen                                                  ${CYAN}║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    echo -e "${BLUE}[INFO]${NC} This script will help you set up all necessary repositories for building Android ROM"
    echo -e "${BLUE}[INFO]${NC} for Xiaomi Mars (Xiaomi 11T Pro) with SM8350 chipset."
    echo
    echo -e "${YELLOW}Press any key to continue...${NC}"
    read -n 1 -s
    echo
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get Android source directory
get_android_source_dir() {
    local config_file="$HOME/.android_setup_config"
    local saved_path=""
    
    # Function for normal directory selection menu
    show_normal_menu() {
        echo
        log_info "Please specify the Android source directory:"
        echo "1) Use current directory: $(pwd)"
        echo "2) Enter custom path"
        echo
        
        while true; do
            read -p "Enter your choice (1-2): " choice
            case $choice in
                1)
                    ANDROID_SOURCE_DIR="$(pwd)"
                    break
                    ;;
                2)
                    read -p "Enter Android source directory path: " custom_path
                    if [ -n "$custom_path" ]; then
                        ANDROID_SOURCE_DIR="$custom_path"
                        break
                    else
                        log_warning "Please enter a valid path."
                    fi
                    ;;
                *)
                    log_warning "Invalid choice. Please enter 1 or 2."
                    ;;
            esac
        done
    }
    
    # Check if there's a saved path
    if [ -f "$config_file" ]; then
        saved_path=$(cat "$config_file" 2>/dev/null)
        if [ -n "$saved_path" ] && [ -d "$saved_path" ]; then
            echo
            log_info "Found previously used Android source directory:"
            echo "  $saved_path"
            echo
            log_info "Please specify the Android source directory:"
            echo "1) Use previous directory: $saved_path"
            echo "2) Use current directory: $(pwd)"
            echo "3) Enter custom path"
            echo
            
            while true; do
                read -p "Enter your choice (1-3): " choice
                case $choice in
                    1)
                        ANDROID_SOURCE_DIR="$saved_path"
                        break
                        ;;
                    2)
                        ANDROID_SOURCE_DIR="$(pwd)"
                        break
                        ;;
                    3)
                        read -p "Enter Android source directory path: " custom_path
                        if [ -n "$custom_path" ]; then
                            ANDROID_SOURCE_DIR="$custom_path"
                            break
                        else
                            log_warning "Please enter a valid path."
                        fi
                        ;;
                    *)
                        log_warning "Invalid choice. Please enter 1-3."
                        ;;
                esac
            done
        else
            # Saved path doesn't exist anymore, use normal menu
            show_normal_menu
        fi
    else
        # No config file, use normal menu
        show_normal_menu
    fi
    
    # Expand tilde and resolve path
    ANDROID_SOURCE_DIR=$(eval echo "$ANDROID_SOURCE_DIR")
    ANDROID_SOURCE_DIR=$(realpath "$ANDROID_SOURCE_DIR" 2>/dev/null || echo "$ANDROID_SOURCE_DIR")
    
    log_info "Selected Android source directory: $ANDROID_SOURCE_DIR"
    
    # Create directory if it doesn't exist
    if [ ! -d "$ANDROID_SOURCE_DIR" ]; then
        read -p "Directory doesn't exist. Create it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p "$ANDROID_SOURCE_DIR"
            log_success "Created directory: $ANDROID_SOURCE_DIR"
        else
            log_error "Directory doesn't exist. Exiting."
            exit 1
        fi
    fi
    
    # Save the path for future use
    echo "$ANDROID_SOURCE_DIR" > "$config_file"
    log_info "Directory path saved for future use."
    
    # Change to the Android source directory
    cd "$ANDROID_SOURCE_DIR"
    
    # Check if it's an Android source directory or initialize it
    if [ ! -f "build/envsetup.sh" ]; then
        log_warning "This doesn't appear to be an Android source directory (missing build/envsetup.sh)."
        read -p "Continue anyway? This script will create the necessary directory structure. (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Please navigate to your Android source directory or sync Android source code first."
            exit 1
        fi
    fi
}

# Function to check if repositories exist
check_existing_repos() {
    local existing_repos=()
    local repo_paths=(
        "device/xiaomi/mars"
        "device/xiaomi/sm8350-common"
        "vendor/xiaomi/mars"
        "vendor/xiaomi/sm8350-common"
        "hardware/xiaomi"
        "kernel/xiaomi/sm8350"
    )
    
    for repo_path in "${repo_paths[@]}"; do
        if [ -d "$repo_path" ]; then
            existing_repos+=("$repo_path")
        fi
    done
    
    if [ ${#existing_repos[@]} -gt 0 ]; then
        echo
        log_warning "The following repositories already exist:"
        for repo in "${existing_repos[@]}"; do
            echo "  - $repo"
        done
        echo
        
        echo
        log_info "Available update options:"
        echo "1) Update existing repositories"
        echo "2) Update this setup script"
        echo "3) Both repositories and script"
        echo "4) Skip updates"
        echo
        
        while true; do
            read -p "Enter your choice (1-4): " update_choice
            case $update_choice in
                1)
                    UPDATE_SCRIPT=false
                    break
                    ;;
                2)
                    UPDATE_SCRIPT=true
                    SKIP_UPDATES=true
                    log_info "Script will be updated and then restarted."
                    break
                    ;;
                3)
                    UPDATE_SCRIPT=true
                    break
                    ;;
                4)
                    SKIP_UPDATES=true
                    UPDATE_SCRIPT=false
                    log_info "Skipping all updates."
                    return
                    ;;
                *)
                    log_warning "Invalid choice. Please enter 1-4."
                    ;;
            esac
        done
        
        if [[ $UPDATE_SCRIPT == true ]]; then
            update_setup_script
            if [[ $update_choice == "2" ]]; then
                return  # Exit function if only updating script
            fi
        fi
        
        if [[ $update_choice == "1" || $update_choice == "3" ]]; then
            echo
            log_info "Select which repositories to update:"
            echo "1) Device Trees (mars, sm8350-common)"
            echo "2) Vendor Files (mars, sm8350-common vendor)"
            echo "3) Hardware HAL"
            echo "4) Kernel"
            echo "5) All repositories"
            echo "6) Custom selection"
            echo
            
            while true; do
                read -p "Enter your choice (1-6): " choice
                case $choice in
                    1)
                        UPDATE_REPOS=("device/xiaomi/mars" "device/xiaomi/sm8350-common")
                        break
                        ;;
                    2)
                        UPDATE_REPOS=("vendor/xiaomi/mars" "vendor/xiaomi/sm8350-common")
                        break
                        ;;
                    3)
                        UPDATE_REPOS=("hardware/xiaomi")
                        break
                        ;;
                    4)
                        UPDATE_REPOS=("kernel/xiaomi/sm8350")
                        break
                        ;;
                    5)
                        UPDATE_REPOS=("${existing_repos[@]}")
                        break
                        ;;
                    6)
                        echo
                        log_info "Select repositories to update (enter numbers separated by spaces, e.g., '1 3 4'):"
                        for i in "${!existing_repos[@]}"; do
                            echo "$((i+1))) ${existing_repos[i]}"
                        done
                        echo
                        read -p "Enter your selection: " selection
                        UPDATE_REPOS=()
                        for num in $selection; do
                            if [[ $num =~ ^[0-9]+$ ]] && [ $num -ge 1 ] && [ $num -le ${#existing_repos[@]} ]; then
                                UPDATE_REPOS+=("${existing_repos[$((num-1))]}")
                            fi
                        done
                        if [ ${#UPDATE_REPOS[@]} -eq 0 ]; then
                            log_warning "No valid selection made. Skipping updates."
                            SKIP_UPDATES=true
                        fi
                        break
                        ;;
                    *)
                        log_warning "Invalid choice. Please enter 1-6."
                        ;;
                esac
            done
            
            if [ ${#UPDATE_REPOS[@]} -gt 0 ]; then
                echo
                log_info "Selected repositories for update:"
                for repo in "${UPDATE_REPOS[@]}"; do
                    echo "  - $repo"
                done
                echo
                read -p "Proceed with update? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    SKIP_UPDATES=true
                    log_info "Update cancelled by user."
                fi
            fi
        else
            SKIP_UPDATES=true
            log_info "Repository updates will be skipped."
        fi
    else
        log_info "No existing repositories found. Proceeding with fresh installation."
    fi
}

# Function to update the setup script itself
update_setup_script() {
    log_info "Updating setup script from GitHub..."
    
    local script_path="$(realpath "$0")"
    local backup_path="${script_path}.backup"
    local temp_script="/tmp/setup_new.sh"
    
    # Create backup of current script
    if cp "$script_path" "$backup_path"; then
        log_success "Backup created: $backup_path"
    else
        log_error "Failed to create backup. Aborting script update."
        return 1
    fi
    
    # Download latest version
    if curl -fsSL "https://raw.githubusercontent.com/darkinzen/setup/master/setup.sh" -o "$temp_script"; then
        log_success "Downloaded latest script version"
        
        # Make it executable
        chmod +x "$temp_script"
        
        # Replace current script
        if mv "$temp_script" "$script_path"; then
            log_success "Setup script updated successfully!"
            log_info "The script will now restart with the new version..."
            log_warning "Note: If you want to revert, use: mv $backup_path $script_path"
            echo
            
            # Restart script with same arguments
            exec "$script_path" "$@"
        else
            log_error "Failed to replace script. Restoring backup..."
            mv "$backup_path" "$script_path"
            return 1
        fi
    else
        log_error "Failed to download latest script version"
        log_warning "Check your internet connection or GitHub repository availability"
        return 1
    fi
}

# Function to check if a repository should be updated
should_update_repo() {
    local target_dir="$1"
    
    if [ "$SKIP_UPDATES" = true ]; then
        return 1
    fi
    
    if [ ${#UPDATE_REPOS[@]} -eq 0 ]; then
        return 0  # No existing repos, proceed with normal clone
    fi
    
    for repo in "${UPDATE_REPOS[@]}"; do
        if [ "$repo" = "$target_dir" ]; then
            return 0
        fi
    done
    
    return 1
}

# Function to get kernel branch selection
get_kernel_branch() {
    echo
    log_info "Please select kernel branch:"
    echo "1) 15.0 - Standard Android 15.0 kernel"
    echo "2) kernelsu-next-integration - Kernel with KernelSU Next integration"
    echo
    
    while true; do
        read -p "Enter your choice (1-2): " choice
        case $choice in
            1)
                KERNEL_BRANCH="15.0"
                KERNEL_DESCRIPTION="Standard Android 15.0"
                break
                ;;
            2)
                KERNEL_BRANCH="kernelsu-next-integration" 
                KERNEL_DESCRIPTION="KernelSU Next Integration"
                break
                ;;
            *)
                log_warning "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
    
    log_info "Selected kernel branch: $KERNEL_BRANCH ($KERNEL_DESCRIPTION)"
}

# Function to clone repository with error handling
clone_repo() {
    local repo_url="$1"
    local target_dir="$2"
    local repo_name="$3"
    local branch="${4:-}"
    local with_submodules="${5:-false}"
    
    # Check if repository exists and if we should update it
    if [ -d "$target_dir" ]; then
        if should_update_repo "$target_dir"; then
            log_info "Updating $repo_name..."
            log_warning "Removing existing directory: $target_dir"
            rm -rf "$target_dir"
        else
            log_info "Skipping $repo_name (already exists)"
            return 0
        fi
    else
        log_info "Cloning $repo_name..."
    fi
    
    # Prepare git clone command
    local clone_cmd="git clone"
    
    # Add branch parameter if specified
    if [ -n "$branch" ]; then
        clone_cmd="$clone_cmd -b $branch"
    fi
    
    # Add recursive flag for submodules if specified
    if [ "$with_submodules" = true ]; then
        clone_cmd="$clone_cmd --recursive"
    fi
    
    clone_cmd="$clone_cmd $repo_url $target_dir"
    
    # Clone repository
    if eval "$clone_cmd"; then
        log_success "Successfully cloned $repo_name"
        
        # If submodules weren't cloned initially but are needed, clone them now
        if [ "$with_submodules" = true ] && [ -f "$target_dir/.gitmodules" ]; then
            cd "$target_dir"
            if git submodule update --init --recursive; then
                log_success "Submodules initialized successfully"
            else
                log_warning "Failed to initialize submodules, but main repository was cloned"
            fi
            cd "$ANDROID_SOURCE_DIR"
        fi
    else
        log_error "Failed to clone $repo_name from $repo_url"
        return 1
    fi
}

# Get Android source directory from user
show_welcome_screen
get_android_source_dir

# Initialize update variables
UPDATE_REPOS=()
SKIP_UPDATES=false
UPDATE_SCRIPT=false

# Check for existing repositories and ask user about updates
check_existing_repos

log_info "Starting Android ROM setup for Xiaomi Mars (SM8350)..."

# CLONE DEVICE TREES
log_info "=== Cloning Device Trees ==="
clone_repo "https://github.com/darkinzen/android_device_xiaomi_mars.git" \
           "device/xiaomi/mars" \
           "Mars Device Tree"

clone_repo "https://github.com/darkinzen/android_device_xiaomi_sm8350-common.git" \
           "device/xiaomi/sm8350-common" \
           "SM8350 Common Device Tree"

# CLONE VENDOR FILES
log_info "=== Cloning Vendor Files ==="
clone_repo "https://github.com/darkinzen/proprietary_vendor_xiaomi_mars.git" \
           "vendor/xiaomi/mars" \
           "Mars Vendor Files"

clone_repo "https://github.com/darkinzen/proprietary_vendor_xiaomi_sm8350-common.git" \
           "vendor/xiaomi/sm8350-common" \
           "SM8350 Common Vendor Files"

# CLONE HARDWARE
log_info "=== Cloning Hardware HAL ==="
clone_repo "https://github.com/darkinzen/android_hardware_xiaomi.git" \
           "hardware/xiaomi" \
           "Xiaomi Hardware HAL"

# CLONE KERNEL
log_info "=== Cloning Kernel ==="
get_kernel_branch

clone_repo "https://github.com/darkinzen/android_kernel_xiaomi_sm8350.git" \
           "kernel/xiaomi/sm8350" \
           "SM8350 Kernel ($KERNEL_DESCRIPTION)" \
           "$KERNEL_BRANCH" \
           true

# MIUI CAMERA (Optional)
# Uncomment the following lines if you want to include MIUI camera
# log_info "=== Cloning MIUI Camera (Optional) ==="
# clone_repo "https://gitlab.stud.atlantis.ugent.be/aksrivas/vendor_xiaomi_star-miuicamera.git" \
#            "vendor/xiaomi/star-miuicamera" \
#            "MIUI Camera"



log_success "Android ROM setup completed successfully!"
log_info "You can now proceed with building your ROM."
log_info "Remember to run 'source build/envsetup.sh' and 'lunch' before building."
