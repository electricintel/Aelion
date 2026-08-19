#include <windows.h>
#include <wincrypt.h>
#include <stdio.h>
#include "aelion_hash.h"

int aelion_hash_file(const char *path, char *out_hex) {
    HCRYPTPROV hProv = 0;
    HCRYPTHASH hHash = 0;
    BYTE buffer[4096];
    DWORD bytesRead = 0;
    BYTE hash[32]; // SHA-256 = 32 bytes
    DWORD hashLen = 32;

    FILE *f = fopen(path, "rb");
    if (!f)
        return 1;

    if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        fclose(f);
        return 1;
    }

    if (!CryptCreateHash(hProv, CALG_SHA_256, 0, 0, &hHash)) {
        CryptReleaseContext(hProv, 0);
        fclose(f);
        return 1;
    }

    while ((bytesRead = fread(buffer, 1, sizeof(buffer), f)) > 0) {
        if (!CryptHashData(hHash, buffer, bytesRead, 0)) {
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            fclose(f);
            return 1;
        }
    }

    fclose(f);

    if (!CryptGetHashParam(hHash, HP_HASHVAL, hash, &hashLen, 0)) {
        CryptDestroyHash(hHash);
        CryptReleaseContext(hProv, 0);
        return 1;
    }

    CryptDestroyHash(hHash);
    CryptReleaseContext(hProv, 0);

    // Convert to hex
    for (DWORD i = 0; i < hashLen; i++) {
        sprintf(out_hex + (i * 2), "%02x", hash[i]);
    }

    return 0;
}
