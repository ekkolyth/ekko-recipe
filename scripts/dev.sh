#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    
    # Kill any running Next.js processes on port 3000
    PORT_PIDS=$(lsof -ti:3000 2>/dev/null || true)
    if [ -n "$PORT_PIDS" ]; then
        echo -e "${YELLOW}Stopping Next.js processes on port 3000...${NC}"
        echo "$PORT_PIDS" | xargs kill -9 2>/dev/null || true
    fi
    
    # Stop Redis container if we started it
    if [ "$REDIS_STARTED" = "true" ]; then
        echo -e "${YELLOW}Stopping Redis container...${NC}"
        docker-compose stop redis 2>/dev/null || true
    fi
    
    echo -e "${GREEN}Cleanup complete${NC}"
    exit 0
}

# Trap signals to cleanup
trap cleanup SIGINT SIGTERM EXIT

# Check if Redis is running
if ! docker-compose ps redis | grep -q "Up"; then
    echo -e "${GREEN}Starting Redis container...${NC}"
    docker-compose up -d redis
    REDIS_STARTED="true"
    
    # Wait for Redis to be ready
    echo -e "${YELLOW}Waiting for Redis to be ready...${NC}"
    for i in {1..30}; do
        if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
            echo -e "${GREEN}Redis is ready!${NC}"
            break
        fi
        sleep 1
    done
else
    echo -e "${GREEN}Redis is already running${NC}"
    REDIS_STARTED="false"
fi

# Kill any existing Next.js processes on port 3000
PORT_PIDS=$(lsof -ti:3000 2>/dev/null || true)
if [ -n "$PORT_PIDS" ]; then
    echo -e "${YELLOW}Killing existing processes on port 3000...${NC}"
    echo "$PORT_PIDS" | xargs kill -9 2>/dev/null || true
    sleep 1
fi

# Start the development server
echo -e "${GREEN}Starting development server...${NC}"
bun dev

