package cmd

import (
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/discentem/nanomdmsandbox/cli/pkg/enrollment"
	"github.com/groob/plist"
	"github.com/manifoldco/promptui"
	"github.com/spf13/cobra"
)

var createEnrollment = &cobra.Command{
	Use:   "create_enrollment",
	Short: "",
	Long:  `generate static enrollment profile`,
	Run: func(cmd *cobra.Command, args []string) {
		finalBaseMDMURL, finalCompany, finalScepChallenge, finalPathToPem := promptForFlags()
		profile, err := enrollment.EnrollmentProfile(
			finalBaseMDMURL,
			finalCompany,
			finalScepChallenge,
			finalPathToPem)
		if err != nil {
			log.Fatal(err)
		}
		b, err := plist.MarshalIndent(profile, "  ")
		if err != nil {
			log.Fatal(err)
		}
		err = os.WriteFile("app/enrollment.mobileconfig", b, 0755)
		if err != nil {
			log.Fatal(err)
		}
	},
}

func promptForFlags() (string, string, string, string) {
	finalBaseMDMURL := baseMDMURL
	finalCompany := company
	finalScepChallenge := scepChallenge
	finalPathToPem := pathToPem

	if finalBaseMDMURL == "" {
		prompt := promptui.Prompt{
			Label: "baseMDMURL",
			Validate: func(input string) error {
				if input == "" {
					return errors.New("baseMDMURL can't be empty")
				}
				return nil
			},
		}
		var err error
		finalBaseMDMURL, err = prompt.Run()

		if err != nil {
			fmt.Printf("Prompt failed %v\n", err)
		}
	}

	if finalCompany == "" {
		prompt := promptui.Prompt{
			Label: "company (ex: acme.com)",
			Validate: func(input string) error {
				if input == "" {
					return errors.New("company can't be empty")
				}
				return nil
			},
		}
		var err error
		finalCompany, err = prompt.Run()

		if err != nil {
			fmt.Printf("Prompt failed %v\n", err)
		}
	}
	if finalScepChallenge == "" {
		prompt := promptui.Prompt{
			Label: "scepChallenge (ex: ThisIsAChallenge)",
			Validate: func(input string) error {
				if input == "" {
					return errors.New("scepChallenge can't be empty")
				}
				return nil
			},
		}
		var err error
		finalScepChallenge, err = prompt.Run()

		if err != nil {
			fmt.Printf("Prompt failed %v\n", err)
		}
	}
	if finalPathToPem == "" {
		prompt := promptui.Prompt{
			Label: "path to push cert",
			Validate: func(input string) error {
				_, err := os.Stat(input)
				return err
			},
		}
		var err error
		finalPathToPem, err = prompt.Run()

		if os.IsNotExist(err) {
			fmt.Printf("Prompt failed %v\n", err)
		}

	}

	return finalBaseMDMURL, finalCompany, finalScepChallenge, finalPathToPem

}
