// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Streamer
/// @notice A contract that allows a service provider to exchange services to a client for ether
contract Streamer is Ownable {

  mapping(address => uint256) balances;
  mapping(address => uint256) canCloseAt;

  struct Voucher {
    uint256 updatedBalance;
    Signature sig;
  }

  struct Signature {
    bytes32 r;
    bytes32 s;
    uint8 v;
  }

  event Opened(address indexed client, uint256 indexed amount);
  event Challenged(address indexed client);
  event Withdrawn(address indexed owner, uint256 indexed amount);
  event Closed(address indexed client);

  error AlreadyOpened();
  error NoOpenChannel();
  error NoChannelToClose();
  error InvalidSigner();
  error EthTransferFailed();

  /// @notice Clients can fund a channel with ether
  function fundChannel() public payable {
    if (balances[msg.sender] != 0) {
      revert AlreadyOpened();
    }

    balances[msg.sender] += msg.value;

    emit Opened(msg.sender, msg.value);
  }

  /// @notice Time left until the channel can be closed
  /// @param channel The address of the client
  function timeLeft(address channel) public view returns (uint256) {
    if (canCloseAt[channel] == 0 || canCloseAt[channel] < block.timestamp) {
      return 0;
    }

    return canCloseAt[channel] - block.timestamp;
  }

  /// @notice Service providers can withdraw their earnings
  /// @param voucher A voucher containing the updated balance and a signature
  /// @dev The signature must be signed by the client and the client must have a valid channel
  function withdrawEarnings(Voucher calldata voucher) public {
    bytes32 hashed = keccak256(abi.encode(voucher.updatedBalance));
    bytes memory prefixed = abi.encodePacked("\x19Ethereum Signed Message:\n32", hashed);
    bytes32 prefixedHashed = keccak256(prefixed);

    address signer = ecrecover(prefixedHashed, voucher.sig.v, voucher.sig.r, voucher.sig.s);
    if (balances[signer] <= voucher.updatedBalance) {
      revert InvalidSigner();
    }

    uint256 payment = balances[signer] - voucher.updatedBalance;
    balances[signer] = voucher.updatedBalance;

    emit Withdrawn(owner(), payment);

    (bool sent,) = owner().call{value: payment}("");
    if (!sent) {
      revert EthTransferFailed();
    }
  }

  /// @notice Client can challenge the channel
  /// @dev Client needs to have an open channel
  function challengeChannel() public {
    if (balances[msg.sender] == 0) {
      revert NoOpenChannel();
    }

    canCloseAt[msg.sender] = block.timestamp + 30 seconds;

    emit Challenged(msg.sender);
  }

  /// @notice Client can defund the channel and get their remaining funds
  /// @dev Client needs to have a channel that can be closed
  function defundChannel() public {
    if (canCloseAt[msg.sender] == 0 || timeLeft(msg.sender) > 0) {
      revert NoChannelToClose();
    }
    emit Closed(msg.sender);

    (bool sent,) = msg.sender.call{value: balances[msg.sender]}("");
    if (!sent) {
      revert EthTransferFailed();
    }
  }
}
