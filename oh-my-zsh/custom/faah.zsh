FAAH_MP3="${0:A:h}/faaah.mp3"

_faah_on_error() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    (ffplay -nodisp -autoexit -loglevel quiet "$FAAH_MP3" &) >/dev/null 2>&1
  fi
  return $exit_code
}

precmd_functions+=(_faah_on_error)
