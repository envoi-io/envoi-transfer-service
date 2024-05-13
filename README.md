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

