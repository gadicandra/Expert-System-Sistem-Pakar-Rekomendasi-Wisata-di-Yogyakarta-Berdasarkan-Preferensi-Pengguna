; Template
(deftemplate preferensi
  (slot lokasi)
  (slot aktivitas)
)

(deftemplate destinasi
  (slot nama)
  (slot lokasi)
  (slot aktivitas)
)

; Inisialisasi
(deffacts status-awal
  (fase mulai)
)

; Rules
(defrule load-facts ; Load Data
  ?state <- (fase mulai)
  =>
  (load-facts "data_wisata.dat")
  (printout t "Rekomendasi Wisata Jogja" crlf)
  (retract ?state)
  (assert (fase tanya-lokasi))
)

(defrule tanya-lokasi
   ?state <- (fase tanya-lokasi)
   =>
   (printout t "Halo! Untuk liburan kali ini, kamu lebih prefer jalan-jalan ke 'alam' atau di 'perkotaan' aja? ")
   (bind ?lokasi (read))
   (assert (preferensi-sementara lokasi ?lokasi))
   (retract ?state)
   (assert (fase tanya-aktivitas))
)

(defrule tanya-aktivitas
   ?state <- (fase tanya-aktivitas)
   =>
   (printout t "Wah, asik tuh! Nah, di sana kamu lebih pengen nyari 'kuliner', belajar 'sejarah', atau hunting foto 'estetik'? ")
   (bind ?aktivitas (read))
   (assert (preferensi-sementara aktivitas ?aktivitas))
   (retract ?state)
   (assert (fase gabung-data))
)

; Penggabungan Fakta
(defrule proses-preferensi
   ?state <- (fase gabung-data)
   (preferensi-sementara lokasi ?lokasi)
   (preferensi-sementara aktivitas ?aktivitas)
   =>
   (assert (preferensi (lokasi ?lokasi) (aktivitas ?aktivitas)))
   (retract ?state)
)

; Rekomendasi
(defrule berikan-rekomendasi
   (preferensi (lokasi ?lokasi) (aktivitas ?aktivitas))
   =>
   (bind ?hasil (find-all-facts ((?d destinasi)) 
                   (and (eq ?d:lokasi ?lokasi) 
                        (eq ?d:aktivitas ?aktivitas))))
   
   (if (> (length$ ?hasil) 0)
      then
      (printout t crlf "=> Berdasarkan pilihanmu, kamu wajib banget mampir ke:" crlf)
      
      (progn$ (?f ?hasil)
         (printout t "- " (fact-slot-value ?f nama) crlf)
      )
      (printout t crlf)
      
      else
      ; Jika list kosong
      (printout t crlf "=> Hmm, kayaknya aku belum punya rekomendasi yang pas buat kombinasi itu." crlf crlf)
   )
)