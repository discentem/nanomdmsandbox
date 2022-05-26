package cli

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/discentem/nanomdmsandbox/pkg/enrollment"
	"github.com/groob/plist"
	"github.com/spf13/cobra"
)

var enrollEndpoint = &cobra.Command{
	Use:   "enrollment_endpoint",
	Short: "",
	Long:  `generate static enrollment profile and host it on an http endpoint`,
	RunE: func(cmd *cobra.Command, args []string) error {
		if baseMDMURL == "" {
			return fmt.Errorf("value for %q must be provided", "baseMDMURL")
		}
		if company == "" {
			return fmt.Errorf("value for %q must be provided", "company")
		}
		if scepChallenge == "" {
			return fmt.Errorf("value for %q must be provided", "scepChallenge")
		}
		if pathToPem == "" {
			return fmt.Errorf("value for %q must be provided", "pathToPem")
		}
		profile, err := enrollment.EnrollmentProfile(
			baseMDMURL,
			company,
			scepChallenge,
			pathToPem)
		if err != nil {
			log.Fatal(err)
		}
		b, err := plist.MarshalIndent(profile, "  ")
		if err != nil {
			log.Fatal(err)
		}
		err = os.MkdirAll("enrollment", 0755)
		if err != nil {
			log.Fatal(err)
		}
		err = os.WriteFile("enrollment/enrollment.mobileconfig", b, 0755)
		if err != nil {
			log.Fatal(err)
		}
		log.Printf("port: %s\n", port)
		sf := func() http.HandlerFunc {
			return func(w http.ResponseWriter, r *http.Request) {
				w.Header().Set("Content-Disposition", "attachment; filename="+strconv.Quote("enrollment.mobileconfig"))
				w.Header().Set("Content-Type", "application/octet-stream")
				http.ServeFile(w, r, "./enrollment/enrollment.mobileconfig")
			}
		}

		http.HandleFunc("/enroll", sf())

		http.ListenAndServe(fmt.Sprintf(":%s", port), nil)
		return nil
	},
}
