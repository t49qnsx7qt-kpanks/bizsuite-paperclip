# BizSuite × Paperclip

Runs all 20 BizSuite AI plugins as autonomous Paperclip agents, each with MnemoPay Agent FICO behavioral scoring.

## Architecture

```
BizSuite Dashboard (getbizsuite.com)
          │
          │  POST /api/companies/{id}/issues
          ▼
  Paperclip (localhost:3100)
          │
          ├── LocalRank AI          [SEO]
          ├── ContentForge          [Content]
          ├── GEO Auditor           [GEO]
          ├── Competitor Intel      [GEO]
          ├── Brand Tracker         [GEO]
          ├── OutreachBot           [Sales]
          ├── LeadFlow              [Sales]
          ├── ProposalForge         [Sales]
          ├── ReferralHub           [Sales]
          ├── RenewalIQ             [Operations]
          ├── ReviewPulse           [Operations]
          ├── OnboardFlow           [Operations]
          ├── ContentCalendar       [Operations]
          ├── InvoiceTracker        [Operations]
          ├── BookingEngine         [Operations]
          ├── ChatCapture           [Operations]
          ├── InsightBoard          [Operations]
          ├── ContractVault         [Operations]
          ├── BillSync              [Operations]
          └── PageForge             [Marketing]
                    │
                    │  mnemopay-paperclip-plugin adapter
                    ▼
          MnemoPay (localhost:3200) ← optional
          Agent FICO scoring + semantic memory
```

Each agent runs on its own heartbeat schedule (30min–weekly depending on task type), uses Claude Haiku by default, and accumulates an Agent FICO score from its execution history.

## Quick Start

### 1. Copy env file

```bash
cp .env.example .env
# Fill in BETTER_AUTH_SECRET and ANTHROPIC_API_KEY
```

Generate a secret:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 2. Start Paperclip

```bash
docker compose up -d
```

Paperclip UI will be at http://localhost:3100

### 3. Install the MnemoPay adapter

In Paperclip UI → Settings → Adapters → Install → search `mnemopay-paperclip-plugin`

### 4. Seed agents

The 20 agent configs are in `agents/bizsuite-agents.json`. Create them in Paperclip:
- Create a Company named "BizSuite AI Company"
- Create each agent with adapter type `mnemopay` and the taskPrompt from the JSON

```bash
bash setup.sh
```

### 5. Optional: Enable semantic memory

Run the MnemoPay MCP server:
```bash
cd ~/Projects/mnemopay-sdk && npm run mcp
```

Then set `MNEMOPAY_URL=http://localhost:3200` in Paperclip's environment. Agents will recall relevant memories before each execution and store outcomes after.

## Heartbeat Schedule

| Agent | Heartbeat | Why |
|-------|-----------|-----|
| ChatCapture, BookingEngine | 30-60 min | Real-time customer interactions |
| OutreachBot, ReviewPulse, RenewalIQ | 60-180 min | Time-sensitive sales/support |
| ContentForge, GEO Auditor, etc. | 720 min | Batch content/analysis work |
| ContentCalendar, InsightBoard | Weekly | Strategic planning cadence |

## BizSuite Dashboard Integration

Trigger any agent from BizSuite's Express server:

```javascript
// In bizsuite-site/server.js
await fetch('http://localhost:3100/api/companies/COMPANY_ID/issues', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer PAPERCLIP_KEY' },
  body: JSON.stringify({
    title: 'Generate invoice for Order #123',
    description: 'Client: Acme Corp, Amount: $2500, Due: 2026-04-30',
    assigneeId: 'INVOICE_TRACKER_AGENT_ID'
  })
});
```

## Agent FICO Scoring

Each agent's FICO score builds up over time:
- New agents start at 650 (baseline)
- Successful runs push score toward 850
- Failures push score down
- FICO gating can block misbehaving agents automatically

View scores in Paperclip's agent dashboard or query the session state via the API.
