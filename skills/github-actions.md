# github-actions

Опис
----

Skill "github-actions" описує створення CI workflow у файлі `.github/workflows/ci.yml`, що виконує збірку та тести Java-проєкту на матриці ОС (windows-latest, ubuntu-latest, macos-latest). Workflow не містить логіки збірки безпосередньо — він лише викликає скрипти збірки `ci.sh` (для Unix-подібних ОС) і `ci.bat` (для Windows). Ці скрипти повинні бути частиною репозиторію й у собі містити команди для складання, запуску тестів та генерації артефактів.

Цілі
-----
- Уніфікувати CI для трьох ОС у одному workflow з матрицею.
- Забезпечити, щоб в CI логіку збірки та запуск тестів містили зовнішні скрипти (`ci.sh` / `ci.bat`).
- Повернути ясний зрозумілий статус job (успіх/помилка) та зберегти артефакти (артефакти збірки, звіти тестів).

Структура файлу
---------------
- `.github/workflows/ci.yml` — workflow який:
  - виконує checkout
  - налаштовує JDK (для Java)
  - виконує `ci.sh` або `ci.bat` залежно від ОС
  - зберігає артефакти (опціонально) і публікує результати тестів

Приклад `.github/workflows/ci.yml`
----------------------------------

```yaml
name: CI

on:
  push:
    branches: ["main", "master"]
  pull_request:
    branches: ["main", "master"]
  workflow_dispatch:

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        # при потребі можна додати matrix.java-version
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Make CI scripts executable (Unix)
        if: runner.os != 'Windows'
        run: |
          chmod +x ./.github/ci.sh || true

      - name: Run CI script (Linux/macOS)
        if: runner.os != 'Windows'
        run: |
          set -e
          ./.github/ci.sh

      - name: Run CI script (Windows)
        if: runner.os == 'Windows'
        shell: cmd
        run: |
          .\.github\ci.bat

      - name: Upload build artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts-${{ matrix.os }}
          path: |
            HelloProject/out/**
            HelloProject/build/**
            HelloProject/target/**

      - name: Upload test reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-reports-${{ matrix.os }}
          path: |
            HelloProject/build/test-results/**
            HelloProject/build/reports/**
            HelloProject/target/surefire-reports/**
```

Примітки:
- Workflow припускає, що скрипти знаходяться в `.github/ci.sh` і `.github/ci.bat`.
- Скрипти повинні повертати код 0 при успішній збірці/тестах, і ненульовий при помилках — це забезпечить коректний статус GitHub job.
- `actions/upload-artifact` збирає артефакти для подальшого аналізу у випадку помилок.

Приклади скриптів для репозиторію
---------------------------------

.example: `.github/ci.sh` (Unix: Linux/macOS)

```bash
#!/usr/bin/env bash
set -euo pipefail

# Перейти до проектної директориї
cd HelloProject

# Якщо використовуєте Gradle Wrapper, використовуйте ./gradlew
if [[ -x "./gradlew" ]]; then
  ./gradlew clean test
else
  # Якщо wrapper відсутній, намагаємось використати локальний gradle
  gradle --no-daemon clean test
fi

# Вивід arifacts/звітів розміщено у build/ або out/
```

.example: `.github/ci.bat` (Windows)

```bat
@echo off
setlocal enabledelayedexpansion

cd HelloProject

REM Якщо є gradlew.bat — використайте його
if exist gradlew.bat (
  gradlew.bat clean test
) else (
  gradle --no-daemon clean test
)

endlocal
```

Що саме мають робити ці скрипти
--------------------------------
- Виконати збірку (команда build/package у вашій системі складання).
- Запустити юніт-тести та згенерувати звіти (наприклад: Gradle generetes build/test-results та build/reports).
- На завершення повернути код 0 при успіху, ненульовий при помилці.
- За бажанням: зберегти додаткові артефакти у папці `out/` або іншій директорії, яка відома workflow.

Приклад вхідних даних для skill
-------------------------------
- Розташування проекту: `HelloProject/`
- Система збірки: `gradle` (можна адаптувати під maven)
- Наявність скриптів: `.github/ci.sh` і `.github/ci.bat` (або згідні з іншими назвами)

Очікуваний результат
--------------------
- У репозиторії з'являється `.github/workflows/ci.yml`.
- При пуші в GitHub запуститься workflow на трьох ОС, кожен job:
  - виконає `checkout`, `setup-java`, викличе відповідний скрипт,
  - завантажить артефакти та звіти.
- У GitHub UI буде чітко видно статуси кожного job (green/red) і доступ до артефактів.

Перевірки (checks)
------------------
1. CI виконується при push/pull-request або вручну (workflow_dispatch).
2. Скрипти повертають код 0 при успіху. Якщо скрипт завершився з ненульовим кодом — job позначається як failed.
3. У розділі Artifacts з'являються архіви `build-artifacts-<os>` і `test-reports-<os>`.
4. Тести повинні генерувати тести-звіти у стандартних шляхах (Gradle: build/test-results або build/reports).

Типові сценарії помилок та виправлення
--------------------------------------
1) Скрипт не знайдено або не має права на виконання (Unix)
   - Симптом: job падає з помилкою "No such file or directory" або "permission denied".
   - Виправлення: додати файл `.github/ci.sh`/`.github/ci.bat` у репозиторій; додати `chmod +x .github/ci.sh` у workflow або встановити права локально.

2) Відсутній Gradle Wrapper / gradle на runner
   - Симптом: `gradle: not found` або схожа помилка.
   - Виправлення: додати Gradle Wrapper у HelloProject (запустити `gradle wrapper --gradle-version <x>` локально і закомітити файли), або змінити скрипт щоб використовувати Docker або інший підхід.

3) Неправильна структура каталогів
   - Симптом: немає класів для компіляції, помилки `package/class not found`.
   - Виправлення: переконатися, що проект має стандартну структуру `src/main/java` і `src/test/java`, або налаштувати sourceSets у `build.gradle`.

4) Непідтримувана версія JDK
   - Симптом: помилки компіляції через несумісні можливості мови.
   - Виправлення: змінити `actions/setup-java` java-version на потрібну або адаптувати код під JDK 17.

5) Тести падають на одній ОС, але успішні на іншій
   - Симптом: матрична збірка має різний статус для різних ОС.
   - Виправлення: перевірити OS-specific шляхи/роздільники, кодування, чутливість до регістру або налаштування локалі. Можна збирати додаткові логи та артефакти для діагностики.

Приклад типового workflow-run перевірки
--------------------------------------
1. Push → запускається CI.
2. GitHub Actions запускає 3 job (ubuntu, macos, windows).
3. Кожен job виконує checkout → setup-java → виклик скрипта → завантаження артефактів.
4. Якщо всі job повернули 0 — зелений статус; інакше — видно який job упав, та можна завантажити артефакти та логи для аналізу.

Готові шаблони (файли для додавання у репозиторій)
-------------------------------------------------
1) `.github/workflows/ci.yml` — наведено вище
2) `.github/ci.sh` — приклад скрипта (Unix)
3) `.github/ci.bat` — приклад скрипта (Windows)

Що я зроблю зараз
------------------
Я можу:
- додати файл `skills/github-actions.md` у репозиторій (зараз це роблю),
- за твоїм дозволом додати також сам `.github/workflows/ci.yml` і прикладні скрипти `.github/ci.sh` та `.github/ci.bat` у репозиторій.

Скажи, чи додавати workflow і скрипти зараз. Якщо так — я додам їх і потім підкажу, як перевірити виконання в GitHub Actions.
