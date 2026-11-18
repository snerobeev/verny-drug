package ru.vernydrug;

import io.restassured.http.ContentType;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.containsString;

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
