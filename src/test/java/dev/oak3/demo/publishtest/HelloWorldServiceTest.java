package dev.oak3.demo.publishtest;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class HelloWorldServiceTest {
    private static HelloWorldService helloWorldService;

    @BeforeAll
    static void beforeAll() {
        helloWorldService = new HelloWorldService();
    }

    @Test
    void sayHelloWorld() {
        assertEquals("Hello, World", helloWorldService.sayHelloWorld());
    }

    @Test
    void sayHelloTo_You() {
        String to = "You";
        assertEquals(String.format("Hello, %s", to), helloWorldService.sayHelloTo(to));
    }
}