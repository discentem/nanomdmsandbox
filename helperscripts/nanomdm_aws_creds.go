package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"

	"os"

	"github.com/bigkevmcd/go-configparser"
)

type Secrets struct {
	// PublicInboundCidrBlocksIpv4 []string "json:`public_inbound_cidr_blocks_ipv4`"
	// PublicInboundCidrBlocksIpv6 []string "json:`public_inbound_cidr_blocks_ipv6`"
	// DomainName                  string   "json:`domain_name`"
	// RepositoryName              string   "json:`repository_name`"
	AWSAccessKey string `json:"AWS_ACCESS_KEY"`
	AWSSecretKey string `json:"AWS_SECRET_KEY"`
}

func main() {
	jsonFile, err := os.Open("terraform/secrets.auto.tfvars.json")
	// if we os.Open returns an error then handle it
	if err != nil {
		fmt.Println(err)
	}

	b, _ := ioutil.ReadAll(jsonFile)
	var s Secrets
	err = json.Unmarshal(b, &s)

	if err != nil {
		log.Fatal(err)
	}

	homedir, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}
	creds := fmt.Sprintf("%s/.aws/credentials", homedir)
	p, err := configparser.NewConfigParserFromFile(creds)
	if err != nil {
		log.Fatal(err)
	}
	if p.HasSection("nanomdm") {
		if err := p.RemoveSection("nanomdm"); err != nil {
			log.Fatal((err))
		}
	}
	if err := p.AddSection("nanomdm"); err != nil {
		log.Fatal(err)
	}

	err = p.Set("nanomdm", "aws_access_key_id", s.AWSAccessKey)
	if err != nil {
		log.Fatal(err)
	}
	err = p.Set("nanomdm", "aws_secret_access_key", s.AWSSecretKey)
	if err != nil {
		log.Fatal(err)
	}
	err = p.SaveWithDelimiter(fmt.Sprintf("%s/.aws/credentials", homedir), "=")
	if err != nil {
		log.Fatal(err)
	}

}
