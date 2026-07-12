replace_text_in_files() {
  local src_text="$1"
  local target_text="$2"

  local match_file
  local count_file
  local total_occurrences

  if [[ -z "$src_text" || -z "$target_text" ]]; then
      echo "Error: Both source and target text are required."
      return 1
  fi

  match_file=$(mktemp)
  count_file=$(mktemp)
  echo "0" > "$count_file"

  find . -type f | while read -r file; do
      if grep -Iq "^" "$file"; then
          matches=$(grep -nF "$src_text" "$file")
          if [[ -n "$matches" ]]; then
              echo -e "$file" >> "$match_file"
              total=$(cat "$count_file")
              count=$(echo "$matches" | wc -l)
              echo $((total + count)) > "$count_file"
          fi
      fi
  done

  total_occurrences=$(cat "$count_file")
  if [[ $total_occurrences -eq 0 ]]; then
      echo "No matches found!"
      rm -f "$match_file" "$count_file"
      return 0
  fi

  echo "$total_occurrences matches found in following files:"
  cat "$match_file"

  if ! confirm_yes_no "Replace \"$src_text\" with \"$target_text\" in all the files?"; then
      echo "Replacement cancelled."
      rm -f "$match_file" "$count_file"
      return 1
  fi

  grep "^\./" "$match_file" | while read -r file; do
      local safe_src
      local safe_new

      safe_src=$(printf '%s\n' "$src_text" | sed 's/[\/&]/\\&/g')
      safe_new=$(printf '%s\n' "$target_text" | sed 's/[\/&]/\\&/g')

      sed -i "" "s/$safe_src/$safe_new/g" "$file"
      echo "Updated: $file"
  done

  rm -f "$match_file" "$count_file"
}
