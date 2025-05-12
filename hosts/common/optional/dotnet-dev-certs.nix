{config, ...}: {
  ##dotnet dev-certs https --format PEM -ep server.crt
  sops.secrets.dotnet-dev-cert = {
    # owner = config.systemd.services.drone-server.serviceConfig.User;
  };
  # security.pki.certificates = [
  #   config.sops.secrets.dotnet-dev-cert.path
  # ];
  ##dotnet dev-certs https --format PEM -ep server.crt

  # security.pki.certificates = [
  #   ''
  #     -----BEGIN CERTIFICATE-----
  #     MIIDDDCCAfSgAwIBAgIIPc2VKViwjr0wDQYJKoZIhvcNAQELBQAwFDESMBAGA1UE
  #     AxMJbG9jYWxob3N0MB4XDTI0MTIxMjA3MTUzMVoXDTI1MTIxMjA3MTUzMVowFDES
  #     MBAGA1UEAxMJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
  #     AQEAuydbR+TfIRs0qX2d0D6t0shpG5tOOECMttBW0Sfgv9wERsP7h0L9pG++2+eD
  #     h//WMhJg4B1cL1/9+zj+eDyurwDaZ1vGHjeRAIFUkSsIsuF9PxtQ2E/dpmTg7u6e
  #     X+FvcUtKwKYzEY0G38CKVDittS5ePWSDXTF0N0KvrjU3w5mYB2uQdX5IjAH2Qchj
  #     nK0U9EzNgEsfAGiVTdwMBPykHcYbVb/GIa/QryvGF0AJU2TLU13awhdhZjJymu53
  #     VeC1WbFbvcl5FzaHHorKsM9DjHraGM2fMEQ6PvwnThevkI86cC82KxySMvRhwb8u
  #     YqRyEwn3Es0U2O/wFe+NvSoC+wIDAQABo2IwYDAMBgNVHRMBAf8EAjAAMA4GA1Ud
  #     DwEB/wQEAwIFoDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDATAXBgNVHREBAf8EDTAL
  #     gglsb2NhbGhvc3QwDwYKKwYBBAGCN1QBAQQBAjANBgkqhkiG9w0BAQsFAAOCAQEA
  #     fUkkh6JVoIjT9nPSmCOaiPOOT4zECmSn0QcTk5XAiOqBrD9jDU+qe6avKPO+fjuM
  #     8wGk0sj4+G09NmTgpmX/ibP8/rQOuBmLFAq+cqflDvjDmS7vIsKCTV/L7RKLDsJO
  #     uXxeuttWloYQeFv2hPmXlh8P2Im/JNtFXdS9afxrqdByy5NIoUy8/jDFxIvT49nW
  #     /Sa7bezx7I6xTIqjjB2HtgZg3QbTR9pJoamOLpIGgOZNSqfus/i94AA/CjUQ3Fqz
  #     CnHZ1IyloOyMqoaNgGzXJWfaMif4emxGTxYDghCde8Pp4XXfOMsykSVRX7yQx5Ay
  #     soBLSHJ2r0nFeF+o3AZhbA==
  #     -----END CERTIFICATE-----
  #   ''
  # ];
}
