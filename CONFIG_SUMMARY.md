# Supabase Dev Stack Config Summary

This file summarizes the current configuration and highlights changes from the upstream repository.
Secrets are redacted.

## Current Configuration (Key Values)

- Environment file: env/supabase.yml
- Deploy user: jlamere
- Docker users: jlamere
- Grafana auth: anonymous enabled
- Grafana URL: https://monitor.supabase-dev.haywirenetworks.com
- Supabase Studio URL (site_url): https://app.supabase-dev.haywirenetworks.com
- Supabase API URL (api_external_url): https://supa.supabase-dev.haywirenetworks.com
- Auth portal (SSO): https://auth.supabase-dev.haywirenetworks.com
- Root cookie domain: supabase-dev.haywirenetworks.com
- Caddy DNS-01 provider: cloudflare
- Cloudflare token: [REDACTED] (stored in env/supabase.secrets.yml, encrypted)
- GitHub OAuth:
  - client_id: [REDACTED]
  - client_secret: [REDACTED] (stored in env/supabase.secrets.yml, encrypted)
  - allow_list: github.com/jlamere-haywire
- SMTP (Postmark):
  - host: smtp.postmarkapp.com
  - user: [REDACTED]
  - password: [REDACTED]
  - sender: jlamere@gohaywire.com
- Supabase secrets (stored in env/supabase.secrets.yml, encrypted):
  - postgres_db_pwd: [REDACTED]
  - sb_jwt_secret: [REDACTED]
  - sb_anon_key: [REDACTED]
  - sb_service_role_key: [REDACTED]
  - secret_key_base: [REDACTED]

## URLs in Use

- Supabase Studio (frontend): https://app.supabase-dev.haywirenetworks.com
- Supabase API (Kong): https://supa.supabase-dev.haywirenetworks.com
- Auth portal (Caddy SSO): https://auth.supabase-dev.haywirenetworks.com
- Grafana (monitoring): https://monitor.supabase-dev.haywirenetworks.com

## Changes From Upstream Repo

### env/supabase.yml

- Set deploy user and docker users to jlamere.
- Enabled Grafana anonymous access.
- Updated domain set to supabase-dev.haywirenetworks.com for auth, API, Studio, and monitor.
- Added Cloudflare DNS-01 settings for Caddy.
- Filled Supabase secrets (JWT, service role, etc.) and Postgres password.
- Added GitHub OAuth app credentials and allow list.
- Configured SMTP for Postmark.

### env/supabase.secrets.yml (new, encrypted)

- Stores all sensitive values (Supabase keys, Postmark creds, Cloudflare token, GitHub OAuth secret).
- Encrypted with Ansible Vault; password stored in ~/.ansible/.vault_pass.

### install.sh

- Loads env/supabase.secrets.yml when present.
- Uses the vault password file automatically when it exists.

### Caddy Role

- Build Caddy with the Cloudflare DNS plugin when DNS-01 is enabled.
- Inject CLOUDFLARE_API_TOKEN into the systemd unit.
- Add TLS DNS-01 blocks for Cloudflare in all Caddyfile templates (GitHub/GitLab/Discord).

## Files Modified

- env/supabase.yml
- roles/caddy/tasks/main.yml
- roles/caddy/templates/caddy.service.j2
- roles/caddy/templates/Caddyfile-github.j2
- roles/caddy/templates/Caddyfile-gitlab.j2
- roles/caddy/templates/Caddyfile-discord.j2
- env/supabase.secrets.yml (new, encrypted)
- install.sh
