---
description: "Налаштувати Maven і JUnit 5 та виконати автоматизовані тести"
name: "Create Build"
argument-hint: "Необов'язкові groupId, artifactId або Java release"
agent: "agent"
---

Використай skill [build-and-test](../skills/build-and-test/SKILL.md) для `create-build`.

## Передумови
- Перевір структуру Java-проєкту та прочитай наявний `pom.xml`.
- Узгодь Java release; типовий сумісний варіант — 17.

## Дії
1. Створи або обережно онови `pom.xml`.
2. Додай JUnit 5 і сумісний Surefire без дублювання.
3. Створи щонайменше один автоматизований тест без заміни наявних тестів.
4. Запусти `mvn clean test`.

## Очікувані файли
`pom.xml` і щонайменше один `*Test.java` у `src/test/java`.

## Перевірки
Перевір XML, залежності та фактичний код завершення `mvn clean test`.

## Помилки та повторний запуск
Повідомляй Maven/JDK/XML/test помилки окремо. Не обходь падіння тесту. Повторний запуск не дублює dependency, plugin або тест.
