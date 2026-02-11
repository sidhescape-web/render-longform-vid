# Setup Guide - Video Merge API v2.0

Complete setup instructions for the Video Merge API with longform video rendering capabilities.

---

## Prerequisites

- **Python 3.9+**
- **FFmpeg** installed and available in PATH
- **Railway account** (or compatible S3 storage) for video storage
- **Git** (optional, for deployment)

---

## Installation

### 1. Clone or Download the Repository

```bash
cd merge-videos-api
```

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 3. Install FFmpeg

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ffmpeg
```

**macOS:**
```bash
brew install ffmpeg
```

**Windows:**
Download from https://ffmpeg.org/download.html and add to PATH.

**Verify installation:**
```bash
ffmpeg -version
```

### 4. Configure Environment Variables

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and fill in your values:

```env
API_KEY=your-secure-api-key-here
BUCKET=your-railway-bucket-name
ENDPOINT=https://storage.railway.app
ACCESS_KEY_ID=your-access-key-id
SECRET_ACCESS_KEY=your-secret-access-key
REGION=auto
PORT=8000
DATABASE_PATH=jobs.db
```

**Important:**
- `API_KEY`: Create a strong, random API key (e.g., use `openssl rand -hex 32`)
- Railway Storage credentials: Get from Railway dashboard → Storage → Access Keys

### 5. Initialize Database

The database will be automatically initialized on first startup. The SQLite database file will be created at the path specified in `DATABASE_PATH`.

---

## Running the Application

### Local Development

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at:
- **API:** http://localhost:8000
- **Docs:** http://localhost:8000/docs
- **Health:** http://localhost:8000/health

### Production

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1
```

**Note:** For longform video processing, use only 1 worker to avoid database conflicts. The background worker handles async jobs automatically.

---

## Deployment to Railway

### Method 1: Railway CLI

```bash
railway up
```

### Method 2: GitHub Integration

1. Push code to GitHub
2. Connect repository in Railway dashboard
3. Railway will auto-detect and deploy

### Environment Variables on Railway

Set these in Railway dashboard → Variables:

```
API_KEY=your-secure-api-key-here
BUCKET=your-railway-bucket-name
ENDPOINT=https://storage.railway.app
ACCESS_KEY_ID=your-access-key-id
SECRET_ACCESS_KEY=your-secret-access-key
REGION=auto
PORT=8000
DATABASE_PATH=/app/jobs.db
```

**Important for Railway:**
- Set `DATABASE_PATH=/app/jobs.db` to ensure the database persists in the app directory
- Railway automatically provides storage credentials if you have Railway Storage enabled

---

## Testing the API

### 1. Health Check

```bash
curl http://localhost:8000/health
```

### 2. Test Video Merge (Sync)

```bash
curl -X POST "http://localhost:8000/api/v1/merge" \
  -H "X-API-Key: your-secure-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "video_urls": [
      "https://www.w3schools.com/html/mov_bbb.mp4",
      "https://www.w3schools.com/html/movie.mp4"
    ],
    "quality": "720",
    "aspect_ratio": "16:9"
  }'
```

### 3. Test Longform Render (Async)

**Step 1: Submit job**

```bash
curl -X POST "http://localhost:8000/api/v1/longform/render" \
  -H "X-API-Key: your-secure-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "audio_urls": [
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    ],
    "background_source": "images",
    "background_urls": [
      "https://picsum.photos/1920/1080",
      "https://picsum.photos/id/237/1920/1080"
    ],
    "quality": "720"
  }'
```

**Step 2: Check status (use request_id from step 1)**

```bash
curl -X GET "http://localhost:8000/api/v1/longform/status/req_xxxxxxxxxx" \
  -H "X-API-Key: your-secure-api-key-here"
```

**Step 3: Get result (once status is "completed")**

```bash
curl -X GET "http://localhost:8000/api/v1/longform/result/req_xxxxxxxxxx" \
  -H "X-API-Key: your-secure-api-key-here"
```

---

## Project Structure

```
merge-videos-api/
├── main.py                      # FastAPI app entry point
├── requirements.txt             # Python dependencies
├── .env                         # Environment variables (not in git)
├── .env.example                 # Example environment file
├── jobs.db                      # SQLite database (created on first run)
├── API-DOCUMENTATION.md         # Complete API documentation
├── SETUP.md                     # This file
│
├── migrations/
│   └── 001_initial_schema.sql  # Database schema
│
├── routers/
│   ├── __init__.py
│   └── longform.py             # Longform video endpoints
│
└── utils/
    ├── __init__.py
    ├── auth.py                 # API key authentication
    ├── db.py                   # Database utilities
    ├── storage.py              # S3/Railway storage
    ├── video_processor.py      # Video merge logic (sync)
    ├── longform_processor.py   # Longform video processing
    └── worker.py               # Background job worker
```

---

## Features

### Video Merge (Synchronous)
- Merge 2-10 videos
- Configurable quality (720p, 1080p)
- Configurable aspect ratio (16:9, 9:16, 1:1)
- Max duration: 2 hours
- Immediate response with merged video URL

### Longform Video Rendering (Asynchronous)
- Support for up to 30 audio files
- Background source: images (1-15) or videos (1-5)
- Fixed 16:9 aspect ratio
- Quality: 720p or 1080p
- Max duration: 2 hours (capped at audio length)
- Background videos automatically muted
- Background media looped to match audio duration
- Async processing with polling

---

## Troubleshooting

### Database Errors

**Error:** `database is locked`

**Solution:** Ensure only one instance of the app is running. The background worker processes jobs sequentially.

### FFmpeg Errors

**Error:** `ffmpeg: command not found`

**Solution:** Install FFmpeg and ensure it's in your system PATH.

### Download Errors

**Error:** `Failed to download video from URL`

**Solutions:**
- Ensure URLs are publicly accessible
- Check if URLs require authentication (not supported)
- Verify URLs return actual media files (not HTML pages)

### Storage/Upload Errors

**Error:** `Failed to upload merged video`

**Solutions:**
- Verify Railway Storage credentials in `.env`
- Check bucket name and endpoint URL
- Ensure bucket exists and has write permissions

### Worker Not Processing Jobs

**Symptoms:** Jobs stuck in "pending" status

**Solutions:**
- Check server logs for worker errors
- Restart the application to restart the worker
- Verify database is accessible and not locked

### Memory Issues

**Error:** Out of memory during processing

**Solutions:**
- Reduce video quality from 1080p to 720p
- Reduce number of input files
- Increase server memory allocation (Railway: adjust plan)

---

## API Documentation

See **API-DOCUMENTATION.md** for complete API reference with examples.

---

## Monitoring

### Check Worker Status

Check application logs for worker activity:

```
Background worker started
Processing job req_xxxxx
Job req_xxxxx completed successfully in 245.8s
```

### Database Queries

You can query the database directly to check job status:

```bash
sqlite3 jobs.db "SELECT id, status, created_at FROM jobs ORDER BY created_at DESC LIMIT 10;"
```

---

## Performance Considerations

- **Longform videos** can take 5-30+ minutes depending on:
  - Total audio duration
  - Number of audio/background files
  - Quality setting (1080p takes longer than 720p)
  - Server resources

- **Recommended limits:**
  - Keep audio files under 1 hour total for faster processing
  - Use 720p for faster processing times
  - Limit concurrent jobs (worker processes one at a time)

---

## Security

- **API Key:** Keep your API_KEY secret. Rotate regularly.
- **Storage Credentials:** Never commit to git. Use environment variables.
- **Database:** SQLite file should be protected with file system permissions
- **HTTPS:** Use HTTPS in production (Railway provides this automatically)

---

## Scaling

For high-traffic scenarios:

1. **Multiple Workers:** Deploy multiple instances with separate workers
2. **Queue System:** Replace SQLite with PostgreSQL + job queue (Redis, Celery)
3. **Storage:** Use CDN for serving videos
4. **Caching:** Cache status responses to reduce database queries

---

## Support

- **API Documentation:** See API-DOCUMENTATION.md
- **Logs:** Check Railway logs or local console output
- **Database:** Query jobs.db directly for debugging

---

## License

This project is provided as-is for your use.
