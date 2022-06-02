/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  async rewrites() {
    // When running Next.js via Node.js (e.g. `dev` mode), proxy API requests
    // to the Go server.
    return [
      {
        source: "/api/items",
        destination: "http://localhost:8080/api/items",
      },
      {
        source: "/api/items/:id",
        destination: "http://localhost:8080/api/items/:id",
      },
    ];
  },
}

module.exports = nextConfig
