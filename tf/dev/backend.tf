terraform {
  backend "gcs" {
    bucket = "tf-kic-chat-assistant-state"
    prefix = "tf/state"
  }
}
