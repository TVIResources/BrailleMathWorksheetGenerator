#!/usr/bin/env zsh
# Simple TUI to create math worksheets (zsh)
# Features: addition, subtraction, multiplication (standard), multiplication fixed-first, multiplication XxY, division without remainder, mixed mul/div

script_dir="$(cd "$(dirname "${0}")" && pwd)"
output_folder="$script_dir/math_worksheets"
mkdir -p "$output_folder"

# lou_translate configuration: allow override with env vars
# LOU_TRANSLATE_PATH - full path to lou_translate executable
# LIBLOUIS_TABLE - path to the liblouis table (e.g. en-ueb-g2.ctb)
lou_translate_path="${LOU_TRANSLATE_PATH:-}"
liblouis_table="${LIBLOUIS_TABLE:-}"

find_lou_translate() {
  if [ -n "$lou_translate_path" ] && [ -x "$lou_translate_path" ]; then
    echo "$lou_translate_path"
    return 0
  fi

  cmd="$(command -v lou_translate 2>/dev/null)"
  if [ -n "$cmd" ]; then
    echo "$cmd"
    return 0
  fi

  cmd="$(command -v lou_translate.exe 2>/dev/null)"
  if [ -n "$cmd" ]; then
    echo "$cmd"
    return 0
  fi

  return 1
}

find_table() {
  if [ -n "$liblouis_table" ] && [ -f "$liblouis_table" ]; then
    echo "$liblouis_table"
    return 0
  fi
  possible=("/usr/share/liblouis/tables/en-ueb-g2.ctb" "/usr/local/share/liblouis/tables/en-ueb-g2.ctb")
  for p in "${possible[@]}"; do
    if [ -f "$p" ]; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

# Simple CLI flags: -h/--help, -v/--verbose
VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -h, --help     Show this help and exit"
      echo "  -v, --verbose  Print detected lou_translate path and table path then exit"
      exit 0
      ;;
      read -p "Enter choice: " choice
      case "$choice" in
        1)
          digits=$(read_int_default "Enter number of digits per operand" 2)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          for s in $(seq 1 $count); do
            file="$output_folder/addition_${digits}_$s.txt"
            > "$file"
            for i in $(seq 1 $problems); do
              echo "$(generate_problem $digits +)" >> "$file"
            done
            echo "Created $file"
          done
          ;;
        2)
          digits=$(read_int_default "Enter number of digits per operand" 2)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          for s in $(seq 1 $count); do
            file="$output_folder/subtraction_${digits}_$s.txt"
            > "$file"
            for i in $(seq 1 $problems); do
              echo "$(generate_problem $digits −)" >> "$file"
            done
            echo "Created $file"
          done
          ;;
        3)
          digits=$(read_int_default "Enter number of digits per operand" 2)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          for s in $(seq 1 $count); do
            file="$output_folder/mixed_addsub_${digits}_$s.txt"
            > "$file"
            for i in $(seq 1 $problems); do
              op=$(shuf -e + − -n 1)
              if [ "$op" = "+" ]; then
                echo "$(generate_problem $digits +)" >> "$file"
              else
                echo "$(generate_problem $digits −)" >> "$file"
              fi
            done
            echo "Created $file"
          done
          ;;
        4)
          digits=$(read_int_default "Enter number of digits per operand" 1)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          for s in $(seq 1 $count); do
            file="$output_folder/multiplication_${digits}_$s.txt"
            > "$file"
            for i in $(seq 1 $problems); do
              echo "$(generate_problem $digits ×)" >> "$file"
            done
            echo "Created $file"
          done
          ;;
        5)
          fixed=$(read_int_default "Enter fixed first factor" 2)
          other_max=$(read_int_default "Enter maximum other factor" 12)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          for s in $(seq 1 $count); do
            file="$output_folder/mul_fixed_${fixed}_$s.txt"
            > "$file"
            for i in $(seq 1 $problems); do
              echo "$(generate_mul_fixed $fixed $other_max)" >> "$file"
            done
            echo "Created $file"
          done
          ;;
        6)
          x=$(read_int_default "Enter X (max first factor)" 12)
          y=$(read_int_default "Enter Y (max second factor)" 12)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          for s in $(seq 1 $count); do
            file="$output_folder/mul_${x}x${y}_$s.txt"
            > "$file"
            for i in $(seq 1 $problems); do
              echo "$(generate_mul_xy $x $y)" >> "$file"
            done
            echo "Created $file"
          done
          ;;
        7)
          max_divisor=$(read_int_default "Enter maximum divisor" 12)
          max_quotient=$(read_int_default "Enter maximum quotient" 12)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          for s in $(seq 1 $count); do
            file="$output_folder/division_whole_$s.txt"
            > "$file"
            for i in $(seq 1 $problems); do
              echo "$(generate_whole_division $max_divisor $max_quotient)" >> "$file"
            done
            echo "Created $file"
          done
          ;;
        8)
          max_divisor=$(read_int_default "Enter maximum divisor" 12)
          max_quotient=$(read_int_default "Enter maximum quotient" 12)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          for s in $(seq 1 $count); do
            file="$output_folder/mixed_muldiv_$s.txt"
            > "$file"
            for i in $(seq 1 $((problems/2))); do
              echo "$(generate_mul_xy $max_divisor $max_quotient)" >> "$file"
            done
            for i in $(seq 1 $((problems/2))); do
              echo "$(generate_whole_division $max_divisor $max_quotient)" >> "$file"
            done
            echo "Created $file"
          done
          ;;
        9)
          if [ -d "$output_folder" ]; then
            convert_to_individual_brf "$output_folder"
          else
            echo "No worksheets found."
          fi
          ;;
        10)
          if [ -d "$output_folder" ]; then
            read -p "Enter output filename (default: combined_worksheets.brf): " fname
            fname=${fname:-combined_worksheets.brf}
            convert_to_single_brf "$output_folder" "$fname"
          else
            echo "No worksheets found."
          fi
          ;;
        11)
          # Generate then convert to individual BRF files
          echo "Generate then convert to individual BRF files"
          echo "Select worksheet type to generate:"
          echo " 1) Addition"
          echo " 2) Subtraction"
          echo " 3) Mixed Add/Subtract"
          echo " 4) Multiplication"
          read -p "Enter choice (1-4, default 1): " typ
          typ=${typ:-1}
          digits=$(read_int_default "Enter number of digits per operand" 2)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          mkdir -p "$output_folder"
          for s in $(seq 1 $count); do
            case "$typ" in
              1)
                file="$output_folder/addition_${digits}_$s.txt"
                > "$file"
                for i in $(seq 1 $problems); do
                  echo "$(generate_problem $digits +)" >> "$file"
                done
                ;;
              2)
                file="$output_folder/subtraction_${digits}_$s.txt"
                > "$file"
                for i in $(seq 1 $problems); do
                  echo "$(generate_problem $digits −)" >> "$file"
                done
                ;;
              3)
                file="$output_folder/mixed_addsub_${digits}_$s.txt"
                > "$file"
                for i in $(seq 1 $problems); do
                  op=$(shuf -e + − -n 1)
                  if [ "$op" = "+" ]; then
                    echo "$(generate_problem $digits +)" >> "$file"
                  else
                    echo "$(generate_problem $digits −)" >> "$file"
                  fi
                done
                ;;
              4)
                file="$output_folder/multiplication_${digits}_$s.txt"
                > "$file"
                for i in $(seq 1 $problems); do
                  echo "$(generate_problem $digits ×)" >> "$file"
                done
                ;;
            esac
            echo "Created $file"
          done
          convert_to_individual_brf "$output_folder"
          ;;
        12)
          # Generate then combine into a single BRF
          echo "Generate then combine into a single BRF"
          echo "Select worksheet type to generate:"
          echo " 1) Addition"
          echo " 2) Subtraction"
          echo " 3) Mixed Add/Subtract"
          echo " 4) Multiplication"
          read -p "Enter choice (1-4, default 1): " typ
          typ=${typ:-1}
          digits=$(read_int_default "Enter number of digits per operand" 2)
          problems=$(read_int_default "Problems per sheet" 20)
          count=$(read_int_default "Number of worksheets" 1)
          mkdir -p "$output_folder"
          for s in $(seq 1 $count); do
            case "$typ" in
              1)
                file="$output_folder/addition_${digits}_$s.txt"
                > "$file"
                for i in $(seq 1 $problems); do
                  echo "$(generate_problem $digits +)" >> "$file"
                done
                ;;
              2)
                file="$output_folder/subtraction_${digits}_$s.txt"
                > "$file"
                for i in $(seq 1 $problems); do
                  echo "$(generate_problem $digits −)" >> "$file"
                done
                ;;
              3)
                file="$output_folder/mixed_addsub_${digits}_$s.txt"
                > "$file"
                for i in $(seq 1 $problems); do
                  op=$(shuf -e + − -n 1)
                  if [ "$op" = "+" ]; then
                    echo "$(generate_problem $digits +)" >> "$file"
                  else
                    echo "$(generate_problem $digits −)" >> "$file"
                  fi
                done
                ;;
              4)
                file="$output_folder/multiplication_${digits}_$s.txt"
                > "$file"
                for i in $(seq 1 $problems); do
                  echo "$(generate_problem $digits ×)" >> "$file"
                done
                ;;
            esac
            echo "Created $file"
          done
          read -p "Enter output filename for combined BRF (default: combined_worksheets.brf): " fname
          fname=${fname:-combined_worksheets.brf}
          convert_to_single_brf "$output_folder" "$fname"
          ;;
        13)
          echo "Goodbye"
          exit 0
          ;;
        *) echo "Invalid choice" ;;
      esac
    done
          echo "$(generate_mul_xy $max_divisor $max_quotient)" >> "$file"
        done
        for i in $(seq 1 $((problems/2))); do
          echo "$(generate_whole_division $max_divisor $max_quotient)" >> "$file"
        done
        echo "Created $file"
      done
      ;;
    9)
      if [ -d "$output_folder" ]; then
        echo "Converting each .txt to BRF requires lou_translate; run conversion separately or ensure liblouis is installed."
      else
        echo "No worksheets found."
      fi
      ;;
    10)
      if [ -d "$output_folder" ]; then
        echo "Combine conversion (single BRF) requires lou_translate; run conversion separately or ensure liblouis is installed."
      else
        echo "No worksheets found."
      fi
      ;;
    11)
      echo "Generate+convert not implemented in zsh — generate then run lou_translate manually or use PowerShell for conversion."
      ;;
    12)
      echo "Generate+combine not implemented in zsh — generate then run lou_translate manually or use PowerShell for conversion."
      ;;
    13)
      echo "Goodbye"
      exit 0
      ;;
    *) echo "Invalid choice" ;;
  esac
done
