package main

import (
	"bytes"
	"compress/gzip"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

// APIResponse is the structure returned by the Reputation end point
type APIResponse struct {
	Version int
	Data    []Account
	Format  string
}

// Account is the structure defining an account
type Account struct {
	AccountName     string
	Characters      []string
	Guild           string
	GuildID         string
	SponsorMessage  string
	CommunityFigure bool
	Reputation      map[string]Reputation
}

// Reputation represents an accumulation of reviews
type Reputation struct {
	Count   int
	Reviews []string
}

func main() {
	argsWithProg := os.Args
	if len(argsWithProg) > 1 {
		resp, err := http.Get("http://rep.poeledger.com/Reputation?varsion=1&characters=" + argsWithProg[1])
		if err != nil {
			fmt.Println(err)
			return
		}
		defer resp.Body.Close()

		// Decode the response
		var reader io.ReadCloser
		switch resp.Header.Get("Content-Encoding") {
		case "gzip":
			reader, err = gzip.NewReader(resp.Body)
			defer reader.Close()
		default:
			reader = resp.Body
		}
		apiResponse, err := decodeAccount(reader)
		if err != nil {
			fmt.Println(err)
			return
		}

		// Format our output data
		outputContent := "" //apiResponse.Format
		if len(apiResponse.Data) > 0 {
			for j, account := range apiResponse.Data {
				if j > 0 {
					outputContent += fmt.Sprintf("\n------------------------------------------\n")
				}
				outputContent += fmt.Sprintf("Account Name:        %s\n", account.AccountName)
				outputContent += fmt.Sprintf("Character Name:      %s\n", account.Characters[0])
				if account.SponsorMessage != "" {
					lines := strings.Split(account.SponsorMessage, "\\n")
					for _, line := range lines {
						outputContent += fmt.Sprintf("%s\n", line)
					}
				}
				if account.CommunityFigure {
					outputContent += fmt.Sprintf("This account has a level of fame within the POE community that means their reviews might not be true.\n")
				}
				outputContent += fmt.Sprintf("Net Reputaiton:      %d\n", account.Reputation["Good"].Count-account.Reputation["Bad"].Count)
				outputContent += fmt.Sprintf("Positive Reputaiton: %d\n", account.Reputation["Good"].Count)
				for i, review := range account.Reputation["Good"].Reviews {
					outputContent += fmt.Sprintf("  %d) %s\n", i, review)
				}
				outputContent += fmt.Sprintf("Negative Reputaiton: %d\n", account.Reputation["Bad"].Count)
				for i, review := range account.Reputation["Bad"].Reviews {
					outputContent += fmt.Sprintf("  %d) %s", i, review)
					if i < len(account.Reputation["Bad"].Reviews) {
						outputContent += fmt.Sprintf("\n")
					}
				}
			}
		}

		// Create the output file
		path := "./repChecks/"
		if _, err := os.Stat(path); os.IsNotExist(err) {
			os.Mkdir(path, os.ModeDir)
		}
		f, err := os.Create(path + argsWithProg[1] + ".txt")
		if err != nil {
			fmt.Println(err)
			return
		}
		defer f.Close()
		buf := new(bytes.Buffer)
		buf.WriteString(outputContent)
		// buf.ReadFrom(resp.Body)
		buf.WriteTo(f)
	}
}

func decodeAccount(data io.Reader) (*APIResponse, error) {
	dec := json.NewDecoder(data)
	JSONObject := APIResponse{}
	err := dec.Decode(&JSONObject)
	if err != nil {
		return nil, err
	}
	return &JSONObject, nil
}
