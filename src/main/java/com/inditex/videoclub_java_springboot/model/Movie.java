package com.inditex.videoclub_java_springboot.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

@Entity
@Table(name="movies")
public class Movie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private String titulo;
    private String director;
    @JsonProperty("año")
    private int anio;
    private String genero;
    private String argumento;
    private String imagen;
    private String imageCartel;
    private String trailer;
    private String pais;

    public Movie(String titulo, String director, int anio, String genero, String argumento, String imagen, String imageCartel, String trailer, String pais) {
        this.titulo = titulo;
        this.director = director;
        this.anio = anio;
        this.genero = genero;
        this.argumento = argumento;
        this.imagen = imagen;
        this.imageCartel = imageCartel;
        this.trailer = trailer;
        this.pais = pais;
    }

    public Movie() {
    }

    public int getId() {
        return id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getDirector() {
        return director;
    }

    public void setDirector(String director) {
        this.director = director;
    }

    public int getAnio() {
        return anio;
    }

    public void setAnio(int anio) {
        this.anio = anio;
    }

    public String getGenero() {
        return genero;
    }

    public void setGenero(String genero) {
        this.genero = genero;
    }

    public String getArgumento() {
        return argumento;
    }

    public void setArgumento(String argumento) {
        this.argumento = argumento;
    }

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String imagen) {
        this.imagen = imagen;
    }

    public String getImageCartel() {
        return imageCartel;
    }

    public void setImageCartel(String imageCartel) {
        this.imageCartel = imageCartel;
    }

    public String getTrailer() {
        return trailer;
    }

    public void setTrailer(String trailer) {
        this.trailer = trailer;
    }

    public String getPais() {
        return pais;
    }

    public void setPais(String pais) {
        this.pais = pais;
    }
}
