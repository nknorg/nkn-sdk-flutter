package nkngolib

import (
	dnsresolver "github.com/nknorg/dns-resolver-go"
	ethresolver "github.com/nknorg/eth-resolver-go"
	"github.com/nknorg/nkn-sdk-go"
	"github.com/nknorg/nkngomobile"
	"golang.org/x/mobile/bind"
)

var (
	_ = nkn.NewStringArray
	_ = dnsresolver.NewResolver
	_ = ethresolver.NewResolver
	_ = nkngomobile.NewStringArray
	_ = bind.GenGo
)
