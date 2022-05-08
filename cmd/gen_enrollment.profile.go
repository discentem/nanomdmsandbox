package main

import (
	"crypto/x509"
	"errors"
	"fmt"
	"io/ioutil"

	"github.com/micromdm/micromdm/mdm/enroll"
	"github.com/micromdm/nanomdm/cryptoutil"
)

func allRights() enroll.AccessRights {
	return enroll.ProfileInspection |
		enroll.ProfileInstallAndRemoval |
		enroll.DeviceLock |
		enroll.DeviceErase |
		enroll.DeviceInformationQuery |
		enroll.NetworkInformationQuery |
		enroll.ProvisioningProfileInspection |
		enroll.ProvisioningProfileInstallAndRemoval |
		enroll.ApplicationInspection |
		enroll.RestrictionQuery |
		enroll.SecurityQuery |
		enroll.SettingsManipulation |
		enroll.AppManagement
}

const perUserConnections = "com.apple.mdm.per-user-connections"
const bootstrapToken = "com.apple.mdm.bootstraptoken"

type EnrollmentOpts struct {
	serverURL     string
	company       string
	topic         string
	scepChallenge string
	pathToPem     string
}

func EnrollmentProfile(serverURL, company, topic, scepChallenge, pathToPem string) (*enroll.Profile, error) {
	return EnrollmentOpts{
		serverURL:     serverURL,
		company:       company,
		topic:         topic,
		scepChallenge: scepChallenge,
		pathToPem:     pathToPem,
	}.EnrollmentProfile()
}

func (opts EnrollmentOpts) EnrollmentProfile() (*enroll.Profile, error) {
	if opts.topic == "" {
		if opts.pathToPem == "" {
			return nil, errors.New("topic is empty string, so opts.pathToPem is expected")
		}
		b, err := ioutil.ReadFile(opts.pathToPem)
		if err != nil {
			return nil, err
		}
		opts.topic, err = cryptoutil.TopicFromPEMCert(b)
		if err != nil {
			return nil, err
		}
		fmt.Println(opts.topic)
	}

	profile := enroll.NewProfile()
	profile.PayloadIdentifier = fmt.Sprintf("com.%s.nanomdm.scep", opts.company)
	profile.PayloadOrganization = opts.company
	profile.PayloadDisplayName = "Enrollment Profile"
	profile.PayloadDescription = "The server may alter your settings"
	profile.PayloadScope = "System"

	mdmPayload := enroll.NewPayload("com.apple.mdm")
	mdmPayload.PayloadDescription = "Enrolls with the MDM server"
	mdmPayload.PayloadOrganization = opts.company
	mdmPayload.PayloadIdentifier = fmt.Sprintf("com.%s.nanomdm.mdm", opts.company)
	mdmPayload.PayloadScope = "System"

	mdmPayloadContent := enroll.MDMPayloadContent{
		Payload:             *mdmPayload,
		AccessRights:        allRights(),
		CheckInURL:          "/mdm",
		CheckOutWhenRemoved: true,
		ServerURL:           opts.serverURL,
		Topic:               opts.topic,
		SignMessage:         true,
		ServerCapabilities: []string{
			perUserConnections,
			bootstrapToken},
	}

	payloadContent := []interface{}{}
	scepContent := enroll.SCEPPayloadContent{
		URL:      fmt.Sprintf("%s/scep", opts.serverURL),
		Keysize:  2048,
		KeyType:  "RSA",
		KeyUsage: int(x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment),
		Name:     "Device Management Identity Certificate",
	}
	{
		scepContent.Challenge = opts.scepChallenge

		scepPayload := enroll.NewPayload("com.apple.security.scep")
		scepPayload.PayloadDescription = "Configures SCEP"
		scepPayload.PayloadDisplayName = "SCEP"
		scepPayload.PayloadIdentifier = fmt.Sprintf("com.%s.nanomdm.scep", opts.company)
		scepPayload.PayloadOrganization = opts.company
		scepPayload.PayloadContent = scepContent
		scepPayload.PayloadScope = "System"

		payloadContent = append(payloadContent, *scepPayload)
		mdmPayloadContent.IdentityCertificateUUID = scepPayload.PayloadUUID
	}

	payloadContent = append(payloadContent, mdmPayloadContent)

	profile.PayloadContent = payloadContent
	return profile, nil
}
