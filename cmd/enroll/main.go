package main

import (
	"errors"
	"flag"
	"fmt"
	"log"
	"net/http"

	"github.com/discentem/nanomdmsandbox/internal/enroll"
)

var (
	baseMdmUrl           = flag.String("base_url", "", "base url is the URL for the nanomdm instance ")
	companyName          = flag.String("company", "", "company name will be automatically filled in to the generated profile")
	scepChallenge        = flag.String("scep_challenge", "", "challenge for the SCEP instance for enrolling certificates")
	pushPemPath          = flag.String("push_pem_path", ".", "directory to the Push certificate PEM file")
	port          string = "9300"
)

func flagParse() error {
	flag.Parse()
	if len(*baseMdmUrl) == 0 {
		return errors.New("base MDM URL is blank")
	}
	if len(*companyName) == 0 {
		return errors.New("company name is blank")
	}
	if len(*scepChallenge) == 0 {
		return errors.New("scep challenge is blank")
	}
	if len(*pushPemPath) == 0 {
		return errors.New("push PEM path is blank")
	}
	return nil
}

func main() {
	err := flagParse()
	if err != nil {
		log.Fatal(err)
	}

	log.Println("server is booting up...")
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)

	mux := http.NewServeMux()

	healthHandler := &enroll.HealthHandler{}

	enrollHandler := &enroll.EnrollHandler{
		BaseMdmUrl:    *baseMdmUrl,
		Company:       *companyName,
		SCEPChallenge: *scepChallenge,
		PathToPEM:     *pushPemPath,
	}

	mux.Handle("/health", healthHandler)
	mux.Handle("/enroll", enrollHandler)
	log.Printf("server started and serving traffic on: %s\n", port)

	err = http.ListenAndServe(fmt.Sprintf(":%s", port), logRequest(mux))
	if err != nil {
		log.Fatal(err)
	}
}

func logRequest(handler http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s %s\n", r.RemoteAddr, r.Method, r.URL)
		handler.ServeHTTP(w, r)
	})
}
