
;; title: GamerVote
;; version: 1.0.0
;; summary: Gaming community democracy platform for server rules and tournament organization
;; description: A smart contract that enables democratic voting on server rules,
;;              tournament organization, and community governance for gaming communities

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-VOTED (err u101))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u102))
(define-constant ERR-VOTING-ENDED (err u103))
(define-constant ERR-INVALID-PROPOSAL (err u104))
(define-constant ERR-ALREADY-REGISTERED (err u105))
(define-constant ERR-NOT-REGISTERED (err u106))
(define-constant ERR-TOURNAMENT-NOT-FOUND (err u107))
(define-constant ERR-TOURNAMENT-FULL (err u108))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Data variables
(define-data-var next-proposal-id uint u1)
(define-data-var next-tournament-id uint u1)

;; Data maps for user registration and roles
(define-map users
    principal
    {
        username: (string-ascii 32),
        role: (string-ascii 16),
        reputation: uint,
        registered-at: uint
    }
)

;; Data maps for proposals (server rules, community decisions)
(define-map proposals
    uint
    {
        title: (string-ascii 64),
        description: (string-ascii 256),
        proposer: principal,
        votes-for: uint,
        votes-against: uint,
        voting-end-height: uint,
        proposal-type: (string-ascii 32),
        executed: bool
    }
)

;; Track who voted on which proposal
(define-map votes
    {proposal-id: uint, voter: principal}
    {vote: bool, voted-at: uint}
)

;; Data maps for tournaments
(define-map tournaments
    uint
    {
        name: (string-ascii 64),
        game: (string-ascii 32),
        max-participants: uint,
        current-participants: uint,
        entry-fee: uint,
        prize-pool: uint,
        organizer: principal,
        start-height: uint,
        registration-end: uint,
        status: (string-ascii 16)
    }
)

;; Tournament participants
(define-map tournament-participants
    {tournament-id: uint, participant: principal}
    {registered-at: uint, paid: bool}
)

;; Public functions

;; User registration
(define-public (register-user (username (string-ascii 32)))
    (let ((caller tx-sender))
        (if (is-some (map-get? users caller))
            ERR-ALREADY-REGISTERED
            (begin
                (map-set users caller {
                    username: username,
                    role: "member",
                    reputation: u10,
                    registered-at: block-height
                })
                (ok true)
            )
        )
    )
)

;; Update user role (only contract owner can promote users)
(define-public (update-user-role (user principal) (new-role (string-ascii 16)))
    (if (is-eq tx-sender CONTRACT-OWNER)
        (match (map-get? users user)
            user-data (begin
                (map-set users user (merge user-data {role: new-role}))
                (ok true)
            )
            ERR-NOT-REGISTERED
        )
        ERR-NOT-AUTHORIZED
    )
)

;; Create a new proposal
(define-public (create-proposal
    (title (string-ascii 64))
    (description (string-ascii 256))
    (voting-duration uint)
    (proposal-type (string-ascii 32))
)
    (let
        (
            (proposal-id (var-get next-proposal-id))
            (caller tx-sender)
        )
        (match (map-get? users caller)
            user-data
            (begin
                (map-set proposals proposal-id {
                    title: title,
                    description: description,
                    proposer: caller,
                    votes-for: u0,
                    votes-against: u0,
                    voting-end-height: (+ block-height voting-duration),
                    proposal-type: proposal-type,
                    executed: false
                })
                (var-set next-proposal-id (+ proposal-id u1))
                (ok proposal-id)
            )
            ERR-NOT-REGISTERED
        )
    )
)

;; Vote on a proposal
(define-public (vote-on-proposal (proposal-id uint) (vote-for bool))
    (let
        (
            (caller tx-sender)
            (vote-key {proposal-id: proposal-id, voter: caller})
        )
        (match (map-get? proposals proposal-id)
            proposal-data
            (if (> block-height (get voting-end-height proposal-data))
                ERR-VOTING-ENDED
                (if (is-some (map-get? votes vote-key))
                    ERR-ALREADY-VOTED
                    (match (map-get? users caller)
                        user-data
                        (begin
                            ;; Record the vote
                            (map-set votes vote-key {
                                vote: vote-for,
                                voted-at: block-height
                            })
                            ;; Update proposal vote counts
                            (if vote-for
                                (map-set proposals proposal-id
                                    (merge proposal-data {votes-for: (+ (get votes-for proposal-data) u1)})
                                )
                                (map-set proposals proposal-id
                                    (merge proposal-data {votes-against: (+ (get votes-against proposal-data) u1)})
                                )
                            )
                            (ok true)
                        )
                        ERR-NOT-REGISTERED
                    )
                )
            )
            ERR-PROPOSAL-NOT-FOUND
        )
    )
)

;; Create a tournament
(define-public (create-tournament
    (name (string-ascii 64))
    (game (string-ascii 32))
    (max-participants uint)
    (entry-fee uint)
    (registration-duration uint)
    (start-delay uint)
)
    (let
        (
            (tournament-id (var-get next-tournament-id))
            (caller tx-sender)
        )
        (match (map-get? users caller)
            user-data
            (begin
                (map-set tournaments tournament-id {
                    name: name,
                    game: game,
                    max-participants: max-participants,
                    current-participants: u0,
                    entry-fee: entry-fee,
                    prize-pool: u0,
                    organizer: caller,
                    start-height: (+ block-height start-delay),
                    registration-end: (+ block-height registration-duration),
                    status: "open"
                })
                (var-set next-tournament-id (+ tournament-id u1))
                (ok tournament-id)
            )
            ERR-NOT-REGISTERED
        )
    )
)

;; Register for a tournament
(define-public (register-for-tournament (tournament-id uint))
    (let
        (
            (caller tx-sender)
            (participant-key {tournament-id: tournament-id, participant: caller})
        )
        (match (map-get? tournaments tournament-id)
            tournament-data
            (if (> block-height (get registration-end tournament-data))
                ERR-VOTING-ENDED
                (if (>= (get current-participants tournament-data) (get max-participants tournament-data))
                    ERR-TOURNAMENT-FULL
                    (if (is-some (map-get? tournament-participants participant-key))
                        ERR-ALREADY-VOTED
                        (match (map-get? users caller)
                            user-data
                            (begin
                                ;; Register participant
                                (map-set tournament-participants participant-key {
                                    registered-at: block-height,
                                    paid: false
                                })
                                ;; Update tournament participant count
                                (map-set tournaments tournament-id
                                    (merge tournament-data {
                                        current-participants: (+ (get current-participants tournament-data) u1)
                                    })
                                )
                                (ok true)
                            )
                            ERR-NOT-REGISTERED
                        )
                    )
                )
            )
            ERR-TOURNAMENT-NOT-FOUND
        )
    )
)

;; Read only functions

;; Get user information
(define-read-only (get-user (user principal))
    (map-get? users user)
)

;; Get proposal information
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

;; Get tournament information
(define-read-only (get-tournament (tournament-id uint))
    (map-get? tournaments tournament-id)
)

;; Check if user has voted on proposal
(define-read-only (has-voted (proposal-id uint) (voter principal))
    (is-some (map-get? votes {proposal-id: proposal-id, voter: voter}))
)

;; Get vote details
(define-read-only (get-vote (proposal-id uint) (voter principal))
    (map-get? votes {proposal-id: proposal-id, voter: voter})
)

;; Check if user is registered for tournament
(define-read-only (is-tournament-participant (tournament-id uint) (participant principal))
    (is-some (map-get? tournament-participants {tournament-id: tournament-id, participant: participant}))
)

;; Get current proposal ID counter
(define-read-only (get-next-proposal-id)
    (var-get next-proposal-id)
)

;; Get current tournament ID counter
(define-read-only (get-next-tournament-id)
    (var-get next-tournament-id)
)

;; Check if proposal voting is still active
(define-read-only (is-voting-active (proposal-id uint))
    (match (map-get? proposals proposal-id)
        proposal-data (<= block-height (get voting-end-height proposal-data))
        false
    )
)

;; Private functions

;; Calculate reputation bonus (could be used for weighted voting in future)
(define-private (calculate-reputation-bonus (reputation uint))
    (if (> reputation u50)
        u2
        (if (> reputation u20)
            u1
            u0
        )
    )
)
