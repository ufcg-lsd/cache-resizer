package com.luizcnn.testapp.domain.models;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Person {

    private String firstName;

    private String lastName;

    private String email;

    private String gender;

    private String country;

    private String state;

    private String city;

    private String cellPhone;

}
