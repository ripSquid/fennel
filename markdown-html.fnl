(local fennel (require :fennel))

(fn _G.pp [x] (print (fennel.view x)))

(local replaces ["^# (.+)"      "<h1>%s</h1>"
                "^## (.+)"      "<h2>%s</h2>"
                "^### (.+)"     "<h3>%s</h3>"
                "^#### (.+)"    "<h4>%s</h4>"
                "^##### (.+)"   "<h5>%s</h5>"
                "^###### (.+)"  "<h6>%s</h6>"])

; Supposed to read the markdown file
(fn read-markdown-file [] "# Hello, World!\nTwo")

; Create text-contents as an array of codepoint values or empty if nil
(fn into-utf8-codepoints [text]
  (icollect [_ codepoint (utf8.codes text)] codepoint))

(fn turn-into-lines [codepoints]
  (var lines {})
  (var cur {})
  (each [_ codepoint (ipairs codepoints)]
    (if (= codepoint 10) ; '/n' = 10
        (do
          (table.insert lines cur) ; if newline, insert current line into lines and set current line to empty
          (set cur {}))
        (table.insert cur codepoint) ; else insert codepoint to current line
        ))
  (if (> (length cur) 0) (table.insert lines cur)) ; add last line to current lines if not empty
  lines)

(fn into-string-lines [lines]
  (icollect [_ line (ipairs lines)] (utf8.char (table.unpack line))))

; Varargs should be in pairs. It tries to match the pattern and turn it into a string with the format.
; Then recursively calls itself with the next varargs.
; If no varargs patterns match, return the line without modifications
;
; Technically we could need to match a line multiple times
(fn try-replace [line ...]
  (match [...]
    [pattern format] (case (string.match line pattern)
                       strmatch (string.format format strmatch)
                       _ (tail! (try-replace line (select 3 ...))))
    _ line))

(fn convert-lines [lines]
  (icollect [_ line (ipairs lines)] (try-replace line (table.unpack replaces))))

(fn main []
  (-?> (read-markdown-file)
       (into-utf8-codepoints)
       (turn-into-lines)
       (into-string-lines)
       (convert-lines)
       (_G.pp)))

(main)
