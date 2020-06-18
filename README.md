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

## Local Setup

Assuming that all commands are run from `${BASEDIR}/services/`.

1.  Stand up the `docker-compose` stack:

    ```shell
    make up
    ```

2.  In your origin database  (`make origindb-psql`), create a table:

    ```sql
    somedb=# CREATE TABLE todos (col1 VARCHAR(256), col2 VARCHAR(256));
    CREATE TABLE
    somedb=# INSERT INTO todos (col1, col2) VALUES ('cat', 'dog');
    INSERT 0 1
    somedb=#
    ```

3.  In your custom database (`make customdb-psql`), create a `postgres_fdw`
    extension:

    ```sql
    mydb=# CREATE EXTENSION postgres_fdw;
    CREATE EXTENSION
    ```

4.  In your custom database (`make customdb-psql`), create a server referencing
    your origin database:

    ```sql
    mydb=# CREATE SERVER origindb FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'origindb', port '5432', dbname 'somedb');
    CREATE SERVER
    ```

5.  In your custom database (`make customdb-psql`), create a user mapping to map
    permissions between your user on the custom database and a user on the
    origin database:

    ```sql
    mydb=# CREATE USER MAPPING FOR myuser SERVER origindb OPTIONS (user 'someuser', password 'somepassword');
    CREATE USER MAPPING
    ```

6.  In your custom database (`make customdb-psql`), create a foreign table
    referencing the table in the origin database:

    ```sql
    mydb=# CREATE FOREIGN TABLE todos (col1 VARCHAR(256), col2 VARCHAR(256)) SERVER origindb OPTIONS (schema_
    name 'public', table_name 'todos');
    CREATE FOREIGN TABLE
    ```

    You can see the table using `make -f services/Makefile customdb-psql` and
    the `psql` command `\dE[S+]`:

    ```sql
    mydb=# \dE[S+]
                            List of relations
    Schema | Name  |     Type      | Owner  |  Size   | Description
    --------+-------+---------------+--------+---------+-------------
    public | todos | foreign table | myuser | 0 bytes |
    (1 row)

    mydb=#
    ```

7.  Open up `localhost:3000` in order to see the PostgREST server connectedto
    your custom database up and running, and `localhost:3000/todos` in order to
    see the foreign table reference.

8.  To tear down the `docker-compose` stack, run:

    ```bash
    make down
    ```

9.  (OPTIONAL) To publish the custom database Dockerfile to Docker Hub, run:

    ```bash
    make publish-customdb
    ```

    Take care to change `$(DOCKER_HUB_USERNAME)` to your Docker Hub username.

10. (OPTIONAL) To publish the PostgREST Dockerfile to Docker Hub, run:

    ```bash
    make publish-postgrest
    ```

## AWS Setup

Assuming that all commands are run from `${BASEDIR}/infra-aws/`.

**NOTE**: Deployment targets (`deploy-$SOMETHINg`) assume no changes in AWS
CloudFormation input parameters. In order to override parameters, the command
needs to be copied and pasted into the terminal, with the flag
`--parameter-overrides` passed in. See [the documentation for `aws
cloudformation
deploy`](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/deploy/index.html)
for more details.

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
    $ make create-iam
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

    After AWS CloudFormation finishes creating the stack with response
    `CREATE_COMPLETE` (which you can see either by logging into the AWS
    CloudFormation console, or by running `make wait-iam`), you can begin
    setting up local references for this user.

4.  In the AWS console, take your root account ID, your newly created IAM user
    ID `postgresasapp-user`, and your IAM user password `IAMPassword`, to log
    into a session of AWS console.

5.  Open `Services | IAM`, and in `Users | postgresasapp-user | Security
    Credentials`, add an MFA device in `Assigned MFA Device`. Register your MFA
    device, then log out and log back in using the same root account ID, IAM
    user ID, and IAM user password. This time, the console should prompt you for
    an MFA code. Enter the code from your authenticator app and login.

6.  On the right-hand side of the top navbar, click on "Switch Role", just above
    "Sign Out. Switch role to role `postgresasapp-admin`, using your root AWS
    account ID and role `postgresasapp-admin`.

    You should now have access to all AWS resources after switching to this
    role, and confirmed signing into your IAM user with an MFA device grants you
    access to all AWS resources.

7.  In order to run further AWS commands in the terminal, you need a set of AWS
    credentials saved onto your local computer. In the AWS console, in window
    `Services | IAM`, and in window `Users | postgresasapp-user | Security
    Credentials`, click on "Create Access Key". This should create a key/secret
    pair for you to download.

8.  On your local machine, configure your new user by running `aws configure
    --profile postgresasapp-user`. This should properly configure
    `~/.aws/credentials`.

9.  At this point, you need to configure `~/.aws/config` in order to enable MFA
    login within the terminal. Take the section of `~/.aws/config` that matches
    your IAM user:

    ```text
    [profile postgresasapp-user]
    region = us-east-1
    output = json
    ```

    And replace it with this new section to properly configure MFA via CLI:

    ```text
    [profile postgresasapp-user]
    source_profile = postgresasapp-user
    role_arn = arn:aws:iam::${RootAWSAccountID}:role/postgresasapp-admin
    role_session_name=postgresasapp-user
    mfa_serial = arn:aws:iam::${RootAWSAccountID}:mfa/postgresasapp-user
    region = us-east-1
    output = json
    ```

10. Finally, export `AWS_PROFILE` as `postgresasapp-user` to avoid piping
    `--profile` into `aws` commands:

    ```bash
    export AWS_PROFILE=postgresasapp-user
    ```

    You should now be able to lift into admin role via MFA on the CLI.

11. As a sanity check, run the following test command:

    ```bash
    aws s3 ls
    ```

    This command should prompt you for an MFA token. After successful MFA
    validation, it should then give the appropriate response (no S3 buckets
    created) without erroring out.

12. To deploy changes to the IAM user, make your changes in `iam.yaml`, then
    run:

    ```bash
    make deploy-iam
    ```

13. To tear down the IAM user, run:

    ```bash
    make terminate-iam
    ```

14. To wait until the IAM user has been successfully created, run:

    ```bash
    make wait-iam
    ```

### VPC

1.  To create the VPC, run:

    ```bash
    make create-vpc
    ```

2.  To deploy changes to the VPC, make your changes in `vpc.yaml`, then
    run:

    ```bash
    make deploy-vpc
    ```

3.  To tear down the VPC, run:

    ```bash
    make terminate-vpc
    ```

4.  To wait until the VPC has been successfully created, run:

    ```bash
    make wait-vpc
    ```

### RDS

1.  Copy the file `${BASDIR}/infra-aws/rds.sample.json` to
    `${BASEDIR}/infra-aws/rds.json`, containing the following:

    ```json
    [
        {
            "ParameterKey": "DatabaseUsername",
            "ParameterValue": "$YOUR_USERNAME_HERE"
        },
        {
            "ParameterKey": "DatabasePassword",
            "ParameterValue": "$YOUR_PASSWORD_HERE"
        }
    ]
    ```

2.  Replace `$YOUR_USERNAME_HERE` in `${BASEDIR}/infra-aws/rds.json` with your
    preferred RDS master username, and `$YOUR_PASSWORD_HERE` in
    `${BASEDIR}/infra-aws/rds.json with your preferred RDS master password.

3.  Run `make create-rds`:

    ```bash
    $ make create-rds
    ```

4.  To deploy changes to the RDS instance, make your changes in `rds.yaml`, then
    run:

    ```bash
    make deploy-rds
    ```

5.  To tear down the RDS instance, run:

    ```bash
    make terminate-rds
    ```

6.  To wait until the RDS instance has been successfully created, run:

    ```bash
    make wait-rds
    ```

7.  To connect to the RDS instance via `psql`, run:

    ```bash
    make rds-psql
    ```

### Custom DB persist

1.  To create the custom database persist layer, run:

    ```bash
    $ make create-persist
    ```

2.  To deploy changes to the custom database persist layer, run:

    ```bash
    $ make deploy-persist
    ```

3.  To tear down the custom database persist layer, run:

    ```bash
    $ make terminate-persist
    ```

4.  To wait until the custom database persist layer has been successfully
    created, run:

    ```bash
    $ make wait-persist
    ```

### Custom DB / PostgREST compute

1.  Login to the [AWS EC2 console](https://console.aws.amazon.com/ec2) for your
    specific region.

2.  Under 'Network & Security', select 'Key Pairs' to see the 'Key Pair' window.
    In the top-right corner, click on the orange button "Create key pair". This
    should open a new window.

3.  Give a name to your keypair, like `admin`. Select `.pem` for your file
    format, then click "Create key pair" in the bottom-right corner of the form.

4.  Download your keypair `.pem` file to your local computer, and save it as
    `/path/to/file.pem`.

5.  Copy the file `${BASDIR}/infra-aws/compute.sample.json` to
    `${BASEDIR}/infra-aws/compute.json`, containing the following:

    ```json
    [
        {
            "ParameterKey": "EC2KeyPair",
            "ParameterValue": "$YOUR_EC2_KEYPAIR"
        }
    ]
    ```

6.  Replace `$YOUR_EC2_KEYPAIR` in `${BASEDIR}/infra-aws/compute.json` with your
    EC2 keypair. This will allow you to SSH into the EC2 instance, which grants
    you access to the ECS Docker container runtimes, by running `ssh -i
    /path/to/file.pem ec2-user@$YOUR_EC2_IPV4_ADDRESS`.

7.  To create the custom database / app compute node, run:

    ```bash
    $ make create-compute
    ```

8.  To deploy changes to the custom database / app compute node, run:

    ```bash
    $ make deploy-compute
    ```

9.  To tear down the custom database / app compute node, run:

    ```bash
    $ make terminate-compute
    ```

10. To wait until the custom database / app compute node has been successfully
    created, run:

    ```bash
    $ make wait-compute
    ```

11. To connect to the custom database instance using `psql`, run:

    ```bash
    make compute-psql
    ```
