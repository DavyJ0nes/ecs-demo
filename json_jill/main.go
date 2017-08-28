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

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/v1/data", dataHandler)
	log.Println("Starting JSON Jill Server")
	log.Fatal(http.ListenAndServe(":8000", mux))
}

func dataHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("%s | %s => %s", req.Method, req.RemoteAddr, req.URL.Path)
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
