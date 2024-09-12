package main 

import (
    "net/http"
    "encoding/json"
)

func main() {
    s := http.NewServeMux()
    s.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        json.NewEncoder(w).Encode(map[string]string{
            "Hello":"World",
        }) 
    })
    http.ListenAndServe(":8080", s)
}
