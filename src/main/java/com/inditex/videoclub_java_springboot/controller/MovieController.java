package com.inditex.videoclub_java_springboot.controller;

import com.inditex.videoclub_java_springboot.model.CoproduccionDTO;
import com.inditex.videoclub_java_springboot.model.Movie;
import com.inditex.videoclub_java_springboot.service.MovieService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
public class MovieController {

    private final MovieService movieService;

    public MovieController(MovieService movieService) {
        this.movieService = movieService;
    }

    @GetMapping("/movies")
    public List<Movie> getAllMovies(){
        return movieService.getAll();
    }

    @GetMapping("/coproducciones")
    public List<CoproduccionDTO> getCoproducciones(){
        return movieService.getCoproducciones();
    }

    @PostMapping("/movies")
    public Movie createMovie(@RequestBody Movie newMovie){
        return movieService.addMovie(newMovie);
    }

    @DeleteMapping("/movies/{id}")
    public void deleteMovieById(@PathVariable int id){
        movieService.deleteMovie(id);
    }

    @GetMapping("/movies/ASC")
    public List<Movie> getAllByOrder(){
        return movieService.getAllByOrder();
    }

    @GetMapping("/movies/{id}")
    public ResponseEntity<Movie> findMovieById(@PathVariable int id){
        Optional<Movie> foundMovie = movieService.findMovie(id);
        if(foundMovie.isPresent()){
            return new ResponseEntity<>(foundMovie.get(), HttpStatus.FOUND);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/movies/{id}")
    public ResponseEntity<Movie> updateMovieById(@PathVariable int id, @RequestBody Movie updatedMovie){
        try{
            Movie movie = movieService.updateMovie(id, updatedMovie);
            return new ResponseEntity<>(movie, HttpStatus.OK);
        }
        catch(Exception exception){
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
