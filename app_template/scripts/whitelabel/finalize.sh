#!/bin/bash

function finalizeProject() {
  echo -e "▶️ Performing final cleanup and other operations...\n"
  cleanProject
  echo -e "\nRunning pub get ..."
  $(get_flutter_cmd) pub get
  showFinalTodos
}
