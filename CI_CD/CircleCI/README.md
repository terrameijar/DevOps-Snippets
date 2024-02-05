## Deploying a Nodejs app to AWS Elastic Beanstalk

### Steps

1. Create AWS IAM account
2. Assign ElasticBeanstalk permissions for the account
3. Generate access key and secret key credentials
	1. https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/AWSHowTo.iam.managed-policies.html
4. Add environment variables to CircleCI
5. Create a config file like the one below

```yaml
version: 2.1

jobs:
  build:
    docker:
      - image: cimg/node:18.18.0

    working_directory: ~/app

    steps:
      - checkout

      # Install dependencies
      - run:
          name: Install Dependencies
          command: npm install

      # Run Tests
      - run:
          name: Run Tests
          command: npm test

  deploy:
    docker:
      - image: cimg/aws:2023.12
    steps:
      - checkout

      # Install Deployment Dependencies
      - run:
          name: Install Deployment Dependencies
          command: python3 -m pip install --upgrade --user awsebcli

      - run:
          name: Deploy to ElasticBeanstalk
          command: |
            aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
            aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
            aws configure set region $AWS_REGION
            eb init <application-name> --region $AWS_REGION --platform "Docker running on 64bit Amazon Linux 2023"
            eb use <environment-name>
            eb deploy

workflows:
  build_and_deploy:
    jobs:
      - build
      - deploy

```


## Deploying a multi-container application to ElasticBeanstalk

### Steps

1. Create AWS IAM account
2. Assign ElasticBeanstalk permissions for the account
3. Generate access key and secret key credentials
	1. https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/AWSHowTo.iam.managed-policies.html
4. Add AWS and DockerHub environment variables to CircleCI
5. Push images to dockerhub
6. Create EB Application and use Docker or ECS platform
7. Create a `Dockerrun.aws.json` file. Add container information to it. See example [`Dockerrun.aws.json`](./Dockerrun.aws.json) file included in the folder.
  1. https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_v2config.html#create_deploy_docker_v2config_dockerrun
