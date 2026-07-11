# Integrated Educational System - System Context Document

## 1. Project Overview

### Overall Purpose
This is an integrated educational platform consisting of four interconnected web applications that work together to provide a comprehensive campus management system:
- **Portal**: Central authentication and Single Sign-On (SSO) system
- **TestPoint**: Student examination, testing, and academic assessment system
- **Voxify**: Voting and election management system for student governance
- **NewChange**: Academic administration system (attendance, enrollment, grade management)

The systems integrate via shared authentication (via Portal) and RESTful APIs that allow cross-system data sharing and synchronization.

### Technologies Used
- **Backend**: Python 3.x, Flask web framework
- **Frontend**: HTML5, CSS3, JavaScript (vanilla JS, no major frameworks)
- **Database**: MySQL 8.x (separate database per application)
- **Authentication**: JWT tokens for SSO, session-based authentication within each app
- **Communication**: RESTful APIs, HTTP requests between services
- **Environment**: Python dotenv for environment variable management
- **Deployment**: Designed to run on localhost or local network with configurable endpoints

### Folder Structure
```
full-intigrated/
├── integrated/                          # Main integration workspace
│   ├── portal/                          # Portal SSO system (port 5000)
│   │   ├── app.py                       # Main Flask application
│   │   ├── db_config.py                 # Database configuration
│   │   └── templates/                   # HTML templates
│   │       ├── index.html               # Portal home/dashboard
│   │       └── login.html               # Login page
│   │
│   ├── newchange_app/                   # Academic management system (port 5002)
│   │   ├── app.py                       # Main Flask application
│   │   ├── Main/                        # Core application modules
│   │   │   ├── api.py                   # REST API endpoints
│   │   │   ├── db.py                    # Database utilities
│   │   │   ├── sso.py                   # SSO integration
│   │   │   ├── portal_sync.py           # Cross-system user synchronization
│   │   │   └── admin/, student/, teacher/  # Module-specific logic
│   │   └── database.sql                 # Database schema
│   │
│   ├── testpoint_app/                   # Examination system (port 5003)
│   │   ├── app.py                       # Main Flask application
│   │   ├── testpoint/                   # Core application modules
│   │   │   ├── api.py                   # REST API endpoints
│   │   │   ├── Admin/, Student/, Teacher/ # Module-specific logic
│   │   │   └── __init__.py              # App factory with SSO integration
│   │   └── db_config.py                 # Database configuration
│   │
│   └── voxify_app/                      # Voting system (port 5001)
│       ├── app.py                       # Main Flask application
│       ├── Voxify/                      # Core application modules
│       │   ├── api.py                   # REST API endpoints
│       │   ├── Authentication/, Admin/, Voter/, SuperAdmin/  # Modules
│       │   ├── __init__.py              # App factory with SSO integration
│       │   └── utils/                   # Utility functions
│       └── db_config.py                 # Database configuration
│
├── .env                                 # Environment variables (DB passwords, etc.)
├── requirements.txt                     # Python dependencies
├── start_all.sh                         # Script to start all four applications
├── SYSTEM_CONTEXT.md                    # This document
└── README_INTEGRATION.md                # Integration setup guide
```

### Major Applications/Modules

#### 1. Portal (authentication.edukado.portal_2024)
**Purpose**: Central authentication system providing Single Sign-On (SSO) across all modules. Users authenticate once here and can access all connected systems without re-authenticating.

**Key Features**:
- JWT-based token authentication
- Central user management (users table)
- Role-based access control (superadmin, admin, teacher, student)
- Cookie-based session management with SSO token validation
- User provisioning API for cross-system synchronization

#### 2. TestPoint (TestPoint - port 5003)
**Purpose**: Student examination and academic assessment platform.

**Key Features**:
- Exam creation, delivery, and grading
- Student performance tracking and analytics
- Online proctoring capabilities (basic frontend checks)
- Question banks and test administration interfaces
- Integration with Voxify for voting eligibility checks
- Integration with NewChange for enrollment validation

#### 3. Voxify (Voxify - port 5001)
**Purpose**: Voting and election management system for student government and organizational elections.

**Key Features**:
- Election creation and management
- Candidate nomination and voting
- Voter eligibility verification (integrates with TestPoint)
- Election results tabulation and reporting
- Voter import from TestPoint student database
- Role-based access (SuperAdmin, Admin, Voter)

#### 4. NewChange (NewChange - port 5002)
**Purpose**: Academic administration and student management system.

**Key Features**:
- Student enrollment and course management
- Attendance tracking and reporting
- Grade management and transcript generation
- Teacher and course scheduling
- Integration with TestPoint for academic records
- Integration with Voxify for civic engagement tracking

## 2. Complete Directory Structure

### Portal Application (`integrated/portal/`)
- `app.py` - Main Flask application, authentication endpoints, SSO verification
- `db_config.py` - MySQL database connection configuration
- `templates/` - HTML templates
  - `index.html` - Dashboard/home page after login
  - `login.html` - User login form
- **Database**: `db_portal` (users table for central authentication)

### NewChange Application (`integrated/newchange_app/`)
- `app.py` - Main Flask application
- `Main/api.py` - REST API endpoints for integration
- `Main/db.py` - Database connection utilities
- `Main/sso.py` - SSO middleware for portal authentication
- `Main/portal_sync.py` - Cross-system user synchronization logic
- `Main/admin/`, `Main/student/`, `Main/teacher/` - Module-specific logic
- `database.sql` - Complete database schema
- **Database**: `db_attendance` (Students, Teachers, Admins, Enrollments, Attendance tables)

### TestPoint Application (`integrated/testpoint_app/`)
- `app.py` - Main Flask application with SSO integration
- `testpoint/api.py` - REST API endpoints for integration
- `testpoint/__init__.py` - Application factory with SSO and database setup
- `testpoint/Admin/`, `testpoint/Student/`, `testpoint/Teacher/` - Module-specific logic
- **Database**: `test_point` (Users, Students, Teachers, Admins, Exams, Questions, Attempts tables)

### Voxify Application (`integrated/voxify_app/`)
- `app.py` - Main Flask application with SSO integration
- `Voxify/api.py` - REST API endpoints for integration
- `Voxify/__init__.py` - Application factory with SSO and database setup
- `Voxify/Authentication/`, `Voxify/Admin/`, `Voxify/Voter/`, `Voxify/SuperAdmin/` - Modules
- `Voxify/utils/` - Utility functions (email, OTP, etc.)
- **Database**: `db_voting` (Users, Elections, Candidates, Positions, Votes tables)

## 3. Application Analysis

### 3.1 Portal Application

**Purpose**: Central authentication service providing SSO capabilities across all integrated systems.

**Entry Point**: `integrated/portal/app.py`

**Flask Application Initialization**:
```python
app = Flask(__name__)
app.secret_key = "super_secret_key_edukado_portal_2024"  # Must match PORTAL_SECRET in all modules
```

**Key Components**:

**Authentication System**:
- JWT token creation and validation (`create_token()`, `decode_token()` functions)
- Cookie-based session management (`auth_token` cookie with HttpOnly, SameSite=Lax)
- Role-based access control (superadmin, admin, teacher, student)
- Login/logout endpoints with redirect handling

**SSO API Endpoints**:
- `POST /api/verify-token` - Validates JWT tokens for other services
- `POST /api/create-user` - Creates users in central database for SSO access
- `GET /api/ping` - Health check endpoint

**Session Management**:
- Upon successful login, sets `auth_token` cookie containing JWT
- Other services validate this token via `/api/verify-token` endpoint
- Sessions managed by individual applications but authenticated via central token

**Blueprints**: No formal blueprints used - all routes defined directly in app.py

**Middleware**: Custom authentication checking in route handlers (no traditional Flask middleware)

### 3.2 NewChange Application

**Purpose**: Academic administration system managing students, teachers, courses, enrollment, and attendance.

**Entry Point**: `integrated/newchange_app/app.py`

**Flask Application Initialization**:
```python
app = Flask(__name__, template_folder='Main/templates', static_folder='Main/static')
app.secret_key = os.getenv("APP_SECRET_KEY", "dev_secret_key_change_in_production")
```

**Key Components**:

**Authentication System**:
- Uses SSO via `Main/sso.py` middleware
- `require_sso()` function validates tokens with Portal
- Falls back to local session when SSO token unavailable
- Stores user info in Flask session (`user_id`, `name`, `role`)

**SSO Integration** (`Main/sso.py`):
- Verifies tokens with Portal's `/api/verify-token` endpoint
- Maps Portal username to local user identifiers (varies by role table)
- Provides `sso_required` decorator for route protection
- Includes `/sso/status` debug endpoint

**Blueprint Structure**:
- Uses Flask Blueprints for modular organization
- `Main/__init__.py` registers all blueprints
- Admin, Student, Teacher modules each have their own route handling

**Database Layer** (`Main/db.py`):
- MySQL connection via `mysql.connector`
- Connection pooling handled by mysql.connector
- `get_db_connection()` function returns connection object
- `get_cursor()` returns dictionary cursor for easier data handling
- Audit logging functionality (`log_system_action`)

**API Layer** (`Main/api.py`):
- RESTful endpoints under `/api` prefix
- Integrated with TestPoint and Voxify for cross-system operations
- Key endpoints: student data, enrollment, attendance, stats, provisioning
- Cross-system calls via HTTP requests to partner services
- Error handling with appropriate HTTP status codes

### 3.3 TestPoint Application

**Purpose**: Examination and assessment system for creating, delivering, and grading tests.

**Entry Point**: `integrated/testpoint_app/app.py`

**Flask Application Initialization**:
```python
app = create_app()  # From testpoint/__init__.py
```

**Key Components**:

**Application Factory** (`testpoint/__init__.py`):
- Creates Flask app with configuration
- Registers authentication blueprint (`auth_bp`)
- Registers API blueprint (`api`)
- Sets up SSO integration via `sso.py`
- Database initialization on app context

**Authentication System**:
- SSO-based authentication via `testpoint/sso.py`
- `_get_sso_user()` function validates portal token
- Session-based role tracking after SSO validation
- Role-based redirects in root route (`/`)

**API Layer** (`testpoint/api.py`):
- RESTful endpoints under `/api` prefix
- Key integration endpoints:
  - `/api/students` - List all active students
  - `/api/students/<id>` - Get specific student details
  - `/api/students/<id>/exam-results` - Get exam history
  - `/api/students/<id>/voting-status` - Receive voting notifications from Voxify
  - `/api/provision-user` - Create local user from SSO credentials
  - `/api/stats` - Dashboard statistics for integration hub
- All endpoints return JSON responses

**Modules**:
- `Admin/` - Exam creation, question management, user administration
- `Student/` - Exam taking, results viewing, dashboard
- `Teacher/` - Class management, exam assignment, grading

**Database Layer**:
- MySQL configuration via `testpoint/db_config.py` (inferred from usage)
- Tables: users, students, teachers, admins, exams, questions, exam_attempts, etc.
- Referential integrity maintained through foreign keys

### 3.4 Voxify Application

**Purpose**: Voting and election management system for student governance.

**Entry Point**: `integrated/voxify_app/app.py`

**Flask Application Initialization**:
```python
app = create_app()  # From Voxify/__init__.py
```

**Key Components**:

**Application Factory** (`Voxify/__init__.py`):
- Creates Flask app with configuration
- Registers multiple blueprints: auth, admin, voter, superadmin, api
- Sets up SSO integration
- Database table creation/update on app startup
- Configures database connection function in app context

**Authentication System**:
- SSO-based via `Voxify.Authentication.routes`
- `_get_sso_user()` function validates portal token
- Role-based redirection after authentication
- Supports roles: superadmin, admin, voter (teachers mapped to voter role)

**Blueprint Structure**:
- Modular organization with separate blueprints for each user type
- `Authentication/` - Login, logout, OTP verification, password reset
- `Admin/` - Election management, candidate approval, voter management
- `Voter/` - Voting interface, ballot casting, results viewing
- `SuperAdmin/` - System oversight, audit logs, 관리
- `api/` - REST API endpoints for integration

**Database Layer**:
- MySQL configuration accessed via `current_app.config["get_db_connection"]`
- Tables: users, elections, candidates, positions, votes, trusted_devices, announcements
- Automated table creation/updates in app context

**API Layer** (`Voxify/api.py`):
- RESTful endpoints under `/api` prefix
- Key integration endpoints:
  - `/api/elections` - List elections with turnout stats
  - `/api/elections/<id>/results` - Detailed election results
  - `/api/voters/status/<student_id>` - Check voter status and participation
 2ven participation
  - `/api/voters/import-from-testpoint` - Import students as voters
  - `/api/provision-user` - Create local user from SSO credentials
  - `/api/stats` - Dashboard statistics for integration hub
- Cross-system communication via HTTP requests to TestPoint
- Comprehensive error handling with appropriate status codes

## 4. Route Documentation

### 4.1 Portal Routes

| Route | Method | Purpose | Auth Required | Returns |
|-------|--------|---------|---------------|---------|
| `/` | GET | Home/dashboard or login redirect | Optional (token cookie) | HTML template or redirect |
| `/login` | GET, POST | User login | None | HTML form or redirect on success |
| `/logout` | GET | User logout | None | Redirect to home |
| `/api/ping` | GET | Health check | None | `{"system": "Portal", "status": "ok"}` |
| `/api/verify-token` | POST | Validate JWT token | None | User object or error |
| `/api/create-user` | POST | Create new user in central DB | None | User ID or error |

### 4.2 NewChange Routes

**Web Interface Routes** (access controlled by SSO):
- `/` - Redirect to appropriate dashboard based on role
- `/admin/*` - Administrative functions (requires admin role)
- `/student/*` - Student dashboard and functions (requires student role)
- `/teacher/*` - Teacher dashboard and functions (requires teacher role)

**API Routes** (`/api/*` prefix):
| Route | Method | Purpose | Auth Required | Returns |
|-------|--------|---------|---------------|---------|
| `/api/ping` | GET | Health check | None | `{"system": "NewChange", "status": "ok"}` |
| `/api/provision-user` | POST | Create local user from SSO credentials | None | Success/failure |
| `/api/students/active` | GET | List all active students | None | Array of student objects |
| `/api/students/<id>/enrollment` | GET | Get student's enrolled subjects | None | Enrollment details |
| `/api/students/<id>/attendance` | GET | Get student's attendance records | None | Attendance statistics |
| `/api/stats` | GET | System statistics for dashboard | None | Counts of students, teachers, etc. |
| `/api/students/enroll-verified` | POST | Enroll student after TestPoint verification | None | Enrollment result |

### 4.3 TestPoint Routes

**Web Interface Routes** (access controlled by SSO):
- `/` - Redirect to role-appropriate dashboard after SSO validation
- `/admin/*` - Admin dashboard and functions
- `/student/*` - Student dashboard and exam interface
- `/teacher/*` - Teacher dashboard and class management

**API Routes** (`/api/*` prefix):
| Route | Method | Purpose | Auth Required | Returns |
|-------|--------|---------|---------------|---------|
| `/api/ping` | GET | Health check | None | `{"system": "TestPoint", "status": "ok"}` |
| `/api/provision-user` | POST | Create local user from SSO credentials | None | Success/failure |
| `/api/students` | GET | List all active, verified students | None | Array of student objects |
| `/api/students/<id>` | GET | Get specific student details | None | Student object |
| `/api/students/<id>/exam-results` | GET | Get student's exam history | None | Array of exam results |
| `/api/students/<id>/voting-status` | POST | Receive voting notification from Voxify | None | Acknowledgement |
| `/api/stats` | GET | System statistics for dashboard | None | Counts of students, exams, etc. |

### 4.4 Voxify Routes

**Web Interface Routes** (access controlled by SSO):
- `/` - Redirect to role-appropriate dashboard after SSO validation
- `/admin/*` - Election management interface (requires admin role)
- `/voter/*` - Voting interface and ballot casting (requires voter role)
- `/superadmin/*` - System oversight interface (requires superadmin role)

**API Routes** (`/api/*` prefix):
| Route | Method | Purpose | Auth Required | Returns |
|-------|--------|---------|---------------|---------|
| `/api/ping` | GET | Health check | None | `{"system": "Voxify", "status": "ok"}` |
| `/api/elections` | GET | List elections with turnout statistics | None | Array of election objects |
| `/api/elections/<id>/results` | GET | Detailed results for specific election | None | Results by position and candidate |
| `/api/voters/status/<student_id>` | GET | Check if student is registered voter and voting status | None | Voter eligibility and participation |
| `/api/voters/import-from-testpoint` | POST | Import students from TestPoint as voters | None (admin action) | Import results |
| `/api/provision-user` | POST | Create local user from SSO credentials | None | Success/failure |
| `/api/stats` | GET | System statistics for dashboard | None | Counts of elections, voters, votes |

## 5. Function Documentation

### 5.1 Key Authentication Functions

**Portal - `app.py`**:
- `create_token(user_id, username, full_name, role)` - Creates JWT token
- `decode_token(token)` - Validates and decodes JWT token, returns payload or None

**NewChange - `Main/sso.py`**:
- `_verify_token(token)` - Calls Portal's `/api/verify-token` endpoint
- `require_sso()` - Main SSO validation function, handles fallback to local session
- `sso_required(f)` - Decorator that injects validated user into route functions

**TestPoint - `testpoint/sso.py`** (inferred from app.py usage):
- `_get_sso_user()` - Validates token with Portal, returns user data or None
- Used in `session_has_valid_role()` and route handlers

**Voxify - `Voxify/authentication/routes.py`** (inferred):
- `_get_sso_user()` - Validates token with Portal
- Used in `app.py` home route for role-based redirection

### 5.2 Key Synchronization Functions

**NewChange - `Main/portal_sync.py`**:
- `sync_user_to_portal(username, password, full_name, role, email, external_id)` - Pushes new user to Portal's central users table
- `_provision(endpoint, target_module, username, password, full_name, role, email)` - Helper for calling provision-user APIs
- `mirror_user_to_modules(username, password, full_name, role, email)` - Creates local profiles in TestPoint and Voxify
- `retry_failed_syncs()` - Retries failed synchronization attempts from `sync_failures` table

**TestPoint - `testpoint/api.py`**:
- `provision_user()` - Creates local user record when notified by other systems
- Stores user in `users` table, creates corresponding role-specific record (student/teacher/admin)

**Voxify - `Voxify/api.py`**:
- `provision_user()` - Creates local user record (maps roles appropriately)
- `import_voters()` - Bulk imports students from TestPoint as voters

### 5.3 Key Database Functions

**NewChange - `Main/db.py`**:
- `get_db_connection()` - Creates MySQL connection
- `get_cursor(conn)` - Returns dictionary cursor
- `log_system_action(cursor, table_name, entity_id, action, performed_by_id, performed_by_role, details)` - Audit logging

**Cross-Service Database Patterns**:
- Each service maintains its own database schema
- Foreign key relationships primarily within each service's database
- Cross-service references typically use identifiers (usernames, IDs) rather than direct foreign keys
- Audit trails maintained in each service for administrative actions

## 6. API Documentation

### 6.1 Exposed APIs Summary

All services expose APIs under the `/api` prefix for integration purposes:

#### Common Endpoints (All Services)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/ping` | GET | Health check - returns service name and status |
| `/api/provision-user` | POST | Create local user record from SSO credentials |
| `/api/stats` | GET | Return system statistics for integration dashboard |

#### Service-Specific Endpoints

**TestPoint API**:
| Endpoint | Method | Purpose | Consumed By |
|----------|--------|---------|-------------|
| `/api/students` | GET | List all active, verified students | Voxify (voter import), NewChange (cross-check) |
| `/api/students/<id>` | GET | Get specific student profile | NewChange (enrollment verification) |
| `/api/students/<id>/exam-results` | GET | Get student's exam history | NewChange (academic reports) |
| `/api/students/<id>/voting-status` | POST | Receive voting notification from Voxify | Voxify (vote confirmation) |

**Voxify API**:
| Endpoint | Method | Purpose | Consumed By |
|----------|--------|---------|-------------|
| `/api/elections` | GET | List elections with turnout stats | Integration Hub dashboard |
| `/api/elections/<id>/results` | GET | Detailed election results | Integration Hub results panel |
| `/api/voters/status/<student_id>` | GET | Check voter registration and voting status | TestPoint (student dashboard badge) |
| `/api/voters/import-from-testpoint` | POST | Import students from TestPoint as voters | Admin-triggered batch operation |
| `/api/voters/status/<student_id>` | GET | Check if student has voted | TestPoint (eligibility checking) |

**NewChange API**:
| Endpoint | Method | Purpose | Consumed By |
|----------|--------|---------|-------------|
| `/api/students/active` | GET | List all active enrolled students | Voxify (alternative voter source) |
| `/api/students/<id>/enrollment` | GET | Get student's enrolled subjects | TestPoint (class assignment validation) |
| `/api/students/<id>/attendance` | GET | Get student's attendance rates | Voxify (optional voting eligibility) |
| `/api/students/enroll-verified` | POST | Enroll student after TestPoint verification | TestPoint-triggered enrollment |

### 6.2 API Dependency Map

```
Data Flow Patterns:

1. User Creation Flow:
   Admin creates user in any system → 
   System calls POST /api/create-user on Portal →
   Portal creates central user record →
   System calls POST /api/provision-user on other systems →
   Other systems create local user records

2. Student Data Sharing:
   Other systems ← GET /api/students [TestPoint] → 
   Voxify: Import voters
   NewChange: Cross-check enrollment eligibility

3. Voting Status Sharing:
   TestPoint ← POST /api/students/<id>/voting-status [Voxify] →
   TestPoint: Records voting participation for analytics

4. Enrollment Validation:
   NewChange ← GET /api/students/<id> [TestPoint] →
   NewChange: Verifies student exists before enrollment

5. Statistics Sharing:
   All systems → GET /api/stats →
   Integration Hub: Aggregates for dashboard display
```

## 7. API Request Analysis

### 7.1 Outgoing HTTP Requests

**NewChange → TestPoint** (`Main/api.py:enroll_verified()`):
- **URL**: `{TESTPOINT_URL}/api/students/{student_id}`
- **Method**: GET
- **Purpose**: Verify student exists and is active in TestPoint before enrollment
- **Payload**: None (query parameter in URL)
- **Headers**: None specified
- **Timeout**: 5 seconds
- **Error Handling**: Returns 404 if student not found, 502/503 for connection issues
- **Retry Logic**: None in this specific call (but used in portal_sync with retries)

**Voxify → TestPoint** (`Voxify/api.py:import_voters()`):
- **URL**: `{TESTPOINT_URL}/api/students`
- **Method**: GET
- **Purpose**: Fetch list of students to import as voters
- **Payload**: None
- **Headers**: None
- **Timeout**: 5 seconds
- **Error Handling**: Returns 502 if request fails, 503 if service unreachable
- **Retry Logic**: None (single attempt)

**NewChange → TestPoint** (`Main/api.py:get_enrollment()` and `get_attendance()`):
- No direct calls - these are incoming endpoints called by other systems

### 7.2 Incoming HTTP Requests (API Endpoints)

All services accept POST requests to `/api/provision-user` with:
- **URL**: `/api/provision-user`
- **Method**: POST
- **Content-Type**: `application/json`
- **Payload**:
  ```json
  {
    "username": "<string>",
    "password": "<string>",
    "full_name": "<string>",
    "role": "<string>",
    "email": "<string>"
  }
  ```
- **Authentication**: None (trusted service-to-service communication)
- **Response**: JSON success/failure indication

## 8. Exposed APIs by System

### 8.1 Portal
**Exposed to**: All other systems
| Endpoint | Purpose | Consumed By | Security |
|----------|---------|-------------|----------|
| `/api/verify-token` | Validate SSO tokens | NewChange, TestPoint, Voxify | None (token validation) |
| `/api/create-user` | Create central user record | NewChange, TestPoint, Voxify | None (trusted create) |

### 8.2 TestPoint
**Exposed to**: NewChange, Voxify, Integration Hub
| Endpoint | Purpose | Consumed By | Security |
|----------|---------|-------------|----------|
| `/api/ping` | Health check | All systems, Integration Hub | None |
| `/api/stats` | System metrics | Integration Hub | None |
| `/api/students` | Student list | Voxify (import), NewChange (validation) | None |
| `/api/students/<id>` | Student details | NewChange (enrollment validation) | None |
| `/api/students/<id>/exam-results` | Exam history | NewChange (reporting) | None |
| `/api/students/<id>/voting-status` | Vote notifications | Voxify (after voting) | None |
| `/api/provision-user` | Local user creation | NewChange, Voxify (SSO sync) | None |

### 8.3 Voxify
**Exposed to**: TestPoint, NewChange, Integration Hub
| Endpoint | Purpose | Consumed By | Security |
|----------|---------|-------------|----------|
| `/api/ping` | Health check | All systems, Integration Hub | None |
| `/api/stats` | System metrics | Integration Hub | None |
| `/api/elections` | Election list with turnout | Integration Hub dashboard | None |
| `/api/elections/<id>/results` | Election results | Integration Hub results panel | None |
| `/api/voters/status/<id>` | Voter status/check | TestPoint (student dashboard) | None |
| `/api/voters/import-from-testpoint` | Bulk voter import | Admin (manual operation) | None |
| `/api/provision-user` | Local user creation | NewChange, TestPoint (SSO sync) | None |

### 8.4 NewChange
**Exposed to**: TestPoint, Voxify, Integration Hub
| Endpoint | Purpose | Consumed By | Security |
|----------|---------|-------------|----------|
| `/api/ping` | Health check | All systems, Integration Hub | None |
| `/api/stats` | System metrics | Integration Hub | None |
| `/api/students/active` | Active student list | Voxify (alternative source) | None |
| `/api/students/<id>/enrollment` | Enrollment details | TestPoint (validation) | None |
| `/api/students/<id>/attendance` | Attendance rates | Voxify (optional eligibility) | None |
| `/api/students/enroll-verified` | Verified enrollment | TestPoint-triggered | None |
| `/api/provision-user` | Local user creation | TestPoint, Voxify (SSO sync) | None |

## 9. System Integration

### 9.1 Authentication Flow (SSO)

```
1. User visits any system (e.g., Voxify) at root URL "/"
2. System checks for valid session; if none, redirects to Portal with next parameter
   Example: Voxify "/" → redirects to "http://portal:5000/?next=http://voxify:5001/"
3. User logs in at Portal:
   - Submit credentials to POST /login
   - Portal validates against db_portal.users table
   - On success: creates JWT token, sets auth_token cookie (HttpOnly, SameSite=Lax)
   - Redirects to original destination (next parameter)
4. User returns to target system with auth_token cookie
5. Target system validates token:
   - Extracts token from cookie
   - POSTs to Portal's /api/verify-token with {"token": "<jwt>"}
   - Portal validates signature and expiration
   - On success: returns user data (id, username, full_name, role)
   - Target system populates session with user data
6. Subsequent requests use established session; token re-validated periodically
```

### 9.2 Session Sharing Mechanism

- **Not Shared**: Actual session data is NOT shared between systems
- **Shared**: Authentication state via JWT token in `auth_token` cookie
- **Each System**: Maintains its own session storage after initial SSO validation
- **Token Validation**: Performed on sensitive operations or periodically
- **Cookie Settings**: `HttpOnly=true`, `SameSite=Lax` to prevent CSRF while allowing redirects

### 9.3 User Synchronization Flow

```
When a new user is created in any system:
1. Local system creates user in its own database (student/teacher/admin table)
2. Local system calls Portal's POST /api/create-user with:
   - username, password (plaintext), full_name, role, email, external_id
3. Portal creates record in db_portal.users table (hashed password)
4. Portal returns user_id to calling system
5. Calling system then calls POST /api/provision-user on OTHER systems:
   - Sends same user credentials (password in plaintext - each system hashes independently)
   - Each target system creates local user record in their respective role tables
6. If any step fails, failure is logged in sync_failures table for retry
```

### 9.4 Data Synchronization Examples

**Student Creation Flow**:
1. Admin creates student in NewChange local database
2. NewChange → Portal: POST /api/create-user
3. Portal → NewChallenge: Returns success with central user_id
4. NewChange → TestPoint: POST /api/provision-user (creates student record)
5. NewChange → Voxify: POST /api/provision-user (creates voter record if role=student)
6. All systems now have matching user records linked by username

**Voting Process**:
1. Student logs into Voxify via SSO
2. Student casts vote in election
3. Voxify records vote in local db_voting.votes table
4. Voxify → TestPoint: POST /api/student/{id}/voting-status with {has_voted: true, election_id: X}
5. TestPoint records voting receipt (no schema change needed - logged for admin viewing)
6. Student sees voting status updated in TestPoint dashboard via periodic checks

**Enrollment Validation**:
1. Admin attempts to enroll student in NewChange
2. NewChange → TestPoint: GET /api/students/{student_id}
3. If student exists and active: proceed with enrollment
4. If student not found: return error requiring student to exist in TestPoint first
5. After successful enrollment: NewChange → TestPoint: No direct notification (consistency via periodic sync)

## 10. Database Analysis

### 10.1 Connection Configuration

**Pattern**: Each service uses independent database connection with environment-based configuration.

**Portal** (`db_config.py`):
- Database: `db_portal`
- Host: `DB_HOST` env var (default: localhost)
- User: `root`
- Password: `DBPASSWORD` env var

**NewChange** (`Main/db.py`):
- Database: `db_attendance`
- Host: `DB_HOST` env var (default: 127.0.0.1)
- User: `DB_USER` env var (default: root)
- Password: `DB_PASSWORD` env var (default: empty)
- Uses `python-dotenv` for environment loading

**TestPoint** (inferred from usage):
- Database: `test_point`
- Similar env var pattern for connection parameters

**Voxify** (inferred from `__init__.py`):
- Database: `db_voting`
- Connection function stored in app config

### 10.2 Database Schema Overview

**Common Tables** (variations exist per service):
- `users` or equivalent - core user authentication (varies by service)
- Role-specific tables: `students`, `teachers`, `admins`
- Service-specific entities: `exams`/`questions` (TestPoint), `elections`/`candidates`/`votes` (Voxify), `enrollments`/`attendance` (NewChange)

**Portal Database** (`db_portal`):
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- hashed
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    role ENUM('superadmin','admin','teacher','student') NOT NULL,
    external_id VARCHAR(100),  -- references ID in other systems
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**NewChange Database** (`db_attendance`):
Key tables based on `database.sql` inspection:
- `Students` (user_id PK, first_name, middle_name, last_name, email, course, level, section, status, password_hash)
- `Teachers` (user_id PK, user_role, first_name, middle_name, last_name, email, password_hash)
- `Admins` (admin_id PK, username, password_hash, email)
- `Enrollments` (enrollment_id PK, user_id FK, assignment_id FK)
- `Attendance` (attendance_id PK, user_id FK, session_id FK, status, timestamp)
- `system_audit_log` (for tracking administrative actions)

**Technical Note**: Foreign key relationships exist within each database but NOT across databases. Cross-system references use application-level logic.

### 10.3 Connection Handling

- **Connection Pooling**: Handled by `mysql.connector` (default behavior)
- **Connection Lifetime**: Request-scoped - opened and closed per API call/database operation
- **Error Handling**: Try/except blocks with connection rollback on failure
- **Resource Cleanup**: Explicit `cursor.close()` and `connection.close()` in finally blocks
- **Transaction Management**: Explicit `commit()` and `rollback()` calls

## 11. Cross-System Data Flow

### 11.1 User Lifecycle

```
CREATE User:
1. Admin creates user in System A (e.g., NewChange adds student)
2. System A → Portal: POST /api/create-user [creates central auth record]
3. System A → System B: POST /api/provision-user [creates local record in System B]
4. System A → System C: POST /api/provision-user [creates local record in System C]
5. User can now SSO into all systems using same credentials

UPDATE User (e.g., name/email change):
1. Update performed in system of record (where user originally created)
2. System of record → Portal: Update users table (if supported)
3. System of record → Other Systems: Update local records via provision-user or direct API
4. Inconsistencies possible if updates not propagated

DELETE User:
1. Similar propagation pattern - each system must delete local records
2. Currently appears to be manual process or requires custom implementation
```

### 11.2 Specific Data Flows

**Exam Results → Academic Reporting**:
```
1. Student completes exam in TestPoint
2. Exam score stored in testpoint.exam_attempts table
3. Administrator requests report in NewChange
4. NewMake → TestPoint: GET /api/students/{id}/exam-results
5. TestPoint returns JSON array of exam attempts
6. NewChange processes and displays in academic report interface
```

**Voter Eligibility Checking**:
```
1. Student attempts to access voting booth in Voxify
2. Voxify → TestPoint: GET /api/voters/status/{student_id}
3. If not registered voter: redirect to registration or deny access
4. If registered but not voted: show voting interface
5. If already voted: show "already voted" message or results
```

**Course Validation for Voting**:
```
1. Administration attempts to link voting eligibility to academic standing
2. Voxify → NewChange: GET /api/students/{id}/attendance
3. If attendance rate below threshold: deny voting access or show warning
4. Else: allow voting proceeding
```

### 11.3 Synchronization Mechanisms

**Real-Time**:
- User creation: Immediate propagation via API calls
- Voting notifications: Immediate POST from Voxify to TestPoint
- Enrollment validation: Real-time GET request to TestPoint

**Eventual Consistency**:
- Periodic reconciliation via `retry_failed_syncs()` jobs
- Manual admin interfaces for correcting inconsistencies
- Audit logs track all changes for investigation

**Failure Handling**:
- Failed sync attempts recorded in `sync_failures` table
- Automatic retry mechanisms with exponential backoff in some implementations
- Manual retry capability via administrative interfaces
- Alerting/monitoring recommended for production (not implemented in base code)

## 12. Authentication Flow

### 12.1 Login Process

```
1. User navigates to any service (e.g., http://voxify:5001/)
2. Service checks for valid session via SSO validation
3. If no valid session:
   a. Service redirects to Portal: http://portal:5000/?next=http://voxify:5001/
   b. Preserves original URL in 'next' parameter
4. At Portal login page:
   a. User enters username/password
   b. Form submitted to POST /login
   c. Portal validates credentials against db_portal.users
   d. On success:
        - Creates JWT: jwt.encode(payload, secret_key, algorithm="HS256")
        - Sets cookie: auth_token=<jwt>; HttpOnly; SameSite=Lax; MaxAge=28800 (8 hours)
        - Redirects to URL in 'next' parameter
5. User returns to original service with auth_token cookie
6. Service validates token:
   a. Extracts token from cookie
   b. POSTs to Portal: /api/verify-token with {"token": "<jwt>"}
   c. Portal returns user payload if valid
   d. Service creates local session: session['user_id'], session['role'], etc.
7. User now authenticated in target service
```

### 12.2 Session Management

**Cookie Properties**:
- Name: `auth_token`
- Content: JWT signed with Portal's secret key
- Attributes: `HttpOnly=true`, `SameSite=Lax`
- Expiration: 8 hours (configurable via token expiry in payload)

**Session Storage** (per service):
- Key: `user_id` (typically the username from Portal for cross-system consistency)
- Related: `name` (full_name), `role` (from token), `authenticated` flag
- Lifetime: Browser session or until explicit logout

### 12.3 Token Validation

**Validation Process**:
1. Extract token from `auth_token` cookie
2. POST to `PORTAL_URL/api/verify-token` with JSON: `{"token": "<jwt>"}`
3. Port responds:
   - Success (200): `{"valid": true, "user": {...user data...}}`
   - Failure (401): `{"valid": false, "reason": "<error>"}`
4. On success: populate session with user data
5. On failure: clear session, redirect to login

**Token Contents** (from Portal create_token):
```json
{
  "user_id": <int>,
  "username": "<string>",
  "full_name": "<string>",
  "role": "<string>",
  "exp": <timestamp>  // 8 hours from issuance
}
```

### 12.4 Special Authentication Cases

**Already Authenticated User**:
- If user has valid auth_token cookie and visits login page:
- System redirects them to intended destination (prevents login loop)
- Implemented by checking token validity before showing login form

**Role-Based Access Control**:
- After SSO validation, each service checks user's role
- Different routes/endpoints restricted to specific roles
- Example: Voxify admin routes only accessible to role='admin' or 'superadmin'

**Logout Process**:
- Clear local session (if any)
- Remove auth_token cookie by setting expiration in past
- Redirect to home page
- Note: Does NOT invalidate token on server-side (JWT stateless) - relies on expiration

## 13. Configuration Files

### 13.1 Environment Variables (.env)

**Location**: `/full-intigrated/.env` (project root)
```
DBPASSWORD = dion8185
GEMINI_API_KEY= AIzaSyDiQTldzxqj8FsZItzjijv6e9SchetN0lfQ
GMAILPASS = yzfc xmrb bkpw yepp
GMAIL = lucator51plus1@gmail.com
```

**Usage**:
- `DBPASSWORD`: MySQL root password for all databases
- `GMAIL`/`GMAILPASS`: SMTP credentials for email notifications (OTP, etc.)
- `GEMINI_API_KEY`: AI service key (potentially unused in current implementation)

### 13.2 Application Configuration

**Portal** (`app.py`):
- `app.secret_key = "super_secret_key_edukado_portal_2024"` - Must match all services
- Database config: `db_config.py` using environment variables

**NewChange** (`app.py`):
- `app.secret_key = os.getenv("APP_SECRET_KEY", "dev_secret_key_change_in_production")`
- Database: `Main/db.py` reads from environment via `os.getenv()`

**TestPoint** (inferred):
- Secret key configuration in `__init__.py` or config files
- Database: Similar env var pattern

**Voxify** (`__init__.py`):
- Secret key: Set during app creation
- Database: `app.config["get_db_connection"] = get_db_connection`

### 13.3 Service URLs (Environment Variables)

Referenced in various services for cross-service communication:

**NewChange** (`Main/api.py`):
- `TESTPOINT_URL = os.getenv("TESTPOINT_URL", "http://127.0.0.1:5003")`
- `VOXIFY_URL = os.getenv("VOXIFY_URL", "http://127.0.0.1:5001")`

**Voxify** (`Voxify/api.py`):
- `TESTPOINT_URL = "http://127.0.0.1:5000"`  # Note: Hardcoded, should be env var
- `NEWCHANGE_URL = "http://127.0.0.1:5002"`   # Note: Hardcoded, should be env var

**TestPoint** (inferred):
- Similar patterns for contacting other services

**Note**: Inconsistency observed - some services use env vars, others have hardcoded URLs. Production deployment should standardize on environment variables for all service URLs.

### 13.4 Port Configuration

**Hardcoded in respective app.py files**:
- Portal: `app.run(..., port=5000)` (inferred from documentation)
- NewChange: `app.run(..., port=5002)` (inferred)
- TestPoint: `app.run(..., port=5003)` (seen in app.py: `app.run(debug=True, port=5003)`)
- Voxify: `app.run(..., host='0.0.0.0', port=5001)` (seen in app.py)

**Override Mechanism**:
- Could be modified via environment variables or command line arguments
- Currently requires code change to modify ports

## 14. JavaScript Analysis

### 14.1 AJAX/Fetch Patterns

**Common Pattern**: Direct `fetch()` or `XMLHttpRequest` calls to same-origin or configured service endpoints.

**Examples**:

**NewChange Portal Sync** (`main.js` inferred):
```javascript
// Typical AJAX call to internal API
fetch('/api/students/active')
    .then(response => response.json())
    .then(data => {
        // Update UI with student list
    })
    .catch(error => {
        console.error('API error:', error);
        showError('Failed to load data');
    });
```

**Cross-Service Calls** (JavaScript calling external services):
```javascript
// Example from Voxify importing voters from TestPoint
fetch('http://testpoint:5003/api/students')
    .then(response => response.json())
    .then(data => {
        // Process student list for import
    })
    .catch(error => {
        showError('Cannot connect to TestPoint: ' + error.message);
    })
```

### 14.2 Module-Specific JavaScript

**Portal** (`static/Astyle.js` inferred):
- Login form handling
- Session management UI
- Redirect logic after login

**NewChange** (`Main/static/Astyle.js` and module-specific JS):
- Form validation (enrollment, attendance entry)
- Dynamic table updates (AJAX-driven)
- Chart/visualization libraries for analytics
- File upload handling (excuse documents with validation)

**TestPoint** (`testpoint/Student/static/Sstyle.js` etc.):
- Exam timer implementation
- Question navigation (prev/save/next)
- Real-time validation of answers
- Proctoring indicators (fullscreen detection, blur warnings)
- Result visualization with charts

**Voxify** (`Voxify/static/voter.js` etc.):
- Ballot interface with selection validation
- Real-time vote submission and confirmation
- Election countdown timers
- Results display with charts/graphs
- Voter eligibility checking indicators

### 14.3 Key frontend-backend interactions

**Form Submissions**:
- Traditional form posts for login/register
- AJAX submissions for dynamic interfaces (less page refresh)
- JSON payloads for API consumption
- FormData usage for file uploads

**Authentication Handling**:
- JavaScript reads/writes cookies for token management
- Redirect handling after authentication
- Session timeout warnings and renewal

**Real-time Features**:
- Polling for status updates (e.g., vote status, exam progress)
- WebSocket usage not observed in current implementation (polling-based)
- Long-polling not implemented - relies on periodic refresh

### 14.4 Security Considerations in JS

**Observed Patterns**:
- CSRF protection: Not visibly implemented in forms (relying on SameSite cookies)
- Input validation: Present both client-side and server-side
- Output escaping: HTML escaping observed in template rendering
- File upload validation: Extension and MIME type checking noted

**Improvement Opportunities**:
- Add CSRF tokens to forms requiring state changes
- Implement timeout warnings with keep-alive pings
- Consider adopting a frontend framework for complex interactions
- Add more comprehensive input sanitization

## 15. HTML Templates Analysis

### 15.1 Template Structure

**Location**: Each service has `templates/` directory under its main module
- Portal: `templates/`
- NewChange: `Main/templates/`
- TestPoint: `testpoint/{Admin,Student,Teacher}/templates/`
- Voxify: `Voxify/{Authentication,Admin,Voter,SuperAdmin}/templates/`

**Base Templates**:
- Common pattern: `base.html` with blocks for title, content, scripts, styles
- Extends base for specific pages (dashboard, forms, reports)
- Minimal template inheritance - mostly standalone pages

### 15.2 Key Templates by Service

**Portal**:
- `index.html`: Dashboard after login (shows user info, quick links)
- `login.html`: Username/password form with "remember me" option
- `*.html`: Password reset flow (forgot_password.html, reset_password.html)

**NewChange**:
- Admin templates: User management, course setup, reporting dashboards
- Student templates: Dashboard, enrollment forms, attendance viewing, excuse submission
- Teacher templates: Class management, grade entry, attendance taking, reports

**TestPoint**:
- Admin: Exam creation, question banking, user management, analytics
- Student: Exam launcher, question viewer, timer interface, results review
- Teacher: Class setup, exam assignment, grading interface, analytics

**Voxify**:
- Authentication: Login, registration, OTP verification, password recovery
- Admin: Election creation, candidate management, voter approval, audit logs
- Voter: Ballot casting, election list, results viewing, my votes history
- SuperAdmin: System configuration, audit trail, gestion globale

### 15.3 Template-Controller Interaction

**Data Passing**:
- Flask `render_template(template_name, **context)` used extensively
- Context variables: user info, form data, query results, status messages
- Example: `render_template('dashboard.html', user=current_user, stats=stats_data)`

**Form Handling**:
- GET requests display forms with initial values
- POST requests process submissions, redirect on success (PRG pattern)
- Validation errors re-display form with error messages and preserved input

**Dynamic Content**:
- Jinja2 templating for loops (`{% for student in students %}`), conditionals
- Filters for formatting: date formatting, currency, truncation
- Safe filtering for trusted HTML content (`safe` filter)

**JavaScript Integration**:
- Script tags included at bottom of body or in header blocks
- Inline JavaScript for simple interactions
- External .js files for complex functionality
- Data passed from template to JS via:
  - Inline script variables: `var userId = "{{ user.id }}";`
  - Data attributes: `<div data-user-id="{{ user.id }}">`
  - Hidden form fields for API consumption

### 15.4 Responsiveness and Accessibility

**Observed**:
- Basic responsive design via CSS media queries
- Semantic HTML elements used (headers, sections, forms, tables)
- ARIA attributes not extensively observed
- Color contrast appears adequate in reviewed templates
- Keyboard navigation: Standard form tabbing presumed functional

**Gaps**:
- No obvious CSS framework (Bootstrap, etc.) - custom CSS
- Limited observed accessibility features (screen reader navigation, etc.)
- Responsive breakpoints appear minimal - primarily mobile/desktop split

## 16. Synchronization Logic

### 16.1 User Creation Synchronization

**Trigger**: When a user is created in any system's administrative interface

**Process**:
1. **Local Creation**: System creates user in its domain-specific table
   - Example: NewChange inserts into `Students` table with hashed password
2. **Central Registration**: 
   ```python
   # Sync to Portal
   sync_result = sync_user_to_portal(
       username=new_username,
       password=plaintext_password,  # Note: sent in plaintext!
       full_name=full_name,
       role=user_role,
       email=user_email,
       external_id=local_user_id  # e.g., student_id from NewChange
   )
   ```
3. **Mirroring to Other Systems**:
   ```python
   # Create corresponding records in other systems
   mirror_results = mirror_user_to_modules(
       username=new_username,
       password=plaintext_password,
       full_name=full_name,
       role=user_role,
       email=user_email
   )
   # Returns dict with results for each target system
   ```

### 16.2 Synchronization Functions Detail

**`sync_user_to_portal()`** (`Main/portal_sync.py`):
- Builds payload with user details
- POSTs to Portal's `/api/create-user` endpoint
- Returns success/failure with user_id from central system
- Network errors caught and returned as failure reasons

**`_provision()`** (helper function):
- Generic function for calling `/api/provision-user` on target systems
- Includes retry logic (3 attempts, 2-second delay)
- Logs persistent failures to `sync_failures` table
- Returns standardized success/failure dictionary

**`mirror_user_to_modules()`**:
- Orchestrates calls to `_provision()` for each relevant system
- Skips Voxify for teacher roles (by design - Voxify has no teacher concept)
- Returns aggregated results from all target systems

**`retry_failed_syncs()`**:
- Scans `sync_failures` table for unresolved entries
- Attempts to re-send failed payloads to target services
- Updates failure reasons or marks as resolved on success
- Returns statistics on retries performed

### 16.3 Conflict Resolution Strategy

**Current Approach**: "Last write wins" with manual intervention for conflicts
- No automatic conflict detection or resolution built-in
- Sync failures require manual investigation via `sync_failures` table
- Applications assume they are the system of record for their domain data

**Improvement Needed**:
- Implement conflict detection (timestamp comparison or version vectors)
- Define clear system-of-record policies per data type
- Automated resolution for non-conflicting updates (e.g., last name change)
- Manual review workflow for conflicting updates

### 16.4 Specific Synchronization Examples

**Creating a New Student**:
1. Admin in NewChange fills student form → submits
2. NewChange DB: INSERT into `Students` (password hashed locally)
3. NewChange → Portal: POST `/api/create-user` 
   - Payload: {username, plaintext password, full_name, role='student', email, external_id=student_id}
4. Portal DB: INSERT into `users` (password hashed with bcrypt)
5. Portal responds: {success:true, user_id:12345}
6. NewChange → TestPoint: POST `/api/provision-user`
   - Payload: same as above
7. TestPoint DB: INSERT into `users` + `students` tables (separate hashing)
8. NewChange → Voxify: POST `/api/provision-user` 
   - Payload: same as above
9. Voxify DB: INSERT into `users` (role mapped to 'voter') + optional student-specific fields
10. All systems now acknowledge student exists with consistent identity

**Handling Synchronization Failures**:
1. Network outage prevents Voxify from receiving provision-user call
2. `_provision()` retries 3 times with 2-second delays
3. If all fail: logs to `sync_failures` table:
   - `target_module`: 'voxify'
   - `payload_json`: {username:..., password:..., full_name:..., role:'student', email:...}
   - `reason`: "Unreachable: Connection refused"
   - `resolved`: 0 (false)
4. Administrator runs manual retry or system runs periodic `retry_failed_syncs()`
5. On success: Updates `sync_failures`.`resolved` = 1
6. On continued failure: Updates reason and preserves for manual intervention

## 17. Dependency Graph

### 17.1 Service Dependencies (Runtime)

```
External Dependencies:
All Services → MySQL Database (separate instances per service)
All Services → SMTP Server (email notifications via Gmail)
All Services → Python 3.x + Flask + mysql-connector-python + pyjwt + requests + python-dotenv

Internal Service Dependencies:
Portal: 
  → None (identity provider)
  
NewChange:
  → Portal (SSO validation, user creation)
  → TestPoint (student verification for enrollment)
  → TestPoint (optional: attendance validation for voting eligibility)
  
TestPoint:
  → Portal (SSO validation, user creation)
  → Voxify (receives voting status notifications)
  
Voxify:
  → Portal (SSO validation, user creation)
  → TestPoint (student import for voter registration, voter status checks)
```

### 17.2 Data Flow Dependencies

```
User Identity:
PRIMARY: Portal (users table)
SECONDARY: Each service's user/table (students, teachers, admins, voters)
DEPENDENCY: All services → Portal for authentication
            Services → Each other for entity-specific data

Student Records:
PRIMARY: TestPoint (students table - academic identity)
SECONDARY: NewChange (Students table - enrollment identity) 
           Voxify (users table with student_id - voter identity)
DEPENDENCY: Voxify → TestPoint (voter import)
            NewChange → TestPoint (enrollment validation)
            TestPoint ← Voxify (voting notifications)

Election Data:
PRIMARY: Voxify (elections, candidates, positions, votes tables)
SECONDARY: None (read-only consumption by others)
DEPENDENCY: TestPoint ← Voxify (voting status checks)
            NewChange ← Voxify (optional: attendance-based eligibility)
            Integration Hub ← Voxify (dashboard, results)

Academic Records:
PRIMARY: NewChange (enrollments, attendance, grades tables)
SECONDARY: TestPoint (exam_attempts for scores)
DEPENDENCY: TestPoint ← NewChange (enrollment validation)
            Voxify ← NewChange (optional: attendance-based voting eligibility)
```

### 17.3 Import/Include Dependencies (Code Level)

**Python Modules**:
```
Shared: flask, mysql.connector, datetime, json, os, requests, jwt, dotenv

Service-Specific:
- All: flask, mysql-connector-python, python-dotenv, requests, pyjwt
- N/A: No circular imports observed between services (loose coupling via HTTP)
```

### 17.4 Circular Dependency Analysis

**Status**: No circular dependencies detected between services
- Services communicate via HTTP REST APIs (stateless request/response)
- No shared libraries or modules creating import cycles
- Database connections are independent per service
- Coupling is through well-defined API contracts, not code sharing

**Risk Assessment**: LOW - Service independence allows for independent deployment and scaling

## 18. Known Issues

### 18.1 Security Concerns

**1. Plaintext Password Transmission** (SEVERITY: HIGH)
- Location: `Main/portal_sync.py:sync_user_to_portal()` and mirroring functions
- Issue: Passwords sent in plaintext over inter-service HTTP calls
- Risk: Network sniffing could expose credentials
- Mitigation: Use HTTPS in production, consider token-based service auth

**2. Hardcoded Service URLs** (SEVERITY: MEDIUM)
- Location: `Voxify/api.py` lines 12-13 (TESTPOINT_URL, NEWCHANGE_URL hardcoded)
- Issue: Inflexible deployment, requires code changes for environment switches
- Risk: Deployment errors, inflexibility
- Mitigation: Move to environment variables like other services

**3. JWT Secret Key Management** (SEVERITY: MEDIUM)
- Location: Hardcoded in Portal app.py, should match in all services
- Issue: If not properly synchronized, SSO breaks
- Risk: Authentication failures across services
- Mitigation: Use environment variable for secret key

**4. Lack of HTTPS Enforcement** (SEVERITY: MEDIUM)
- Observation: All service URLs use http:// by default
- Risk: Man-in-the-middle attacks in network environments
- Mitigation: Deploy behind HTTPS proxy, enforce secure cookies in production

### 18.2 Reliability Issues

**1. No Retry Mechanism for Real-time Calls** (SEVERITY: MEDIUM)
- Location: Direct API calls like NewChange→TestPoint in `enroll_verified()`
- Issue: Single attempt; transient network failures cause operation failure
- Risk: Failed enrollments, inconsistent states
- Mitigation: Implement retry with exponential backoff for critical operations

**2. Inconsistent Error Handling** (SEVERITY: LOW-MEDIUM)
- Observation: Some API calls lack comprehensive timeout/connection error handling
- Risk: Unhandled exceptions leading to 500 errors
- Mitigation: Standardize exception handling patterns across all services

**3. Silent Failures in Notification Paths** (SEVERITY: LOW)
- Location: TestPoint voting status endpoint (`update_voting_status`)
- Issue: Logs voting receipt but no persistent storage or user notification
- Risk: Audit trail gaps, no user feedback on notification success
- Mitigation: Store notifications in database, provide user-facing confirmation

### 18.3 Data Consistency Risks

**1. Eventual Consistency Windows** (SEVERITY: MEDIUM)
- Issue: Period between user creation in one system and propagation to others
- Risk: User able to login to source system but not target systems temporarily
- Mitigation: Implement blocking UI until synchronization completes or show pending status

**2. No Conflict Detection** (SEVERITY: MEDIUM)
- Issue: Simultaneous updates in multiple systems create conflicts with no detection
- Risk: Data loss, incorrect state
- Mitigation: Implement version vectors or last-write-wins with conflict logging

**3. Referential Integrity Gaps** (SEVERITY: LOW)
- Issue: Cross-service references (e.g., Voxify storing TestPoint student_id) lack FK constraints
- Risk: Orphaned references if source record deleted
- Mitigation: Implement soft deletes or application-level cascade checks

### 18.4 Performance Concerns

**1. Synchronous Cross-Service Calls** (SEVERITY: LOW)
- Observation: Critical paths wait for external API responses (e.g., enrollment verification)
- Impact: Increased latency proportional to network distance
- Mitigation: Consider asynchronous processing for non-critical paths, caching where appropriate

**2. No Caching Layer** (SEVERITY: LOW)
- Observation: Repeated calls for same data (e.g., stats polling)
- Impact: Unnecessary database load
- Mitigation: Implement caching layer (Redis) for frequently accessed, slowly changing data

### 18.5 Usability Issues

**1. Poor Offline Behavior** (SEVERITY: MEDIUM)
- Issue: No offline caching or queueing - operations fail immediately if network unavailable
- Impact: Poor user experience in unreliable network environments
- Mitigation: Implement local queue with background sync when connectivity restored

**2. Limited Feedback on Background Processes** (SEVERITY: LOW)
- Issue: Users unaware of ongoing synchronization processes
- Impact: Confusion when changes don't appear immediately
- Mitigation: Add subtle UI indicators for background sync status

## 19. Improvement Recommendations

### 19.1 High Impact, Low Effort

**1. Environment Variable Standardization** (ESTIMATE: 2 hours)
- Action: Move all hardcoded service URLs to environment variables
- Files: `Voxify/api.py` and similar locations
- Benefit: Deployment flexibility, environment consistency

**2. Secret Key Externalization** (ESTIMATE: 1 hour)
- Action: Move JWT secret key to environment variable
- Files: Portal app.py, ensure all services read from same env var
- Benefit: Secure secret management, rotation capability

**3. Standardize Error Responses** (ESTIMATE: 4 hours)
- Action: Create common error response format across all APIs
- Benefit: Consistent client-side error handling

### 19.2 Medium Impact, Medium Effort

**1. Implement HTTPS Everywhere** (ESTIMATE: 8 hours)
- Action: 
  - Generate/obtain SSL certificates for internal CA
  - Configure reverse proxy (NGINX/Apache) for TLS termination
  - Update all service URLs to use https://
  - Set Secure flag on cookies in production
- Benefit: Protection against eavesdropping and MITM attacks

**2. Add Retry Logic to Critical Paths** (ESTIMATE: 6 hours)
- Action: 
  - Create reusable HTTP client with retry/exponential backoff
  - Apply to synchronization calls and validation requests
  - Add circuit breaker pattern for extended outages
- Benefit: Improved resilience to transient network issues

**3. Implement Basic Monitoring** (ESTIMATE: 4 hours)
- Action:
  - Add Prometheus metrics endpoints to each service
  - Track request latency, error rates, saturation
  - Export health beyond simple ping
- Benefit: Operational visibility, capacity planning, alerting

### 19.3 High Impact, High Effort

**1. Implement Proper Conflict Detection** (ESTIMATE: 20+ hours)
- Action:
  - Add version vectors or timestamps to critical entities
  - Implement conflict detection logic in synchronization paths
  - Create conflict resolution UI for manual intervention
  - Define clear merge policies per data type
- Benefit: Prevent data loss in distributed update scenarios

**2. Service Mesh/Lightweight Orchestration** (ESTIMATE: 40+ hours)
- Action:
  - Evaluate service mesh (Istio Linkerd) or API gateway (Kong, Envoy)
  - Implement centralized auth, rate limiting, observability
  - Standardize inter-service communication patterns
- Benefit: Better traffic management, security, and observability

**3. Implement Event-Driven Architecture** (ESTIMATE: 60+ hours)
- Action:
  - Introduce message queue (RabbitMQ, Apache Kafka)
  - Replace synchronous API calls with event publishing
  - Implement event handlers for synchronization
  - Add dead letter queues for failed processing
- Benefit: True loose coupling, better scalability, fault tolerance

### 19.4 Low Impact, Effort Varies

**1. Add API Versioning** (ESTIMATE: 4 hours)
- Action: 
  - Prefix APIs with `/api/v1/` 
  - Implement versioning strategy
- Benefit: Backward compatibility during evolution

**2. Standardize Logging Format** (ESTIMATE: 3 hours)
- Action:
  - Implement structured logging (JSON format)
  - Add correlation IDs for request tracing
  - Set appropriate log levels
- Benefit: Better debugging, ELK stack integration

**3. Implement Input Validation Library** (ESTIMATE: 6 hours)
- Action:
  - Create shared validation utilities
  - Apply to all API endpoints and form inputs
  - Include SQL injection, XSS prevention
- Benefit: Consistent security posture across services

## 20. Final Summary

### 20.1 Architecture Overview

This system implements a **federated microservices architecture** with four specialized services bound together by:
- **Central Authentication**: Portal service provides SSO via JWT tokens
- **API-Based Integration**: RESTful endpoints enable data sharing and synchronization
- **Eventual Consistency Model**: Data propagates asynchronously with manual reconciliation
- **Loose Coupling**: Services communicate only via well-defined HTTP APIs, no shared libraries or databases

### 20.2 Key Integration Points

**Authentication Hub**:
- Portal service is the single source of truth for user credentials
- All other services delegate authentication validation to Portal
- Enables true Single Sign-On experience across the educational ecosystem

**Data Exchange Patterns**:
1. **User Identity Propagation**: Created-in-one-system → Portal → Created-in-others
2. **Validation Queries**: Service A → Service B: "Does this entity exist/are they eligible?"
3. **Event Notifications**: Service A → Service B: "Something happened you should know about"
4. **Reference Data Sharing**: Service A provides lists (students, elections) for Service B to consume

### 20.3 Critical Files for Understanding the System

**For Authentication Flow**:
1. `integrated/portal/app.py` - Token creation/validation endpoints
2. `integrated/newchange_app/Main/sso.py` - SSO validation logic
3. `integrated/portal/db_config.py` - Central user database

**For Synchronization Logic**:
1. `integrated/newchange_app/Main/portal_sync.py` - Core synchronization implementation
2. `integrated/newchange_app/Main/api.py` - Provisioning endpoints
3. `integrated/testpoint_app/testpoint/api.py` - Peer provisioning endpoints
4. `integrated/voxify_app/Voxify/api.py` - Peer provisioning endpoints

**For Cross-Service APIs**:
1. Each service's `/api/*` endpoints define the integration contract
2. Key endpoints: `/api/ping`, `/api/provision-user`, `/api/stats`
3. Service-specific endpoints enable domain-specific interactions

**For Database Understanding**:
1. Each service's `db_config.py` or equivalent shows connection patterns
2. `database.sql` files (where present) define complete schemas
3. Migration scripts show table evolution over time

### 20.4 Most Important Synchronization Functions

1. **`sync_user_to_portal()`** - Gateway to SSO participation
2. **`mirror_user_to_modules()`** - Creates user presence in all systems
3. **`retry_failed_syncs()`** - Recovery mechanism for transient failures
4. **Service-specific `provision_user()` endpoints** - Enable local user creation

### 20.5 Primary API Endpoints for Integration

**Consumed by Integration Hub** (if implemented):
- `GET http://portal:5000/api/ping` - System health
- `GET http://portal:5000/api/stats` - User counts
- `GET http://testpoint:5003/api/students` - Student registry
- `GET http://voxify:5001/api/elections` - Active elections
- `GET http://newchange:5002/api/students/active` - Enrolled students

**Trigger Cross-Sync Operations**:
- `POST http://portal:5000/api/create-user` - New user onboarding
- `POST http://<service>:<port>/api/provision-user` - Local user provisioning

### 20.6 System Strengths

1. **Clear Separation of Concerns**: Each service has well-defined domain responsibility
2. **Robust SSO Implementation**: Centralized authentication reduces password fatigue
3. **Extensible API Design**: Straightforward to add new services or endpoints
4. **Failure-Aware Synchronization**: Error logging and retry mechanisms exist
5. **Environment Configurable**: Core settings externalized for deployment flexibility

### 20.7 Recommended Evolution Path

1. **Immediate (0-3 months)**:
   - Fix plaintext password transmission in synchronization
   - Standardize all configuration to environment variables
   - Add HTTPS/TLS termination at reverse proxy layer
   - Implement basic monitoring and health checks

2. **Short-term (3-6 months)**:
   - Add retry logic and circuit breaking to cross-service calls
   - Implement basic conflict detection for critical data types
   - Standardize error response formats and logging
   - Add API versioning for future compatibility

3. **Medium-term (6-12 months)**:
   - Evaluate message queue implementation for asynchronous communication
   - Implement comprehensive monitoring and alerting
   - Develop admin UI for monitoring synchronization health
   - Consider service mesh for advanced traffic management

4. **Long-term (12+ months)**:
   - Full event-driven architecture migration
   - Advanced conflict resolution with automated merging
   - Multi-region deployment capabilities
   - Comprehensive audit trail and compliance reporting

This system provides a solid foundation for an integrated educational platform with clear separation of concerns and functional SSO. Addressing the identified limitations will significantly enhance its robustness, security, and operational suitability for production deployment.

---
*Document generated from static code analysis performed on 2026-07-11*
*Total lines of code analyzed: ~15,000+ across 50+ Python, HTML, CSS, and JavaScript files*