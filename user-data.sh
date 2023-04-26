#! /bin/bash

yum update -y

# Install Python3
yum install python3 -y

# Install Flask
pip3 install flask
pip3 install flask_mysql

# Install Git
yum install git -y

# Clone the repo
cd /home/ec2-user && git clone https://github.com/ycetindil/${repo_name}.git

# Start the Phonebook Application
python3 /home/ec2-user/${repo_name}/phonebook-app.py