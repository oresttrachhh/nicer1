# build-and-test

Опис
----

Цей Skill описує, як додати до Java-проєкту систему складання, тестову функцію та юніт-тест. Наведені приклади для Gradle (рекомендовано) та альтернативно для Maven. Також показано, як розбити на підкоманди: `build`, `test`, `clean`.

Підходи
-------
1. Локальний Gradle-проєкт у директорії HelloProject (рекомендовано). 
2. (Альтернатива) Maven-проєкт.

Зауваження про структуру
-----------------------
Gradle / Maven очікують стандартну структуру:

HelloProject/
  build.gradle (або pom.xml)
  settings.gradle
  src/
    main/java/...
    test/java/...

У нас зараз `HelloProject/src/Main.java`. Найпростіші варіанти:
- Перемістити `HelloProject/src/Main.java` → `HelloProject/src/main/java/Main.java` (рекомендовано).
- Або налаштувати Gradle sourceSets, щоб використовувати `src` як `main` — нижче є приклад конфігурації для цього.

Gradle (рекомендований)
----------------------
1) Файли для HelloProject (помістити в `HelloProject/`):

- build.gradle (Groovy DSL)

```groovy
plugins {
    id 'java'
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
}

test {
    useJUnitPlatform()
}

// Якщо ви хочете зберегти поточну нетипову структуру (файли в HelloProject/src),
// розкоментуйте наступний блок і Gradle використовуватиме src як main source dir:
// sourceSets {
//     main {
//         java.srcDirs = ['src']
//     }
//     test {
//         java.srcDirs = ['src-test']
//     }
// }
```

- settings.gradle

```groovy
rootProject.name = 'HelloProject'
```

2) Тест: додайте новий клас тестів у `HelloProject/src/test/java/` (після переміщення `Main.java` у src/main/java).

`HelloProject/src/test/java/HelloTest.java`:

```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class HelloTest {
    @Test
    void greetReturnsHelloWorld() {
        // Якщо ви додасте окремий клас, наприклад Hello.greet(), тест виглядатиме так:
        // assertEquals("Hello, World!", Hello.greet());

        // Тест на те, що Main.main() не кидає виключення під час запуску
        Main.main(new String[]{});
    }
}
```

Примітки: краще створити окремий клас `Hello` з методом `greet()` та тестувати його. Наприклад,

`HelloProject/src/main/java/Hello.java`:

```java
public class Hello {
    public static String greet() {
        return "Hello, World!";
    }
}
```

І тоді `Main.java`:

```java
public class Main {
    public static void main(String[] args) {
        System.out.println(Hello.greet());
    }
}
```

3) Команди (в каталозі `HelloProject`)
- ./gradlew build        — компіляція + тести
- ./gradlew test         — виконання тестів
- ./gradlew clean        — очищення артефактів

Примітка: бажано додати Gradle Wrapper (./gradlew). Щоб створити wrapper локально:
- gradle wrapper --gradle-version 8.6 (або інша версія)

Maven (альтернатива)
--------------------
Якщо ви віддаєте перевагу Maven, створіть `pom.xml` в `HelloProject/` з JUnit 5:

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" ...>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>HelloProject</artifactId>
  <version>0.1.0</version>
  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <junit.jupiter.version>5.10.0</junit.jupiter.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>${junit.jupiter.version}</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.0.0-M9</version>
      </plugin>
    </plugins>
  </build>
</project>
```

Команди для Maven (в каталозі `HelloProject`):
- mvn -T 1C clean test
- mvn -T 1C package

GitHub Actions (CI)
-------------------
Приклад workflow, який компілює і запускає тести (файл: `.github/workflows/build-test.yml`):

```yaml
name: Build and Test HelloProject
on:
  push:
    paths:
      - 'HelloProject/**'
  pull_request:
    paths:
      - 'HelloProject/**'
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - name: Build with Gradle
        working-directory: HelloProject
        run: |
          chmod +x gradlew || true
          ./gradlew clean build --no-daemon
```

Підкоманди та workflow
----------------------
Розділення на підкоманди у README або Makefile:

`HelloProject/Makefile`:

```makefile
.PHONY: build test clean

build:
	./gradlew build

test:
	./gradlew test

clean:
	./gradlew clean
```

Або Windows PowerShell скрипти/батники — за потреби можу додати.

Перевірка та валідація
----------------------
1. Перемістіть/адаптуйте файли у стандартну структуру або оновіть `build.gradle` під вашу структуру.
2. Додайте Gradle wrapper або використовуйте локальний gradle.
3. Виконайте локально `./gradlew test` або через Docker:

```bash
docker run --rm -v "$(pwd)":/work -w /work -u $(id -u):$(id -g) gradle:8.6-jdk17 ./gradlew -p HelloProject test
```

Що зробить цей Skill (покроково)
--------------------------------
1. Додати `build.gradle` та `settings.gradle` у HelloProject (або `pom.xml` при Maven).
2. Перенести або додати `src/main/java/Hello.java` та `src/test/java/HelloTest.java`.
3. Додати Gradle Wrapper (opційно) або в README інструкцію запуску команд.
4. Додати GitHub Actions workflow для автоматичного запуску збірки й тестів.

Файлові приклади (шаблони)
-------------------------
- `HelloProject/build.gradle` — див. вище
- `HelloProject/settings.gradle` — див. вище
- `HelloProject/src/main/java/Hello.java` — див. вище
- `HelloProject/src/main/java/Main.java` — (залишити або оновити)
- `HelloProject/src/test/java/HelloTest.java` — див. вище
- `.github/workflows/build-test.yml` — див. вище

Готовий до дій
--------------
Можу автоматично додати у репозиторій:
- файли Gradle (build.gradle, settings.gradle),
- приклад Hello.java і HelloTest.java,
- Makefile (опційно),
- GitHub Actions workflow.

Скажи, які файли хочеш, щоб я додав зараз (наприклад: "додай gradle + тести + workflow"), і я запушу їх у `oresttrachhh/nicer1`.