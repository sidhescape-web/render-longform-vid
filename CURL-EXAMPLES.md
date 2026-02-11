# cURL Examples - Quick Reference

Quick copy-paste cURL commands for testing the Video Merge API.

**Before using:** Replace `BASE_URL` and `YOUR_API_KEY` with your actual values.

---

## Setup Variables (Optional)

```bash
export BASE_URL="http://localhost:8000"
export API_KEY="your-secure-api-key-here"
```

Then you can use `$BASE_URL` and `$API_KEY` in commands below.

---

## 1. Health Check

```bash
curl -s "$BASE_URL/health"
```

---

## 2. Video Merge (Synchronous)

### Merge 2 videos - 1080p, 16:9

```bash
curl -X POST "$BASE_URL/api/v1/merge" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "video_urls": [
      "https://www.w3schools.com/html/mov_bbb.mp4",
      "https://www.w3schools.com/html/movie.mp4"
    ],
    "quality": "1080",
    "aspect_ratio": "16:9"
  }'
```

---

## 3. Longform Rendering - With Images

### Minimum example (1 audio, 1 image)

```bash
curl -X POST "$BASE_URL/api/v1/longform/render" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "audio_urls": [
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    ],
    "background_source": "images",
    "background_urls": [
      "https://picsum.photos/1920/1080"
    ],
    "quality": "1080"
  }'
```

### With 5 audio files and 10 images

```bash
curl -X POST "$BASE_URL/api/v1/longform/render" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "audio_urls": [
      "https://example.com/audio1.mp3",
      "https://example.com/audio2.mp3",
      "https://example.com/audio3.mp3",
      "https://example.com/audio4.mp3",
      "https://example.com/audio5.mp3"
    ],
    "background_source": "images",
    "background_urls": [
      "https://example.com/image1.jpg",
      "https://example.com/image2.jpg",
      "https://example.com/image3.jpg",
      "https://example.com/image4.jpg",
      "https://example.com/image5.jpg",
      "https://example.com/image6.jpg",
      "https://example.com/image7.jpg",
      "https://example.com/image8.jpg",
      "https://example.com/image9.jpg",
      "https://example.com/image10.jpg"
    ],
    "quality": "1080"
  }'
```

**Guidance:**
- **Minimum:** 1 audio URL, 1 image URL
- **Maximum:** 30 audio URLs, 15 image URLs
- Images will cycle/loop to match the total audio duration
- Each image displays for an equal duration

### With 15 images (maximum)

```bash
curl -X POST "$BASE_URL/api/v1/longform/render" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "audio_urls": [
      "https://example.com/audio1.mp3"
    ],
    "background_source": "images",
    "background_urls": [
      "https://example.com/img1.jpg",
      "https://example.com/img2.jpg",
      "https://example.com/img3.jpg",
      "https://example.com/img4.jpg",
      "https://example.com/img5.jpg",
      "https://example.com/img6.jpg",
      "https://example.com/img7.jpg",
      "https://example.com/img8.jpg",
      "https://example.com/img9.jpg",
      "https://example.com/img10.jpg",
      "https://example.com/img11.jpg",
      "https://example.com/img12.jpg",
      "https://example.com/img13.jpg",
      "https://example.com/img14.jpg",
      "https://example.com/img15.jpg"
    ],
    "quality": "720"
  }'
```

---

## 4. Longform Rendering - With Videos

### Minimum example (1 audio, 1 video)

```bash
curl -X POST "$BASE_URL/api/v1/longform/render" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "audio_urls": [
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    ],
    "background_source": "videos",
    "background_urls": [
      "https://www.w3schools.com/html/mov_bbb.mp4"
    ],
    "quality": "720"
  }'
```

### With 3 audio files and 3 videos

```bash
curl -X POST "$BASE_URL/api/v1/longform/render" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "audio_urls": [
      "https://example.com/audio1.mp3",
      "https://example.com/audio2.mp3",
      "https://example.com/audio3.mp3"
    ],
    "background_source": "videos",
    "background_urls": [
      "https://example.com/background1.mp4",
      "https://example.com/background2.mp4",
      "https://example.com/background3.mp4"
    ],
    "quality": "1080"
  }'
```

**Guidance:**
- **Minimum:** 1 audio URL, 1 video URL
- **Maximum:** 30 audio URLs, 5 video URLs
- Background videos are **automatically muted**
- Videos will loop to match the total audio duration

### With 5 videos (maximum)

```bash
curl -X POST "$BASE_URL/api/v1/longform/render" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "audio_urls": [
      "https://example.com/audio1.mp3"
    ],
    "background_source": "videos",
    "background_urls": [
      "https://example.com/video1.mp4",
      "https://example.com/video2.mp4",
      "https://example.com/video3.mp4",
      "https://example.com/video4.mp4",
      "https://example.com/video5.mp4"
    ],
    "quality": "720"
  }'
```

---

## 5. Check Status

Replace `req_xxxxxxxxxx` with your actual request_id from the render response:

```bash
curl -X GET "$BASE_URL/api/v1/longform/status/req_xxxxxxxxxx" \
  -H "X-API-Key: $API_KEY"
```

---

## 6. Get Result

Only works when status is "completed":

```bash
curl -X GET "$BASE_URL/api/v1/longform/result/req_xxxxxxxxxx" \
  -H "X-API-Key: $API_KEY"
```

---

## 7. Complete Workflow Example

**Step 1: Submit job and capture request_id**

```bash
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/longform/render" \
  -H "X-API-Key: $API_KEY" \
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
  }')

REQUEST_ID=$(echo $RESPONSE | jq -r '.request_id')
echo "Request ID: $REQUEST_ID"
```

**Step 2: Poll for status**

```bash
while true; do
  STATUS=$(curl -s "$BASE_URL/api/v1/longform/status/$REQUEST_ID" \
    -H "X-API-Key: $API_KEY" | jq -r '.status')
  
  echo "Status: $STATUS ($(date))"
  
  if [ "$STATUS" = "completed" ] || [ "$STATUS" = "failed" ]; then
    break
  fi
  
  sleep 10
done
```

**Step 3: Get result**

```bash
curl -s "$BASE_URL/api/v1/longform/result/$REQUEST_ID" \
  -H "X-API-Key: $API_KEY" | jq
```

---

## 8. One-Liners

### Quick health check

```bash
curl -s http://localhost:8000/health
```

### Quick merge (compact)

```bash
curl -X POST "http://localhost:8000/api/v1/merge" -H "X-API-Key: YOUR_KEY" -H "Content-Type: application/json" -d '{"video_urls":["https://www.w3schools.com/html/mov_bbb.mp4","https://www.w3schools.com/html/movie.mp4"],"quality":"720","aspect_ratio":"16:9"}'
```

### Quick longform render (compact, images)

```bash
curl -X POST "http://localhost:8000/api/v1/longform/render" -H "X-API-Key: YOUR_KEY" -H "Content-Type: application/json" -d '{"audio_urls":["https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"],"background_source":"images","background_urls":["https://picsum.photos/1920/1080"],"quality":"720"}'
```

### Quick longform render (compact, videos)

```bash
curl -X POST "http://localhost:8000/api/v1/longform/render" -H "X-API-Key: YOUR_KEY" -H "Content-Type: application/json" -d '{"audio_urls":["https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"],"background_source":"videos","background_urls":["https://www.w3schools.com/html/mov_bbb.mp4"],"quality":"720"}'
```

---

## Testing Tips

1. **Use environment variables:** Set `BASE_URL` and `API_KEY` to avoid typing them repeatedly

2. **Use jq for pretty output:**
   ```bash
   curl ... | jq
   ```

3. **Save response to file:**
   ```bash
   curl ... > response.json
   ```

4. **Check HTTP status code:**
   ```bash
   curl -w "\nHTTP Status: %{http_code}\n" ...
   ```

5. **Verbose mode for debugging:**
   ```bash
   curl -v ...
   ```

---

## Key Constraints Summary

### Images Background Source
- **Audio URLs:** 1-30
- **Image URLs:** 1-15
- **Aspect Ratio:** 16:9 (fixed)
- **Quality:** 720p or 1080p
- **Max Duration:** 2 hours (audio length)

### Videos Background Source
- **Audio URLs:** 1-30
- **Video URLs:** 1-5
- **Aspect Ratio:** 16:9 (fixed)
- **Quality:** 720p or 1080p
- **Max Duration:** 2 hours (audio length)
- **Note:** Background videos are automatically muted

---

## Sample URLs for Testing

**Audio:**
- https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3

**Videos:**
- https://www.w3schools.com/html/mov_bbb.mp4
- https://www.w3schools.com/html/movie.mp4

**Images:**
- https://picsum.photos/1920/1080 (random)
- https://picsum.photos/id/237/1920/1080 (specific)
- https://via.placeholder.com/1920x1080

---

## Error Handling

**Check for errors:**
```bash
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/longform/render" ...)
ERROR=$(echo $RESPONSE | jq -r '.error // empty')

if [ ! -z "$ERROR" ]; then
  echo "Error: $ERROR"
  exit 1
fi
```

---

## See Also

- **Full API Documentation:** See `API-DOCUMENTATION.md`
- **Setup Guide:** See `SETUP.md`
- **Changelog:** See `CHANGELOG.md`
