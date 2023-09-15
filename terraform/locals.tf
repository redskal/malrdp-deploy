locals {
    public_ip = chomp(data.http.public_ip.response_body)
}