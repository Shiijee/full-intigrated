# IT 3012 — Integration Setup Guide

## What was added to each system

### TestPoint (port 5000)
- **New file:** `testpoint/api.py` — Flask blueprint with 5 API endpoints
- **Modified:** `testpoint/__init__.py` — registers the API blueprint
- **Modified:** `testpoint/Student/student.py` — fetches voting status from Voxify on dashboard load
- **Modified:** `testpoint/Student/templates/student_dashboard.html` — shows voting banner (green if voted, yellow if not)

### Voxify (port 5001)
- **New file:** `Voxify/api.py` — Flask blueprint with 5 API endpoints
- **Modified:** `Voxify/__init__.py` — registers the API blueprint
- **Modified:** `Voxify/Admin/routes.py` — passes college_id to voters template
- **Modified:** `Voxify/Admin/templates/voters.html` — "Import from TestPoint" button + modal
- **Modified:** `app.py` — now runs on port 5001 with host='0.0.0.0'

### NewChange (port 5002)
- **New file:** `Main/api.py` — Flask blueprint with 5 API endpoints
- **Modified:** `Main/__init__.py` — registers the API blueprint
- **Modified:** `Main/admin/adminPY.py` — cross-checks TestPoint when adding a student
- **Modified:** `app.py` — now runs on port 5002 with host='0.0.0.0'

### Integration Hub (port 5003) — NEW
- `hub/app.py` — aggregates data from all 3 systems
- `hub/templates/hub.html` — live dashboard showing status, elections, cross-lookup

---

## API Endpoints exposed

### TestPoint (http://localhost:5000)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /api/ping | Health check |
| GET | /api/stats | Dashboard counts |
| GET | /api/students | All active students |
| GET | /api/students/<id> | Single student |
| GET | /api/students/<id>/exam-results | Exam scores |
| POST | /api/students/<id>/voting-status | Receive vote notification |

### Voxify (http://localhost:5001)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /api/ping | Health check |
| GET | /api/stats | Dashboard counts |
| GET | /api/elections | All elections with turnout |
| GET | /api/elections/<id>/results | Vote tallies per candidate |
| GET | /api/voters/status/<student_id> | Has student voted? |
| POST | /api/voters/import-from-testpoint | Pull students from TestPoint as voters |

### NewChange (http://localhost:5002)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /api/ping | Health check |
| GET | /api/stats | Dashboard counts |
| GET | /api/students/active | All active enrolled students |
| GET | /api/students/<id>/enrollment | Enrolled subjects |
| GET | /api/students/<id>/attendance | Attendance rates |
| POST | /api/students/enroll-verified | Enroll after TestPoint verification |

---

## How to run

### Windows
Double-click `START_ALL.bat`

### Manual (open 4 terminals)
```bash
# Terminal 1
cd testpoint_app && python app.py

# Terminal 2
cd voxify_app && python app.py

# Terminal 3
cd newchange_app && python app.py

# Terminal 4
cd hub && python app.py
```

Then open **http://localhost:5003** for the Integration Hub.

---

## Demo Day — Updating IPs
When on the same WiFi as the other groups:
1. Open **http://localhost:5003**
2. At the top, update the IP fields (e.g. `192.168.1.5:5000`)
3. Click **Apply & Refresh**
4. All panels update to use the real IPs

Also update in each system's code:
- TestPoint `testpoint/Student/student.py` → `VOXIFY_URL`
- NewChange `Main/admin/adminPY.py` → `TESTPOINT_URL`
- Voxify `Voxify/api.py` → `TESTPOINT_URL`

Or set environment variables:
```bash
set VOXIFY_URL=http://192.168.1.7:5001
set TESTPOINT_URL=http://192.168.1.5:5000
```
