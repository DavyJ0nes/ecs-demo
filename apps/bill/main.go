package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", indexHandler)
	mux.HandleFunc("/bill", billHandler)

	log.Println("Starting bill server")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

func indexHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("%s | %s => %s", req.Method, req.RemoteAddr, req.URL.Path)
	log.Println("Redirecting to /bill")
	http.Redirect(w, req, "/bill", 302)

}

func billHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("%s | %s => %s", req.Method, req.RemoteAddr, req.URL.Path)
	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, "<h1>Hey I'm Bill</h1>\n")
}
