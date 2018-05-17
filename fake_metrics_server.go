package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "wrong method", http.StatusMethodNotAllowed)
			return
		}
		defer r.Body.Close()

		data, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.Printf("can't read data from %s: %v", r.RemoteAddr, err)
			return
		}

		fmt.Println(string(data))
	})

	http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}
