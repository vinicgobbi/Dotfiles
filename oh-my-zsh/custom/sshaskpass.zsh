if command -v ksshaskpass >/dev/null 2>&1; then
  export SSH_ASKPASS="$(command -v ksshaskpass)"
  export SSH_ASKPASS_REQUIRE="prefer"
fi
