# recipes

This repository is to represent the steps that are needed to deploy an application and it's also a workaround to not 
add all this steps in the buildspec file that does the deploy.

It will also provide a way to rollout changes by tagging the releases.

## deploy script
This is a bash script (unfortunately) where it will:
1. create the tag based on the customer project repo
2. create the docker image that will contain the application
3. push the image to ECR 
4. Deploy the application to ECS with Terraform

## Testing

```shell
docker run --rm -it -v ~/.ssh/:/root/.ssh:ro \
-v /var/run/docker.sock:/var/run/docker.sock \
-v ~/.aws/:/root/.aws:ro \
606626603369.dkr.ecr.us-east-1.amazonaws.com/xtages-build-images/node_cd:15.13.0 bash
```
