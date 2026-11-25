package demo

// Stands in for a server: keeps working after startup, like a Spring Boot app handling requests
fun main() {
    val calculator = Calculator()
    repeat(30) { i ->
        println("$i + 2 = ${calculator.add(i, 2)}")
        Thread.sleep(1000)
    }
}
