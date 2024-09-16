package com.luizcnn.testapp.domain.service;

import com.luizcnn.testapp.dataprovider.client.RandomPersonClient;
import com.luizcnn.testapp.dataprovider.dao.impl.PersonJpaRepository;
import com.luizcnn.testapp.domain.entity.PersonEntity;
import com.luizcnn.testapp.domain.mappers.impl.PersonMapper;
import com.luizcnn.testapp.domain.models.Person;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class PersonService {

    private final RandomPersonClient randomPersonClient;
    private final PersonJpaRepository personJpaRepository;

    public PersonEntity findPersonById(Long id) {
        return personJpaRepository
                .findById(id)
                .orElse(null);
    }

    public void createPersonsFromApi(int quantity) {
        final var personsModel = randomPersonClient.getPersons(quantity)
                .getResults()
                .stream()
                .map(it -> Person.builder()
                        .firstName(it.getName().getFirst())
                        .lastName(it.getName().getLast())
                        .gender(it.getGender())
                        .country(it.getLocation().getCountry())
                        .city(it.getLocation().getCity())
                        .state(it.getLocation().getState())
                        .email(it.getEmail())
                        .cellPhone(it.getPhone())
                        .build()
                ).toList();

        personsModel.forEach(it -> personJpaRepository.save(new PersonMapper().toEntity(it)));
    }

}
