// A tiny long-running process for attach debugging: node --inspect src/server.ts
import { sum } from "./sum.ts"

setInterval(() => {
  const value = sum(1, 2)
  console.log("tick", value)
}, 1000)
