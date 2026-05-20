package com.inditex.videoclub_java_springboot.repository;

import com.inditex.videoclub_java_springboot.model.Movie;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MovieRepository extends JpaRepository<Movie, Integer> {
}
