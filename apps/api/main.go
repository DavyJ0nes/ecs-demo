package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type data struct {
	Name         string
	RandomString string
	Version      string
}

type health struct {
	Status  int
	Message string
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/v1/data", dataHandler)
	mux.HandleFunc("/health", healthHandler)
	log.Println("Starting JSON Jill Server")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

func dataHandler(w http.ResponseWriter, req *http.Request) {
	logger(req)
	data := data{
		"Json Jill",
		"s;kje;ifu930iufvnpuf2309piujvn2930ruhfn;cm;a39irpouwj",
		"JSON Jill API - v0.0.2 (9363fd9)",
	}
	js, err := json.Marshal(data)
	if err != nil {
		log.Fatal(err)
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}

func healthHandler(w http.ResponseWriter, req *http.Request) {
	healthData := health{
		Status:  1,
		Message: "A OK",
	}

	status, err := json.Marshal(healthData)
	if err != nil {
		log.Fatal(err)
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(status)
}

func logger(req *http.Request) {
	log.Printf("%s | %s => %s", req.Method, req.RemoteAddr, req.URL.Path)
}
