variable "location" {
  default = "west europe"
}

/* variable "CLOUDINIT_FILE_CGF" {
  type        = string
  description = "cloud init file bash"
  default = "script-cgf.sh"
} */

variable "SharedKey" {
      description = "Shared Key of CC IP"
      default = "Cuda-DemoTF"
}

variable "CC_User" {
      description = "Shared Key of CC IP"
      default = "API"
}

variable "CC_IP" {
      description = "Public IP of CC"
      default = "20.101.172.11"
}
variable "CC_Range" {
      description = "CC_Range"
      default = "1"
}

variable "CC_Cluster" {
      description = "Cluster where the box resides"
      default = "Terraform"
}

variable "CC_Box" {
      description = "Name of the box"
      default = "Trainer "
}
variable "prefix" {
      description = "An abbreviation which represents your resource group as well as it is added in front of some resources"
      default = "ap-teraform-alpbach"
}

variable "cgf_ipaddress" {
    description = "Private IP address of the Barracuda CGF VM"
    default = "10.12.3.30"
}

variable "vnet" {
    description = "Network range of the VNET (e.g. 10.11.0.0/16)"
    default = "10.12.0.0/16"
}


variable "subnet_cgf" {
    description = "Network range of the Subnet containing the CloudGen Firewall (e.g. 10.123.0.0/24)"
    default = "10.12.3.0/24"
}


variable "cgf_subnetmask" {
    description = "Subnetmask of the internal IP address of the CGF (e.g. 24)"
    default = "24"
}

variable "cgf_defaultgateway" {
    description = "Default gateway of the CGF network. This is always the first IP in the Azure subnet where the CGF is located. (e.g. 10.123.0.1)"
    default = "10.12.3.1"
}


variable "cgf_imagesku" {
    description = "SKU Hourly (hourly) or Bring your own license (byol)"
    default     = "byol"
}

variable "cgf_vmsize" {
    description = "Size of the Barracuda CGF VMs to be created"
    default     = "Standard_DS1_v2"
}
variable "password" { 
    description = "The password for the Barracuda CloudGen Firewall to use"
    default="Cuda-DemoTF2022"
}
