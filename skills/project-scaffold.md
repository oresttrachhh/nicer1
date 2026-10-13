# project-scaffold

Опис
----

Цей Skill створює мінімальний Java-проєкт типу «Hello World» з базовою структурою каталогів, README і початковим `.gitignore`.

Він приймає два аргументи:
- `language` — мова проєкту (у цій версії: `java`)
- `project_name` — назва проєкту / папки, в якій буде створено шаблон

Після створення Skill перевіряє:
1. чи існує файл з точкою входу (`src/Main.java`),
2. чи команда запуску виконується успішно (`javac` + `java`),
3. чи README містить коректну інструкцію запуску.

Очікувана структура проєкту:

```text
<project_name>/
  README.md
  .gitignore
  src/
    Main.java
```

---

Приклад Bash-скрипта для Java

```bash
#!/usr/bin/env bash
set -euo pipefail

LANG="${1:-}"
PROJECT="${2:-}"

if [[ -z "$LANG" || -z "$PROJECT" ]]; then
  echo "Usage: $0 <language> <project_name>"
  exit 2
fi

if [[ "$LANG" != "java" ]]; then
  echo "This scaffold is configured for Java. Use: $0 java <project_name>"
  exit 3
fi

mkdir -p "$PROJECT"
cd "$PROJECT"

mkdir -p src

cat > README.md <<EOF
# $PROJECT

Minimal Java Hello World project.

## Structure

- src/Main.java — entry point
- .gitignore — ignores build output and temporary files

## Run

```bash
javac -d out src/Main.java && java -cp out Main
```
EOF

cat > .gitignore <<'EOF'
# Java build output
out/
*.class

# IDE files
.idea/
.vscode/

# OS files
.DS_Store
Thumbs.db
EOF

cat > src/Main.java <<'EOF'
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
EOF

if [[ ! -f "src/Main.java" ]]; then
  echo "Missing source file: src/Main.java"
  exit 4
fi

# Validate compile and run
javac -d out src/Main.java
if [[ $? -ne 0 ]]; then
  echo "Compilation failed. Check Java installation and source code."
  exit 5
fi

java -cp out Main
if [[ $? -ne 0 ]]; then
  echo "Runtime failed. Check generated class and JVM."
  exit 6
fi

echo "Project '$PROJECT' created successfully."
```

---

Критерії успіху
---------------

Skill вважається успішним, якщо:
- каталог проєкту було створено,
- файл `src/Main.java` існує,
- README містить інструкцію запуску,
- `.gitignore` створений,
- команда `javac -d out src/Main.java && java -cp out Main` завершується з кодом 0.

Приклад використання:

```bash
./project-scaffold.sh java my-java-app
```

Після запуску буде створено проєкт з мінімальним Java Hello World, готовий до розширення.
