import { NextResponse } from "next/server";
import { unstable_cache } from "next/cache";

// Test cached API route
export async function GET() {
  const getCachedData = unstable_cache(
    async () => {
      // Simulate expensive operation
      await new Promise((resolve) => setTimeout(resolve, 100));
      
      return {
        timestamp: new Date().toISOString(),
        random: Math.random(),
        message: "This API response is cached in Redis",
      };
    },
    ["test-api-cache"],
    {
      revalidate: 60, // Cache for 60 seconds
      tags: ["test-api-cache"],
    }
  );

  const data = await getCachedData();

  return NextResponse.json({
    ...data,
    cached: true,
    instructions: "Call this endpoint multiple times - the timestamp and random should stay the same for 60 seconds",
  });
}

