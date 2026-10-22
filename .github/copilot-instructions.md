# Project Guidelines

## Build and Test

The runnable Maven sample is `HelloProject/`. The repository also contains the
prompts and skills that generate and validate this project shape.

Run commands from `HelloProject/`:

- Build and run manually:
  `javac -d target/classes src/main/java/Main.java`, then
  `java -cp target/classes Main`.
- Run the full Maven test suite: `mvn clean test`.
- Run one test class: `mvn -Dtest=MainTest test`.
- Run one test method: `mvn -Dtest=MainTest#mainPrintsHelloWorld test`.
- The CI-equivalent command is `mvn --batch-mode clean test`.

The Maven layout is `src/main/java` and `src/test/java`; JUnit 5 is a test
dependency and Surefire runs the tests. Build output belongs in `target/`.
There is no repository-wide lint command configured.

## Architecture

- The root `README.md` documents the Java 17, Maven, JUnit 5, and Copilot
  workflow.
- Root `.github/prompts/` is the user-facing command layer. `/init` orchestrates
  `git-init` → `create-project` → `create-build` → `create-actions` → `check`,
  stopping when a required stage fails.
- Root `.github/skills/` is the canonical implementation layer:
  `project-scaffold` creates the Maven source layout, `build-and-test` adds
  `pom.xml`/JUnit/test coverage, and `github-actions` creates the root CI
  workflow.
- [`.github/workflows/ci.yml`](workflows/ci.yml) runs Maven in
  `HelloProject/` on `push` and `pull_request` to `main`.
- `nicer1/docs/architecture.md` describes the conceptual
  planner/dispatcher/persistence pipeline. The `nicer1/` subtree contains
  older examples and an independent sample; prefer root prompts, root skills,
  and `HelloProject/` when they differ.

## Conventions

- Default to Java 17 unless the request explicitly establishes another
  compatible release.
- Keep application and test sources in the standard Maven directories; do not
  move them to the legacy `nicer1/HelloProject/src` layout.
- Before editing any existing file, read it and preserve user configuration.
  Changes should be idempotent: do not duplicate dependencies, plugins, tests,
  `.gitignore` entries, or workflows.
- The scaffolding/build/actions prompts are intentionally safety-oriented:
  validate paths and prerequisites, avoid overwriting user code, report the
  actual command and exit status, and distinguish missing tooling from project
  failures.
- `check` is read-only. It compares Git status before and after diagnostics and
  must not run formatters, generators, commits, pushes, resets, checkouts,
  cleanups, or deletions.
- The automation does not commit or push changes. Surface build, XML, YAML,
  dependency, and test failures instead of masking them or claiming success
  without verification.
- Treat `check` as read-only: record Git status before and after diagnostics,
  report missing required files as errors, and do not repair them
  automatically.
