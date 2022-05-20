package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/discentem/nanomdmsandbox/pkg/enrollment"

	"github.com/discentem/nanomdmsandbox/pkg/env"
	mysql "github.com/go-sql-driver/mysql"
	"github.com/groob/plist"
	"github.com/manifoldco/promptui"
	"github.com/pkg/errors"
)

var (
	genEnrollment bool
	baseMDMURL    string
	company       string
	scepChallenge string
	pathToPem     string
)

func init() {
	flag.BoolVar(&genEnrollment, "gen_enrollment", false, "generate enrollment profile")
	flag.StringVar(&baseMDMURL, "base_url", env.String("NANOMDM_BASE_URL", ""), "base mdm url")
	flag.StringVar(&company, "company", env.String("NANOMDM_COMPANY", ""), "company name")
	flag.StringVar(&scepChallenge, "scep_challenge", env.String("NANOMDM_SCEP_CHALLENGE", ""), "the challenge password matching your scep server")
	flag.StringVar(&pathToPem, "path_to_pem", env.String("NANOMDM_PUSH_PEM", ""), "output path for mobileconfig")

}

func main() {
	flag.Parse()
	if genEnrollment {
		if pathToPem == "" {
			log.Fatal("pathToPem cannot be empty")
		}
		profile, err := enrollment.EnrollmentProfile(
			baseMDMURL,
			company,
			scepChallenge,
			pathToPem)
		if err != nil {
			log.Fatal(err)
		}
		b, err := plist.Marshal(profile)
		if err != nil {
			log.Fatal(err)
		}
		err = os.WriteFile("app/enrollment.mobileconfig", b, 0755)
		if err != nil {
			log.Fatal(err)
		}
		os.Exit(1)
	}

	hostname := ""

	prompt := promptui.Prompt{
		Label: "Username",
	}

	username, err := prompt.Run()

	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
	}

	prompt = promptui.Prompt{
		Label: "Password",
		Mask:  '*',
	}

	password, err := prompt.Run()

	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
	}

	dsnString := dsn("", username, password, hostname)

	config, err := validateDSNString(dsnString)

	// dsnString, err := CreateDSN(hostname, username, password, 0)
	if err != nil {
		fmt.Printf("validateDSNString: error: %v", err)
	}
	fmt.Printf("\n%s%s\n", "Input DSN String: ", dsnString)
	fmt.Printf("\n%s%s\n", "Validated DSN String: ", config.FormatDSN())
	fmt.Printf("\n%s%v\n", "Validated Config: ", config)

}

func dsn(dbName, username, password, hostname string) string {
	return fmt.Sprintf("%s:%s@tcp(%s)/%s", username, password, hostname, dbName)
}

// CreateDSN creates a DSN (data source name) string out of hostname, username,
// password, and timeout. It validates the resulting DSN and returns an error
// if the DSN is invalid.
func CreateDSN(host, username, password string, timeout time.Duration) (string, error) {
	// Example: [username[:password]@][protocol[(address)]]/
	dsn := host

	if username != "" || password != "" {
		dsn = "@" + dsn
	}

	if password != "" {
		dsn = ":" + password + dsn
	}

	if username != "" {
		dsn = username + dsn
	}

	config, err := mysql.ParseDSN(dsn)
	if err != nil {
		return "", errors.Wrapf(err, "config error for host '%s'", host)
	}

	if timeout > 0 {
		// Add connection timeouts to the DSN.
		config.Timeout = timeout
		config.ReadTimeout = timeout
		config.WriteTimeout = timeout
	}

	return config.FormatDSN(), nil
}

func validateDSNString(dsn string) (*mysql.Config, error) {
	config, err := mysql.ParseDSN(dsn)
	if err != nil {
		return config, errors.Wrapf(err, "config error")
	}

	fmt.Printf("Validated DSN string: %s", config.FormatDSN())

	return config, nil
}
