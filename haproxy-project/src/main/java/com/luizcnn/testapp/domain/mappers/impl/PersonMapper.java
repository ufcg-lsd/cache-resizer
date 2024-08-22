package com.luizcnn.testapp.domain.mappers.impl;

import com.luizcnn.testapp.domain.entity.PersonEntity;
import com.luizcnn.testapp.domain.mappers.ModelEntityMapper;
import com.luizcnn.testapp.domain.models.Person;

public class PersonMapper implements ModelEntityMapper<Person, PersonEntity> {
    @Override
    public Person toModel(PersonEntity entity) {
        return Person
                .builder()
                .firstName(entity.getFirstName())
                .lastName(entity.getLastName())
                .gender(entity.getGender())
                .email(entity.getEmail())
                .country(entity.getCountry())
                .city(entity.getCity())
                .state(entity.getState())
                .cellPhone(entity.getCellPhone())
                .build();
    }

    @Override
    public PersonEntity toEntity(Person model) {
        return PersonEntity
                .builder()
                .firstName(model.getFirstName())
                .lastName(model.getLastName())
                .gender(model.getGender())
                .email(model.getEmail())
                .country(model.getCountry())
                .city(model.getCity())
                .state(model.getState())
                .cellPhone(model.getCellPhone())
                .build();
    }
}
