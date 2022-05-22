// Stolen with <3 from https://github.com/micromdm/go4/blob/master/env/env.go

package env

import (
	"os"
	"strconv"
	"strings"
)

// String returns the environment variable value specified by the key parameter,
// otherwise returning a default value if set.
func String(key, def string) string {
	if env, ok := os.LookupEnv(key); ok {
		return env
	}
	return def
}

// Bool returns the environment variable value specified by the key parameter,
// otherwise returning a default value if set.
func Bool(key string, def bool) bool {
	switch env := os.Getenv(key); strings.ToLower(env) {
	case "true", "yes", "1":
		return true
	case "false", "no", "0":
		return false
	}
	return def
}

// Int returns the environment variable value specified by the key parameter,
// otherwise returning a default value if set.
func Int(key string, def int) int {
	env := os.Getenv(key)
	if i, err := strconv.Atoi(env); err == nil {
		return i
	}
	return def
}
