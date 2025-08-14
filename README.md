# TrustNet

**Stake-Secured Social Protocol on Stacks**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Clarity](https://img.shields.io/badge/Clarity-v3-purple.svg)](https://docs.stacks.co/clarity)
[![Tests](https://img.shields.io/badge/Tests-Vitest-green.svg)](https://vitest.dev)

A revolutionary social networking protocol where reputation is earned, not gamed. Every social action requires STX staking, creating authentic engagement and eliminating bots while building a trustworthy digital reputation ecosystem.

## 🌟 Vision

TrustNet reimagines social networking by introducing financial accountability to every interaction. Unlike traditional platforms where fake accounts and manipulation run rampant, TrustNet requires users to stake STX tokens for profile creation, content posting, and social endorsements. This creates a self-policing ecosystem where quality content rises naturally, authentic relationships flourish, and reputation becomes a valuable, transferable asset.

Built on Stacks, every social interaction is secured by Bitcoin's finality, ensuring your digital reputation is permanent, portable, and protected from platform manipulation. TrustNet transforms social media from an attention economy into a value economy where genuine contribution is rewarded.

## 🎯 Key Features

### 🔐 Stake-Secured Profiles

- **Profile Creation**: Minimum 1 STX stake required for account creation
- **Reputation Staking**: Additional staking increases reputation score
- **Unique Identity**: Immutable username registry prevents impersonation
- **Transferable Reputation**: Your reputation is owned by you, not the platform

### 👥 Verified Social Graph

- **Authenticated Follows**: All connections are blockchain-verified
- **Sybil Resistance**: Economic barriers prevent fake account networks
- **Trust Metrics**: Follower counts carry real economic weight
- **Social Proof**: Following relationships are permanent and auditable

### 📝 Quality Content System

- **Post Boosting**: Economic amplification for important content
- **Stake-Backed Endorsements**: Users stake STX to endorse quality posts
- **Author Reputation**: Content creators build verifiable track records
- **Spam Prevention**: Economic barriers eliminate low-quality content

### 🏆 Reputation Economy

- **Dynamic Scoring**: Reputation calculated from stakes, endorsements, and activity
- **Peer Validation**: Profile endorsements with testimonial messages
- **Economic Incentives**: Quality participation is financially rewarded
- **Transparent Metrics**: All reputation factors are on-chain and auditable

## 🔧 Technical Architecture

### Smart Contract Overview

The TrustNet protocol consists of a single, comprehensive smart contract (`trustnet.clar`) that manages all core functionality:

#### Core Data Structures

```clarity
;; User Profiles - Central identity management
(define-map profiles { profile-id: uint } { ... })

;; Social Graph - Verified connections
(define-map following { follower: uint, following: uint } { ... })

;; Content System - Immutable posts with metadata
(define-map posts { post-id: uint } { ... })

;; Reputation System - Stake-backed endorsements
(define-map profile-endorsements { endorser: uint, endorsed: uint } { ... })
```

#### Stake Requirements

| Action | Minimum Stake | Purpose |
|--------|---------------|---------|
| Profile Creation | 1 STX | Identity verification & spam prevention |
| Post Endorsement | 0.5 STX | Quality content validation |
| Post Boosting | 0.1 STX | Content amplification |
| Profile Endorsement | 0.5 STX | Peer reputation validation |

### Key Functions

#### Profile Management

- `create-profile`: Create new stake-secured identity
- `update-profile`: Modify bio and avatar information
- `stake-for-reputation`: Increase reputation through additional staking

#### Social Interactions

- `follow-user` / `unfollow-user`: Manage social connections
- `create-post`: Publish content to the network
- `boost-post`: Economically amplify content visibility

#### Reputation System

- `endorse-post`: Stake-backed content quality validation
- `endorse-profile`: Peer-to-peer reputation endorsement
- `calculate-reputation-score`: Dynamic reputation calculation

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Smart contract development tool
- [Node.js](https://nodejs.org/) v18+ - For running tests
- [Stacks Wallet](https://hiro.so/wallet) - For interacting with the protocol

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/paul-sha256/trustnet.git
   cd trustnet
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify contract syntax**

   ```bash
   clarinet check
   ```

### Development Setup

1. **Start Clarinet console**

   ```bash
   clarinet console
   ```

2. **Deploy contract locally**

   ```clarity
   ::deploy_contracts
   ```

3. **Interact with functions**

   ```clarity
   (contract-call? .trustnet create-profile "alice" "Web3 enthusiast" "https://avatar.url")
   ```

### Running Tests

The project includes comprehensive test coverage using Vitest and Clarinet SDK:

```bash
# Run all tests
npm test

# Run tests with coverage and cost analysis
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Coverage

- ✅ Profile creation and management
- ✅ Social graph operations (follow/unfollow)
- ✅ Content creation and boosting
- ✅ Reputation endorsement systems
- ✅ Error handling and edge cases
- ✅ Stake requirements validation

## 📖 Usage Examples

### Creating a Profile

```clarity
;; Create a new profile with minimum stake
(contract-call? .trustnet create-profile 
  "satoshi" 
  "Bitcoin creator, privacy advocate" 
  "https://example.com/avatar.jpg")
```

### Following Users

```clarity
;; Follow another user (profile ID required)
(contract-call? .trustnet follow-user u2)
```

### Publishing Content

```clarity
;; Create a new post
(contract-call? .trustnet create-post 
  "Just deployed my first smart contract on Stacks! 🚀 #DeFi #Bitcoin")
```

### Endorsing Quality Content

```clarity
;; Endorse a post with stake
(contract-call? .trustnet endorse-post u1 u500000) ;; 0.5 STX endorsement
```

### Boosting Content Visibility

```clarity
;; Boost a post to increase visibility
(contract-call? .trustnet boost-post u1 u100000) ;; 0.1 STX boost
```

## 🛡️ Security Features

### Economic Security

- **Sybil Resistance**: Staking requirements prevent fake account creation
- **Spam Prevention**: Economic barriers eliminate low-value content
- **Reputation Integrity**: Self-endorsement protection maintains trust metrics

### Technical Security

- **Input Validation**: All user inputs are strictly validated
- **Access Control**: Profile ownership verification for all modifications
- **State Consistency**: Atomic operations ensure data integrity
- **Error Handling**: Comprehensive error codes for debugging

### Audit Considerations

- **Open Source**: Full contract code is publicly auditable
- **Test Coverage**: Extensive test suite validates all functionality
- **Documentation**: Detailed inline comments explain all logic
- **Best Practices**: Follows Clarity security guidelines

## 🏗️ Project Structure

```
trustnet/
├── contracts/
│   └── trustnet.clar          # Main protocol contract
├── tests/
│   └── trustnet.test.ts       # Comprehensive test suite
├── settings/
│   ├── Devnet.toml           # Development network config
│   ├── Testnet.toml          # Test network config
│   └── Mainnet.toml          # Production network config
├── Clarinet.toml             # Project configuration
├── package.json              # Dependencies and scripts
└── README.md                 # Project documentation
```

## 🤝 Contributing

We welcome contributions to TrustNet! Here's how you can help:

### Development Process

1. **Fork the repository**
2. **Create a feature branch**

   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Write tests** for new functionality
4. **Implement your changes**
5. **Run the test suite**

   ```bash
   npm test
   ```

6. **Submit a pull request**

### Contribution Guidelines

- Write comprehensive tests for all new features
- Follow Clarity best practices and style guidelines
- Include detailed commit messages
- Update documentation for user-facing changes
- Ensure all tests pass before submitting PRs

## 🔧 Configuration

### Network Settings

The protocol can be deployed on different Stacks networks:

- **Devnet**: Local development and testing
- **Testnet**: Public test network for integration testing
- **Mainnet**: Production Bitcoin-secured network

### Customizable Parameters

```clarity
;; Stake requirements (modifiable via governance)
(define-constant MIN_PROFILE_STAKE u1000000)    ;; 1 STX
(define-constant MIN_POST_BOOST u100000)        ;; 0.1 STX
(define-constant MIN_ENDORSEMENT_STAKE u500000) ;; 0.5 STX

;; Protocol fees
(define-data-var protocol-fee-rate uint u100)   ;; 1% (100 basis points)
```

## 📊 Economics

### Stake Distribution

- **Profile Stakes**: Locked until profile deactivation
- **Endorsement Stakes**: Locked to maintain endorsement validity
- **Boost Stakes**: Transferred to protocol treasury
- **Protocol Fees**: 1% fee on certain operations (governance controlled)

### Reputation Calculation

```clarity
reputation = base_stake + 
             (followers × 1000) + 
             (endorsements × 2000) + 
             (posts × 500)
```

## 📈 Roadmap

### Phase 1: Core Protocol (Current)

- [x] Profile creation and management
- [x] Social graph functionality
- [x] Content creation and endorsement
- [x] Basic reputation system

### Phase 2: Enhanced Features

- [ ] Governance token integration
- [ ] Advanced reputation algorithms
- [ ] Content moderation mechanisms
- [ ] Mobile-friendly interfaces

### Phase 3: Ecosystem Expansion

- [ ] Third-party integrations
- [ ] Developer APIs
- [ ] Cross-chain compatibility
- [ ] Advanced analytics

## ⚠️ Important Notes

### Alpha Software

TrustNet is currently in development. Use at your own risk and never stake more than you can afford to lose.

### Testnet Usage

For development and testing, use Stacks testnet STX tokens. Mainnet deployment should only be used with proper security audits.

### Gas Costs

All operations require transaction fees in addition to stake requirements. Factor in gas costs when planning interactions.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Stacks Foundation** for the robust blockchain infrastructure
- **Hiro Systems** for excellent developer tools
- **Clarity Community** for language support and best practices
- **Bitcoin Community** for inspiring decentralized innovation
