# Building and Publishing the SimpleTimeService Docker Image

This guide walks you through building the Docker image for SimpleTimeService and publishing it to Docker Hub.


----



## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system.
- A [Docker Hub](https://hub.docker.com/) account.
- [Terraform CLI Installed](https://developer.hashicorp.com/terraform/install#windows)


----



## 1. Clone or Download the Source Code

Clone the repository that contains the `Dockerfile` and application code:

```
git clone <your-repo-url>
cd <your-repo-name>
```

2. Build the Docker Image
   Build the image locally using the provided Dockerfile.
Replace <your-dockerhub-username> with your Docker Hub username.

```
docker build -t <your-dockerhub-username>/simpletimeservice:latest .
```

3. Test the Image Locally (Optional)
Run the container to ensure it works as expected:


```
docker run -p 8080:8080 <your-dockerhub-username>/simpletimeservice:latest
```

Then access http://localhost:8080/ in your browser or use:

```
curl http://localhost:8080/
```
4. Login to Docker Hub
Authenticate your Docker CLI with your Docker Hub credentials:

```
docker login
```
5. Push the Image to Docker Hub
Push the image to your Docker Hub repository:

```
docker push <your-dockerhub-username>/simpletimeservice:latest
```




# SimpleTimeService Infra (Azure, Terraform)

This Terraform module deploys:
- A new VNet with 2 public and 2 private subnets.
- An AKS cluster with agent nodes in private subnet(s).
- A Kubernetes LoadBalancer service exposing your containerized app via a public IP.

## Usage

1. **In the same repository, Go to terraform folder**
      ```
         cd terraform
      ```

2. **Authenticate with Azure**

   - Install & login with Azure CLI:  
     ```
     az login
     az account set --subscription "<your-subscription-id>"
     ```
   - Set `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, etc., if using a service principal (see Terraform docs).

3. **Edit terraform.tfvars**  
   Update `docker_image = "<your-dockerhub-username>/simpletimeservice:latest"` as needed.

4. **Deploy**
```
   terraform init
   terraform apply
```