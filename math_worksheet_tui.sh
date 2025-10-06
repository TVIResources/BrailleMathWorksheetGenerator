#!/usr/bin/env bash
# Simple TUI to create math worksheets (bash)
# Features: addition, subtraction, multiplication (standard), multiplication fixed-first, multiplication XxY, division without remainder, mixed mul/div

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
output_folder="$script_dir/math_worksheets"
  esac
done
  if [ ! -e "${files[0]}" ]; then
    echo "No .txt files found in $src" >&2
    return 1
  fi

  count=0
  for f in "$src"/*.txt; do
    out="${f%.*}.brf"
    # use lou_translate --forward TABLE
    "$lou" --forward "$table" < "$f" > "$out"
    if [ $? -eq 0 ]; then
      count=$((count+1))
    else
      echo "Error converting $f" >&2
    fi
  done
  echo "Converted $count files to BRF in $src"
  return 0
}

convert_to_single_brf() {
  src="$1"
  outname="$2"
  lou="$(find_lou_translate)"
  table="$(find_table)"
  if [ -z "$lou" ] || [ -z "$table" ]; then
    echo "ERROR: lou_translate or table missing." >&2
    return 1
  fi

  outfile="$src/$outname"
  : > "$outfile"
  for f in "$src"/*.txt; do
    "$lou" --forward "$table" < "$f" >> "$outfile"
    # add form feed between worksheets
    printf "\f" >> "$outfile"
  done
  echo "Created combined BRF: $outfile"
  return 0
}

rand_between() {
  shuf -i "$1"-"$2" -n 1
}

get_random_number() {
  digits=$1
  min=$((10**(digits-1)))
  max=$((10**digits - 1))
  shuf -i $min-$max -n 1
}

generate_problem() {
  digits=$1
  op=$2
  num1=$(get_random_number "$digits")
  num2=$(get_random_number "$digits")
  if [ "$op" = "-" ]; then
    if [ $num1 -lt $num2 ]; then
      tmp=$num1; num1=$num2; num2=$tmp
    fi
  fi
  echo "${num1}${op}${num2}"
}

generate_mul_fixed() {
  fixed=$1
  other_max=$2
  other=$(shuf -i 1-$other_max -n 1)
  echo "${fixed}×${other}"
}

generate_mul_xy() {
  x=$1
  y=$2
  a=$(shuf -i 1-$x -n 1)
  b=$(shuf -i 1-$y -n 1)
  echo "${a}×${b}"
}

generate_whole_division() {
  max_divisor=$1
  max_quotient=$2
  divisor=$(shuf -i 1-$max_divisor -n 1)
  quotient=$(shuf -i 1-$max_quotient -n 1)
  dividend=$((divisor * quotient))
  echo "${dividend}÷${divisor}"
}

read_int_default() {
  prompt="$1"
  default=$2
  read -p "$prompt (default: $default): " input
  if [ -z "$input" ]; then
    echo $default
  else
    echo $input
  fi
}

while true; do
  cat <<EOF
1) Addition
2) Subtraction
3) Mixed Add/Subtract
4) Multiplication (standard)
5) Multiplication (fixed first factor)
6) Multiplication XxY
7) Division (no remainder)
8) Mixed Multiplication/Division
9) Convert Existing Worksheets to Individual BRF Files
10) Convert Existing Worksheets to Single Combined BRF
11) Generate AND Convert to Individual BRF Files
12) Generate AND Convert to Single Combined BRF
13) Exit
EOF
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
      # generate then convert individual
      echo "Generate and convert: please follow the prompts to create worksheets, then conversion will run."
      ;;
    12)
      echo "Generate and combine: please follow the prompts to create worksheets, then conversion will run."
      ;;
    13)
      echo "Goodbye"
      exit 0
      ;;
    *) echo "Invalid choice" ;;
  esac
done
