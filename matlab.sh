#!/bin/bash

# ==============================================================================
# MATLAB Silent Installation Script
# ==============================================================================
#
# Description:
# This script automates the installation of MATLAB in silent (non-interactive)
# mode on a Linux system. It creates the necessary configuration files to
# specify the installation key, accept the license agreement, and set up
# the network license server.
#
# Based on the "Install Products Programmatically" section of the MathWorks
# installation documentation.
#
# Author: Gemini
# Date: September 27, 2025
#
# ==============================================================================
# INSTRUCTIONS
# ==============================================================================
#
# 1.  **Download & Unzip Installer:**
#     - Download the MATLAB installer ZIP file for Linux from the MathWorks website.
#     - Unzip the installer into a directory.
#
# 2.  **Edit Configuration:**
#     - Fill in the values for the variables in the "USER CONFIGURATION"
#       section below (MATLAB_INSTALLER_PATH, FILE_INSTALLATION_KEY, and
#       INSTALL_PATH).
#
# 3.  **Make Executable:**
#     - Open your terminal and run:
#       chmod +x install_matlab.sh
#
# 4.  **Run with Sudo:**
#     - The script requires root permissions to write to the default installation
#       directory (/usr/local/MATLAB).
#     - Run the script using sudo:
#       sudo ./install_matlab.sh
#
# ==============================================================================

# --- USER CONFIGURATION ---

# Path to the unzipped MATLAB installer directory.
# Example: "/home/user/Downloads/matlab_R2025b_Linux"
MATLAB_INSTALLER_PATH="/path/to/your/matlab_installer_folder"

# Your File Installation Key (FIK).
# This is required for a silent installation. Get this from your license admin
# or your MathWorks Account.
# Example: "12345-67890-12345-67890-12345"
FILE_INSTALLATION_KEY="YOUR-FILE-INSTALLATION-KEY"

# The desired installation directory for MATLAB.
# This script requires sudo because the default path is system-protected.
INSTALL_PATH="/usr/local/MATLAB/R2025b"

# The network license server address.
LICENSE_SERVER="matlab.statler.wvu.edu"

# --- END OF USER CONFIGURATION ---


# --- SCRIPT LOGIC (DO NOT EDIT BELOW THIS LINE) ---

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting MATLAB silent installation script..."

# 1. Validate user configuration and environment
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run with sudo or as the root user."
  exit 1
fi

if [ ! -d "$MATLAB_INSTALLER_PATH" ] || [ ! -f "$MATLAB_INSTALLER_PATH/install" ]; then
    echo "Error: MATLAB installer not found at '$MATLAB_INSTALLER_PATH'."
    echo "Please check the MATLAB_INSTALLER_PATH variable."
    exit 1
fi

if [ "$FILE_INSTALLATION_KEY" == "YOUR-FILE-INSTALLATION-KEY" ]; then
    echo "Error: Please edit the script and set your FILE_INSTALLATION_KEY."
    exit 1
fi

echo "Configuration validated."

# 2. Create temporary configuration files
# The installer needs a properties file for silent mode and a license file
# to point to the network server.

TEMP_DIR=$(mktemp -d)
INSTALLER_INPUT_FILE="$TEMP_DIR/installer_input.txt"
LICENSE_FILE="$TEMP_DIR/network.lic"

echo "Creating temporary configuration files in $TEMP_DIR..."

# Create the installer properties file (installer_input.txt)
# This file automates the answers to the installer's questions.
cat > "$INSTALLER_INPUT_FILE" <<EOF
# Installer properties for silent MATLAB installation

# Installation directory
destinationFolder=$INSTALL_PATH

# File Installation Key
fileInstallationKey=$FILE_INSTALLATION_KEY

# Agree to the license agreement
agreeToLicense=yes

# Installation mode
mode=silent

# Path to the network license file
licensePath=$LICENSE_FILE
EOF

# Create the network license file (network.lic)
# This file tells MATLAB where to find the license server.
# The format is SERVER <hostname> ANY
cat > "$LICENSE_FILE" <<EOF
SERVER $LICENSE_SERVER ANY
USE_SERVER
EOF

echo "Configuration files created successfully."
echo "--- installer_input.txt contents ---"
cat "$INSTALLER_INPUT_FILE"
echo "------------------------------------"
echo "--- network.lic contents ---"
cat "$LICENSE_FILE"
echo "----------------------------"

# 3. Regarding Java Environment
# The official MathWorks installer for Linux bundles its own Java Runtime
# Environment (JRE). Therefore, explicit configuration of a system Java
# is typically not required for the installation to succeed. The installer
# will use its internal JRE automatically.

echo "Note: MATLAB will be installed using its bundled Java Runtime Environment."

# 4. Run the installer
echo "Running the MATLAB installer... This may take a significant amount of time."
"$MATLAB_INSTALLER_PATH/install" -inputFile "$INSTALLER_INPUT_FILE"

echo "Installer finished."

# 5. Clean up temporary files
echo "Cleaning up temporary configuration files..."
rm -rf "$TEMP_DIR"
echo "Cleanup complete."

echo ""
echo "========================================================================"
echo "MATLAB installation complete!"
echo "You can now run MATLAB from: $INSTALL_PATH/bin/matlab"
echo "Consider adding this directory to your system's PATH for easier access."
echo "========================================================================"

exit 0

