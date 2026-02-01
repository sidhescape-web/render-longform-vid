# Async / Job-Based Merge (Future)

When you want to avoid timeouts for long merges, you can switch to an **async job flow**: the client gets a `task_id` immediately, then polls for status and fetches the result when done. This doc describes the flow and what you need (including storage) so it works reliably.

---

## 1. The flow (what you described)

1. **POST** `/api/v1/merge` with the same body (video_urls, quality, aspect_ratio)  
   → Response: `{ "task_id": "abc-123", "message": "Merge started" }`  
   → Request returns right away (no long wait).

2. **GET** `/api/v1/merge/{task_id}/status`  
   → Response: `{ "status": "pending" | "processing" | "completed" | "failed", "message": "..." }`  
   → Client polls this until `status` is `completed` or `failed`.

3. **GET** `/api/v1/merge/{task_id}/result` (when status is `completed`)  
   → Response: same as current sync API: `{ "success": true, "merged_url": "...", "duration_seconds": ..., "processing_time": ..., "clips_merged": ... }`  
   → If status is `failed`, this can return an error or a `reason` field.

Yes, this will work. The only requirement is that **something** (in-memory store or a database) keeps the mapping: `task_id → status + result (or error)`.

---

## 2. Do you need a database?

You need **somewhere to store job state and results** so that:

- The status endpoint can return current status for a given `task_id`.
- The result endpoint can return the merged URL (and metadata) when the job is done.
- Optionally: jobs survive server restarts and work across multiple instances.

| Option | Storage | Survives restart? | Multiple instances? | Best for |
|--------|--------|--------------------|----------------------|----------|
| **In-memory (dict)** | Python dict in the app | No | No | Quick prototype, single instance |
| **Redis** | Key-value store | Yes (if Redis is persistent) | Yes | Production, job queues (e.g. Celery) |
| **PostgreSQL / SQLite** | Table: task_id, status, result_json, created_at | Yes | Yes | Production if you already have a DB |

- **Minimal / prototype:** Use an **in-memory dict**. No database, no new services. Jobs are lost on deploy/restart and only work with one app instance. Good to implement the flow and test the API.
- **Production / “for real”:** Use a **database** (e.g. PostgreSQL on Railway) or **Redis**. Store at least: `task_id`, `status`, `result` (or error), `created_at`. Then the status and result endpoints read from this store, and jobs survive restarts and work across replicas.

So: **you don’t strictly need a database for a first version** (in-memory is enough to implement and try the flow), but **for a robust, production-ready setup you will want a database (or Redis)**.

---

## 3. How it fits together

- **POST /api/v1/merge**  
  - Generate `task_id` (e.g. UUID).  
  - Store initial record: `task_id → { status: "pending" }` (in memory or DB).  
  - Start the merge in the **background** (see below).  
  - Return `{ "task_id": "..." }` immediately.

- **Background worker**  
  - Updates status to `"processing"`.  
  - Runs the same steps as today: download → ffprobe → merge (FFmpeg) → upload.  
  - On success: update store to `status: "completed"`, save `merged_url`, `duration_seconds`, etc.  
  - On failure: update to `status: "failed"`, save error message.

- **GET .../status**  
  - Look up `task_id` in your store; return `{ "status": "...", "message": "..." }`.

- **GET .../result**  
  - Look up `task_id`; if `completed`, return the same JSON as the current sync success response; if `failed`, return error info.

So yes: **when you implement this, you will need either an in-memory store (for a quick version) or a database/Redis (for a version that survives restarts and scales).**

---

## 4. Background execution options

You have to run the merge **in the background** so POST returns right away:

| Method | Pros | Cons |
|--------|------|------|
| **FastAPI `BackgroundTasks`** | No extra services, easy to add | Runs in same process; if the process dies, job is lost. Single instance. |
| **Thread pool** | Same as above, a bit more control | Same as above. |
| **Celery + Redis** | Persistent queue, retries, multiple workers | Need Redis (or RabbitMQ) and a separate worker process (e.g. on Railway). |

For a first async version: **BackgroundTasks + in-memory dict** is enough to implement the flow and see that it works. When you’re ready to make it robust and avoid losing jobs on restart, add a **database (or Redis)** and store `task_id → status/result` there; the endpoints stay the same, only the storage layer changes.

---

## 5. Summary

- **Flow:** POST → `task_id` → poll status → when `completed`, GET result. **Yes, it will work.**
- **Storage:** For a quick version, an **in-memory dict** is enough. For production, you’ll want a **database (or Redis)** so jobs survive restarts and work across instances.
- **When you implement it:** Start with in-memory + BackgroundTasks; later add a DB (or Redis) and keep the same API (status + result endpoints).

If you want, the next step can be a short “API contract” section (exact request/response shapes for POST, GET status, GET result) so you can implement it without changing the design later.
