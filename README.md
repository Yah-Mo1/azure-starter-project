# 🚀 CoderCo Azure Terraform Starter

## 📖 Overview

This repository provides a **Terraform-based infrastructure deployment** for **Microsoft Azure**, focusing on **Virtual Machine Scale Sets (VMSS), high availability, and best practices**.

This README outlines the **steps to deploy the infrastructure**, along with key **assumptions, limitations, and trade-offs** made during the implementation.

---

## 🛠 Prerequisites

Before deploying, ensure you have the following installed:

- ✅ **Azure CLI** – [Download & Install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- ✅ **Terraform** (latest stable version) – [Download & Install](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- ✅ **jq** (for JSON parsing in CLI)
- ✅ **An Azure Subscription** with the correct permissions

Ensure you are authenticated with Azure:

```sh
az login
```

To verify the correct subscription is active:

```sh
az account show
```

---

## 🚀 Deployment Steps

### 1️⃣ Clone the Repository

```sh
git clone https://github.com/YOUR_GITHUB_USERNAME/coderco-azure-terraform.git
cd coderco-azure-terraform
```

### 2️⃣ Initialise Terraform

Run the following command to initialise Terraform and download required providers:

```sh
terraform init
```

### 3️⃣ Validate & Plan

Before applying changes, ensure the configuration is valid:

```sh
terraform validate
terraform plan
```

### 4️⃣ Apply the Terraform Configuration

Deploy the infrastructure:

```sh
terraform apply -auto-approve
```

Terraform will output the **public IP** of the application load balancer after a successful deployment. You can access the application via:

```sh
curl http://<PUBLIC_IP>
```

Expected Response:

```
Hello! Your CoderCo Tech Test VM is working!
```

### 5️⃣ Destroy the Resources (If Needed)

To remove all created resources:

```sh
terraform destroy -auto-approve
```

---

## 📌 Assumptions, Limitations & Trade-offs

### ✅ Assumptions

- The VM Scale Set should be **Linux-based** instead of Windows.
- **Auto-scaling** should be enabled with a minimum of **3 instances** across **multiple Availability Zones**.
- The application should be accessible via **HTTP on port 80**.
- Terraform **state should be stored remotely** for production use (not included in this setup by default).

### ⚠️ Limitations

- **No database configuration** is included. If required, a managed database service like **Azure Database for PostgreSQL** should be added.
- **No CI/CD automation** is included, but it can be implemented using **GitHub Actions** or **Azure DevOps Pipelines**.
- The setup assumes a **static workload**; additional autoscaling rules may be required for highly dynamic workloads.

### 🔄 Trade-offs

- **Using an Azure Load Balancer (ALB)** instead of an **Application Gateway** keeps costs lower, but **ALB does not offer WAF (Web Application Firewall)**.
- **Standard_D2s_v3 VM size** is chosen to balance **performance and cost-efficiency**.
- **Terraform provisioners are not used** to keep the setup declarative and avoid dependency issues; instead, **cloud-init** is recommended for VM provisioning.

---

## 🏆 Future Enhancements

- ✅ Implement **autoscaling policies** based on CPU utilisation.
- ✅ Store Terraform state in an **Azure Storage Account with state locking**.
- ✅ Automate deployments using **Azure DevOps Pipelines or GitHub Actions**.
- ✅ Enable monitoring using **Azure Monitor & Log Analytics**.

---

## 📩 Support

If you encounter issues, please open an issue on **GitHub** or contact the repository maintainers.

**Happy Coding! 🚀**
