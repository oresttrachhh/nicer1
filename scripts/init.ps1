[CmdletBinding()]
param([string]$ProjectPath = "HelloProject")

$ErrorActionPreference = "Stop"
$repositoryRoot = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$projectRoot = [IO.Path]::GetFullPath((Join-Path $repositoryRoot $ProjectPath))
$created = [Collections.Generic.List[string]]::new()
$skipped = [Collections.Generic.List[string]]::new()

function Join-Lines([string[]]$Lines) { [string]::Join([Environment]::NewLine, $Lines) }
function Assert-InRoot {
    $root = $repositoryRoot.TrimEnd('\') + '\'
    if ($projectRoot -eq $repositoryRoot -or -not $projectRoot.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Project path must remain inside the repository: $ProjectPath"
    }
}
function Ensure-Directory([string]$Path) {
    if (-not (Test-Path $Path)) { [IO.Directory]::CreateDirectory($Path) | Out-Null; $created.Add($Path) }
}
function Ensure-File([string]$Path, [string]$Content) {
    if (Test-Path $Path) { $skipped.Add($Path); return }
    Ensure-Directory (Split-Path -Parent $Path)
    [IO.File]::WriteAllText($Path, $Content, [Text.UTF8Encoding]::new($false))
    $created.Add($Path)
}
function Require([string]$Path) { if (-not (Test-Path $Path)) { throw "Required path is missing: $Path" } }
function Report([string]$Stage, [string]$Status, [string]$Message) {
    Write-Output "[$Stage] $Status`: $Message"
}

function Git-InitStage {
    $git = Join-Path $repositoryRoot ".git"
    $ignore = Join-Path $repositoryRoot ".gitignore"
    if (Test-Path $git) { Report "git-init" "done" "Repository already exists; git init skipped." }
    else {
        & git init $repositoryRoot
        if ($LASTEXITCODE -ne 0) { throw "git init failed with exit code $LASTEXITCODE." }
        Report "git-init" "done" "Repository initialized."
    }
    Ensure-File $ignore (Join-Lines @("# Java build output", "target/", "out/", "*.class", "", "# IDE files", ".idea/", ".vscode/", "*.iml", "", "# OS files", ".DS_Store", "Thumbs.db"))
    Require $ignore
}

function Create-ProjectStage {
    $main = Join-Path $projectRoot "src\main\java"
    $test = Join-Path $projectRoot "src\test\java"
    Ensure-Directory $main; Ensure-Directory $test
    Ensure-File (Join-Path $projectRoot "README.md") (Join-Lines @("# HelloProject", "", "Minimal Java Maven project.", "", "Run ``mvn clean test`` from this directory."))
    Ensure-File (Join-Path $projectRoot ".gitignore") (Join-Lines @("target/", "out/", "*.class", ".idea/", ".vscode/", "*.iml"))
    Ensure-File (Join-Path $main "Main.java") (Join-Lines @("public class Main {", "    public static void main(String[] args) {", "        System.out.println(""Hello, World!"");", "    }", "}"))
    Require (Join-Path $main "Main.java"); Require $test
    Report "create-project" "done" "Missing project files were created; existing files were skipped."
}

function Create-BuildStage {
    $pom = Join-Path $projectRoot "pom.xml"
    $test = Join-Path $projectRoot "src\test\java\MainTest.java"
    $pomText = Join-Lines @(
        "<?xml version=""1.0"" encoding=""UTF-8""?>",
        "<project xmlns=""http://maven.apache.org/POM/4.0.0""><modelVersion>4.0.0</modelVersion>",
        "<groupId>com.example</groupId><artifactId>hello-project</artifactId><version>1.0-SNAPSHOT</version>",
        "<properties><maven.compiler.release>17</maven.compiler.release><project.build.sourceEncoding>UTF-8</project.build.sourceEncoding><junit.jupiter.version>5.10.2</junit.jupiter.version></properties>",
        "<dependencies><dependency><groupId>org.junit.jupiter</groupId><artifactId>junit-jupiter</artifactId><version>${junit.jupiter.version}</version><scope>test</scope></dependency></dependencies>",
        "<build><plugins><plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-surefire-plugin</artifactId><version>3.2.5</version></plugin></plugins></build></project>"
    )
    $testText = Join-Lines @("import org.junit.jupiter.api.Test;", "import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;", "", "class MainTest {", "    @Test", "    void mainRunsWithoutException() {", "        assertDoesNotThrow(() -> Main.main(new String[0]));", "    }", "}")
    Ensure-File $pom $pomText; Ensure-File $test $testText
    Require $pom; Require $test
    $raw = Get-Content $pom -Raw
    if (([regex]::Matches($raw, "<artifactId>junit-jupiter</artifactId>")).Count -ne 1 -or ([regex]::Matches($raw, "maven-surefire-plugin")).Count -ne 1) { throw "Maven configuration is missing or duplicated." }
    Report "create-build" "done" "Maven/JUnit files prepared; Maven was not run."
}

function Create-ActionsStage {
    $workflow = Join-Path $repositoryRoot ".github\workflows\ci.yml"
    $path = $ProjectPath.Replace([string][char]92, "/").Trim("/")
    $text = Join-Lines @("name: Java Maven CI", "", "on:", "  push:", "    branches: [""main""]", "  pull_request:", "    branches: [""main""]", "", "jobs:", "  build:", "    runs-on: ubuntu-latest", "    defaults:", "      run:", "        working-directory: $path", "    steps:", "      - uses: actions/checkout@v4", "      - uses: actions/setup-java@v4", "        with:", "          distribution: temurin", "          java-version: ""17""", "          cache: maven", "      - run: mvn --batch-mode clean test")
    Ensure-File $workflow $text; Require $workflow
    $raw = Get-Content $workflow -Raw
    foreach ($item in @("push:", "pull_request:", "actions/checkout@v4", "actions/setup-java@v4", "cache: maven", "mvn --batch-mode clean test")) { if (-not $raw.Contains($item)) { throw "Workflow is missing: $item" } }
    Report "create-actions" "виконано" "CI workflow prepared; existing workflow was not overwritten."
}

function CheckStage {
    Require (Join-Path $projectRoot "pom.xml"); Require (Join-Path $projectRoot "src\main\java"); Require (Join-Path $projectRoot "src\test\java")
    Require (Join-Path $projectRoot ".gitignore"); Require (Join-Path $projectRoot "README.md"); Require (Join-Path $repositoryRoot ".github\workflows\ci.yml")
    Report "check" "done" "Read-only checks completed."
}

try {
    Assert-InRoot
    Write-Output "Copilot prompt files are not executed by PowerShell; equivalent local operations are used."
    Write-Output "Maven is not run without explicit user permission."
    Git-InitStage; Create-ProjectStage; Create-BuildStage; Create-ActionsStage; CheckStage
    Write-Output "Init completed successfully. Created: $($created.Count); skipped: $($skipped.Count)."
    exit 0
}
catch {
    Report "init" "error" $_.Exception.Message
    Write-Error "Init stopped at the first error."
    exit 1
}
