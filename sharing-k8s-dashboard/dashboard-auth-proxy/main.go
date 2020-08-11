package main

import (
	"crypto/tls"
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
)

func main() {
	config, err := loadConfigFromEnv()
	if err != nil {
		panic(err)
	}
	reverseProxy := httputil.NewSingleHostReverseProxy(config.proxyURL)
	// The default Director builds the request URL. We want our custom Director to add Authorization, in
	// addition to building the URL
	singleHostDirector := reverseProxy.Director
	reverseProxy.Director = func(r *http.Request) {
		singleHostDirector(r)
		r.Header.Add("Authorization", fmt.Sprintf("Bearer %s", config.token))
		fmt.Println("request header", r.Header)
		fmt.Println("request host", r.Host)
		fmt.Println("request ULR", r.URL)
	}
	reverseProxy.Transport = &http.Transport{
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: true,
		},
	}
	server := http.Server{
		Addr:    config.listenAddr,
		Handler: reverseProxy,
	}
	server.ListenAndServe()
}

type config struct {
	listenAddr string
	proxyURL   *url.URL
	token      string
}

func loadConfigFromEnv() (*config, error) {
	listenAddr, err := requireEnv("LISTEN_ADDRESS")
	if err != nil {
		return nil, err
	}
	proxyURLStr, err := requireEnv("DASHBOARD_PROXY_URL")
	if err != nil {
		return nil, err
	}
	proxyURL, err := url.Parse(proxyURLStr)
	if err != nil {
		return nil, err
	}
	token, err := requireEnv("DASHBOARD_TOKEN")
	if err != nil {
		return nil, err
	}
	return &config{
		listenAddr: listenAddr,
		proxyURL:   proxyURL,
		token:      token,
	}, nil
}

func requireEnv(key string) (string, error) {
	result := os.Getenv(key)
	if result == "" {
		return "", fmt.Errorf("%v not provided", key)
	}
	return result, nil
}
