package demo

import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe

class CalculatorSpec : FunSpec({
    test("adds with kotest") {
        Calculator().add(2, 3) shouldBe 5
    }
})
