# DevOps Portfolio and Code Snippets

Welcome to my DevOps Portfolio! This repository serves as a central hub for documenting and showcasing various projects and useful scripts related to automation, deployment and infrastructure management that I've worked on.

# Table of Contents

## CI/CD

1. [CircleCI -- Deploying a Node.js app to AWS Elastic Beanstalk](#project-1-deploying-a-nodejs-app-to-aws-elastic-beanstalk)
1. [CircleCI -- Deploying a Multi-Container Application to ElasticBeanstalk](#project-2-deploying-a-multi-container-application-to-elasticbeanstalk)
1. [GitHub Actions -- Deploying an Application to AWS Lightsail using GitHub Actions](#project-3-deploying-an-application-to-aws-lightsail)

## Storage

1. [Streaming Replication in PostgreSQL](#project-4-postgresql-replication)

## Infrastructure as Code

1. [Two-Tier WordPress Architecture on AWS using CloudFormation](#project-5-two-tier-wordpress-architecture-on-aws)

## Auto Scaling

1. [AWS Auto Scaling Architecture using EC2](#project-6-aws-auto-scaling-architecture-using-ec2)

---

## Projects

Here is a summary of some projects in this repo.

### Project 1: Deploying a Node.js app to AWS Elastic Beanstalk

### Overview

This project demonstrates the process of deploying a Node.js application to AWS Elastic Beanstalk using CircleCI for continuous integration. For detailed instructions, [deployment guide](CI_CD/CircleCI/README.md).

---

### Project 2: [Deploying a Multi-Container Application to ElasticBeanstalk](CI_CD/CircleCI/multi_container_deploy_config.yml)

### Overview

This project showcases the deployment of a multi-container application to AWS Elastic Beanstalk, leveraging Docker Hub for image storage and CircleCI for continuous integration. For detailed instructions, follow the [deployment guide](CI_CD/CircleCI/README.md).

---

### Project 3: [Deploying a Django Application to AWS Lightsail](CI_CD/Github_Actions/README.md)

### Overview

This project highlights the deployment of an application to AWS Lightsail using a combination of technologies, including SSH, Ansible, GitHub Actions, and AWS Lightsail. For detailed instructions, refer to the [project README](CI_CD/Github_Actions/README.md).

---

### Project 4: [PostgreSQL Replication](Storage/PostgreSQL/replication/README.md)

### Overview

The PostgreSQL Replication project demonstrates the setup of a primary PostgreSQL server and the configuration of replication to ensure data redundancy and fault tolerance. For detailed instructions, refer to the [project README](Storage/PostgreSQL/replication/README.md).

---

### Project 5: [Two-Tier WordPress Architecture on AWS](Wordpress/README.md)

### Overview

This project provides a CloudFormation template and shell scripts to create a two-tier WordPress architecture on AWS. For detailed instructions, follow the deployment guide.

---

### Project 6: [AWS Auto Scaling Architecture using EC2](LoadBalancing/README.md)

### Overview

A project that demonstrates using an infrastructure as code tool(CloudFormation) to create an auto-scaling EC2 infrastructure with Security Groups, an Application Load Balancer, and EC2 instances.

---

### Project 7: [Cloud Uploader - A CLI tool for uploading files to AWS S3](Scripts/Cloud_Uploader/README.md)

### Overview

A Bash CLI tool for uploading files to AWS S3. The CLI can also generate links to uploaded file.
