# Create docker build server in Hetzner Cloud

Little helper that can create and destroy temporary docker build server.
I'm using it from time to time to build docker images on Hetzner Cloud if it is not possible to build it locally. (legacy code saying hello to the new Apple M1)

## Before you start

Make sure you have a working local docker installation and you have a Hetzner Cloud token for your project.

also you need to install Terraform (in my case via `brew`)

```sh
brew install terraform
```

## Additional preparations

Some little preparations are needed to make this work.

- clone this repo
- create a file `secrets.auto.tfvars` and add your Hetzner Cloud token: `hcloud_token = "<your_token>"`
- grant the script execution permission: `chmod +x builder.sh`
- make sure you have created ssh key and it's located in `~/.ssh/id_rsa.pub`. Otherwise you need to change the path in `main.tf` file.
  
## Usage

You can run the script just like that:

```sh
source ~/Projects/create-docker-build-server/builder.sh
```

It will ask you what you want to do. You can create a new server or destroy a previously created one.

After successful creation you will get the IP address of the server. It will be automatically added to your `DOCKER_HOST` ENV.
