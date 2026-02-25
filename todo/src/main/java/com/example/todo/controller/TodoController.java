package com.example.todo.controller;

import com.example.todo.model.Todo;
import com.example.todo.repo.TodoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/todos")
@RequiredArgsConstructor
@CrossOrigin(origins="*")
public class TodoController {

    private final TodoRepository repo;

    @GetMapping
    public List<Todo> all() {
        return repo.findAll();
    }

    @PostMapping
    public Todo create(@RequestBody Todo t) {
        return repo.save(t);
    }

    @PutMapping("/{id}")
    public Todo update(@PathVariable Long id, @RequestBody Todo t) {
        t.setId(id);
        return repo.save(t);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        repo.deleteById(id);
    }
}