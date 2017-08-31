package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
)

type health struct {
	Status  int
	Message string
}

var tmpl *template.Template

func init() {
	templatePath := fmt.Sprintf("%s/*.html", "templates")
	tmpl = template.Must(template.ParseGlob(templatePath))
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", indexHandler)
	mux.HandleFunc("/health", healthHandler)
	mux.Handle("/static/", http.StripPrefix("/static", http.FileServer(http.Dir("templates/static"))))

	log.Println("Starting Front End Server")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

func indexHandler(w http.ResponseWriter, req *http.Request) {
	logger(req)

	hostnameString, _ := os.Hostname()

	data := struct {
		Hostname string
	}{
		Hostname: hostnameString,
	}

	w.Header().Set("Content-Type", "text/html")
	tmpl.ExecuteTemplate(w, "index.html", data)
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
