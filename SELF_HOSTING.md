# Fred SDK — Self-Hosting Guide

## Requirements
- Linux server (Ubuntu 22.04+ recommended)
- 4GB RAM minimum, 8GB recommended
- 2 CPU cores minimum
- 20GB disk space
- Docker 24+ and Docker Compose v2
- A domain name pointing to your server

## Quick Start
```bash
git clone https://github.com/aifredoai/sdk.git fred
cd fred
cp .env.example .env
nano .env
docker compose up -d --build
```

First build takes 5-10 minutes. Fred will be live at your domain once complete.

## Configuration

All config via `.env`. See `.env.example` for full reference.

**Required:**
- `ANTHROPIC_API_KEY` — get one at console.anthropic.com
- `FRED_DOMAIN` — your domain (e.g. fred.yourcompany.com)

**Optional:**
- `GOOGLE_OAUTH_CLIENT_ID` / `GOOGLE_OAUTH_CLIENT_SECRET` — Gmail/Calendar
- `RESEND_API_KEY` — outbound email via Resend
- `TAVILY_API_KEY` — web research

## Google Workspace Setup

1. Create a GCP project at console.cloud.google.com
2. Enable Gmail API, Calendar API, Drive API
3. Create OAuth 2.0 credentials (Web application)
4. Set redirect URI: `https://your-domain/oauth2callback`
5. Add credentials to `.env`
6. Visit `https://your-domain/auth` to authenticate

## Support

- Docs: https://aifredoai.github.io/sdk
- Email: support@aifredo.chat
