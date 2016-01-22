return {
  fields = {
    --http header doesn't allow underscore '_'
    HostTag = { type = "string", default = "K-HOST" },
    HostTagUnknown = { type = "string", default = "K-HOST-UNKNOWN" }
  }
}
