package main

import (
	"io/ioutil"
	"testing"

	"github.com/davecgh/go-spew/spew"
	"github.com/docker/go-plugins-helpers/authorization"
)

func TestNormalizeAllowPath(t *testing.T) {
	tests := []struct {
		input    string
		useConf  bool
		expected string
	}{
		{
			input:    "data.policy.rule",
			useConf:  true,
			expected: "/policy/rule",
		},
		{
			input:    "data.policy.rule",
			useConf:  false,
			expected: "data.policy.rule",
		},
		{
			input:    "/policy/rule",
			useConf:  true,
			expected: "/policy/rule",
		},
		{
			input:    "/policy/rule",
			useConf:  false,
			expected: "data.policy.rule",
		},
		{
			input:    "",
			useConf:  true,
			expected: "",
		},
	}

	for _, tc := range tests {
		t.Run("Normalize allowPath", func(t *testing.T) {
			result := normalizeAllowPath(tc.input, tc.useConf)
			if result != tc.expected {
				t.Errorf("Expected %v, got %v", tc.expected, result)
			}
		})
	}
}

func TestInput(t *testing.T) {
	rawBody, err := ioutil.ReadFile("./input.json")
	if err != nil {
		t.Fatal(err)
	}

	request := authorization.Request{
		RequestBody: rawBody,
		RequestHeaders: map[string]string{
			"Content-Type": "application/json",
		},
		RequestURI: "http://127.0.0.1:2376/v1.41/containers/create",
	}

	input, err := MakeInput(request)
	if err != nil {
		t.Fatal(err)
	}

	spew.Dump(input)
}
