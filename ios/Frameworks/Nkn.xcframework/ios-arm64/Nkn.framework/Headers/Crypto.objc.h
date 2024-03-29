// Objective-C API for talking to nkngolib/crypto Go package.
//   gobind -lang=objc nkngolib/crypto
//
// File is generated by gobind. Do not edit.

#ifndef __Crypto_H__
#define __Crypto_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


FOUNDATION_EXPORT NSData* _Nullable CryptoGetPrivateKeyFromSeed(NSData* _Nullable seed);

FOUNDATION_EXPORT NSData* _Nullable CryptoGetPublicKeyFromPrivateKey(NSData* _Nullable privateKey);

FOUNDATION_EXPORT NSData* _Nullable CryptoGetSeedFromPrivateKey(NSData* _Nullable priKey);

FOUNDATION_EXPORT NSData* _Nullable CryptoSign(NSData* _Nullable privateKey, NSData* _Nullable data, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT BOOL CryptoVerify(NSData* _Nullable publicKey, NSData* _Nullable data, NSData* _Nullable signature, NSError* _Nullable* _Nullable error);

#endif
