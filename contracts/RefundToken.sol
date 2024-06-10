// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "./IRefundToken.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract RefundToken is IRefundToken, ERC165{
    string public name = "RefundToken";
    string public symbol = "RFT";
    uint256 public decimals = 0; //18 is very common
    uint256 public override totalSupply = 1000000000;

    address public founder;
    mapping(address => uint256) public balances;

    mapping(address => mapping(address => uint256)) allowed;
    uint256 public firstBlock;
    uint256 public refundDuration = 80_640; // 14 days


    constructor(){
        founder = msg.sender;
        balances[founder] = totalSupply;
        firstBlock = block.number;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens);

        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        require(allowed[from][msg.sender] >= tokens);
        require(balances[from] >= tokens);

        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;

        emit Transfer(from, to, tokens);

        return true;
    }

    /// @notice         As long as the refund is active, refunds the user
    /// @dev            Make sure to check that the user has the token, and be aware of potential re-entrancy vectors
    /// @param  amount  The `amount` to refund
    function refund(uint256 amount) public override {
        require(balances[msg.sender] >= amount);
        require(amount > 0);
        require(block.number > firstBlock);
        require(block.number <= firstBlock + refundDuration);
        balances[msg.sender] = amount;
        // allowed[founder][msg.sender] = amount;

        // balances[msg.sender] -= amount;

        emit Refund(msg.sender, amount);
    }

    /// @notice         As long as the refund is active and the sender has sufficient approval, refund the tokens and send the ether to the sender
    /// @dev            Make sure to check that the user has the token, and be aware of potential re-entrancy vectors
    ///                 The ether goes to msg.sender.
    /// @param  from    The user from which to refund the assets
    /// @param  amount  The `amount` to refund
    function refundFrom(address from, uint256 amount) public override {
        require(balances[from] >= amount);
        require(amount > 0);
        require(block.number > firstBlock);
        require(block.number <= refundDeadlineOf());
        balances[msg.sender] += amount;
        balances[from] -= amount;

        emit RefundFrom(msg.sender, from, amount);
    }

    /// @notice         Gets the refund price
    /// @return _wei    The amount of ether (in wei) that would be refunded for a single token unit (10**decimals indivisible units)
    function refundOf() public override view returns (uint256 _wei) {
        return balances[msg.sender] * (10**18);
    }

    /// @notice         Gets the first block for which the refund is not active
    /// @return blockNumber   The first block where the token cannot be refunded
    function refundDeadlineOf() public override view returns (uint256 blockNumber) {
        return firstBlock + refundDuration;
    }
}
