# Phonebook Application deployed on AWS Application Load Balancer with Auto Scaling and Relational Database Service using Terraform

## Description

The Phonebook Application aims to create a phonebook application in Python and deployed as a web application with Flask on AWS Application Load Balancer with Auto Scaling Group of Elastic Compute Cloud (EC2) Instances and Relational Database Service (RDS) using Terraform.

## Project Architecture

![Project](./images/tf-phonebook.jpg)

## Case Study Details

- Your company has recently started a project that aims to serve as phonebook web application. You and your colleagues have started to work on the project. Your teammates have developed the UI part the project as shown in the template folder and develop the coding part and they need your help to deploying the app in development environment.

- You are requested to deploy your web application using Python's Flask framework.

- You need to transform your program into web application using the `index.html`, `add-update.html` and `delete.html` within the `templates` folder. Note the followings for your web application.

  - User should face first with `index.html` when web app started and the user should be able to;

    - search the phonebook using `index.html`.

    - add or update a record using `add-update.html`.

    - delete a record using `delete.html`.

  - User input can be either integer or string, thus the input should be checked for the followings,

    - The input for name should be string, and input for the phone number should be decimal number.

    - When adding, updating or deleting a record, inputs can not be empty.

    - If the input is not conforming with any conditions above, user should be warned using the `index.html` with template formatting.

  - The Web Application should be accessible via web browser from anywhere.

- Lastly, after transforming your code into web application, you are requested to push your program to the project repository on the Github and deploy your solution in the development environment on AWS Cloud using Terraform to showcase your project. In the development environment, you can configure your Terraform file using the followings,

![Project](./images/Security-Groups.png)

- The application should be created with new AWS resources.

- Template should create Application Load Balancer with Auto Scaling Group of Amazon Linux 2 EC2 Instances within default VPC.

- Application Load Balancer should be placed within a security group which allows HTTP (80) connections from anywhere.

- EC2 instances should be placed within a different security group which allows HTTP (80) connections only from the security group of Application Load Balancer.

- The Auto Scaling Group should use a Launch Template in order to launch instances needed and should be configured to;

  - use all Availability Zones.

  - set desired capacity of instances to `2`

  - set minimum size of instances to `1`

  - set maximum size of instances to `3`

  - set health check grace period to `300 seconds`

  - set health check type to `ELB`

- The Launch Template should be configured to;

  - prepare Python Flask environment on EC2 instance,

  - download the Phonebook Application code from Github repository,

  - deploy the application on Flask Server.

- EC2 Instances type can be configured as `t2.micro`.

- Instance launched by Terraform should be tagged `phonebook`

- For RDS Database Instance;

  - Instance type can be configured as `db.t2.micro`

  - Database engine can be `MySQL` with version of `8.0.19`.

- Phonebook Application Website URL should be given as output by Terraform, after the resources created.

## Terraform

- Creating and deploying project resources on AWS using Terraform may take 10 minutes approximately.
