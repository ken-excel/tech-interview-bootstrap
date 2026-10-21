import react from "@vitejs/plugin-react";
import { defineConfig } from "vitest/config";

// Dev server proxies API calls to the Rust starter (poc/rust-api, `cargo run`).
const API = "http://127.0.0.1:3000";

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      "/api": API,
      "/health": API,
    },
  },
  test: {
    environment: "node",
  },
});
