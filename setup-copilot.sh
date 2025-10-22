#!/bin/bash
set -e

echo "🤖 VEP MVP - GitHub Copilot Setup"
echo "=================================="

# Check if VS Code is installed
if ! command -v code &> /dev/null; then
    echo "❌ VS Code is not installed. Please install VS Code first:"
    echo "   https://code.visualstudio.com/"
    exit 1
fi

echo "✅ VS Code is installed"

# Check if GitHub Copilot extension is installed
if ! code --list-extensions | grep -q "github.copilot"; then
    echo "❌ GitHub Copilot extension not found. Installing..."
    code --install-extension github.copilot
    code --install-extension github.copilot-chat
    echo "✅ GitHub Copilot extensions installed"
else
    echo "✅ GitHub Copilot extension is installed"
fi

# Check if user is logged into GitHub
if ! gh auth status &> /dev/null; then
    echo "❌ Not logged into GitHub. Please run:"
    echo "   gh auth login"
    exit 1
fi

echo "✅ GitHub authentication verified"

# Run the main setup script
echo ""
echo "📦 Running main project setup..."
./setup.sh

echo ""
echo "🎉 GitHub Copilot setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Open VS Code: code ."
echo "2. Read .github/copilot/README.md for agent instructions"
echo "3. Start with Agent 1: .github/copilot/agent-1-database.md"
echo "4. Press Ctrl+I (or Cmd+I) in VS Code to invoke GitHub Copilot"
echo ""
echo "Happy coding! 🚀"