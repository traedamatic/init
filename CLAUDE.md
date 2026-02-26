
Please extend this file with more project related content

## Coding Conventions

See [`code_guidelines.md`](./code_guidelines.md) for full coding standards. Key points:

- **TypeScript strict mode** is enabled — no `any`, prefer `unknown`
- **Path alias**: `@/*` maps to `./src/*`
- Prefer `const` over `let`, never `var`
- Use `async/await` over raw promise chains
- Named exports preferred over default exports
- Early returns to reduce nesting
- DRY, single responsibility, composition over inheritance

### Bun-Specific Conventions

- Use Bun APIs over Node.js equivalents where available: `Bun.serve()`, `Bun.build()`, `Bun.file()`, `Bun.glob()`
- Use Bun's built-in test runner (`bun test`) — no external test framework needed
- Hot reload in dev via `bun --hot` (not nodemon or similar)
- Environment variables for the client must be prefixed with `BUN_PUBLIC_*`
