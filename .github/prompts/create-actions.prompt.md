---
description: "Створити CI workflow GitHub Actions для Java та Maven"
name: "Create Actions"
argument-hint: "Необов'язкова версія Java для CI"
agent: "agent"
---

Використай skill [github-actions](../skills/github-actions/SKILL.md) для `create-actions`.

## Передумови
- Перевір `pom.xml` і всі файли `.github/workflows`.
- Перед зміною прочитай наявний `ci.yml`, якщо він є.

## Дії
1. Не створюй дублікати workflow.
2. Створи `.github/workflows/ci.yml` з `push` і `pull_request`.
3. Додай checkout, setup-java з Maven cache та `mvn --batch-mode clean test`.

## Очікувані файли
`.github/workflows/ci.yml` з одним CI job і необхідними кроками.

## Перевірки
Перевір YAML, тригери, setup Java, Maven cache і test command; за наявності інструментів виконай Maven-тести.

## Помилки та повторний запуск
Повідомляй невалідний YAML або дублікати. Не перезаписуй наявний workflow без дозволу. Повторний запуск ідемпотентний.
