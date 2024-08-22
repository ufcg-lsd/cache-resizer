package com.luizcnn.testapp.dataprovider.client;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.luizcnn.testapp.domain.models.RandomPersonApiResponse;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.springframework.stereotype.Component;

import static java.util.Objects.nonNull;

@Component
public class RandomPersonClientImpl implements RandomPersonClient {

    private static final String BASE_URL = "https://randomuser.me";
    private static final String PATH = "/api";
    private final OkHttpClient client = new OkHttpClient();

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public RandomPersonApiResponse getPersons(int quantity) {
        final var req = new Request.Builder()
                .url(BASE_URL + PATH + "?results=" + quantity)
                .build();
        try (Response res = client.newCall(req).execute()) {
            final var resBody = res.body();
            if(nonNull(resBody)) {
                return mapper.readValue(resBody.string(), new TypeReference<>() {});
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return null;
    }
}
