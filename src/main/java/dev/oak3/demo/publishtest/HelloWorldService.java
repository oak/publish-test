package dev.oak3.demo.publishtest;

public class HelloWorldService {
    public String sayHelloWorld() {
        return sayHelloTo("World");
    }

    public String sayHelloTo(String name) {
        return String.format("Hello, %s", name);
    }
}
