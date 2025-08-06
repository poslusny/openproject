# AGENTS.md

## Build, Lint, and Test Commands
- **Backend (Ruby):**
  - Run all tests: `bundle exec rspec`
  - Run a single test: `bundle exec rspec path/to/file_spec.rb[:line]`
  - Lint: `bundle exec rubocop`
- **Frontend (Angular/TypeScript):**
  - Install deps: `cd frontend && npm install`
  - Run all tests: `cd frontend && npm test`
  - Run a single test: `cd frontend && ng test --include src/app/path/to/file.spec.ts`
  - Lint: `cd frontend && npm run lint:eslint`
  - Format: `cd frontend && npm run lint:fix`

## Code Style Guidelines
- **General:**
  - Indent with 2 spaces, LF line endings, max line length 120 (see .editorconfig).
- **TypeScript/Angular:**
  - Use single quotes, semicolons, and OnPush change detection for new components.
  - Component selectors: kebab-case with `op`/`opce` prefix; directive selectors: camelCase.
  - Allow short-circuit eval, no unused vars (prefix with `_` to ignore), allow empty interfaces for HAL resources.
  - Imports: no forced order, allow absolute paths, sort members.
  - Error handling: handle all promises, allow `void` for unhandled.
- **Ruby:**
  - Target Ruby 3.4, double quotes for strings, max line length 130.
  - Naming: avoid `is_` prefix, allow snake_case and camelCase as needed.
  - Many Rubocop cops are relaxed; see `.rubocop.yml` for specifics.
  - RSpec: avoid `fit`, focus on clear, maintainable specs.

For more, see `.eslintrc.js`, `.editorconfig`, `.rubocop.yml`, and CONTRIBUTING.md.