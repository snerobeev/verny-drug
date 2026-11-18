package ru.vernydrug;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;
import org.junit.jupiter.api.BeforeAll;

abstract class BaseApiTest {

    protected static RequestSpecification spec;

    @BeforeAll
    static void setUpSpec() {
        String baseUrl = System.getProperty("baseUrl");
        if (baseUrl == null || baseUrl.isBlank()) {
            throw new IllegalStateException(
                    "Не задан baseUrl: запускайте тесты через Gradle или передайте -DbaseUrl=...");
        }
        spec = new RequestSpecBuilder()
                .setBaseUri(baseUrl)
                .setAccept(ContentType.JSON)
                .build();
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();
    }
}
