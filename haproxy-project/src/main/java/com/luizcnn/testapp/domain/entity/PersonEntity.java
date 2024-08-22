package com.luizcnn.testapp.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PersonEntity {

    private Long id;

    private String firstName;

    private String lastName;

    private String email;

    private String gender;

    private String country;

    private String state;

    private String city;

    private String cellPhone;

}
