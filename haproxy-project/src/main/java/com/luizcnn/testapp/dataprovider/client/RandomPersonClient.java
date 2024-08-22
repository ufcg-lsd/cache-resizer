package com.luizcnn.testapp.dataprovider.client;

import com.luizcnn.testapp.domain.models.RandomPersonApiResponse;


public interface RandomPersonClient {

    RandomPersonApiResponse getPersons(int quantity);

}
