# Define variables
PROJECT_NAME = fastapi-app
TAG_VERSION := latest
IMAGE_NAME := $(PROJECT_NAME)
CONTAINER_NAME := fastapi-container

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME):$(TAG_VERSION) .

# Run the Docker container
run:
	docker run -d --name $(CONTAINER_NAME) -p 80:80 $(IMAGE_NAME)

# Stop and remove the Docker container
stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)

hit-api:
	curl http://localhost

##############################    AWS SHIT    ###################################
AWS_REGION := "ca-central-1"
AWS_ACCOUNT_ID := "475456120483"

aws-setup:
	aws configure

docker-aws-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

# for each project you have to create a separate repo (that's how amazon's repo works)
# you "can" make it work otherwise but it'll be weird.
AWS_REPO_URL := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

create-repository:
	aws ecr create-repository \
    --repository-name $(PROJECT_NAME) \
    --image-scanning-configuration scanOnPush=true \
    --region $(AWS_REGION)

tag-aws:
	docker tag $(PROJECT_NAME):$(TAG_VERSION) $(AWS_REPO_URL)/$(IMAGE_NAME):$(TAG_VERSION)

push-aws:
	docker push $(AWS_REPO_URL)/$(IMAGE_NAME):$(TAG_VERSION)

##############################    GCP SHIT    ###################################
# 1. Enable billing (optionaly add a budget)
# 2. Create artifacts repository
# 3. Upload docker image
# 4. Deploy

GCP_PROJECT_ID := "arshan-readit"
SERVICE_NAME := $(PROJECT_NAME)-service
REPO_NAME := "readit-artifacts"
REGION := "northamerica-northeast2"
GCP_REPO_URL := gcr.io/$(GCP_PROJECT_ID)/$(REPO_NAME)
IMAGE_URL := $(GCP_REPO_URL)/$(IMAGE_NAME):$(TAG_VERSION)

gcp-create-artifact-repo:
	gcloud artifacts repositories create $(REPO_NAME) --repository-format=docker --location=$(REGION)

#  describe bulling
describe-billing:
	gcloud alpha billing projects describe $(GCP_PROJECT_ID)

# EVERY DAY STUFF
tag-gcp:
	docker tag $(IMAGE_NAME):$(TAG_VERSION) $(IMAGE_URL)

push-gcp:
	docker push $(IMAGE_URL)

deploy-gcp:
	gcloud run deploy $(SERVICE_NAME) --image $(IMAGE_URL) --platform managed --region $(REGION)

