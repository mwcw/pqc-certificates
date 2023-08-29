# IETF Hackathon - PQC Certificates

This project provides a set of data repositories for X.509 data
structures that make use of post-quantum and composite algorithms
(classic with PQC).

This repo represents work done between IETF 115 - 117.

A summary table of the ongoing interoperability testing can be found here:
https://ietf-hackathon.github.io/pqc-certificates/pqc_hackathon_results.html

## Goals
- Adding PQ algorithm support into existing X.509 structures (keys, signatures, certificates and protocols)
- Test and interoperate with newer draft updated to support the migration to PQ 
- provide an artifact repository for interoperability testing
- Provide a comprehensive compatibility matrix to show results
- Provide feedback to the standards groups about practical usage

## Folder structure of this repo

The project's directory structure is as follows:

~~~
    - main_project_dir
    - Makefile
    - docs/
    - providers/
        - provider_name_1/
            - implementation_name_1/
                - artifacts.zip
            - implementation_name_2/
                - artifacts.zip
            - compatMatrices
                - prov2_prov1.csv
                - prov3_prov1.csv
                - ...
            - gen.sh
            - check.sh
            - Makefile
                - unzip, generate, verify, and cross_verify targets
        - provider_name_2
            - implementation_name_1
            - ...
~~~

Where:

  * The `Makefile` provides few useful targets for generating data
    (for open-source packages) and/or validating the distributed
    artifacts. 
    
    Required targets to be supported are:
    * **unzip** - decompresses the `artifacts.zip`, if any

    * **generate** - generates the directory structure (might require
      local tools) (requires `gen.sh`)
    
    * **verify** - verifies the provided artifacts material for
      the entire provider (requires `check.sh`). The material can
      be either generated (`gen.sh`) and/or directly provided in
      the package (`artifacts.zip`)
    
    * **cross_verify** - verifiers the decompressed artifacts material
        from a different directory that is passed as the argument
        to the `check.sh` script

  * The `docs` directory contains the extended documentation related
    to this project.

  * The `providers` directory is where the core of the data is kept.
    Each provider must come with a `bin` directory where the `gen.sh`
    and `check.sh` scripts must be stored (more on this later).
    Each provider sub directory also contains one directory for each
    different implementation from the provider (if more than one),
    inside each directory, the artifacts.zip file must be present
    carrying the X.509 structures (e.g., keys, requests, certs, etc.)
    generated via the implementation. See the `Zip format` section
    for more information about its structure.

## Zip Format (R3)

### Certificates - artifacts_certs_r3.zip

Starting with artifacts for the NIST Draft standards released 2023-08-24, we will use a much simpler artifact format:

* Only produce a self-signed certificate (TAs). Let's not bother with CA / EE / CRL / OCSP; those are begging for compatibility issues that have nothing to do with the PQ algs.
* We will restrict the R3 artifacts to only the algorithms with NIST draft standards.
* Use PEM formats.
* Switch to a flat folder structure with filenames <oid>_ta.pem
* For Kyber, use the the Dilithium TA of the equivalent security level to sign a <kyber_oid>_ee.pem

Within `providers/<provider_name>/`
- artifacts_certs_r3.zip
  - 1.3.6.1.4.1.2.267.7.4.4_ta.pem  # Dilithium2
  - 1.3.6.1.4.1.2.267.7.6.5_ta.pem  # Dilithium3
  - 1.3.6.1.4.1.2.267.7.8.7_ta.pem  # Dilithium5
  - 1.3.6.1.4.1.22554.5.6.1_ee.pem  # Kyber512  - signed with Dilithium2
  - 1.3.6.1.4.1.22554.5.6.2_ee.pem  # Kyber768  - signed with Dilithium3
  - 1.3.6.1.4.1.22554.5.6.3_ee.pem  # Kyber1024 - signed with Dilithium5
  - 1.3.9999.6.4.13_ta.pem  # SPHINCS+-SHA2-128f-simple
  - 1.3.9999.6.4.16_ta.pem  # SPHINCS+-SHA2-128s-simple
  - 1.3.9999.6.5.10_ta.pem  # SPHINCS+-SHA2-192f-simple
  - 1.3.9999.6.5.12_ta.pem  # SPHINCS+-SHA2-192s-simple
  - 1.3.9999.6.6.10_ta.pem  # SPHINCS+-SHA2-256f-simple
  - 1.3.9999.6.6.12_ta.pem  # SPHINCS+-SHA2-256s-simple
  - 1.3.9999.6.7.4_ta.pem   # SPHINCS+-SHAKE128f-simple
  - 1.3.9999.6.8.3_ta.pem   # SPHINCS+-SHAKE192f-simple
  - 1.3.9999.6.9.3_ta.pem   # SPHINCS+sSHAKE256f-simple

### CMS -- artifacts_cms.zip

CMS artficats should be placed into a `artifacts_cms.zip` within `providers/<provider_name>/`. We will specify the exact file format when we start to see more robust artifacts submitted.

### CMP -- artifacts_cmp.zip

CMP artficats should be placed into a `artifacts_cmp.zip` within `providers/<provider_name>/`. We will specify the exact file format when we start to see more robust artifacts submitted.

## Old Zip Format (R2)

OLD -- IF YOU ARE SUBMITTING ARTIFACTS AGAINST THE NIST DRAFT SPECS AS OF 2023-08-24, THEN PLEASE USE THE R3 FORMAT ABOVE.

At the hackathon, we are all going to script our PKI toolkit to produce and read zip bundles of certs in the following format. Scripts should place data into files with the following names so that parsing scripts 

(parentheses denotes optional files)

- artifacts_r2.zip
  - artifacts/
    - alg_oid_dir/
        - ta/     # trust anchor, aka root CA, aka self-signed
            - ta.der
            - ta_priv.der
            - (*.pem)
        - ca/     # certificate authority, aka intermediate CA
            - ca.der
            - ca_priv.der
            - (*.pem)
        - ee/     # end entity
            - cert.der
            - cert_priv.der    # corresponding private key
            - cert.csr
            - (*.pem)
        - (crl/)
            - crl_ta.crl
            - crl_ca.crl
        - (ocsp/)
            - ocsp.der           /* R1 */
            - (ocsp_ca.der)      /* R2 */
            - (ocsp_cert.der)    /* R2 */

NOTE: The OCSP filename has changed from R1 (ocsp.der) to R2 (ocsp_ca.der)
      amd ocsp_cert.der for the OCSP responses for the Intermediate CA and
      the EE certificate.

## OIDs

The OID mappings to be used for this hackathon are documented in [oid_mapping.md](docs/oid_mapping.md).

## Unzipping Artifacts

The repository comes with a Makefile that is meant to ease and automate
the operations for unzipping, generating, and validating the artifacts
provided.

To accommodate for different options from different providers, there
are three primary targets for the Makefile:

  * `unzip` - Uncompresses all the artifacts archives from all the
    providers, if present;

  * `gen` - Generates new artifacts in all providers who support this
    option. In order to generate the artifacts you need to have all
    the requirements for the provider satisfied. Please refer to the
    provider directory's readme.md or the docs directory for further
    details; Providers that wish to provide the generation option are
    required to provide the `gen.sh` script in their directory.

  * `verify` - Verifies the presence and validity of the artifacts
    for the individual providers. Providers that wish to provide the
    functionality they are required to provide the `check.sh` script.

  * `cross_verify` - Runs the verify scripts from each provider by
    using the material from a different provider. Providers that wish
    to provide this functionality must provide the `check.sh` script
    for 

Specifically, to unzip all the artifacts from all the providers, simply
use the following:
```
$ make unzip
```

To run the verify for all the providers:
```
$ make verify
```

To run the verify from a single provider, simply change the directory
to the specific provider and run the same command:
```
$ cd providers/<provider_name>
$ make verify
```

# Interoperability Results

Interop results are documented in [compat_matrix.md](docs/compat_matrix.md).
