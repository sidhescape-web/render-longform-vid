# Project Structure - Video Merge API v2.0

Visual overview of the complete project organization.

---

## 📁 Directory Structure

```
merge-videos-api/
│
├── 📄 main.py                          # FastAPI application entry point
├── 📄 requirements.txt                 # Python dependencies
├── 📄 .env                             # Environment variables (not in git)
├── 📄 .env.example                     # Environment template
├── 📄 .gitignore                       # Git ignore rules
├── 📄 Procfile                         # Railway deployment config
├── 📄 railway.json                     # Railway settings
├── 📄 nixpacks.toml                    # Nixpacks config
│
├── 📚 Documentation/
│   ├── 📄 README.md                    # Project overview
│   ├── 📄 API-DOCUMENTATION.md         # Complete API reference
│   ├── 📄 CURL-EXAMPLES.md             # Quick cURL examples
│   ├── 📄 SETUP.md                     # Setup & deployment guide
│   ├── 📄 CHANGELOG.md                 # Version history
│   ├── 📄 IMPLEMENTATION-SUMMARY.md    # Implementation details
│   ├── 📄 PROJECT-STRUCTURE.md         # This file
│   ├── 📄 ASYNC-JOBS.md                # Legacy async jobs doc
│   ├── 📄 DEPLOYMENT.md                # Legacy deployment doc
│   ├── 📄 REST-API.md                  # Legacy API doc
│   └── 📄 merge-video-project.md       # Legacy project doc
│
├── 📂 migrations/
│   └── 📄 001_initial_schema.sql       # Database schema
│
├── 📂 routers/
│   ├── 📄 __init__.py                  # Package initialization
│   └── 📄 longform.py                  # Longform video endpoints
│
└── 📂 utils/
    ├── 📄 __init__.py                  # Package initialization
    ├── 📄 auth.py                      # API key authentication
    ├── 📄 db.py                        # Database utilities
    ├── 📄 storage.py                   # S3/Railway storage
    ├── 📄 video_processor.py           # Video merge logic (sync)
    ├── 📄 longform_processor.py        # Longform video processing
    └── 📄 worker.py                    # Background job worker
```

---

## 🗂️ File Organization by Function

### Core Application
```
main.py                    - FastAPI app, routers, exception handlers
requirements.txt           - Dependencies list
.env / .env.example        - Configuration
```

### API Endpoints
```
routers/
├── longform.py           - Longform render, status, result endpoints
└── (merge endpoints)     - In main.py (original)
```

### Business Logic
```
utils/
├── video_processor.py    - Sync video merging
├── longform_processor.py - Async longform video creation
└── worker.py             - Background job processing
```

### Data Layer
```
utils/
├── db.py                 - SQLite database operations
└── storage.py            - S3/Railway storage upload

migrations/
└── 001_initial_schema.sql - Database schema
```

### Infrastructure
```
utils/
└── auth.py               - API key authentication
```

### Documentation
```
README.md                 - Main project overview
API-DOCUMENTATION.md      - Complete API reference
CURL-EXAMPLES.md          - Quick examples
SETUP.md                  - Installation & deployment
CHANGELOG.md              - Version history
IMPLEMENTATION-SUMMARY.md - Implementation details
PROJECT-STRUCTURE.md      - This file
```

---

## 📊 Component Dependencies

```
┌─────────────────────────────────────────────────────────────┐
│                         main.py                             │
│  - FastAPI app initialization                              │
│  - Startup events (DB init, worker start)                  │
│  - Exception handlers                                       │
└──────────────┬──────────────────────────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼──────┐  ┌──────▼──────────┐
│   Router    │  │  Utils/Auth     │
│  (merge)    │  │  - get_api_key  │
└──────┬──────┘  └─────────────────┘
       │
┌──────▼──────┐
│   Router    │
│ (longform)  │
└──────┬──────┘
       │
       ├───────────┬──────────────┬──────────────┐
       │           │              │              │
┌──────▼──────┐ ┌──▼────────┐ ┌──▼─────────┐ ┌─▼────────┐
│  utils/db   │ │  worker   │ │  longform  │ │ storage  │
│  - DB ops   │ │  - Process│ │  processor │ │ - Upload │
└─────────────┘ └───────────┘ └────────────┘ └──────────┘
```

---

## 🔄 Data Flow

### Synchronous Video Merge
```
Client Request
    ↓
main.py (merge endpoint)
    ↓
video_processor.py
    ├── download_video()
    ├── get_duration_and_has_audio()
    └── merge_videos()
    ↓
storage.py (upload_merged_video)
    ↓
Response to Client (with URL)
```

### Asynchronous Longform Render
```
Client Request
    ↓
routers/longform.py (render endpoint)
    ↓
utils/db.py (create_job)
    ↓
Response to Client (with request_id)
    ↓
[Background Process]
    ↓
utils/worker.py (worker_loop)
    ├── get_pending_jobs()
    ├── update_job_status("processing")
    └── process_job()
        ↓
    utils/longform_processor.py
        ├── download_media()
        ├── concatenate_audio()
        └── create_video_from_images/videos()
        ↓
    storage.py (upload_merged_video)
        ↓
    utils/db.py (update_job_result)
    ↓
[Client Polling]
    ↓
routers/longform.py (status endpoint)
    ↓
utils/db.py (get_job)
    ↓
Response to Client (status)
    ↓
[When completed]
    ↓
routers/longform.py (result endpoint)
    ↓
utils/db.py (get_job)
    ↓
Response to Client (result URL)
```

---

## 🗄️ Database Structure

### SQLite Database (`jobs.db`)

**Location:** Root directory (configurable via `DATABASE_PATH`)

**Tables:**
```sql
jobs
├── id (TEXT, PRIMARY KEY)
├── status (TEXT)              -- pending, processing, completed, failed
├── created_at (TEXT)
├── updated_at (TEXT)
├── audio_urls (TEXT)          -- JSON array
├── background_source (TEXT)   -- images or videos
├── background_urls (TEXT)     -- JSON array
├── quality (TEXT)             -- 720 or 1080
├── result_url (TEXT)          -- NULL until completed
├── error_message (TEXT)       -- NULL unless failed
├── duration_seconds (REAL)    -- NULL until completed
└── processing_time (REAL)     -- NULL until completed
```

**Indexes:**
- `idx_jobs_status` - For status filtering
- `idx_jobs_created_at` - For chronological ordering

---

## 🚀 Runtime Components

### Main Process
```
uvicorn (ASGI server)
    ├── FastAPI app
    ├── Routers (merge, longform)
    └── Background Worker (asyncio task)
```

### Background Worker
```
worker_loop (asyncio)
    ├── Poll database every 5 seconds
    ├── Process one job at a time
    ├── Update job status
    └── Handle errors and cleanup
```

---

## 📦 External Dependencies

### Python Packages
```python
# Web Framework
fastapi>=0.104.0           # API framework
uvicorn[standard]>=0.24.0  # ASGI server

# HTTP & Storage
httpx>=0.25.0              # HTTP client
boto3>=1.29.0              # S3 storage

# Database
aiosqlite>=0.19.0          # Async SQLite

# Processing
ffmpeg-python>=0.2.0       # FFmpeg wrapper
pillow>=10.0.0             # Image processing

# Utilities
python-dotenv>=1.0.0       # Environment variables
python-multipart>=0.0.6    # Form data
pydantic>=2.0.0            # Data validation
```

### System Dependencies
```
FFmpeg                     # Video/audio processing
SQLite3                    # Database (usually pre-installed)
```

---

## 🔧 Configuration Files

### Environment Variables (`.env`)
```env
# Authentication
API_KEY=<secret-key>

# Storage (Railway/S3)
BUCKET=<bucket-name>
ENDPOINT=<storage-endpoint>
ACCESS_KEY_ID=<access-key>
SECRET_ACCESS_KEY=<secret-key>
REGION=<region>

# Application
PORT=8000
DATABASE_PATH=jobs.db
```

### Deployment (`Procfile`)
```
web: uvicorn main:app --host 0.0.0.0 --port $PORT
```

### Railway (`railway.json`)
```json
{
  "build": {...},
  "deploy": {...}
}
```

---

## 📏 Size & Complexity

### Lines of Code (Approximate)
```
main.py:                  ~220 lines
routers/longform.py:      ~180 lines
utils/db.py:              ~120 lines
utils/longform_processor.py: ~280 lines
utils/worker.py:          ~90 lines
utils/video_processor.py: ~180 lines
utils/storage.py:         ~60 lines
utils/auth.py:            ~20 lines
───────────────────────────────────
Total:                    ~1,150 lines
```

### Documentation (Approximate)
```
API-DOCUMENTATION.md:     ~580 lines
CURL-EXAMPLES.md:         ~350 lines
SETUP.md:                 ~350 lines
README.md:                ~300 lines
CHANGELOG.md:             ~250 lines
IMPLEMENTATION-SUMMARY.md: ~520 lines
PROJECT-STRUCTURE.md:     ~400 lines (this file)
───────────────────────────────────
Total:                    ~2,750 lines
```

---

## 🎯 Entry Points

### For Users
```
http://localhost:8000/                  # API info
http://localhost:8000/docs              # Swagger UI
http://localhost:8000/health            # Health check
http://localhost:8000/api/v1/merge      # Sync merge
http://localhost:8000/api/v1/longform/render    # Async render
http://localhost:8000/api/v1/longform/status/{id}  # Check status
http://localhost:8000/api/v1/longform/result/{id}  # Get result
```

### For Developers
```
main.py                 # Application entry
utils/db.py             # Database operations
utils/longform_processor.py  # Core processing
routers/longform.py     # API endpoints
```

### For Deployment
```
requirements.txt        # Install dependencies
.env                    # Configure environment
Procfile                # Start command
railway.json            # Railway config
```

---

## 🧩 Module Purposes

| Module | Purpose | Key Functions |
|--------|---------|---------------|
| `main.py` | App initialization | `app`, `startup_event()`, exception handlers |
| `routers/longform.py` | Longform API | `render_longform_video()`, `get_render_status()`, `get_render_result()` |
| `utils/db.py` | Database ops | `create_job()`, `get_job()`, `update_job_status()`, `update_job_result()` |
| `utils/worker.py` | Background processing | `worker_loop()`, `process_job()` |
| `utils/longform_processor.py` | Video creation | `process_longform_video()`, `create_video_from_images()`, `create_video_from_videos()` |
| `utils/video_processor.py` | Video merging | `merge_videos()`, `download_video()` |
| `utils/storage.py` | File upload | `upload_merged_video()` |
| `utils/auth.py` | Authentication | `get_api_key()` |

---

## 🎨 Design Patterns Used

1. **Router Pattern** - Organized endpoints by feature
2. **Repository Pattern** - Database abstraction in `utils/db.py`
3. **Worker Pattern** - Background job processing
4. **Factory Pattern** - Video processor selection based on source type
5. **Request-Poll-Fetch** - Async job handling pattern

---

## 🔍 Quick Navigation

**Need to:**
- **Add new endpoint?** → Create in `routers/` or add to `main.py`
- **Modify processing?** → Edit `utils/longform_processor.py` or `utils/video_processor.py`
- **Change database?** → Update `utils/db.py` and create migration
- **Update worker?** → Modify `utils/worker.py`
- **Add documentation?** → Update relevant `.md` file
- **Configure deployment?** → Edit `.env`, `Procfile`, or `railway.json`

---

**Last Updated:** February 11, 2026  
**Version:** 2.0.0
