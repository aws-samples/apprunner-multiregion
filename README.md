# apprunner-multiregion

This project contains infrastructure and application source code for deploying a sample, highly resilient, multi-region application running on AWS AppRunner and DynamoDB.  It contains the companion source code for the [Architecting for Resiliency using AWS App Runner blog post]().  The IaC code is written in Terraform and the application code is written in Go and Next.js.


## Usage

1. Clone this git repository

2. Update the Terraform input variables [here](./iac/base/terraform.tfvars), [here](./iac/region-a/terraform.tfvars), and [here](./iac/region-b/terraform.tfvars) to specify the app name, regions, and Route53 Hosted zone that you'd like to use.

3. Run `make init` to provision the AWS resources

4. After the command completes and the custom domain has been validated (this can take some time), you should be able to access the application at the URL specified in the `custom_service_url` output value. 


At this point, you should have an application running in whichever two AWS regions you set in the `terraform.tfvars` files.

From this point on you can iterate on the source code and then run `make deploy` to build a new container image and deploy it to both regions.

If you wish to tear down the application, you can run `make destroy` to deprovision the resources that were created in your AWS account.


## Dependencies


### Deployment

The following are the minimum required dependencies needed to deploy the solution.

- AWS CLI v2
- Terraform >= v1
- Docker Desktop >= v1 OR Docker CE >= v20


## Development

If you wish to make changes to the application code and build it (outside of Docker) then you'll need to install the following.

- Go >= v1.18
- Nodejs >= v16


### asdf Version Manager

A [.tool-versions](./.tool-versions) file is included which lets you optionally use the [asdf](https://asdf-vm.com/) tool to install the dependencies via `asdf install`.  [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [Docker Desktop](https://www.docker.com/products/docker-desktop/) are typically installed separately.


### AWS Cloud9

If you choose to use Cloud9 for your development environment, it comes with the following dependencies pre-installed.

- Docker CE
- Terraform
- AWS CLI v1 (you'll need to [upgrade to v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- Nodejs
- Go (you'll need to [upgrade to the latest](https://go.dev/doc/install))
