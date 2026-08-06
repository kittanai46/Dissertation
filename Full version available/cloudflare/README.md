# Cloudflare Tunnel

Use a named tunnel for a stable production hostname. The Node API continues to
listen only on the host; Cloudflare publishes it over HTTPS without opening an
inbound router port.

## Dashboard-managed tunnel (recommended)

1. In Cloudflare, open **Networking > Tunnels** and create a tunnel.
2. Install `cloudflared` on the machine that will run the API.
3. Add a published application route:
   - Hostname: `api.<your-domain>`
   - Service: `http://localhost:4000`
4. Install/run the connector using the token shown by Cloudflare. Do not save
   the token in this repository.
5. Verify `https://api.<your-domain>/health`.

For production, set these values in `API&Web/.env`:

```dotenv
NODE_ENV=production
COOKIE_SECURE=true
CORS_ORIGINS=https://admin.example.com
SESSION_KEYS=<random-key-1>,<random-key-2>
```

Run Flutter against the stable hostname:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

Quick tunnels are suitable only for temporary testing:

```bash
cloudflared tunnel --url http://localhost:4000
```

Anyone who knows a public tunnel URL can reach its public API routes. Add
application authentication before treating the API as production-ready.
