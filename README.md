# State Channels

## Description

Exchange paid services off-chain between the Streamer's contract owner (the Guru) and rube clients with funded channels. The Guru provides the service in exchange for signed vouchers which can later be redeemed on-chain.

## Installation and Setup Instructions

### Prerequisites

- Node (v18 LTS)
- Yarn (v1 or v2+)
- Git

### Clone the Repository

To get started, clone the repository to your local machine:

```bash
git clone https://github.com/dianakocsis/state-channels
```

### Environment Setup

1. Navigate to the cloned directory:

   ```bash
   cd state-channels
   ```

2. Copy the .env.example files to create a new .env file and fill in the necessary details:

   ```bash
   cp .env.example .env
   ```

   ```bash
   cd frontend
   cp .env.example .env
   ```

### Environment Setup

1. Install Dependencies

   To install project dependencies, run the following commands:

   ```bash
   yarn install
   cd frontend && yarn install
   cd ..
   ```

2. Start Local Blockchain

   In a new terminal, start the local blockchain:

   ```bash
   yarn chain
   ```

3. Deploy Contracts (In another tab)

   Open another terminal tab and deploy the contracts:

   ```bash
   yarn deploy
   ```

4. Start the Aplication (In another tab)

   Finally, in a new terminal tab, start the application:

   ```bash
   yarn start
   ```

## Testnet Deploy Information

| Contract | Address Etherscan Link                                                            |
| -------- | --------------------------------------------------------------------------------- |
| Streamer | `https://sepolia.etherscan.io/address/0xE1a326458160BcDa2F54666131C5412b7530006b` |
