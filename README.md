# Envoi Transfer Service

Prerequisites

    - [Ruby](https://www.ruby-lang.org/en/documentation/installation/)
    - [Node](https://nodejs.org/en/download/package-manager)
    - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Install Bundler

```bash
gem install bundler
```

Install Aspera CLI

```bash
gem install aspera-cli
```

Add ascli to the bin path

```bash
sudo ln -s ~/.gem/bin/ascli /usr/local/bin/
```

Install Aspera Transfer Client (ascp)

```bash
ascli conf ascp install
```