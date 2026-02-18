# OFFSET Registry Smart Contract

A Clarity smart contract for tracking carbon credit issuance, transfers, and retirements on the Stacks blockchain.

## Features

- **Ownership & Roles:**  
  - Contract owner can add or remove authorized issuers.
  - Issuers can mint (issue) new carbon credits.

- **Supply Tracking:**  
  - Tracks total issued and retired credits.

- **Balances:**  
  - Users can hold, transfer, and retire credits.

- **Retirement Registry:**  
  - Each retirement event is logged with an ID, owner, and amount.

## Contract Functions

### Initialization

- `initialize`  
  Sets the contract owner. Can only be called once.

### Issuer Management

- `add-issuer (issuer principal)`  
  Adds a new authorized issuer (owner only).

- `remove-issuer (issuer principal)`  
  Removes an issuer (owner only).

### Issuance

- `issue-credits (recipient principal) (amount uint)`  
  Authorized issuers can mint credits to any user.

### Transfers

- `transfer (recipient principal) (amount uint)`  
  Users can transfer credits to others.

### Retirement

- `retire (amount uint)`  
  Burns credits from the sender and logs the event.

### Read-Only Functions

- `get-user-balance (user principal)`  
  Returns the balance of a user.

- `get-total-issued`  
  Returns the total number of credits issued.

- `get-total-retired`  
  Returns the total number of credits retired.

- `get-retirement (id uint)`  
  Returns details of a retirement event.

- `is-authorized-issuer (who principal)`  
  Checks if a principal is an authorized issuer.

## Error Codes

- `ERR-UNAUTHORIZED (100)` — Unauthorized action.
- `ERR-INVALID-AMOUNT (101)` — Amount must be greater than zero.
- `ERR-INSUFFICIENT-BAL (102)` — Not enough balance.
- `ERR-ALREADY-INIT (103)` — Contract already initialized.

## Usage

1. **Deploy the contract.**
2. **Call `initialize`** to set the contract owner.
3. **Owner adds issuers** using `add-issuer`.
4. **Issuers mint credits** with `issue-credits`.
5. **Users transfer or retire credits** as needed.

## Development

- **Check contract:**  
  ```sh
  clarinet check
  ```
- **Run tests:**  
  ```sh
  clarinet test
  ```

