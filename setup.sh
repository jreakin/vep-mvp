#!/bin/bash
set -e

echo "🚀 VEP MVP - Development Setup"
echo "================================"

# Check if UV is installed
if ! command -v uv &> /dev/null; then
    echo "❌ UV is not installed. Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "✅ UV is installed"

# Setup backend
echo ""
echo "📦 Setting up Python backend with UV..."
cd backend

# Create virtual environment with UV
echo "Creating virtual environment..."
uv venv

# Activate virtual environment
source .venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
uv pip install -e ".[dev]"

echo "✅ Backend setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy .env.example to .env and fill in your Supabase credentials"
echo "2. Create a Supabase project at https://supabase.com"
echo "3. Run the migration: psql -d your_db -f migrations/001_initial_schema.sql"
echo "4. Start the server: uv run uvicorn app.main:app --reload"
echo ""
echo "5. Open Cursor IDE and invoke Agent 1 to create the database schema"
echo "6. See AGENT_INSTRUCTIONS.md for detailed agent instructions"
echo ""
echo "Happy coding! 🎉"
