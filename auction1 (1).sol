// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract auction{
    address public depositor;
    address payable public beneficiary;
    bool public ended;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;
    
    mapping(address => uint256)  pendingReturns;

    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    error AuctionNotYetEnded(uint timeToAuctionEnd);
    error AuctionEndAlreadyCalled();

    constructor(uint256 _auctionEndTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        depositor = msg.sender;
        auctionEndTime = block.timestamp + _auctionEndTime;
    }

    function bid() public payable {
        require( msg.value > highestBid, "There is already a higher bid.");
        require(!ended);
        
        if (highestBidder != address(0)) {
        pendingReturns[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function auctionEnd() public{
        if (block.timestamp < auctionEndTime){
            revert AuctionNotYetEnded(auctionEndTime - block.timestamp);
        }
        if (ended){
            revert AuctionEndAlreadyCalled();
        }
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }

    function withdraw() public returns(bool){
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function getBalance() public view returns(uint){
        return pendingReturns[msg.sender];
    }


}
