package ru.vernydrug;

import io.restassured.http.ContentType;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import java.util.Map;
import java.util.Set;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.matchesPattern;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.jupiter.api.Assertions.assertEquals;

@DisplayName("API приюта: карточка питомца")
class ShelterApiTest extends BaseApiTest {

    @Test
    @DisplayName("POST на карточку → 405: метод не поддерживается")
    void postToPetReturns405() {
        given(spec)
                .contentType(ContentType.JSON)
                .body("{}")
                .when()
                .post("/animals/{code}", "000000001")
                .then()
                .statusCode(405);
    }

    @Test
    @DisplayName("Существующий питомец → 200 и карточка без лишних полей")
    void existingPetReturnsCard() {
        Map<String, Object> card =
                given(spec)
                        .when()
                        .get("/animals/{code}", "000000001")
                        .then()
                        .statusCode(200)
                        .contentType(ContentType.JSON)
                        .body("code", equalTo("000000001"))
                        .body("name", equalTo("Федя"))
                        .body("species", equalTo("Собаки"))
                        .body("shelter", nullValue())
                        .body("birthDate", matchesPattern("\\d{4}-\\d{2}-\\d{2}"))
                        .body("arrivalDate", matchesPattern("\\d{4}-\\d{2}-\\d{2}"))
                        .extract()
                        .jsonPath().getMap("$");

        assertEquals(
                Set.of("code", "name", "species", "breed", "sex", "birthDate",
                        "color", "status", "shelter", "arrivalDate"),
                card.keySet(),
                "Состав полей карточки изменился");
    }

    @Test
    @DisplayName("Несуществующий код → 404 и JSON с ошибкой")
    void unknownPetReturns404WithError() {
        given(spec)
                .when()
                .get("/animals/{code}", "999999999")
                .then()
                .statusCode(404)
                .contentType(ContentType.JSON)
                .body("error", containsString("999999999"));
    }
}
