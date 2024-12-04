# Envoi Transfer Service

## Running Locally 

Prerequisites

- [Ruby](https://www.ruby-lang.org/en/documentation/installation/)
- [Node](https://nodejs.org/en/download/package-manager)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Installation

Install Bundler

```bash
gem install bundler
```

Install the application dependencies

```bash
bundle install
gem install aspera-cli
```

Create a link for ascli in the user local bin directory

```bash
sudo ln -s ~/.gem/bin/ascli /usr/local/bin/
```

Install Aspera Transfer Client (ascp)

```bash
ascli conf ascp install
```

### Ubuntu
#### Installation

```shell
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y ruby-dev
sudo apt-get install -y build-essential
sudo gem install bundler
sudo gem install aspera-cli
sudo mkdir -p /opt/envoi
sudo chown -R ubuntu:ubuntu /opt/envoi
cd /opt/envoi
git clone https://github.com/envoi-io/envoi-transfer-service.git
cd /opt/envoi/envoi-transfer-service/src/envoi-transfer-worker
sudo bundle install
```

#### Configuration
```shell
export AWS_REGION=us-east-1
export ACTIVITY_ARN=arn:aws:states:us-east-1:123456789:activity:transferFile
```

#### Execution

```shell
bundle exec exe/envoi-transfer-worker
```

## Other Commands

## Launching an Instance for Imaging
```shell
bash <(curl -s https://raw.githubusercontent.com/envoi-io/envoi-transfer-service/main/src/envoi-transfer-worker/scripts/launch-instance-for-imaging)
```


## Creating an Image
```shell
 aws ec2 create-image --instance-id ${INSTANCE_ID}
```


## Launch an Instance from an Image
```shell
bash <(curl -s https://raw.githubusercontent.com/envoi-io/envoi-transfer-service/main/src/envoi-transfer-worker/scripts/launch-instance)
```


## Launch Instance and Install Worker
```shell
bash <(curl -s https://raw.githubusercontent.com/envoi-io/envoi-transfer-service/main/src/envoi-transfer-worker/scripts/launch-instance-and-install)
```

```
./launch-instance-and-install
Enter the name of the instance (envoi-transfer-worker): 
Please select a key pair:
0) kj-envoi-services-us-east-1
1) studio-833740154547-us-east-1-prod
c) Create a new key pair
Enter the number of the key pair you want to select or 'c' to create a new key pair: 0
You selected key pair: kj-envoi-services-us-east-1
Please select a security group:
0) aspera
1) CloudDat
2) CloudDat
3) default
4) default
5) default
6) default
7) diskover
8) docdb-ec2-envoi-docdb-2024-04-02-09-02-27:i-03b5c547dad73ffc1
9) ec2-docdb-envoi-docdb-2024-04-02-09-02-27:i-03b5c547dad73ffc1
10) envoi-dev-macos
11) envoi-dev-server
12) envoi-dev-server
13) envoi-prod-utility
14) Hourly-1.20C-221011-AutogenByAWSMP--1
15) Hourly-1.20C-221011-AutogenByAWSMP--2
16) instance-Ec2-server
17) launch-wizard-1
18) launch-wizard-2
19) launch-wizard-3
20) launch-wizard-4
21) launch-wizard-5
c) Create a new security group
Enter the number of the security group you want to select or 'c' to create a new security group: 11
You selected security group: envoi-dev-server
Enter the ARN of the activity to use: abc
envoi-transfer-worker kj-envoi-services-us-east-1 ami-0cfa2ad4242c3168d t3.large
```

## Latest Installation Script

Installation onto an Ubuntu 20.04 instance using AMI [ami-053b0d53c279acc90](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#ImageDetails:imageId=ami-053b0d53c279acc90)
with an image name of `ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516`

If using the default ACTIVITY_ARN be sure to set the AWS_REGION and AWS_ACCOUNT_ID environment variables before running the script

```shell
sudo mkdir -p /opt/envoi/envoi-transfer-worker
sudo chown -R ubuntu:ubuntu /opt/envoi
sudo pro status
sudo apt-get update
sudo apt-get upgrade
sudo snap install ruby --classic
sudo snap install node --classic
gem install bundler
sudo gem update --system 3.4.19
gem install aspera-cli
sudo ln -s ~/.gem/bin/ascli /usr/local/bin/
which ascli
ascli conf ascp install
cat .aspera/sdk/aspera.conf

tar czvf aspera.tgz .aspera
ascli config wizard --query=aoc
cd /opt/envoi
mkdir envoi-transfer-service
cd envoi-transfer-service

# === PULL REPOS ===
git clone https://github.com/envoi-io/envoi-transfer-service.git

cd /opt/envoi/envoi-transfer-service/src/envoi-transfer-worker/
chmod +x exe/envoi-transfer-worker
bundle install
export AWS_REGION=us-east-1
export ACTIVITY_ARN=arn:aws:states:$AWS_REGION:$AWS_ACCOUNT_ID:activity:transferFileDev
bundle exec exe/envoi-transfer-worker
```