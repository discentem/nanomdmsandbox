package main

import (
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

type rawTime []byte

func (t rawTime) Time() (time.Time, error) {
	if string(t) == "0000-00-00 00:00:00" {
		return time.Time{}, nil
	}
	return time.Parse("2006-01-02 15:04:05", string(t))
}

type Enrollment struct {
	Id               string         `json:"id"`
	DeviceID         string         `json:"device_id"`
	UserId           sql.NullString `json:"user_id"`
	Type             string         `json:"type"`
	Topic            string         `json:"topic"`
	Enabled          string         `json:"enabled"`
	PushMagic        string         `json:"push_magic"`
	TokenHex         string         `json:"token_hex"`
	LastSeenAt       rawTime        `json:"last_seen_at"`
	TokenUpdateTally string         `json:"token_update_tally"`
	CreatedAt        string         `json:"created_at"`
	UpdatedAt        string         `json:"updated_at"`
}

type DEPProfileStatus string

type DeviceDTO struct {
	SerialNumber     string           `json:"serial_number"`
	UDID             string           `json:"udid"`
	EnrollmentStatus bool             `json:"enrollment_status"`
	LastSeen         time.Time        `json:"last_seen"`
	DEPProfileStatus DEPProfileStatus `json:"dep_profile_status"`
}
type DeviceDTOLastSeenString struct {
	SerialNumber     string           `json:"serial_number"`
	UDID             string           `json:"udid"`
	EnrollmentStatus bool             `json:"enrollment_status"`
	LastSeen         string           `json:"last_seen"`
	DEPProfileStatus DEPProfileStatus `json:"dep_profile_status"`
}

func DevicesWithRFC3339Nano(devices []DeviceDTO) []DeviceDTOLastSeenString {
	var nDevices []DeviceDTOLastSeenString
	for _, d := range devices {
		nDevices = append(nDevices, DeviceDTOLastSeenString{
			SerialNumber:     d.SerialNumber,
			UDID:             d.UDID,
			EnrollmentStatus: d.EnrollmentStatus,
			LastSeen:         d.LastSeen.Format(time.RFC3339Nano),
			DEPProfileStatus: d.DEPProfileStatus,
		})
	}
	return nDevices
}

var (
	dsn string
)

func main() {
	flag.StringVar(&dsn, "dsn", "", "data source name (e.g. connection string or path)")
	flag.Parse()
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatal(err)
	}
	rows, err := db.Query(`select * from enrollments;`)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	var devices []DeviceDTO
	for rows.Next() {
		var e Enrollment
		if err := rows.Scan(&e.Id, &e.DeviceID, &e.UserId, &e.Type, &e.Topic, &e.PushMagic, &e.TokenHex, &e.Enabled, &e.TokenUpdateTally, &e.LastSeenAt, &e.CreatedAt, &e.UpdatedAt); err != nil {
			fmt.Println("failed parsing enrollment")
			log.Fatal(err)
		}
		fmt.Println(e.LastSeenAt)
		lsa, err := e.LastSeenAt.Time()
		if err != nil {
			fmt.Println("failed parsing time")
			log.Fatal(err)
		}
		ddto := DeviceDTO{
			UDID: e.Id,
			EnrollmentStatus: func(enabled string) bool {
				return enabled == "1"
			}(e.Enabled),
			LastSeen:         lsa,
			DEPProfileStatus: "unknown",
		}
		type Serial struct {
			Serial string `json:"serial_number"`
		}
		rows, err = db.Query(`select serial_number from devices where id = ?`, e.Id)
		if err != nil {
			fmt.Println("failed querying serial")
			log.Fatal(err)
		}
		defer rows.Close()
		var s Serial
		for rows.Next() {
			if err := rows.Scan(
				&s.Serial,
			); err != nil {
				fmt.Println("failed querying serial")
				log.Fatal(err)
			}
		}
		ddto.SerialNumber = s.Serial
		devices = append(devices, ddto)
	}
	for _, d := range devices {
		fmt.Printf(
			"LastSceen: %s; EnrollmentStatus: %t; SerialNumber: %s; DEPProfileStatus: %s; UDID: %s",
			d.LastSeen, d.EnrollmentStatus, d.SerialNumber,
			d.DEPProfileStatus, d.UDID,
		)
	}

	devicesHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusCreated)
		w.Header().Set("Content-Type", "application/json")
		fDevices := DevicesWithRFC3339Nano(devices)
		jsonResp, err := json.Marshal(fDevices)
		if err != nil {
			log.Fatalf("Error happened in JSON marshal. Err: %s", err)
		}
		w.Write(jsonResp)
	})
	http.Handle("/devices", devicesHandler)
	http.ListenAndServe(":8080", nil)
}
