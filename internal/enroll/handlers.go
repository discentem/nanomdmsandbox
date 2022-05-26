package enroll

import (
	"fmt"
	"net/http"
	"os"
	"strconv"

	"github.com/discentem/nanomdmsandbox/pkg/enrollment"
	"github.com/groob/plist"
)

func printServerError(w http.ResponseWriter, statusCode int, err error) {
	bodyStr := fmt.Sprintf(`{"error": "%d", "status": %s }`, statusCode, err.Error())
	_, _ = w.Write([]byte(bodyStr))
	w.WriteHeader(statusCode)
	return
}

type HealthHandler struct {
}

func (h *HealthHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	_, err := w.Write([]byte(`{"status": "healthy"}`))
	if err != nil {
		printServerError(w, http.StatusInternalServerError, err)
	}
	w.WriteHeader(http.StatusOK)
	return
}

type EnrollHandler struct {
	BaseMdmUrl    string
	Company       string
	SCEPChallenge string
	PathToPEM     string
}

func (h *EnrollHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	profile, err := enrollment.EnrollmentProfile(
		h.BaseMdmUrl,
		h.Company,
		h.SCEPChallenge,
		h.PathToPEM)
	if err != nil {
		printServerError(w, http.StatusInternalServerError, err)
		return
	}

	bytes, err := plist.MarshalIndent(profile, "  ")
	if err != nil {
		printServerError(w, http.StatusInternalServerError, err)
		return
	}

	err = os.MkdirAll("enrollment", 0755)
	if err != nil {
		printServerError(w, http.StatusInternalServerError, err)
		return
	}

	err = os.WriteFile("enrollment/enrollment.mobileconfig", bytes, 0755)
	if err != nil {
		printServerError(w, http.StatusInternalServerError, err)
		return
	}

	w.Header().Set("Content-Disposition", "attachment; filename="+strconv.Quote("enrollment.mobileconfig"))
	w.Header().Set("Content-Type", "application/octet-stream")
	w.WriteHeader(http.StatusOK)
	http.ServeFile(w, r, "./enrollment/enrollment.mobileconfig")
	return
}
