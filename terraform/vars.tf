variable "resource_group_location" {
    description = "Azure region to create the resources in."
    default = "uksouth"
}

variable "vm_size" {
    description = "Size of the VM to create."
    default = "Standard_B2s"
}

variable "base_name" {
    description = "Use something like the company name"
    default = "client-name"
}

variable "admin_user" {
    description = "Admin username to use for the VM"
    default = "redskal"
}

variable "admin_pass" {
    description = "Admin password to use for the VM"
    default = "JarJarSithLord!23"
}

variable "host_name" {
    description = "Set the hostname of the VM OS"
    default = "ACME-WKS01"
}

variable "victim_user" {
    description = "Set the username the victim sees"
    default = "tsuser"
}