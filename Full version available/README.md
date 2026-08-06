# Class Tracking

The project contains a Flutter mobile application, a Node/Express web and API
server, and a MySQL database dump.

## Requirements

- Flutter 3.44 or a compatible newer release
- Node.js 20.12 or newer
- Docker Desktop (recommended) or MySQL 8
- Android Studio/emulator or an Android device

## 1. Start MySQL

The Compose service imports `13-10-67.sql` and the missing
`course_conditions` migration only when its data volume is created for the
first time.

```bash
docker compose up -d mysql
docker compose ps
```

If an existing database was imported before this migration was added, apply it
manually:

```bash
docker compose exec -T mysql mysql -u root -p mysql_nodejs < database/migrations/001_create_course_conditions.sql
```

## 2. Configure and start the API

```bash
cd 'API&Web'
cp .env.example .env
npm ci
npm run check
npm start
```

The development values in `.env.example` match the defaults in `compose.yaml`.
Replace every password and session key before production use.

Verify the API and database together:

```bash
curl http://localhost:4000/health
```

Expected response:

```json
{"status":"ok","database":"connected"}
```

## 3. Run Flutter

Android emulator:

```bash
cd Application
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Physical Android device on the same LAN:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_LAN_IP:4000
```

Cloudflare production hostname:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

See `cloudflare/README.md` for tunnel setup.

## Data and security notes

- Leave documents are currently stored in MySQL `LONGBLOB` columns. R2
  migration should be done separately after the restored system is verified.
- `API&Web/.env` is ignored and must never be committed.
- The old database password that was previously committed must be rotated.
- `node_modules` must not be committed. Always recreate it with `npm ci`.
