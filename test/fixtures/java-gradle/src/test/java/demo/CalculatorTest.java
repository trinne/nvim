package demo;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class CalculatorTest {
    private final Calculator calculator = new Calculator();

    @Test
    void addsTwoNumbers() {
        assertEquals(3, calculator.add(1, 2));
    }

    @Test
    void failing() {
        assertEquals(5, calculator.add(2, 2));
    }
}
