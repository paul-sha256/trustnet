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