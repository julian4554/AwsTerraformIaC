variable "tags" {
  type = map(string)
  default = {
    Project     = "Uni-Cloud-Website"
    Environment = "dev"
  }
}
