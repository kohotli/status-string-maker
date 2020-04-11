#lang racket/base

#| Goals:
1. Time, duh. #DONE. AND DATE.
2. Battery charging status & percent #DONE
3. Music #DONE
4. User@Hostname #DONE
5. Wifi status #DONE
6. CPU usage
7. Command line arguments.
|#

(require racket/system)
(require racket/port)
(require racket/list)
(require racket/string)

;Command output parsing
(define (get-command-output-string command)
	(let ([command-path (find-executable-path command)])
		;(if (not command-path) (error "Error (get-command-output-string): Command not found")
		(if (not command-path) "MPD Disconnected"
				(strip-newline (with-output-to-string (λ () (system* command-path)))))))

;Command output parsing, accepting arguments in a list
(define (get-command-output-with-args command args)
	(let ([command-path (find-executable-path command)])
		(if (not command-path) (error "Error (get-command-output-with-args-string): Command not found")
				(string-split (strip-newline (with-output-to-string
																			(λ () (apply system* (cons command-path args)))))))))

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

;String handling
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
(define (get-current-date) (get-time "+%F"))

;MPD Music functions

(define (get-mpd-now-playing separator host port)
	(let ([mpc-output
				(get-command-output-with-args
					"mpc" (list
									"-h" host
									"-p" port
									"-f" (mpc-make-format-string separator)))])
		(if (empty? mpc-output) "MPD Disconnected"
				(let* ([title-index
								 (if (index-of mpc-output "[playing]")
										 (index-of mpc-output "[playing]")
										 (index-of mpc-output "[paused]"))]
							 ;[playstring-list (take mpc-output title-index)])
							 [playstring-list (if title-index
								 (take mpc-output title-index)
								 (list "MPD Not Playing"))])
					(string-join playstring-list)))))

;Form mpc format string
(define (mpc-make-format-string separator) (string-join (list "%artist%" separator "%title%")))

;Call xsetroot
(define (xsetroot status-string)
	(let ([command-path (find-executable-path "xsetroot")])
		(if (not command-path) (error "Error in (xsetroot): xsetroot command not found")
				(system* command-path "-name" status-string))))

;Configure icons, separator, date format, and internet devices here.
(define (main sleep-length ip-addr)
	(xsetroot (statusline-render
							ip-addr				;Internet device
							"+%R"					;Date format
							"\uF583 "			;Battery charging icon
							"\uF1EB "			;Icon for IP addr display
							"\uF7CA "			;Icon for mpd music display
							" | "					;Separator. The spaces are highly recommended to keep.
							ip-addr				;MPD host IP. Defaults to 127.0.0.1
							"6600"))				;MPD host port. Defaults to 6600
							(sleep sleep-length)
							(main sleep-length ip-addr))

;Statusline render. Edit this to configure the output for your setup. To remove something just comment that line out.
(define (statusline-render
					ip-addr
					date-format
					charging-icon
					inet-icon
					music-icon
					separator
					[mpd-host "127.0.0.1"]
					[mpd-port "6600"])
	(string-append
		music-icon (get-mpd-now-playing "»" mpd-host mpd-port) separator
		;(compose-battery-state charging-icon) separator
		inet-icon ip-addr separator
		"[" (user-at-host-string) "]" separator
		(get-current-date) " " (get-time date-format)))

(main 1 (get-ip-addr "enp0s31f6"))
