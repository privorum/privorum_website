---
title: "Blockchain Permissioned"
date: 2018-11-28T15:15:26+10:00
featured: true
draft: false
---

Privorum develops end-to-end enterprise-grade blockchain solutions for businesses that want to deploy blockchain technology.

Distributed databases have emerged making it possible for many people to access certain parts of data simultaneously. However the significance of the databases have changed today and the world is asking for a global network that can allow different people to access the same data while guaranteeing the state of it as a whole, thereby improving the security and trust.

Researches and experts across the globe are working hard to enhance the security of these Distributed databases. One such perfect example is the Blockchain. 
The blockchain researchers and the open-source community of developers are working together offering a perfect opportunity for companies to benefit from this concept of trust that is deeply woven into all the blockchain technologies. Hyperledger, Corda, Ethereum, Smilo, and Quorum have emerged as some of the most popular blockchain development platforms that are tailor-made to handle specific enterprise use cases. 

------

# Consensus Algorithms
A consensus algorithm is a computer process which helps machines to achieve agreement among systems or distributed processes.  
The purpose of a consensus is to aid in achieving reliability and security in a network that has multiple unreliable nodes. 

## BFT - Byzantine Fault Tolerance (PoW,PoS,Sport,IBFT)
A Fault-tolerant system where components may fail and there is imperfect information on whether a component has failed. It

## Byzantine fault:
* a fault presenting different symptoms to different observers
* occurs in systems that require consensus

## Byzantine fault tolerance:
* defend against failures of system
* Reach consensus if failures are < 1/3

------


## Smilo Architecture: 
It comprises of four components namely: 

### Go-smilo Node (Modified GETH client)
It is designed to be a lightweight blockchain that takes advantage of the R&D and battle-tested Ethereum GETH 1.9.x PoW Blockchain. It is updated regularly such that it is in line with the future GETH releases.

## Some of the modifications done to the Smilo node are:
* Created a new consensus algorithm called Sport BFT, a VRF + Voting mechanism.
* The P2P layer is modified to allow connections to/from specific pre-set nodes.
* The block generation logic has been modified to have two states: `public state root` and `private state root`. Private transactions do not allow the transfer of tokens, transfer of tokens privately should be done via ZK Snarks public smart contracts.
* Block validation logic changed to handle `private transactions`
* The dual token system introduced. XSM (Smilo) and XSP (SmiloPay). Users pay for transactions with XSP and Gas deposit. The gas deposit is returned if all goes well.

## Vault Transaction Manager
Vault transaction manager refers to a general-purpose system that helps to submit private encrypted smart contracts via P2P to restricted parties. It uses the TweetNACL curve 25519 plus a random nonce to encrypt the smart contract state, thus hiding the transaction contents from other peers in the network.

## Smilo Blackbox
The Smilo Private Vault (SPV) is P2P software that stores and shares your private smart contract state across the network. It is a software program written in Golang that makes use of the Ethereum P2P capabilities to find peers and transfer encrypted data.
The protocol will search the network and identify the Vault peer that matches with the peer that is supposed to receive the data at the time of creating the transaction. During this transaction, the smart contract state will never be saved on the blockchain, only a hash that is consequently used as a checksum will be stored on the blockchain. 
With this hash, nodes can validate whether they have received a valid state or not. A not valid state is automatically refused and the peer who sent the faulty data is blacklisted temporarily.

## Deterministic execution
Determinism is guaranteed by the fact that Ethereum smart contract programming languages and Ethereum bytecode cannot encode any non-deterministic operations – it’s that simple.

------

## Quorum Architecture 

Quorum Node (Modified GETH client v1.8.x)

It is designed to be a lightweight fork so that it can take advantage of the R&D which takes place within the Ethereum community. It is updated regularly such that it is in line with the future geth releases.

### Some of the modifications done to the quorum node are:

* Two new consensus algorithm created. RAFT and Istanbul BFT.  
* The P2P layer is modified to allow connections only to/from permission nodes.
* The block generation logic has been modified to replace the ‘global state root’ with a new ‘global public state root’.
* The ‘global state root’ in the block header has now been changed to the ‘global public state root’.
* Block validation logic is now modified to handle ‘private transactions.’


### Constellation- Transaction Manager
Constellation refers to a general-purpose system that helps submit information in a secure manner. It can be compared to the Message Transfer Agents network in which messages are encrypted with Pretty Good Privacy (PGP). It consists of two components:

It is responsible for transaction privacy. It allows access to encrypted data. It helps exchange encrypted payloads with the transaction managers of other participants but it does not have access to sensitive private keys. As the transaction manager is restful/stateless, it can be load balanced easily. It uses the enclave to provide cryptographic functionality.

### Constellation: Enclave
Distributed Ledger protocols use cryptographic techniques for preserving historical data and authenticating participants and transactions. Symmetric key generation and data encryption/decryption are delegated to the enclave to provide performance improvements through the parallelization of crypto-operations. It works along with the transaction manager to strengthen privacy by managing encryption/decryption in an isolated manner.

### Deterministic execution
Determinism is guaranteed by the fact that Ethereum smart contract programming languages and Ethereum bytecode cannot encode any non-deterministic operations – it’s that simple.

------

## Hyperledger Architecture:

The architecture of Hyperledger comprises of the following components:

### Consensus Layer: 
This is responsible for generating agreements for each order. It also confirms the correctness of the transactions of a block.

### Smart Contract Layer
It processes transaction requests and executes a business logic to determine if the transactions are valid.

### Communication Layer
This transfers peer-to-peer messages across the nodes.

### Data Store Abstraction
Stores data which can be used by other modules.

### Crypto Abstraction
Swaps different crypto algorithms and modules without affecting other modules.

### Identity Services
This provides authentication and authorization. This helps enroll and register identities or system entities, establish a root of trust, and manage changes such as adds, drops, and modifications.

### Policy Services
It manages various policies such as consensus policy, endorsement policy, or group management policy.

### APIs
This helps clients and applications to interact with blockchains.

### Interoperation
It helps interoperate between various blockchain instances.


### Determinism by endorsement
Chaincode can be hidden from some of a blockchain’s participants, because of this chaincode can do things that are forbidden in other blockchain environments, such as checking the weather using an online web API without an Oracle Smart contract, for example, if an endorser gets a different answer from this API, the client may fail to obtain enough endorsements for any particular outcome, thus no transaction will take place. 
If the blockchain objective is to remove intermediaries from a shared database-driven application, then Fabric’s reliance on endorsers takes a big step away from that goal. For the participants in the chain, it is no longer enough to follow the blockchain code rules – they also need certain other nodes to agree that they have done so. 
In practice, this means that a malicious subset of endorsers could approve database changes that do not follow chaincode rules, this gives endorsers unprecedented power, much more power than the validators/miners/fullnodes in other blockchains, who could censor transactions but would never be allowed to violate the blockchain code rules. 

### Read-write sets
Hyperledger conflict resolution approach works just fine, but in terms of performance and flexibility, it combines the worst of the other two models (Single spend, Contract checks). Endorsements convert transactions into specific read-write sets, Given an example when Alice and Bob simultaneous spend compatible $40 payments would lead to a conflict that Ethereum avoids. The issue is that Hyperledger does not gain the speed advantage of the input-output model, since endorsers only execute contracts using the most recent version of the database confirmed by the blockchain, ignoring unconfirmed transactions.

------

## Corda Architecture:
The architecture of Corda comprises of the following components:

### Input-output
With this model, a conflict between transactions is directly visible, since the two transactions will be explicitly attempting to spend the same previous output.
However given a scenario where both Alice and Bob request smaller $40 payments from the original balance of $100, at exactly the same time. In the input-output model these transactions would conflict, since they are both spending the same database row containing that $100, and only one of the payments would succeed. The Ethereum will allow both transactions to be successfully processed, irrespective of their final order, since the account contains sufficient funds for both. 

### Deterministic execution
Corda uses Oracle’s standard non-deterministic JVM, but work is underway to integrate a deterministic version. In the meantime, Corda contract developers must take care not to allow non-determinism in their code.

### Conflict prevention
Corda is not a blockchain, so “notaries” are required to prevent double spends. Every Corda output state is assigned to a notary, who sign a transaction spending & confirming it has not been spent before. All participants must trust notaries to follow this rule honestly, and malicious notaries can cause havoc at will. 


------

## Benefits of Smilo
* Privacy
* Alternative consensus to PoW
* Peer permissioning
* Higher performance
* Dual token system
* Battle-tested codebase
* Community-driven
* Voting-based consensus mechanisms
* Enhanced contract privacy and transaction
* Possibility of upgrading smart contracts

------

## Benefits of Quorum
* Privacy
* Two Alternative consensuses to PoW
* Peer permissioning
* Higher performance
* Battle-tested codebase
* Community-driven
* Voting-based consensus mechanisms
* Enhanced contract privacy and transaction
* Possibility of upgrading smart contracts

------

## Benefits of Hyperledger
* Privacy
* A handful of alternative consensus to PoW, thus R&D is required to integrate and mold different Fabric implementations.
* Peer permissioning
* Higher performance, depending on the consensus selected
* Relatively new codebase, but it is being used internally by corporations

------

## Benefits of Corda
* Not a blockchain, thus easier to scale.
* Privacy built-in, notaries only talk with who they are interested in.
* Security compromise that allows faster transactions, no consensus is required for transactions, only the notary signature. 
* Peer permissioning
* Higher performance
* Relatively new codebase, but it is being used internally by corporations
