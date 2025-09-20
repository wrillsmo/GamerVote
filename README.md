# GamerVote

GamerVote is a decentralized gaming community democracy platform built on the Stacks blockchain. It enables democratic voting on server rules, tournament organization, and community governance for gaming communities through smart contracts written in Clarity.

## Features

### Community Governance
- **User Registration System**: Players can register with usernames and gain reputation over time
- **Role-based Access Control**: Contract owner can assign roles to community members
- **Democratic Proposal System**: Create and vote on server rules, community decisions, and governance proposals
- **Transparent Voting**: All votes are recorded on-chain with full transparency

### Tournament Management
- **Tournament Creation**: Organize gaming tournaments with customizable parameters
- **Registration System**: Players can register for tournaments with entry fees and participant limits
- **Prize Pool Management**: Automated prize pool accumulation through entry fees
- **Multi-game Support**: Support for various gaming titles and tournament formats

### Reputation System
- **Merit-based Reputation**: Users earn reputation points through community participation
- **Future-ready Architecture**: Foundation for weighted voting and advanced governance features

## Technical Specifications

- **Blockchain**: Stacks (Layer-2 Bitcoin)
- **Smart Contract Language**: Clarity
- **Clarity Version**: 2.0
- **Epoch**: 2.5
- **Contract Architecture**: Single contract with modular functionality

### Data Structures

#### Users
- Username (32 character ASCII)
- Role assignment (member, moderator, admin)
- Reputation score
- Registration timestamp

#### Proposals
- Title and description
- Proposal type categorization
- Vote tracking (for/against)
- Voting duration with block-height based timing
- Execution status

#### Tournaments
- Tournament metadata (name, game, participants)
- Entry fee and prize pool management
- Registration periods and start times
- Participant tracking and payment status

## Installation

### Prerequisites
- Node.js (v16 or higher)
- Clarinet CLI
- Stacks Wallet for testing

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd GamerVote
```

2. Navigate to the contract directory:
```bash
cd GamerVote_contract
```

3. Install dependencies:
```bash
npm install
```

4. Run tests:
```bash
npm test
```

## Usage Examples

### User Registration
```clarity
;; Register a new user
(contract-call? .GamerVote register-user "PlayerOne")
```

### Creating Proposals
```clarity
;; Create a server rule proposal
(contract-call? .GamerVote create-proposal
    "New PvP Rules"
    "Implement new player vs player combat rules for server balance"
    u1000  ;; Voting duration in blocks (~1 week)
    "server-rules"
)
```

### Voting on Proposals
```clarity
;; Vote in favor of proposal #1
(contract-call? .GamerVote vote-on-proposal u1 true)

;; Vote against proposal #1
(contract-call? .GamerVote vote-on-proposal u1 false)
```

### Tournament Creation
```clarity
;; Create a gaming tournament
(contract-call? .GamerVote create-tournament
    "Summer Championship"
    "CS:GO"
    u16      ;; Max 16 participants
    u100000  ;; Entry fee in microSTX
    u500     ;; Registration period in blocks
    u100     ;; Start delay in blocks
)
```

### Tournament Registration
```clarity
;; Register for tournament #1
(contract-call? .GamerVote register-for-tournament u1)
```

## Contract Functions Documentation

### Public Functions

#### User Management
- `register-user(username)` - Register a new user with username
- `update-user-role(user, new-role)` - Update user role (owner only)

#### Proposal System
- `create-proposal(title, description, voting-duration, proposal-type)` - Create new proposal
- `vote-on-proposal(proposal-id, vote-for)` - Cast vote on proposal

#### Tournament System
- `create-tournament(name, game, max-participants, entry-fee, registration-duration, start-delay)` - Create tournament
- `register-for-tournament(tournament-id)` - Register for tournament

### Read-Only Functions

#### Data Retrieval
- `get-user(user)` - Get user information
- `get-proposal(proposal-id)` - Get proposal details
- `get-tournament(tournament-id)` - Get tournament information
- `get-vote(proposal-id, voter)` - Get specific vote details

#### Status Checks
- `has-voted(proposal-id, voter)` - Check if user voted on proposal
- `is-tournament-participant(tournament-id, participant)` - Check tournament registration
- `is-voting-active(proposal-id)` - Check if proposal voting is still open

#### Counters
- `get-next-proposal-id()` - Get next proposal ID
- `get-next-tournament-id()` - Get next tournament ID

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | ERR-NOT-AUTHORIZED | Caller not authorized for action |
| u101 | ERR-ALREADY-VOTED | User already voted on proposal |
| u102 | ERR-PROPOSAL-NOT-FOUND | Proposal does not exist |
| u103 | ERR-VOTING-ENDED | Voting period has ended |
| u104 | ERR-INVALID-PROPOSAL | Invalid proposal parameters |
| u105 | ERR-ALREADY-REGISTERED | User already registered |
| u106 | ERR-NOT-REGISTERED | User not registered |
| u107 | ERR-TOURNAMENT-NOT-FOUND | Tournament does not exist |
| u108 | ERR-TOURNAMENT-FULL | Tournament at capacity |

## Deployment Guide

### Local Testing (Clarinet)

1. Start Clarinet console:
```bash
clarinet console
```

2. Deploy contract:
```clarity
::deploy_contracts
```

3. Test contract functions:
```clarity
(contract-call? .GamerVote register-user "TestUser")
```

### Testnet Deployment

1. Configure testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

### Mainnet Deployment

1. Configure mainnet settings in `settings/Mainnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deployments generate --mainnet
clarinet deployments apply --mainnet
```

## Security Notes

### Access Control
- Contract owner has exclusive rights to update user roles
- Only registered users can create proposals and vote
- Voting periods are enforced through block-height validation

### Data Integrity
- All votes are immutable once cast
- Proposal and tournament data cannot be modified after creation
- User registration is permanent and cannot be reversed

### Best Practices
- Always verify user registration before allowing actions
- Implement proper front-end validation for user inputs
- Monitor contract events for unusual activity
- Use testnet for extensive testing before mainnet deployment

### Known Limitations
- No proposal execution mechanism (voting is advisory)
- Tournament prize distribution must be handled off-chain
- User reputation is not yet used for weighted voting
- No mechanism to cancel or modify tournaments after creation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add comprehensive tests
5. Submit a pull request

## License

This project is licensed under the ISC License.

## Support

For technical support or questions about the GamerVote platform, please create an issue in the repository or contact the development team.