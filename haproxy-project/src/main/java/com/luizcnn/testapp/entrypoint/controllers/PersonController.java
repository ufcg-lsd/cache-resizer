package com.luizcnn.testapp.entrypoint.controllers;

import com.luizcnn.testapp.domain.service.PersonService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;

import static java.util.Objects.nonNull;
import static org.springframework.http.HttpStatus.CREATED;

@Slf4j
@RestController
@RequestMapping("/persons")
@RequiredArgsConstructor
public class PersonController {

    private final PersonService personService;

    @GetMapping("/{id}")
    public ResponseEntity<?> getPerson(@PathVariable Long id) {
        try {
            log.info("status=requesting-person-by-id, id={}", id);
            final var person =  personService.findPersonById(id);
            if(nonNull(person)) {
                log.info("status=success, person={}", person);
                return ResponseEntity
                        .ok()
                        .cacheControl(CacheControl.maxAge(Duration.ofHours(3)).sMaxAge(Duration.ofHours(3)))
                        .body(person);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/random/{quantity}")
    public ResponseEntity<?> getRandomPerson(@PathVariable int quantity) {
        personService.createPersonsFromApi(quantity);
        return ResponseEntity.status(CREATED).build();
    }

}

