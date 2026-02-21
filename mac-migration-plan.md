# Mac Studio Migration Plan
## Moving Jarvis + All Agents to Apple Silicon

### The Hardware
- **Mac Studio #1** → Jarvis (The Brain) + Mule + Forge — runs all agents
- **Mac Studio #2** → Client workloads + redundancy/failover

### Pre-Migration (Do NOW on Windows)
- [x] Keep all workspace files organized and portable
- [x] Stockpile cartoon scripts
- [x] Keep training logs and memory files updated
- [ ] Document all config files and their locations
- [ ] Export openclaw.json, all agent configs, workspace files
- [ ] List all Telegram bot tokens, API keys, credentials
- [ ] Back up everything to GitHub or external drive

### Day 1 — Mac Studio Arrives
1. **Unbox & setup macOS** — updates, Xcode command line tools
2. **Install Homebrew** → `brew install node git python`
3. **Install OpenClaw** → `npm install -g openclaw`
4. **Install Ollama for Mac** → `brew install ollama`
   - Apple Silicon runs models on unified memory (GPU)
   - 512GB = can run 400B+ parameter models (Llama 3.1 405B, Mixtral, etc.)
5. **Pull models:**
   - `ollama pull llama3.1:405b` ← THE BIG ONE (impossible on Windows, easy on 512GB Mac)
   - `ollama pull llama3.1:70b` ← Mule upgrade
   - `ollama pull qwen2.5-coder:32b` ← Forge upgrade  
   - `ollama pull deepseek-coder-v2:236b` ← Beast mode coding
   - `ollama pull mixtral:8x22b` ← Multi-expert model
6. **Copy workspace files** from Windows → Mac
   - All of `~/.openclaw/` (workspace, workspace-mule, workspace-forge, agents, configs)
   - All cartoon scripts, training logs, dashboard
7. **Restore openclaw.json** — update paths from Windows (`C:\Users\alfre\`) to Mac (`/Users/jeremy/`)
8. **Test each agent** — Jarvis, Mule, Forge all responding on Telegram
9. **Test local model performance** — benchmark speeds on 512GB unified memory

### Day 2 — Optimization
1. **Upgrade Jarvis to local model** → Drop Anthropic API, run Llama 405B or comparable locally = $0/month
2. **Upgrade Mule** → From 8B to 70B parameters = WAY smarter, still free
3. **Upgrade Forge** → From 7B to 32B+ = actually good at coding now
4. **Set up Mac Studio #2** as client-facing server
5. **Configure redundancy** — if Mac #1 goes down, Mac #2 takes over
6. **Run speed tests** — compare to old Windows laptop (will be night and day)

### Day 3+ — Empire Mode
1. **Start serving clients** — AI chatbots running on Mac #2
2. **Start YouTube production pipeline** — AI voices + animation on local hardware
3. **Cancel/reduce Anthropic API** — most work runs locally now
4. **Set up remote access** — SSH into Mac Studios from anywhere

### What Changes
| Thing | Windows (Now) | Mac Studio (After) |
|---|---|---|
| Jarvis model | Claude Opus (API, $$$) | Llama 405B (local, $0) |
| Mule model | Llama 3.1 8B | Llama 3.1 70B |
| Forge model | Qwen2.5-Coder 7B | Qwen2.5-Coder 32B |
| VRAM/Memory | 8GB GPU + 16GB RAM | 512GB unified |
| Speed | Slow, bottlenecked | Screaming fast |
| Monthly AI cost | ~$50-200+ API fees | ~$45 electricity |
| Client capacity | Can't serve clients | 10-50+ simultaneous |
| Model options | Tiny models only | ANY open-source model |

### Files to Back Up Before Migration
```
C:\Users\alfre\.openclaw\openclaw.json
C:\Users\alfre\.openclaw\workspace\  (everything)
C:\Users\alfre\.openclaw\workspace-mule\
C:\Users\alfre\.openclaw\workspace-forge\
C:\Users\alfre\.openclaw\agents\
C:\Users\alfre\.openclaw\workspace\memory\
C:\Users\alfre\.openclaw\workspace\dashboard\
C:\Users\alfre\.openclaw\workspace-forge\projects\cartoon\
```

### Credentials to Transfer
- Telegram bot tokens (Jarvis, Mule, Forge)
- GitHub token
- OpenClaw gateway token (or generate new)
- Brave API key (if obtained by then)
- Any client API keys

### Keep Windows Laptop As
- Backup/emergency access
- Mobile workstation
- Testing environment
- Jeremy's daily driver for editing work
