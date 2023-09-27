# Envoi Transfer Service - Scripts

## s3-to-step-function

Takes in a bucket name, object key prefix, and state machine arn then creates
a list of matching objects from the bucket and submits each of those objects

### Installation

The script needs the `aws-sdk-s3` and `aws-sdk-states` gems to operate. You 
can install these by having ruby installed and running the following command:

```bash
gem install aws-sdk-s3 aws-sdk-states
```