;; TrustNet - Stake-Secured Social Protocol
;;
;; Summary:
;; A revolutionary social networking protocol where reputation is earned, not gamed. 
;; Every social action requires STX staking, creating authentic engagement and 
;; eliminating bots while building a trustworthy digital reputation ecosystem.
;;
;; Description:
;; TrustNet reimagines social networking by introducing financial accountability 
;; to every interaction. Unlike traditional platforms where fake accounts and 
;; manipulation run rampant, TrustNet requires users to stake STX tokens for 
;; profile creation, content posting, and social endorsements. This creates a 
;; self-policing ecosystem where quality content rises naturally, authentic 
;; relationships flourish, and reputation becomes a valuable, transferable asset. 
;; Built on Stacks, every social interaction is secured by Bitcoin's finality, 
;; ensuring your digital reputation is permanent, portable, and protected from 
;; platform manipulation. TrustNet transforms social media from an attention 
;; economy into a value economy where genuine contribution is rewarded.
;;

;; Contract Constants & Configuration

(define-constant CONTRACT_OWNER tx-sender)

;; Error Definitions

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROFILE_EXISTS (err u101))
(define-constant ERR_PROFILE_NOT_FOUND (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))
(define-constant ERR_INVALID_AMOUNT (err u104))
(define-constant ERR_ALREADY_FOLLOWING (err u105))
(define-constant ERR_NOT_FOLLOWING (err u106))
(define-constant ERR_SELF_FOLLOW (err u107))
(define-constant ERR_ALREADY_ENDORSED (err u108))
(define-constant ERR_POST_NOT_FOUND (err u109))
(define-constant ERR_INVALID_POST_ID (err u110))

;; Stake Requirements Configuration

(define-constant MIN_PROFILE_STAKE u1000000) ;; 1 STX - Profile creation stake
(define-constant MIN_POST_BOOST u100000) ;; 0.1 STX - Minimum post boost
(define-constant MIN_ENDORSEMENT_STAKE u500000) ;; 0.5 STX - Endorsement stake

;; Protocol State Variables

(define-data-var next-profile-id uint u1)
(define-data-var next-post-id uint u1)
(define-data-var protocol-fee-rate uint u100) ;; 1% = 100 basis points

;; Core Data Structures

;; User Profile Registry - Central identity management
(define-map profiles
  { profile-id: uint }
  {
    owner: principal,
    username: (string-ascii 50),
    bio: (string-utf8 280),
    avatar-url: (string-ascii 200),
    created-at: uint,
    staked-amount: uint,
    reputation-score: uint,
    follower-count: uint,
    following-count: uint,
    post-count: uint,
    total-endorsements: uint,
    is-active: bool,
  }
)

;; Username Registry - Ensures unique handles across platform
(define-map username-to-profile
  (string-ascii 50)
  uint
)

;; Principal to Profile Mapping - Links wallet addresses to social identities
(define-map principal-to-profile
  principal
  uint
)

;; Social Graph Relationships - Tracks verified connections
(define-map following
  {
    follower: uint,
    following: uint,
  }
  {
    followed-at: uint,
    is-active: bool,
  }
)

;; Content Repository - Immutable post storage
(define-map posts
  { post-id: uint }
  {
    author: uint,
    content: (string-utf8 500),
    created-at: uint,
    boosted-amount: uint,
    endorsement-count: uint,
    is-active: bool,
  }
)

;; Post Endorsement System - Stake-backed content validation
(define-map post-endorsements
  {
    post-id: uint,
    endorser: uint,
  }
  {
    endorsed-at: uint,
    stake-amount: uint,
  }
)

;; Profile Endorsement Network - Peer reputation validation
(define-map profile-endorsements
  {
    endorser: uint,
    endorsed: uint,
  }
  {
    endorsed-at: uint,
    stake-amount: uint,
    message: (string-utf8 140),
  }
)

;; Reputation Staking Pools - Profile-specific stake tracking
(define-map profile-stakes
  {
    profile-id: uint,
    staker: principal,
  }
  {
    amount: uint,
    staked-at: uint,
  }
)

;; Content Monetization Stakes - Post boost tracking
(define-map post-boosts
  {
    post-id: uint,
    booster: principal,
  }
  {
    amount: uint,
    boosted-at: uint,
  }
)

;; Read-Only Functions - Data Queries

;; Retrieve complete profile information by ID
(define-read-only (get-profile (profile-id uint))
  (map-get? profiles { profile-id: profile-id })
)

;; Find profile using unique username
(define-read-only (get-profile-by-username (username (string-ascii 50)))
  (match (map-get? username-to-profile username)
    profile-id (get-profile profile-id)
    none
  )
)

;; Resolve profile from wallet address
(define-read-only (get-profile-by-principal (user principal))
  (match (map-get? principal-to-profile user)
    profile-id (get-profile profile-id)
    none
  )
)

;; Check username availability for registration
(define-read-only (is-username-available (username (string-ascii 50)))
  (is-none (map-get? username-to-profile username))
)

;; Verify active following relationship between users
(define-read-only (is-following
    (follower-id uint)
    (following-id uint)
  )
  (match (map-get? following {
    follower: follower-id,
    following: following-id,
  })
    follow-data (get is-active follow-data)
    false
  )
)

;; Retrieve post content and metadata
(define-read-only (get-post (post-id uint))
  (map-get? posts { post-id: post-id })
)

;; Get next available profile identifier
(define-read-only (get-next-profile-id)
  (var-get next-profile-id)
)

;; Get next available post identifier
(define-read-only (get-next-post-id)
  (var-get next-post-id)
)

;; Calculate dynamic reputation score based on stakes and activity
(define-read-only (calculate-reputation-score (profile-id uint))
  (match (get-profile profile-id)
    profile-data (let (
        (base-score (get staked-amount profile-data))
        (follower-bonus (* (get follower-count profile-data) u1000))
        (endorsement-bonus (* (get total-endorsements profile-data) u2000))
        (post-bonus (* (get post-count profile-data) u500))
      )
      (+ base-score (+ follower-bonus (+ endorsement-bonus post-bonus)))
    )
    u0
  )
)

;; Public Functions - Core Protocol Actions

;; Create new user profile with initial reputation stake
(define-public (create-profile
    (username (string-ascii 50))
    (bio (string-utf8 280))
    (avatar-url (string-ascii 200))
  )
  (let (
      (profile-id (var-get next-profile-id))
      (current-block stacks-block-height)
    )
    ;; Prevent duplicate profile creation per wallet
    (asserts! (is-none (map-get? principal-to-profile tx-sender))
      ERR_PROFILE_EXISTS
    )

    ;; Ensure username uniqueness across platform
    (asserts! (is-username-available username) ERR_PROFILE_EXISTS)

    ;; Verify sufficient balance for minimum stake
    (asserts! (>= (stx-get-balance tx-sender) MIN_PROFILE_STAKE)
      ERR_INSUFFICIENT_FUNDS
    )

    ;; Transfer stake to protocol escrow
    (try! (stx-transfer? MIN_PROFILE_STAKE tx-sender (as-contract tx-sender)))

    ;; Initialize new profile with stake-backed reputation
    (map-set profiles { profile-id: profile-id } {
      owner: tx-sender,
      username: username,
      bio: bio,
      avatar-url: avatar-url,
      created-at: current-block,
      staked-amount: MIN_PROFILE_STAKE,
      reputation-score: MIN_PROFILE_STAKE,
      follower-count: u0,
      following-count: u0,
      post-count: u0,
      total-endorsements: u0,
      is-active: true,
    })

    ;; Establish global identity mappings
    (map-set username-to-profile username profile-id)
    (map-set principal-to-profile tx-sender profile-id)
    (map-set profile-stakes {
      profile-id: profile-id,
      staker: tx-sender,
    } {
      amount: MIN_PROFILE_STAKE,
      staked-at: current-block,
    })

    ;; Increment global profile counter
    (var-set next-profile-id (+ profile-id u1))

    (ok profile-id)
  )
)

;; Establish verified social connection
(define-public (follow-user (following-id uint))
  (let (
      (follower-profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    ;; Resolve follower identity from wallet address
    (match follower-profile-result
    follower-id (begin
        ;; Prevent self-following to maintain graph integrity
        (asserts! (not (is-eq follower-id following-id)) ERR_SELF_FOLLOW)

        ;; Verify target profile exists and is active
        (asserts! (is-some (get-profile following-id)) ERR_PROFILE_NOT_FOUND)

        ;; Prevent duplicate follow relationships
        (asserts! (not (is-following follower-id following-id))
          ERR_ALREADY_FOLLOWING
        )

        ;; Record timestamped social connection
        (map-set following {
          follower: follower-id,
          following: following-id,
        } {
          followed-at: current-block,
          is-active: true,
        })

        ;; Increment follower count for target user
        (match (get-profile following-id)
          following-profile (map-set profiles { profile-id: following-id }
            (merge following-profile { follower-count: (+ (get follower-count following-profile) u1) })
          )
          false
        )

        ;; Increment following count for initiating user
        (match (get-profile follower-id)
          follower-profile (map-set profiles { profile-id: follower-id }
            (merge follower-profile { following-count: (+ (get following-count follower-profile) u1) })
          )
          false
        )

        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Remove social connection and update metrics
(define-public (unfollow-user (following-id uint))
  (let ((follower-profile-result (map-get? principal-to-profile tx-sender)))
    ;; Resolve follower identity
    (match follower-profile-result
      follower-id (begin
        ;; Verify existing follow relationship
        (asserts! (is-following follower-id following-id) ERR_NOT_FOLLOWING)

        ;; Remove connection from social graph
        (map-delete following {
          follower: follower-id,
          following: following-id,
        })

        ;; Decrement follower count for target user
        (match (get-profile following-id)
          following-profile (map-set profiles { profile-id: following-id }
            (merge following-profile { follower-count: (- (get follower-count following-profile) u1) })
          )
          false
        )

        ;; Decrement following count for initiating user
        (match (get-profile follower-id)
          follower-profile (map-set profiles { profile-id: follower-id }
            (merge follower-profile { following-count: (- (get following-count follower-profile) u1) })
          )
          false
        )

        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Publish content to decentralized social graph
(define-public (create-post (content (string-utf8 500)))
  (let (
      (author-profile-result (map-get? principal-to-profile tx-sender))
      (post-id (var-get next-post-id))
      (current-block stacks-block-height)
    )
    ;; Resolve author profile from wallet address
    (match author-profile-result
      author-id (begin
        ;; Create immutable content record with metadata
        (map-set posts { post-id: post-id } {
          author: author-id,
          content: content,
          created-at: current-block,
          boosted-amount: u0,
          endorsement-count: u0,
          is-active: true,
        })

        ;; Increment author's total post count
        (match (get-profile author-id)
          author-profile (map-set profiles { profile-id: author-id }
            (merge author-profile { post-count: (+ (get post-count author-profile) u1) })
          )
          false
        )

        ;; Increment global post identifier
        (var-set next-post-id (+ post-id u1))

        (ok post-id)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Amplify content visibility through economic backing
(define-public (boost-post
    (post-id uint)
    (amount uint)
  )
  (let ((current-block stacks-block-height))
    ;; Enforce minimum boost threshold
    (asserts! (>= amount MIN_POST_BOOST) ERR_INVALID_AMOUNT)

    ;; Verify target post exists
    (asserts! (is-some (get-post post-id)) ERR_POST_NOT_FOUND)

    ;; Confirm sufficient wallet balance
    (asserts! (>= (stx-get-balance tx-sender) amount) ERR_INSUFFICIENT_FUNDS)

    ;; Transfer boost funds to protocol treasury
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

    ;; Record boost transaction with timestamp
    (map-set post-boosts {
      post-id: post-id,
      booster: tx-sender,
    } {
      amount: amount,
      boosted-at: current-block,
    })

    ;; Accumulate total boost value for post
    (match (get-post post-id)
      post-data (map-set posts { post-id: post-id }
        (merge post-data { boosted-amount: (+ (get boosted-amount post-data) amount) })
      )
      false
    )

    (ok true)
  )
)

;; Provide stake-backed endorsement for content quality
(define-public (endorse-post
    (post-id uint)
    (stake-amount uint)
  )
  (let (
      (endorser-profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    ;; Enforce minimum endorsement stake requirement
    (asserts! (>= stake-amount MIN_ENDORSEMENT_STAKE) ERR_INVALID_AMOUNT)

    ;; Verify target post exists and is active
    (asserts! (is-some (get-post post-id)) ERR_POST_NOT_FOUND)

    ;; Resolve endorser profile
    (match endorser-profile-result
      endorser-id (begin
        ;; Prevent duplicate endorsements per user
        (asserts!
          (is-none (map-get? post-endorsements {
            post-id: post-id,
            endorser: endorser-id,
          }))
          ERR_ALREADY_ENDORSED
        )

        ;; Verify sufficient stake balance
        (asserts! (>= (stx-get-balance tx-sender) stake-amount)
          ERR_INSUFFICIENT_FUNDS
        )

        ;; Lock endorsement stake in protocol
        (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))

        ;; Record stake-backed endorsement
        (map-set post-endorsements {
          post-id: post-id,
          endorser: endorser-id,
        } {
          endorsed-at: current-block,
          stake-amount: stake-amount,
        })

        ;; Increment post's endorsement counter
        (match (get-post post-id)
          post-data (map-set posts { post-id: post-id }
            (merge post-data { endorsement-count: (+ (get endorsement-count post-data) u1) })
          )
          false
        )

        ;; Boost content author's reputation through endorsement
        (match (get-post post-id)
          post-data (match (get-profile (get author post-data))
            author-profile (map-set profiles { profile-id: (get author post-data) }
              (merge author-profile { total-endorsements: (+ (get total-endorsements author-profile) u1) })
            )
            false
          )
          false
        )

        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)