// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public creator;
    uint public fundingGoal;
    uint public deadline;
    mapping(address => uint) public contributions;
    uint public totalContributions;

    enum State { Fundraising, Expired, Successful }
    State public state = State.Fundraising;

    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator can perform this action");
        _;
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid state");
        _;
    }

    constructor(uint _fundingGoal, uint _durationInMinutes) {
        creator = msg.sender;
        fundingGoal = _fundingGoal * 1 ether; // Convert to wei
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    function contribute() external payable inState(State.Fundraising) {
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
    }

    function checkGoalReached() external inState(State.Expired) {
        if (totalContributions >= fundingGoal) {
            state = State.Successful;
        } else {
            state = State.Expired;
        }
    }

    function withdraw() external inState(State.Successful) onlyCreator {
        uint amount = totalContributions;
        totalContributions = 0;
        payable(creator).transfer(amount);
        state = State.Expired;
    }

    function getRefund() external inState(State.Expired) {
        uint refund = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(refund);
    }
}