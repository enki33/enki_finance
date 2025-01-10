#!/bin/bash

# Make script executable
chmod +x setup.sh

# Print colorful messages
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Cleaning project...${NC}"
flutter clean

echo -e "${GREEN}Getting dependencies...${NC}"
flutter pub get

echo -e "${GREEN}Running build_runner...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

echo -e "${GREEN}Setup complete!${NC}" 