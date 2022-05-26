package cmd

import (
	"fmt"
	"os"
	"time"

	"github.com/discentem/nanomdmsandbox/cli/pkg/env"
	"github.com/go-sql-driver/mysql"
	"github.com/pkg/errors"
	"github.com/spf13/cobra"
)

var (
	baseMDMURL    string
	company       string
	scepChallenge string
	pathToPem     string
	port          string
	cfppath       string
	deviceUUID    string
	password      string
)

var rootCmd = &cobra.Command{
	Use:   "cli",
	Short: "",
	Long:  `cli tools for nanomdmsandbox project`,
	// Run: func(cmd *cobra.Command, args []string) {
	// 	// Do Stuff Here
	// },
}

func init() {
	rootCmd.PersistentFlags().StringVar(&baseMDMURL, "base_url", env.String("NANOMDM_BASE_URL", ""), "base url for mdm server")
	rootCmd.PersistentFlags().StringVar(&company, "company", env.String("NANOMDM_COMPANY", ""), "company name")
	rootCmd.PersistentFlags().StringVar(&scepChallenge, "scep_challenge", env.String("NANOMDM_SCEP_CHALLENGE", ""), "the challenge password matching your scep server")
	rootCmd.PersistentFlags().StringVar(&pathToPem, "push_pem_path", env.String("NANOMDM_PUSH_PEM", ""), "path to mdm push cert, needed for topic extraction")

	rootCmd.AddCommand(createEnrollment)

	enrollEndpoint.Flags().StringVar(&port, "port", "9300", "port for enroll endpoint")

	pushProfile.Flags().StringVar(&cfppath, "path", "app/desktop-setting.mobileconfig", "path to profile to push to director")
	pushProfile.Flags().StringVar(&deviceUUID, "device", "", "device UUID to push profile to")
	pushProfile.Flags().StringVar(&password, "password", env.String("MDMDIRECTOR_PASSWORD", ""), "pass for mdmdirector post requests")
	rootCmd.AddCommand(enrollEndpoint)
	rootCmd.AddCommand(pushProfile)

}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, fmt.Errorf("error: %v", err))
		os.Exit(1)
	}
}

// func main() {
// 	flag.Parse()
// 	if createEnrollment {

// 	} else {

// 		hostname := ""

// 		prompt := promptui.Prompt{
// 			Label: "Username",
// 		}

// 		username, err := prompt.Run()

// 		if err != nil {
// 			fmt.Printf("Prompt failed %v\n", err)
// 		}

// 		prompt = promptui.Prompt{
// 			Label: "Password",
// 			Mask:  '*',
// 		}

// 		password, err := prompt.Run()

// 		if err != nil {
// 			fmt.Printf("Prompt failed %v\n", err)
// 		}

// 		dsnString := dsn("", username, password, hostname)

// 		config, err := validateDSNString(dsnString)

// 		// dsnString, err := CreateDSN(hostname, username, password, 0)
// 		if err != nil {
// 			fmt.Printf("validateDSNString: error: %v", err)
// 		}
// 		fmt.Printf("\n%s%s\n", "Input DSN String: ", dsnString)
// 		fmt.Printf("\n%s%s\n", "Validated DSN String: ", config.FormatDSN())
// 		fmt.Printf("\n%s%v\n", "Validated Config: ", config)
// 	}

// }

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
