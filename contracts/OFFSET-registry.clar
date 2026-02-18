;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Carbon Credit Tracker (Elaborate Version)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ============================================================
;; Ownership & Roles
;; ============================================================

(define-data-var contract-owner (optional principal) none)

(define-map issuers
  { issuer: principal }
  { enabled: bool }
)

;; ============================================================
;; Global Supply Tracking
;; ============================================================

(define-data-var total-issued uint u0)
(define-data-var total-retired uint u0)

;; ============================================================
;; User Balances
;; ============================================================

(define-map balances
  { owner: principal }
  { amount: uint }
)

;; ============================================================
;; Retirement Registry
;; ============================================================

(define-map retirement-log
  { id: uint }
  {
    owner: principal,
    amount: uint
  }
)

(define-data-var retirement-counter uint u0)

;; ============================================================
;; Constants
;; ============================================================

(define-constant ERR-UNAUTHORIZED        (err u100))
(define-constant ERR-INVALID-AMOUNT      (err u101))
(define-constant ERR-INSUFFICIENT-BAL    (err u102))
(define-constant ERR-ALREADY-INIT        (err u103))

;; ============================================================
;; Internal Helpers
;; ============================================================

(define-private (is-owner (caller principal))
  (match (var-get contract-owner)
    owner (is-eq caller owner)
    false
  )
)

(define-public (initialize)
  (begin
    (asserts! (is-none (var-get contract-owner)) ERR-ALREADY-INIT)
    (var-set contract-owner (some tx-sender))
    (ok true)
  )
)

(define-private (is-issuer (caller principal))
  (or
    (is-owner caller)
    (default-to false
      (get enabled (map-get? issuers { issuer: caller }))
    )
  )
)

(define-private (get-balance (user principal))
  (default-to u0
    (get amount (map-get? balances { owner: user }))
  )
)

(define-private (set-balance (user principal) (amount uint))
  (map-set balances
    { owner: user }
    { amount: amount }
  )
)

;; ============================================================
;; Read-Only Views
;; ============================================================

(define-read-only (get-user-balance (user principal))
  (get-balance user)
)

(define-read-only (get-total-issued)
  (var-get total-issued)
)

(define-read-only (get-total-retired)
  (var-get total-retired)
)

(define-read-only (get-retirement (id uint))
  (map-get? retirement-log { id: id })
)

(define-read-only (is-authorized-issuer (who principal))
  (is-issuer who)
)

;; ============================================================
;; Issuance Functions
;; ============================================================

(define-public (issue-credits (recipient principal) (amount uint))
  (begin
    (asserts! (is-issuer tx-sender) ERR-UNAUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)

    (let (
          (current (get-balance recipient))
         )
      (set-balance recipient (+ current amount))
      (var-set total-issued (+ (var-get total-issued) amount))
      (ok true)
    )
  )
)

;; ============================================================
;; Transfer Functions
;; ============================================================

(define-public (transfer (recipient principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)

    (let (
          (sender-balance (get-balance tx-sender))
         )

      (asserts! (>= sender-balance amount) ERR-INSUFFICIENT-BAL)

      (let (
            (recipient-balance (get-balance recipient))
           )
        (set-balance tx-sender (- sender-balance amount))
        (set-balance recipient (+ recipient-balance amount))
        (ok true)
      )
    )
  )
)

;; ============================================================
;; Retirement (Burning) Functions
;; ============================================================

(define-public (retire (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)

    (let (
          (current (get-balance tx-sender))
         )

      (asserts! (>= current amount) ERR-INSUFFICIENT-BAL)

      ;; Deduct from balance
      (set-balance tx-sender (- current amount))

      ;; Update global retired total
      (var-set total-retired (+ (var-get total-retired) amount))

      ;; Record retirement event
      (let (
            (new-id (+ (var-get retirement-counter) u1))
           )
        (map-set retirement-log
          { id: new-id }
          {
            owner: tx-sender,
            amount: amount
          }
        )
        (var-set retirement-counter new-id)
        (ok new-id)
      )
    )
  )
)

;; ============================================================
;; Issuer Management
;; ============================================================

(define-public (add-issuer (issuer principal))
  (begin
    (asserts! (is-owner tx-sender) ERR-UNAUTHORIZED)
    (map-set issuers { issuer: issuer } { enabled: true })
    (ok true)
  )
)

(define-public (remove-issuer (issuer principal))
  (begin
    (asserts! (is-owner tx-sender) ERR-UNAUTHORIZED)
    (map-delete issuers { issuer: issuer })
    (ok true)
  )
)
