#!/bin/bash

while getopts "i:o:" opt; do
  case $opt in
    i)
      IFS=',' read -ra in_args <<< "$OPTARG"
      ;;
    o)
      IFS=',' read -ra out_args <<< "$OPTARG"
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [ ${#in_args[@]} -ne ${#out_args[@]} ]; then
  echo "Error: Number of input and output arguments must be the same"
  exit 1
fi

for ((i = 0; i < ${#in_args[@]}; i++)); do
  ./setup.sh "${in_args[i]}" "${out_args[i]}" &
done

wait
