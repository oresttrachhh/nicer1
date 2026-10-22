# Java Maven JUnit 5 Agent System

Система GitHub Copilot Agent Skills і prompt-команд для варіанта №5:
**Java, Maven, JUnit 5**. Вона описує безпечне створення проєкту, Maven-збірку,
автоматизовані тести, GitHub Actions CI та read-only перевірки.

## Технології

- Java 17 (типова сумісна версія, якщо інше не погоджено)
- Maven
- JUnit 5
- GitHub Actions
- GitHub Copilot у VS Code

## Prompt-команди

У VS Code відкрийте Chat і введіть `/`, щоб вибрати:

1. `/git-init` — перевірити/ініціалізувати Git і впорядкувати `.gitignore`.
2. `/create-project` — створити мінімальну Maven-структуру Java.
3. `/create-build` — налаштувати Maven, JUnit 5, тест і виконати `mvn clean test`.
4. `/create-actions` — створити `.github/workflows/ci.yml`.
5. `/check` — виконати повну перевірку без змін.
6. `/init` — послідовно виконати всі п'ять етапів і зупинитися при помилці.

Приклади:

```text
/git-init
/create-project Назва: HelloMaven
/create-build Java: 17
/create-actions
/check
/init Назва: HelloMaven
```

## Skills

- `.github/skills/project-scaffold/SKILL.md` — початковий Java-проєкт.
- `.github/skills/build-and-test/SKILL.md` — Maven і JUnit 5.
- `.github/skills/github-actions/SKILL.md` — CI workflow.

## Структура каталогів

```text
.github/
  prompts/
    git-init.prompt.md
    create-project.prompt.md
    create-build.prompt.md
    create-actions.prompt.md
    check.prompt.md
    init.prompt.md
  skills/
    project-scaffold/SKILL.md
    build-and-test/SKILL.md
    github-actions/SKILL.md
  workflows/
    ci.yml                 # створюється create-actions
src/
  main/java/
  test/java/
pom.xml                   # створюється create-build
README.md
.gitignore
```

## Безпечні правила

Команди перевіряють наявні файли перед зміною, не перезаписують користувацький
код без дозволу, не створюють дублікати залежностей, `.gitignore` або workflow.
Автоматичні commit, push, видалення та небезпечні Git-команди не виконуються.
