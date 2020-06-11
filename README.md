# `postgres_as_app`: Hybrid RDS / custom Postgres / PostgREST deployment templated using AWS CloudFormation

This repository completes [this blog
post](https://bytes.yingw787.com/posts/2020/06/06/postgres_as_app/). See that
post for a higher-level discussion on system design.

## System Requirements

1.  Make sure to create an AWS root account. You can find additional steps to do
    so via [this AWS help
    page](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/).

2.  Install necessary system dependencies. This project requires
    [`curl`](https://github.com/curl/curl),
    [`awscli`](https://github.com/aws/aws-cli),
    [`docker`](https://github.com/docker/docker-ce) and
    [`docker-compose`](https://github.com/docker/compose), and
    [`make`](http://git.savannah.gnu.org/cgit/make.git). I'm using Ubuntu 20.04
    LTS, and my installation commands look something like this:

    ```bash
    $ sudo apt-get install -y curl
    $ sudo python -m pip install awscli
    $ sudo apt-get install -y docker.io
    $ sudo apt-get install -y docker-compose
    $ sudo apt-get install -y build-essential
    ```

    I'm currently running the following versions:

    ```bash
    $ aws --version
    aws-cli/1.18.35 Python/3.7.7 Linux/5.4.0-33-generic botocore/1.15.35
    $ docker --version
    Docker version 19.03.8, build afacb8b7f0
    $ docker-compose --version
    docker-compose version 1.23.2, build 1110ad01
    $ make --version
    GNU Make 4.2.1
    Built for x86_64-pc-linux-gnu
    Copyright (C) 1988-2016 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
    ```

3.  Create a set of root account key and secret pairs in the AWS console, and
    configure default profile key, secret, region, and format on your local
    system:

    ```bash
    $ aws configure
    AWS Access Key ID [****************XXXX]: $YOUR_AWS_ACCESS_KEY_ID
    AWS Secret Access Key [****************XXXX]: $YOUR_AWS_SECRET_ACCESS_KEY
    Default region name [us-east-1]: $YOUR_AWS_REGION
    Default output format [json]: $YOUR_OUTPUT_FORMAT
    ```

4.  (Optional, required for IAM setup) Download a TOTP app like [Google
    Authenticator](https://www.google-authenticator.com/) or
    [Authy](https://authy.com). Either should be fine. Set up your login. I
    combine Authy with [the Bitwarden password manager](https://bitwarden.com)
    for another layer of security.

## Getting Started

1.  If downloading from GitHub, `git` clone this repository:

    ```bash
    $ git clone https://github.com/yingw787/postgres_as_app
    ```

    If unzipping from releases, `unzip` this repository:

    ```bash
    $ unzip postgres_as_app.zip
    ```

## AWS Setup

### IAM

1.  Copy the file `${BASDIR}/infra-aws/iam.sample.json` to
    `${BASEDIR}/infra-aws/iam.json`, containing the following:

    ```json
    [
        {
            "ParameterKey": "IAMPassword",
            "ParameterValue": "$YOUR_PASSWORD_HERE"
        }
    ]
    ```

2.  Replace `$YOUR_PASSWORD_HERE` in `${BASEDIR}/infra-aws/iam.json with your
    preferred IAM user password. Note that the password must follow IAM password
    policies. In order to create a password that passes, run this command in
    your terminal:

    ```bash
    aws secretsmanager get-random-password --include-space --password-length 20   --require-each-included-type --output text
    ```

3.  Run `make create-iam`:

    ```bash
    $ cd ${BASEDIR}/infra-aws; make create-iam
    ```

    You should get a response like:

    ```bash
    $ make create-iam
    aws cloudformation create-stack --stack-name postgresasapp-iam --template-body file://iam.yaml --parameters file://iam.json --capabilities CAPABILITY_NAMED_IAM
    {
        "StackId": "$SAMPLE_ARN"
    }
    ```

    This details the "Amazon Resource Number", an AWS-specific UUID describing
    the created resource.
