package demo

import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

class CalculatorTest {
    private val calculator = Calculator()

    @Test
    fun `adds two numbers`() {
        assertEquals(3, calculator.add(1, 2))
    }

    @Test
    fun failing() {
        assertEquals(5, calculator.add(2, 2))
    }

    @Nested
    inner class Negative {
        @Test
        fun `adds negative numbers`() {
            assertEquals(-3, calculator.add(-1, -2))
        }
    }
}
