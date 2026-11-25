plugins {
    kotlin("jvm") version "2.2.21"
    application
}

application { mainClass = "demo.MainKt" }

repositories { mavenCentral() }

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.13.4")
    testImplementation("io.kotest:kotest-runner-junit5:6.0.4")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

kotlin { jvmToolchain(21) }

tasks.test { useJUnitPlatform() }
