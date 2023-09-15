## MalRDP Deploy

The original guide for configuring MalRDP infrastructure was published by ShorSec [here](https://shorsec.io/blog/malrdp-implementing-rouge-rdp-manually/). That article gives a more comprehensive break down of setting up the infrastructure manually.

I have opted to automate deployment. This meant WSL, as used in the ShorSec article, wasn't an option. So I have automated the provisioning of Windows tooling to achieve the same goal.

Check the full blog post: https://skal.red/automating-malrdp-mostly/

#### Usage

 1. `git clone https://github.com/redskal/malrdp-deploy`
 2. `cd malrdp-deploy/terraform`
 3. `az login`
 4. `terraform init`
 5. `terraform apply --auto-approve`

Check `vars.tf` for variables you can declare on the Terraform command line.