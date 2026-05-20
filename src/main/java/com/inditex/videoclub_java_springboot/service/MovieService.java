package com.inditex.videoclub_java_springboot.service;

import com.inditex.videoclub_java_springboot.model.CoproduccionDTO;
import com.inditex.videoclub_java_springboot.model.Movie;
import com.inditex.videoclub_java_springboot.repository.MovieRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class MovieService {

    private final MovieRepository movieRepository;

    public MovieService(MovieRepository movieRepository) {
        this.movieRepository = movieRepository;
    }

    public List<Movie> getAll(){
        return movieRepository.findAll();
    }

    public Movie addMovie(Movie newMovie){
        return movieRepository.save(newMovie);
    }

    public void deleteMovie(int id){
        movieRepository.deleteById(id);
    }

    public List<Movie> getAllByOrder(){
        return movieRepository.findAll(Sort.by(Sort.Direction.ASC, "titulo"));
    }

    public Optional<Movie> findMovie(int id) {
        return movieRepository.findById(id);
    }

    public Movie updateMovie(int id, Movie updatedMovie) {
        Optional<Movie> foundMovie = movieRepository.findById(id);
        if (foundMovie.isPresent()) {
            Movie existingMovie = foundMovie.get();
            existingMovie.setTitulo(updatedMovie.getTitulo());
            existingMovie.setDirector(updatedMovie.getDirector());
            existingMovie.setAnio(updatedMovie.getAnio());
            existingMovie.setGenero(updatedMovie.getGenero());
            existingMovie.setArgumento(updatedMovie.getArgumento());
            existingMovie.setImagen(updatedMovie.getImagen());
            existingMovie.setImageCartel(updatedMovie.getImageCartel());
            existingMovie.setTrailer(updatedMovie.getTrailer());
            existingMovie.setPais(updatedMovie.getPais());
            return movieRepository.save(existingMovie);
        }
        throw new RuntimeException("Película no encontrada en la BBDD con id: " + id);
    }

    public List<CoproduccionDTO> getCoproducciones() {
        List<Movie> movies = movieRepository.findAll();
        Map<String, List<Movie>> grouped = movies.stream()
                .collect(Collectors.groupingBy(m -> m.getPais() != null ? m.getPais() : "other"));
        return grouped.entrySet().stream()
                .map(e -> new CoproduccionDTO(
                        Integer.toHexString(Math.abs(e.getKey().hashCode())).substring(0, 4),
                        e.getKey(),
                        e.getValue()
                ))
                .collect(Collectors.toList());
    }
}
