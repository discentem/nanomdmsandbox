package cli

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"

	"encoding/base64"
	"encoding/json"

	"github.com/spf13/cobra"
)

var pushProfile = &cobra.Command{
	Use:   "push_profile",
	Short: "p",
	Long:  `push profile`,
	RunE: func(cmd *cobra.Command, args []string) error {
		// return push_profile(baseMDMURL, cfppath, deviceUUID)
		return push_profile(baseMDMURL, cfppath, "14883E92-41E0-5E4D-B2D7-C65B289CEF20")
	},
}

type mdmDirectorProfilePayload struct {
	UDIDs    []string `json:"udids"`
	Profiles []string `json:"profiles"`
	PushNow  bool     `json:"push_now"`
}

func push_profile(mdmdirectorBaseUrl, profilePath, uuid string) error {
	b, err := os.ReadFile(cfppath)
	if err != nil {
		return err
	}
	bep := base64.StdEncoding.EncodeToString(b)

	if deviceUUID == "" {
		deviceUUID = "*"
	}
	jsonData, err := json.Marshal(mdmDirectorProfilePayload{
		UDIDs:    []string{deviceUUID},
		Profiles: []string{bep},
		PushNow:  true,
	})
	if err != nil {
		return err
	}
	fmt.Println(string(jsonData))

	if !strings.Contains(mdmdirectorBaseUrl, "https://") {
		mdmdirectorBaseUrl = "https://" + mdmdirectorBaseUrl
	}
	// req, err := http.NewRequest("POST", fmt.Sprintf("%s/profile/", mdmdirectorBaseUrl), bytes.NewBuffer(jsonData))
	// if err != nil {
	// 	return err
	// }
	req, err := http.NewRequest("GET", fmt.Sprintf("%s/profile/%s", mdmdirectorBaseUrl, deviceUUID), nil)
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json; charset=UTF-8")
	req.SetBasicAuth("mdmdirector", password)
	client := &http.Client{}
	response, err := client.Do(req)
	if err != nil {
		return err
	}
	defer response.Body.Close()

	fmt.Println("response Status:", response.Status)
	fmt.Println("response Headers:", response.Header)
	body, _ := ioutil.ReadAll(response.Body)
	fmt.Println("response Body:", string(body))
	return nil

}
