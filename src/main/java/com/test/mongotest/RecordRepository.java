package com.test.mongotest;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "costs", path = "costs", itemResourceRel = "cost")
public interface RecordRepository extends MongoRepository<Record, String> {

}
