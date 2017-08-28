package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", indexHandler)
	mux.HandleFunc("/fred", fredHandler)

	log.Println("Starting fred server")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

func indexHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("%s | %s => %s", req.Method, req.RemoteAddr, req.URL.Path)
	log.Println("Redirecting to /fred")
	http.Redirect(w, req, "/fred", 302)
}

func fredHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("%s | %s => %s", req.Method, req.RemoteAddr, req.URL.Path)
	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, "<h1>Hey Fred here</h1>\n")
}
