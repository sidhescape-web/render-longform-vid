# Video Merge API v2.0

A powerful FastAPI-based video processing service that supports both synchronous video merging and asynchronous longform video rendering with audio and background media.

---

## 🎥 Features

### Video Merge (Synchronous)
- Merge 2-10 videos instantly
- Configurable quality: 720p, 1080p
- Configurable aspect ratio: 16:9, 9:16, 1:1
- Smooth crossfade transitions
- Up to 2 hours total duration

### Longform Video Rendering (Asynchronous) ⭐ NEW
- Create videos from audio + background media
- Support for 1-30 audio files (auto-concatenated)
- Two background source types:
  - **Images:** 1-15 URLs
  - **Videos:** 1-5 URLs (auto-muted)
- Fixed 16:9 aspect ratio
- Quality: 720p or 1080p
- Background media loops to match audio
- Async processing with status polling
- Up to 2 hours total duration

---

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- FFmpeg
- Railway account (for storage)

### Installation

```bash
# Clone repository
git clone <repo-url>
cd merge-videos-api

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your credentials

# Run locally
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Visit http://localhost:8000/docs for interactive API documentation.

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [API-DOCUMENTATION.md](API-DOCUMENTATION.md) | Complete API reference with examples |
| [CURL-EXAMPLES.md](CURL-EXAMPLES.md) | Quick copy-paste cURL commands |
| [SETUP.md](SETUP.md) | Detailed setup and deployment guide |
| [CHANGELOG.md](CHANGELOG.md) | Version history and migration guide |

---

## 📝 API Overview

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/api/v1/merge` | POST | Merge videos (sync) |
| `/api/v1/longform/render` | POST | Queue longform render |
| `/api/v1/longform/status/{id}` | GET | Check job status |
| `/api/v1/longform/result/{id}` | GET | Get completed result |

### Authentication

All endpoints (except `/health`) require an API key:

```bash
-H "X-API-Key: YOUR_API_KEY"
```

---

## 🎬 Usage Examples

### Merge Videos (Sync)

```bash
curl -X POST "http://localhost:8000/api/v1/merge" \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "video_urls": [
      "https://example.com/video1.mp4",
      "https://example.com/video2.mp4"
    ],
    "quality": "1080",
    "aspect_ratio": "16:9"
  }'
```

**Response:**
```json
{
  "success": true,
  "merged_url": "https://storage.example.com/merged-abc123.mp4",
  "duration_seconds": 180.5,
  "processing_time": 45.2,
  "clips_merged": 2
}
```

### Longform Render with Images (Async)

**Step 1: Submit job**

```bash
curl -X POST "http://localhost:8000/api/v1/longform/render" \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "audio_urls": [
      "https://example.com/audio1.mp3",
      "https://example.com/audio2.mp3"
    ],
    "background_source": "images",
    "background_urls": [
      "https://example.com/img1.jpg",
      "https://example.com/img2.jpg",
      "https://example.com/img3.jpg"
    ],
    "quality": "1080"
  }'
```

**Response:**
```json
{
  "success": true,
  "request_id": "req_a1b2c3d4e5f6",
  "message": "Render job queued. Use the request_id to check status."
}
```

**Step 2: Check status**

```bash
curl "http://localhost:8000/api/v1/longform/status/req_a1b2c3d4e5f6" \
  -H "X-API-Key: YOUR_API_KEY"
```

**Step 3: Get result (when completed)**

```bash
curl "http://localhost:8000/api/v1/longform/result/req_a1b2c3d4e5f6" \
  -H "X-API-Key: YOUR_API_KEY"
```

---

## 🔧 Configuration

### Environment Variables

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

See [SETUP.md](SETUP.md) for detailed configuration instructions.

---

## 📊 Project Structure

```
merge-videos-api/
├── main.py                      # FastAPI app
├── requirements.txt             # Dependencies
├── .env                         # Environment variables
├── jobs.db                      # SQLite database
│
├── migrations/
│   └── 001_initial_schema.sql  # Database schema
│
├── routers/
│   └── longform.py             # Longform endpoints
│
├── utils/
│   ├── auth.py                 # Authentication
│   ├── db.py                   # Database utilities
│   ├── storage.py              # S3/Railway storage
│   ├── video_processor.py      # Video merge
│   ├── longform_processor.py   # Longform processing
│   └── worker.py               # Background worker
│
└── docs/
    ├── API-DOCUMENTATION.md
    ├── CURL-EXAMPLES.md
    ├── SETUP.md
    └── CHANGELOG.md
```

---

## 🎯 Key Constraints

### Longform with Images
- Audio URLs: 1-30
- Image URLs: 1-15
- Aspect ratio: 16:9 (fixed)
- Quality: 720p or 1080p
- Max duration: 2 hours

### Longform with Videos
- Audio URLs: 1-30
- Video URLs: 1-5 (auto-muted)
- Aspect ratio: 16:9 (fixed)
- Quality: 720p or 1080p
- Max duration: 2 hours

### Video Merge
- Video URLs: 2-10
- Aspect ratio: 16:9, 9:16, or 1:1
- Quality: 720p or 1080p
- Max duration: 2 hours

---

## 🛠️ Technologies

- **FastAPI** - Modern Python web framework
- **FFmpeg** - Video/audio processing
- **SQLite** - Async job tracking
- **aiosqlite** - Async database operations
- **boto3** - S3-compatible storage
- **Railway** - Deployment & storage
- **uvicorn** - ASGI server

---

## 🚢 Deployment

### Railway (Recommended)

```bash
# Using Railway CLI
railway up

# Or connect via GitHub in Railway dashboard
```

See [SETUP.md](SETUP.md) for detailed deployment instructions.

---

## 📈 Performance

Longform video processing time depends on:
- Total audio duration
- Number of audio/background files
- Quality setting (1080p vs 720p)
- Server resources

**Typical processing times:**
- 5-10 minutes: Short videos (<10 min audio)
- 10-20 minutes: Medium videos (10-30 min audio)
- 20-30+ minutes: Long videos (30+ min audio)

---

## 🔒 Security

- API key authentication required
- Storage credentials via environment variables
- Database protected by file system permissions
- HTTPS in production (auto-enabled on Railway)
- No sensitive data in logs

---

## 🐛 Troubleshooting

### Common Issues

**Database locked**
- Ensure only one instance is running
- Check file permissions on `jobs.db`

**FFmpeg not found**
- Install FFmpeg and add to PATH
- Verify: `ffmpeg -version`

**Jobs stuck in pending**
- Check server logs for worker errors
- Restart application to restart worker

**Upload fails**
- Verify Railway storage credentials
- Check bucket name and permissions

See [SETUP.md](SETUP.md) for more troubleshooting tips.

---

## 📚 Examples

See [CURL-EXAMPLES.md](CURL-EXAMPLES.md) for copy-paste ready examples including:

- Health checks
- Video merge with different settings
- Longform rendering with images (min, max, typical)
- Longform rendering with videos (min, max, typical)
- Complete workflows with polling
- Error handling examples

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

This project is provided as-is for your use.

---

## 🆕 What's New in v2.0

- ✨ Asynchronous longform video rendering
- 🎵 Support for up to 30 audio files
- 🖼️ Image backgrounds (1-15 URLs)
- 🎬 Video backgrounds (1-5 URLs, auto-muted)
- 🔄 Automatic background looping
- 📊 SQLite job tracking
- ⚙️ Background worker system
- 📖 Comprehensive documentation

See [CHANGELOG.md](CHANGELOG.md) for full release notes.

---

## 📞 Support

- **Documentation:** See docs in this repository
- **Issues:** Report bugs via GitHub issues
- **API Docs:** Visit `/docs` endpoint when running

---

## ⭐ Features Roadmap

Future enhancements (see [CHANGELOG.md](CHANGELOG.md) for details):

- Multiple concurrent workers
- PostgreSQL support
- Webhook notifications
- Progress tracking
- Job cancellation
- Subtitle support
- Watermarks
- Custom transitions

---

**Made with ❤️ using FastAPI and FFmpeg**
