(* compile using:
  ocamlopt main.ml -o main
run using:
  ./main input.txt *)
  
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

exception ERROR of string

let split_on_spaces line = List.filter 
  (fun x -> x <> "")
  (List.map String.trim (String.split_on_char ' ' line))

let row n splits = List.map (fun row -> List.nth row n) splits

let rec range (n:int) (m:int) = if n = m then [m] else n :: (range (n+1) m)

let sum list =
  let result = List.fold_left (fun acc x -> acc + x) 0 list in
  result
  
let prod list =
  let result =  List.fold_left (fun acc x -> acc * x) 1 list in
  result

let part_1_calc row =
  let op = List.hd row in
  let strnums = List.tl row in
  let nums = List.map int_of_string strnums in
  if op = "+" then sum nums else prod nums

let block_lengths ll = 
  let (n,lst) = String.fold_left 
    (fun (n, lst) c -> 
      if c = '*' || c = '+' 
        then (0,(n+1)::lst) 
      else (n+1, lst)) (0,[]) ll in
  List.tl (List.rev ((n+1) :: lst))

let stringtake n str = String.sub str 0 n
let stringdrop n str = String.sub str n ((String.length str)-n)

let rec split_according (sps : int list) (str : string) = 
  match sps with
  | [a] -> [str]
  | a::b -> (stringtake a str) :: (split_according b (stringdrop a str))
  | _ -> raise (ERROR "THIS should not have happened.")

let reverse_string s =
  String.to_seq s |> List.of_seq |> List.rev |> List.to_seq |> String.of_seq

let part_2 row =
  let numlines = List.rev (List.tl (List.rev row)) in
  let revnums = List.map reverse_string numlines in
  let digits n = (String.concat "" (List.map (fun str -> String.sub str n 1) revnums)) in
  let rawnums = List.map digits (range 0 ((String.length (List.hd row))-1)) in
  let trimmednums = List.map String.trim rawnums in
  let filterednums = List.filter (fun x -> x <> "") trimmednums in
  let nums = List.map int_of_string filterednums in
  let rawop = List.hd (List.rev row) in
  let op = String.trim rawop in
  let mul = (op = "*") in
  if mul then prod nums else sum nums
  
let () =
  let file = Sys.argv.(1) in
  let lines = readlines file in
  let splits = List.map split_on_spaces lines in
  let columns = List.length (List.hd splits) in
  let rows = List.map (fun n -> row n splits) (range 0 (columns-1)) in
  let rev_rows = List.map List.rev rows in
  let part_1_results = List.map part_1_calc rev_rows in
  Printf.printf "part 1: %d\n" (sum part_1_results);
  let split_lengths = block_lengths (List.hd (List.rev lines)) in
  let part_2_splits = List.map (fun row -> split_according split_lengths row) lines in
  let part_2_rows = List.map (fun n -> row n part_2_splits) (range 0 (columns-1)) in
  let column_results = List.map part_2 part_2_rows in
  let part_2_result = sum column_results in
  Printf.printf "part 2: %d\n" part_2_result;
