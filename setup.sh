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
NC='\033[0m' # No Color

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

# Function to clone repository with error handling
clone_repo() {
    local repo_url="$1"
    local target_dir="$2"
    local repo_name="$3"
    
    log_info "Cloning $repo_name..."
    
    # Remove existing directory if it exists
    if [ -d "$target_dir" ]; then
        log_warning "Removing existing directory: $target_dir"
        rm -rf "$target_dir"
    fi
    
    # Clone repository
    if git clone "$repo_url" "$target_dir"; then
        log_success "Successfully cloned $repo_name"
    else
        log_error "Failed to clone $repo_name from $repo_url"
        return 1
    fi
}

# Get Android source directory from user
get_android_source_dir

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
clone_repo "https://github.com/darkinzen/android_kernel_xiaomi_sm8350.git" \
           "kernel/xiaomi/sm8350" \
           "SM8350 Kernel"

# MIUI CAMERA (Optional)
# Uncomment the following lines if you want to include MIUI camera
# log_info "=== Cloning MIUI Camera (Optional) ==="
# clone_repo "https://gitlab.stud.atlantis.ugent.be/aksrivas/vendor_xiaomi_star-miuicamera.git" \
#            "vendor/xiaomi/star-miuicamera" \
#            "MIUI Camera"

# KERNELSU SETUP FUNCTIONS
setup_kernelsu_original() {
    log_info "Installing original KernelSU (v0.9.5 for non-GKI device)..."
    if curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s v0.9.5; then
        log_success "Original KernelSU v0.9.5 installed successfully"
        return 0
    else
        log_error "Failed to install original KernelSU v0.9.5"
        return 1
    fi
}

setup_kernelsu_next() {
    log_info "Installing KernelSU Next..."
    if curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -; then
        log_success "KernelSU Next installed successfully"
    else
        log_error "Failed to install KernelSU Next"
        return 1
    fi
    
    # Ask user if they want SUSFS support
    echo
    log_info "SUSFS (Systemless Universal System-as-root File System) provides advanced hiding capabilities."
    read -p "Do you want to install SUSFS support? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing Susfs..."
        if curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next-susfs/kernel/setup.sh" | bash -s next-susfs; then
            log_success "Susfs installed successfully"
        else
            log_error "Failed to install Susfs"
            return 1
        fi
    else
        log_info "Skipping SUSFS installation"
    fi
    
    return 0
}

setup_kernelsu() {
    log_info "=== Setting up KernelSU ==="
    
    if [ ! -d "kernel/xiaomi/sm8350" ]; then
        log_error "Kernel directory not found! Please clone kernel first."
        return 1
    fi
    
    cd "$ANDROID_SOURCE_DIR/kernel/xiaomi/sm8350"
    
    echo
    log_info "Please select KernelSU version:"
    echo "1) Original KernelSU v0.9.5 (tiann/KernelSU) - For non-GKI devices"
    echo "2) KernelSU Next (rifsxd/KernelSU-Next)"
    echo "3) Skip KernelSU setup"
    echo
    
    while true; do
        read -p "Enter your choice (1-3): " choice
        case $choice in
            1)
                if setup_kernelsu_original; then
                    break
                else
                    log_error "Failed to setup original KernelSU"
                    cd "$ANDROID_SOURCE_DIR"
                    return 1
                fi
                ;;
            2)
                if setup_kernelsu_next; then
                    break
                else
                    log_error "Failed to setup KernelSU Next"
                    cd "$ANDROID_SOURCE_DIR"
                    return 1
                fi
                ;;
            3)
                log_info "Skipping KernelSU setup"
                cd "$ANDROID_SOURCE_DIR"
                return 0
                ;;
            *)
                log_warning "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
    
    cd "$ANDROID_SOURCE_DIR"
}

# Ask user if they want to setup KernelSU
echo
read -p "Do you want to setup KernelSU? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    setup_kernelsu
else
    log_info "Skipping KernelSU setup"
fi

log_success "Android ROM setup completed successfully!"
log_info "You can now proceed with building your ROM."
log_info "Remember to run 'source build/envsetup.sh' and 'lunch' before building."
