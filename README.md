This is a [Next.js](https://nextjs.org) monorepo using [Bun](https://bun.sh) as the package manager and [Redis](https://redis.io) for caching.

## Getting Started

### Prerequisites

- [Bun](https://bun.sh/docs/installation) installed
- Redis server running (or Redis URL configured)

### Installation

Install dependencies:

```bash
bun install
```

### Redis Configuration

The project uses `ioredis` (a Node.js Redis client) for Next.js caching.

#### Starting Redis with Docker

The easiest way to get Redis running is using the provided Makefile:

```bash
# Start Redis container
make redis-up

# Check Redis status
make redis-status

# View Redis logs
make redis-logs

# Stop Redis container
make redis-down
```

Or use Docker Compose directly:

```bash
docker-compose up -d redis
```

#### Environment Variables

Configure Redis by setting one of these environment variables:

- `REDIS_URL` (preferred)
- `VALKEY_URL`
- Defaults to `redis://localhost:6379` if neither is set

The Docker Compose setup uses `redis://localhost:6379` by default, so no configuration is needed if you're using the provided setup.

Example `.env.local` in `apps/web/` (optional, only if you need custom configuration):

```bash
REDIS_URL=redis://localhost:6379
# For TLS connections:
# REDIS_URL=rediss://localhost:6379
# For authenticated connections:
# REDIS_URL=redis://username:password@localhost:6379
```

### Development

Start Redis and run the development server:

```bash
# Recommended: Use Makefile (handles cleanup on Ctrl+C)
make dev

# Alternative: Manual start
make redis-up
bun dev
```

**Note:** The `make dev` command will:
- Automatically start Redis if it's not running
- Kill any existing Next.js processes on port 3000
- Clean up Redis container when you press Ctrl+C

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `apps/web/src/app/page.tsx`. The page auto-updates as you edit the file.

## Features

- **Bun**: Fast package manager and runtime
- **Redis Caching**: Custom cache handler using ioredis (Node.js Redis client)
- **Turbo**: Monorepo build system
- **Next.js**: React framework with App Router
- **Docker Compose**: Easy Redis setup with Docker

## Available Make Commands

```bash
make help          # Show all available commands
make redis-up      # Start Redis container
make redis-down    # Stop Redis container
make redis-restart # Restart Redis container
make redis-logs    # View Redis logs
make redis-cli     # Open Redis CLI
make redis-status  # Check Redis status
make redis-flush   # Flush all Redis data (WARNING: deletes all data)
make dev           # Start Redis and dev server (with cleanup on Ctrl+C)
make kill-next     # Kill all Next.js processes on port 3000
make stop-all      # Stop Redis and kill Next.js processes
make clean-next    # Clean Next.js build cache
make clean         # Clean up Docker volumes and containers
```

## Testing Redis Cache

To verify that Redis is handling Next.js caching, see [TESTING_REDIS_CACHE.md](./TESTING_REDIS_CACHE.md) for detailed instructions.

Quick test:
1. Visit http://localhost:3000/test-cache
2. Refresh multiple times - data should stay the same (cached)
3. Check Redis: `make redis-keys` to see cache entries
4. Get stats: `make redis-stats` to see cache statistics

## Troubleshooting

### "Cannot find module 'bun'" Error

If you see this error, it means Next.js is using a cached build. Clear the cache and restart:

```bash
make clean-next
bun dev
```

Or manually:
```bash
rm -rf apps/web/.next
bun dev
```

### Redis Cache Not Working

1. Check Redis is running: `make redis-status`
2. Check cache keys: `make redis-keys`
3. See [TESTING_REDIS_CACHE.md](./TESTING_REDIS_CACHE.md) for detailed testing steps

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
