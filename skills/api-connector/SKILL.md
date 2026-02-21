---
name: api-connector
description: Universal REST API integration framework. Connect to any API (Stripe, Calendly, Mailchimp, etc.) with stored credentials, reusable templates, and automation chains. Use when making API calls, managing integrations, or building webhook workflows.
---

# API Connector

## Purpose

Generic framework for connecting to any REST API. Configure a connection once, save request templates, and reuse them forever — no code required each time.

## Data Locations

- **Connections:** `integrations/connections.json`
- **Logs:** `integrations/logs/YYYY-MM-DD.jsonl`

Create `integrations/` and `integrations/logs/` directories if they don't exist.

---

## connections.json Schema

```json
{
  "connections": [
    {
      "id": "unique-slug",
      "name": "Human-Readable Name",
      "baseUrl": "https://api.example.com/v1",
      "auth": { ... },
      "headers": { "Content-Type": "application/json" },
      "enabled": true,
      "healthCheck": { "method": "GET", "path": "/status" },
      "rateLimit": { "maxPerMinute": 60 },
      "templates": [
        {
          "name": "template-name",
          "method": "GET|POST|PUT|PATCH|DELETE",
          "path": "/endpoint",
          "headers": {},
          "body": {},
          "description": "What this template does"
        }
      ]
    }
  ],
  "chains": [
    {
      "id": "chain-slug",
      "name": "Chain Name",
      "steps": [
        {
          "connection": "connection-id",
          "template": "template-name",
          "vars": {},
          "extractTo": { "varName": "$.json.path" }
        }
      ]
    }
  ]
}
```

### Auth Object Formats

```json
// Bearer token
{ "type": "bearer", "token": "sk_live_xxxx" }

// API key in header
{ "type": "apikey-header", "headerName": "X-API-Key", "key": "abc123" }

// API key in query parameter
{ "type": "apikey-query", "paramName": "api_key", "key": "abc123" }

// Basic auth
{ "type": "basic", "username": "user", "password": "pass" }

// OAuth2 client credentials
{ "type": "oauth2-client", "tokenUrl": "https://auth.example.com/token", "clientId": "xxx", "clientSecret": "xxx", "scope": "read write" }
```

---

## 🔒 Safety Rules — ALWAYS FOLLOW

1. **Mask credentials** — NEVER display full API keys/tokens/secrets. Show only last 4 chars: `sk_...4xYz`. Apply when logging, displaying connections, or echoing config.
2. **Confirm destructive requests** — Before executing any POST, PUT, PATCH, or DELETE that modifies external data, show the user exactly what will be sent and ask for confirmation.
3. **Rate limit awareness** — Track calls per connection. If `rateLimit.maxPerMinute` is set and approaching the limit, warn before proceeding.
4. **Dry run by default for new templates** — When a user creates a new template, do a dry run first (show the full request without sending) before the first real execution.
5. **Never commit secrets** — If connections.json is in a git repo, ensure it's in `.gitignore`.
6. **Log responsibly** — Logs include request/response metadata but NEVER auth headers or tokens. Mask any credentials that appear in response bodies.

---

## Core Operations

### 1. Add a Connection

When the user says "Connect to [service] with key [key]" or similar:

1. Read `integrations/connections.json` (create with `{"connections":[],"chains":[]}` if missing)
2. Generate an `id` slug from the service name (e.g., `stripe-main`)
3. Build the connection object with appropriate auth type
4. Validate — ensure no duplicate ID
5. Write back the file
6. Confirm: show connection name, base URL, auth type (masked key)

**Example:**
```
User: "Connect to Stripe with bearer token sk_test_abc123def456"
→ Creates connection:
  id: stripe-main
  baseUrl: https://api.stripe.com/v1
  auth: bearer (token: sk_...f456)
  headers: Content-Type: application/x-www-form-urlencoded
```

### 2. List Connections

Read `integrations/connections.json` and display each connection:
- Name, ID, base URL, auth type, enabled/disabled, template count
- ALWAYS mask credentials

### 3. Enable/Disable Connection

Toggle `enabled` field. Disabled connections refuse all requests.

### 4. Test Connection

Execute the `healthCheck` endpoint (or a sensible default like `GET /` or `GET /status`).
Report: status code, response time, success/failure.

### 5. Remove Connection

Confirm with user, then remove from connections array.

---

## Request Builder

### Making Requests

When the user says "Call [connection]: [template]" or "GET/POST [connection] /path":

1. Look up connection by ID or name (case-insensitive match)
2. Verify connection is enabled
3. If a template name is given, load it; otherwise build from the raw method+path
4. Apply variable substitution (see below)
5. Construct full URL: `baseUrl + path`
6. Apply auth (add header/query param per auth type)
7. For OAuth2: fetch access token first if expired
8. **If POST/PUT/PATCH/DELETE: show request and confirm**
9. Execute via `web_fetch` or `curl` (via exec)
10. Log the call
11. Return parsed response

### Variable Substitution

Templates can include `{{variable}}` placeholders in URLs, paths, headers, and body:

```json
{
  "name": "get-customer",
  "method": "GET",
  "path": "/customers/{{customer_id}}",
  "description": "Fetch a customer by ID"
}
```

When invoked: "Call Stripe: get-customer where customer_id=cus_abc123"

**Built-in variables** (always available):
- `{{date}}` → today's date (YYYY-MM-DD)
- `{{timestamp}}` → Unix epoch seconds
- `{{datetime}}` → ISO 8601 datetime

### Response Parsing

Extract specific fields from JSON responses using dot notation or JSONPath:

- "Call Stripe: check-balance and extract available[0].amount"
- Save extracted values as variables for chain steps

---

## Logging

Every API call gets logged to `integrations/logs/YYYY-MM-DD.jsonl`:

```json
{
  "timestamp": "2026-02-15T14:30:00Z",
  "connection": "stripe-main",
  "template": "check-balance",
  "method": "GET",
  "url": "https://api.stripe.com/v1/balance",
  "status": 200,
  "responseTimeMs": 342,
  "success": true,
  "error": null
}
```

**Never log:** auth headers, tokens, API keys, or sensitive request/response bodies.

---

## Pre-built Integration Templates

When a user connects to a known service, auto-suggest these templates.

### Stripe (`https://api.stripe.com/v1`)

Auth: Bearer token. Headers: `Content-Type: application/x-www-form-urlencoded`

| Template | Method | Path | Description |
|----------|--------|------|-------------|
| `check-balance` | GET | `/balance` | Current account balance |
| `list-charges` | GET | `/charges?limit={{limit\|10}}` | Recent payments |
| `get-charge` | GET | `/charges/{{charge_id}}` | Single charge details |
| `list-customers` | GET | `/customers?limit={{limit\|10}}` | List customers |
| `create-invoice` | POST | `/invoices` | Create draft invoice (body: `customer={{customer_id}}`) |
| `list-invoices` | GET | `/invoices?limit={{limit\|10}}` | Recent invoices |
| `create-payment-link` | POST | `/payment_links` | Create payment link |

### Calendly (`https://api.calendly.com`)

Auth: Bearer token. Headers: `Content-Type: application/json`

| Template | Method | Path | Description |
|----------|--------|------|-------------|
| `get-user` | GET | `/users/me` | Current user info |
| `list-events` | GET | `/scheduled_events?user={{user_uri}}&min_start_time={{date}}T00:00:00Z` | Upcoming events |
| `list-event-types` | GET | `/event_types?user={{user_uri}}` | Available event types |
| `get-event` | GET | `/scheduled_events/{{event_id}}` | Single event details |

### Mailchimp (`https://{{dc}}.api.mailchimp.com/3.0`)

Auth: Basic (username: `anystring`, password: API key). Note: `{{dc}}` = datacenter from API key suffix (e.g., `us21`).

| Template | Method | Path | Description |
|----------|--------|------|-------------|
| `list-audiences` | GET | `/lists` | All audiences/lists |
| `add-subscriber` | POST | `/lists/{{list_id}}/members` | Add subscriber (body: `{"email_address":"{{email}}","status":"subscribed"}`) |
| `list-campaigns` | GET | `/campaigns?count={{limit\|10}}` | Recent campaigns |
| `create-campaign` | POST | `/campaigns` | Create campaign |
| `get-subscriber` | GET | `/lists/{{list_id}}/members/{{subscriber_hash}}` | Get subscriber (hash = MD5 of lowercase email) |

### Google Sheets (`https://sheets.googleapis.com/v4/spreadsheets`)

Auth: Bearer token (OAuth2 or service account).

| Template | Method | Path | Description |
|----------|--------|------|-------------|
| `read-range` | GET | `/{{spreadsheet_id}}/values/{{range}}` | Read cell range (e.g., `Sheet1!A1:D10`) |
| `write-range` | PUT | `/{{spreadsheet_id}}/values/{{range}}?valueInputOption=USER_ENTERED` | Write to range |
| `append-row` | POST | `/{{spreadsheet_id}}/values/{{range}}:append?valueInputOption=USER_ENTERED` | Append row |
| `get-spreadsheet` | GET | `/{{spreadsheet_id}}` | Spreadsheet metadata |

### Webhooks (Generic)

No stored connection needed — direct URL:

| Template | Method | Description |
|----------|--------|-------------|
| `post-webhook` | POST | Send JSON payload to any URL |
| `discord-webhook` | POST | Discord-formatted message (`{"content":"{{message}}"}`) |
| `slack-webhook` | POST | Slack-formatted message (`{"text":"{{message}}"}`) |

**Usage:** "POST to webhook https://hooks.zapier.com/xxx with {"event":"signup","email":"j@x.com"}"

→ Show full request, confirm, then send.

---

## Automation Chains

Chains execute multiple API calls in sequence, passing data between steps.

### Chain Schema

```json
{
  "id": "new-client-onboard",
  "name": "New Client Onboarding",
  "steps": [
    {
      "connection": "crm-main",
      "template": "get-client",
      "vars": { "client_id": "{{input.client_id}}" },
      "extractTo": { "client_name": "$.name", "client_email": "$.email" }
    },
    {
      "connection": "mailchimp-main",
      "template": "add-subscriber",
      "vars": { "email": "{{client_email}}", "list_id": "abc123" }
    },
    {
      "connection": "slack-webhook",
      "template": "post-webhook",
      "vars": { "message": "New client onboarded: {{client_name}}" }
    }
  ]
}
```

### Running a Chain

"Run chain: new-client-onboard with client_id=12345"

1. Execute each step in order
2. Extract specified fields from responses into variables
3. Substitute variables into subsequent steps
4. **Confirm each destructive step individually** (or user can pre-approve all)
5. Log entire chain execution
6. Report results for each step

### Scheduled Chains

Use OpenClaw cron to schedule recurring API calls:

```
"Schedule: Run chain daily-report every day at 9am"
→ Creates cron job that triggers the chain
```

---

## Dry Run Mode

When the user says "dry run" or for first-time template execution:

```
🔍 DRY RUN — Nothing will be sent

POST https://api.stripe.com/v1/invoices
Headers:
  Authorization: Bearer sk_...f456
  Content-Type: application/x-www-form-urlencoded
Body:
  customer=cus_abc123

→ Say "send it" to execute for real.
```

---

## Commands Quick Reference

| Command | Action |
|---------|--------|
| "Connect to [service] with [auth]" | Add new connection |
| "List all API connections" | Show all connections |
| "Test [connection] connection" | Health check |
| "Enable/Disable [connection]" | Toggle connection |
| "Remove [connection]" | Delete connection |
| "Call [connection]: [template]" | Execute template |
| "GET/POST/etc [connection] /path" | Raw request |
| "Create template [name] for [connection]" | Save new template |
| "POST to webhook [url] with [data]" | Direct webhook call |
| "Run chain: [chain-name]" | Execute automation chain |
| "Dry run: [any request]" | Preview without sending |
| "Show logs for [connection]" | View call history |

---

## Workflow Examples

### Quick Stripe Balance Check
```
User: "Check my Stripe balance"
1. Find stripe connection → stripe-main
2. Load template → check-balance (GET /balance)
3. Apply auth → Bearer header
4. Execute → GET https://api.stripe.com/v1/balance
5. Parse response → "Available: $1,234.56 USD"
```

### Webhook Notification
```
User: "POST to webhook https://hooks.slack.com/xxx with {\"text\": \"Deploy complete\"}"
1. Show full request for confirmation
2. User confirms
3. POST with JSON body
4. Log result
5. Report: "✅ Webhook sent — 200 OK"
```

### Multi-step Chain
```
User: "Run chain: new-client-onboard with client_id=500"
1. Step 1: GET client from CRM → extracts name, email
2. Step 2: POST add subscriber to Mailchimp → confirms first
3. Step 3: POST notification to Slack webhook → confirms first
4. Report: "Chain complete — 3/3 steps succeeded"
```

---

## Error Handling

- **401/403:** Auth failed — suggest checking/refreshing credentials
- **404:** Endpoint not found — verify path and base URL
- **429:** Rate limited — show retry-after header, wait if possible
- **5xx:** Server error — log and suggest retry
- **Timeout:** Report and suggest increasing timeout or checking connectivity
- **OAuth2 token expired:** Auto-refresh using client credentials flow, retry request

## File Bootstrap

When first used, create the required structure:

```
integrations/
  connections.json    ← {"connections":[],"chains":[]}
  logs/               ← empty directory
```
