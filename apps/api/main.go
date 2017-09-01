package main

import (
	"encoding/json"
	"log"
	"math/rand"
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
	log.Fatal(http.ListenAndServe(":3000", mux))
}

func dataHandler(w http.ResponseWriter, req *http.Request) {
	logger(req)
	randomString := generateRandomString()

	data := data{
		"Json Jill",
		randomString,
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

// generateRandomString
func generateRandomString() string {
	letterBytes := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	b := make([]byte, 64)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b)
}
