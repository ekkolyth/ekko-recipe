# Testing Redis Cache for Next.js

This guide will help you verify that Redis is properly handling Next.js caching.

## Quick Test Steps

### 1. Start Redis and Development Server

```bash
make dev
```

### 2. Test the Cache Page

1. Open http://localhost:3000/test-cache
2. Note the timestamp and random number
3. Refresh the page multiple times
4. **Expected**: The timestamp and random number should stay the same (data is cached)
5. Click "Revalidate Cache" button
6. Refresh the page
7. **Expected**: New timestamp and random number (cache was cleared)

### 3. Test the API Route

```bash
# Call the API multiple times
curl http://localhost:3000/api/test-cache

# The response should be identical for 60 seconds
```

### 4. Inspect Redis Cache

```bash
# See all cache keys
make redis-keys

# Inspect a specific key (replace with actual key from redis-keys)
make redis-inspect KEY=nextjs:cache:APP_PAGE:/test-cache:...

# Get Redis statistics
make redis-stats
```

## Manual Redis Inspection

### Connect to Redis CLI

```bash
make redis-cli
```

### Useful Redis Commands

```redis
# List all cache keys
KEYS nextjs:cache:*

# List all tag keys
KEYS nextjs:tag:*

# Get a specific cache entry
GET nextjs:cache:APP_PAGE:/test-cache:...

# See all keys with pattern
SCAN 0 MATCH nextjs:cache:* COUNT 100

# Get key TTL (time to live)
TTL nextjs:cache:APP_PAGE:/test-cache:...

# Get Redis info
INFO stats

# Monitor Redis commands in real-time
MONITOR
```

## Verification Checklist

- [ ] Cache page shows same data on refresh (cached)
- [ ] Revalidate button clears cache (new data appears)
- [ ] API route returns same response for 60 seconds
- [ ] `make redis-keys` shows cache entries
- [ ] `make redis-stats` shows cache statistics
- [ ] Redis CLI shows `nextjs:cache:*` keys

## Expected Behavior

### When Caching Works:

1. **First request**: Data is fetched and stored in Redis
2. **Subsequent requests**: Data is served from Redis (faster, same data)
3. **After revalidate**: Cache is cleared, new data is fetched
4. **Redis keys**: You should see keys like:
   - `nextjs:cache:APP_PAGE:/test-cache:...`
   - `nextjs:cache:APP_ROUTE:/api/test-cache:...`
   - `nextjs:tag:test-cache`

### When Caching is NOT Working:

- Data changes on every refresh
- No keys in Redis with `nextjs:cache:*` pattern
- Redis stats show no cache hits

## Troubleshooting

### No cache keys found?

1. Check if Redis is running: `make redis-status`
2. Check Next.js logs for cache handler errors
3. Verify `next.config.ts` has `cacheHandler` configured
4. Check that `ioredis` is installed: `bun list ioredis`

### Cache not persisting?

1. Check Redis connection: `make redis-cli` then `PING`
2. Check environment variables: `echo $REDIS_URL`
3. Verify cache handler file exists: `ls apps/web/src/lib/cache-handler.js`

### Still seeing errors?

1. Clear Next.js cache: `make clean-next`
2. Restart dev server: `make dev`
3. Check Redis logs: `make redis-logs`

