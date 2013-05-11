;; moe-theme-switcher.el
;; Author: kuanyui (azazabc123@gmail.com)
;; Date: 2013/05/11 11:39
;; 
;; This file is not a part of GNU Emacs,
;; but this file is released under GPL v3.

(require 'moe-dark-theme)
(require 'moe-light-theme)

(defvar moe-theme-switch-by-sunrise-and-sunset t
"Automatically switch between dark and light moe-theme.

If this value is nil, moe-theme will switch at fixed time (06:00 and 18:00). 

If this value is t and both calendar-latitude and calendar-longitude are set properly, the switching will be triggered at the sunrise and sunset time of the local calendar.

Take Keelung, Taiwan(25N,121E) for example, you can set like this:

	(setq calendar-latitude +25)
	(setq calendar-longitude +121)"
)

(defun switch-at-fixed-time ()
  (let ((now (string-to-int (format-time-string "%H"))))
    (if (and (>= now 06) (<= now 18))
        (load-theme 'moe-light t) (load-theme 'moe-dark t))
    nil))

;; Convert am/pm to 24hr and save to 24h/sunrise & 24h/set
;; Excute every 24 hr
(defun convert-time-format-of-sunrise-and-sunset ()
  (let (rise_set a b c d e f)
    (setq rise_set (sunrise-sunset))
    (if (string-match "0:00 hours daylight" rise_set) ;If polar-night
        (progn 
          (setq 24h/sunrise 'polar-night
                24h/sunset 'polar-night))
      (if (string-match "24:00 hours daylight" rise_set) ;If midnight-sun
          (progn
            (setq 24h/sunrise 'midnight-sun
                  24h/sunset 'midnight-sun))
        (progn
         (string-match "\\([0-9][0-9]?\\):\\([0-9][0-9]\\)\\([ap]m\\).+\\([0-9][0-9]?\\):\\([0-9][0-9]\\)\\([ap]m\\)" rise_set)
         (setq a (string-to-number (match-string 1 rise_set))
               b (string-to-number (match-string 2 rise_set))
               c (match-string 3 rise_set)
               d (string-to-number (match-string 4 rise_set))
               e (string-to-number (match-string 5 rise_set))
               f (match-string 6 rise_set))
         (if (equal c "pm")
             (setq 24h/sunrise (list (+ 12 a) b))
           (setq 24h/sunrise (list a b)))
         (if (equal f "pm")
             (setq 24h/sunset (list (+ 12 d) e))
           (setq 24h/sunset (list d e))))))))

;; Excute every minute.
(defun switch-by-locale ()
  (if (equal 24h/sunrise 'polar-night)  ;If polar-night...moe-dark!
      (load-theme 'moe-dark t)
    (if (equal 24h/sunrise 'midnight-sun) ;If midnight-sun...moe-light!
        (load-theme 'moe-light t)
      (progn
       (let ((now (list (string-to-number (format-time-string "%H"))
                        (string-to-number (format-time-string "%M")))))
         (if (and (or                        ;magic-logic [tm]
                   (> (car now) (car 24h/sunrise)) 
                   (and 
                    (= (car now) (car 24h/sunrise)) 
                    (>= (second now) (second 24h/sunrise)))) 
                  (or 
                   (< (car now) (car 24h/sunset)) 
                   (and 
                    (= (car now) (car 24h/sunset)) 
                    (< (second now) (second 24h/sunset)))))
             (load-theme 'moe-light t)
           (load-theme 'moe-dark t)
           ))))))

(defun moe-theme-auto-switch ()
  (interactive)
  (if (boundp '24h/sunrise)
      (switch-by-locale)
    (switch-at-fixed-time))
  )

(if (and
     (boundp 'calendar-longitude)
     (boundp 'calendar-latitude)
     (eql moe-theme-switch-by-sunrise-and-sunset t))
    (progn
      (convert-time-format-of-sunrise-and-sunset)
      (run-with-timer 0 (* 60 60 24) 'convert-time-format-of-sunrise-and-sunset))
  ()
  )


(moe-theme-auto-switch)

(run-with-timer 0 (* 1 60) 'moe-theme-auto-switch) 

(provide 'moe-theme-switcher)


