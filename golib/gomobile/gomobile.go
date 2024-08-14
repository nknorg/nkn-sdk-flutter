package gomobile

import (
	dnsresolver "github.com/nknorg/dns-resolver-go"
	"github.com/nknorg/nkn-sdk-go"
	"github.com/nknorg/nkngomobile"
	"github.com/pion/webrtc/v4"
	"golang.org/x/mobile/bind"
)

var (
	_ = nkn.NewStringArray
	_ = dnsresolver.NewResolver
	_ = nkngomobile.NewStringArray
	_ = webrtc.NewAPI
	_ = bind.GenGo
)
