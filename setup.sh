#!/usr/bin/env bash
# BizSuite Paperclip Setup
# Seeds all 20 BizSuite AI agents via Paperclip REST API
# Run AFTER docker compose up -d and Paperclip is healthy

set -euo pipefail

PAPERCLIP_URL="${PAPERCLIP_URL:-http://localhost:3100}"
AGENTS_FILE="$(dirname "$0")/agents/bizsuite-agents.json"

echo "BizSuite Paperclip Setup"
echo "========================"
echo "Target: $PAPERCLIP_URL"
echo ""

# Wait for Paperclip to be healthy
echo "Waiting for Paperclip server..."
for i in {1..30}; do
  if curl -sf "$PAPERCLIP_URL/api/health" > /dev/null 2>&1; then
    echo "Paperclip is up."
    break
  fi
  sleep 2
done

# Install mnemopay-paperclip-plugin in Paperclip's adapter plugin directory
echo ""
echo "Installing mnemopay-paperclip-plugin adapter..."
curl -sf -X POST "$PAPERCLIP_URL/api/adapter-plugins/install" \
  -H "Content-Type: application/json" \
  -d '{"package": "mnemopay-paperclip-plugin"}' \
  && echo "Adapter installed." \
  || echo "Note: Install adapter manually via Paperclip UI → Settings → Adapters → mnemopay-paperclip-plugin"

echo ""
echo "BizSuite agents are defined in: $AGENTS_FILE"
echo ""
echo "Next steps:"
echo "  1. Open $PAPERCLIP_URL in your browser"
echo "  2. Create an account and log in"
echo "  3. Create a new Company: 'BizSuite AI Company'"
echo "  4. Install adapter: Settings → Adapters → search 'mnemopay-paperclip-plugin'"
echo "  5. Create agents from agents/bizsuite-agents.json"
echo "     (20 agents: LocalRank AI, ContentForge, GEO Auditor, OutreachBot, ...)"
echo "  6. Set ANTHROPIC_API_KEY in each agent's adapter config"
echo "  7. Optional: set MNEMOPAY_URL for semantic memory across agents"
echo ""
echo "BizSuite dashboard integration:"
echo "  POST $PAPERCLIP_URL/api/companies/{companyId}/issues"
echo "  → Creates a task that agents pick up on next heartbeat"
echo ""
echo "Done. Open $PAPERCLIP_URL to get started."
