variable "google" {
  description = "Google API Key"
  type        = map(string)

  default = {
    project = ""
    region  = ""
    zone    = ""
  }
}
