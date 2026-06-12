#!/usr/bin/env bash
# Rule: BestPractices_Ensemble_IRIS.md §11.7 "SSL/TLS server certificate validation in IRIS — build the trusted CA chain"
# Validity: Still valid.
# Severity: High.
#
# Goal: enforce strict server-cert validation in an IRIS client SSL configuration.
#       1. Set "Server Certificate Validation = Require" on the SSL config.
#       2. Build the chain .PEM using IRIS-bundled openssl.

set -euo pipefail

HOSTNAME="${1:-example.com}"
PORT="${2:-443}"
IRIS_HOME="${IRIS_HOME:-/usr/irissys}"

# CRITICAL: -servername is REQUIRED for TLS Server Name Indication.
# Without it, s_client returns a default Kubernetes/wildcard cert and validation
# will fail mysteriously.
"$IRIS_HOME/bin/openssl" s_client \
    -servername "$HOSTNAME" \
    -connect "$HOSTNAME:$PORT" \
    -prexit \
    -showcerts \
    </dev/null > "$HOSTNAME.chain.raw" 2>/dev/null

# Output contains 2 certs (server + immediate CA). Append the ROOT CA fetched
# from the public source (e.g. USERTrust RSA Certification Authority) to complete the chain.
# Order in the file: server cert -> intermediate CA -> root CA.
#
# Optimisation: once the chain works, REMOVE the server's own cert from the .PEM file
# (keep only intermediate + root). The chain still validates because the server
# sends its own cert in the TLS handshake. This decouples the IRIS client config
# from the server's annual cert renewal cycle.

# Extract just the PEM blocks (drops openssl's negotiation noise):
awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "$HOSTNAME.chain.raw" \
    > "$HOSTNAME.chain.pem"

echo "Chain written to $HOSTNAME.chain.pem"
echo "Next: append the root CA, install into IRIS SSL config, then drop the server cert (optimisation)."
