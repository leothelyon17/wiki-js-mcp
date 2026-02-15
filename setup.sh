#!/bin/bash

# Wiki.js MCP Server Setup Script
# This script sets up the Python virtual environment and installs dependencies

set -e  # Exit on any error

echo "🚀 Setting up Wiki.js MCP Server..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Python 3.12+ is available
echo "📋 Checking Python version..."
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "❌ Error: Python is not installed or not in PATH"
    exit 1
fi

# Check Python version
PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2)
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 12 ]); then
    echo "❌ Error: Python 3.12+ is required. Found: $PYTHON_VERSION"
    exit 1
fi

echo "✅ Python $PYTHON_VERSION found"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    $PYTHON_CMD -m venv venv
    echo "✅ Virtual environment created"
else
    echo "📦 Virtual environment already exists"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📚 Installing dependencies..."
if [ -f "pyproject.toml" ] && command -v poetry &> /dev/null; then
    if poetry --version >/dev/null 2>&1; then
        echo "📖 Using Poetry for dependency management..."
        poetry install
    else
        echo "⚠️  Poetry command found but isn't working. Falling back to pip..."
        pip install -r requirements.txt
    fi
elif [ -f "requirements.txt" ]; then
    echo "📖 Using pip for dependency management..."
    pip install -r requirements.txt
else
    echo "❌ Error: No pyproject.toml or requirements.txt found"
    exit 1
fi

# Create .env file from example if it doesn't exist
if [ ! -f ".env" ] && [ -f "config/example.env" ]; then
    echo "⚙️  Creating .env file from example..."
    cp config/example.env .env
    echo "✅ .env file created. Please edit it with your Wiki.js credentials."
else
    echo "⚙️  .env file already exists"
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p logs

# Set executable permissions for scripts
echo "🔐 Setting executable permissions..."
chmod +x setup.sh
chmod +x start-server.sh

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Edit .env file with your Wiki.js credentials:"
echo "   - Set WIKIJS_API_URL (e.g., http://localhost:3000)"
echo "   - Set WIKIJS_TOKEN (your JWT token from Wiki.js)"
echo ""
echo "2. Test the server:"
echo "   ./start-server.sh"
echo ""
echo "3. Configure Cursor MCP:"
echo "   - Copy config-mcp.json settings to your Cursor MCP configuration"
echo "   - Update the absolute paths in the configuration"
echo ""
echo "📖 For more information, see README.md" 
