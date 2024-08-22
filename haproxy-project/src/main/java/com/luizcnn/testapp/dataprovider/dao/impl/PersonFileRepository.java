package com.luizcnn.testapp.dataprovider.dao.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.luizcnn.testapp.domain.entity.PersonEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.io.*;

@Repository
@RequiredArgsConstructor
public class PersonFileRepository {

    private static final String DB_PATH = System.getProperty("user.dir") + "/db/db.txt";
    private static final String PERSON_INDEX_PATH = System.getProperty("user.dir") + "/db/person.index";

    private final ObjectMapper mapper = new ObjectMapper();

    public PersonEntity findPersonById(long id) {
        try (BufferedReader reader = new BufferedReader(new FileReader(DB_PATH))) {
            String line;
            int currentLine = 1;

            while((line = reader.readLine()) != null) {
                if (currentLine == id) {
                    return mapper.readValue(line, PersonEntity.class);
                }
                currentLine++;
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        return null;
    }

    public synchronized void save(PersonEntity person) {
        final Long id = getId() + 1;
        person.setId(id);
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(DB_PATH, true))) {
            writer.write(mapper.writeValueAsString(person));
            writer.newLine();
            writer.flush();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        updateIdIndex(id);
    }

    private synchronized void updateIdIndex(Long newId) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(PERSON_INDEX_PATH))) {
            writer.write(String.valueOf(newId));
            writer.flush();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private Long getId() {
        try (BufferedReader reader = new BufferedReader(new FileReader(PERSON_INDEX_PATH))) {
            return Long.parseLong(reader.readLine());
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

}
