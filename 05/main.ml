(* compile this file using 
```bash

ocamlopt str.cmxa main.ml -o main

``` *)

open Str

let readlines file =
  let in_chan = open_in file in
  let rec helper ch acc =
      try
          let l = input_line ch in
          helper ch (l :: acc)
      with End_of_file ->
          close_in ch;
          acc
  in
  try
      List.rev (helper in_chan [])
  with e ->
      close_in in_chan;
      raise e

let rec take_while f a = match a with
  | [] -> []
  | (h::r) -> if f h then (h :: take_while f r) else take_while f r

let rec drop n lst = match (n, lst) with
    | (0, a) -> a
    | (n, []) -> []
    | (n, a::b) -> drop (n-1) b

let range_contains ((a, b) : int * int) (n : int) : bool = (a <= n) && (n <= b)

exception NoParse of string

let range_of_string line =
  let pattern = Str.regexp "\\(.+\\)-\\(.+\\)" in
  let match_result = Str.string_match pattern line 0 in
  if match_result then
    let first_num = Str.matched_group 1 line in
    let second_num = Str.matched_group 2 line in
    (int_of_string first_num, int_of_string second_num)
  else
    raise (NoParse ("sorry kid, could not parse this: " ^ line))

let fresh id ranges = (List.length (List.filter (fun range -> range_contains range id) ranges)) > 0

let rec sum lst = match lst with
    | [] -> 0
    | a::b -> a + sum b

let ranges_overlap (a,b) (c,d) = 
  (range_contains (a,b) c) 
  || (range_contains (a,b) d)
  || (range_contains (c,d) a)
  || (range_contains (c,d) b)
  || a == d+1  
  || c == b+1

let merge_two_ranges (a,b) (c,d) =
  let e = if a < c then a else c in
  let f = if b > d then b else d in
  (e, f)

let rec flatten_pairs lst = match lst with
  | [] -> []
  | ((a,b)::c) -> a::b::(flatten_pairs c)

let rec combinations lst =
  match lst with
  | [] -> []
  | x :: xs ->
      let pairs_with_x = List.map (fun y -> (x, y)) xs in
      pairs_with_x @ combinations xs

let remove el lst = List.filter (fun x -> x <> el) lst

let rec remove_all els lst =
  match els with
  | [] -> lst
  | (a::b) -> remove_all b (remove a lst)

let head lst = match lst with
  | [] -> []
  | a::b -> [a]

let step ranges =
  let range_combination = combinations ranges in
  let mergeables = head (List.filter (fun (r1, r2) -> ranges_overlap r1 r2) range_combination) in
  let merged = List.map (fun (r1, r2) -> merge_two_ranges r1 r2) mergeables in
  let flattened_mergeables = flatten_pairs mergeables in
  (List.length mergeables > 0, (remove_all flattened_mergeables ranges) @ merged)

let rec fully_merge ranges =
  let (changed, new_ranges) = step ranges in
  if changed then fully_merge new_ranges
  else ranges

let () =
  try
    let file = Sys.argv.(1) in
    let lines = readlines file in
    let range_lines = take_while (fun line -> String.contains line '-') lines in
    let id_lines = drop ((List.length range_lines)+1) lines in
    let ids = List.map int_of_string id_lines in
    let ranges = List.map range_of_string range_lines in
    let part1 = List.length (List.filter (fun id -> fresh id ranges) ids) in
    let merged_ranges = fully_merge ranges in
    let range_sizes = List.map (fun (a,b) -> b-a+1) merged_ranges in
    let part2 = sum range_sizes in
    Printf.printf "part 1: %d\n" part1;
    Printf.printf "part 2: %d\n" part2;
  with 
    exp -> Printf.printf "please specify input file name!\n"
