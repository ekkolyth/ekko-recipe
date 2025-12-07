import { revalidateTag, unstable_cache } from "next/cache";

// Force dynamic rendering to test caching
export const dynamic = "force-dynamic";

async function getCachedData() {
  // Simulate an expensive operation
  const timestamp = new Date().toISOString();
  const random = Math.random();
  
  return {
    timestamp,
    random,
    message: "This data should be cached in Redis",
  };
}

export default async function TestCachePage() {
  // Use unstable_cache to cache the data in Redis
  const data = await unstable_cache(
    getCachedData,
    ["test-cache-page"],
    {
      revalidate: 3600, // Cache for 1 hour
      tags: ["test-cache"],
    }
  )();

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold mb-4">Redis Cache Test</h1>
      
      <div className="space-y-4">
        <div className="bg-gray-100 dark:bg-gray-800 p-4 rounded">
          <h2 className="text-xl font-semibold mb-2">Current Data:</h2>
          <pre className="bg-black text-green-400 p-4 rounded overflow-auto">
            {JSON.stringify(data, null, 2)}
          </pre>
        </div>

        <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded">
          <p className="mb-2">
            <strong>How to test:</strong>
          </p>
          <ol className="list-decimal list-inside space-y-1">
            <li>Refresh this page - the timestamp and random number should stay the same (cached)</li>
            <li>Wait a few seconds and refresh - it should still be cached</li>
            <li>Check Redis to see the cached data (see commands below)</li>
            <li>Use the revalidate button below to clear the cache</li>
          </ol>
        </div>

        <form action={async () => {
          "use server";
          revalidateTag("test-cache");
        }}>
          <button
            type="submit"
            className="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded"
          >
            Revalidate Cache (Clear)
          </button>
        </form>
      </div>
    </div>
  );
}

