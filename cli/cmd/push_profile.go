package cmd

import (
	"bytes"
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
		return push_profile(baseMDMURL, cfppath, deviceUUID)
	},
}

type mdmDirectorProfilePayload struct {
	UUIDs    []string `json:"uuids"`
	Profiles []string `json:"profiles"`
	PushNow  bool     `json:"push_now"`
}

func push_profile(mdmdirectorBaseUrl, profilePath, uuid string) error {
	b, err := os.ReadFile(cfppath)
	if err != nil {
		return err
	}
	bep := base64.StdEncoding.EncodeToString(b)

	jsonData, err := json.Marshal(mdmDirectorProfilePayload{
		UUIDs:    []string{"*"},
		Profiles: []string{bep},
		PushNow:  true,
	})
	if err != nil {
		return err
	}

	/*
	   payload = {"udids": ["*"], "profiles": profiles, "push_now": False}

	       print(payload)
	       profile_url = "{}/profile".format(url)
	       try:
	           r = requests.post(profile_url, json=payload, auth=("mdmdirector", password))
	       except Exception as e:
	           print(r.status_code)
	           print(e)
	*/

	if !strings.Contains(mdmdirectorBaseUrl, "https://") {
		mdmdirectorBaseUrl = "https://" + mdmdirectorBaseUrl
	}
	req, err := http.NewRequest("POST", fmt.Sprintf("%s/profile", mdmdirectorBaseUrl), bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json; charset=UTF-8")
	req.SetBasicAuth("mdmdirector", password)
	client := &http.Client{}
	response, error := client.Do(req)
	if error != nil {
		panic(error)
	}
	defer response.Body.Close()

	fmt.Println("response Status:", response.Status)
	fmt.Println("response Headers:", response.Header)
	body, _ := ioutil.ReadAll(response.Body)
	fmt.Println("response Body:", string(body))
	return nil

}
