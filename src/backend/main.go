package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/sei-shigeo/website-waseisyouji/views"
)

var err error

func greetHandler(w http.ResponseWriter, r *http.Request) {
	views.Home().Render(r.Context(), w)
}

func setupAssetsDir(mux *http.ServeMux) {
	mux.Handle("/assets/", http.StripPrefix("/assets/", http.FileServer(http.Dir("./assets"))))
}

func startServer(mux *http.ServeMux) {
	server := &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}
	fmt.Printf("Server listening to http://localhost%s", server.Addr)
	err = server.ListenAndServe()
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	mux := http.NewServeMux()
	setupAssetsDir(mux)
	mux.HandleFunc("/", greetHandler)
	startServer(mux)
}
