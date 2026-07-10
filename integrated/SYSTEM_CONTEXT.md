# Integrated System — System Context

Last updated: 2026-07-10

## Purpose

Provide a concise, runnable system context for the integrated deployment that ties together TestPoint, Voxify, NewChange and the Integration Hub. This document describes architecture, components, integration APIs, data flows, ports, security, operational notes, and assumptions needed to run and maintain the integrated system.

## High-level Overview

- The integrated system consists of four web services (Flask-based) running on the same host or local network:
  - TestPoint (student/exam system) — default port 5000
  - Voxify (voting/election system) — default port 5001
  - NewChange (academic management) — default port 5002
  - Integration Hub (`hub`) — aggregator and dashboard — default port 5003
- The Hub aggregates health, stats, and cross-system lookups and provides a central UI for linking the services together.

## Components

- Integration Hub (`hub/app.py`)
  - Aggregates APIs from TestPoint, Voxify, and NewChange
  - Provides live dashboard (`hub/templates/hub.html`) for system status and cross-lookup
  - Configuration: expects service URLs (IP + port) that can be updated via UI or env vars
- TestPoint (`testpoint_app`)
  - Student, Teacher, Admin modules (Flask blueprints)
  - Features: OTP, document upload (PDF), exam proctoring (fullscreen, blur detection), analytics
  - Exposes internal API endpoints under `/api/*` used by other systems (health, students, voting-status)
- Voxify (`voxify_app`)
  - Voting system with Admin/Voter/Authentication blueprints
  - Exposes API endpoints for elections, voters, and a small integration API used by Hub and TestPoint
  - DB setup scripts create tables like `trusted_devices`, `announcements`; uses `get_db_connection` helper
- NewChange (`newchange_app`)
  - Administrative features and an API for students/enrollment used by other systems

## Ports & URLs

- TestPoint: http://localhost:5000 (API: `/api/...`)
- Voxify: http://localhost:5001 (API: `/api/...`, voters status `/api/voters/status/<student_id>`)
- NewChange: http://localhost:5002 (API: `/api/...`)
- Integration Hub: http://localhost:5003 (UI dashboard)

Note: On demo days or multi-machine deployments, use real IP addresses (e.g. `http://192.168.1.5:5000`) and update either env vars or the Hub UI.

## Integration API Summary (exposed by each system)

- Health & status:
  - `GET /api/ping` — health check
  - `GET /api/stats` — dashboard counts
- TestPoint-specific:
  - `GET /api/students` — all active students
  - `GET /api/students/<id>` — student details
  - `POST /api/students/<id>/voting-status` — receive vote notification (used by Voxify/Hub)
- Voxify-specific:
  - `GET /api/elections` — list elections
  - `GET /api/elections/<id>/results` — results
  - `GET /api/voters/status/<student_id>` — whether a student has voted
  - `POST /api/voters/import-from-testpoint` — import voters from TestPoint
- NewChange-specific:
  - `GET /api/students/active`
  - `POST /api/students/enroll-verified` — enroll after verification

The Integration Hub calls these endpoints to display consolidated data and to trigger cross-system actions (e.g., import, verification, lookup).

## Data Flows & Integration Patterns

- Hub → Service: Hub polls `GET /api/ping` and `GET /api/stats` for status and aggregated metrics.
- Voxify ↔ TestPoint: Voxify queries `GET /api/voters/status/<student_id>` on TestPoint (or vice versa depending on configuration) to check voting status; supports `POST` notifications for votes.
- NewChange ↔ TestPoint: NewChange may call TestPoint endpoints to verify enrollment or fetch student info when enrolling via cross-system flows.
- Import flows: Voxify can `POST /api/voters/import-from-testpoint` to pull student data from TestPoint.

## Authentication, Sessions & Secrets

- Services use simple session configurations and environment-driven secret values. Examples observed in repo:
  - Hard-coded or env-backed Flask `secret_key` in several app factories (e.g., Voxify uses a secret key string in code)
  - DB passwords and SMTP credentials are loaded from `.env` / `passwordDB.env` (e.g., `DBPASSWORD`, `GMAIL`, `GMAILPASS`)
  - Gmail SMTP is used for OTP emails (flask-mail or custom SMTP configs). Ensure app-specific passwords or secure SMTP credentials are used.
- Session cookie settings (examples from Voxify): `SESSION_COOKIE_SECURE`, `SESSION_COOKIE_HTTPONLY`, `SESSION_COOKIE_SAMESITE`, and `PERMANENT_SESSION_LIFETIME` are configured. Verify these for production.

## Databases & Schema

- Each service manages its own database schema (MySQL). Example DB names and connections found in code:
  - TestPoint: `test_point` database
  - Voxify: `db_voting` database
- Startup initialization functions exist to create or alter tables if missing (e.g., create `trusted_devices`, add `photo` column to `candidates`, create `announcements`). These run in app context on startup.

## Running & Deployment

- Local developer start script: `integrated/start_all.sh` (Linux/macOS shell) starts all apps in background using `python app.py` and `pip install` for Hub dependencies.
- Manual run (Windows): Open four terminals and run each app from its folder: `python app.py` for each of `testpoint_app`, `voxify_app`, `newchange_app`, and `hub`.
- Environment variables:
  - `VOXIFY_URL`, `TESTPOINT_URL` are referenced by UI and some cross-system code; set these to point to the correct host:port values when not localhost.
  - Create `passwordDB.env` or configure OS env vars for DB and SMTP credentials.

## Security Considerations

- OTP and email: OTPs are a key verification mechanism. OTP tables and rate limits (e.g., 5 per hour) are implemented; keep rate limits enforced.
- File uploads: verification documents are stored under `static/uploads/verifications` — validate file types (PDF) and enforce storage permissions.
- Proctoring: Exam lockdown uses client-side detection (fullscreen, blur, visibilitychange). These are not foolproof; server-side logging and throttling are important.
- Secrets handling: Replace any hard-coded secrets in code with environment variables or a secure secrets store before production.
- CORS and network exposure: If services are exposed beyond localhost, configure CORS and reverse proxy rules (nginx) and use TLS for all public endpoints.

## Operational Notes

- Health checks: Use `GET /api/ping` for service monitoring and alerting.
- Database migrations: Code includes inline create/alter helpers; adopt migration tooling (Alembic, Flyway) for production schema changes.
- Backups: Regular MySQL backups for each service DB recommended.
- Logging & Audits: Centralize logs (syslog/ELK) for cross-service auditing, especially for OTP events, vote notifications, and admin approvals.

## Assumptions & Constraints

- Assumes services run on same LAN or host; cross-host deployments require correct `VOXIFY_URL` / `TESTPOINT_URL` env vars.
- The Integration Hub acts as a read/aggregation layer — it does not replace authoritative data in each system.
- Auth flows remain local to each service (users log into the specific system they belong to). No SSO is implemented by default across services.

## Quick Start (local)

1. Ensure Python 3.8+, MySQL, and required env vars are set.
2. Start services (example manual steps):

```bash
# Terminal 1
cd testpoint_app && python app.py

# Terminal 2
cd voxify_app && python app.py

# Terminal 3
cd newchange_app && python app.py

# Terminal 4
cd hub && pip install flask requests -q && python app.py
```

3. Open the Hub at `http://localhost:5003` and set service URLs if needed.

## Where to Look in the Repo

- Hub: `hub/app.py`, `hub/templates/hub.html`
- TestPoint: `testpoint_app/` (blueprints under `Auth`, `Student`, `Teacher`, `Admin`)
- Voxify: `voxify_app/Voxify/` (blueprints and `__init__.py`)
- NewChange: `newchange_app/` (Main folder)

---

If you want, I can: (a) add example `docker-compose.yml` to run all services with networks, or (b) convert this document into `integrated/SYSTEM_CONTEXT.txt` to match existing naming. Which would you prefer?
