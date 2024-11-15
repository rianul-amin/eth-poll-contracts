// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollContract {

    struct Poll {
        string title;
        string description;
        string[] options;
        uint256[] votes;
        uint256 duration; 
        uint256 endTime;
        bool isClosed;
    }

    address public admin;  
    mapping(uint256 => Poll) public polls; 
    mapping(address => mapping(uint256 => bool)) public hasVoted; 

    uint256 public pollCount;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyActivePoll(uint256 pollId) {
        if (block.timestamp >= polls[pollId].endTime) {
            polls[pollId].isClosed = true;
        }
        require(!polls[pollId].isClosed, "Poll is already closed");
        _;
    }

    event PollCreated(uint256 pollId, string title, uint256 duration);

    event Voted(uint256 pollId, address voter, uint256 option);

    event PollClosed(uint256 pollId);

    constructor() {
        admin = msg.sender;  
    }

    function createPoll(
        string memory _title,
        string memory _description,
        string[] memory _options,
        uint256 _duration
    ) external onlyAdmin {
        require(_options.length > 1, "There must be at least two options");
        require(_duration > 60, "Duration should be at least 1 minute");

        uint256 pollId = pollCount++;  
        uint256[] memory initialVotes = new uint256[](_options.length);

        polls[pollId] = Poll({
            title: _title,
            description: _description,
            options: _options,
            votes: initialVotes,
            duration: _duration,
            endTime: block.timestamp + _duration,
            isClosed: false
        });

        emit PollCreated(pollId, _title, _duration);
    }

    function vote(uint256 pollId, uint256 optionIndex) external onlyActivePoll(pollId) {
        require(optionIndex < polls[pollId].options.length, "Invalid option");
        require(!hasVoted[msg.sender][pollId], "You have already voted");

        hasVoted[msg.sender][pollId] = true;

        polls[pollId].votes[optionIndex]++;

        emit Voted(pollId, msg.sender, optionIndex);
    }

    function closePoll(uint256 pollId) external onlyAdmin {
        require(!polls[pollId].isClosed, "Poll is already closed");

        polls[pollId].isClosed = true;
        emit PollClosed(pollId);
    }

    function getPollResults(uint256 pollId) external view returns (string[] memory, uint256[] memory) {
        require(polls[pollId].isClosed, "Poll is still active");
        return (polls[pollId].options, polls[pollId].votes);
    }

    function getPollStatus(uint256 pollId) external view returns (string memory status, uint256 remainingTime) {
        if (polls[pollId].isClosed) {
            return ("Closed", 0);
        }
        if (block.timestamp >= polls[pollId].endTime) {
            return ("Expired", 0);
        }
        return ("Active", polls[pollId].endTime - block.timestamp);
    }

}
