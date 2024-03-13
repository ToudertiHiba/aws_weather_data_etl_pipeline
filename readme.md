# AWS Infrastructure Deployment & Data Processing Pipeline

This comprehensive guide outlines the steps to deploy AWS instances using Terraform and configure them using Ansible. 
The pipeline automates the deployment and configuration of a cloud-based data processing and visualization infrastructure on AWS, integrating essential services like Cassandra, Kafka, Spark, and Streamlit.

It utilizes Terraform for infrastructure provisioning, Ansible for server configuration management, and enables the ingestion, processing, storage, and interactive visualization of real-time weather data using components such as Cassandra, Kafka, Spark, and Streamlit.

By orchestrating these tools, the pipeline facilitates the seamless setup of a scalable and efficient data processing and visualization environment on AWS.

### Project Folder Contents:

#### `.terraform/`
Directory containing Terraform state files and configurations.

#### `.venv/`
Virtual environment directory for Python dependencies.

#### `ansible_playbooks/`
Ansible playbooks for installing Cassandra, Kafka, Spark, and Streamlit services.

#### `files/`
Directory containing miscellaneous files used in the project, including JSON configurations, SSH keys, and Scala/Python scripts.

#### `.gitignore`
Git configuration file specifying files and directories to be ignored in version control.

#### `.terraform.lock.hcl`
Terraform lock file specifying exact versions of dependencies used in the project.

#### `main.tf`
Main Terraform configuration defining infrastructure resources provisioned on AWS.

#### `poetry.lock`, `pyproject.toml`
Poetry configuration files specifying Python dependencies and project metadata.

#### `readme.md`
Project readme file containing documentation and instructions for setup and usage.

#### `terraform.tfstate`, `terraform.tfstate.backup`
Terraform state files containing current infrastructure state and backups.

#### `variables.tf`
Terraform variables file defining input variables and their default values for the Terraform configuration.

## Terraform Setup

1. **Install Terraform**: Install Terraform on your local machine.
2. **AWS Account Setup**: Create an AWS account and sign in to the AWS Management Console.
3. **IAM User Creation**: Create an IAM user with programmatic access and attach the `AmazonEC2FullAccess` policy.
4. **Access Key Setup**: Note down the access key and secret key for the IAM user.
5. **Environment Variables**: Set the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

### Terraform Configuration Explanation

The provided Terraform configuration file automates the creation of necessary infrastructure components, ensuring consistency and reproducibility. It defines:
1. **Provider Configuration**: AWS provider settings: region, access keys, etc.
2. **VPC, Subnet, and Internet Gateway**: Networking components: Virtual Private Cloud (VPC), a subnet within the VPC, and an internet gateway, enabling the instances to communicate with the internet.
3. **Route Table, Security Groups**: Routing and security configurations: a route table for the subnet allowing outbound internet access for the instances, security groups with specific ingress and egress rules to control inbound and outbound traffic for different services.
5. **Key Pair**: an SSH key pair (of an IAM user with the `AmazonEC2FullAccess` policy) for accessing the instances securely.
6. **Instances**: The file creates EC2 instances for Kafka, Spark, Cassandra, and Streamlit Visualization services, configuring them with specific settings and attaching appropriate security groups.
7. **Inventory File**: Generated file (`inventory.ini`) containing the public IP addresses of the created instances, which can be used by Ansible for configuration management.

### Terraform Commands

- `terraform init`: Initializes the Terraform configuration.
- `terraform apply`: Applies the Terraform configuration and creates the resources.

### Configuration Parameters

- `ami_id`: The ID of the AMI to use for the instance, choose one from [here](https://eu-west-3.console.aws.amazon.com/ec2/home?region=eu-west-3#AMICatalog:).
- `key_pair_name`: Generate a new private key and its corresponding public key using `ssh-keygen -t rsa -b 4096`.

## Ansible Setup

### Prerequisites

- Ansible cannot be installed directly on Windows, you can use Windows Subsystem for Linux (WSL) instead.

### Installation Steps

1. **Install WSL**: Run `wsl --install` and reboot.
2. **Install Ubuntu**: From Microsoft Store, install Ubuntu.
3. **Ubuntu Setup**: Open Ubuntu, create a new user, set a password, and update.
5. **Add Ansible Repository**: Execute `sudo apt-add-repository ppa:ansible/ansible`.
6. **Install Ansible**: Run `sudo apt install ansible`.
7. **Install Dependencies**: Execute `sudo apt-get install -y python3-pip libssl-dev`.
8. **Check Ansible Version**: Ensure Ansible is installed by running `ansible --version`.

### Ansible Playbooks 
#### Install Kafka on Ubuntu
This playbook installs Kafka on an Ubuntu instance.

- **Tasks**:
  - Update apt cache
  - Install required packages
  - Download and extract Kafka
  - Set KAFKA_HEAP_OPTS
  - Install Python3 and kafka-python
  - Copy the Kafka Producer and the API Configuration File
  - Start Zookeeper and Kafka Server
  - Run Kafka producer

#### Install Spark with Scala on Ubuntu
This playbook installs Spark with Scala on an Ubuntu instance.

- **Tasks**:
  - Install OpenJDK 8 JDK
  - Install Spark, Scala and SBT dependencies
  - Download and extract Spark, Scala and SBT
  - Add environment variables to `.bashrc`
  - Create StreamHandler directory
  - Copy the build.sbt and the stream_handler.scala file
  - Configure Spark log level
  - Run SBT Package
  - Run Spark Submit

#### Install Cassandra on Ubuntu
This playbook installs Cassandra on an Ubuntu instance.

- **Tasks**:
  - Update apt cache
  - Install OpenJDK 8 and Wget
  - Set JAVA_HOME and PATH environment variable
  - Download and Extract Cassandra
  - Add CASSANDRA_HOME to ~/.bashrc
  - Add CASSANDRA_HOME/bin to PATH in ~/.bashrc
  - Set PYSPARK_PYTHON environment variable
  - Source .bashrc
  - Start Cassandra service
  - Start CQL Shell

#### Install and configure Streamlit app
This playbook installs and configures a Streamlit app on an Ubuntu instance.

- **Tasks**:
  - Update apt cache
  - Install Python 3 pip and other required Python packages
  - Add ~/.local/bin to PATH
  - Source ~/.bashrc
  - Copy the Streamlit Visualisation file
  - Get Cassandra VM IP address
  - Run Streamlit app

### Running Ansible Playbooks
- Run Ansible playbooks from Ubuntu using commands like:
  ```bash
  ansible-playbook -i /mnt/c/path/to/inventory.ini /mnt/c/path/to/playbook.yml
  ```

## Global Description of the Kafka Producer File
The provided Kafka producer file, a Python script, fetches weather data from an external API by sending HTTP requests to specific endpoints with city names. Authentication is required through an API key. Once retrieved, the script continuously loops through a predefined list of cities, fetching weather data for each one and publishing it to a Kafka topic. 

## Description of the stream handler class 
The provided Scala file, `StreamHandler.scala`, is a Spark Structured Streaming application designed to consume data from a Kafka topic, process it, and persist the results to Apache Cassandra, ensuring efficient data storage and retrieval.

## Description of the kafka console class 
The Scala file `KafkaConsole.scala` represents a Spark Structured Streaming application designed to consume data from a Kafka topic and display it to the console, aiding in data monitoring and analysis. It is an intermediary file to verify the connection between the spark job and the kafka topic.

## Description of the SBT file
The `build.sbt` file configures dependencies for building the Scala application.

## Description of the Streamlit Visualisation App
The Streamlit Python script provides a web-based interface for visualizing weather data from Cassandra, enabling interactive data exploration.

It reads weather data from the Cassandra database table and converts the retrieved data into a Pandas DataFrame for easy manipulation. It displays the DataFrame in a table format. 

Additionally, it provides interactive components for data exploration, such as a dropdown menu to select cities and a radio button to choose between displaying temperature or humidity data. Based on the user's selections, the script filters the DataFrame accordingly and generates a line chart to visualize the selected weather data over time for the chosen city.

### Troubleshooting
- If a VM is unreachable, try connecting using:
  ```bash
  ssh -i "aws_ec2_rsa_key" ubuntu@ec2-ip-address
  ```
- You may need to copy SSH keys inside Ubuntu and change the permissions
