package com.inditex.videoclub_java_springboot.model;

import java.util.List;

public class CoproduccionDTO {

    private String id;
    private String pais;
    private List<Movie> peliculas;

    public CoproduccionDTO(String id, String pais, List<Movie> peliculas) {
        this.id = id;
        this.pais = pais;
        this.peliculas = peliculas;
    }

    public String getId() {
        return id;
    }

    public String getPais() {
        return pais;
    }

    public List<Movie> getPeliculas() {
        return peliculas;
    }
}
