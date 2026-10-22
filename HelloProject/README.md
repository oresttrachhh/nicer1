# HelloProject

Minimal Java project scaffold.

## Structure

- `src/main/java/Main.java` - application entry point
- `src/test/java/` - test sources added by the build step
- `.gitignore` - ignored build and IDE files

## Build and test

```text
mvn clean test
```

Run one test class with:

```text
mvn -Dtest=MainTest test
```

## Run manually

```text
javac -d target/classes src/main/java/Main.java
java -cp target/classes Main
```
