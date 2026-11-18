plugins {
    id("java")
}

group = "ru.vernydrug"
version = "1.0-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(platform("org.junit:junit-bom:6.0.0"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    testImplementation("io.rest-assured:rest-assured:5.5.6")
}

tasks.test {
    useJUnitPlatform()
    systemProperty(
        "baseUrl",
        System.getProperty("baseUrl") ?: "http://localhost:80/shelter-test/hs/shelter"
    )
    testLogging {
        events("passed", "failed", "skipped")
    }
}