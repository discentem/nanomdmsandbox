package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	mysql "github.com/go-sql-driver/mysql"
	"github.com/groob/plist"
	"github.com/manifoldco/promptui"
	"github.com/pkg/errors"
)

var (
	genEnrollment bool
)

func init() {
	flag.BoolVar(&genEnrollment, "generate_enrollment", false, "generate enrollment profile")
}

func main() {
	flag.Parse()
	if genEnrollment {
		profile, err := EnrollmentProfile(
			"mdm.mdm.bkurtz.cloud/enroll",
			"place",
			"",
			"ThisIsAChallenge",
			"/Users/brandon_kurtz/nanomdm_push_cert.pem")
		if err != nil {
			log.Fatal(err)
		}
		b, err := plist.Marshal(profile)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(string(b))
		os.Exit(1)
	}

	hostname := "nanomdm-rds.civ0hthv7lpj.us-east-1.rds.amazonaws.com"

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
