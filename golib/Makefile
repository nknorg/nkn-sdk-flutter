.DEFAULT_GOAL:=all

USE_PROXY=GOPROXY=https://goproxy.io
BIN_NAME=nkn

PHONY: all apk app

all: apk app

app:
	gomobile bind -target=ios -ldflags "-s -w" github.com/nknorg/nkn-sdk-go github.com/nknorg/ncp-go github.com/nknorg/nkn/v2/transaction

apk:
	gomobile bind -target=android -ldflags "-s -w" github.com/nknorg/nkn-sdk-go github.com/nknorg/ncp-go github.com/nknorg/nkn/v2/transaction
