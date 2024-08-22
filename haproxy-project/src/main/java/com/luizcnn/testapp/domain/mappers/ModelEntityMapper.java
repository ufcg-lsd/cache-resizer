package com.luizcnn.testapp.domain.mappers;

public interface ModelEntityMapper<M, E> {

    M toModel(E entity);

    E toEntity(M model);

}
