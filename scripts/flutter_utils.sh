get_flutter_cmd() {
    if command -v fvm &>/dev/null; then
        echo "fvm flutter"
    elif command -v flutter &>/dev/null; then
        echo "flutter"
    else
        echo "Error: neither fvm nor flutter found on PATH" >&2
        return 1
    fi
}

get_dart_cmd() {
    if command -v fvm &>/dev/null; then
        echo "fvm dart"
    elif command -v dart &>/dev/null; then
        echo "dart"
    else
        echo "Error: neither fvm nor dart found on PATH" >&2
        return 1
    fi
}
