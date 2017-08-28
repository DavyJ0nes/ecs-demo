package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", indexHandler)
	mux.HandleFunc("/steve", steveHandler)

	log.Println("Starting steve server")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

func indexHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("%s | %s => %s", req.Method, req.RemoteAddr, req.URL.Path)
	log.Println("Redirecting to /steve")
	http.Redirect(w, req, "/steve", 302)

}

func steveHandler(w http.ResponseWriter, req *http.Request) {
	log.Printf("%s | %s => %s", req.Method, req.RemoteAddr, req.URL.Path)
	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, "<h1>Just Steve being Steve</h1>\n")
}
