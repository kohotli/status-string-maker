#lang racket/base

#| Goals:
1. Time, duh.
2. Battery charging status & percent
3. Music
4. User@Hostname
5. Wifi status
|#

(require racket/system)
(require racket/port)
(require racket/list)
(require racket/string)

;Command output parsing
(define (get-command-output-string command)
  (let ([command-path (find-executable-path command)])
    (if (not command-path) (error "Error (get-command-output-string): Command not found")
    (strip-newline (with-output-to-string (λ () (system* (find-executable-path command))))))))

(define (get-command-output-list command)
 (string-split (get-command-output-string command)))

;User@Hostname functions
(define (get-current-user) (get-command-output-string "whoami"))
(define (get-acpi) (get-command-output-list "acpi"))
(define (get-hostname) (get-command-output-string "hostname"))
(define (user-at-host-string) (string-append (get-current-user) "@" (get-hostname)))

;Network Functions
(define (get-ip-out-list device)
 (let ([command-path (find-executable-path "ip")])
  (if (not command-path) (error "Error in (get-ip-out device): ip command not found")
   (string-split (with-output-to-string (λ () (system* command-path "addr" "show" device)))))))
(define (get-ip-addr device)
 (let* ([unparsed-ip-out (get-ip-out-list device)]
        [filtered-ip-out (member "inet" unparsed-ip-out)])
  (if (not filtered-ip-out) "Disconnected"
  (string-trim (second filtered-ip-out) "/24"))))

(define (strip-commas str) (string-trim str ","))
(define (strip-newline str) (string-trim str "\n"))

;Battery functions
(define (get-battery-level acpi-out) (strip-commas (fourth acpi-out)))
(define (get-battery-status acpi-out) (strip-commas (third acpi-out)))

(define (compose-battery-state charging-icon)
 (let* ([acpi (get-acpi)]
        [battery-level (get-battery-level acpi)]
        [battery-status (get-battery-status acpi)]
        [battery-charging (if (equal? "Charging" battery-status) charging-icon "")])
  (string-append battery-charging battery-level)))

;Get current time
(define (get-time date-format)
 (let ([command-path (find-executable-path "date")])
  (if (not command-path) (error "Error in (get-time): date command not found")
   (strip-newline (with-output-to-string (λ () (system* command-path date-format)))))))

;Statusline render
(define (statusline-render wifi-device date-format charging-icon separator)
 (string-append "[" (user-at-host-string) "]" " " (get-ip-addr wifi-device) separator
                (compose-battery-state charging-icon) separator
                (get-time date-format)))

;Call xsetroot
(define (xsetroot status-string)
 (let ([command-path (find-executable-path "xsetroot")])
  (if (not command-path) (error "Error in (xsetroot): xsetroot command not found")
   (system* command-path "-name" status-string))))

(define (main sleep-length)
 (xsetroot (statusline-render "wlp58s0" "+%R" "\uF0E7 " " | "))
 (sleep sleep-length)
 (main sleep-length)
 )

(main 5)
;(displayln (statusline-render "wlp58s0" "+%R" "\uF0E7 " " | "))
;Music functions
;(define (get-mpd-state) (get-command-output-string "mpc"))
