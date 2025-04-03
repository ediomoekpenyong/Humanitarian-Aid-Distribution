;; Recipient Verification Contract
;; This contract validates the eligibility of aid beneficiaries

(define-data-var admin principal tx-sender)

;; Data structure for recipients
(define-map recipients
  { id: (string-utf8 36) }  ;; Unique identifier for each recipient
  {
    name: (string-utf8 100),
    location: (string-utf8 100),
    verified: bool,
    needs-assessment: (string-utf8 200),
    last-verified: uint
  }
)

;; Public function to register a new recipient
(define-public (register-recipient
    (id (string-utf8 36))
    (name (string-utf8 100))
    (location (string-utf8 100))
    (needs-assessment (string-utf8 200)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? recipients { id: id })) (err u100))
    (ok (map-set recipients
      { id: id }
      {
        name: name,
        location: location,
        verified: false,
        needs-assessment: needs-assessment,
        last-verified: block-height
      }
    ))
  )
)

;; Public function to verify a recipient
(define-public (verify-recipient (id (string-utf8 36)))
  (let ((recipient (unwrap! (map-get? recipients { id: id }) (err u404))))
    (begin
      (asserts! (is-eq tx-sender (var-get admin)) (err u403))
      (ok (map-set recipients
        { id: id }
        (merge recipient {
          verified: true,
          last-verified: block-height
        })
      ))
    )
  )
)

;; Read-only function to check if a recipient is verified
(define-read-only (is-recipient-verified (id (string-utf8 36)))
  (match (map-get? recipients { id: id })
    recipient (ok (get verified recipient))
    (err u404)
  )
)

;; Read-only function to get recipient details
(define-read-only (get-recipient-details (id (string-utf8 36)))
  (map-get? recipients { id: id })
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
