package com.luizcnn.testapp.dataprovider.dao.impl;

import com.luizcnn.testapp.domain.entity.PersonEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PersonJpaRepository extends JpaRepository<PersonEntity, Long> {
}
