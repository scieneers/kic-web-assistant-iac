
resource "google_kms_key_ring" "this" {
  name = var.key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "this" {
  for_each = toset(var.key_names)

  name            = each.value
  key_ring        = google_kms_key_ring.this.id
  purpose         = "ENCRYPT_DECRYPT"


  # Gcp does not allow key destruction
  # Otherwise would only remove the state and render the key unusable
  lifecycle {
    prevent_destroy = true
  }
}